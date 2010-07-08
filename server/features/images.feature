Feature: Working with images
  In order to work with images

  Background:
    Given I want to get XML

  Scenario: I want to get list of all images
    When I request index operation for images collection
    Then I in order to see list of images I need to be authorized
    When I enter correct username and password
    And I request index operation for images collection
    Then I should see <IMAGE_COUNT> image inside images

  Scenario: I want to show image details
    Given I am authorized to show image '<IMAGE_ID>'
    When I request for '<IMAGE_ID>' image
    Then I should get this image
    And image should have valid href parameter
    And image should contain id parameter
    And image should contain name parameter
    And image should contain owner_id parameter
    And image should contain description parameter
    And image should contain architecture parameter

  Scenario: I want filter images by owner_id
    When I want images with '<IMAGE_OWNER>' owner_id
    Then I should get only images with owner_id '<IMAGE_OWNER>'

  Scenario: I want filter images by architecture
    When I want images with '<IMAGE_ARCH>' architecture
    Then I should get only images with architecture '<IMAGE_ARCH>'

  Scenario: I want filter images by architecture
    When I want images with '<IMAGE_ARCH>' architecture
    And images with '<IMAGE_OWNER>' owner_id
    Then I should get only images with architecture '<IMAGE_ARCH>'
    And this images should also have owner_id '<IMAGE_OWNER>'
