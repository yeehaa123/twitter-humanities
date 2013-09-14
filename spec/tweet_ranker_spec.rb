require 'spec_helper'

describe TweetRanker do
  let(:parser)    { TweetParser.new }
  let(:tweets)    { parser.tweets}
  let(:words)     { parser.words }
  let(:tweeters)  { parser.tweeters }

  before do
    VCR.insert_cassette 'twitter-humanities'
    parser.populate
  end

  after do
    VCR.eject_cassette
  end

  describe "#rank_tweeters" do

    let(:ranker) { TweetRanker.new.rank_tweeters(tweeters) }

    it "should return the most popular authors" do
      ranker.size.must_equal 20
    end 

    it "should have TLTP with 2 tweets as the first tweeter" do
      ranker.first[:name].must_equal "TLTP"
      ranker.first[:count].must_equal 36
      ranker.first[:ranked].must_equal true
    end

    it "should have JasonManier with 10 tweets as the last tweeter" do
      ranker.last[:name].must_equal "ArtsAlertz"
      ranker.last[:count].must_equal 3
      ranker.first[:ranked].must_equal true
    end
  end

  describe "#rank_concepts" do

    let(:ranker) { TweetRanker.new.rank_concepts(words) }

    it "should return 11 concepts" do
      ranker.size.must_equal 20
    end
    
    it "should have art with 2 tweets as the first concept" do
      ranker.first[:name].must_equal "art"
      ranker.first[:count].must_equal 99 
      ranker.first[:ranked].must_equal true
    end

    it "should have history with 2 tweets as the last concept" do
      ranker.last[:name].must_equal "essay" 
      ranker.last[:count].must_equal 25
      ranker.first[:ranked].must_equal true
    end
  end
end
