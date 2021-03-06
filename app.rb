require 'geokit'
require 'nearest_time_zone'
require 'tzinfo'
require 'sinatra'

get '/time' do
  locations = params.keys[0].to_s
  get_time(locations).map { |line| "<p>#{line}</p>" }.join
end

def get_time(locations)
  time = Time.new.utc.strftime '%Y-%m-%d %H:%M:%S'
  result = ["UTC: #{time}"]

  locations.split(',').compact.each do |location|
    time = time_for_location(location)
    result << "#{location.strip}: #{time}"
  end

  result
end

def time_for_location(location)
  res = Geokit::Geocoders::GoogleGeocoder.geocode(location)
  timezone_name = NearestTimeZone.to(res.lat, res.lng)
  zone = TZInfo::Timezone.get(timezone_name)
  zone.now.strftime '%Y-%m-%d %H:%M:%S'
end
