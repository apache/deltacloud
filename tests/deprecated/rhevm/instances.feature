Feature: Working with RHEV-M instances

  Scenario: Get list of all instances
    Given I enter instances collection
    And I am authorized with my credentials
    When I request HTML response
    Then result should be valid HTML
    When I request XML response
    Then result should be valid XML
    And result should contain 5 instances
    And name of these instances should be
      |  apitest1  |
      |  bababab   |
      |  test1     |
      |  test5     |
      | TestPool-1 |
    And each instance should have properties set to
      | owner_id     |  admin@rhevm.brq.redhat.com |


  Scenario: Get details about bababab instance
    Given I enter instances collection
    And I am authorized with my credentials
    And I choose instance with id 5b2555c9-73f1-46dc-b379-a1f6dd382c86
    When I request HTML response
    Then result should be valid HTML
    When I request XML response
    Then result should be valid XML
    And result should contain one instance
    And attribute id should be set to 5b2555c9-73f1-46dc-b379-a1f6dd382c86
    And instance should have launch_time set to valid time
    And instance should be in RUNNING state
    And instance should have defined actions
      | reboot |
      | stop   |
    And instance should have set of public_addresses 
      | 10.34.2.121      |
    And instance should have linked valid
      | realm            |
      | image            |
      | hardware_profile |

  Scenario: Stop bababab instance
    Given I enter instances collection
    And I am authorized with my credentials
    And I choose instance with id 5b2555c9-73f1-46dc-b379-a1f6dd382c86
    When I request XML response
    Then result should be valid XML
    And result should contain one instance
    And attribute id should be set to 5b2555c9-73f1-46dc-b379-a1f6dd382c86
    Then I want to stop this instance
    And I follow stop link in actions
    And this instance should be in STOPPED state

  Scenario: Start test1 instance
    Given I enter instances collection
    And I am authorized with my credentials
    And I choose instance with id 5b602d1a-4db0-4ab0-8842-5f3dfb551ba6
    When I request XML response
    Then result should be valid XML
    And result should contain one instance
    And attribute id should be set to 5b602d1a-4db0-4ab0-8842-5f3dfb551ba6
    Then I want to start this instance
    And I follow start link in actions
    And this instance should be in RUNNING state

