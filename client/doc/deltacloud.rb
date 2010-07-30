module DeltaCloud
  class API
# Return InstanceState object with given id

# 
# The possible states of an instance, and how to traverse between them
# @return [InstanceState]
def instance_state
end
# Return collection of InstanceState objects
# 
# The possible states of an instance, and how to traverse between them
# @return [Array] [InstanceState]
def instance_states(opts={})
end
# Return StorageVolume object with given id

# 
# Storage volumes description here
# @return [StorageVolume]
def storage_volume
end
# Return collection of StorageVolume objects
# 
# Storage volumes description here
   # @param [string, id] 
# @return [Array] [StorageVolume]
def storage_volumes(opts={})
end
# Return Instance object with given id

# 
# 
#         An instance is a concrete machine realized from an image.
#         The images collection may be obtained by following the link from the primary entry-point."
#     
# @return [Instance]
def instance
end
# Return collection of Instance objects
# 
# 
#         An instance is a concrete machine realized from an image.
#         The images collection may be obtained by following the link from the primary entry-point."
#     
   # @param [string, state] 
   # @param [string, id] 
# @return [Array] [Instance]
def instances(opts={})
end
# Return HardwareProfile object with given id

# 
# 
#        A hardware profile represents a configuration of resources upon which a
#        machine may be deployed. It defines aspects such as local disk storage,
#        available RAM, and architecture. Each provider is free to define as many
#        (or as few) hardware profiles as desired.
#     
# @return [HardwareProfile]
def hardware_profile
end
# Return collection of HardwareProfile objects
# 
# 
#        A hardware profile represents a configuration of resources upon which a
#        machine may be deployed. It defines aspects such as local disk storage,
#        available RAM, and architecture. Each provider is free to define as many
#        (or as few) hardware profiles as desired.
#     
   # @param [string, architecture] 
   # @param [string, id] 
# @return [Array] [HardwareProfile]
def hardware_profiles(opts={})
end
# Return StorageSnapshot object with given id

# 
# Storage snapshots description here
# @return [StorageSnapshot]
def storage_snapshot
end
# Return collection of StorageSnapshot objects
# 
# Storage snapshots description here
   # @param [string, id] 
# @return [Array] [StorageSnapshot]
def storage_snapshots(opts={})
end
# Return Image object with given id

# 
# 
#         An image is a platonic form of a machine. Images are not directly executable,
#         but are a template for creating actual instances of machines."
#     
# @return [Image]
def image
end
# Return collection of Image objects
# 
# 
#         An image is a platonic form of a machine. Images are not directly executable,
#         but are a template for creating actual instances of machines."
#     
   # @param [string, architecture] 
   # @param [string, owner_id] 
   # @param [string, id] 
# @return [Array] [Image]
def images(opts={})
end
# Return Realm object with given id

# 
# 
#         Within a cloud provider a realm represents a boundary containing resources.
#         The exact definition of a realm is left to the cloud provider.
#         In some cases, a realm may represent different datacenters, different continents,
#         or different pools of resources within a single datacenter.
#         A cloud provider may insist that resources must all exist within a single realm in
#         order to cooperate. For instance, storage volumes may only be allowed to be mounted to
#         instances within the same realm.
#     
# @return [Realm]
def realm
end
# Return collection of Realm objects
# 
# 
#         Within a cloud provider a realm represents a boundary containing resources.
#         The exact definition of a realm is left to the cloud provider.
#         In some cases, a realm may represent different datacenters, different continents,
#         or different pools of resources within a single datacenter.
#         A cloud provider may insist that resources must all exist within a single realm in
#         order to cooperate. For instance, storage volumes may only be allowed to be mounted to
#         instances within the same realm.
#     
   # @param [string, architecture] 
   # @param [string, id] 
