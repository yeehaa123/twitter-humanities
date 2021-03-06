require 'spec_helper'

describe TweetParser do
  let(:parser)          { TweetParser.new }
  let(:tweets)          { parser.tweets }
  let(:tweeters)        { parser.tweeters }
  let(:words)           { parser.words }
  let(:population_size) { 693 }

  before do
    VCR.insert_cassette 'twitter-humanities'
    parser.populate
  end

  after do
    VCR.eject_cassette
  end

  describe "#populate" do
    it "should return all elements" do
      tweets.size.must_be :>=, population_size
    end
  end

  describe "#tweeters" do
    it "should return all tweeters" do
      tweeters.size.must_equal population_size
      tweeters.uniq.size.must_be :<,  population_size
    end
  end
  
  describe "#words" do
    it "should return all words" do
      words.size.must_equal 5062
    end
  end
end
