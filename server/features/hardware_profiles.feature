Feature: Working with hardware profiles
  In order to work with hardware profiles

  Background:
    Given I want to get XML

  Scenario: I want to get list of all hardware profiles
    When I follow hardware profiles link in entry points
    Then I should see <HARDWARE_PROFILE_COUNT> hardware profile inside hardware profiles
    And each link in hardware profiles should point me to valid hardware profile

  Scenario: I want to show hardware profile details
    When I request for '<HARDWARE_PROFILE_ID>' hardware profile
    Then I should get this hardware profile
    And it should have a href attribute
    And hardware profile should include id parameter
    And it should have a fixed property 'cpu'
    And it should have a range property 'memory'
    And it should have a enum property 'storage'

  Scenario: I want filter hardware profiles by architecture
    When I want hardware profiles with '<HARDWARE_PROFILE_ARCH>' architecture
    Then the returned hardware profiles should have architecture '<HARDWARE_PROFILE_ARCH>'
