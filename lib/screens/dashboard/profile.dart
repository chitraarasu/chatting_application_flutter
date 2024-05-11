import 'package:animations/animations.dart';
import 'package:chatting_application/screens/profile/edit_profile.dart';
import 'package:chatting_application/screens/profile/settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workmanager/workmanager.dart';

import '../../controller/controller.dart';
import '../../controller/payment_controller.dart';
import '../../widget/open_image.dart';
import '../chats/my_groups.dart';
import '../onboarding/onboarding_page.dart';

class Profile extends StatelessWidget {
  List buttonList = [
    "😴 Away",
    "💻 At Work",
    "🎮 Gaming",
    "🆓 Free",
    "📖 Study",
  ];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  _displayDialog(BuildContext context) async {
    return showModal(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Do you want to logout?'),
            actions: <Widget>[
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text(
                  'Yes',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Get.find<HomeController>().setScreen(0);
                  _auth.signOut();
                  Get.offAll(const OnBoardingPage(),
                      transition: Transition.fade);
                  await FirebaseMessaging.instance.deleteToken();
                  await Purchases.logOut();
                  PaymentController.to.isPlanActive.value = false;
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find();
    return WillPopScope(
      onWillPop: () async {
        homeController.setScreen(0);
        return false;
      },
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(_auth.currentUser?.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: SpinKitFadingCircle(
                  color: Color(0xFF006aff),
                  size: 45.0,
                  duration: Duration(milliseconds: 1000),
                ),
              ),
            );
          } else {
            var docs = snapshot.data;
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                title: const Text(
                  "Profile",
                  style: TextStyle(
                    color: Colors.black,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Get.to(() => EditProfile(docs),
                          transition: Transition.fadeIn);
                    },
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (docs.get('profileUrl') != null) {
                                      Get.to(
                                          () =>
                                              OpenImage(docs.get('profileUrl')),
                                          transition: Transition.fadeIn);
                                    }
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Color(0xFFf4f5f7),
                                    radius: 40,
                                    backgroundImage: docs.get('profileUrl') ==
                                            null
                                        ? null
                                        : NetworkImage(docs.get('profileUrl')),
                                  ),
                                ),
                                SizedBox(
                                  width: 25,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        docs.get('username'),
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        docs.get('phoneNumber'),
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // SizedBox(
                      //   height: 20,
                      // ),
                      // Text(
                      //   "My Status",
                      //   style: TextStyle(
                      //     fontSize: 20,
                      //     fontWeight: FontWeight.w400,
                      //     color: Colors.grey,
                      //   ),
                      // ),
                      // GetBuilder<Controller>(
                      //   init: Controller(),
                      //   builder: (getController) => Container(
                      //     margin: EdgeInsets.only(top: 10),
                      //     height: 45.0,
                      //     child: ListView.builder(
                      //       scrollDirection: Axis.horizontal,
                      //       itemBuilder: (BuildContext context, int index) {
                      //         return TopButton(
                      //           index: index,
                      //           buttonTitle: buttonList[index],
                      //           tagDataMethod: (isSelected) async {
                      //             getController
                      //                 .setValue(isSelected ? index : null);
                      //           },
                      //           value: getController.value,
                      //         );
                      //       },
                      //       itemCount: buttonList.length,
                      //     ),
                      //   ),
                      // ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Dashboard",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Obx(
                        () => PaymentController.to.isPlanActive.value
                            ? Container()
                            : CustomTile(
                                "Subscribe Now",
                                "assets/images/crown.png",
                                Color(0xFFBDA36B),
                                () {
                                  PaymentController.to.openPayWall();
                                },
                              ),
                      ),
                      CustomTile("Groups", Icons.group_rounded, Colors.green,
                          () {
                        Get.to(() => MyGroups(), transition: Transition.fadeIn);
                      }),
                      // CustomTile("Block List", Icons.block_rounded,
                      //     Colors.yellow, () {}),
                      CustomTile(
                          "Settings", Icons.settings_rounded, Colors.grey, () {
                        Get.to(() => CustomSettings(),
                            transition: Transition.fadeIn);
                      }),

                      CustomTile(
                        "Clear Schedules",
                        Icons.punch_clock,
                        Colors.blueGrey,
                        () {
                          Workmanager().cancelAll();
                          Fluttertoast.showToast(
                            msg: "All schedules cleared!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        },
                      ),
                      SizedBox(height: 10),

                      // Row(
                      //   children: [
                      //     TextButton(
                      //       onPressed: () {},
                      //       child: Text(
                      //         "Switch to Other Account",
                      //         style:
                      //             TextStyle(color: Colors.blue, fontSize: 18),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              launchUrl(Uri.parse(
                                  "https://www.buymeacoffee.com/ckncreation"));
                            },
                            child: Image(
                              image: AssetImage("assets/images/bmac.png"),
                              height: 45,
                            ),
                          ),
                          Spacer(),
                          TextButton(
                            onPressed: () {
                              _displayDialog(context);
                            },
                            child: Text(
                              "Log Out",
                              style: TextStyle(color: Colors.red, fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Obx(
                        () => PaymentController.to.isPlanActive.value
                            ? Container()
                            : Text(
                                "Ads",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: homeController.getAdsWidget(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: homeController.getAdsWidget(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: homeController.getAdsWidget(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class CustomTile extends StatelessWidget {
  final topic;
  final color;
  final icon;
  Function onTap;

  CustomTile(this.topic, this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: color,
                    child: icon.runtimeType == String
                        ? ImageIcon(
                            AssetImage(icon),
                            color: Colors.white,
                            size: 30,
                          )
                        : Icon(
                            icon,
                            color: Colors.white,
                            size: 30,
                          ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    topic,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (topic != "Clear Schedules")
                if (topic != "Donate")
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 25,
                    color: Colors.black,
                  )
            ],
          ),
        ),
      ),
    );
  }
}

class TopButton extends StatelessWidget {
  final buttonTitle;
  Function tagDataMethod;
  final index;
  final value;

  TopButton({
    this.buttonTitle,
    required this.tagDataMethod,
    this.index,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 5.0),
      child: Wrap(
        children: [
          ChoiceChip(
            onSelected: (isSelected) {
              tagDataMethod(isSelected);
            },
            label: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                buttonTitle,
                style: TextStyle(color: Colors.white),
              ),
            ),
            backgroundColor: Colors.blue,
            selectedColor: Color(0xFF003F9C),
            selected: value == index,
          ),
        ],
      ),
    );
  }
}
