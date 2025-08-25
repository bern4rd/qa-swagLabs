*** Settings ***
Resource          ..${/}common${/}common-keywords.resource
Resource          ..${/}03-shopping-cart${/}shopping-cart-keywords.resource
Resource          checkout-variables.resource

*** Keywords ***

user is at information checkout page
    [Documentation]   Ensures that the user is at the information checkout page.
    Element Should Be Visible    ${CHECKOUT_INFORMATION_PAGE_${PLATFORM}}

user should be at information checkout page
    [Documentation]   Navigate to the information checkout page.
    
    ${isCheckoutInfoPage?}    Run Keyword And Return Status    Element Should Be Visible      ${CHECKOUT_INFORMATION_PAGE_${PLATFORM}}

    IF  not ${isCheckoutInfoPage?}
        
        ${isProductCartOpen?}    Run Keyword And Return Status    Element Should Be Visible      ${SHOPPING_CART_CONTENT_${PLATFORM}}
        
        IF  not ${isProductCartOpen?}
            
            ${isLoginPage?}       Run Keyword And Return Status    Element Should Be Visible     ${LOGIN_PAGE}
            
            IF  not ${isLoginPage?}    
                Open Application      &{appium_config_default}
            END
            
            user perform login
            user adds the product to the cart
            user opens the shopping cart   
        
        END

        Click Element                               ${CHECKOUT_BTN_${PLATFORM}}
        Wait Until Element Is Interactive           ${CHECKOUT_INFORMATION_PAGE_${PLATFORM}}

    END

user proceeds to checkout with empty ${field}
    [Documentation]   Simulate user attempting checkout with an empty ${field}.
    Wait Until Element Is Interactive           ${CHECKOUT_INFORMATION_PAGE_${PLATFORM}}
    Enter checkout data
    IF    '${field}' == 'first name'
        Clear Text                              ${CHECKOUT_FIRST_NAME_FIELD_${PLATFORM}}
    ELSE IF    '${field}' == 'last name'
        Clear Text                              ${CHECKOUT_LAST_NAME_FIELD_${PLATFORM}}
    ELSE IF    '${field}' == 'zip/postal code'
        Clear Text                              ${CHECKOUT_ZIP_POSTAL_CODE_FIELD_${PLATFORM}}
    END
    Click Element                               ${CHECKOUT_CONTINUE_BTN_${PLATFORM}}

message error ${message} should be displayed
    [Documentation]    Verifies that the checkout error message is displayed.
    Wait Until Element Is Visible    ${CHECKOUT_ERROR_MSG_${PLATFORM}}
    Page Should Contain Text         text=${message}


Enter checkout data
    [Documentation]   Fill in the checkout information form with valid data.
    Wait Until Element Is Interactive           ${CHECKOUT_FIRST_NAME_FIELD_${PLATFORM}}
    Input Text                                  ${CHECKOUT_FIRST_NAME_FIELD_${PLATFORM}}       John
    Input Text                                  ${CHECKOUT_LAST_NAME_FIELD_${PLATFORM}}        Doe
    Input Text                                  ${CHECKOUT_ZIP_POSTAL_CODE_FIELD_${PLATFORM}}  12345

user proceeds to checkout with valid information
    [Documentation]   Simulate user proceeding to checkout with valid information.
    Wait Until Element Is Interactive           ${CHECKOUT_INFORMATION_PAGE_${PLATFORM}}
    Enter checkout data
    Click Element                               ${CHECKOUT_CONTINUE_BTN_${PLATFORM}}
    Wait Until Element Is Visible               ${CHECKOUT_OVERVIEW_PAGE_${PLATFORM}}
    Page Should Contain Text                    ${CHECKOUT_OVERVIEW_PAYMENT_INFO_${PLATFORM}}
    Page Should Contain Text                    ${CHECKOUT_OVERVIEW_SAUCE_CARD_${PLATFORM}}
    Page Should Contain Text                    ${CHECKOUT_OVERVIEW_SHIPPING_INFO_${PLATFORM}}
    Page Should Contain Text                    ${CHECKOUT_OVERVIEW_FREE_DELIVERY_${PLATFORM}}
    Page Should Contain Text                    ${CHECKOUT_OVERVIEW_ITEM_TOTAL_${PLATFORM}}
    Page Should Contain Text                    ${CHECKOUT_OVERVIEW_TAX_${PLATFORM}}
    Page Should Contain Text                    ${CHECKOUT_OVERVIEW_TOTAL_${PLATFORM}}
    Locate Element                              ${CHECKOUT_OVERVIEW_FINISH_BTN_${PLATFORM}}    
    Click Element                               ${CHECKOUT_OVERVIEW_FINISH_BTN_${PLATFORM}}

user should be redirected to the order confirmation page
    [Documentation]   Verifies that the user is redirected to the order confirmation page.
    Wait Until Element Is Visible               ${CHECKOUT_COMPLETE_PAGE_${PLATFORM}}
    Page Should Contain Text                    ${CHECKOUT_COMPLETE_TITLE_${PLATFORM}}
    Page Should Contain Text                    ${CHECKOUT_COMPLETE_MESSAGE_${PLATFORM}}
    Page Should Contain Element                 ${CHECKOUT_COMPLETE_BACK_HOME_BTN_${PLATFORM}}