Feature: Accessing realms

  Scenario: Getting list of available realms
    Given URI /api/realms exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'realms'
    And this element contains some realms
    And each realm should have:
    | name |
    | state |
    | limit |
    And each realm should have 'href' attribute with valid URL
    And this URI should be available in XML, JSON, HTML format

  Scenario: Following realm href attribute
    Given URI /api/realms exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'realms'
    And this element contains some realms
    When client want to show first realm
    Then client should follow href attribute in realm
    And client should get valid response with requested realm
    And this realm should have:
    | name |
    | state |
    And this URI should be available in XML, JSON, HTML format
