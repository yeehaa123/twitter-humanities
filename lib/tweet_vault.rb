require_relative 'tweet_filter'
require_relative 'tweet_ranker'
require_relative 'tweet_parser'
require 'redis'

class TweetVault
  attr_reader :redis, :ranker
  
  def initialize(amount_of_tweets)
    @amount_of_tweets = amount_of_tweets
    @redis  ||= Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    @ranker ||= TweetRanker.new
  end

  def tweeters
    JSON.parse(redis.get("tweeters"))
  end

  def concepts
    # update_tweets
  end

  def past_concepts
    JSON.parse(redis.get("past_concepts"))
  end

  def future_concepts
    JSON.parse(redis.get("future_concepts"))
  end

  private

  def parser
    @parser ||= TweetParser.new
  end 

  def update_tweets
    redis_object = redis.get("concepts")
    if redis_object == nil
      update_concepts
    else
      redis_object = JSON.parse(redis_object)
    end 
    redis_object
  end

  def update_concepts
    redis_object = ranker.rank_concepts(words)
    [past_concepts, future_concepts, tweeters].each do |concepts|
      update_redis(concepts)
    end
    redis.set("concepts", redis_object.to_json)
    redis.expire('concepts', 3600)
    redis_object 
  end

  def update_redis(concepts_name)
    concepts_to_update = redis.get("#{concepts_name}")
    current_concepts = concepts.map { |concept| concept["name"] } 
    updated_concepts = concepts_to_update.map do |concept| 
      if current_concepts.include?(concept["name"])
        concept["ranked"] = true
        concept
      else
        concept["ranked"] = false
        concept
      end
    end
    redis.set("#{concepts_name}", updated_concepts.to_json)
    updated_concepts.shuffle
  end

  def set_past_concepts
    past_concepts = %w{art job hiring new degree career teacher education neglect oppose history}
    past_concepts.map {|concept| Hash[:name, concept, :ranked, false]}
  end

  def set_future_concepts
    future_concepts = %w{code algorithm javascript make future ruby html css language data visualisation}
    future_concepts.map {|concept| Hash[:name, concept, :ranked, false]}
  end

  def unranked_tweeters
    #parser.tweeters
  end

  def words
    parser.words
  end

  def uri
    uri = URI.parse(ENV["REDISCLOUD_URL"])
  end
end
