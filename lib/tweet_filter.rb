class TweetFilter

  def filter_words(words)
    words = remove_hashtags(words)
    words = remove_hyperlinks(words) 
    words = remove_tweeters(words)
    words = clean_words(words)
    filter_trivial_words(words) 
  end

  private
  
  def remove_hashtags(words)
    words.map { |word| word.gsub(/\#/, "") }
  end

  def remove_tweeters(words)
    words.reject { |word| word =~ /[\@]/ }
  end
  
  def remove_hyperlinks(words)
    words.reject { |word| word =~ /http/ }
  end

  def clean_words(words)
    clean_regex = /[\W\d]/
    words.map! { |word| word.downcase.gsub(/s$/, "") }
    words.map! { |word| word.downcase.gsub(clean_regex, "") }
    words.reject { |word| word if word == "" }
  end

  def filter_trivial_words(words)
    trivial_words = <<-EOL 
lord stern dont test phuckmat neh house harap lahat choice highered entering three humanities do not humanitiesthe could about geography percent sixty and oh know chelmsford have or is on the of for by to de RT the we how tawanan with yay zemon you what was saying without add day are ng ang any apchemalso through bexley big them than they yes yea write wrote makapagdrawing more rt via amp this finds your our from that if two ko my youve heres us make socialsciences in ba humanitie a i na sa thi c at p no it here be clas u publichumanitie should but like both way side require altac 
    EOL
    words.reject { |word| word if trivial_words.split(" ").include? word }
  end
end
