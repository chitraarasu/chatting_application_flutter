import 'dart:io';

import 'package:chatting_application/controller/controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';

import '../../ads/ad_state.dart';
import '../../controller/payment_controller.dart';

class EditProfile extends StatefulWidget {
  final data;

  EditProfile(this.data);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();

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

  // final TextEditingController _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find();
    _nameController.value = _nameController.value.copyWith(
      text: widget.data.get('username'),
    );

    var isLoading = false.obs;

    var editProfileImage = File("").obs;

    Future _takePicture() async {
      var imageFile = await ImagePicker.platform.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        imageQuality: 50,
      );
      if (imageFile != null) {
        editProfileImage.value = File(imageFile.path);
        isLoading.value = false;
      }
    }

    return Obx(
      () => Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                onPressed: () {
                  Get.back();
                },
              ),
              actions: [
                GestureDetector(
                  onTap: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    isLoading.value = true;
                    var url;
                    if (editProfileImage.value.path.isNotEmpty) {
                      final ref = FirebaseStorage.instance
                          .ref()
                          .child('user_image')
                          .child(
                              "${FirebaseAuth.instance.currentUser?.uid}.jpg");
                      await ref.putFile(editProfileImage.value);
                      url = await ref.getDownloadURL();
                    }
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .update({
                      'username': _nameController.text,
                      'profileUrl': url ?? widget.data.get('profileUrl'),
                    });
                    isLoading.value = false;

                    Get.back();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Icon(
                      Icons.save,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
              centerTitle: true,
              title: const Text(
                "Edit Profile",
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 65,
                                    backgroundColor: Color(0xFFedeff0),
                                    backgroundImage:
                                        widget.data.get('profileUrl') == null
                                            ? null
                                            : NetworkImage(
                                                widget.data.get('profileUrl')),
                                    child: CircleAvatar(
                                      radius: 65,
                                      backgroundColor: Colors.transparent,
                                      backgroundImage: editProfileImage
                                              .value.path.isEmpty
                                          ? null
                                          : FileImage(editProfileImage.value),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: FloatingActionButton.small(
                                      onPressed: () {
                                        _takePicture();
                                      },
                                      child: const Icon(Icons.edit),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                widget.data.get('username'),
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                widget.data.get('phoneNumber'),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          "Username",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                        ),
                        TextField(
                          controller: _nameController,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        // SizedBox(
                        //   height: 30,
                        // ),
                        // Text(
                        //   "Email Address",
                        //   style: TextStyle(
                        //     fontSize: 20,
                        //     fontWeight: FontWeight.w400,
                        //     color: Colors.grey,
                        //   ),
                        // ),
                        // TextField(
                        //   controller: _emailController,
                        //   keyboardType: TextInputType.emailAddress,
                        //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        // ),
                        // SizedBox(
                        //   height: 30,
                        // ),
                        // Text(
                        //   "About",
                        //   style: TextStyle(
                        //     fontSize: 20,
                        //     fontWeight: FontWeight.w400,
                        //     color: Colors.grey,
                        //   ),
                        // ),
                        // TextField(
                        //   controller: _aboutController,
                        //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        //   textCapitalization: TextCapitalization.sentences,
                        // ),
                      ],
                    ),
                  ),
                ),
                homeController.getAdsWidget(),
              ],
            ),
          ),
          if (isLoading.value)
            Container(
              color: Color(0x85000000),
              child: Center(
                child: SpinKitFadingCircle(
                  color: Color(0xffffffff),
                  size: 45.0,
                  duration: Duration(milliseconds: 900),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
