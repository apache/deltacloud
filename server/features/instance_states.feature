Feature: Get possible instance states
  In order to get possible instance states

  Scenario:
    Given I want to get XML
    When I follow instance states link in entry points
    Then I should see list of instance states
