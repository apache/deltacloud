Feature: CIMI Volumes Collection
  The URI of the Volumes collection is given in the Cloud Entry Point.

Scenario: Create a new Volume entity
  Given Cloud Entry Point URL is provided
  And client retrieve the Cloud Entry Point
  When client specifies a Volume Configuration
    | volumeConfig | http://example.com/cimi/volume_configurations/2 |
  And client specifies a new Volume using
    | name | cucumber_volume |
    | description | created in a cucumber scenario |
  Then client should be able to create this Volume

Scenario: Query the Volume collection
  Given Cloud Entry Point URL is provided
  And client retrieve the Cloud Entry Point
  When client GET the Volumes Collection
  Then client should get a list of volumes
  And list of volumes should contain newly created volume

Scenario: Query the newly created Volume
  Given Cloud Entry Point URL is provided
  And client retrieve the Cloud Entry Point
  When client GET the newly created Volume in json format
  Then client should verify that this Volume was created correctly
    | capacity | 2 |

Scenario: Attach the newly created Volume to a Machine
  Given Cloud Entry Point URL is provided
  And client retrieve the Cloud Entry Point
  When client specifies a running Machine using
    | name | inst0 |
  And client specifies the new Volume with attachment point using
    | attachment_point | /dev/sdc |
  Then client should be able to attach the new volume to the Machine

Scenario: Detach the newly created Volume from the Machine
  Given Cloud Entry Point URL is provided
  And client retrieve the Cloud Entry Point
  Then client should be able to detach the volume

Scenario: Delete the newly created Volume
  Given Cloud Entry Point URL is provided
  And client retrieve the Cloud Entry Point
  When client deletes the newly created Volume
  Then client should verify the volume was deleted
