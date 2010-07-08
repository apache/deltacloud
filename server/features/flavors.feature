Feature: Working with flavors
  In order to work with flavors

  Background:
    Given I want to get XML

  Scenario: I want to get list of all flavors
    When I follow flavors link in entry points
    Then I should see <FLAVOR_COUNT> flavor inside flavors
    And each link in flavors should point me to valid flavor

  Scenario: I want to show flavor details
    When I request for '<FLAVOR_ID>' flavor
    Then I should get this flavor
    And flavor should have valid href parameter
    And flavor should contain id parameter
    And flavor should contain architecture parameter
    And flavor should contain memory parameter
    And flavor should contain storage parameter

  Scenario: I want filter flavors by architecture
    When I want flavors with '<FLAVOR_ARCH>' architecture
    Then I should get only flavors with architecture '<FLAVOR_ARCH>'
