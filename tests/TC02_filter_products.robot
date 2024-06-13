*** Settings ***
Resource            ${EXECDIR}${/}resources${/}base_keywords.resource

Test Setup          Before Tests
Test Teardown       After Tests

*** Test Cases ***

Scenario: Filter products by price (low to high)
    [Tags]    filter_products
    Perform Login    standard_user    secret_sauce
    Home Page Should Be Open
    Filter Products Without Bug             filter_type=Price (low to high)
    Products Should Be Filtered             filter_type=Price (low to high)

Scenario: Filter products by price (high to low)
    [Tags]    filter_products
    Perform Login    standard_user    secret_sauce
    Home Page Should Be Open
    Filter Products Without Bug             filter_type=Price (high to low)
    Products Should Be Filtered             filter_type=Price (high to low)

Scenario: Filter products by name (A to Z)
    [Tags]    filter_products
    Perform Login    standard_user    secret_sauce
    Home Page Should Be Open
    Filter Products Without Bug             filter_type=Name (A to Z)
    Products Should Be Filtered             filter_type=Name (A to Z)

Scenario: Filter products by name (Z to A)
    [Tags]    filter_products
    Perform Login    standard_user    secret_sauce
    Home Page Should Be Open
    Filter Products Without Bug             filter_type=Name (Z to A)
    Products Should Be Filtered             filter_type=Name (Z to A)