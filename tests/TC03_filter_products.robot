*** Settings ***
Resource            ${EXECDIR}${/}resources${/}base_keywords.resource

Test Setup          Before Tests
Test Teardown       After Tests

*** Test Cases ***

Scenario: Filter products by price (low to high)
    [Tags]    filter_products
    [Setup]   user should be logged in
    Given the home page is open
    When user filter products by price (low to high)
    Then products should be filtered
    
Scenario: Filter products by price (high to low)
    [Tags]    filter_products
    [Setup]   user should be logged in
    Given the home page is open
    When user filter products by price (high to low)
    Then products should be filtered

Scenario: Filter products by name (A to Z)
    [Tags]    filter_products
    [Setup]   user should be logged in
    Given the home page is open
    When user filter products by name (A to Z)
    Then products should be filtered

Scenario: Filter products by name (Z to A)
    [Tags]    filter_products
    [Setup]   user should be logged in
    Given the home page is open
    When user filter products by name (Z to A)
    Then products should be filtered
    