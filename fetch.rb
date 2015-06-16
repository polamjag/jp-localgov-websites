require 'bundler/setup'

require 'nokogiri'
require 'open-uri'

require 'json'

INTERVAL = 1

host = "https://www.j-lis.go.jp"
entrypoint = "/map-search/cms_1069.html"

abort 'specify output file as argument' if ARGV[0].nil?

def parse_table(table)
  ret = []
  ret.concat(table.css('th a').map do |tr|
    {
      name: tr.text.strip,
      url: tr.attribute('href').value
    }
  end)
  ret.concat(table.css('td a').map do |tr|
    {
      name: tr.text.strip,
      url: tr.attribute('href').value
   }
  end)
  ret
end

page = Nokogiri::HTML.parse open host + entrypoint

out = page.css("#map_201412162522 area").map.with_index do |area, index|
  sleep INTERVAL

  area_page = Nokogiri::HTML.parse(open host + area.attribute('href').value)
  pref = area_page.xpath('/html/body/div[2]/div/div[2]/div/div/div/div[2]/div[1]/h1').first.text

  puts "[#{(index+1).to_s.rjust 3}] processing #{pref} (#{area.attribute('href').value})"

  if pref == "北海道地方"
    {
      pref: "北海道",
      municipalities: (
        area_page.css(".wb-contents h3 a").map do |n|
          sleep INTERVAL

          parse_table Nokogiri::HTML.parse(open host + n.attribute('href').value).css('table.listtbl')
        end
      ).flatten.compact.uniq
    }
  else
    {
      pref: area_page.xpath('/html/body/div[2]/div/div[2]/div/div/div/div[2]/div[1]/h1').first.text,
      municipalities: parse_table(area_page.css('table.listtbl'))
    }
  end
end

File.write ARGV[0], out.to_json
