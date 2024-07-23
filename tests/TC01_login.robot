*** Settings ***
Resource            ${EXECDIR}${/}resources${/}base_keywords.resource

Test Setup          Before Tests
Test Teardown       After Tests

*** Test Cases ***

Scenario: Login successfully
    [Tags]    login_success
    Perform Login    standard_user    secret_sauce
    Home Page Should Be Open

Scenario: Logout successfully
    [Tags]    logout_success
    Perform Login    standard_user    secret_sauce
    Home Page Should Be Open
    Perform Logout

Scenario: Login with wrong credentials
    [Tags]    wrong_login
    Perform Login                 username=test    password=test
    Wait Until Page Contains      Username and password do not match any user in this service.    timeout=5