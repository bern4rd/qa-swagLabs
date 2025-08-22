*** Settings ***
Library           AppiumLibrary    run_on_failure=Capture Page Screenshot    timeout=30s
Resource          ..${/}common${/}common-keywords.resource
Resource          geolocation-variables.resource
