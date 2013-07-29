class TweetRanker

  def rank_concepts(words)
    concepts = []
    words.each do |word|
      concept = concepts.find {|concept| concept[:name] == word } 
      if concept  
        concept[:count] += 1
      else
        concepts << Hash[:name, word, :count, 1, :ranked, true]
      end
    end
    rank(concepts)
  end

  alias :rank_tweeters :rank_concepts

  private

  def rank(rankable)
    rankable.select! { |concept| concept[:count] > 1 }
    ranked_by_name = rankable.sort_by {|concept| concept[:name] }
    ranked_by_count = ranked_by_name.sort_by {|concept| concept[:count] }.reverse.take(11)
  end
end
