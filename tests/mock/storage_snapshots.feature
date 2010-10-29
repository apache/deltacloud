Feature: Accessing storage snapshots

  Scenario: Listing available storage snapshots
    Given URI /api/storage_snapshots exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'storage_snapshots'
    And this element contains some storage_snapshots
    And each storage-volume should have:
    | created |
    | storage_volume |
    And each image should have 'href' attribute with valid URL
    And this URI should be available in XML, JSON, HTML format

  Scenario: Get details about first volume
    Given URI /api/storage_snapshots exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'storage_snapshots'
    And this element contains some storage_snapshots
    When client want to show first storage_snapshot
    Then client follow href attribute in first storage_snapshot
    Then client should get this storage_snapshot
    And this storage_snapshot should have:
    | created |
    | storage_volume |
