Feature: Instance states and transitions

  Scenario: Getting list of states
    Given URI /api/instance_states exists
    And authentification is not required for this URI
    When client access this URI
    Then client should get root element 'states'
    And this element contains some states
    And this URI should be available in XML, JSON, HTML format


  Scenario: State names
    Given URI /api/instance_states exists
    And authentification is not required for this URI
    When client access this URI
    Then client should get root element 'states'
    And states element contains some states
    And each state should have 'name' attribute
    And first state should have 'name' attribute set to 'start'
    And last state should have 'name' attribute set to 'finish'

  Scenario: Transitions
    Given URI /api/instance_states exists
    And authentification is not required for this URI
    When client access this URI
    Then client should get root element 'states'
    And states element contains some states
    And some states should have transitions
    And each transitions should have 'to' attribute

  Scenario: State diagram
    Given URI /api/instance_states exists
    And authentification is not required for this URI
    When client access this URI
    And client wants PNG format
    Then client should get PNG image