# @return [Array] [Realm]
def realms(opts={})
end
  end
  class API::StorageVolume
    # Return URI to API for this object

    # @return [String] Value of uri
    def uri
      # This method was generated dynamically from API
    end

    # Get device attribute value from api::storagevolume

    # @return [String] Value of device
    def device
      # This method was generated dynamically from API
    end

    # Get id attribute value from api::storagevolume

    # @return [String] Value of id
    def id
      # This method was generated dynamically from API
    end

    # Return instance of API client

    # @return [String] Value of client
    def client
      # This method was generated dynamically from API
    end

    # Get capacity= attribute value from api::storagevolume

    # @return [String] Value of capacity=
    def capacity=
      # This method was generated dynamically from API
    end

    # Get device= attribute value from api::storagevolume

    # @return [String] Value of device=
    def device=
      # This method was generated dynamically from API
    end

    # Get instance attribute value from api::storagevolume

    # @return [String] Value of instance
    def instance
      # This method was generated dynamically from API
    end

    # Get created attribute value from api::storagevolume

    # @return [String] Value of created
    def created
      # This method was generated dynamically from API
    end

    # Get created= attribute value from api::storagevolume

    # @return [String] Value of created=
    def created=
      # This method was generated dynamically from API
    end

    # Get capacity attribute value from api::storagevolume

    # @return [String] Value of capacity
    def capacity
      # This method was generated dynamically from API
    end

  end
end
module DeltaCloud
  class API
# Return InstanceState object with given id

# 
# The possible states of an instance, and how to traverse between them
# @return [InstanceState]
def instance_state
end
# Return collection of InstanceState objects
# 
# The possible states of an instance, and how to traverse between them
# @return [Array] [InstanceState]
def instance_states(opts={})
end
# Return StorageVolume object with given id

# 
# Storage volumes description here
# @return [StorageVolume]
def storage_volume
end
# Return collection of StorageVolume objects
# 
# Storage volumes description here
   # @param [string, id] 
# @return [Array] [StorageVolume]
def storage_volumes(opts={})
end
# Return Instance object with given id

# 
# 
#         An instance is a concrete machine realized from an image.
#         The images collection may be obtained by following the link from the primary entry-point."
#     
# @return [Instance]
def instance
end
# Return collection of Instance objects
# 
# 
#         An instance is a concrete machine realized from an image.
#         The images collection may be obtained by following the link from the primary entry-point."
#     
   # @param [string, state] 
   # @param [string, id] 
# @return [Array] [Instance]
def instances(opts={})
end
# Return HardwareProfile object with given id

# 
# 
#        A hardware profile represents a configuration of resources upon which a
#        machine may be deployed. It defines aspects such as local disk storage,
#        available RAM, and architecture. Each provider is free to define as many
#        (or as few) hardware profiles as desired.
#     
# @return [HardwareProfile]
def hardware_profile
end
# Return collection of HardwareProfile objects
# 
# 
#        A hardware profile represents a configuration of resources upon which a
#        machine may be deployed. It defines aspects such as local disk storage,
#        available RAM, and architecture. Each provider is free to define as many
#        (or as few) hardware profiles as desired.
#     
   # @param [string, architecture] 
   # @param [string, id] 
# @return [Array] [HardwareProfile]
def hardware_profiles(opts={})
end
# Return StorageSnapshot object with given id

# 
# Storage snapshots description here
# @return [StorageSnapshot]
def storage_snapshot
end
# Return collection of StorageSnapshot objects
# 
# Storage snapshots description here
   # @param [string, id] 
# @return [Array] [StorageSnapshot]
def storage_snapshots(opts={})
end
# Return Image object with given id

# 
# 
#         An image is a platonic form of a machine. Images are not directly executable,
#         but are a template for creating actual instances of machines."
#     
# @return [Image]
def image
end
# Return collection of Image objects
# 
# 
#         An image is a platonic form of a machine. Images are not directly executable,
#         but are a template for creating actual instances of machines."
#     
   # @param [string, architecture] 
   # @param [string, owner_id] 
   # @param [string, id] 
# @return [Array] [Image]
def images(opts={})
end
# Return Realm object with given id

