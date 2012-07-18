Feature: Managing Machines
  In order to interact with the provider
  We must first be provided a URL to the main entry point (CEP).

  Scenario: Create a New Machine entity
    Given Cloud Entry Point URL is provided
    And client retrieve the Cloud Entry Point
    When client specifies a Machine Image
      | machineImage | http://example.com/cimi/machine_images/img1 |
    And client specifies a Machine Configuration
      |   machineConfig | http://example.com/cimi/machine_configurations/m1-small |
    And client specifies a new Machine using
      | name | sampleMachine1 |
      | description | sampleMachine1Description |
    Then client should be able to create this Machine

  Scenario: Querying created Machine entity
    Given Cloud Entry Point URL is provided
    And client retrieve the Cloud Entry Point
    When client query for created Machine entity
    Then client should verify that this Machine exists
    And client should verify that this Machine has been created properly
      | cpu         | 1                         |
      | memory      | 1740.8                    |
      | state       | STARTED                   |

  Scenario: Stopping created Machine entity
    Given Cloud Entry Point URL is provided
    And client retrieve the Cloud Entry Point
    When client executes stop operation on created Machine
    Then client query for created Machine entity
    And client should verify that this machine is stopped

  Scenario: Starting created Machine entity
    Given Cloud Entry Point URL is provided
    And client retrieve the Cloud Entry Point
    When client executes start operation on created Machine
    Then client query for created Machine entity
    And client should verify that this machine is started

  Scenario: Deleting created Machine entity
    Given Cloud Entry Point URL is provided
    And client retrieve the Cloud Entry Point
    When client executes delete operation on created Machine
    Then client query for created Machine entity
    And client should verify that this machine is deleted
