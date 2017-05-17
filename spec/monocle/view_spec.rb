require 'spec_helper'

RSpec.describe Monocle::View do
  subject { described_class.new "foo" }

  before do
    Monocle.stubs(:views_path).returns(File.join(Monocle.root, "spec/fixtures"))
  end

  describe "#initialize" do
    it "assigns to name" do
      expect(subject.name).to eq "foo"
    end
  end

  describe "#materialized?" do
    context "with a materialized view" do
      it "returns true" do
        expect(subject.materialized?).to eq true
      end
    end

    context "with a normal view" do
      subject { described_class.new "normal_view" }
      it "returns false" do
        expect(subject.materialized?).to eq false
      end
    end
  end

  describe "#drop" do
    context "with no dependants" do
      it "drops the view from the database" do
        expect(subject.drop).to eq true
        expect(subject.exists?).to eq false
      end
    end

    context "with a dependant views" do
      subject { described_class.new('parent_with_no_data') }
      let(:child) { described_class.new('child_with_no_data') }

      let(:list) {
        { parent_with_no_data: subject, child_with_no_data: child }
      }

      before do
        Monocle.stubs(:list).returns(list)
        subject.create
        child.create
      end

      it "calls drop on them" do
        expect(subject.drop).to eq true
        expect(subject.exists?).to eq false
        expect(child.exists?).to eq false
      end
    end
  end

  describe "#create" do

    before do
      subject.drop
    end

    it "creates the view in the database" do
      subject.create
      expect(subject.exists?).to eq true
    end

    it "creates a new version" do
      subject.create
      expect(Monocle::Migration.exists?(version: subject.slug)).to eq true
    end

    context "with dependants" do
      let(:foo) { described_class.new('foo')  }
      let(:bar) { described_class.new('bar')  }

      it "calls #create on its dependants" do
        subject.stubs(:dependants).returns([foo, bar])
        foo.expects(:create).once
        bar.expects(:create).once
        subject.create
      end
    end

    context "when the version already exists" do
      before do
        Monocle::Migration.create version: subject.slug
      end

      it "doesn't create a new version" do
        expect { subject.create }.not_to change { Monocle::Migration.count }
      end
    end

    context "when creation depends on a view that doesn't exist yet" do
      subject { described_class.new('bad_matview') }

      it "raises an error" do
        expect { subject.create }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end

  describe "#refresh" do
    it "triggers a materialized view refresh" do
      subject.expects(:execute).with("REFRESH MATERIALIZED VIEW #{subject.name}")
      subject.refresh
    end

    context "with a dependant materialized view" do
      subject { described_class.new('child_with_no_data') }
      let(:parent) { described_class.new('parent_with_no_data')  }
      let(:list) {
        { parent_with_no_data: parent, child_with_no_data: subject }
      }
      before do
        Monocle.stubs(:list).returns(list)
        subject.drop; parent.drop
        parent.create; subject.create
      end

      it "triggers refresh on it if it needs to" do
        expect(subject.refresh).to eq true
      end
    end
  end

  describe "#migrate" do
    context "when you have a new view that depends on another new view that wasn't created yet" do
      subject { described_class.new('view_a') }
      it "creates the dependant view first, then creates it" do
        expect { subject.migrate }.not_to raise_error
        view_a = Monocle.fetch("view_a")
        view_b = Monocle.fetch("view_b")
        expect(Monocle.versions).to include(view_a.slug)
        expect(Monocle.versions).to include(view_b.slug)
      end
    end

    it "calls drop then migrate" do
      subject.expects(:drop).once.returns(true)
      subject.expects(:create).once.returns(true)
      subject.migrate
    end

    context "when versions include the slug" do
      before do
        Monocle::Migration.create version: subject.slug
      end

      it "doesn't do anything" do
        subject.expects(:drop).never
        subject.expects(:create).never
        subject.migrate
      end
    end
  end

  describe "#exists?" do
    context "with a view that haven't been created yet" do
      subject { described_class.new('lala') }

      it "returns false" do
        expect(subject.exists?).to eq false
      end
    end

    context "with a view that has been created" do
      subject { described_class.new('matview_uptodate') }

      it "returns false" do
        subject.create
        expect(subject.exists?).to eq true
      end
    end
  end

  describe "#get_dependants_from_pg" do
    let(:view_a) { described_class.new('view_a') } # queries view b
    let(:view_b) { described_class.new('view_b') }

    before do
      subject.stubs(:list).returns({view_a: view_a, view_b: view_b})
    end

    it "returns a list of dependants without the original view name" do
      deps = view_b.send(:get_dependants_from_pg).map(&:name)
      expect(deps).to include('view_a')
      expect(deps).not_to include('view_b')
    end
  end

  describe "#slug" do
    it "returns the version generator slug" do
      expect(subject.slug).to match /#{subject.name}_\d+/
    end
  end

end
