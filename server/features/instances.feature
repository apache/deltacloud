Feature: Managing instances
  In order to manage instances

  Background:
    Given I want to get XML

  Scenario: I want to get list of all instances
    Given I am authorized to list instances
    When I request index operation for instances collection
    # FIXME: Add starting number here
    Then I should see some instance inside instances

  Scenario: I want to create a new instance
    Given I am authorized to create instance
    When I request create new instance with:
      | name     | <INSTANCE_1_NAME> | 
      | image_id | <INSTANCE_IMAGE_ID> | 
    Then I should request this instance
    And this instance should be 'RUNNING'
    And this instance should have name '<INSTANCE_1_NAME>'
    And this instance should be image '<INSTANCE_IMAGE_ID>'

  Scenario: I want to create a new instance using realm
    Given I am authorized to create instance
    When I request create new instance with:
      | name     | <INSTANCE_2_NAME> | 
      | image_id | <INSTANCE_IMAGE_ID> | 
      | realm    | <INSTANCE_REALM> | 
    Then I should request this instance
    And this instance should be 'RUNNING'
    And this instance should have name '<INSTANCE_2_NAME>'
    And this instance should be image '<INSTANCE_IMAGE_ID>'
    And this instance should have realm  '<INSTANCE_REALM>'

  Scenario: I want to show instance details
    Given I am authorized to show instance '<INSTANCE_1_ID>'
    When I request for '<INSTANCE_1_ID>' instance
    Then I should get this instance
    And instance should contain id parameter
    And instance should contain name parameter
    And instance should contain owner_id parameter
    And instance should contain state parameter
    And instance state should be RUNNING
    When instance state is RUNNING
    Then instance should have one public address
    And instance should have one private address
    When instance state is RUNNING
    Then instance should include link to 'reboot' action
    And instance should include link to 'stop' action

  Scenario: I want to get instance image
    Given I am authorized to show instance '<INSTANCE_1_ID>'
    Given I request for '<INSTANCE_1_ID>' instance
    When I want to get details about instance image
    Then I could follow image href attribute
    And this attribute should point me to valid image

  Scenario: I want to get instance flavor
    Given I am authorized to show instance '<INSTANCE_1_ID>'
    Given I request for '<INSTANCE_1_ID>' instance
    When I want to get details about instance flavor
    Then I could follow flavor href attribute
    And this attribute should point me to valid flavor

  Scenario: I want to get instance realm
    Given I am authorized to show instance '<INSTANCE_1_ID>'
    Given I request for '<INSTANCE_1_ID>' instance
    When I want to get details about instance realm
    Then I could follow realm href attribute
    And this attribute should point me to valid realm

  Scenario: I want to stop instance
    Given I am authorized to show instance '<INSTANCE_1_ID>'
    Given I request for '<INSTANCE_1_ID>' instance
    When I want to stop this instance
    Then I could follow stop action in actions
    And this instance state should be 'STOPPED'

  Scenario: I want to start instance
    Given I am authorized to show instance '<INSTANCE_1_ID>'
    Given I request for '<INSTANCE_1_ID>' instance
    When I want to stop this instance
    Then I could follow start action in actions
    And this instance state should be 'RUNNING'

  Scenario: I want to reboot instance
    Given I am authorized to show instance '<INSTANCE_1_ID>'
    Given I request for '<INSTANCE_1_ID>' instance
    When I want to reboot this instance
    Then I could follow reboot action in actions
    And this instance state should be 'RUNNING'

  Scenario: I want to destroy instance
    Given I am authorized to show instance '<INSTANCE_1_ID>'
    Given I request for '<INSTANCE_1_ID>' instance
    When I want to stop this instance
    Then I could follow stop action in actions
    And this instance state should be 'STOPPED'
