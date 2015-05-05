require 'overpass_api_ruby'

class OsmWaterFountains::Client
  def overpass_client
    options={ :timeout => 900,
              :element_limit => 1073741824,
              :json => true}

    @client ||= OverpassAPI.new(options)
  end

  def results
    overpass_client.query(query)
  end

  def query
    #118.3240, 34.0937
    <<-XML
      <bbox-query s="34.00" n="34.10" w="-118.324" e="-118.20"/>
      <query type="node">
        <item/>
        <has-kv k="amenity" v="drinking_water"/>
      </query>
    XML
  end
end
