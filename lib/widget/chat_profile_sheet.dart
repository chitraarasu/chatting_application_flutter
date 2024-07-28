import 'package:animations/animations.dart';
import 'package:appwrite/models.dart' as aw;
import 'package:chatting_application/controller/app_write_controller.dart';
import 'package:chatting_application/controller/controller.dart';
import 'package:chatting_application/screens/chats/map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../screens/chats/edit_channel.dart';
import '../screens/chats/user_list_screen.dart';
import '../screens/contacts.dart';

class ChatProfileSheet extends StatelessWidget {
  final name;
  final image;
  final channelId;
  final isForSingleChatList;
  final reciverData;
  final isChannelAdmin;

  ChatProfileSheet(this.name, this.image, this.channelId,
      this.isForSingleChatList, this.reciverData, this.isChannelAdmin);

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find();

    _displayDialog(BuildContext context) async {
      return showModal(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Do you want to leave this group?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('No'),
                  onPressed: () {
                    Get.back();
                  },
                ),
                TextButton(
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () async {
                    aw.User? user = AWController.to.user.value;

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user?.$id)
                        .get()
                        .then((data) async {
                      List userChannels = data["userChannels"] ?? [];
                      userChannels.remove(channelId);
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(user?.$id)
                          .update({"userChannels": userChannels});
                    });
                    FirebaseFirestore.instance
                        .collection('messages')
                        .doc(channelId)
                        .collection("channelMembers")
                        .doc(user?.$id)
                        .delete();
                    Get.back();
                    Get.back();
                    Get.back();
                  },
                )
              ],
            );
          });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 75 / 2 + 40,
                        ),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        if (isForSingleChatList)
                          Text(reciverData["phoneNumber"]),
                        if (!isForSingleChatList)
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  CustomCircleButton(
                                    Icons.list_alt_rounded,
                                    Colors.blue,
                                    const Color(0xFFebf4ff),
                                    () {
                                      Get.back();

                                      Get.to(
                                        () => ChannelUserList(
                                          channelId: channelId,
                                        ),
                                        transition: Transition.noTransition,
                                      );
                                    },
                                  ),
                                  CustomCircleButton(
                                    Icons.location_on,
                                    Colors.pinkAccent,
                                    const Color(0xFFf9edff),
                                    () {
                                      Get.back();
                                      Get.to(
                                        () => Map(channelId),
                                        transition: Transition.noTransition,
                                      );
                                    },
                                  ),
                                  CustomCircleButton(
                                    Icons.add_box_rounded,
                                    Colors.purple,
                                    const Color(0xFFffebf8),
                                    () {
                                      Get.back();
                                      Get.to(
                                          () => Contacts(
                                                "group",
                                                channelData: channelId,
                                              ),
                                          transition: Transition.noTransition);
                                    },
                                  ),
                                  if (isChannelAdmin)
                                    CustomCircleButton(
                                      Icons.edit,
                                      Colors.green,
                                      const Color(0xFFE3FFE4),
                                      () {
                                        Get.back();
                                        Get.to(
                                            () => EditChannel(
                                                name, image, channelId),
                                            transition:
                                                Transition.noTransition);
                                      },
                                    ),
                                  CustomCircleButton(
                                    Icons.exit_to_app,
                                    Colors.orange,
                                    const Color(0xFFfff1eb),
                                    () {
                                      _displayDialog(context);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              const Text(
                                "Invite id",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(
                                          ClipboardData(text: channelId));
                                      Fluttertoast.showToast(
                                        msg: "Text copied!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.black,
                                        textColor: Colors.white,
                                        fontSize: 16.0,
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(width: 10),
                                            Text(channelId),
                                            // SelectableText(
                                            //   channelId,
                                            //   cursorColor: const Color(0xFF006aff),
                                            //   showCursor: true,
                                            //   toolbarOptions: const ToolbarOptions(
                                            //     copy: true,
                                            //     selectAll: true,
                                            //     cut: false,
                                            //     paste: false,
                                            //   ),
                                            // ),
                                            SizedBox(width: 10),
                                            const Icon(
                                              Icons.copy,
                                              size: 20,
                                            ),
                                            SizedBox(width: 10),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(width: 4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: QrImageView(
                                  data: channelId,
                                  version: QrVersions.auto,
                                  size: 150.0,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  homeController.getAdsWidget(),
                ],
              ),
            ),
          ),
          Positioned(
            top: -75 / 2 - 40,
            child: CircleAvatar(
              backgroundColor: const Color(0xFFd6e2ea),
              radius: 75,
              backgroundImage: image == null ? null : NetworkImage(image),
              child: image == null
                  ? const Icon(
                      Icons.person_rounded,
                      color: Colors.grey,
                      size: 100,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomCircleButton extends StatelessWidget {
  final icon;
  final color;
  final bgColor;
  final onTap;

  CustomCircleButton(this.icon, this.color, this.bgColor, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: CircleAvatar(
        child: Icon(
          icon,
          color: color,
        ),
        backgroundColor: bgColor,
      ),
    );
  }
}
