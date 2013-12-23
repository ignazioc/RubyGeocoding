require 'csv'
require 'geocoder'
 
LOCATIONS = './locations.csv'
 
def degrees_to_meters(lon, lat)
    half_circumference = 20037508.34
    x = lon * half_circumference / 180
    y = Math.log(Math.tan((90 + lat) * Math::PI / 360)) / (Math::PI / 180)
 
    y = y * half_circumference / 180
 
    return [x, y]
end
 
Geocoder.configure({
	lookup: :google,
	http_proxy: "http://proxy.reply.it:8080" 
})

# puts 'address,city,state,point,lat,lon'
CSV.foreach(LOCATIONS, :headers => true, :header_converters => :symbol) do |line|
    address_string = "#{line[:address]}, #{line[:city]}, #{line[:state]}"
    result = Geocoder.search(address_string).first
 
    lat = result.latitude
    lon = result.longitude
 
    point = "POINT(#{lon} #{lat})"
    projected = degrees_to_meters(lon, lat)
    point = "POINT(#{projected[0]} #{projected[1]})"
 
    puts "#{address_string}, #{point}, #{lat}, #{lon}"
    #puts address_string
end