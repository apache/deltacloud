Feature: Working with RHEV-M hardware profiles 

  Scenario: Get list of available hardware profiles
    Given I enter hardware_profiles collection
    When I request HTML response
    Then result should be valid HTML
    When I request XML response
    Then result should be valid XML
    And result should contain 2 hardware_profiles
    And name of these hardware_profiles should be
      | SERVER  |
      | DESKTOP |
    And range properties should be
      | memory  |
      | cpu     |
      | storage |
    And fixed properties should be
      | architecture |
    

  Scenario: Get details about SERVER hardware_profile
    Given I enter hardware_profiles collection
    And I choose hardware_profile with id SERVER
    When I request HTML response
    Then result should be valid HTML
    When I request XML response
    Then result should be valid XML
    And result should contain one hardware_profile
    And name of this hardware_profile should be SERVER
    And range properties should have default, first and last values:
      |   memory  |   512   |   512   |   32768   |
      |   cpu     |   1     |   1     |   4       |
      |   storage |   1     |   1     |   102400  |
    And range properties should have param for instance create operation
