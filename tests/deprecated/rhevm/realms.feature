Feature: Working with RHEV-M realms

  Scenario: Get list of available realms
    Given I enter realms collection
    And I am authorized with my credentials
    When I request HTML response
    Then result should be valid HTML
    When I request XML response
    Then result should be valid XML
    And result should contain 1 realms
    And name of these realms should be
      | Brno |
    And each realm should have properties set to
      | state |  AVAILABLE                     |

  Scenario: Get details about Brno realm
    Given I enter realms collection
    And I am authorized with my credentials
    And I choose realm with id 0
    When I request HTML response
    Then result should be valid HTML
    When I request XML response
    Then result should be valid XML
    And result should contain one realm
    And attribute id should be set to 0
