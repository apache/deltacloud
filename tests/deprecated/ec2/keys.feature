Feature: Managing keys

  Scenario: Basic key creation
    Given URI /api/keys exists
    And authentification is required for this URI
    When client want to create a new key
    Then client should choose name 'test001'
    When client request for a new key
    Then new key should be created
    And this instance should have id attribute set to 'test001'
    And this instance should have valid fingerprint
    And this instance should have valid pem key
    And this instance should have credential_type set to 'key'
    And this instance should have state set to AVAILABLE
    And this instance should have destroy action

  Scenario: Listing current keys
    Given URI /api/keys exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'keys'
    And this element contains some keys
    And each instance should have:
    | name |
    | fingerprint |
    | state |
    | actions |
    And each key should have 'href' attribute with valid URL
    And this URI should be available in XML, JSON, HTML format

 Scenario: Get details about last key
    Given URI /api/keys exists
    And authentification is required for this URI
    When client access this URI
    Then client should get root element 'keys'
    And this element contains some keys
    When client want to show first key
    Then client follow href attribute in first key
    Then client should get this key
    And this instance should have:
    | name |
    | actions |
    | credential_type |
    | fingerprint |
    | state |

  @prefix-destroy
  Scenario: Destroying created key
    Given URI /api/keys exists
    And authentification is required for this URI
    When client want to 'destroy' last key
    And client follow destroy link in actions
    Then client should get created key
    And this key should be destroyed

