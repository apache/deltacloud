Feature: Managing instances

  @prefix-create
  Scenario: Basic instance creation
    Given URI /api/instances exists
    And authentification is required for this URI
    When client want to create a new instance
    Then client should choose first image
    When client request for a new instance
    Then new instance should be created
    And this instance should have chosed image
    And this instance should be in 'PENDING' state
    And this instance should have valid id
    And this instance should have name

  @prefix-create-hwp
  Scenario: Choosing hardware profile for instance
    Given URI /api/instances exists
    And authentification is required for this URI
    When client want to create a new instance
    Then client should choose first image
    And client choose first hardware profile
    When client request for a new instance
    Then new instance should be created
    And this instance should have chosed image
    And this instance should be in 'PENDING' state
    And this instance should have valid id
    And this instance should have last hardware profile
    And this instance should have name

  @prefix-create-public_ip
  Scenario: Choosing public ip address for instance
    Given URI /api/instances exists
    And authentification is required for this URI
    When client want to create a new instance
    Then client should choose first image
    And client choose public IP address '184.73.218.247'
    When client request for a new instance
    Then new instance should be created
    And this instance should have chosed image
    And this instance should be in 'PENDING' state
    And this instance should have valid id
    And this instance should have name
    And IP address for this instance should be '184.73.218.247'

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
    | state | STOPPED |
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
    | public_addresses |
    | private_addresses |
    | authentication |
    | launch_time |

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

  @prefix-actions
  Scenario: Instance actions
    Given URI /api/instances exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'instances'
    And this element contains some instances
    And each running instance should have actions
    And each actions should have some links
    And each link should have valid href attribute
    And each link should have valid method attribute
    And each link should have valid rel attribute

  @prefix-reboot
  Scenario: Reboot instance
    Given URI /api/instances exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'instances'
    And this element contains some instances
    When client want to 'reboot' RUNNING instance
    And client follow link in actions

  @prefix-stop
  Scenario: Stop instance
    Given URI /api/instances exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'instances'
    And this element contains some instances
    When client want to 'stop' last instance
    And client follow link in actions


  @prefix-destroy
  Scenario: Destroying created instance
    Given URI /api/instances exists
    And authentification is required for this URI
    When client want to 'stop' RUNNING instance
    And client follow link in actions
    Then client should get created instance
    And this instance should be destroyed
