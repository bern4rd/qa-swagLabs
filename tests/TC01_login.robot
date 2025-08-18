*** Settings ***
Resource            ${EXECDIR}${/}resources${/}base_keywords.resource

Test Setup          Before Tests
Test Teardown       After Tests

*** Test Cases ***
Scenario: Login successfully
    [Tags]    login_success
    Given login page is open
    When user perform login    ${username}    ${password}
    Then the home page is open   
