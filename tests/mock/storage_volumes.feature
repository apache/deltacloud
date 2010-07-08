Feature: Accessing storage volumes

  Scenario: Listing available storage volumes
    Given URI /api/storage_volumes exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'storage-volumes'
    And this element contains some storage-volumes
    And each storage-volume should have:
    | id |
    | created |
    | capacity |
    | device |
    | instance |
    And each image should have 'href' attribute with valid URL
    And this URI should be available in XML, JSON, HTML format

  Scenario: Get details about first volume
    Given URI /api/storage_volumes exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'storage-volumes'
    And this element contains some storage-volumes
    When client want to show first storage-volume
    Then client follow href attribute in first storage-volume
    Then client should get this storage-volume
    And this storage-volume should have:
    | id |
    | created |
    | capacity |
    | device |
    | instance |
    | state |
