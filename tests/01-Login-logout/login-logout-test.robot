*** Settings ***
Documentation       Test cases for logging into the Swag Labs application.
Resource            ${EXECDIR}${/}resources${/}base_keywords.resource

Test Setup          Before Tests
Test Teardown       After Tests
Test Tags           smoke


*** Test Cases ***

TC-Login-Logout-01: Login successfully
    [Tags]    feature-login
    Given login page is open
    When user perform login    ${username}    ${password}
    Then the home page is open   

TC-Login-Logout-02: Logout successfully
    [Tags]    feature-logout
    [Setup]   user should be logged in
    Given the home page is open
    When user perform logout
    Then login page should be open
