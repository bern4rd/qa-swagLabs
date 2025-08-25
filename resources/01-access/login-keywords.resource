*** Settings ***
Resource          ..${/}common${/}common-keywords.resource

*** Keywords ***

the home page is open
    [Documentation]    Verifies that the application's home page is open and visible.
    Wait Until Element Is Interactive            ${HAMBURGUER_MENU}
    Wait Until Element Is Interactive            ${CART_MENU}

user perform logout
    [Documentation]    Performs the user logout process.
    Open Menu
    Select Menu Option                           ${LOGOUT_MENU} 

login page should be open
    [Documentation]    Verifies that the login page is visible, checking for the main elements.
    Wait Until Element Is Interactive            ${LOGIN_BTN}
    Wait Until Element Is Interactive            ${USERNAME_FIELD}
    Wait Until Element Is Interactive            ${PASSWORD_FIELD}

login page is open
    [Documentation]    Verifies that the login page is open by checking the username and password fields.
    Wait Until Element Is Interactive            ${USERNAME_FIELD}
    Wait Until Element Is Interactive            ${PASSWORD_FIELD}

login error should be displayed
    [Documentation]    Verifies that the login error message is displayed.
    [Arguments]        ${message}
    Wait Until Element Is Visible    ${LOGIN_ERROR_MSG}
    Page Should Contain Text         text=${message}