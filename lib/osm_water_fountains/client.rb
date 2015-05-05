require 'overpass_api_ruby'

class OsmWaterFountains::Client
  attr_writer :fountains, :last_crawled_lat

  def overpass_client
    options={ :timeout => 3000,
              :element_limit => 1073741824,
              :json => true}

    @client ||= OverpassAPI.new(options)
  end

  def results(south, north, west, east)
    # example results
    # [{:type=>"node", :id=>298351863, :lat=>32.7603747, :lon=>-16.9415023, :tags=>{:amenity=>"drinking_water"}}]

    #don't overload the server!
    sleep 2
    overpass_client.query(query_xml(south, north, west, east))

  end

  def query_xml(south, north, west, east)
    #118.3240, 34.0937
    <<-XML
      <bbox-query s="#{south}" n="#{north}" w="#{west}" e="#{east}"/>
      <query type="node">
        <item/>
        <has-kv k="amenity" v="drinking_water"/>
      </query>
    XML
  end

  def crawl_all
    total_count = 0
    @fountains ||= {}

    @last_crawled_lat ||= -90

    max_retry_attempts =3
    puts "starting crawl at #{@last_crawled_lat}"
    lat_step_size = 1 
    lon_step_size = 20
    (@last_crawled_lat..89).step(lat_step_size).each do |latitude|
      (-180..179).step(lon_step_size).each do |longitude|
        attempts = 0
        success = false
        while( !success && attempts < max_retry_attempts ) do
          attempts += 1
          begin
            south = latitude
            north = [latitude + lat_step_size, 90].min
            west = longitude
            east = [longitude + lon_step_size, 180].min

            batch = results(south, north, west, east).each do |fountain|
              fountains[fountain[:id]] = fountain
            end
            success = true

            puts "crawled #{batch.count} fountains in bbox: (north: #{north}, south: #{south}, east: #{east}, west: #{west})"
            puts "#{fountains.count} fountains total"
            @last_crawled_lat = latitude
          rescue Exception => e
            puts "failed #{attempts} attempt(s) to crawl fountains in bbox: (north: #{north}, south: #{south}, east: #{east}, west: #{west})"
            puts e.message
          end
        end

        if ( !success && attempts >= max_retry_attempts )
          raise Exception.new('failed final attempt to crawl fountains')
        end
      end
    end
  end
end
