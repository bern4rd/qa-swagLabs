*** Settings ***
Resource          ..${/}common${/}common-keywords.resource
Resource          shopping-cart-variables.resource

*** Keywords ***

user opens the shopping cart
    [Documentation]    Opens the shopping cart.
    Page Should Contain Element                  ${CART_MENU}
    Click Element                                ${CART_MENU}
    Wait Until Element Is Interactive            ${SHOPPING_CART_CONTENT_${PLATFORM}}

user adds the product to the cart
    [Documentation]    Adds a product to the shopping cart.
    Wait Until Element Is Interactive            ${CART_MENU}
    Page Should Not Contain Element              ${REMOVE_PRODUCT_BTN}
    Click Element                                ${FIRST_CATALOG_PRODUCT_ADD_BTN_${PLATFORM}}
    Wait Until Element Is Interactive            ${REMOVE_PRODUCT_BTN}

the cart should contain the product
    [Documentation]    Verifies that the cart contains the added product.
    user opens the shopping cart
    Page Should Contain Text                     text=1
    Page Should Contain Text                     text=${PRODUCT_NAME_${PLATFORM}}

user should have a product in the cart
    [Documentation]    Ensures that the user has a product in the cart.
    ${isProductCartOpen?}    Run Keyword And Return Status    Element Should Be Visible      ${SHOPPING_CART_CONTENT_${PLATFORM}}

    IF  not ${isProductCartOpen?}
        
        ${isLoginPage?}       Run Keyword And Return Status    Element Should Be Visible     ${LOGIN_PAGE}
        
        IF  not ${isLoginPage?}    
            Open Application      &{appium_config_default}
        END
        
        user perform login
        user adds the product to the cart
        user opens the shopping cart   
    
    ELSE

        ${hasProductInCart?}    Run Keyword And Return Status    Element Should Be Visible    ${CART_ITEM_DESCRIPTION_${PLATFORM}}
        IF  not ${hasProductInCart?}

            user returns to home page from shopping cart
            user adds the product to the cart
            user opens the shopping cart   

        ELSE

            Log    Product already in cart

        END
    END

the cart page is open
    [Documentation]    Ensures that the cart page is open.
    Page Should Contain Element   ${SHOPPING_CART_CONTENT_${PLATFORM}}

user removes the product from the cart
    [Documentation]    Removes the product from the cart.
    Page Should Contain Element                  ${SHOPPING_CART_CONTENT_${PLATFORM}}
    Page Should Contain Element                  ${REMOVE_PRODUCT_BTN}
    Click Element                                ${REMOVE_PRODUCT_BTN}
    Wait Until Page Does Not Contain Element     ${REMOVE_PRODUCT_BTN}

the cart should be empty
    [Documentation]    Ensures that the cart is empty.
    Page Should Contain Element       ${SHOPPING_CART_CONTENT_${PLATFORM}}
    Page Should Not Contain Element   ${CART_ITEM_DESCRIPTION_${PLATFORM}}
    Page Should Not Contain Element   ${REMOVE_PRODUCT_BTN}

user returns to home page from shopping cart
    [Documentation]    Navigates back to the home page from the shopping cart page.
    Wait Until Element Is Interactive            ${CONTINUE_SHOPPING_BTN_${PLATFORM}}
    Click Element                                ${CONTINUE_SHOPPING_BTN_${PLATFORM}}
    Wait Until Page Does Not Contain Element     ${CONTINUE_SHOPPING_BTN_${PLATFORM}}