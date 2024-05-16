import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../../controller/controller.dart';

class ChannelRequest extends StatelessWidget {
  getCircleIcon(icon, color, onTap) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: color,
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(
          icon,
          color: color,
          size: 30,
        ),
      ),
    );
  }

  final _auth = FirebaseAuth.instance;

  Rx<bool> isLoading = Rx(false);

  joinChannel(channelId) async {
    isLoading.value = true;
    var isValid = false;
    var channelList;
    await FirebaseFirestore.instance.collection("messages").get().then(
      (data) {
        channelList = data.docs;
      },
    );
    for (var item in channelList) {
      if (channelId == item["channelId"]) {
        isValid = true;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .get()
            .then((data) async {
          List userChannels = data["userChannels"] ?? [];

          await FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .update({
            "userChannels": [item["channelId"], ...userChannels]
          });

          await FirebaseFirestore.instance
              .collection("messages")
              .doc(channelId)
              .collection("channelMembers")
              .doc(_auth.currentUser?.uid)
              .set({
            'userId': _auth.currentUser?.uid,
          });
        });
      }
    }
    if (isValid) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(_auth.currentUser?.uid)
          .collection('invites')
          .doc(channelId)
          .delete();
      Get.back();
    }
    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser!;
    HomeController homeController = Get.find();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.black,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Invites",
          style: TextStyle(
            color: Colors.black,
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(authUser.uid)
                      .collection('invites')
                      .orderBy(
                        'createdTime',
                        descending: true,
                      )
                      .snapshots(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Text("Loading..."),
                      );
                    } else {
                      List docs = snapshot.data.docs
                          .map((item) => item.data())
                          .toList();
                      if (docs.isEmpty) {
                        return Container(
                          child: Center(
                            child: Text("No invites found !"),
                          ),
                        );
                      }
                      print(docs);
                      // var channelIds = [];
                      // if (snapshot.data != null) {
                      //   for (var item in docs) {
                      //     channelIds.add(item["channelId"]);
                      //   }
                      // }

                      return FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection("messages")
                            .get(),
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SpinKitFadingCircle(
                              color: Color(0xFF006aff),
                              size: 45.0,
                              duration: Duration(milliseconds: 900),
                            );
                          } else {
                            List channelData = snapshot.data.docs
                                .map((e) => e.data())
                                .toList();
                            for (var item in channelData) {
                              for (var e in docs) {
                                if (item["channelId"] == e["channelId"]) {
                                  e["channelData"] = item;
                                }
                              }
                            }
                            print(docs);

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView.builder(
                                  itemCount: docs.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Card(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 8),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 25,
                                                        backgroundColor:
                                                            const Color(
                                                                0xFFd6e2ea),
                                                        backgroundImage: docs[
                                                                            index]
                                                                        [
                                                                        "channelData"]
                                                                    [
                                                                    'channelProfile'] ==
                                                                null
                                                            ? null
                                                            : NetworkImage(docs[
                                                                        index][
                                                                    "channelData"]
                                                                [
                                                                'channelProfile']),
                                                      ),
                                                      const SizedBox(
                                                        width: 20,
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              docs[index][
                                                                      "channelData"]
                                                                  [
                                                                  'channelName'],
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text(
                                                              "Invited by ${docs[index]["invitedBy"]}",
                                                              maxLines: 1,
                                                              style:
                                                                  const TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(width: 4),
                                                      getCircleIcon(
                                                          Icons.cancel,
                                                          Colors.red, () {
                                                        showModal(
                                                            context: context,
                                                            builder: (context) {
                                                              return AlertDialog(
                                                                title: const Text(
                                                                    'Are you sure? Do you want to remove this invite?'),
                                                                actions: <Widget>[
                                                                  TextButton(
                                                                    child:
                                                                        const Text(
                                                                            'No'),
                                                                    onPressed:
                                                                        () {
                                                                      Get.back();
                                                                    },
                                                                  ),
                                                                  TextButton(
                                                                    child:
                                                                        const Text(
                                                                      'Yes',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.red),
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      Get.back();

                                                                      isLoading
                                                                              .value =
                                                                          true;
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              "users")
                                                                          .doc(authUser
                                                                              .uid)
                                                                          .collection(
                                                                              'invites')
                                                                          .doc(docs[index]
                                                                              [
                                                                              "channelId"])
                                                                          .delete();
                                                                      isLoading
                                                                              .value =
                                                                          false;
                                                                    },
                                                                  )
                                                                ],
                                                              );
                                                            });
                                                      }),
                                                      SizedBox(width: 10),
                                                      getCircleIcon(
                                                          Icons.check_circle,
                                                          Colors.green, () {
                                                        joinChannel(docs[index]
                                                            ["channelId"]);
                                                      }),
                                                      SizedBox(width: 4),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            );
                          }
                        },
                      );
                    }
                  },
                ),
                Obx(
                  () => isLoading.value
                      ? Container(
                          color: Colors.white.withOpacity(.5),
                          child: SpinKitFadingCircle(
                            color: Color(0xFF006aff),
                            size: 45.0,
                            duration: Duration(milliseconds: 900),
                          ),
                        )
                      : Container(),
                ),
              ],
            ),
          ),
          // homeController.getAdsWidget(),
          homeController.getAdsWidget(),
        ],
      ),
    );
  }
}
