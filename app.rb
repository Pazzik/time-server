require 'geokit'
require "nearest_time_zone"
require 'tzinfo'
require "socket" 

def get_time(locations)
  time = Time.new.utc.strftime "%Y-%m-%d %H:%M:%S" 
  result = ["UTC: #{time}"]

  locations.split(',').compact.each do |location|
    res = Geokit::Geocoders::GoogleGeocoder.geocode(location)
    timezone_name = NearestTimeZone.to(res.lat,res.lng)
    zone = TZInfo::Timezone.get(timezone_name) 
    time = zone.now.strftime "%Y-%m-%d %H:%M:%S" 
    result << "#{location.strip}: #{time}"
  end

  return result
end 

Socket.tcp_server_loop(3000) {|sock, client_addrinfo|
  Thread.new {
    begin
      message = sock.recvmsg[0]
      first_line = message.lines[0]
      query_string = first_line.split(' ')[1]
      return if /\A\/time(\z|\?)/.match(query_string).nil? #check '/time' query
      
      locations = query_string.split('?')[1].to_s
      resp = get_time(locations).map{ |line| "<p>#{line}</p>" }.join

      sock.write(resp)
    ensure
      sock.close
    end
  }
}