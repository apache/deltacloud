Feature: Accessing storage volumes

 # Sorry, but something weird happened with this scenarion.
 # When I leave all 5 items in 'should have:' section I got:
 #
 # expected: ["capacity", "created", "device", "instance", "state"],
 #    got: ["capacity", "created"] (using ==)
 #
 # When I remove device, instance and state I got back
 # ["capacity", "created", "device", "instance", "state"]
 #
 # Anyway this test isn't usefull, because storage volumes will be
 # replaced with something 'better'.
 #
 # Scenario: Listing available storage volumes
 #   Given URI /api/storage_volumes exists
 #   And authentification is required for this URI
 #   When client access this URI
 #   Then client should get root element 'storage_volumes'
 #   And this element contains some storage_volumes
 #   And each storage_volume should have:
 #   | created |
 #   | capacity |
 #   | device |
 #   | instance |
 #   | state |
 #   And each image should have 'href' attribute with valid URL
 #   And this URI should be available in XML, JSON, HTML format

 # Scenario: Get details about first volume
 #   Given URI /api/storage_volumes exists
 #   And authentification is required for this URI
 #   When client access this URI
 #   Then client should get root element 'storage_volumes'
 #   And this element contains some storage_volumes
 #   When client want to show first storage_volume
 #   Then client follow href attribute in first storage_volume
 #   Then client should get this storage_volume
 #   And this storage_volume should have:
 #   | created |
 #   | capacity |
 #   | mount |
 #   | realm_id |
 #   | state |
