import 'package:chatting_application/controller/app_write_controller.dart';
import 'package:chatting_application/controller/call_controller.dart';
import 'package:chatting_application/controller/payment_controller.dart';
import 'package:chatting_application/controller/schedule_controller.dart';
import 'package:get/get.dart';

import 'controller.dart';

class Binder extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
    Get.put(SMController());
    Get.put(CallController());
    Get.put(PaymentController());
    Get.put(AWController());
  }
}
