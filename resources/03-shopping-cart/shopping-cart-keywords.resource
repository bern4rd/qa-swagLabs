*** Settings ***
Library           AppiumLibrary    run_on_failure=Capture Page Screenshot    timeout=30s
Resource          ..${/}common${/}common-keywords.resource
Resource          shopping-cart-variables.resource

*** Keywords ***
user adds the product to the cart
    [Documentation]    Adds a product to the shopping cart.
    Wait Until Element Is Interactive            ${CART_MENU}
    Page Should Not Contain Element              ${REMOVE_PRODUCT_BTN}
    Click Element                                ${FIRST_CATALOG_PRODUCT_ADD_BTN_ANDROID}
    Wait Until Element Is Interactive            ${REMOVE_PRODUCT_BTN}

the cart should contain the product
    [Documentation]    Verifies that the cart contains the added product.
    Click Element                                ${CART_MENU}
    Wait Until Element Is Interactive            ${CART_ITEM_COUNT_ANDROID}
    Wait Until Element Is Interactive            ${CART_ITEM_DESCRIPTION_ANDROID}
    Page Should Contain Text                     text=1
    Page Should Contain Text                     text=${PRODUCT_NAME_ANDROID}