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