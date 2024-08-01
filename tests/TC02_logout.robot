*** Settings ***
Resource            ${EXECDIR}${/}resources${/}base_keywords.resource

Test Setup          Before Tests
Test Teardown       After Tests

*** Test Cases ***

Scenario: Logout successfully
    [Tags]    logout_success
    [Setup]   user should be logged in
    Given the home page is open
    When user perform logout
    Then login page should be open
