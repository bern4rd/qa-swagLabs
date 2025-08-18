*** Variables ***
${HAMBURGUER_MENU}                            accessibility_id=test-Menu
${CART_MENU}                                  accessibility_id=test-Cart

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
    
${LOGIN_MENU}                                 accessibility_id=menu item log in
${LOGOUT_MENU}                                accessibility_id=test-LOGOUT
${USERNAME_FIELD}                             accessibility_id=test-Username
${PASSWORD_FIELD}                             accessibility_id=test-Password
${LOGIN_BTN}                                  accessibility_id=test-LOGIN

# Valid Credentials
${username}                                   standard_user
${password}                                   secret_sauce