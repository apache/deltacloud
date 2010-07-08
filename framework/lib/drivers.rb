
module Drivers

  class AuthException < Exception
  end

  class BaseDriver

    def flavor(credentials, id)
      flavors = flavors(credentials, [id]) 
      return flavors.first unless flavors.empty?
      nil
    end

    def flavors_by_architecture(credentials, architecture)
      flavors(credentials).select{|f| f[:architecture] == architecture}
    end


    def image(credentials, id)
      images = images(credentials, [id])
      return images.first unless images.empty?
      nil
    end
    
    def instance(credentials, id)
      instances = instances(credentials, [id])
      return instances.first unless instances.empty?
      nil
    end

    def volume(credentials, id)
      volumes = volumes(credentials, [id])
      return volumes.first unless volumes.empty?
      nil
    end

    def snapshot(credentials, id)
      snapshots = snapshots(credentials, [id])
      return snapshots.first unless snapshots.empty?
      nil
    end
  end

end
