*** Settings ***

Library           AppiumLibrary    run_on_failure=Capture Page Screenshot    timeout=30s

Resource          ${RESOURCES}${/}base_variables.resource

*** Variables ***

${RESOURCES}    ${EXECDIR}${/}resources

*** Keywords ***

###################################################################################
### General Keywords ##############################################################
###################################################################################

    #robot --variable PLATFORM:Android your_file.robot

Before Tests
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


###################################################################################
### Common Keywords ###############################################################
###################################################################################

Wait Until Element Is Interactive
    [Arguments]                         ${locator}
    Wait Until Page Contains Element    ${locator}    timeout=5s
    Wait Until Element Is Visible       ${locator}    timeout=5s

Open Menu
    Wait Until Element Is Interactive            ${hamburguer_menu}
    Page Should Not Contain Element              ${logout_menu}    loglevel=TRACE    
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

user perform login
    [Arguments]    ${username}    ${password}
    Wait Until Page Contains Element             ${LOGIN_BTN}
    Wait Until Page Contains Element             ${USERNAME_FIELD}
    Wait Until Page Contains Element             ${PASSWORD_FIELD}
    Enter Credentials                            ${username}    ${password}

the home page is open
    Wait Until Element Is Interactive            ${HAMBURGUER_MENU}
    Wait Until Element Is Interactive            ${CART_MENU}
    Capture Page Screenshot

user perform logout
    Open Menu
    Select Menu Option                           ${logout_menu}
    Capture Page Screenshot

login page should be open
    Wait Until Element Is Interactive            ${LOGIN_BTN}
    Wait Until Element Is Interactive            ${USERNAME_FIELD}
    Wait Until Element Is Interactive            ${PASSWORD_FIELD}
    Capture Page Screenshot

login page is open
    Wait Until Element Is Interactive            ${USERNAME_FIELD}
    Wait Until Element Is Interactive            ${PASSWORD_FIELD}
    Capture Page Screenshot

user should be logged in
    Before Tests
    user perform login    ${username}    ${password}
    Capture Page Screenshot

Filter Products     
    [Arguments]    ${filter_type}
    Wait Until Element Is Interactive    accessibility_id=${BTN_FILTER}
    Click Element                        accessibility_id=${BTN_FILTER}
    Wait Until Element Is Visible        accessibility_id=${filter_type}    timeout=5
    Click Element                        accessibility_id=${filter_type}

# Filter Products
#     [Arguments]    ${filter_type}
#     Set Global Variable                  ${filter_type}
#     Wait Until Element Is Interactive    accessibility_id=${BTN_FILTER}
#     Click Element                        accessibility_id=${BTN_FILTER}
#     Capture Page Screenshot
#     IF  "${PLATFORM}" == "iOS"
#         Wait Until Element Is Visible    accessibility_id=${filter_type}    timeout=5
#         Click Element                    accessibility_id=${filter_type}
#     ELSE
#         Wait Until Page Contains         ${filter_type}
#         Click Text                       ${filter_type}
#     END

user filter products by price (low to high)
    Filter Products             filter_type=Price (low to high)

user filter products by price (high to low)
    Filter Products             filter_type=Price (high to low)

user filter products by name (A to Z)
    Filter Products             filter_type=Name (A to Z)

user filter products by name (Z to A)
    Filter Products             filter_type=Name (Z to A)

products should be filtered  
    Page Should Not Contain Element      accessibility_id=${filter_type}

    IF  "${filter_type}" == "Price (low to high)"
        Wait Until Element Is Visible          ${sorted_${PLATFORM}_low_to_high}    timeout=5
        Page Should Not Contain Element        ${sorted_${PLATFORM}_high_to_low}      
    ELSE IF    "${filter_type}" == "Price (high to low)"
        Wait Until Element Is Visible          ${sorted_${PLATFORM}_high_to_low}    timeout=5
        Page Should Not Contain Element        ${sorted_${PLATFORM}_low_to_high}      
    ELSE IF    "${filter_type}" == "Name (A to Z)"
        Wait Until Element Is Visible          ${sorted_${PLATFORM}_A_to_Z}  timeout=5
        Page Should Not Contain Element        ${sorted_${PLATFORM}_Z_to_A}
    ELSE IF    "${filter_type}" == "Name (Z to A)"
        Wait Until Element Is Visible          ${sorted_${PLATFORM}_Z_to_A}  timeout=5
        Page Should Not Contain Element        ${sorted_${PLATFORM}_A_to_Z}
    ELSE
        Fail    The filter ${filter_type} is not supported
    END    

Element Should Not Be Visible
    [Arguments]    ${locator}
    ${res}         Run Keyword And Return Status    Element Should Be Visible    ${locator}
    Capture Page Screenshot
    Should Not Be True    ${res}