Feature: Working with RHEV-M storage volumes

  Scenario: Get list of available storage volumes
    Given I enter storage_volumes collection
    And I am authorized with my credentials
    When I request HTML response
    Then result should be valid HTML
    When I request XML response
    Then result should be valid XML
    And result should contain 2 storage_volumes
    And name of these storage_volumes should be
      |  isos |
      |  windows |

  Scenario: Get details about windows storage volume
    Given I enter storage_volumes collection
    And I am authorized with my credentials
    And I choose storage_volume with id abbc1a9e-4a91-416e-9f62-a180d88f3825
    When I request HTML response
    Then result should be valid HTML
    When I request XML response
    Then result should be valid XML
    And result should contain one storage_volume
    And attribute id should be set to abbc1a9e-4a91-416e-9f62-a180d88f3825
    And storage_volume should have capacity set to
      | 194560.0 |
    And storage_volume should have device set to
      | 192.168.1.10:/RHEV |
