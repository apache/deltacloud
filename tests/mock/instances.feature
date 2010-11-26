Feature: Managing instances

  Scenario: Listing current instances
    Given URI /api/instances exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'instances'
    And this element contains some instances
    And each instance should have:
    | name |
    | owner_id |
    | image |
    | realm |
    | state |
    | hardware_profile |
    | actions |
    | public_addresses |
    | private_addresses |
    And each instance should have 'href' attribute with valid URL
    And this URI should be available in XML, JSON, HTML format

  Scenario: Filtering instances by state
    Given URI /api/instances exists
    And authentification is required for this URI
    When client access this URI with parameters:
    | state | RUNNING |
    Then client should get some instances
    And each instance should have 'state' attribute set to 'RUNNING'

  Scenario: Get details about first instance
    Given URI /api/instances exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'instances'
    And this element contains some instances
    When client want to show first instance
    Then client follow href attribute in first instance
    Then client should get this instance
    And this instance should have:
    | name |
    | owner_id |
    | image |
    | realm |
    | state |
    | hardware_profile |
    | actions |
    | authentication |
    | public_addresses |
    | private_addresses |

  Scenario: Following image href in instance
    Given URI /api/instances exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'instances'
    And this element contains some instances
    When client follow image href attribute in first instance
    Then client should get valid image

  Scenario: Following realm href in instance
    Given URI /api/instances exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'instances'
    And this element contains some instances
    When client follow realm href attribute in first instance
    Then client should get valid realm

  Scenario: Following hardware profile href in instance
    Given URI /api/instances exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'instances'
    And this element contains some instances
    When client follow hardware_profile href attribute in first instance
    Then client should get valid hardware_profile

  Scenario: Instance actions
    Given URI /api/instances exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'instances'
    And this element contains some instances
    And each instance should have actions
    And each actions should have some links
    And each link should have valid href attribute
    And each link should have valid method attribute
    And each link should have valid rel attribute

  Scenario: Reboot instance
    Given URI /api/instances exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'instances'
    And this element contains some instances
    When client want to 'reboot' first instance
    And client follow link in actions
    Then client should get first instance
    And this instance should be in 'RUNNING' state

  Scenario: Stop instance
    Given URI /api/instances exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'instances'
    And this element contains some instances
    When client want to 'stop' first instance
    And client follow link in actions
    Then client should get first instance
    And this instance should be in 'STOPPED' state

  Scenario: Start instance
    Given URI /api/instances exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'instances'
    And this element contains some instances
    When client want to 'start' first instance
    And client follow link in actions
    Then client should get first instance
    And this instance should be in 'RUNNING' state

  Scenario: Basic instance creation
    Given URI /api/instances exists
    And authentification is required for this URI
    When client want to create a new instance
    Then client should choose first image
    When client request for a new instance
    Then new instance should be created
    And this instance should have chosed image
    And this instance should be in 'RUNNING' state
    And this instance should have valid id
    And this instance should have name

  Scenario: Choosing hardware profile for instance
    Given URI /api/instances exists
    And authentification is required for this URI
    When client want to create a new instance
    Then client should choose first image
    And client choose last hardware profile
    When client request for a new instance
    Then new instance should be created
    And this instance should have chosed image
    And this instance should be in 'RUNNING' state
    And this instance should have valid id
    And this instance should have last hardware profile
    And this instance should have name

  Scenario: Create instance using HTML form
    Given URI /api/instances/new exists in HTML format
    And authentification is required for this URI
    When client access this URI
    Then client should get HTML form

  Scenario: Destroying created instance
    Given URI /api/instances exists
    And authentification is required for this URI
    When client want to 'stop' first instance
    And client follow link in actions
    Then client should get this instance
    And this instance should be in 'STOPPED' state
    When client want to 'destroy' first instance
    And client follow link in actions
    And this instance should be destroyed
