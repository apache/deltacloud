Feature: Working with API
  In order to work with API

  Scenario: I want to get list of entry points in XML
    Given I want to get XML
    When I request for entry points
    Then I should see these entry points:
    | flavors    |
    | realms     |
    | instances  |
    | images     |
    | instance_states |
    | hardware_profiles  |
    | storage_snapshots  |
    | storage_volumes    |

  Scenario: I want to get list of entry points in HTML
    Given I want to get HTML
    When I request for entry points
    Then I should get valid HTML response
    And I should see these entry points in page:
    | flavors    |
    | realms     |
    | instances  |
    | images     |
    | instance_states |
    | hardware_profiles  |
    | storage_snapshots  |
    | storage_volumes    |
    When I follow this entry points
    Then I should get valid HTML response for each
    And each entry points should have documentation
