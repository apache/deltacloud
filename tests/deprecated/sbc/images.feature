Feature: Working with SBC images

  Scenario: Get list of available images
    Given I enter images collection
    And I am authorized with my credentials
    When I request HTML response
    Then result should be valid HTML
    When I request XML response
    Then result should be valid XML
    And result should contain 285 images
    And name of these images should be
      | IBM Lotus Domino Enterprise Server V8.5.2 - PAYG |
      | SUSE Linux Enterprise Server 11 for x86 |
      | IBM Rational Reqmnt Composer 2.0.0.2 - BYOL |
      
   Scenario: Get details about Mashup Center image
    Given I enter images collection
    And I am authorized with my credentials
    And I choose image with id 20006009
    When I request HTML response
    Then result should be valid HTML
    When I request XML response
    Then result should be valid XML
    And result should contain one image
    And attribute id should be set to 20006009
    And the image should have properties set to
      |  state  |  AVAILABLE  |
      |  owner_id  |  SYSTEM  |
      |  architecture  |  i386  |