#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'
require 'net/smtp'

def title_match?(title)
  pattern_file = "/home/changeme/patterns.txt"
  pattern = /#{File.read(pattern_file).gsub("\n","|").chop}/i
  pattern.match(title)
end

def send_mail(item)

  fromaddr = 'changeme'
  toaddr = 'changeme@gmail.com'

  Net::SMTP.start('localhost', 25) do |smtp|
    msg = <<END
From: ODT Watcher <changeme@changeme.com>
To: changeme <changeme@changeme.com>
Subject: #{item['type']}: #{item['title']} - #{item['location']} - #{item['price']}

#{item['link']}

END

    smtp.send_message msg, fromaddr, toaddr
  end
end

def process_match(item)
  File.open('/home/changeme/store.txt', "a+") do |f|
    store = f.read.split

    title = item['title']
    link = item['link']

    # if link is not in store, we want to mail out
    unless store.include? link
      send_mail(item)
      # and save thread URL to file
      f << link + "\n"
    end
  end
end 

baseurl = 'http://www.someforum.com/'
urls = [
  baseurl + changeme1
  baseurl + changeme2
]

urls.each do |url|
  doc = Nokogiri::HTML(open(url))

  items = []
  doc.xpath('//div[@class="threadinfo"]').each do |e|
    item = {}
    item['type'] = url.match(/\d.*-(.*)/).captures.first
    item['price'] = 0
    line = e.at_xpath('@title').to_s.gsub("\n","")

    next if line =~ /Trade only/i or line !~ /Item Name/

#    puts line
    item['title'] = line.match(/Item Name:?.*?(.*)(Location|\.\.\.)/).captures.first
    item['location'] = $1 if line.match(/Location:?.*?(.*?)(Zip|Item)/)
    item['price'] = $1.to_i if line.match(/Sale Price.*?(\d+)/)

    item['link'] = baseurl + e.at_xpath('div/h3/a/@href').to_s.gsub(/\?s=.*/, '')

    items << item
  end

  items.each do |item|
    next if item['price'] > 800)
    next if item['link'] =~ /Gone!/
    if title_match?(item['title'])
      process_match(item)
      puts item
    end
  end

end
