require 'rubygems'
require 'libcraigscrape'
require 'prowl'
require 'uri'
require 'cgi'
require 'fileutils'
require 'prowl_notifier'
require 'yaml'

search_terms_file = File.join  'search_terms.yml'
search_terms = YAML.load File.open(search_terms_file).read

search_terms.each do |decoded_search_term|
  search_term = CGI.escape(decoded_search_term)

  url = "http://sfbay.craigslist.org/search/?areaID=1&subAreaID=&query=#{search_term}&catAbb=sss"
  listing = CraigScrape::Listings.new url
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
    event, description = "Found new #{decoded_search_term} posting", "Total results: #{current_listings_count}.\n Newest: #{last_posting.label}"
    prowl_message event, description, url

    File.open(search_count_file, 'w') { |f| f.puts current_listings_count }
    puts "Sending prowl message: #{event}, #{description}"
  elsif current_listings_count < previous_listing_count
    File.open(search_count_file, 'w') { |f| f.puts current_listings_count }
    puts "Less postings detected. Decreasing the count."
  else
    puts "The count was the same (at #{current_listings_count})"
  end
end
  

