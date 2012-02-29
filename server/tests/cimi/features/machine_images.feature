Feature: Managing Machines Images
  In order to interact with the provider
  We must first be provided a URL to the main entry point (CEP).

Scenario: Listing Machine Images collection
    Given Cloud Entry Point URL is provided
    And client retrieve the Cloud Entry Point
    When client lists Machine Images collection
    Then client should get list of all Machine Images

Scenario: Querying Machine Image
    Given Cloud Entry Point URL is provided
    And client retrieve the Cloud Entry Point
    When client query for 'img1' Machine Image entity
    Then client should verify that this Machine Image exists
    And client should verify that this Machine Image has set
      | *image_location | mock://img1 |
      | description     | Fedora 10   |
      | name            | img1        |
      | id              | http://example.org/cimi/machine_images/img1 |
