*** Settings ***
Documentation       Test cases for geolocation functionality in the Swag Labs application.
Resource            ${EXECDIR}${/}resources${/}base.resource

Test Setup          Run Keywords   Before Tests  AND  user should be logged in
Test Teardown       After Tests
Test Tags           feature-geolocation

*** Test Cases ***

TC-Geolocation-01: Verify geolocation feature is working
    Given the home page is open
    When user opens the geolocation feature
    Then the geolocation feature should be opened
