*** Settings ***
Documentation       Test cases for checkout functionality in the Swag Labs application.    
Resource            ${EXECDIR}${/}resources${/}base.resource

Suite Setup         Before Tests
Suite Teardown      After Tests
Test Tags           feature-checkout

*** Test Cases ***

TC-Checkout-01: Checkout with valid information
    [Setup]   user should be logged in
    Given the cart is not empty
    When user proceeds to checkout with valid information
    Then the order should be placed successfully

TC-Checkout-02: Checkout with empty cart
    [Setup]   user should be logged in
    Given the cart is empty
    When user attempts to checkout
    Then an error message should be displayed

TC-Checkout-03: Checkout with invalid payment information
    [Setup]   user should be logged in
    Given the cart is not empty
    When user proceeds to checkout with invalid payment information
    Then an error message should be displayed