# 
# 
#         Within a cloud provider a realm represents a boundary containing resources.
#         The exact definition of a realm is left to the cloud provider.
#         In some cases, a realm may represent different datacenters, different continents,
#         or different pools of resources within a single datacenter.
#         A cloud provider may insist that resources must all exist within a single realm in
#         order to cooperate. For instance, storage volumes may only be allowed to be mounted to
#         instances within the same realm.
#     
# @return [Realm]
def realm
end
# Return collection of Realm objects
# 
# 
#         Within a cloud provider a realm represents a boundary containing resources.
#         The exact definition of a realm is left to the cloud provider.
#         In some cases, a realm may represent different datacenters, different continents,
#         or different pools of resources within a single datacenter.
#         A cloud provider may insist that resources must all exist within a single realm in
#         order to cooperate. For instance, storage volumes may only be allowed to be mounted to
#         instances within the same realm.
#     
   # @param [string, architecture] 
   # @param [string, id] 
# @return [Array] [Realm]
def realms(opts={})
end
  end
  class API::Instance
    # Return URI to API for this object

    # @return [String] Value of uri
    def uri
      # This method was generated dynamically from API
    end

    # Get realm attribute value from api::instance

    # @return [String] Value of realm
    def realm
      # This method was generated dynamically from API
    end

    # Get reboot! attribute value from api::instance

    # @return [String] Value of reboot!
    def reboot!
      # This method was generated dynamically from API
    end

    # Get name= attribute value from api::instance

    # @return [String] Value of name=
    def name=
      # This method was generated dynamically from API
    end

    # Get private_addresses= attribute value from api::instance

    # @return [String] Value of private_addresses=
    def private_addresses=
      # This method was generated dynamically from API
    end

    # Get id attribute value from api::instance

    # @return [String] Value of id
    def id
      # This method was generated dynamically from API
    end

    # Return instance of API client

    # @return [String] Value of client
    def client
      # This method was generated dynamically from API
    end

    # Get owner_id attribute value from api::instance

    # @return [String] Value of owner_id
    def owner_id
      # This method was generated dynamically from API
    end

    # Get image attribute value from api::instance

    # @return [String] Value of image
    def image
      # This method was generated dynamically from API
    end

    # Get actions_urls attribute value from api::instance

    # @return [String] Value of actions_urls
    def actions_urls
      # This method was generated dynamically from API
    end

    # Get hardware_profile attribute value from api::instance

    # @return [String] Value of hardware_profile
    def hardware_profile
      # This method was generated dynamically from API
    end

    # Get owner_id= attribute value from api::instance

    # @return [String] Value of owner_id=
    def owner_id=
      # This method was generated dynamically from API
    end

    # Get destroy! attribute value from api::instance

    # @return [String] Value of destroy!
    def destroy!
      # This method was generated dynamically from API
    end

    # Get state attribute value from api::instance

    # @return [String] Value of state
    def state
      # This method was generated dynamically from API
    end

    # Read api::instance collection from Deltacloud API
    # @param [String, #id] Filter by ID
    # @return [String] Value of public_addresses
    def public_addresses
      # This method was generated dynamically from API
    end

    # Get stop! attribute value from api::instance

    # @return [String] Value of stop!
    def stop!
      # This method was generated dynamically from API
    end

    # Get actions attribute value from api::instance

    # @return [String] Value of actions
    def actions
      # This method was generated dynamically from API
    end

    # Get name attribute value from api::instance

    # @return [String] Value of name
    def name
      # This method was generated dynamically from API
    end

    # Read api::instance collection from Deltacloud API
    # @param [String, #id] Filter by ID
    # @return [String] Value of private_addresses
    def private_addresses
      # This method was generated dynamically from API
    end

    # Get start! attribute value from api::instance

    # @return [String] Value of start!
    def start!
      # This method was generated dynamically from API
    end

    # Get state= attribute value from api::instance

    # @return [String] Value of state=
    def state=
      # This method was generated dynamically from API
    end

    # Get public_addresses= attribute value from api::instance

    # @return [String] Value of public_addresses=
    def public_addresses=
      # This method was generated dynamically from API
    end

  end
end
module DeltaCloud
  class API
# Return InstanceState object with given id

