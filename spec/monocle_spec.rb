require "spec_helper"

RSpec.describe Monocle do
  subject { described_class }

  it "has a version number" do
    expect(Monocle::VERSION).not_to be nil
  end

  describe "#list" do
    # This memoizes
    before do
      subject.instance_variable_set(:'@list', nil)
    end
    it "triggers ListCommand.new.call" do
      list_cmd = mock('ListCommand')
      Monocle::ListCommand.expects(:new).returns(list_cmd)
      list_cmd.expects(:call).once
      subject.list
    end
  end

  describe "#versions" do
    it "delegates to Monocle::Migration" do
      Monocle::Migration.expects(:versions).once
      subject.versions
    end
  end

  describe "#migrate" do
    it "calls #migrate on every view" do
      subject.list.values.each do |view|
        view.expects(:migrate).once
      end
      subject.migrate
    end
  end

  describe "#create" do
    it "triggers create on the view" do
      view_name = "lala"
      view = mock(create: true)
      subject.expects(:fetch).with(view_name).returns(view)
      subject.create(view_name)
    end
  end

  describe "#refresh" do
    it "triggers refresh on the view" do
      view_name = "lala"
      view = mock(refresh: true)
      subject.expects(:fetch).with(view_name).returns(view)
      subject.refresh(view_name)
    end
  end

  describe "#refresh_all" do
    it "triggers refresh on all views" do
      view1 = mock(refresh: true)
      view2 = mock(refresh: true)
      subject.stubs(:list).returns({foo: view1, bar: view2})
      subject.refresh_all
    end
  end

  describe "#drop" do
    it "triggers drop on the view" do
      view_name = "lala"
      view = mock(drop: true)
      subject.expects(:fetch).with(view_name).returns(view)
      subject.drop(view_name)
    end
  end

  describe "#bump" do
    it "triggers a BumpCommand with the view" do
      view_name = "lala"
      view = stub
      subject.expects(:fetch).with(view_name).returns(view)
      Monocle::BumpCommand.expects(:new).with(view).returns(mock call: true)
      subject.bump(view_name)
    end
  end

  describe "#configure" do
    it "returns a configuration block" do
      subject.configure do |c|
        expect(c).to be_a Monocle::Configuration
      end
    end

    it "takes configurations" do
      subject.configure do |c|
        c.path_to_views = "lala/land"
      end
      expect(subject.path_to_views).to eq "lala/land"
    end
  end

  describe "#views_path" do
    it "returns the absolute path to the views" do
      expect(subject.views_path).to eq File.join(subject.root, subject.path_to_views)
    end
  end

  describe "#root" do
    it "returns an expanded Dir.pwd" do
      expect(subject.root).to eq File.expand_path(Dir.pwd)
    end
  end
end
