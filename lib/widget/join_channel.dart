import 'dart:io';

import 'package:appwrite/models.dart' as aw;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class JoinChannel extends StatefulWidget {
  JoinChannel({
    Key? key,
    required aw.User auth,
  })  : _auth = auth,
        super(key: key);

  final aw.User _auth;

  @override
  State<JoinChannel> createState() => _JoinChannelState();
}

class _JoinChannelState extends State<JoinChannel> {
  TextEditingController channelId = TextEditingController();

  var isLoading = false.obs;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? _controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller!.pauseCamera();
    } else if (Platform.isIOS) {
      _controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      joinChannel(result?.code);
    });
  }

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
            .doc(widget._auth.$id)
            .get()
            .then((data) async {
          List userChannels = data["userChannels"] ?? [];

          await FirebaseFirestore.instance
              .collection("users")
              .doc(widget._auth.$id)
              .update({
            "userChannels": [item["channelId"], ...userChannels]
          });

          await FirebaseFirestore.instance
              .collection("messages")
              .doc(channelId)
              .collection("channelMembers")
              .doc(widget._auth.$id)
              .set({
            'userId': widget._auth.$id,
          });
        });
      }
    }
    isLoading.value = false;
    if (isValid) {
      Get.back();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  const Text(
                    "Scan to join channel",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                      overlay: QrScannerOverlayShape(
                        overlayColor: Colors.white,
                        borderLength: 20,
                        borderWidth: 4,
                        borderRadius: 15,
                        borderColor: const Color(0xFF006aff),
                        cutOutSize: MediaQuery.of(context).size.width * 0.6,
                      ),
                    ),
                  ),
                  Container(
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
                      maxLines: 1,
                      controller: channelId,
                      style: const TextStyle(color: Colors.blueGrey),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(12.5),
                        hintText: 'Enter channel ID',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              try {
                if (!isLoading.value) {
                  if (channelId.text.trim().isNotEmpty) {
                    joinChannel(channelId.text);
                  }
                }
              } catch (error) {
                isLoading.value = false;
              }
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
                          "Join",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
