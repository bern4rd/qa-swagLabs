*** Settings ***
Documentation       Test cases for filtering products by price and name in the Swag Labs application.
Resource            ${EXECDIR}${/}resources${/}base.resource

Test Setup          Run Keywords   Before Tests  AND  user should be logged in
Test Teardown       After Tests
Test Tags           feature-filter-products

*** Test Cases ***

TC-Filter-Products-01: Filter products by price (low to high)
    Given the home page is open
    When user filter products by price (low to high)
    Then products should be filtered

TC-Filter-Products-02: Filter products by price (high to low)
    Given the home page is open
    When user filter products by price (high to low)
    Then products should be filtered

TC-Filter-Products-03: Filter products by name (A to Z)
    Given the home page is open
    When user filter products by name (A to Z)
    Then products should be filtered

TC-Filter-Products-04: Filter products by name (Z to A)
    Given the home page is open
    When user filter products by name (Z to A)
    Then products should be filtered
    