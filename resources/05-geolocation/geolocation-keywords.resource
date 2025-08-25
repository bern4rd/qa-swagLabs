*** Settings ***
Resource          ..${/}common${/}common-keywords.resource
Resource          geolocation-variables.resource

*** Keywords ***

user opens the geolocation feature
    [Documentation]    Opens the geolocation feature in the application
    Element Should Be Visible            ${HAMBURGUER_MENU}
    Click Element                        ${HAMBURGUER_MENU}
    Wait Until Element Is Interactive    ${GEOLOCATION_FEATURE_BTN_${PLATFORM}}
    Click Element                        ${GEOLOCATION_FEATURE_BTN_${PLATFORM}}

the geolocation feature should be opened
    [Documentation]    Verifies that the geolocation feature page is displayed
    Wait Until Element Is Interactive    ${GEOLOCATION_FEATURE_PAGE_${PLATFORM}}
    Page Should Contain Text             ${GEOLOCATION_TEXT_1}
    Page Should Contain Text             ${GEOLOCATION_TEXT_2}
    Page Should Contain Element          ${GEOLOCATION_LATITUDE}
    Element Text Should Be a Number      ${GEOLOCATION_LATITUDE}
    Page Should Contain Element          ${GEOLOCATION_LONGITUDE}
    Element Text Should Be a Number      ${GEOLOCATION_LONGITUDE}