require_relative 'tweet_filter'
require_relative 'tweet_ranker'
require_relative 'tweet_parser'
require 'redis'

class TweetVault
  attr_reader :redis, :ranker, :parser

  def initialize(amount_of_tweets)
    @redis  ||= Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    # @redis ||= Redis.new
    @ranker ||= TweetRanker.new
    @parser ||= TweetParser.new
    set_past_concepts
    set_future_concepts
  end

  def concepts
    update_concepts
  end

  def past_concepts
    cc = concepts.map {|concept| concept["name"]}
    @pc.map do |concept|
      cc.include?(concept[:name]) ? concept[:ranked] = true : concept[:ranked] = false
      concept
    end
  end

  def future_concepts
    cc = concepts.map {|concept| concept["name"]}
    @fc.map do |concept|
      cc.include?(concept[:name]) ? concept[:ranked] = true : concept[:ranked] = false
      concept
    end
  end

  private

  def update_concepts
    redis_object = redis.get("concepts")
    if redis_object == nil
      redis_object = fetch_concepts
    else
      redis_object = JSON.parse(redis_object)
      redis.expire('concepts', 1)
    end 
    redis_object
  end

  def fetch_concepts
    parser.populate
    redis_object = ranker.rank_concepts(words)
    redis.set("concepts", redis_object.to_json)
    redis.expire('concepts', 3600)
    redis_object 
  end

  def set_past_concepts
    @pc = %w{art job hiring new degree career teacher education neglect oppose history}
    @pc.map! {|concept| Hash[:name, concept, :ranked, false]}
  end

  def set_future_concepts
    @fc = %w{code algorithm javascript digital future ruby html css language data visualisation}
    @fc.map! {|concept| Hash[:name, concept, :ranked, false]}
  end

  def words
    parser.words
  end

  def uri
    uri = URI.parse(ENV["REDISCLOUD_URL"])
  end
end
