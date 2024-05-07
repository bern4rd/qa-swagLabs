*** Variables ***


#Connection

${REMOTE_URL}                                 ${SAUCELABS_REMOTE_URL} 
 
#Connection iOS          
${PLATFORM_NAME_IOS}                          iOS
${PLATFORM_VERSION_IOS}                       16.4.1
${DEVICE_NAME_IOS}                            iPhone XR
${AUTOMATION_NAME_IOS}                        XCUITest
             
#Connection Android                      
${PLATFORM_NAME_ANDROID}                      Android
${PLATFORM_VERSION_ANDROID}                   8.0
${DEVICE_NAME_ANDROID}                        Android Emulator
${AUTOMATION_NAME_ANDROID}                    UiAutomator2
 
#Mapping                      
${HAMBURGUER_MENU}                            accessibility_id=open menu

${FIRST_CATALOG_PRODUCT_NAME_ANDROID}         //android.widget.TextView[@content-desc="store item text"][1]
${FIRST_CATALOG_PRODUCT_PRICE_ANDROID}        //android.widget.TextView[@content-desc="store item price"][1]
${PRODUCT_NAME_ANDROID}                       //android.view.ViewGroup[@content-desc="container header"]/android.widget.TextView
${FIRST_CATALOG_PRODUCT_RATE_ANDROID}         //android.view.ViewGroup[@content-desc="review star 5"][1]/android.widget.TextView
${REVIEW_MSG_ANDROID}                         //hierarchy/android.widget.FrameLayout/android.widget.LinearLayout/android.widget.FrameLayout/android.widget.FrameLayout/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.widget.TextView
${SORT_BTN_ANDROID}                           //android.view.ViewGroup[@content-desc="sort button"]/android.widget.ImageView
${ITEM_PLUS_BTN_ANDROID}                      //android.view.ViewGroup[@content-desc="counter plus button"]/android.widget.ImageView
${CART_ITEM_COUNT_ANDROID}                    //android.view.ViewGroup[@content-desc="cart badge"]/android.widget.TextView
${ERROR_MSG_ANDROID}                          //android.view.ViewGroup[@content-desc="generic-error-message"]/android.widget.TextView
${LOGOUT_YES_ANDROID}                         android:id/button1
${LOGOUT_OK_ANDROID}                          android:id/button1
${LOGOUT_MSG_ANDROID}                         android:id/alertTitle

${PRODUCT_PRICE}                              accessibility_id=product price
${CLOSE_REVIEW_BTN}                           accessibility_id=Close Modal button
${SORT_BY_NAME_ASC}                           accessibility_id=nameAsc
${ADD_CART_BTN}                               accessibility_id=Add To Cart button
    
${LOGIN_MENU}                                 accessibility_id=menu item log in
${LOGOUT_MENU}                                accessibility_id=menu item log out
${USERNAME_FIELD}                             accessibility_id=Username input field
${PASSWORD_FIELD}                             accessibility_id=Password input field
${LOGIN_BTN}                                  accessibility_id=Login button
