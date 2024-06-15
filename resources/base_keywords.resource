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
    Wait Until Page Contains Element             ${locator}    timeout=5s
    Wait Until Element Is Visible                ${locator}    timeout=5s

Open Menu
    Wait Until Element Is Interactive            ${hamburguer_menu}

    #Antes de abrir o menu, o botão de logout não deve estar visível
    Page Should Not Contain Element              ${logout_menu}    loglevel=TRACE    

    #Só após abrir o menu, o botão de logout deve estar visível
    Click Element                                ${hamburguer_menu}
    Wait Until Element Is Interactive            ${logout_menu}

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

Filter Products     
    [Arguments]    ${filter_type}
    Wait Until Element Is Interactive    accessibility_id=test-Modal Selector Button
    Click Element                        accessibility_id=test-Modal Selector Button
    Sleep                                2s    reason=Wait for the filter options to be displayed
    Capture Page Screenshot
    Wait Until Element Is Visible        accessibility_id=${filter_type}    timeout=5
    Click Element                        accessibility_id=${filter_type}

Filter Products Without Bug
    [Arguments]    ${filter_type}
    Set Global Variable                  ${filter_type}
    Wait Until Element Is Interactive    accessibility_id=test-Modal Selector Button
    Click Element                        accessibility_id=test-Modal Selector Button
    Capture Page Screenshot
    IF  "${PLATFORM}" == "iOS"
        Wait Until Element Is Visible    accessibility_id=${filter_type}    timeout=5
        Click Element                    accessibility_id=${filter_type}
    ELSE
        Wait Until Page Contains         ${filter_type}
        Click Text                       ${filter_type}
    END

Products Should Be Filtered  
    Page Should Not Contain Element      accessibility_id=${filter_type}
    IF    "${PLATFORM}"=="Android"
        IF  "${filter_type}" == "Price (low to high)"
            Wait Until Element Is Visible        xpath=//android.widget.TextView[@content-desc="test-Item title" and @text="Sauce Labs Onesie"]          timeout=5
            Page Should Not Contain Element      xpath=//android.widget.TextView[@content-desc="test-Item title" and @text="Sauce Labs Fleece Jacket"]
        ELSE IF    "${filter_type}" == "Price (high to low)"
            Wait Until Element Is Visible        xpath=//android.widget.TextView[@content-desc="test-Item title" and @text="Sauce Labs Fleece Jacket"]    timeout=5
            Page Should Not Contain Element      xpath=//android.widget.TextView[@content-desc="test-Item title" and @text="Sauce Labs Onesie"] 
        ELSE IF    "${filter_type}" == "Name (A to Z)"
            Wait Until Element Is Visible        xpath=//android.widget.TextView[@content-desc="test-Item title" and @text="Sauce Labs Backpack"]    timeout=5
            Page Should Not Contain Element      xpath=//android.widget.TextView[@content-desc="test-Item title" and @text="Test.allTheThings() T-Shirt (Red)"]
        ELSE IF    "${filter_type}" == "Name (Z to A)"
            Wait Until Element Is Visible        xpath=//android.widget.TextView[@content-desc="test-Item title" and @text="Test.allTheThings() T-Shirt (Red)"]    timeout=5
            Page Should Not Contain Element      xpath=//android.widget.TextView[@content-desc="test-Item title" and @text="Sauce Labs Backpack"]            
        ELSE
            Fail    The filter ${filter_type} is not supported
        END    
    ELSE  #${PLATFORM}=="iOS"
        IF  "${filter_type}" == "Price (low to high)"
            Wait Until Element Is Visible        accessibility_id=assets/src/img/red-onesie.jpg        timeout=5
            Element Should Not Be Visible        accessibility_id=assets/src/img/sauce-pullover.jpg 
        ELSE IF    "${filter_type}" == "Price (high to low)"
            Wait Until Element Is Visible        accessibility_id=assets/src/img/sauce-pullover.jpg    timeout=5
            Element Should Not Be Visible        accessibility_id=assets/src/img/red-onesie.jpg
        ELSE IF    "${filter_type}" == "Name (A to Z)"
            Wait Until Element Is Visible        accessibility_id=assets/src/img/sauce-backpack.jpg    timeout=5
            Element Should Not Be Visible        accessibility_id=assets/src/img/red-tatt.jpg    
        ELSE IF    "${filter_type}" == "Name (Z to A)"
            Wait Until Element Is Visible        accessibility_id=assets/src/img/red-tatt.jpg    timeout=5 
            Element Should Not Be Visible        accessibility_id=assets/src/img/sauce-backpack.jpg           
        ELSE
            Fail    The filter ${filter_type} is not supported
        END    
    END

Element Should Not Be Visible
    [Arguments]    ${locator}
    ${res}         Run Keyword And Return Status    Element Should Be Visible    ${locator}
    Capture Page Screenshot
    Should Not Be True    ${res}