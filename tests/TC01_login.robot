*** Settings ***
Resource            ${EXECDIR}${/}resources${/}base_keywords.resource
Resource    ../resources/base_keywords.resource

Test Setup          Before Tests
Test Teardown       After Tests

*** Test Cases ***
Scenario: Login successfully
    [Tags]    login_success
    Given login page is open
    When user perform login    ${username}    ${password}
    Then the home page is open

Scenario: Logout successfully
    [Tags]    logout_success
    [Setup]   user should be logged in
    Given the home page is open
    When user perform logout
    Then login page should be open

Scenario: Login with wrong credentials
    [Tags]    wrong_login
    Given the home page is open
    When user perform login           username=test    password=test
    Then login should be unsuccessful