Feature: Working with RHEV-M images

  Scenario: Get list of available images
    Given I enter images collection
    And I am authorized with my credentials
    When I request HTML response
    Then result should be valid HTML
    When I request XML response
    Then result should be valid XML
    And result should contain 3 images
    And name of these images should be
      | Blank |
      | DamnSmallLinux |
      | Fedora14Live |
    And each image should have properties set to
      | architecture |  x86_64                     |
      | owner_id     |  admin@rhevm.brq.redhat.com |
      | state        |  OK                         |


  Scenario: Get details about Fedora image
    Given I enter images collection
    And I am authorized with my credentials
    And I choose image with id f7c71c82-ad3f-4b08-b741-db37a40429b4
    When I request HTML response
    Then result should be valid HTML
    When I request XML response
    Then result should be valid XML
    And result should contain one image
    And attribute id should be set to f7c71c82-ad3f-4b08-b741-db37a40429b4
