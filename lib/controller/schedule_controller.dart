import 'package:chatting_application/controller/app_write_controller.dart';
import 'package:chatting_application/controller/my_encryption.dart';
import 'package:chatting_application/model/schedule_mesage_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workmanager/workmanager.dart';

class SMController extends GetxController {
  var _messages = [];

  get message {
    return _messages.reversed.toList();
  }

  addMessage(message, type) {
    _messages.add(ScheduleMessageModel(message, type));
    update();
  }

  makeSchedule(channelId, DateTime date, TimeOfDay time) async {
    final user = AWController.to.user.value;
    var data = {
      'currentUserId': user?.$id,
      'cid': channelId,
      'messages': _messages
          .map((item) => item.type == "image"
              ? "${item.message}"
              : encryptData("${item.message}"))
          .toList(),
      'type': _messages.map((item) => "${item.type}").toList()
    };
    final scheduleTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final now = DateTime.now();
    final difference = scheduleTime.difference(now).inSeconds;
    print(difference);
    Workmanager().cancelByTag('$channelId');
    Workmanager().registerOneOffTask("$channelId", "simpleTask",
        inputData: data,
        initialDelay: Duration(seconds: difference),
        constraints: Constraints(networkType: NetworkType.connected));
    _messages = [];
    Get.back();
  }
}
