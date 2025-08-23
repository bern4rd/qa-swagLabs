*** Settings ***

# Import variable files
Library           AppiumLibrary    run_on_failure=Capture Page Screenshot    timeout=30s
Resource          common-variables.resource

*** Variables ***

${RESOURCES}                    ${EXECDIR}${/}resources
&{appium_config_default}        
${isAppOpen?}                   ${False}        

*** Keywords ***

###################################################################################
### Setup Keywords ################################################################
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
        ...    newCommandTimeout=50
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
    
Element Should Not Be Visible
    [Documentation]   
    ...    Verifies that the specified element is not visible on the screen.
    ...    - `${locator}`: The locator of the element to check.
    [Arguments]    ${locator}
    ${res}         Run Keyword And Return Status    Element Should Be Visible    ${locator}
    IF  ${res}
        Fail    Element should not be visible: ${locator}        
    END

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

###################################################################################
### Test Steps ####################################################################
###################################################################################

user perform login
    [Documentation]    Performs the login process, using the provided credentials or default values.
    ...    - `${user}`: The username for login.
    ...    - `${pass}`: The password for login.
    [Arguments]    ${user}=${username}    ${pass}=${password}
    Wait Until Page Contains Element             ${LOGIN_BTN}
    Wait Until Page Contains Element             ${USERNAME_FIELD}
    Wait Until Page Contains Element             ${PASSWORD_FIELD}
    Clear Text                                   ${USERNAME_FIELD}
    Clear Text                                   ${PASSWORD_FIELD}
    Enter Credentials                            ${user}    ${pass}

user should be logged in
    [Documentation]    Ensures the user is logged in. It performs the login with standard credentials.

    ${isLogged?}            Run Keyword And Return Status    Element Should Be Visible    ${HAMBURGUER_MENU}
    
    IF  not ${isLogged?}
        Open Application      &{appium_config_default}
        user perform login
    ELSE
        Log    message=User is already logged in
        Capture Page Screenshot
    END
