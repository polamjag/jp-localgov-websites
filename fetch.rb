require 'bundler/setup'

require 'nokogiri'
require 'open-uri'

require 'json'

INTERVAL = 1

host = "https://www.j-lis.go.jp"
entrypoint = "/map-search/cms_1069.html"

abort 'specify output file as argument' if ARGV[0].nil?

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
        muni = area_page.css("map area").select do |n|
          n.attribute('href').value =~ /^\/map/
        end.map do |n|
          sleep INTERVAL

          Nokogiri::HTML.parse(open host + n.attribute('href').value).css('map area').map do |h|
            {
              name: h.attribute('alt').value,
              url: h.attribute('href').value
            } unless h.attribute('href').nil?
          end
        end.flatten
      )
    }
  else
    {
      pref: pref,
      municipalities: (
        muni = area_page.css("map area").map do |n|
          {
            name: n.attribute('alt').value,
            url: n.attribute('href').value
          } unless n.attribute('href').nil?
        end.compact
      )
    }
  end
end

File.write ARGV[0], out.to_json
