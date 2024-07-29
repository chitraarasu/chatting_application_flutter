import 'dart:convert';
import 'dart:io';

import 'package:chatting_application/controller/payment_controller.dart';
import 'package:chatting_application/credentials.dart';
import 'package:chatting_application/screens/dashboard/chat_list.dart';
import 'package:chatting_application/screens/dashboard/music.dart';
import 'package:chatting_application/screens/dashboard/profile.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:new_version_plus/new_version_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ads/ad_state.dart';
import '../screens/dashboard/news.dart';

class HomeController extends GetxController {
  var _index = 0;
  var isEmojiVisible = false;

  var _isLoading = false;

  get isLoading {
    return _isLoading;
  }

  setIsLoading(val) {
    _isLoading = val;
  }

  var _value = 0;

  get value {
    return _value;
  }

  setValue(val) {
    _value = val;
    update();
  }

  final _screens = [
    ChatList(),
    Music(),
    News(),
    Profile(),
  ];

  get body {
    return _screens[_index];
  }

  get index {
    return _index;
  }

  setScreen(index) {
    switch (index) {
      case 0:
        _index = index;
        break;
      case 1:
        _index = index;
        break;
      case 2:
        _index = index;
        break;
      case 3:
        _index = index;
        break;
    }
    update();
  }

  Country _selectedDialogCountry =
      CountryPickerUtils.getCountryByPhoneCode('91');

  Country get selectedDialogCountry {
    return _selectedDialogCountry;
  }

  setCountry(country) {
    _selectedDialogCountry = country;
    update();
  }

  File? _storedImage;
  File? _storedChannelImage;

  get userProfileImage {
    return _storedImage;
  }

  get channelProfileImage {
    return _storedChannelImage;
  }

  setUserProfileImage(image) {
    _storedImage = image;
    update();
  }

  setChannelProfileImage(image) {
    _storedChannelImage = image;
    update();
  }

  List<Contact> _contactPhoneNumbers = [];
  List userData = [];

  Future<List<Contact>> getContacts() async {
    if (_contactPhoneNumbers.isNotEmpty) {
      return _contactPhoneNumbers;
    }
    var permissionStatus = await Permission.contacts.request();
    if (permissionStatus.isGranted) {
      _contactPhoneNumbers = [];
      try {
        print("Fetching contacts!");
        List<Contact> contacts = await FastContacts.getAllContacts();
        _contactPhoneNumbers =
            contacts.where((element) => element.phones.isNotEmpty).toList();
        _contactPhoneNumbers
            .sort((a, b) => a.displayName.compareTo(b.displayName));
        return _contactPhoneNumbers;
      } catch (e) {
        throw "Something went wrong. Please try again later";
      }
    } else if (permissionStatus.isDenied) {
      throw 'Contacts permission is denied.';
    } else if (permissionStatus.isPermanentlyDenied) {
      throw 'Contacts permission is permanently denied.';
    } else {
      throw "Something went wrong. Please try again later";
    }
  }

  sendNotification({data, tokens, name, message}) async {
    const url = 'https://fcm.googleapis.com/fcm/send';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$firebaseSecret',
    };

    final messagee = {
      'registration_ids': tokens,
      'data': data,
      'notification': {
        "body": message,
        "title": name,
      },
      'priority': 'high',
    };

    print(messagee);

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(messagee),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Error: ${response.body}');
    }
  }

  void checkVersion(context) async {
    final newVersion = NewVersionPlus(
      iOSId: 'com.csp.jabber',
      androidId: "com.csp.jabber",
    );

    final VersionStatus? versionStatus = await newVersion.getVersionStatus();
    if (versionStatus != null && versionStatus.canUpdate) {
      showCustomDialog(versionStatus, context);
    }
  }

  showCustomDialog(VersionStatus versionStatus, context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Update Available"),
        content: Text(
          'You can now update this app from ${versionStatus.localVersion} to ${versionStatus.storeVersion}',
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Update',
            ),
            onPressed: () {
              launch(versionStatus.appStoreLink);
            },
          ),
        ],
      ),
    );
  }

  Widget getAdsWidget() {
    return Obx(
      () => PaymentController.to.isPlanActive.value
          ? Container()
          : Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xFFebebec),
              ),
              clipBehavior: Clip.hardEdge,
              child: AdWidget(
                ad: BannerAd(
                  adUnitId: AdState.to.bannerAdUnitId,
                  size: AdSize.banner,
                  request: AdRequest(),
                  listener: BannerAdListener(),
                )..load(),
              ),
            ),
    );
  }
}