# 
# The possible states of an instance, and how to traverse between them
# @return [InstanceState]
def instance_state
end
# Return collection of InstanceState objects
# 
# The possible states of an instance, and how to traverse between them
# @return [Array] [InstanceState]
def instance_states(opts={})
end
# Return StorageVolume object with given id

# 
# Storage volumes description here
# @return [StorageVolume]
def storage_volume
end
# Return collection of StorageVolume objects
# 
# Storage volumes description here
   # @param [string, id] 
# @return [Array] [StorageVolume]
def storage_volumes(opts={})
end
# Return Instance object with given id

# 
# 
#         An instance is a concrete machine realized from an image.
#         The images collection may be obtained by following the link from the primary entry-point."
#     
# @return [Instance]
def instance
end
# Return collection of Instance objects
# 
# 
#         An instance is a concrete machine realized from an image.
#         The images collection may be obtained by following the link from the primary entry-point."
#     
   # @param [string, state] 
   # @param [string, id] 
# @return [Array] [Instance]
def instances(opts={})
end
# Return HardwareProfile object with given id

# 
# 
#        A hardware profile represents a configuration of resources upon which a
#        machine may be deployed. It defines aspects such as local disk storage,
#        available RAM, and architecture. Each provider is free to define as many
#        (or as few) hardware profiles as desired.
#     
# @return [HardwareProfile]
def hardware_profile
end
# Return collection of HardwareProfile objects
# 
# 
#        A hardware profile represents a configuration of resources upon which a
#        machine may be deployed. It defines aspects such as local disk storage,
#        available RAM, and architecture. Each provider is free to define as many
#        (or as few) hardware profiles as desired.
#     
   # @param [string, architecture] 
   # @param [string, id] 
# @return [Array] [HardwareProfile]
def hardware_profiles(opts={})
end
# Return StorageSnapshot object with given id

# 
# Storage snapshots description here
# @return [StorageSnapshot]
def storage_snapshot
end
# Return collection of StorageSnapshot objects
# 
# Storage snapshots description here
   # @param [string, id] 
# @return [Array] [StorageSnapshot]
def storage_snapshots(opts={})
end
# Return Image object with given id

# 
# 
#         An image is a platonic form of a machine. Images are not directly executable,
#         but are a template for creating actual instances of machines."
#     
# @return [Image]
def image
end
# Return collection of Image objects
# 
# 
#         An image is a platonic form of a machine. Images are not directly executable,
#         but are a template for creating actual instances of machines."
#     
   # @param [string, architecture] 
   # @param [string, owner_id] 
   # @param [string, id] 
# @return [Array] [Image]
def images(opts={})
end
# Return Realm object with given id

# 
# 
#         Within a cloud provider a realm represents a boundary containing resources.
#         The exact definition of a realm is left to the cloud provider.
#         In some cases, a realm may represent different datacenters, different continents,
#         or different pools of resources within a single datacenter.
#         A cloud provider may insist that resources must all exist within a single realm in
#         order to cooperate. For instance, storage volumes may only be allowed to be mounted to
#         instances within the same realm.
#     
# @return [Realm]
def realm
end
# Return collection of Realm objects
# 
# 
#         Within a cloud provider a realm represents a boundary containing resources.
#         The exact definition of a realm is left to the cloud provider.
#         In some cases, a realm may represent different datacenters, different continents,
#         or different pools of resources within a single datacenter.
#         A cloud provider may insist that resources must all exist within a single realm in
#         order to cooperate. For instance, storage volumes may only be allowed to be mounted to
#         instances within the same realm.
#     
   # @param [string, architecture] 
   # @param [string, id] 
