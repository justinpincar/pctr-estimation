require "ai4r"

REPORT_INTERVAL = ARGV[0].to_i
RUN_LENGTH = ARGV[1].nil? ? nil : ARGV[1].to_i

# Calculated from the entire training data set
MEAN_CTR = 0.03488213165100169

# Averages calculated off of first 10,000 rows in training.txt
KEYWORDS_AVG_LENGTH = 3 #3.220632348763987
KEYWORDS_AVG_MATCH_VAL = 0.2538000000000004

@ads = {}
@advertisers = {}
@keywords = {}
@queries = {}

def log(msg)
  warn("#{Time.now}: #{msg}")
end

def gc()
  log("Garbage collecting...")
  GC.start()
  log("OK")
end

def init_ads
  log("Loading ads...")
  ads_file = File.new("_ads.txt#{RUN_LENGTH.nil? ? "" : ".#{RUN_LENGTH}"}", "r")
  line_number = 0
  while (line = ads_file.gets)
    line.chomp!
    elements = line.split("\t")

    @ads[elements[0]] = elements[1].to_f

    line_number += 1
    if line_number % REPORT_INTERVAL == 0
      log("Processed #{line_number} lines...")
    end
  end
  log("OK")
end

def init_advertisers
  log("Loading advertisers...")
  advertisers_file = File.new("_advertisers.txt#{RUN_LENGTH.nil? ? "" : ".#{RUN_LENGTH}"}", "r")
  line_number = 0
  while (line = advertisers_file.gets)
    line.chomp!
    elements = line.split("\t")

    @advertisers[elements[0]] = elements[1].to_f

    line_number += 1
    if line_number % REPORT_INTERVAL == 0
      log("Processed #{line_number} lines...")
    end
  end
  log("OK")
end

def init_keywords
  log("Loading keywords...")
  keywords_file = File.new("purchasedkeywordid_tokensid.txt#{RUN_LENGTH.nil? ? "" : ".#{RUN_LENGTH}"}", "r")
  line_number = 0
  while (line = keywords_file.gets)
    line.chomp!
    elements = line.split("\t")

    keyword_id = elements[0]
    @keywords[keyword_id] = elements[1]

    line_number += 1
    if line_number % REPORT_INTERVAL == 0
      log("Processed #{line_number} lines...")
    end
  end
  log("OK")
end

def init_queries
  log("Loading queries...")
  queries_file = File.new("queryid_tokensid.txt#{RUN_LENGTH.nil? ? "" : ".#{RUN_LENGTH}"}", "r")
  line_number = 0
  while (line = queries_file.gets)
    line.chomp!
    elements = line.split("\t")

    query_id = elements[0]
    @queries[query_id] = elements[1]

    line_number += 1
    if line_number % REPORT_INTERVAL == 0
      log("Processed #{line_number} lines...")
    end
  end
  log("OK")
end

def write_training_data
  log("Writing training data...")
  training_file = File.new("training.txt#{RUN_LENGTH.nil? ? "" : ".#{RUN_LENGTH}"}", "r")
  training_data_file = File.new("_training.txt#{RUN_LENGTH.nil? ? "" : ".#{RUN_LENGTH}"}", "w")
  line_number = 0
  keywords_match_count = 0
  keyword_total_matches = 0
  keyword_lengths = 0
  while (line = training_file.gets)
    line.chomp!
    elements = line.split("\t")

    clicks = elements[0].to_i
    impressions = elements[1].to_i
    ad_id = elements[3]
    advertiser_id = elements[4]
    query_id = elements[7]
    keyword_id = elements[8]

    observed_ctr = clicks / impressions.to_f

    ad_pctr = @ads[ad_id] || @advertisers[advertiser_id] || MEAN_CTR

    keyword_line = @keywords[keyword_id] || ""
    keyword_tokens = keyword_line.split("|")
    query_line = @queries[query_id]
    if query_line.nil?
      keyword_match_val = KEYWORDS_AVG_MATCH_VAL
    else
      query_tokens = query_line.split("|")
      keyword_matches = (keyword_tokens & query_tokens).length
      keyword_match_val = keyword_matches == 0 ? 0.to_f : keyword_matches / [keyword_tokens.length, KEYWORDS_AVG_LENGTH].min.to_f
      keyword_total_matches += keyword_matches
      keywords_match_count += 1
      keyword_lengths += keyword_tokens.length
    end


    #if keyword_match_val.nan?
    #  log("query_tokens: #{query_tokens}")
    #  log("keyword_tokens: #{keyword_tokens}")
    #  log("keyword_matches: #{keyword_matches}")
    #  log("keyword_match_val: #{keyword_match_val}")
    #end

    #log("Observed ctr: #{observed_ctr}")
    #log("Ad pctr: #{ad_pctr}")
    #log("Keyword_match_val: #{keyword_match_val}")

    training_data_file.puts("#{observed_ctr}\t#{ad_pctr}\t#{keyword_match_val}")

    line_number += 1
    if line_number % REPORT_INTERVAL == 0
      log("Processed #{line_number} lines...")
    end
  end
  log("Average keyword_matches: #{keyword_total_matches / keywords_match_count.to_f}")
  log("Average keywords_length: #{keyword_lengths / keywords_match_count.to_f}")
  training_file.close
  training_data_file.close
  log("OK")
end

def write_test_data
  log("Calculating pctrs...")
  test_file = File.new("test.txt#{RUN_LENGTH.nil? ? "" : ".#{RUN_LENGTH}"}", "r")
  test_data_file = File.new("_test.txt#{RUN_LENGTH.nil? ? "" : ".#{RUN_LENGTH}"}", "w")
  line_number = 0
  while (line = test_file.gets)
    line.chomp!
    elements = line.split("\t")

    ad_id = elements[1]
    advertiser_id = elements[2]
    query_id = elements[5]
    keyword_id = elements[6]

    ad_pctr = @ads[ad_id] || @advertisers[advertiser_id] || MEAN_CTR

    keyword_line = @keywords[keyword_id] || ""
    keyword_tokens = keyword_line.split("|")
    query_line = @queries[query_id]
    if query_line.nil?
      keyword_match_val = KEYWORDS_AVG_MATCH_VAL
    else
      query_tokens = query_line.split("|")
      keyword_matches = (keyword_tokens & query_tokens).length
      keyword_match_val = keyword_matches == 0 ? 0.to_f :  keyword_matches / [keyword_tokens.length, KEYWORDS_AVG_LENGTH].min.to_f
    end

    test_data_file.puts("#{ad_pctr}\t#{keyword_match_val}")

    line_number += 1
    if line_number % REPORT_INTERVAL == 0
      log("Processed #{line_number} lines...")
    end
  end
  test_file.close
  test_data_file.close
  log("OK")
end

init_ads()
gc()
init_advertisers()
gc()
init_keywords()
gc()
init_queries()
gc()
write_training_data()
gc()
write_test_data()

# Thoughts:
# pctr = {ad_pctr | content_pctr | user_pctr}
# ad_pctr = ad_ctr || advertiser_ctr || ?similar_ads_ctr || mean_ctr
# content_pctr = {keyword_match_val | description_match_val | title_match_val}
# user_pctr = ?

