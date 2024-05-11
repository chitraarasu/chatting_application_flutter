import 'package:chatting_application/controller/controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../ads/ad_state.dart';
import '../../controller/payment_controller.dart';

class MyGroups extends StatefulWidget {
  @override
  State<MyGroups> createState() => _MyGroupsState();
}

class _MyGroupsState extends State<MyGroups> {
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    if (!PaymentController.to.isPlanActive.value) {
      InterstitialAd.load(
        adUnitId: AdState.to.interstitialAd,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error');
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    if (!PaymentController.to.isPlanActive.value) {
      _interstitialAd?.show();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find();

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("messages").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: SpinKitFadingCircle(
                color: Color(0xFF006aff),
                size: 45.0,
                duration: Duration(milliseconds: 900),
              ),
            ),
          );
        } else if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              title: const Text(
                "My groups",
                style: TextStyle(color: Colors.black),
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.black,
                ),
                onPressed: () {
                  Get.back();
                },
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      var data = snapshot.data.docs[index];
                      if (data['channelOwnerId'] ==
                          FirebaseAuth.instance.currentUser!.uid) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 8),
                          child: Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 8),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 25,
                                              backgroundColor:
                                                  const Color(0xFFd6e2ea),
                                              backgroundImage: data[
                                                          'channelProfile'] ==
                                                      null
                                                  ? null
                                                  : NetworkImage(
                                                      data['channelProfile']),
                                              child:
                                                  data['channelProfile'] == null
                                                      ? const Icon(
                                                          Icons.person_rounded,
                                                          color: Colors.grey,
                                                          size: 30,
                                                        )
                                                      : null,
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data['channelName'],
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            PopupMenuButton<int>(
                                              itemBuilder:
                                                  (BuildContext context) =>
                                                      <PopupMenuItem<int>>[
                                                const PopupMenuItem<int>(
                                                    value: 0,
                                                    child: Text('Copy id')),
                                                const PopupMenuItem<int>(
                                                    value: 1,
                                                    child: Text('Delete')),
                                              ],
                                              onSelected: (int value) {
                                                if (value == 1) {
                                                  FirebaseFirestore.instance
                                                      .collection('messages')
                                                      .doc(data['channelId'])
                                                      .delete();
                                                }
                                                if (value == 0) {
                                                  Clipboard.setData(
                                                      ClipboardData(
                                                          text: data[
                                                              'channelId']));
                                                  Fluttertoast.showToast(
                                                    msg: "Channel id copied!",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    backgroundColor:
                                                        Colors.black,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0,
                                                  );
                                                }
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
                homeController.getAdsWidget(),
              ],
            ),
          );
        } else {
          return const Center(
            child: Text("Check your internet connection."),
          );
        }
      },
    );
  }
}
