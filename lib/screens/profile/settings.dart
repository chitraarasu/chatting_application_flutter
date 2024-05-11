import 'package:chatting_application/controller/controller.dart';
import 'package:chatting_application/screens/onboarding/privacy_policy.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../ads/ad_state.dart';
import '../../controller/payment_controller.dart';
import '../../widget/contributors.dart';

class CustomSettings extends StatefulWidget {
  @override
  State<CustomSettings> createState() => _CustomSettingsState();
}

class _CustomSettingsState extends State<CustomSettings> {
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

  List items = [
    "Contributors",
    "Source Code",
    "Privacy Policy",
  ];

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Settings",
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < items.length; i++)
                  GestureDetector(
                    onTap: () {
                      if (i == 0) {
                        Get.to(() => Contributors(),
                            transition: Transition.fadeIn);
                      } else if (i == 1) {
                        launchUrl(
                            Uri.parse("https://github.com/chitraarasu/Jabber"));
                      } else if (i == 2) {
                        Get.to(() => PrivacyPolicyScreen(isFromInsideApp: true),
                            transition: Transition.fadeIn);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Card(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Text(
                                items[i],
                                style: TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                              Spacer(),
                              Icon(Icons.arrow_forward_ios_rounded)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          homeController.getAdsWidget(),
        ],
      ),
    );
  }
}
