import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class PaymentController extends GetxController {
  static PaymentController to = Get.find();
  final String _entitlementName = "pro";

  @override
  void onInit() {
    super.onInit();
    Purchases.addCustomerInfoUpdateListener((purchaserInfo) {
      print(purchaserInfo);
    });
  }

  Future openPayWall() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      EntitlementInfo? entitlement =
          customerInfo.entitlements.all[_entitlementName];
      if (entitlement != null && entitlement.isActive) {
      } else {
        final paywallResult = await RevenueCatUI.presentPaywallIfNeeded(
          _entitlementName,
          displayCloseButton: true,
        );
        print(paywallResult);
      }
      // print(customerInfo);
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
        msg: "Something went wrong, please try again later!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
