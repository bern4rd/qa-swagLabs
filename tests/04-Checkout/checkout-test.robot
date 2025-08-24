*** Settings ***
Documentation       Test cases for checkout functionality in the Swag Labs application.    
Resource            ${EXECDIR}${/}resources${/}base.resource

Suite Setup         Before Tests
Suite Teardown      After Tests
Test Tags           feature-checkout

*** Test Cases ***

TC-Checkout-01: Checkout with empty first name
    [Tags]    negative
    [Setup]   user should be at information checkout page
    Given user is at information checkout page
    When user proceeds to checkout with empty first name
    Then message error First Name is required should be displayed

TC-Checkout-02: Checkout with empty last name
    [Tags]    negative
    [Setup]   user should be at information checkout page
    Given user is at information checkout page
    When user proceeds to checkout with empty last name
    Then message error Last Name is required should be displayed

TC-Checkout-03: Checkout with empty zip/postal code
    [Tags]    negative
    [Setup]   user should be at information checkout page
    Given user is at information checkout page
    When user proceeds to checkout with empty zip/postal code
    Then message error Postal Code is required should be displayed

TC-Checkout-04: Checkout a product successfully
    [Setup]   user should be at information checkout page
    Given user is at information checkout page
    When user proceeds to checkout with valid information
    Then user should be redirected to the order confirmation page
