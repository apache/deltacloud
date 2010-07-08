Feature: Running rake tasks

  Scenario: I want to build Deltacloud API gem
    Given I have a clean /pkg directory
    When I run a 'package' task
    Then I should see a gem file inside pkg directory
    And I should see a tgz file inside pkg directory
