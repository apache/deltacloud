Feature: Working with realms
  In order to work with realms

  Background:
    Given I want to get XML

  Scenario: I want to get list of all realms
    When I follow realms link in entry points
    Then I in order to see list of realms I need to be authorized
    When I enter correct username and password
    And I follow realms link in entry points
    Then I should see <REALM_COUNT> realm inside realms
    And each link in realms should point me to valid realm

  Scenario: I want to show realm details
    When I request for '<REALM_ID>' realm
    Then I should get this realm
    And realm should have valid href parameter
    And realm should contain id parameter
    And realm should contain name parameter
    And realm should contain state parameter

  Scenario: I want filter realms by state
    When I want realms with '<REALM_STATE>' state
    Then I should get only realms with state '<REALM_STATE>'
