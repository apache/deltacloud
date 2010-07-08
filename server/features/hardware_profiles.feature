Feature: Accessing hardware profiles

  Scenario: I want to get list of all hardware profiles
    Given URI /api/hardware_profiles exists
    And authentification is not required for this URI
    When client access this URI
    Then client should get root element 'hardware-profiles'
    And this URI should be available in XML, HTML, JSON format

  Scenario: I want to show hardware profile details
    Given URI /api/hardware_profiles exists
    And authentification is not required for this URI
    When client access this URI
    Then client should get root element 'hardware-profiles'
    When client want to show 'm1-large' hardware-profile
    And client should get this hardware-profile
    And it should have a href attribute
    And it should have a fixed property 'cpu'
    And it should have a range property 'memory'
    And it should have a enum property 'storage'
    And this URI should be available in XML, HTML, JSON format

  Scenario: Filtering images by architecture
    Given URI /api/hardware_profiles exists
    And authentification is required for this URI
    When client access this URI with parameters:
    | architecture | i386 |
    Then client should get some hardware-profiles
    And each hardware-profile should have 'architecture' attribute set to 'i386'