# @return [Array] [Realm]
def realms(opts={})
end
  end
  class API::HardwareProfile
    # Return URI to API for this object

    # @return [String] Value of uri
    def uri
      # This method was generated dynamically from API
    end

    # Get cpu= attribute value from api::hardwareprofile

    # @return [String] Value of cpu=
    def cpu=
      # This method was generated dynamically from API
    end

    # Get name= attribute value from api::hardwareprofile

    # @return [String] Value of name=
    def name=
      # This method was generated dynamically from API
    end

    # Get storage attribute value from api::hardwareprofile

    # @return [String] Value of storage
    def storage
      # This method was generated dynamically from API
    end

    # Get id attribute value from api::hardwareprofile

    # @return [String] Value of id
    def id
      # This method was generated dynamically from API
    end

    # Return instance of API client

    # @return [String] Value of client
    def client
      # This method was generated dynamically from API
    end

    # Get architecture attribute value from api::hardwareprofile

    # @return [String] Value of architecture
    def architecture
      # This method was generated dynamically from API
    end

    # Get storage= attribute value from api::hardwareprofile

    # @return [String] Value of storage=
    def storage=
      # This method was generated dynamically from API
    end

    # Get architecture= attribute value from api::hardwareprofile

    # @return [String] Value of architecture=
    def architecture=
      # This method was generated dynamically from API
    end

    # Get memory attribute value from api::hardwareprofile

    # @return [String] Value of memory
    def memory
      # This method was generated dynamically from API
    end

    # Get cpu attribute value from api::hardwareprofile

    # @return [String] Value of cpu
    def cpu
      # This method was generated dynamically from API
    end

    # Get memory= attribute value from api::hardwareprofile

    # @return [String] Value of memory=
    def memory=
      # This method was generated dynamically from API
    end

    # Get name attribute value from api::hardwareprofile

    # @return [String] Value of name
    def name
      # This method was generated dynamically from API
    end

  end
end
module DeltaCloud
  class API
# Return InstanceState object with given id

# 
# The possible states of an instance, and how to traverse between them
# @return [InstanceState]
def instance_state
end
# Return collection of InstanceState objects
# 
# The possible states of an instance, and how to traverse between them
# @return [Array] [InstanceState]
def instance_states(opts={})
end
# Return StorageVolume object with given id

# 
# Storage volumes description here
# @return [StorageVolume]
def storage_volume
end
# Return collection of StorageVolume objects
# 
# Storage volumes description here
   # @param [string, id] 
# @return [Array] [StorageVolume]
def storage_volumes(opts={})
end
# Return Instance object with given id

# 
# 
#         An instance is a concrete machine realized from an image.
#         The images collection may be obtained by following the link from the primary entry-point."
#     
# @return [Instance]
def instance
end
# Return collection of Instance objects
# 
# 
#         An instance is a concrete machine realized from an image.
#         The images collection may be obtained by following the link from the primary entry-point."
#     
   # @param [string, state] 
   # @param [string, id] 
# @return [Array] [Instance]
def instances(opts={})
end
# Return HardwareProfile object with given id

# 
# 
#        A hardware profile represents a configuration of resources upon which a
#        machine may be deployed. It defines aspects such as local disk storage,
#        available RAM, and architecture. Each provider is free to define as many
#        (or as few) hardware profiles as desired.
#     
# @return [HardwareProfile]
def hardware_profile
end
# Return collection of HardwareProfile objects
# 
# 
#        A hardware profile represents a configuration of resources upon which a
#        machine may be deployed. It defines aspects such as local disk storage,
#        available RAM, and architecture. Each provider is free to define as many
#        (or as few) hardware profiles as desired.
#     
   # @param [string, architecture] 
   # @param [string, id] 
# @return [Array] [HardwareProfile]
def hardware_profiles(opts={})
end
# Return StorageSnapshot object with given id

# 
# Storage snapshots description here
# @return [StorageSnapshot]
def storage_snapshot
end
# Return collection of StorageSnapshot objects
# 
# Storage snapshots description here
   # @param [string, id] 
# @return [Array] [StorageSnapshot]
def storage_snapshots(opts={})
end
# Return Image object with given id

# 
# 
#         An image is a platonic form of a machine. Images are not directly executable,
#         but are a template for creating actual instances of machines."
#     
# @return [Image]
def image
end
# Return collection of Image objects
# 
# 
#         An image is a platonic form of a machine. Images are not directly executable,
#         but are a template for creating actual instances of machines."
#     
   # @param [string, architecture] 
   # @param [string, owner_id] 
   # @param [string, id] 
# @return [Array] [Image]
def images(opts={})
end
# Return Realm object with given id

