
class ApiController < ApplicationController

  def show
    @version = 1.0
    @entry_points = [
      [ :flavors, flavors_url ],
      [ :realms, realms_url ],
      [ :images, images_url ],
      [ :instances, instances_url ],
      [ :storage_volumes, storage_volumes_url ],
      [ :storage_snapshots, storage_snapshots_url ],
    ]
    respond_to do |format|
      format.html
      format.json
      format.xml
    end
  end

end
