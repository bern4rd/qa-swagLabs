*** Settings ***
Documentation       Test cases for geolocation functionality in the Swag Labs application.
Resource            ${EXECDIR}${/}resources${/}base.resource

Suite Setup         Before Tests
Suite Teardown      After Tests
Test Tags           feature-geolocation

*** Test Cases ***

TC-Geolocation-01: Verify geolocation feature is enabled
    [Setup]   user should be logged in
    Given the user is on the home page
    When user enables the geolocation feature
    Then the geolocation feature should be enabled

TC-Geolocation-02: Verify geolocation accuracy
    [Setup]   user should be logged in
    Given the user is on the home page
    When user checks the geolocation accuracy
    Then the geolocation accuracy should be within acceptable limits

TC-Geolocation-03: Verify geolocation error handling
    [Setup]   user should be logged in
    Given the user is on the home page
    When user disables the geolocation feature
    Then an error message should be displayed
