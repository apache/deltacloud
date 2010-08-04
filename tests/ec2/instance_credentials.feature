Feature: Managing instance credentials

  Scenario: Basic instance credential creation
    Given URI /api/instance_credentials exists
    And authentification is required for this URI
    When client want to create a new instance credential
    Then client should choose name 'test01'
    When client request for a new instance credential
    Then new instance credential should be created
    And this instance should have id attribute set to 'test01'
    And this instance should have valid fingerprint
    And this instance should have valid pem key
    And this instance should have credential_type set to 'key'
    And this instance should have destroy action

  Scenario: Listing current instance credentials
    Given URI /api/instance_credentials exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'instance_credentials'
    And this element contains some instance_credentials
    And each instance should have:
    | name |
    | actions |
    And each instance_credential should have 'href' attribute with valid URL
    And this URI should be available in XML, JSON, HTML format

 Scenario: Get details about last instance_credential
    Given URI /api/instance_credentials exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'instance_credentials'
    And this element contains some instance_credentials
    When client want to show first instance_credential
    Then client follow href attribute in first instance_credential
    Then client should get this instance_credential
    And this instance should have:
    | name |
    | actions |
    | credential_type |
    | fingerprint |

  @prefix-destroy
  Scenario: Destroying created instance credential
    Given URI /api/instances exists
    And authentification is required for this URI
    When client want to 'destroy' last instance_credential
    And client follow destroy link in actions
    Then client should get created instance_credential
    And this instance_credential should be destroyed

