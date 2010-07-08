require 'deltacloud/base_driver'
require 'rackspace_client'

class RackspaceDriver < DeltaCloud::BaseDriver

  def flavors(credentials, opts=nil)
    racks = new_client( credentials )
    results = racks.list_flavors.map do |flav|
      Flavor.new( {
                    :id=> flav["id"].to_s,
                    :memory=>flav["ram"].to_f/1024,
                    :storage=>flav["disk"].to_i,
                    :architecture=>'x86_64'
                  } )    
    end
    results = filter_on( results, :id, opts )
    results = filter_on( results, :architecture, opts )
    results
  end

  def images(credentials, opts=nil)
    racks = new_client( credentials )
    results = racks.list_images.map do |img|
      Image.new( {
                   :id=>img["id"].to_s,
                   :description=>img["name"],
                   :owner_id=>"root",
                   :architecture=>'x86_64'
                 } )
    end
    results.sort_by{|e| [e.description]}
  end



  def new_client(credentials)
    if ( credentials[:name].nil? || credentials[:password].nil? || credentials[:name] == '' || credentials[:password] == '' )
      raise DeltaCloud::AuthException.new
    end
    RackspaceClient.new(credentials[:name], credentials[:password])
  end

end
