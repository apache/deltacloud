Feature: Returning valid responses with various queries

  Scenario: User will get XML version if there is no Accept or format parameter
    Given URI /api exists
    And authentification is not required for this URI
    And client perform an HTTP request for this URI
    Then client should get valid XML response

  Scenario: User wants to get XML version of API using Accept header
    Given URI /api exists
    And authentification is not required for this URI
    When client use Accept header:
    | application/xml;q=0.9 |
    And client perform an HTTP request for this URI
    Then client should get valid XML response

  Scenario: User wants to get HTML version of API using Accept header
  Given URI /api exists
    And authentification is not required for this URI
    When client use Accept header:
    | application/xhtml+html;q=0.9 |
    And client perform an HTTP request for this URI
    Then client should get valid HTML response

  Scenario: User wants to get JSON version of API
  Given URI /api exists
    And authentification is not required for this URI
    When client use Accept header:
    | application/json;q=0.9 |
    And client perform an HTTP request for this URI
    Then client should get valid JSON response

  Scenario: User wants to get XML version of API with format parameter
    Given URI /api exists
    And authentification is not required for this URI
    When client use Accept header:
    | application/xhtml+html;q=0.9 |
    And client accept this URI with parameters:
    | format | xml |
    And client perform an HTTP request for this URI
    Then client should get valid XML response

  Scenario: User wants to get JSON version of API with format parameter
    Given URI /api exists
    And authentification is not required for this URI
    When client use Accept header:
    | application/xhtml+html;q=0.9 |
    And client accept this URI with parameters:
    | format | json |
    And client perform an HTTP request for this URI
    Then client should get valid JSON response

  Scenario: User set Accept to json but force format to XML using format parameter 
    Given URI /api exists
    And authentification is not required for this URI
    When client use Accept header:
    | application/json;q=0.9 |
    And client accept this URI with parameters:
    | format | xml |
    And client perform an HTTP request for this URI
    Then client should get valid XML response

  # Extensions are ignored, so this doesn't affect content-negotiation
  Scenario: User wants to get XML version of API with format parameter and set extension
    Given URI /api exists
    And authentification is not required for this URI
    When client wants to get URI '/api.xml'
    When client use Accept header:
    | application/xhtml+html;q=0.9 |
    And client perform an HTTP request for this URI
    Then client should get valid HTML response
