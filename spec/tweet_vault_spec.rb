require 'spec_helper'

describe TweetVault do
  let(:vault) { TweetVault.new(100)} 

  before do
    VCR.insert_cassette 'twitter-humanities'
  end

  after do
    VCR.eject_cassette
  end

  describe "#concepts" do
    it "should return the 20 most tweeted concepts" do
      vault.concepts.size.must_equal 20
    end

    it "should have the right attributes" do
      vault.concepts.each do |concept|
        concept["name"].must_match(/\w*/)
        concept["count"].must_be :>=, 2
        concept["ranked"].must_equal true 
      end
    end
  end

  describe "#past_concepts" do
    describe "before update" do
      it "should return the 11 original concepts" do
        vault.past_concepts.size.must_equal 11
      end

      it "should have the right attributes" do
        vault.past_concepts.each do |concept|
          concept[:name].must_match(/\w*/)
        end
      end
    end
  end

  describe "#future_concepts" do
    it "should return the 11 original concepts" do
      vault.future_concepts.size.must_equal 11
    end
  end
end
