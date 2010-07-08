Feature: Accessing storage snapshots

  Scenario: Listing available storage snapshots
    Given URI /api/storage_snapshots exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'storage-snapshots'
    And this element contains some storage-snapshots
    And each storage-volume should have:
    | id |
    | created |
    | storage-volume |
    And each image should have 'href' attribute with valid URL
    And this URI should be available in XML, JSON, HTML format

  Scenario: Get details about first volume
    Given URI /api/storage_snapshots exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'storage-snapshots'
    And this element contains some storage-snapshots
    When client want to show first storage-snapshot
    Then client follow href attribute in first storage-snapshot
    Then client should get this storage-snapshot
    And this storage-snapshot should have:
    | id |
    | created |
    | state |
    | storage-volume |
