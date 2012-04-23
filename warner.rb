require 'rubygems'
require 'libcraigscrape'
require 'prowl'
require 'ap'
require 'uri'
require 'cgi'
require 'fileutils'

def prowl_message event, description, url=nil
  require 'prowl'
  
  prowl_config_file = File.join  'prowl.yml'
  if File.exists? prowl_config_file
    prowl_config = YAML.load File.open(prowl_config_file).read
    if prowl_config["active"]
      Prowl.add(
        :apikey => prowl_config["api_key"],
        :application => "CraigsWarn",
        :event => event,
        :description => description,
        :url => url
      )
    end
  end
  puts "Prowl notification sent '#{event}'"
end

decoded_search_term = 'buster keaton'
search_term = CGI.escape(decoded_search_term)

listing = CraigScrape::Listings.new "http://sfbay.craigslist.org/search/?areaID=1&subAreaID=&query=#{search_term}&catAbb=sss"
current_listings_count = listing.posts.length
puts "Found %d posts for the search '#{decoded_search_term}' on this page" % current_listings_count

FileUtils.mkdir_p('search_counts')
search_count_file = File.join('search_counts', search_term)

if(File.exists? search_count_file)
  previous_listing_count = File.open(search_count_file, 'r').read.to_i
else
  puts "Never seen this one before, creating the count file."
  previous_listing_count = 0
  File.open(search_count_file, 'w') { |f| f.puts current_listings_count }
end


if current_listings_count > previous_listing_count
  last_posting = listing.posts.first
  event, description = "Counts don't match", "Posting titled: #{last_posting.label}"
  File.open(search_count_file, 'w') { |f| f.puts current_listings_count }
  puts "Sending prowl message: #{event}, #{description}"
  prowl_message "New Craigslist Post", last_posting.label, last_posting.url
elsif current_listings_count < previous_listing_count
  File.open(search_count_file, 'w') { |f| f.puts current_listings_count }
  puts "Less postings detected. Decreasing the count."
else
  puts "The count was the same (at #{current_listings_count})"
end

  