# 
# 
#         Within a cloud provider a realm represents a boundary containing resources.
#         The exact definition of a realm is left to the cloud provider.
#         In some cases, a realm may represent different datacenters, different continents,
#         or different pools of resources within a single datacenter.
#         A cloud provider may insist that resources must all exist within a single realm in
#         order to cooperate. For instance, storage volumes may only be allowed to be mounted to
#         instances within the same realm.
#     
# @return [Realm]
def realm
end
# Return collection of Realm objects
# 
# 
#         Within a cloud provider a realm represents a boundary containing resources.
#         The exact definition of a realm is left to the cloud provider.
#         In some cases, a realm may represent different datacenters, different continents,
#         or different pools of resources within a single datacenter.
#         A cloud provider may insist that resources must all exist within a single realm in
#         order to cooperate. For instance, storage volumes may only be allowed to be mounted to
#         instances within the same realm.
#     
   # @param [string, architecture] 
   # @param [string, id] 
# @return [Array] [Realm]
def realms(opts={})
end
  end
  class API::StorageSnapshot
    # Return URI to API for this object

    # @return [String] Value of uri
    def uri
      # This method was generated dynamically from API
    end

    # Get storage_volume attribute value from api::storagesnapshot

    # @return [String] Value of storage_volume
    def storage_volume
      # This method was generated dynamically from API
    end

    # Get id attribute value from api::storagesnapshot

    # @return [String] Value of id
    def id
      # This method was generated dynamically from API
    end

    # Return instance of API client

    # @return [String] Value of client
    def client
      # This method was generated dynamically from API
    end

    # Get created attribute value from api::storagesnapshot

    # @return [String] Value of created
    def created
      # This method was generated dynamically from API
    end

    # Get state attribute value from api::storagesnapshot

    # @return [String] Value of state
    def state
      # This method was generated dynamically from API
    end

    # Get created= attribute value from api::storagesnapshot

    # @return [String] Value of created=
    def created=
      # This method was generated dynamically from API
    end

    # Get state= attribute value from api::storagesnapshot

    # @return [String] Value of state=
    def state=
      # This method was generated dynamically from API
    end

  end
end
module DeltaCloud
  class API
# Return InstanceState object with given id

# 
# The possible states of an instance, and how to traverse between them
# @return [InstanceState]
def instance_state
end
# Return collection of InstanceState objects
# 
# The possible states of an instance, and how to traverse between them
# @return [Array] [InstanceState]
def instance_states(opts={})
end
# Return StorageVolume object with given id

# 
# Storage volumes description here
# @return [StorageVolume]
def storage_volume
end
# Return collection of StorageVolume objects
# 
# Storage volumes description here
   # @param [string, id] 
# @return [Array] [StorageVolume]
def storage_volumes(opts={})
end
# Return Instance object with given id

# 
# 
#         An instance is a concrete machine realized from an image.
#         The images collection may be obtained by following the link from the primary entry-point."
#     
# @return [Instance]
def instance
end
# Return collection of Instance objects
# 
# 
#         An instance is a concrete machine realized from an image.
#         The images collection may be obtained by following the link from the primary entry-point."
#     
   # @param [string, state] 
   # @param [string, id] 
# @return [Array] [Instance]
def instances(opts={})
end
# Return HardwareProfile object with given id

# 
# 
#        A hardware profile represents a configuration of resources upon which a
#        machine may be deployed. It defines aspects such as local disk storage,
#        available RAM, and architecture. Each provider is free to define as many
#        (or as few) hardware profiles as desired.
#     
# @return [HardwareProfile]
def hardware_profile
end
# Return collection of HardwareProfile objects
# 
# 
#        A hardware profile represents a configuration of resources upon which a
#        machine may be deployed. It defines aspects such as local disk storage,
#        available RAM, and architecture. Each provider is free to define as many
#        (or as few) hardware profiles as desired.
#     
   # @param [string, architecture] 
   # @param [string, id] 
# @return [Array] [HardwareProfile]
def hardware_profiles(opts={})
end
# Return StorageSnapshot object with given id

