*** Settings ***
Resource            ${EXECDIR}${/}resources${/}base_keywords.resource
Resource            ${EXECDIR}${/}resources${/}base_variables.resource

Test Setup          Before Tests
Test Teardown       After Tests

*** Test Cases ***

Scenario: Filter products by price
    [Tags]    filter_products
    Perform Login    standard_user    secret_sauce
    Home Page Should Be Open
    Filter Products                         filer_type=Price (low to high)
    Products Should Be Filtered             filer_type=Price (low to high)