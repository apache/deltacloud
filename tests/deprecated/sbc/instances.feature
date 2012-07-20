Feature: Working with IBM SBC instances

  Scenario: Get list of all instances
    Given I enter instances collection
    And I am authorized with my credentials
    When I request HTML response
    Then result should be valid HTML
    When I request XML response
    Then result should be valid XML
    And result should contain 3 instances
    And name of these instances should be
      |  Win2008  |
      |  EricTest1  |
      |  EricTest2  |
    And each instance should have properties set to
      |  state  |  RUNNING  |
      
  Scenario: Get details about instance 48151
    Given I enter instances collection
    And I am authorized with my credentials
    And I choose instance with id 48151
    When I request HTML response
    Then result should be valid HTML
    When I request XML response
    Then result should be valid XML
    And result should contain one instance
    And instance should be in RUNNING state
    And instance should have defined actions
      | reboot |
      | destroy |
    And attribute id should be set to 48151
    #TODO: And the property realm should have attribute realm set to 41
    #TODO: And the property image should have attribute id set to 20006009
    
  Scenario: Restart instance 48151
    Given I enter instances collection
    And I am authorized with my credentials
    And I choose instance with id 48151
    When I request XML response
    Then result should be valid XML
    And result should contain one instance
    And attribute id should be set to 48151
    Then I want to reboot this instance
    And I follow reboot link in actions
    And instance should be in RUNNING state