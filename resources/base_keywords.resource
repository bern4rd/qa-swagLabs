*** Settings ***

Library           AppiumLibrary    run_on_failure=Capture Page Screenshot    timeout=30s

Resource          ${RESOURCES}${/}base_variables.resource

*** Variables ***

${RESOURCES}    ${EXECDIR}${/}resources

*** Keywords ***

###################################################################################
### General Keywords ##############################################################
###################################################################################

Before Tests
    #robot --variable PLATFORM:Android your_file.robot
    &{appium_config_default}=  Create Dictionary
    ...    remote_url=${REMOTE_URL}
    ...    appium:noReset=${True}
    ...    appium:fullReset=${false}
    ...    appium:forceAppLaunch=true
    ...    platformName=${PLATFORM}

    Set Global Variable             &{appium_config_default}

    IF  "${PLATFORM}"=="Android"

        &{appium_config_android}    Create Dictionary
        ...    appPackage=${APP_PACKAGE}
        ...    udid=${UDID_Android}
        ...    automationName=${AUTOMATION_NAME_ANDROID}
        ...    appActivity=${APP_PACKAGE}.MainActivity 
        ...    useNewWDA=${False}
        ...    newCommandTimeout=100
        ...    autoGrantPermissions=${True}     

        &{appium_config_default}=    Create Dictionary    &{appium_config_default}    &{appium_config_android} 
        Set Global Variable          &{appium_config_default}
    
    ELSE IF  "${PLATFORM}"=="iOS"
    
        &{appium_config_iOS}        Create Dictionary
        ...    bundleId=${BUNDLE_ID}
        ...    udid=${UDID_iOS}
        ...    useNewWDA=${False}
        ...    automationName=${AUTOMATION_NAME_IOS}
        ...    appium:settings[snapshotMaxDepth]=${100}
        ...    autoGrantPermissions=${True}
        ...    newCommandTimeout=100
        ...    showXcodeLog=true
        
        &{appium_config_default}=    Create Dictionary    &{appium_config_default}    &{appium_config_iOS} 
        Set Global Variable          &{appium_config_default}
    
    ELSE
        Fail    Invalid platform: ${PLATFORM}
    END

    Open Application                &{appium_config_default}

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
    Wait Until Element Is Interactive            ${USERNAME_FIELD}
    Input Text                                   ${USERNAME_FIELD}    ${username}
    Input Text                                   ${PASSWORD_FIELD}    ${password}
    Click Element                                ${LOGIN_BTN}

Perform Login
    [Arguments]    ${username}    ${password}
    Wait Until Page Contains Element             ${LOGIN_BTN}
    Wait Until Page Contains Element             ${USERNAME_FIELD}
    Wait Until Page Contains Element             ${PASSWORD_FIELD}
    Enter Credentials                            ${username}    ${password}

Home Page Should Be Open
    Wait Until Element Is Interactive            ${HAMBURGUER_MENU}
    Wait Until Element Is Interactive            ${CART_MENU}

Perform Logout
    Open Menu
    Wait Until Element Is Interactive            ${logout_menu}
    Select Menu Option                           ${logout_menu}

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