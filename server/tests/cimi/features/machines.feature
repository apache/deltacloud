Feature: Managing Machines
  In order to interact with the provider
  We must first be provided a URL to the main entry point (CEP).

  Scenario: Create a New Machine
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

  Scenario: Querying created Machine
    Given Cloud Entry Point URL is provided
    And client retrieve the Cloud Entry Point
    When client query for 'sampleMachine1' Machine
    And client should verify that this machine exists

  Scenario: Stopping Machine
    Given Cloud Entry Point URL is provided
    And client retrieve the Cloud Entry Point
    When client executes stop operation on Machine 'sampleMAchine1'
    Then client should be able to query this Machine
    And client should verify that this machine is stopped

  Scenario: Starting Machine
    Given Cloud Entry Point URL is provided
    And client retrieve the Cloud Entry Point
    When client executes start operation on Machine 'sampleMAchine1'
    Then client should be able to query this Machine
    And client should verify that this machine is started
