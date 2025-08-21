*** Variables ***
${PRODUCT_PRICE}                              accessibility_id=product price
${CLOSE_REVIEW_BTN}                           accessibility_id=Close Modal button
${SORT_BY_NAME_ASC}                           accessibility_id=nameAsc
${ADD_CART_BTN}                               accessibility_id=Add To Cart button

${BTN_FILTER}                                 accessibility_id=test-Modal Selector Button
${filter_type}                                ${EMPTY}

${sorted_Android_low_to_high}                 xpath=//android.widget.TextView[@content-desc="test-Item title" and @text="Sauce Labs Onesie"]
${sorted_Android_high_to_low}                 xpath=//android.widget.TextView[@content-desc="test-Item title" and @text="Sauce Labs Fleece Jacket"]
${sorted_Android_Z_to_A}                      xpath=//android.widget.TextView[@content-desc="test-Item title" and @text="Test.allTheThings() T-Shirt (Red)"]
${sorted_Android_A_to_Z}                      xpath=//android.widget.TextView[@content-desc="test-Item title" and @text="Sauce Labs Backpack"]

${sorted_iOS_low_to_high}                     accessibility_id=assets/src/img/red-onesie.jpg
${sorted_iOS_high_to_low}                     accessibility_id=assets/src/img/sauce-pullover.jpg
${sorted_iOS_A_to_Z}                          accessibility_id=assets/src/img/sauce-backpack.jpg
${sorted_iOS_Z_to_A}                          accessibility_id=assets/src/img/red-tatt.jpg    