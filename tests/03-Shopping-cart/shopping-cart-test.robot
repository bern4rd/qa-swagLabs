*** Settings ***
Documentation       Test cases for shopping cart functionality in the Swag Labs application.
Resource            ${EXECDIR}${/}resources${/}base.resource

Suite Setup         Before Tests
Suite Teardown      After Tests
Test Tags           feature-shopping-cart

*** Test Cases ***

TC-Shopping-Cart-01: Add product to cart
    [Setup]   user perform login
    Given the home page is open
    When user adds the product to the cart
    Then the cart should contain the product

#:TODO: 

# TC-Shopping-Cart-02: Remove product from cart
#     [Setup]   user should have a product in the cart
#     Given the cart page is open
#     When user removes the product from the cart
#     Then the cart should be empty


