Feature: Add/Remove Elements

    Scenario: Add an element
        Given I open the Add Remove Elements page
        When I add an element
        Then I should see the element

    Scenario: Remove an element
        Given I open the Add Remove Elements page
        When I add an element
        And I remove the element
        Then I should not see the element
