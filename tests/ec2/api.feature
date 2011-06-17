Feature: Accessing API entry points

  Scenario: API driver and version
    Given URI /api exists
    And authentification is not required for this URI
    When client access this URI
    Then client should get root element 'api'
    And this element should have attribute 'driver' with value 'ec2'
    And this element should have attribute 'version' with value '0.3.0'

  Scenario: List of entry points
    Given URI /api exists
    And authentification is not required for this URI
    When client access this URI
    Then client should get list of valid entry points:
    | realms     |
    | instances  |
    | keys  |
    | buckets |
    | images     |
    | drivers |
    | load_balancers |
    | instance_states |
    | hardware_profiles  |
    | storage_snapshots  |
    | storage_volumes    |
    | addresses |
    | firewalls |
    And this URI should be available in XML, JSON, HTML format

  Scenario: Following entry points
    Given URI /api exists
    And authentification is not required for this URI
    When client access this URI
    Then client should get list of valid entry points:
    | realms     |
    | instances  |
    | keys  |
    | buckets |
    | drivers |
    | images     |
    | load_balancers |
    | instance_states |
    | hardware_profiles  |
    | storage_snapshots  |
    | storage_volumes    |
    | addresses |
    | firewalls |
    And each link should have 'rel' attribute with valid name
    And each link should have 'href' attribute with valid URL
    When client follow this attribute
    Then client should get a valid response

  Scenario: Instance features
    Given URI /api exists
    And authentification is not required for this URI
    When client access this URI
    Then client should get list of features inside 'instances':
    | authentication_key |
    | attach_snapshot |
    | user_data |
    | register_to_load_balancer |
    | instance_count |
    | firewall |
