*** Variables ***

${REMOVE_PRODUCT_BTN}                         accessibility_id=test-REMOVE
${PRODUCT_NAME_ANDROID}                       Sauce Labs Backpack
${FIRST_CATALOG_PRODUCT_ADD_BTN_ANDROID}      android=UiSelector().description("test-ADD TO CART").instance(0)
${FIRST_CATALOG_PRODUCT_NAME_ANDROID}         //android.widget.TextView[@content-desc="test-Item title" and @text="${PRODUCT_NAME_ANDROID}"]
${CART_ITEM_COUNT_ANDROID}                    accessibility_id=test-Amount
${CART_ITEM_DESCRIPTION_ANDROID}              accessibility_id=test-Description