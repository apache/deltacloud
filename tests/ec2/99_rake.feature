Feature: Running rake tasks

  Scenario: I want to build Deltacloud API gem
    Given I have a clean /pkg directory
    When I run a 'package' task
    Then I should see a 1 gem file inside pkg directory
    And I should see a 1 tgz file inside pkg directory
