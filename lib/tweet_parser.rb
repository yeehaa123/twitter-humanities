require 'twitter'
require_relative '../config/twitter_config'
require 'json'

class TweetParser
  attr_reader :tweets

  def initialize
    @since_id ||= 1 
    @old_since_id ||= 1
    @tweets = [] 
  end

  def tweeters
    @tweeters ||= []
  end

  def tweets
    @tweets ||= []
  end

  def words
    words = []
    tweets.each { |tweet| words << tweet.split(/\s+/) }
    words = words.flatten
    filter.filter_words(words)
  end

  def populate
    loop do
      add_tweets
      break tweets if @since_id == @old_since_id 
    end
    @tweets = tweets
  end

  private

  def tweet_texts(tweets)
    tweets.map {|tweet| tweet.text }
  end

  def tweet_authors(tweets)
    tweets.map do |tweet| 
      if tweet.user != nil
        tweet.user.screen_name
      end
    end
  end

  def add_tweets
    if @since_id == 1
      query = Twitter.search("#humanities", count: 100, result_type: "recent")
    else
     query = Twitter.search("#humanities", count: 100, max_id: @since_id, result_type: "recent")
    end
    tweets.concat(tweet_texts(query.results))
    tweeters.concat(tweet_authors(query.results))
    @old_since_id = @since_id
    @since_id = query.results.last.id 
  end

  def filter
    TweetFilter.new
  end
end
