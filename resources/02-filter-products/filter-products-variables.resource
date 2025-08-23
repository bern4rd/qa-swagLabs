*** Variables ***
${PRODUCT_PRICE}                              accessibility_id=product price
${CLOSE_REVIEW_BTN}                           accessibility_id=Close Modal button
${SORT_BY_NAME_ASC}                           accessibility_id=nameAsc
${ADD_CART_BTN}                               accessibility_id=Add To Cart button

${BTN_FILTER}                                 accessibility_id=test-Modal Selector Button
${filter_type}                                ${EMPTY}

${sorted_low_to_high_Android}                 xpath=//android.widget.TextView[@content-desc="test-Item title" and @text="Sauce Labs Onesie"]
${sorted_high_to_low_Android}                 xpath=//android.widget.TextView[@content-desc="test-Item title" and @text="Sauce Labs Fleece Jacket"]
${sorted_Z_to_A_Android}                      xpath=//android.widget.TextView[@content-desc="test-Item title" and @text="Test.allTheThings() T-Shirt (Red)"]
${sorted_A_to_Z_Android}                      xpath=//android.widget.TextView[@content-desc="test-Item title" and @text="Sauce Labs Backpack"]

${sorted_low_to_high_iOS}                     accessibility_id=assets/src/img/red-onesie.jpg
${sorted_high_to_low_iOS}                     accessibility_id=assets/src/img/sauce-pullover.jpg
${sorted_A_to_Z_iOS}                          accessibility_id=assets/src/img/sauce-backpack.jpg
${sorted_Z_to_A_iOS}                          accessibility_id=assets/src/img/red-tatt.jpg    