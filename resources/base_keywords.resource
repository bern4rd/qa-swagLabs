*** Settings ***

Library           AppiumLibrary    run_on_failure=Capture Page Screenshot    timeout=30s

Resource          base_variables.resource
Resource          login_variables.resource
Resource          filter_products_variables.resource

*** Variables ***

${RESOURCES}                    ${EXECDIR}${/}resources
&{appium_config_default}        
${isAppOpen?}                   ${False}        

*** Keywords ***

###################################################################################
### General Keywords ##############################################################
###################################################################################
Before Tests
    [Documentation]
    ...    Prepares and opens the mobile application for testing.
    ...    This keyword sets up the necessary Appium capabilities based on the target platform (Android or iOS),
    ...    which must be specified by the global variable ${PLATFORM}.
    ...    For Android, it uses variables such as ${APP_PACKAGE}, ${UDID_Android}, etc.
    ...    For iOS, it uses variables such as ${BUNDLE_ID}, ${UDID_iOS}, etc.
    ...    It merges the default and platform-specific configurations and then launches the application
    ...    using the 'Open Application' keyword from the AppiumLibrary.
    ...    If an unsupported platform is provided, the test execution will fail.
    &{appium_config_default}=  Create Dictionary
    ...    remote_url=${REMOTE_URL}
    ...    appium:noReset=${True}
    ...    appium:fullReset=${false}
    ...    appium:forceAppLaunch=true
    ...    platformName=${PLATFORM}
    ...    verify_ssl=${False}

    Set Global Variable             &{appium_config_default}

    IF  "${PLATFORM}"=="Android"

        &{appium_config_android}    Create Dictionary
        ...    appPackage=${APP_PACKAGE}
        ...    udid=${UDID_Android}
        ...    automationName=${AUTOMATION_NAME_ANDROID}
        ...    appActivity=${APP_PACKAGE}.MainActivity 
        ...    useNewWDA=${False}
        ...    newCommandTimeout=10
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
    Set Global Variable             ${isAppOpen?}    ${True}

After Tests
    [Documentation]    Closes the application after the test suite execution is complete.
    Close Application

###################################################################################
### Common Keywords ###############################################################
###################################################################################

Wait Until Element Is Interactive
    [Documentation]    
    ...    Waits until the specified element is present and visible on the page.
    ...    - `${locator}`: The locator of the element to wait for.
    [Arguments]                         ${locator}
    Wait Until Page Contains Element    ${locator}    timeout=5s
    Element Should Be Visible           ${locator}    timeout=5s

Open Menu
    [Documentation]    Opens the side menu of the application.
    Wait Until Element Is Interactive            ${hamburguer_menu}
    Page Should Not Contain Element              ${logout_menu}    loglevel=TRACE    
    Click Element                                ${hamburguer_menu}
    Wait Until Element Is Interactive            ${logout_menu}

Select Menu Option
    [Documentation]    
    ...    Selects an option from the side menu.
    ...    - `${menu_option}`: The locator of the menu option to be selected.
    [Arguments]                                  ${menu_option}
    Wait Until Element Is Interactive            ${menu_option}
    Click Element                                ${menu_option}

Enter Credentials
    [Documentation]    Enters the username and password into the respective fields and clicks the login button.
    ...    - `${username}`: The username to be entered.
    ...    - `${password}`: The password to be entered.
    [Arguments]    ${username}    ${password}
    Wait Until Element Is Interactive            ${USERNAME_FIELD}
    Input Text                                   ${USERNAME_FIELD}    ${username}
    Input Text                                   ${PASSWORD_FIELD}    ${password}
    Click Element                                ${LOGIN_BTN}

user perform login
    [Documentation]    Performs the complete user login process.
    ...    - `${username}`: The username for login.
    ...    - `${password}`: The password for login.
    [Arguments]    ${username}    ${password}
    Wait Until Page Contains Element             ${LOGIN_BTN}
    Wait Until Page Contains Element             ${USERNAME_FIELD}
    Wait Until Page Contains Element             ${PASSWORD_FIELD}
    Enter Credentials                            ${username}    ${password}

the home page is open
    [Documentation]    Verifies that the application's home page is open and visible.
    Wait Until Element Is Interactive            ${HAMBURGUER_MENU}
    Wait Until Element Is Interactive            ${CART_MENU}
    Capture Page Screenshot

user perform logout
    [Documentation]    Performs the user logout process.
    Open Menu
    Select Menu Option                           ${logout_menu}
    Capture Page Screenshot

