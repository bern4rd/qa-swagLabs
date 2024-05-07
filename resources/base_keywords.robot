*** Keywords ***

###################################################################################
### General Keywords ##############################################################
###################################################################################

Before Tests
    Open Application
    ...    ${REMOTE_URL}
    ...    platformName=${PLATFORM_NAME}
    ...    platformVersion=${PLATFORM_VERSION}
    ...    deviceName=${DEVICE_NAME}
    ...    app=${APP}
    ...    automationName=${AUTOMATION_NAME}
    ...    name=${JOB_NAME}

After Tests
    Close Application

###################################################################################
### Common Keywords ###############################################################
###################################################################################

Wait Until Element Is Interactive
    [Arguments]                                  ${locator}
    Wait Until Page Contains Element             ${locator}
    Wait Until Element Is Visible                ${locator}

Open Menu
    Wait Until Element Is Interactive            ${hamburguer_menu}
    Click Element                                ${hamburguer_menu}

Select Menu Option
    [Arguments]                                  ${menu_option}
    Wait Until Element Is Interactive            ${menu_option}
    Click Element                                ${menu_option}

Enter Credentials
    [Arguments]    ${username}    ${password}
    Wait Until Element Is Interactive            ${username_field}
    Input Text                                   ${username_field}    ${username}
    Input Text                                   ${password_field}    ${password}
    Click Element                                ${login_btn}

Perform Login
    [Arguments]    ${username}    ${password}
    Open Menu
    Wait Until Element Is Interactive            ${login_menu}
    Select Menu Option                           ${login_menu}
    Enter Credentials                            ${username}    ${password}

Perform Logout
    Open Menu
    Wait Until Element Is Interactive            ${logout_menu}
    Select Menu Option                           ${logout_menu}
    Wait Until Element Is Interactive            ${logout_yes}
    Click Element                                ${logout_yes}
    Wait Until Element Is Interactive            ${logout_msg}
    Element Text Should Be                       ${logout_msg}    You are successfully logged out.
    Click Element                                ${logout_ok}

Get Catalog Product Details
    [Arguments]                                  ${catalog_product_name_locator}    ${catalog_product_price_locator}
    ${product_name_text}=     Get Text           ${catalog_product_name_locator}     
    ${product_price_text}=    Get Text           ${catalog_product_price_locator} 
    [Return]                                     ${product_name_text}               ${product_price_text}

Open Product and Validate Details
    [Arguments]    ${catalog_product_name_locator}    ${product_name_locator}    ${product_price_locator}    ${expected_product_name}    ${expected_product_price}
    Click Element                                ${catalog_product_name_locator}
    Wait Until Element Is Interactive            ${product_name_locator} 
    ${product_name_text}=    Get Text            ${product_name_locator} 
    ${product_price_text}=   Get Text            ${product_price_locator} 
    Should Be Equal As Strings                   ${product_name_text}        ${expected_product_name}
    Should Be Equal As Strings                   ${product_price_text}       ${expected_product_price}

Rate The Product and Confirm
    [Arguments]                                  ${rating_button_locator}
    Click Element                                ${rating_button_locator}
    Wait Until Element Is Interactive            ${close_review_btn}
    Page Should Contain Text                     Thank you for submitting your review!   
    Click Element                                ${close_review_btn}

Sort Products By
    [Arguments]                                  ${sort_type_locator}
    Click Element                                ${sort_btn}
    Wait Until Element Is Interactive            ${sort_type_locator}
    Page Should Contain Text                     Sort by:
    Click Element                                ${sort_type_locator}
    Wait Until Element Is Interactive            ${sort_btn}
    Click Element                                ${sort_btn}

Add Product To Cart
    [Arguments]                                  ${product_name_locator}
    Wait Until Element Is Interactive            ${product_name_locator}
    Click Element                                ${product_name_locator}
    Wait Until Element Is Interactive            ${add_cart_btn}
    Click Element                                ${add_cart_btn}

Verify Cart Count
    [Arguments]    ${cart_item_count_locator}    ${expected_count}
    Wait Until Element Is Interactive            ${cart_item_count_locator}
    Element Text Should Be                       ${cart_item_count_locator}    ${expected_count}