import 'dart:io';

import 'package:chatting_application/controller/controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../dashboard/home.dart';

class UserProfileInputScreen extends StatefulWidget {
  final number;
  final code;
  final id;

  UserProfileInputScreen(this.number, this.code, this.id);

  @override
  State<UserProfileInputScreen> createState() => _UserProfileInputScreenState();
}

class _UserProfileInputScreenState extends State<UserProfileInputScreen> {
  TextEditingController nameController = TextEditingController();
  HomeController homeController = Get.find();

  FocusNode focusNode = FocusNode();
  var isEmojiVisible = false.obs;

  @override
  void dispose() {
    // nameController.dispose();
    focusNode.removeListener(() {});
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        isEmojiVisible.value == false;
      }
    });
  }

  var isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    PickedFile? imageFile;
    Future _takePicture() async {
      imageFile = await ImagePicker.platform.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        imageQuality: 50,
      );
      if (imageFile == null) {
        return;
      }
      Get.find<HomeController>().setUserProfileImage(
        File(imageFile!.path),
      );
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
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Colors.deepOrange, Colors.deepOrangeAccent],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "Profile info",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
            ),
          ),
          body: FutureBuilder(
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(widget.id)
                .get(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              } else {
                var docs = snapshot.data?.data();
                if (docs != null) {
                  nameController.text = docs["username"];
                }
                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  "Step 03/03",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  "Please provide your name and an optional profile photo",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22.5,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Stack(
                                  children: [
                                    GetBuilder<HomeController>(
                                      init: HomeController(),
                                      builder: (getController) => CircleAvatar(
                                        radius: 65,
                                        backgroundColor: Colors.white,
                                        backgroundImage: getController
                                                    .userProfileImage !=
                                                null
                                            ? FileImage(
                                                getController.userProfileImage,
                                              )
                                            : docs != null
                                                ? docs["profileUrl"] == null
                                                    ? null
                                                    : NetworkImage(
                                                            docs["profileUrl"])
                                                        as ImageProvider<
                                                            Object>?
                                                : null,
                                        // child: getController.userProfileImage !=
                                        //         null
                                        //     ? null
                                        //     : docs != null
                                        //         ? docs["profileUrl"] != null
                                        //             ? null
                                        //             : const Icon(
                                        //                 Icons
                                        //                     .add_a_photo_rounded,
                                        //                 size: 65,
                                        //                 color: Colors.blueGrey,
                                        //               )
                                        //         : null,
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
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                              border: Border.all(
                                                width: 2,
                                                color: Colors.white,
                                              )),
                                          child: TextField(
                                            focusNode: focusNode,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            maxLines: 1,
                                            controller: nameController,
                                            onTap: () {
                                              if (isEmojiVisible.value) {
                                                isEmojiVisible.value = false;
                                              }
                                            },
                                            style: const TextStyle(
                                                color: Colors.white),
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.all(12.5),
                                              hintText: 'Enter your name',
                                              border: InputBorder.none,
                                              hintStyle: TextStyle(
                                                color: Colors.white,
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
                                          isEmojiVisible.value =
                                              !isEmojiVisible.value;
                                          focusNode.unfocus();
                                          focusNode.canRequestFocus = true;
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: Colors.white,
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.insert_emoticon,
                                              size: 40,
                                              color: Colors.blueGrey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  elevation: MaterialStateProperty.all(0),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.blue),
                                ),
                                onPressed: () async {
                                  try {
                                    if (!isLoading.value) {
                                      if (nameController.text
                                          .trim()
                                          .isNotEmpty) {
                                        isLoading.value = true;
                                        var url;
                                        var channelList = [];
                                        var preProfileData;
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(widget.id)
                                            .get()
                                            .then((value) {
                                          preProfileData = value.data();
                                        });
                                        if (preProfileData != null) {
                                          url = preProfileData['profileUrl'];
                                          channelList =
                                              preProfileData['userChannels'] ??
                                                  [];
                                        }
                                        if (homeController.userProfileImage !=
                                            null) {
                                          final ref = FirebaseStorage.instance
                                              .ref()
                                              .child('user_image')
                                              .child("${widget.id}.jpg");
                                          await ref.putFile(
                                              homeController.userProfileImage);
                                          url = await ref.getDownloadURL();
                                        }
                                        String? token = '';
                                        try {
                                          token = await FirebaseMessaging
                                              .instance
                                              .getToken();
                                        } catch (e) {
                                          print(e);
                                        }
                                        await FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(widget.id)
                                            .set({
                                          'token': token,
                                          'username': nameController.text,
                                          'phoneNumber': widget.number,
                                          'countryCode': widget.code,
                                          'isOnline': true,
                                          'profileUrl': url,
                                          'userChannels': channelList,
                                          "uid": widget.id,
                                        });
                                        isLoading.value = false;
                                        Get.offAll(
                                          () => const Home(),
                                          transition: Transition.fadeIn,
                                        );
                                      }
                                    }
                                  } catch (error) {
                                    isLoading.value = false;
                                  }
                                },
                                child: Obx(
                                  () => Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: isLoading.value
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const Text(
                                            "Next",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                              nameController.text =
                                  nameController.text + emoji.emoji;
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
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