login page should be open
    [Documentation]    Verifies that the login page is visible, checking for the main elements.
    Wait Until Element Is Interactive            ${LOGIN_BTN}
    Wait Until Element Is Interactive            ${USERNAME_FIELD}
    Wait Until Element Is Interactive            ${PASSWORD_FIELD}
    Capture Page Screenshot 

login page is open
    [Documentation]    Verifies that the login page is open by checking the username and password fields.
    Wait Until Element Is Interactive            ${USERNAME_FIELD}
    Wait Until Element Is Interactive            ${PASSWORD_FIELD}
    Capture Page Screenshot

user should be logged in
    [Documentation]    Ensures the user is logged in. It performs the login with standard credentials.

    ${isLogged?}            Run Keyword And Return Status    Element Should Be Visible    ${HAMBURGUER_MENU}
    
    IF  not ${isLogged?}
        Open Application      &{appium_config_default}
        user perform login    ${username}    ${password}
    ELSE
        Log    message=User is already logged in
        Capture Page Screenshot
    END

# Filter Products     
#     [Documentation]    
#     ...    Applies a filter to the list of products.
#     ...    - `${filter_type}`: The type of filter to apply (e.g., 'Price (low to high)').
#     [Arguments]    ${filter_type}
#     Wait Until Element Is Interactive    ${BTN_FILTER}
#     Click Element                        ${BTN_FILTER}
#     Wait Until Element Is Visible        accessibility_id=${filter_type}    timeout=5
#     Click Element                        accessibility_id=${filter_type}
#     Set Global Variable                  ${filter_type}

Filter Products
    [Documentation]
    ...    Applies a filter to the list of products.
    ...    - `${filter_type}`: The type of filter to apply (e.g., 'Price (low to high)').
    [Arguments]    ${filter_type}
    Set Global Variable                  ${filter_type}
    Wait Until Element Is Interactive    ${BTN_FILTER}
    Click Element                        ${BTN_FILTER}
    Capture Page Screenshot
    IF  "${PLATFORM}" == "iOS"
        Wait Until Element Is Visible    accessibility_id=${filter_type}    timeout=5
        Click Element                    accessibility_id=${filter_type}
    ELSE
        Wait Until Page Contains         ${filter_type}
        Click Text                       ${filter_type}
    END

user filter products by price (low to high)
    [Documentation]    Filters products by price, from lowest to highest.
    Filter Products             filter_type=Price (low to high)

user filter products by price (high to low)
    [Documentation]    Filters products by price, from highest to lowest.
    Filter Products             filter_type=Price (high to low)

user filter products by name (A to Z)
    [Documentation]    Filters products by name, in alphabetical order (A-Z).
    Filter Products             filter_type=Name (A to Z)

user filter products by name (Z to A)
    [Documentation]    Filters products by name, in reverse alphabetical order (Z-A).
    Filter Products             filter_type=Name (Z to A)

products should be filtered
    [Documentation]    Verifies that the products have been correctly filtered according to the selected filter type.
    Set Appium Timeout    5
    Page Should Not Contain Element      accessibility_id=${filter_type}

    IF  "${filter_type}" == "Price (low to high)"
        Wait Until Element Is Visible          ${sorted_${PLATFORM}_low_to_high}
        Element Should Not Be Visible          ${sorted_${PLATFORM}_high_to_low}  
    ELSE IF    "${filter_type}" == "Price (high to low)"
        Wait Until Element Is Visible          ${sorted_${PLATFORM}_high_to_low}
        Element Should Not Be Visible          ${sorted_${PLATFORM}_low_to_high}      
    ELSE IF    "${filter_type}" == "Name (A to Z)"
        Wait Until Element Is Visible          ${sorted_${PLATFORM}_A_to_Z}
        Element Should Not Be Visible          ${sorted_${PLATFORM}_Z_to_A}
    ELSE IF    "${filter_type}" == "Name (Z to A)"
        Wait Until Element Is Visible          ${sorted_${PLATFORM}_Z_to_A}
        Element Should Not Be Visible          ${sorted_${PLATFORM}_A_to_Z}
    ELSE
        Fail    The filter ${filter_type} is not supported
    END    
    Set Appium Timeout    10

Element Should Not Be Visible
    [Documentation]   
    ...    Verifies that the specified element is not visible on the screen.
    ...    - `${locator}`: The locator of the element to check.
    [Arguments]    ${locator}
    ${res}         Run Keyword And Return Status    Element Should Be Visible    ${locator}
    IF  ${res}
        Fail    Element should not be visible: ${locator}        
    END
