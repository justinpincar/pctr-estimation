REPORT_INTERVAL = ARGV[0].to_i
RUN_LENGTH = ARGV[1].nil? ? nil : ARGV[1].to_i

def log(msg)
  warn("#{Time.now}: #{msg}")
end

total_clicks = 0
total_impressions = 0

@ads = {}
@advertisers = {}

log("Loading training data...")
training_file = File.new("training.txt#{RUN_LENGTH.nil? ? "" : ".#{RUN_LENGTH}"}", "r")
line_number = 0
while (line = training_file.gets)
  line_number += 1
  elements = line.split("\t")

  clicks = elements[0].to_i
  impressions = elements[1].to_i
  ad_id = elements[3]
  advertiser_id = elements[4]

  ad = @ads[ad_id]
  if ad.nil?
    ad = {}
    ad['clicks'] = clicks
    ad['impressions'] = impressions
    @ads[ad_id] = ad
  else
    ad['clicks'] += clicks
    ad['impressions'] += impressions
  end

  advertiser = @advertisers[advertiser_id]
  if advertiser.nil?
    advertiser = {}
    advertiser['clicks'] = clicks
    advertiser['impressions'] = impressions
    @advertisers[advertiser_id] = advertiser
  else
    advertiser['clicks'] += clicks
    advertiser['impressions'] += impressions
  end

  total_clicks += clicks
  total_impressions += impressions

  if line_number % REPORT_INTERVAL == 0
    log("Processed #{line_number} lines...")
  end
end
log("OK")

@mean_ctr = total_clicks/total_impressions.to_f
log("mean_ctr: #{@mean_ctr}")

log("Writing ad data...")
ads_file = File.new("_ads.txt#{RUN_LENGTH.nil? ? "" : ".#{RUN_LENGTH}"}", "w")
@ads.each_pair do |ad_id, ad|
  ad_pctr = ad['clicks']/ad['impressions'].to_f
  ads_file.puts("#{ad_id}\t#{ad_pctr}")
end
ads_file.close

log("Writing advertisers data...")
advertisers_file = File.new("_advertisers.txt#{RUN_LENGTH.nil? ? "" : ".#{RUN_LENGTH}"}", "w")
@advertisers.each_pair do |advertiser_id, advertiser|
  advertiser_pctr = advertiser['clicks']/advertiser['impressions'].to_f
  advertisers_file.puts("#{advertiser_id}\t#{advertiser_pctr}")
end
advertisers_file.close

