require 'spec_helper'

RSpec.describe Monocle::ListCommand do
  before do
    Monocle.stubs(:views_path).returns(File.join(Monocle.root, "spec/fixtures"))
  end

  subject { described_class.new }

  describe "#initialize" do
    it "instantiates @view_names" do
      expect(subject.view_names).to be_present
    end
  end

  describe "#call" do
    it "returns a hash with keys being view names and values being Views" do
      hash = subject.call
      expect(hash).to be_a Hash
      hash.each do |key, value|
        expect(key).to be_a Symbol
        expect(value).to be_a Monocle::View
        expect(value.name).to eq key.to_s
      end
    end
  end
end
