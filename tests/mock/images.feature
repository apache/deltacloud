Feature: Listing and showing images

  Scenario: Listing available images
    Given URI /api/images exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'images'
    And this element contains some images
    And each image should have:
    | name |
    | description |
    | architecture |
    | owner_id |
    | state |
    And each image should have 'href' attribute with valid URL
    And this URI should be available in XML, JSON, HTML format

  Scenario: Following image href attribute
    Given URI /api/images exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'images'
    And this element contains some images
    When client want to show first image
    Then client should follow href attribute in image
    And client should get valid response with requested image
    And this image should have:
    | name |
    | description |
    | architecture |
    | owner_id |
    | state |
    And this URI should be available in XML, JSON, HTML format

  Scenario: Filtering images by owner_id
    Given URI /api/images exists
    And authentification is required for this URI
    When client access this URI with parameters:
    | owner_id | fedoraproject |
    Then client should get some images
    And each image should have 'owner_id' attribute set to 'fedoraproject'

  Scenario: Filtering images by architecture
    Given URI /api/images exists
    And authentification is required for this URI
    When client access this URI with parameters:
    | architecture | i386 |
    Then client should get some images
    And each image should have 'architecture' attribute set to 'i386'

  Scenario: Filtering images by architecture and owner_id
    Given URI /api/images exists
    And authentification is required for this URI
    When client access this URI with parameters:
    | architecture | i386 |
    | owner_id | fedoraproject |
    Then client should get some images
    And each image should have 'architecture' attribute set to 'i386'
    And each image should have 'owner_id' attribute set to 'fedoraproject'
