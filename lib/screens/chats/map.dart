import 'package:chatting_application/controller/app_write_controller.dart';
import 'package:chatting_application/controller/controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:location/location.dart';

import '../../ads/ad_state.dart';
import '../../controller/payment_controller.dart';

class Map extends StatefulWidget {
  final channelId;

  Map(this.channelId);

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  HomeController homeController = Get.find();

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

  InterstitialAd? _interstitialAd;

  @override
  void dispose() {
    if (!PaymentController.to.isPlanActive.value) {
      _interstitialAd?.show();
    }
    super.dispose();
  }

  var locData;

  Future _getCurrentUserLocation() async {
    locData = await Location().getLocation();

    await FirebaseFirestore.instance
        .collection("messages")
        .doc(widget.channelId)
        .collection('channelMembers')
        .doc(AWController.to.user.value?.$id)
        .set({
      'userId': AWController.to.user.value?.$id,
      'lat': locData.latitude,
      'lon': locData.longitude,
    });

    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((value) async {
      List allUsersData = value.docs.map((e) => e.data()).toList();

      await FirebaseFirestore.instance
          .collection("messages")
          .doc(widget.channelId)
          .collection('channelMembers')
          .get()
          .then((value) {
        List channelUsersData = value.docs.map((e) => e.data()).toList();

        for (var user in allUsersData) {
          for (var channelUser in channelUsersData) {
            if (user["uid"] == channelUser["userId"]) {
              addMarker({
                'lat': channelUser['lat'],
                'lon': channelUser['lon'],
                'name': "${user['username']} (${user['phoneNumber']})",
                'uid': channelUser['userId'],
              });
            }
          }
        }
      });
    });

    return true;
  }

  List<Marker> markerss = [];

  addMarker(mapData) {
    if (mapData == null) {
      return;
    }
    var latitude = mapData["lat"] is String
        ? double.parse(mapData["lat"])
        : mapData["lat"];
    var longitude = mapData["lon"] is String
        ? double.parse(mapData["lon"])
        : mapData["lon"];

    Marker markerFormat = Marker(
      markerId: MarkerId('${mapData["uid"]}'),
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(title: '${mapData["name"]}', onTap: () async {}),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      ),
    );
    markerss.add(markerFormat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FutureBuilder(
                  future: _getCurrentUserLocation(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: SpinKitFadingCircle(
                          color: Color(0xFF006aff),
                          size: 45.0,
                          duration: Duration(milliseconds: 900),
                        ),
                      );
                    } else {
                      return GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(locData.latitude, locData.longitude),
                          zoom: 6,
                        ),
                        mapToolbarEnabled: false,
                        compassEnabled: false,
                        tiltGesturesEnabled: false,
                        myLocationButtonEnabled: false,
                        markers: markerss.map((e) => e).toSet(),
                      );
                    }
                  },
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Color(0xC9000000),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Get.back();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.close_rounded,
                                size: 35,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          homeController.getAdsWidget(),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