# 
# Storage snapshots description here
# @return [StorageSnapshot]
def storage_snapshot
end
# Return collection of StorageSnapshot objects
# 
# Storage snapshots description here
   # @param [string, id] 
# @return [Array] [StorageSnapshot]
def storage_snapshots(opts={})
end
# Return Image object with given id

# 
# 
#         An image is a platonic form of a machine. Images are not directly executable,
#         but are a template for creating actual instances of machines."
#     
# @return [Image]
def image
end
# Return collection of Image objects
# 
# 
#         An image is a platonic form of a machine. Images are not directly executable,
#         but are a template for creating actual instances of machines."
#     
   # @param [string, architecture] 
   # @param [string, owner_id] 
   # @param [string, id] 
# @return [Array] [Image]
def images(opts={})
end
# Return Realm object with given id

# 
# 
#         Within a cloud provider a realm represents a boundary containing resources.
#         The exact definition of a realm is left to the cloud provider.
#         In some cases, a realm may represent different datacenters, different continents,
#         or different pools of resources within a single datacenter.
#         A cloud provider may insist that resources must all exist within a single realm in
#         order to cooperate. For instance, storage volumes may only be allowed to be mounted to
#         instances within the same realm.
#     
# @return [Realm]
def realm
end
# Return collection of Realm objects
# 
# 
#         Within a cloud provider a realm represents a boundary containing resources.
#         The exact definition of a realm is left to the cloud provider.
#         In some cases, a realm may represent different datacenters, different continents,
#         or different pools of resources within a single datacenter.
#         A cloud provider may insist that resources must all exist within a single realm in
#         order to cooperate. For instance, storage volumes may only be allowed to be mounted to
#         instances within the same realm.
#     
   # @param [string, architecture] 
   # @param [string, id] 
# @return [Array] [Realm]
def realms(opts={})
end
  end
  class API::Image
    # Return URI to API for this object

    # @return [String] Value of uri
    def uri
      # This method was generated dynamically from API
    end

    # Get name= attribute value from api::image

    # @return [String] Value of name=
    def name=
      # This method was generated dynamically from API
    end

    # Get id attribute value from api::image

    # @return [String] Value of id
    def id
      # This method was generated dynamically from API
    end

    # Return instance of API client

    # @return [String] Value of client
    def client
      # This method was generated dynamically from API
    end

    # Get architecture attribute value from api::image

    # @return [String] Value of architecture
    def architecture
      # This method was generated dynamically from API
    end

    # Get owner_id attribute value from api::image

    # @return [String] Value of owner_id
    def owner_id
      # This method was generated dynamically from API
    end

    # Get description attribute value from api::image

    # @return [String] Value of description
    def description
      # This method was generated dynamically from API
    end

    # Get architecture= attribute value from api::image

    # @return [String] Value of architecture=
    def architecture=
      # This method was generated dynamically from API
    end

    # Get owner_id= attribute value from api::image

    # @return [String] Value of owner_id=
    def owner_id=
      # This method was generated dynamically from API
    end

    # Get description= attribute value from api::image

    # @return [String] Value of description=
    def description=
      # This method was generated dynamically from API
    end

    # Get name attribute value from api::image

    # @return [String] Value of name
    def name
      # This method was generated dynamically from API
    end

  end
end
module DeltaCloud
  class API
# Return InstanceState object with given id

# 
# The possible states of an instance, and how to traverse between them
# @return [InstanceState]
def instance_state
end
# Return collection of InstanceState objects
# 
# The possible states of an instance, and how to traverse between them
# @return [Array] [InstanceState]
def instance_states(opts={})
end
# Return StorageVolume object with given id

# 
# Storage volumes description here
# @return [StorageVolume]
def storage_volume
end
# Return collection of StorageVolume objects
# 
# Storage volumes description here
   # @param [string, id] 
# @return [Array] [StorageVolume]
def storage_volumes(opts={})
end
# Return Instance object with given id

