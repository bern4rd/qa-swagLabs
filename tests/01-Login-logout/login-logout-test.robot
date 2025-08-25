*** Settings ***
Documentation       Test cases for login and logout into the Swag Labs application.
Resource            ${EXECDIR}${/}resources${/}base.resource

Test Setup           Before Tests
Suite Teardown       After Tests

Task Tags            feature-login-logout

*** Test Cases ***

TC-Login-Logout-01: Login successfully
    [Documentation]    Tests the successful login process with valid credentials.
    [Tags]    feature-login    smoke
    Given login page is open
    When user perform login    
    Then the home page is open   

TC-Login-Logout-02: Logout successfully
    [Documentation]    Tests the successful logout process after logging in.
    [Tags]    feature-logout    smoke
    [Setup]   Run Keywords   Before Tests  AND  user should be logged in
    Given the home page is open
    When user perform logout
    Then login page should be open

TC-Login-Logout-03: Login with empty username
    [Documentation]    Tests the login process with an empty username field.
    [Tags]    feature-login-negative
    Given login page is open
    When user perform login    user=${EMPTY}    
    Then login error should be displayed   message=Username is required

TC-Login-Logout-04: Login with empty password
    [Documentation]    Tests the login process with an empty username field.
    [Tags]    feature-login-negative
    Given login page is open
    When user perform login    pass=${EMPTY}
    Then login error should be displayed   message=Password is required

TC-Login-Logout-05: Login with invalid credentials
    [Documentation]    Tests the login process with an empty username field.
    [Tags]    feature-login-negative
    Given login page is open
    When user perform login    user=invalid_user
    Then login error should be displayed       message=Username and password do not match any user in this service.

TC-Login-Logout-06: Login with locked out user
    [Documentation]    Tests the login process with an empty username field.
    [Tags]    feature-login-negative
    Given login page is open
    When user perform login    user=locked_out_user
    Then login error should be displayed       message=Sorry, this user has been locked out.