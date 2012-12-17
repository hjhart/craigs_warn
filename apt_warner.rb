require 'rubygems'
require 'libcraigscrape'
require 'prowl'
require 'uri'
require 'cgi'
require 'fileutils'
require 'prowl_notifier'
require 'yaml'
require 'pony'

urls = ["http://sfbay.craigslist.org/search/apa/sfc?query=&srchType=A&zoomToPosting=&minAsk=2400&maxAsk=3300&bedrooms=2&nh=2&nh=149&nh=4&nh=12&nh=14&nh=10&nh=24&nh=18&nh=23&nh=30"]

urls.each do |url|
  listing = CraigScrape::Listings.new url
  current_listings_count = listing.posts.length
  puts "Found %d posts for the search on this page" % current_listings_count

  FileUtils.mkdir_p('search_counts/apartments')
  listing.posts.each do |post|
    posting_url = post.url
    number = posting_url.match(/\d+/)[0]
    puts "The number matched was #{number} on #{posting_url}"

    search_count_file = File.join('search_counts', 'apartments', number)

    unless (File.exists? search_count_file)
      puts "Never seen this one before, marking as unsent."
      File.open(search_count_file, 'w') { |f| f.puts current_listings_count }
      event, description = "Found new apartment", "Location: #{post.location}\n#{post.label} #{post.price}"
      send_email event, description, posting_url
      puts "Sending email message: #{event}, #{description}"
    end
  end
end
