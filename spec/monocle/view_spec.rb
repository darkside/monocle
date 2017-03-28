require 'spec_helper'

RSpec.describe Monocle::View do
  subject { described_class.new "foo" }

  before do
    Monocle.stubs(:views_path).returns(File.join(Monocle.root, "spec/fixtures"))
  end

  describe "#initialize" do
    it "assigns to name and dependants" do
      expect(subject.name).to eq "foo"
      expect(subject.dependants).to eq []
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
    it "calls #execute with drop_command" do
      subject.expects(:execute).with(subject.drop_command).once
      expect(subject.drop).to eq true
    end

    context "with a dependant views" do
      subject { described_class.new('parent') }
      let(:foo) { described_class.new('foo')  }
      let(:bar) { described_class.new('bar')  }

      let(:list) {
        { foo: foo, bar: bar, parent: subject }
      }

      before do
        Monocle.stubs(:list).returns(list)
        subject.stubs(:execute).with(subject.drop_command).raises(ActiveRecord::StatementInvalid, "PG::DependentObjectsStillExist \n
        foo depends on materialized view #{subject.name} \n
        bar depends on materialized view #{subject.name}").then.returns(true)
      end

      it "calls drop on them" do
        foo.expects(:drop).once
        bar.expects(:drop).once
        subject.drop
      end
    end
  end

  describe "#create" do
    let(:foo) { described_class.new('foo')  }
    let(:bar) { described_class.new('bar')  }

    it "calls #execute with #create_command" do
      subject.expects(:execute).with(subject.create_command)
      subject.create
    end

    it "creates a new version" do
      subject.create
      expect(Monocle::Migration.exists?(version: subject.slug)).to eq true
    end

    it "calls #create on its dependants" do
      subject.stubs(:dependants).returns([foo, bar])
      foo.expects(:create).once
      bar.expects(:create).once
      subject.create
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

  describe "#migrate" do
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

  describe "#slug" do
    it "returns the version generator slug" do
      expect(subject.slug).to match /#{subject.name}_\d+/
    end
  end

end
