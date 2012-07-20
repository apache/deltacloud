Feature: Managing storage volumes

  @prefix-create
  Scenario: Create a new storage volume
    Given URI /api/storage_volumes exists
    And authentification is required for this URI
    When client want create a new storage_volume
    Then client should POST on /api/storage_volumes using
      | capacity | 1 |
      | realm_id | us-east-1a |
    And a new storage_volume should be created
    And this storage_volume should have capacity set to '1'
    And this storage_volume should have created_at with valid date
    And this storage_volume should have state set to 'CREATING'
    And this storage_volume should have actions:
      | attach |
      | detach |
      | destroy |

  @prefix-list
  Scenario: Getting a list of all storage volumes
    Given URI /api/storage_volumes exists
    And authentification is required for this URI
    When client want to list all storage_volumes
    Then client should GET on /api/storage_volumes
    And a list of storage_volumes should be returned
    And each storage_volume should have id
    And each storage_volume should have created_at with valid date
    And each storage_volume should have state
    And each storage_volume should have capacity
    And each storage_volume should have actions

  @prefix-attach
  Scenario: Attach storage volume to instance
    Given URI /api/storage_volumes exists
    And authentification is required for this URI
    When client want to attach storage volume to RUNNING instance
    Then client should POST on /api/storage_volumes/$storage_volume_id/attach using
      | device | /dev/sdc |
      | instance_id | i-7f6a021e |
    And storage_volume should be attached to this instance
    And this storage_volume should have mounted instance with:
      | instance |
      | device |

  @prefix-detach
  Scenario: Detach storage volume to instance
    Given URI /api/storage_volumes exists
    And authentification is required for this URI
    When client want to detach created storage volume
    Then client should do a POST on /api/storage_volumes/$storage_volume_id/detach
    And storage_volume should be detached from
