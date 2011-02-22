Feature: Working with SBC realms

  Scenario: Get list of available realms
    Given I enter realms collection
    And I am authorized with my credentials
    When I request HTML response
    Then result should be valid HTML
    When I request XML response
    Then result should be valid XML
    And result should contain 4 realms
    And name of these realms should be
      | RTP |
      | EHN |
      | us-co-dc1 |
      | ca-on-dc1 |
    And each realm should have properties set to
      | state |  AVAILABLE  |

  Scenario: Get details about RTP realm
    Given I enter realms collection
    And I am authorized with my credentials
    And I choose realm with id 41
    When I request HTML response
    Then result should be valid HTML
    When I request XML response
    Then result should be valid XML
    And result should contain one realm
    And attribute id should be set to 41
    And the realm should have properties set to
      |  name  |  RTP  |
      |  state  |  AVAILABLE  |