require 'spec_helper'

RSpec.describe Monocle::Configuration do
  subject { described_class.new }

  describe "#path_to_views" do
    it "returns the default path to views" do
      expect(subject.path_to_views).to eq "db/views"
    end
  end

  describe "#path_to_views=" do
    it "sets the new path to views" do
      subject.path_to_views = "some/weird/path"
      expect(subject.path_to_views).to eq "some/weird/path"
    end
  end

  describe "#logger" do
    it "returns a logger" do
      expect(subject.logger).to be_a Logger
    end
  end

  describe "#logger=" do
    it "sets a logger" do
      logger = Logger.new(STDERR)
      subject.logger = logger
      expect(subject.logger).to eq logger
    end
  end

end
