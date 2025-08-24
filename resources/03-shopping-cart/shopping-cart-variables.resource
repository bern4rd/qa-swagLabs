*** Variables ***

${REMOVE_PRODUCT_BTN}                         accessibility_id=test-REMOVE
${PRODUCT_NAME_Android}                       Sauce Labs Backpack
${FIRST_CATALOG_PRODUCT_ADD_BTN_Android}      android=UiSelector().description("test-ADD TO CART").instance(0)
${FIRST_CATALOG_PRODUCT_NAME_Android}         //android.widget.TextView[@content-desc="test-Item title" and @text="${PRODUCT_NAME_Android}"]
${CART_ITEM_COUNT_Android}                    accessibility_id=test-Amount
${CART_ITEM_DESCRIPTION_Android}              accessibility_id=test-Description
${SHOPPING_CART_CONTENT_Android}              accessibility_id=test-Cart Content
${CONTINUE_SHOPPING_BTN_Android}              accessibility_id=test-CONTINUE SHOPPING
${CHECKOUT_BTN_Android}                       accessibility_id=test-CHECKOUT