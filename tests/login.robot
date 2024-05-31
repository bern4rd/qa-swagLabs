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

Scenario: Filter products by price
    [Tags]    filter_products
    Perform Login    standard_user    secret_sauce
    Home Page Should Be Open
    Filter Products                         filer_type=Price (low to high)
    Products Should Be Filtered             filer_type=Price (low to high)

Scenario: Just Open The Application
    [Tags]    open_app
    Log       Open the application
    Sleep     10

*** Keywords ***

Filter Products     
    [Arguments]    ${filer_type}
    Wait Until Element Is Interactive    accessibility_id=test-Modal Selector Button
    Click Element                        accessibility_id=test-Modal Selector Button
    Wait Until Element Is Visible        accessibility_id=${filer_type}
    Click Element                        accessibility_id=${filer_type}

Products Should Be Filtered  
    [Arguments]    ${filer_type}
    Page Should Not Contain Element      accessibility_id=${filer_type}

    IF  "${filer_type}" == "Price (low to high)"
        Wait Until Element Is Visible        accessibility_id=assets/src/img/red-onesie.jpg    timeout=5

    ELSE IF    "${filer_type}" == "Price (high to low)"
        No Operation

    ELSE IF    "${filer_type}" == "Name (A to Z)"
        No Operation

    ELSE IF    "${filer_type}" == "Name (Z to A)"
        No Operation
        
    ELSE
        Fail    The filter ${filer_type} is not supported
    END
    