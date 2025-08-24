*** Variables ***
#Connection
${APPIUM_PORT}                                4723
${REMOTE_URL}                                 http://localhost:${APPIUM_PORT}/wd/hub 
${PLATFORM}                                   Android

#Connection iOS          
${PLATFORM_VERSION_IOS}                       17.4
${AUTOMATION_NAME_IOS}                        XCUITest
${BUNDLE_ID}                                  com.saucelabs.SwagLabsMobileApp
${UDID_iOS}                                   CCB5450C-AB2F-44D5-8BA5-48D36746C0AD
             
#Connection Android                      
${PLATFORM_VERSION_ANDROID}                   12.0
${AUTOMATION_NAME_ANDROID}                    UiAutomator2
${APP_PACKAGE}                                com.swaglabsmobileapp
${UDID_Android}                               emulator-5554

# Valid Credentials
${username}                                   standard_user
${password}                                   secret_sauce

#Common Elements
${max_attempts}                               5

##Login page
${LOGIN_PAGE}                                 accessibility_id=test-Login
${USERNAME_FIELD}                             accessibility_id=test-Username
${PASSWORD_FIELD}                             accessibility_id=test-Password
${LOGIN_BTN}                                  accessibility_id=test-LOGIN
${LOGIN_ERROR_MSG}                            accessibility_id=test-Error message

##Home page
${HAMBURGUER_MENU}                            accessibility_id=test-Menu
${CART_MENU}                                  accessibility_id=test-Cart    
${LOGIN_MENU}                                 accessibility_id=menu item log in
${LOGOUT_MENU}                                accessibility_id=test-LOGOUT

##Auxiliary
${RESOURCES}                                  ${EXECDIR}${/}resources
&{appium_config_default}        
${isAppOpen?}                                 ${False}   