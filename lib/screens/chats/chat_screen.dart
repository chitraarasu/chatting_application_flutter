import 'package:chatting_application/controller/app_write_controller.dart';
import 'package:chatting_application/controller/controller.dart';
import 'package:chatting_application/model/caller_model.dart';
import 'package:chatting_application/screens/chats/schedule_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:workmanager/workmanager.dart';

import '../../controller/my_encryption.dart';
import '../../widget/chat_profile_sheet.dart';
import '../../widget/image_view.dart';
import '../../widget/message_bubble.dart';

enum CallType {
  video,
  audio,
}

class ChatScreen extends StatefulWidget {
  final name;
  final image;
  final channelId;
  final isForSingleChatList;
  final reciverData;
  final isChannelAdmin;

  ChatScreen(this.name, this.image, this.channelId,
      {this.isForSingleChatList = false,
      this.reciverData,
      this.isChannelAdmin = false});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FocusNode focusNode = FocusNode();
  var isEmojiVisible = false.obs;
  HomeController homeController = Get.find();

  var _enteredMessage = ''.obs;
  TextEditingController _controller = TextEditingController();

  RxList selectedMessages = RxList();

  var user = AWController.to.user.value;

  var userData;
  List? channelMemberUserTokens;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedMessages.value = [];

    loadCurrentUserData();
    loadChannelMemberUserData();
  }

  loadCurrentUserData() async {
    userData ??= await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.$id)
        .get();
  }

  loadChannelMemberUserData() async {
    if (channelMemberUserTokens == null) {
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(widget.channelId)
          .collection("channelMembers")
          .get()
          .then((value) {
        var channelMembers = [];
        for (var item in value.docs) {
          channelMembers.add(item.data()["userId"]);
        }
        FirebaseFirestore.instance.collection('users').get().then((usersData) {
          channelMemberUserTokens = [];
          for (var item in usersData.docs) {
            if (channelMembers.contains(item.data()["uid"])) {
              channelMemberUserTokens?.add(item.data()["token"]);
            }
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void _sendMessage() async {
      if (_controller.text.trim().isNotEmpty) {
        _controller.clear();
        loadCurrentUserData();

        if (widget.isForSingleChatList) {
          var randomDoc = FirebaseFirestore.instance
              .collection("private_chats")
              .doc(user?.$id)
              .collection('channelChat')
              .doc();

          FirebaseFirestore.instance
              .collection('private_chats')
              .doc(widget.channelId)
              .collection("channelChat")
              .doc(randomDoc.id)
              .set({
            'messageId': randomDoc.id,
            'message': encryptData(_enteredMessage.value),
            'messageType': "text",
            'createdTime': Timestamp.now(),
            'senderId': user?.$id,
            'senderName': userData['username'],
            'taggedMessageId': '',
          });

          FirebaseFirestore.instance
              .collection('private_chats')
              .doc(widget.channelId)
              .set({
            'chat_id': widget.channelId,
            'messageType': "text",
            'createdTime': Timestamp.now(),
            'chat_members': [user?.$id, widget.reciverData["uid"]],
            'senderName': userData['username'],
            'recentMessage': encryptData(_enteredMessage.value),
          });

          homeController.sendNotification(
            data: {},
            tokens: [widget.reciverData["token"]],
            name: userData['username'],
            message: _enteredMessage.value,
          );
        } else {
          var randomDoc = FirebaseFirestore.instance
              .collection("messages")
              .doc(user?.$id)
              .collection('channelChat')
              .doc();

          FirebaseFirestore.instance
              .collection('messages')
              .doc(widget.channelId)
              .collection("channelChat")
              .doc(randomDoc.id)
              .set({
            'messageId': randomDoc.id,
            'message': encryptData(_enteredMessage.value),
            'messageType': "text",
            'createdTime': Timestamp.now(),
            'senderId': user?.$id,
            'senderName': userData['username'],
            'taggedMessageId': '',
          });

          FirebaseFirestore.instance
              .collection('messages')
              .doc(widget.channelId)
              .update({
            'recentMessage': encryptData(_enteredMessage.value),
            'time': Timestamp.now(),
          });

          // FirebaseFirestore.instance
          //     .collection('users')
          //     .doc(user.uid)
          //     .collection("userChannels")
          //     .doc(widget.channelId)
          //     .update({
          //   'recentMessage': encryptData(_enteredMessage.value),
          //   'time': Timestamp.now(),
          // });

          // Notification
          await loadChannelMemberUserData();
          homeController.sendNotification(
            data: {},
            tokens: channelMemberUserTokens,
            name: userData['username'],
            message: _enteredMessage.value,
          );
        }

        _enteredMessage.value = '';
      }
    }

    sendCallRequest(callType) async {
      if (widget.isForSingleChatList) {
        homeController.sendNotification(
          data: CallModel(
            type: "call",
            nameCaller:
                "${callType == CallType.video ? "🎥" : "📞"} ${userData['username']}",
            avatar: userData['profileUrl'],
            number: userData['phoneNumber'],
          ).toJson(),
          tokens: [widget.reciverData["token"]],
          name: callType == CallType.video ? "Video Call" : "Audio Call",
          message:
              "${callType == CallType.video ? "Video Call" : "Audio Call"} from ${userData['username']}",
        );
      } else {
        await loadChannelMemberUserData();
        await loadCurrentUserData();
        channelMemberUserTokens?.remove(userData['token']);

        homeController.sendNotification(
          data: CallModel(
            type: "call",
            nameCaller:
                "${callType == CallType.video ? "🎥" : "📞"} ${widget.name}",
            avatar: widget.image,
            number: "${userData['username']} (${userData['phoneNumber']})",
          ).toJson(),
          tokens: channelMemberUserTokens,
          name: widget.name,
          message:
              "${callType == CallType.video ? "Video Call" : "Audio Call"} started on ${widget.name}",
        );
      }
    }

    Future<void> handleClick(String value) async {
      switch (value) {
        case 'Schedule message':
          Get.to(() => ScheduleMessage(widget.channelId),
              transition: Transition.fadeIn);
          break;
        case 'Clear schedule':
          Workmanager().cancelByUniqueName(widget.channelId);
          Fluttertoast.showToast(
            msg: "Schedule cleared",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          break;
      }
    }

    String groupMessageDateAndTime(DateTime time) {
      final todayDate = DateTime.now();

      final today = DateTime(todayDate.year, todayDate.month, todayDate.day);
      final yesterday =
          DateTime(todayDate.year, todayDate.month, todayDate.day - 1);
      String difference = '';
      final aDate = DateTime(time.year, time.month, time.day);

      if (aDate == today) {
        difference = "Today";
      } else if (aDate == yesterday) {
        difference = "Yesterday";
      } else {
        difference = DateFormat.yMMMd().format(time).toString();
      }

      return difference;
    }

    return WillPopScope(
      onWillPop: () {
        if (isEmojiVisible.value) {
          isEmojiVisible.value = false;
        } else {
          Navigator.pop(context);
        }
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 70,
          backgroundColor: Colors.white,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.black,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          title: GestureDetector(
            onTap: () {
              focusNode.unfocus();

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return FractionallySizedBox(
                    heightFactor: widget.isForSingleChatList ? 0.5 : 0.70,
                    child: ChatProfileSheet(
                      widget.name,
                      widget.image,
                      widget.channelId,
                      widget.isForSingleChatList,
                      widget.reciverData,
                      widget.isChannelAdmin,
                    ),
                  );
                },
              );
            },
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFd6e2ea),
                  backgroundImage:
                      widget.image == null ? null : NetworkImage(widget.image),
                  child: widget.image == null
                      ? const Icon(
                          Icons.person_rounded,
                          color: Colors.grey,
                          size: 30,
                        )
                      : null,
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Obx(
              () => selectedMessages.isEmpty
                  ? Container()
                  // Row(
                  //         children: [
                  //           IconButton(
                  //             onPressed: () {
                  //               sendCallRequest(CallType.audio);
                  //             },
                  //             icon: Icon(
                  //               Icons.call_rounded,
                  //               color: Colors.black,
                  //             ),
                  //           ),
                  //           IconButton(
                  //             onPressed: () {
                  //               sendCallRequest(CallType.video);
                  //             },
                  //             icon: Icon(
                  //               Icons.video_call,
                  //               color: Colors.black,
                  //             ),
                  //           ),
                  //         ],
                  //       )
                  : Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            for (var element in selectedMessages) {
                              print(element["messageId"]);
                              FirebaseFirestore.instance
                                  .collection(widget.isForSingleChatList
                                      ? "private_chats"
                                      : "messages")
                                  .doc(widget.channelId)
                                  .collection("channelChat")
                                  .doc(element["messageId"])
                                  .delete();
                            }
                            selectedMessages.value = [];
                          },
                          icon: Icon(
                            Icons.delete,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            var message = '';
                            for (var element in selectedMessages) {
                              if (element["messageType"] == "text") {
                                message +=
                                    "${decryptData(element["message"])}\n\n";
                              }
                            }
                            if (message.isNotEmpty) {
                              Clipboard.setData(ClipboardData(text: message));
                              Fluttertoast.showToast(
                                msg: "Message copied!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.black,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
                            selectedMessages.value = [];
                          },
                          icon: Icon(
                            Icons.copy,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
            ),
            // IconButton(
            //   onPressed: () {},
            //   icon: Container(
            //     padding: const EdgeInsets.all(4),
            //     decoration: const BoxDecoration(
            //       shape: BoxShape.circle,
            //       color: Colors.deepOrange,
            //     ),
            //     child: const Icon(Icons.phone),
            //   ),
            // ),
            if (!widget.isForSingleChatList)
              Obx(
                () => selectedMessages.isNotEmpty
                    ? Container()
                    : PopupMenuButton<String>(
                        icon: Icon(
                          Icons.adaptive.more,
                          color: Colors.black,
                        ),
                        onSelected: handleClick,
                        itemBuilder: (BuildContext context) {
                          return {'Schedule message', 'Clear schedule'}
                              .map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                      ),
              ),
            const SizedBox(
              width: 10,
            ),
          ],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(25),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection(widget.isForSingleChatList
                        ? "private_chats"
                        : 'messages')
                    .doc(widget.channelId)
                    .collection('channelChat')
                    .orderBy(
                      'createdTime',
                      descending: true,
                    )
                    .snapshots(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SpinKitFadingCircle(
                        color: Color(0xFF006aff),
                        size: 45.0,
                        duration: Duration(milliseconds: 900),
                      ),
                    );
                  } else {
                    List docs = snapshot.data.docs;
                    final currentUser = user?.$id;
                    if (docs.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Lottie.asset(
                                "assets/animations/no_data_found.json"),
                          ),
                          const Text("No messages here yet..."),
                        ],
                      );
                    } else {
                      return GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                        },
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          reverse: true,
                          itemCount: docs.length,
                          itemBuilder: (ctx, index) {
                            DateTime dateTime = Timestamp(
                              docs[index]["createdTime"].seconds,
                              docs[index]["createdTime"].nanoseconds,
                            ).toDate();

                            var time = DateFormat('hh:mm a').format(dateTime);

                            bool isSameDate = false;
                            String? newDate = '';

                            if (index == docs.length - 1) {
                              newDate =
                                  groupMessageDateAndTime(dateTime).toString();
                            } else {
                              final DateTime currentDate = dateTime;
                              final DateTime previousDate = Timestamp(
                                docs[index + 1]["createdTime"].seconds,
                                docs[index + 1]["createdTime"].nanoseconds,
                              ).toDate();
                              isSameDate =
                                  previousDate.year == currentDate.year &&
                                      previousDate.month == currentDate.month &&
                                      previousDate.day == currentDate.day;

                              if (kDebugMode) {
                                print("$currentDate $previousDate $isSameDate");
                              }

                              newDate = isSameDate
                                  ? ''
                                  : groupMessageDateAndTime(currentDate)
                                      .toString();
                            }

                            return Column(
                              children: [
                                if (newDate.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: Row(
                                      children: [
                                        Expanded(child: Divider()),
                                        SizedBox(width: 10),
                                        Text(newDate),
                                        SizedBox(width: 10),
                                        Expanded(child: Divider()),
                                      ],
                                    ),
                                  ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Obx(
                                    () => GestureDetector(
                                      onTap: () {
                                        if (selectedMessages.isNotEmpty) {
                                          if (selectedMessages
                                              .contains(docs[index])) {
                                            selectedMessages
                                                .remove(docs[index]);
                                          } else {
                                            selectedMessages.add(docs[index]);
                                          }
                                        }
                                      },
                                      onLongPress: () {
                                        if (selectedMessages
                                            .contains(docs[index])) {
                                          selectedMessages.remove(docs[index]);
                                        } else {
                                          selectedMessages.add(docs[index]);
                                        }
                                      },
                                      child: Container(
                                        color: selectedMessages
                                                .contains(docs[index])
                                            ? Color(0x6ec4cede)
                                            : null,
                                        child: Builder(
                                          builder: (BuildContext context) {
                                            if (docs[index]['messageType'] ==
                                                "text") {
                                              return MessageBubble(
                                                decryptData(
                                                    docs[index]['message']),
                                                docs[index]['senderId'] ==
                                                    currentUser,
                                                docs[index]['senderName'],
                                                time,
                                                selectedMessages.isNotEmpty,
                                              );
                                            } else {
                                              return ImageBubble(
                                                docs[index]['message'],
                                                docs[index]['senderId'] ==
                                                    currentUser,
                                                docs[index]['senderName'],
                                                time,
                                                selectedMessages.isNotEmpty,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      );
                    }
                  }
                },
              ),
            ),
            Container(
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, left: 8.0, bottom: 8.0),
                      child: Container(
                        // height: _textFieldHeight.value,
                        decoration: BoxDecoration(
                          color: const Color(0xFFf7f7f7),
                          border: Border.all(
                            width: 1,
                            color: Colors.grey,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(25.0),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            FloatingActionButton.small(
                              heroTag: const Text("btn1"),
                              elevation: 0,
                              disabledElevation: 0,
                              hoverElevation: 0,
                              highlightElevation: 0,
                              focusElevation: 0,
                              onPressed: () {
                                isEmojiVisible.value = !isEmojiVisible.value;
                                focusNode.unfocus();
                                // focusNode.canRequestFocus = true;
                              },
                              backgroundColor: Colors.transparent,
                              child: const Icon(
                                Icons.insert_emoticon,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: TextField(
                                textCapitalization:
                                    TextCapitalization.sentences,
                                controller: _controller,
                                scrollPhysics: BouncingScrollPhysics(),
                                focusNode: focusNode,
                                minLines: 1,
                                onTap: () {
                                  if (isEmojiVisible.value) {
                                    isEmojiVisible.value = false;
                                  }
                                },
                                maxLines: 5,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                onChanged: (value) {
                                  _enteredMessage.value = value;

                                  // _textFieldHeight.value =
                                  //     _enteredMessage.value.isEmpty
                                  //         ? 50.0
                                  //         : _enteredMessage.value
                                  //                     .split('\n')
                                  //                     .length *
                                  //                 20.0 +
                                  //             30.0;
                                  // if (_textFieldHeight.value > 100) {
                                  //   _textFieldHeight.value = 100;
                                  // }
                                  // print(_enteredMessage.value.length);
                                },
                                decoration: const InputDecoration(
                                  hintText: "Type your message here",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            FloatingActionButton.small(
                              heroTag: const Text("btn2"),
                              elevation: 0,
                              disabledElevation: 0,
                              hoverElevation: 0,
                              highlightElevation: 0,
                              focusElevation: 0,
                              onPressed: () async {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(
                                        // allowMultiple: true,
                                        type: FileType.image);
                                if (result != null) {
                                  print(result.files);
                                  if (result.files.isEmpty) return;
                                  Get.to(
                                      () => CustomImageView(
                                          result.files.first,
                                          widget.channelId,
                                          widget.isForSingleChatList,
                                          widget.reciverData),
                                      transition: Transition.zoom);
                                }
                              },
                              backgroundColor: Colors.transparent,
                              child: const Icon(
                                Icons.link_outlined,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () => Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: FloatingActionButton.small(
                        heroTag: const Text("btn3"),
                        elevation: 0,
                        disabledElevation: 0,
                        hoverElevation: 0,
                        highlightElevation: 0,
                        focusElevation: 0,
                        onPressed: _enteredMessage.trim().isEmpty
                            ? null
                            : () {
                                _sendMessage();
                              },
                        backgroundColor: Colors.deepOrange,
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => Offstage(
                offstage: !isEmojiVisible.value,
                child: SizedBox(
                  height: 250,
                  child: EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      _enteredMessage.value = _controller.text + emoji.emoji;
                      _controller.text = _controller.text + emoji.emoji;
                    },
                    onBackspacePressed: () {},
                    config: const Config(
                        columns: 7,
                        verticalSpacing: 0,
                        horizontalSpacing: 0,
                        // initCategory: Category.SMILEYS,
                        bgColor: Color(0xFFF2F2F2),
                        indicatorColor: Colors.blue,
                        iconColor: Colors.grey,
                        iconColorSelected: Colors.blue,
                        // progressIndicatorColor: Colors.blue,
                        // showRecentsTab: true,
                        recentsLimit: 28,
                        // noRecentsText: "No Recents",
                        // noRecentsStyle:
                        //     TextStyle(fontSize: 20, color: Colors.black26),
                        tabIndicatorAnimDuration: kTabScrollDuration,
                        categoryIcons: CategoryIcons(),
                        buttonMode: ButtonMode.MATERIAL),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