# 
# 
#         An instance is a concrete machine realized from an image.
#         The images collection may be obtained by following the link from the primary entry-point."
#     
# @return [Instance]
def instance
end
# Return collection of Instance objects
# 
# 
#         An instance is a concrete machine realized from an image.
#         The images collection may be obtained by following the link from the primary entry-point."
#     
   # @param [string, state] 
   # @param [string, id] 
# @return [Array] [Instance]
def instances(opts={})
end
# Return HardwareProfile object with given id

# 
# 
#        A hardware profile represents a configuration of resources upon which a
#        machine may be deployed. It defines aspects such as local disk storage,
#        available RAM, and architecture. Each provider is free to define as many
#        (or as few) hardware profiles as desired.
#     
# @return [HardwareProfile]
def hardware_profile
end
# Return collection of HardwareProfile objects
# 
# 
#        A hardware profile represents a configuration of resources upon which a
#        machine may be deployed. It defines aspects such as local disk storage,
#        available RAM, and architecture. Each provider is free to define as many
#        (or as few) hardware profiles as desired.
#     
   # @param [string, architecture] 
   # @param [string, id] 
# @return [Array] [HardwareProfile]
def hardware_profiles(opts={})
end
# Return StorageSnapshot object with given id

# 
# Storage snapshots description here
# @return [StorageSnapshot]
def storage_snapshot
end
# Return collection of StorageSnapshot objects
# 
# Storage snapshots description here
   # @param [string, id] 
# @return [Array] [StorageSnapshot]
def storage_snapshots(opts={})
end
# Return Image object with given id

# 
# 
#         An image is a platonic form of a machine. Images are not directly executable,
#         but are a template for creating actual instances of machines."
#     
# @return [Image]
def image
end
# Return collection of Image objects
# 
# 
#         An image is a platonic form of a machine. Images are not directly executable,
#         but are a template for creating actual instances of machines."
#     
   # @param [string, architecture] 
   # @param [string, owner_id] 
   # @param [string, id] 
# @return [Array] [Image]
def images(opts={})
end
# Return Realm object with given id

# 
# 
#         Within a cloud provider a realm represents a boundary containing resources.
#         The exact definition of a realm is left to the cloud provider.
#         In some cases, a realm may represent different datacenters, different continents,
#         or different pools of resources within a single datacenter.
#         A cloud provider may insist that resources must all exist within a single realm in
#         order to cooperate. For instance, storage volumes may only be allowed to be mounted to
#         instances within the same realm.
#     
# @return [Realm]
def realm
end
# Return collection of Realm objects
# 
# 
#         Within a cloud provider a realm represents a boundary containing resources.
#         The exact definition of a realm is left to the cloud provider.
#         In some cases, a realm may represent different datacenters, different continents,
#         or different pools of resources within a single datacenter.
#         A cloud provider may insist that resources must all exist within a single realm in
#         order to cooperate. For instance, storage volumes may only be allowed to be mounted to
#         instances within the same realm.
#     
   # @param [string, architecture] 
   # @param [string, id] 
# @return [Array] [Realm]
def realms(opts={})
end
  end
  class API::Realm
    # Return URI to API for this object

    # @return [String] Value of uri
    def uri
      # This method was generated dynamically from API
    end

    # Get name= attribute value from api::realm

    # @return [String] Value of name=
    def name=
      # This method was generated dynamically from API
    end

    # Get limit attribute value from api::realm

    # @return [String] Value of limit
    def limit
      # This method was generated dynamically from API
    end

    # Get id attribute value from api::realm

    # @return [String] Value of id
    def id
      # This method was generated dynamically from API
    end

    # Return instance of API client

    # @return [String] Value of client
    def client
      # This method was generated dynamically from API
    end

    # Get limit= attribute value from api::realm

    # @return [String] Value of limit=
    def limit=
      # This method was generated dynamically from API
    end

    # Get state attribute value from api::realm

    # @return [String] Value of state
    def state
      # This method was generated dynamically from API
    end

    # Get name attribute value from api::realm

    # @return [String] Value of name
    def name
      # This method was generated dynamically from API
    end

    # Get state= attribute value from api::realm

    # @return [String] Value of state=
    def state=
      # This method was generated dynamically from API
    end

  end
end
