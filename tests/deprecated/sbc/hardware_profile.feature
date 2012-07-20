Feature: Working with SBC hardware profiles 

  Scenario: Get list of available hardware profiles
    Given I enter hardware_profiles collection
    And I am authorized with my credentials
    When I request HTML response
    Then result should be valid HTML
    When I request XML response
    Then result should be valid XML
    And result should contain 9 hardware_profiles
    And name of these hardware_profiles should be
      |  COP32.1-2048-60  |
      |  COP64.2-4096-60  |
      |  BRZ32.1-2048-60*175  |
      |  BRZ64.2-4096-60*500*350  |
      |  SLV32.2-4096-60*350  |
      |  SLV64.4-8192-60*500*500  |
      |  GLD32.4-4096-60*350  |
      |  GLD64.8-16384-60*500*500  |
      |  PLT64.16-16384-60*500*500*500*500  |
    And fixed properties should be
      | architecture |
      | memory  |
      | cpu     |
      | storage |

  Scenario: Get details about COP32.1-2048-60 hardware_profile
    Given I enter hardware_profiles collection
    And I am authorized with my credentials
    And I choose hardware_profile with id COP32.1-2048-60
    When I request HTML response
    Then result should be valid HTML
    When I request XML response
    Then result should be valid XML
    And result should contain one hardware_profile
    And name of this hardware_profile should be COP32.1-2048-60
    # TODO: test value attributes for memory, architecture, storage, and cpu
