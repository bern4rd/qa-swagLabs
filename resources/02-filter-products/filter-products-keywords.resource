*** Settings ***
Library           AppiumLibrary    run_on_failure=Capture Page Screenshot    timeout=30s
Resource          ..${/}common${/}common-keywords.resource
Resource          filter-products-variables.resource

*** Keywords ***
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
        Wait Until Element Is Visible          ${sorted_low_to_high_${PLATFORM}}
        Element Should Not Be Visible          ${sorted_high_to_low_${PLATFORM}}  
    ELSE IF    "${filter_type}" == "Price (high to low)"
        Wait Until Element Is Visible          ${sorted_high_to_low_${PLATFORM}}
        Element Should Not Be Visible          ${sorted_low_to_high_${PLATFORM}}      
    ELSE IF    "${filter_type}" == "Name (A to Z)"
        Wait Until Element Is Visible          ${sorted_A_to_Z_${PLATFORM}}
        Element Should Not Be Visible          ${sorted_Z_to_A_${PLATFORM}}
    ELSE IF    "${filter_type}" == "Name (Z to A)"
        Wait Until Element Is Visible          ${sorted_Z_to_A_${PLATFORM}}
        Element Should Not Be Visible          ${sorted_A_to_Z_${PLATFORM}}
    ELSE
        Fail    The filter ${filter_type} is not supported
    END    
    Set Appium Timeout    10