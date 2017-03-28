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
end
