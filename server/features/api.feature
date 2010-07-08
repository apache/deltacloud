Feature: Working with API
  In order to work with API

  Background:
    Given I want to get XML

  Scenario: I want to get list of entry points
    When I request for entry points
    Then I should see this entry points:
    | flavors    |
    | realms     |
    | instances  |
    | images     |
    | instance_states |
    | hardware_profiles  |
    | storage_snapshots  |
    | storage_volumes    |
