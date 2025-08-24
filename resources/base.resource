*** Settings ***
Documentation     Base resource file containing common settings, variables, and keywords for the Swag Labs application tests.
# Import keyword files
Resource          common${/}common-keywords.resource
Resource          01-access${/}login-keywords.resource    
Resource          02-filter-products${/}filter-products-keywords.resource
Resource          03-shopping-cart${/}shopping-cart-keywords.resource
Resource          04-checkout${/}checkout-keywords.resource
Resource          05-geolocation${/}geolocation-keywords.resource