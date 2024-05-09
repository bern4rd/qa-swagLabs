*** Settings ***
Resource            ${EXECDIR}${/}resources${/}base_keywords.resource
Resource            ${EXECDIR}${/}resources${/}base_variables.resource

Test Setup          Before Tests
Test Teardown       After Tests

*** Test Cases ***

Scenario: Login with wrong credentials
    [Tags]    wrong_login
    Perform Logout
    Perform Login    test    test
    Element Text Should Be    ${ERROR_MSG}    Provided credentials do not match any user in this service.

Scenario: Login successfully
    [Tags]    login_success
    Perform Login    standard_user    secret_sauce
    Home Page Should Be Open

Scenario: Logout successfully
    [Tags]    logout_success
    Perform Login    standard_user    secret_sauce
    Home Page Should Be Open
    Perform Logout

Scenario: Just Open The Application
    [Tags]    open_app
    Log       Open the application
    Sleep     10