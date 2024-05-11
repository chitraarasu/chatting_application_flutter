import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';

import '../../ads/ad_state.dart';
import '../../controller/controller.dart';
import '../../controller/payment_controller.dart';

class EditChannel extends StatefulWidget {
  final channelName;
  final channelImage;
  final channelId;

  EditChannel(this.channelName, this.channelImage, this.channelId);

  @override
  State<EditChannel> createState() => _EditChannelState();
}

class _EditChannelState extends State<EditChannel> {
  TextEditingController channelNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    channelNameController.text = widget.channelName;
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

  @override
  Widget build(BuildContext context) {
    var isLoading = false.obs;
    FocusNode focusNode = FocusNode();
    HomeController homeController = Get.find();
    var isEmojiVisible = false.obs;

    PickedFile? imageFile;
    Future _takePicture() async {
      imageFile = await ImagePicker.platform.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      print(imageFile);
      if (imageFile == null) {
        return;
      }
      Get.find<HomeController>().setChannelProfileImage(
        File(imageFile!.path),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
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
        centerTitle: true,
        title: const Text(
          "Edit Channel",
          style: TextStyle(
            color: Colors.black,
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          GetBuilder<HomeController>(
                            builder: (getController) => CircleAvatar(
                              backgroundColor: Colors.blueGrey,
                              radius: 67,
                              child: CircleAvatar(
                                radius: 65,
                                backgroundColor: Colors.white,
                                backgroundImage:
                                    getController.channelProfileImage != null
                                        ? FileImage(
                                            getController.channelProfileImage,
                                          )
                                        : widget.channelImage != null
                                            ? NetworkImage(widget.channelImage)
                                            : null as ImageProvider<Object>?,
                                child:
                                    getController.channelProfileImage != null ||
                                            widget.channelImage != null
                                        ? null
                                        : const Icon(
                                            Icons.add_a_photo_rounded,
                                            size: 65,
                                            color: Colors.blueGrey,
                                          ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _takePicture();
                            },
                            child: CircleAvatar(
                              child: Icon(Icons.edit),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                                border: Border.all(
                                  width: 2,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              child: TextField(
                                focusNode: focusNode,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                maxLines: 1,
                                onTap: () {
                                  if (isEmojiVisible.value) {
                                    isEmojiVisible.value = false;
                                  }
                                },
                                controller: channelNameController,
                                style: const TextStyle(color: Colors.blueGrey),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(12.5),
                                  hintText: 'Enter channel name',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              isEmojiVisible.value = !isEmojiVisible.value;
                              focusNode.unfocus();
                              focusNode.canRequestFocus = true;
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Colors.blueGrey,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.insert_emoticon,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            homeController.getAdsWidget(),
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                isLoading.value = true;
                var url;
                if (homeController.channelProfileImage != null) {
                  final ref = FirebaseStorage.instance
                      .ref()
                      .child('channel_image')
                      .child("${widget.channelId}.jpg");
                  await ref.putFile(homeController.channelProfileImage);
                  url = await ref.getDownloadURL();
                }
                await FirebaseFirestore.instance
                    .collection("messages")
                    .doc(widget.channelId)
                    .update({
                  'channelName': channelNameController.text,
                  'channelProfile': url ?? widget.channelImage,
                });
                isLoading.value = false;

                Get.back();
                Get.back();
              },
              child: Container(
                height: 55,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF006aff),
                ),
                child: Center(
                  child: Obx(
                    () => isLoading.value
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "Save",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            Obx(
              () => Offstage(
                offstage: !isEmojiVisible.value,
                child: SizedBox(
                  height: 250,
                  child: EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      channelNameController.text =
                          channelNameController.text + emoji.emoji;
                    },
                    onBackspacePressed: () {},
                    config: const Config(
                        columns: 7,
                        verticalSpacing: 0,
                        horizontalSpacing: 0,
                        initCategory: Category.SMILEYS,
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
