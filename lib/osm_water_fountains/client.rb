require 'overpass_api_ruby'

class OsmWaterFountains::Client
  def overpass_client
    options={ :timeout => 3000,
              :element_limit => 1073741824,
              :json => true}

    @client ||= OverpassAPI.new(options)
  end

  def results(south, north, west, east)
    # example results
    # [{:type=>"node", :id=>298351863, :lat=>32.7603747, :lon=>-16.9415023, :tags=>{:amenity=>"drinking_water"}}]
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
    fountains = {}

    step_size = 5
    (-90..89).step(step_size).each do |latitude|
      (-180..179).step(step_size).each do |longitude|
        south = latitude
        north = [latitude + step_size, 90].min
        west = longitude
        east = [longitude + step_size, 180].min

        results(south, north, west, east).each do |fountain|
          fountains[fountain[:id]] = fountain
        end

        puts "crawled #{fountains.count} fountains in bbox: (north: #{north}, south: #{south}, east: #{east}, west: #{west})"
        total_count += fountains.count
      end
    end
  end
end
