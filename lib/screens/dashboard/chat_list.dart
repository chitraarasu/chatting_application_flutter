import 'package:chatting_application/controller/controller.dart';
import 'package:chatting_application/controller/my_encryption.dart';
import 'package:chatting_application/widget/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import '../../controller/payment_controller.dart';
import '../../widget/chat_bar.dart';
import '../../widget/empty_screen.dart';
import '../chats/channel_request.dart';
import '../chats/chat_screen.dart';

class ChatList extends StatefulWidget {
  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final box = GetStorage();
  var groups = [];

  HomeController homeController = Get.find();
  TextEditingController search = TextEditingController();

  RxString selectedListType = RxString("private-chat");
  Rx<List> dataWithOutFilter = Rx([]);
  Rx<List> dataWithFilter = Rx([]);

  updateList(String value) {
    print(value);
    if (selectedListType.value == "people") {
      dataWithFilter.value = dataWithOutFilter.value
          .where(
            (element) =>
                element["channelName"].toString().toLowerCase().contains(
                      value.toLowerCase(),
                    ),
          )
          .toList();
    } else {
      dataWithFilter.value = dataWithOutFilter.value
          .where(
            (element) => element["userData"]["username"]
                .toString()
                .toLowerCase()
                .contains(
                  value.toLowerCase(),
                ),
          )
          .toList();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    groups = [];
    if (box.read("selectedTab") != null) {
      selectedListType.value = box.read("selectedTab");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(10),
            //   child: Image(
            //     image: AssetImage("assets/app-icon.png"),
            //     width: 35,
            //   ),
            // ),
            Text(
              "Messages",
              style: TextStyle(
                color: Colors.black,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            GestureDetector(
              onTap: () {
                PaymentController.to.openPayWall();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    width: 1,
                    color: Color(0xFFBDA36B),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 6),
                  child: Row(
                    children: [
                      Image(
                        image: AssetImage("assets/images/crown.png"),
                        width: 15,
                        color: Color(0xFFBDA36B),
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Text(
                        "Go Premium",
                        style: TextStyle(
                          color: Color(0xFFBDA36B),
                          fontWeight: FontWeight.w500,
                          wordSpacing: 0,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => ChannelRequest());
            },
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                ImageIcon(
                  AssetImage("assets/images/letter.png"),
                  size: 30,
                  color: Colors.black,
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(_auth.currentUser?.uid)
                      .collection('invites')
                      .snapshots(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    } else {
                      List docs = snapshot.data.docs
                          .map((item) => item.data())
                          .toList();
                      if (docs.isEmpty) {
                        return Container();
                      } else {
                        return Positioned(
                            right: -8,
                            top: -8,
                            child: CircleAvatar(
                              radius: 12,
                              child: Text(
                                "${docs.length}",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ));
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          // Padding(
          //   padding: const EdgeInsets.only(right: 15.0),
          //   child: GestureDetector(
          //     onTap: () {
          //       Encrypted encData =
          //           MyEncryptionDecryption.encryptSalsa20("Hello hi");
          //       print(encData.base64);
          //       List<int> data = encData.bytes.toList();
          //       print(data);
          //       print(encData);
          //
          //       print(MyEncryptionDecryption.decryptSalsa20(
          //           Encrypted.from64(encData.base64)));
          //     },
          //     child: Icon(
          //       Icons.enhanced_encryption,
          //       color: Colors.red,
          //     ),
          //   ),
          // ),

          // Padding(
          //   padding: const EdgeInsets.only(right: 15.0),
          //   child: GestureDetector(
          //     onTap: () {
          //       Get.to(() => Chat());
          //     },
          //     child: Tab(
          //       icon: Lottie.asset(
          //         'assets/animations/bot-icon.json',
          //         width: 45,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Search(updateList, search),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Container(
                    height: 45.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFFebebec),
                      borderRadius: BorderRadius.all(
                        Radius.circular(25.0),
                      ),
                    ),
                    child: Row(
                        children: ["private-chat", "people"]
                            .map(
                              (e) => Expanded(
                                child: Tooltip(
                                  message: e == "people"
                                      ? "Groups"
                                      : "Private Chats",
                                  child: GestureDetector(
                                    onTap: () {
                                      if (selectedListType.value != e) {
                                        dataWithFilter.value = [];
                                        dataWithOutFilter.value = [];
                                        selectedListType.value = e;
                                        box.write("selectedTab", e);
                                        search.clear();
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Obx(
                                        () => AnimatedContainer(
                                          duration: Duration(seconds: 1),
                                          decoration: selectedListType.value !=
                                                  e
                                              ? null
                                              : BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(25.0),
                                                  ),
                                                  border: Border.all(
                                                    width: 1.5,
                                                    color: Color(0x9d575757),
                                                  ),
                                                ),
                                          child: Center(
                                            child: Image(
                                              width: 30,
                                              image: AssetImage(
                                                  "assets/images/$e.png"),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList()),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Obx(() {
              return selectedListType.value == "private-chat"
                  ? homeController.getAdsWidget()
                  : homeController.getAdsWidget();
            }),
            const SizedBox(
              height: 5,
            ),
            Expanded(
              child: Obx(
                () => selectedListType.value == "private-chat"
                    ? StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("private_chats")
                            .where('chat_members',
                                arrayContains: _auth.currentUser?.uid)
                            .orderBy(
                              'createdTime',
                              descending: true,
                            )
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SpinKitFadingCircle(
                              color: Color(0xFF006aff),
                              size: 45.0,
                              duration: Duration(milliseconds: 900),
                            );
                          } else if (snapshot.hasData) {
                            List docs = snapshot.data.docs;
                            List chatData = docs.map((e) => e.data()).toList();
                            var receivers = [];
                            for (var e in chatData) {
                              List data = e["chat_members"];
                              data.remove(_auth.currentUser?.uid);
                              receivers.add(data.first);
                            }
                            print(receivers);
                            if (chatData.isEmpty) {
                              return const EmptyScreen();
                            } else {
                              return StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("users")
                                    .where('uid', whereIn: receivers)
                                    .snapshots(),

                                /// whereIn has on restriction. Only 10 item can pass on array

                                builder: (BuildContext context,
                                    AsyncSnapshot<dynamic> snp) {
                                  if (snp.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SpinKitFadingCircle(
                                      color: Color(0xFF006aff),
                                      size: 45.0,
                                      duration: Duration(milliseconds: 900),
                                    );
                                  } else if (snp.hasData) {
                                    List users = snp.data.docs;
                                    List usersData =
                                        users.map((e) => e.data()).toList();
                                    for (var user in usersData) {
                                      for (var e in chatData) {
                                        List data = e["chat_members"];
                                        if (data.length > 1) {
                                          data.remove(_auth.currentUser?.uid);
                                        }
                                        if (user["uid"] == data.first) {
                                          e["userData"] = user;
                                        }
                                      }
                                    }

                                    dataWithOutFilter.value = chatData;
                                    dataWithFilter.value = chatData;

                                    return Obx(
                                      () => ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: dataWithFilter.value.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          var time =
                                              DateFormat('hh:mm a').format(
                                            Timestamp(
                                                    dataWithFilter
                                                        .value[index]
                                                            ["createdTime"]
                                                        .seconds,
                                                    dataWithFilter
                                                        .value[index]
                                                            ["createdTime"]
                                                        .nanoseconds)
                                                .toDate(),
                                          );
                                          var user = dataWithFilter.value[index]
                                              ?["userData"];
                                          return ChatBar(
                                            dataWithFilter.value[index]
                                                ["chat_id"],
                                            user?["username"] ?? "",
                                            dataWithFilter.value[index]
                                                        ["recentMessage"]
                                                    .toString()
                                                    .contains(
                                                        "https://firebasestorage.googleapis.com/v0/b/csp-chatting-app.appspot.com/o/user_data")
                                                ? 'Image'
                                                : decryptData(
                                                    dataWithFilter.value[index]
                                                        ["recentMessage"]),
                                            user["profileUrl"],
                                            time,
                                            "",
                                            () {
                                              Get.to(
                                                () => ChatScreen(
                                                  user["username"],
                                                  user["profileUrl"],
                                                  dataWithFilter.value[index]
                                                      ['chat_id'],
                                                  isForSingleChatList: true,
                                                  reciverData: user,
                                                ),
                                                transition: Transition.fadeIn,
                                              );
                                            },
                                            () {
                                              FirebaseFirestore.instance
                                                  .collection('private_chats')
                                                  .doc(dataWithFilter
                                                      .value[index]["chat_id"])
                                                  .delete();
                                            },
                                          );
                                        },
                                      ),
                                    );
                                  } else {
                                    return const EmptyScreen();
                                  }
                                },
                              );
                            }
                          } else {
                            return const EmptyScreen();
                          }
                        },
                      )
                    : StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("users")
                            .doc(_auth.currentUser?.uid)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SpinKitFadingCircle(
                              color: Color(0xFF006aff),
                              size: 45.0,
                              duration: Duration(milliseconds: 900),
                            );
                          } else if (snapshot.hasData) {
                            var loggedInUserData = snapshot.data.data();
                            List userChannels =
                                loggedInUserData["userChannels"] ?? [];
                            return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection("messages")
                                  .orderBy(
                                    'time',
                                    descending: true,
                                  )
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<dynamic> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SpinKitFadingCircle(
                                    color: Color(0xFF006aff),
                                    size: 45.0,
                                    duration: Duration(milliseconds: 900),
                                  );
                                } else if (!snapshot.hasData ||
                                    snapshot.hasError) {
                                  return const EmptyScreen();
                                } else {
                                  List docs = snapshot.data.docs
                                      .map((item) => item.data())
                                      .toList();

                                  var currentUserGroups = [];

                                  for (var userChannelItem in userChannels) {
                                    for (var item in docs) {
                                      if (item['channelId'] ==
                                          userChannelItem) {
                                        currentUserGroups.add(item);
                                      }
                                    }
                                  }

                                  docs = currentUserGroups;

                                  dataWithOutFilter.value = docs;
                                  dataWithFilter.value = docs;

                                  FirebaseFirestore.instance
                                      .collection('messages')
                                      .get()
                                      .then((items) async {
                                    groups = [];
                                    for (var item in items.docs) {
                                      groups.add(item['channelId']);
                                    }
                                    for (var element in docs) {
                                      if (!groups
                                          .contains(element["channelId"])) {
                                        userChannels
                                            .remove(element["channelId"]);
                                        await FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(FirebaseAuth
                                                .instance.currentUser!.uid)
                                            .update(
                                                {"userChannels": userChannels});
                                      }
                                    }
                                  });

                                  if (dataWithFilter.value.isEmpty) {
                                    return const EmptyScreen();
                                  } else {
                                    return Obx(
                                      () => ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: dataWithFilter.value.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          var time =
                                              DateFormat('hh:mm a').format(
                                            Timestamp(
                                                    dataWithFilter
                                                        .value[index]["time"]
                                                        .seconds,
                                                    dataWithFilter
                                                        .value[index]["time"]
                                                        .nanoseconds)
                                                .toDate(),
                                          );
                                          return ChatBar(
                                            dataWithFilter.value[index]
                                                ["channelId"],
                                            dataWithFilter.value[index]
                                                ["channelName"],
                                            dataWithFilter.value[index]
                                                        ["recentMessage"]
                                                    .toString()
                                                    .contains(
                                                        "https://firebasestorage.googleapis.com/v0/b/csp-chatting-app.appspot.com/o/user_data")
                                                ? 'Image'
                                                : decryptData(
                                                    dataWithFilter.value[index]
                                                        ["recentMessage"]),
                                            dataWithFilter.value[index]
                                                ["channelProfile"],
                                            time,
                                            "3",
                                            () {
                                              Get.to(
                                                () => ChatScreen(
                                                  dataWithFilter.value[index]
                                                      ["channelName"],
                                                  dataWithFilter.value[index]
                                                      ["channelProfile"],
                                                  dataWithFilter.value[index]
                                                      ['channelId'],
                                                  isChannelAdmin: dataWithFilter
                                                              .value[index]
                                                          ["channelOwnerId"] ==
                                                      FirebaseAuth.instance
                                                          .currentUser?.uid,
                                                ),
                                                transition: Transition.fadeIn,
                                              );
                                            },
                                            () async {
                                              final user = FirebaseAuth
                                                  .instance.currentUser!;

                                              FirebaseFirestore.instance
                                                  .collection('messages')
                                                  .doc(dataWithFilter
                                                          .value[index]
                                                      ['channelId'])
                                                  .collection("channelMembers")
                                                  .doc(user.uid)
                                                  .delete();

                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(user.uid)
                                                  .get()
                                                  .then((data) async {
                                                List userChannels =
                                                    data["userChannels"] ?? [];
                                                userChannels.remove(
                                                    dataWithFilter.value[index]
                                                        ['channelId']);
                                                await FirebaseFirestore.instance
                                                    .collection("users")
                                                    .doc(user.uid)
                                                    .update({
                                                  "userChannels": userChannels
                                                });
                                              });
                                            },
                                          );
                                        },
                                      ),
                                    );
                                  }
                                }
                              },
                            );
                          } else {
                            return const EmptyScreen();
                          }
                        },
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
