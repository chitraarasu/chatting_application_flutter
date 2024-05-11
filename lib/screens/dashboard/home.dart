import 'package:animations/animations.dart';
import 'package:chatting_application/controller/call_controller.dart';
import 'package:chatting_application/controller/payment_controller.dart';
import 'package:chatting_application/model/caller_model.dart';
import 'package:chatting_application/screens/contacts.dart';
import 'package:chatting_application/screens/create_new_channel_or_join_channel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:gdpr_dialog/gdpr_dialog.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../controller/controller.dart';
import '../../utils/contact_group_clip.dart';
import '../../widget/customMaterialButton.dart';
import '../onboarding/onboarding_page.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  CallModel data = CallModel.fromJson(message.data);
  if (data.type == "call") {
    showCallkitIncoming(const Uuid().v4(), CallModel.fromJson(message.data));
  }
}

Future<void> showCallkitIncoming(String uuid, CallModel data) async {
  final params = CallKitParams(
    id: uuid,
    nameCaller: data.nameCaller,
    appName: 'Jabber',
    avatar: data.avatar,
    handle: data.number,
    type: 0,
    duration: 30000,
    textAccept: 'Accept',
    textDecline: 'Decline',
    missedCallNotification: const NotificationParams(
      showNotification: true,
      isShowCallback: true,
      subtitle: 'Missed call',
      callbackText: 'Call back',
    ),
    // extra: <String, dynamic>{'userId': '1a2b3c4d'},
    // headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
    android: const AndroidParams(
      isCustomNotification: true,
      isShowLogo: false,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#ffffff',
      backgroundUrl: 'assets/app-icon.png',
      actionColor: '#4CAF50',
      textColor: '#000000',
    ),
    // ios: const IOSParams(
    //   iconName: 'CallKitLogo',
    //   handleType: '',
    //   supportsVideo: true,
    //   maximumCallGroups: 2,
    //   maximumCallsPerCallGroup: 1,
    //   audioSessionMode: 'default',
    //   audioSessionActive: true,
    //   audioSessionPreferredSampleRate: 44100.0,
    //   audioSessionPreferredIOBufferDuration: 0.005,
    //   supportsDTMF: true,
    //   supportsHolding: true,
    //   supportsGrouping: false,
    //   supportsUngrouping: false,
    //   ringtonePath: 'system_ringtone_default',
    // ),
  );
  await FlutterCallkitIncoming.showCallkitIncoming(params);
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  HomeController homeController = Get.find();
  CallController callController = Get.find();
  String? _currentUuid;
  late final Uuid _uuid;

  final _fabDimension = 56.0;

  @override
  void initState() {
    GdprDialog.instance.showDialog().then((value) {});
    GdprDialog.instance
        .getConsentStatus()
        .then((value) => print('consent status == $value'));

    Future.delayed(Duration.zero, () async {
      _uuid = const Uuid();
      var preProfileData;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get()
          .then((value) {
        preProfileData = value.data();
      });
      if (preProfileData == null) {
        FirebaseAuth.instance.signOut();
        Get.offAll(const OnBoardingPage(), transition: Transition.fade);
      }
    });
    super.initState();
    requestNotificationPermissions();
    homeController.checkVersion(context);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print(
          'Message title: ${message.notification?.title}, body: ${message.notification?.body}, data: ${message.data}');
      CallModel data = CallModel.fromJson(message.data);

      if (data.type == "call") {
        _currentUuid = _uuid.v4();
        showCallkitIncoming(_currentUuid!, CallModel.fromJson(message.data));
      }
    });

    checkAndNavigationCallingPage();

    initCurrentCall();
    listenerEvent(onEvent);
  }

  Future<dynamic> getCurrentCall() async {
    //check current call from pushkit if possible
    var calls = await FlutterCallkitIncoming.activeCalls();
    if (calls is List) {
      if (calls.isNotEmpty) {
        print('DATA: $calls');
        _currentUuid = calls[0]['id'];
        return calls[0];
      } else {
        _currentUuid = "";
        return null;
      }
    }
  }

  Future<void> checkAndNavigationCallingPage() async {
    var currentCall = await getCurrentCall();
    print(currentCall);
    if (currentCall != null) {
      // callController.join(currentCall!.id!); // todo
    }
  }

  Future<void> requestNotificationPermissions() async {
    final PermissionStatus status = await Permission.notification.request();
    if (status.isGranted) {
      // Notification permissions granted
    } else if (status.isDenied) {
      // Notification permissions denied
    } else if (status.isPermanentlyDenied) {
      // Notification permissions permanently denied, open app settings
      await openAppSettings();
    }
    await homeController.getContacts();
  }

  RxBool isFavTabVisible = RxBool(false);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      // backgroundColor: const Color(0xFFfcfcfc),
      // body: GetBuilder<Controller>(
      //   builder: (controller) => controller.body,
      // ),
      body: GestureDetector(
        onTap: () {
          if (isFavTabVisible.value) {
            isFavTabVisible.value = false;
          }
        },
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            GetBuilder<HomeController>(
              builder: (controller) => PageTransitionSwitcher(
                transitionBuilder: (
                  Widget child,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                ) {
                  return FadeThroughTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    child: child,
                  );
                },
                child: controller.body,
              ),
            ),
            Visibility(
              visible: MediaQuery.of(context).viewInsets.bottom == 0.0,
              child: Obx(
                () => AnimatedPositioned(
                  bottom: isFavTabVisible.value ? 0 : -40,
                  duration: Duration(milliseconds: 250),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: _fabDimension / 2 + 10),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 250),
                      height: isFavTabVisible.value ? 210 : 0,
                      width: isFavTabVisible.value ? width * .55 : 0,
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 250),
                        opacity: isFavTabVisible.value ? 1 : 0,
                        child: Column(
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  PaymentController.to.openPayWall();
                                },
                                child: Container(
                                  width:
                                      (width * 0.7142857142857143).toDouble(),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.white,
                                    border: Border.all(
                                      width: 2,
                                      color: Color(0xFFBDA36B),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 3,
                                        blurRadius: 3,
                                        offset: Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Image(
                                              image: AssetImage(
                                                  "assets/images/crown.png"),
                                              width: 25,
                                              color: Color(0xFFBDA36B),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              "Upgrade to Premium for an Ad-Free Experience!",
                                              style: TextStyle(
                                                color: Color(0xFFBDA36B),
                                                fontWeight: FontWeight.w600,
                                                wordSpacing: 0,
                                                fontSize: 15,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Flexible(
                              child: CustomPaint(
                                size: Size(width,
                                    (width * 0.7142857142857143).toDouble()),
                                painter: RPSCustomPainter(),
                                child: Row(
                                    children: [
                                  {
                                    "id": 0,
                                    "title": "Contact",
                                    "icon": "contacts.png"
                                  },
                                  {
                                    "id": 1,
                                    "title": "Group",
                                    "icon": "people.png",
                                  }
                                ]
                                        .map((item) => Expanded(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child:
                                                        SingleChildScrollView(
                                                      child: OpenContainer(
                                                        transitionType:
                                                            ContainerTransitionType
                                                                .fade,
                                                        openBuilder:
                                                            (BuildContext
                                                                    context,
                                                                VoidCallback
                                                                    _) {
                                                          if (item["id"] == 0) {
                                                            return Contacts(
                                                                "chat");
                                                          } else {
                                                            return const CreateNewChannelOrJoinChannel();
                                                          }
                                                        },
                                                        openElevation: 0,
                                                        closedElevation: 0,
                                                        closedColor:
                                                            Colors.transparent,
                                                        onClosed: (data) {
                                                          isFavTabVisible
                                                              .value = false;
                                                        },
                                                        closedBuilder: (BuildContext
                                                                context,
                                                            VoidCallback
                                                                openContainer) {
                                                          return Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Image(
                                                                image: AssetImage(
                                                                    "assets/images/${item["icon"]}"),
                                                                width: 45,
                                                              ),
                                                              SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                item["title"]
                                                                    .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              )
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  if (item["id"] == 0)
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 15),
                                                      child: DottedLine(
                                                        direction:
                                                            Axis.vertical,
                                                        lineLength:
                                                            double.infinity,
                                                        lineThickness: 2.0,
                                                        dashLength: 10.0,
                                                        dashColor:
                                                            Color(0xFF86898f),
                                                        dashGapLength: 6.0,
                                                      ),
                                                    )
                                                ],
                                              ),
                                            ))
                                        .toList()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Visibility(
        visible: MediaQuery.of(context).viewInsets.bottom == 0.0,
        // child: FloatingActionButton(
        //   onPressed: () {
        //     Get.to(() => const CreateNewChannelOrJoinChannel());
        //   },
        //   backgroundColor: const Color(0xFF006aff),
        //   child: const Icon(Icons.edit),
        // ),
        child: GestureDetector(
          onTap: () {
            isFavTabVisible.value = !isFavTabVisible.value;
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF006aff),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 3,
                  blurRadius: 3,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: SizedBox(
              height: _fabDimension,
              width: _fabDimension,
              child: Center(
                child: Obx(
                  () => Icon(
                    isFavTabVisible.value ? Icons.clear : Icons.add,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget get bottomNavigationBar {
    var mediaData = MediaQuery.of(context).size;
    return GetBuilder<HomeController>(
      builder: (controller) => BottomAppBar(
        padding: EdgeInsets.zero,
        height: 60,
        clipBehavior: Clip.hardEdge,
        elevation: 0,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 7.5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomMaterialButton(() {
              controller.setScreen(0);
            }, controller.index == 0, Icons.messenger, "Chats"),
            // CustomMaterialButton(() {
            //   controller.setScreen(1);
            // }, controller.index == 1, Icons.music_note_rounded, "Music"),
            // SizedBox(
            //   width: mediaData.width * .05,
            // ),
            // CustomMaterialButton(() {
            //   controller.setScreen(2);
            // }, controller.index == 2, Icons.newspaper_rounded, "News"),
            CustomMaterialButton(() {
              controller.setScreen(3);
            }, controller.index == 3, Icons.account_box_rounded, "Profile"),
          ],
        ),
      ),
    );
  }

  // Call Flow

  Future<dynamic> initCurrentCall() async {
    // await requestNotificationPermission();
    //check current call from pushkit if possible
    var calls = await FlutterCallkitIncoming.activeCalls();
    if (calls is List) {
      if (calls.isNotEmpty) {
        print('DATA: $calls');
        _currentUuid = calls[0]['id'];
        return calls[0];
      } else {
        _currentUuid = "";
        return null;
      }
    }
  }

  Future<void> endCurrentCall() async {
    initCurrentCall();
    await FlutterCallkitIncoming.endCall(_currentUuid!);
  }

  // Future<void> startOutGoingCall() async {
  //   _currentUuid = _uuid.v4();
  //   final params = CallKitParams(
  //     id: _currentUuid,
  //     nameCaller: 'Hien Nguyen',
  //     handle: '0123456789',
  //     type: 1,
  //     extra: <String, dynamic>{'userId': '1a2b3c4d'},
  //     // ios: const IOSParams(handleType: 'number'),
  //   );
  //   await FlutterCallkitIncoming.startCall(params);
  // }

  Future<void> activeCalls() async {
    var calls = await FlutterCallkitIncoming.activeCalls();
    print(calls);
  }

  Future<void> endAllCalls() async {
    await FlutterCallkitIncoming.endAllCalls();
  }

  Future<void> getDevicePushTokenVoIP() async {
    var devicePushTokenVoIP =
        await FlutterCallkitIncoming.getDevicePushTokenVoIP();
    print(devicePushTokenVoIP);
  }

  Future<void> listenerEvent(void Function(CallEvent) callback) async {
    try {
      FlutterCallkitIncoming.onEvent.listen((event) async {
        print('HOME: $event');
        switch (event!.event) {
          case Event.actionCallIncoming:
            // TODO: received an incoming call
            break;
          case Event.actionCallStart:
            // TODO: started an outgoing call
            // TODO: show screen calling in Flutter
            break;
          case Event.actionCallAccept:
            // TODO: accepted an incoming call
            // TODO: show screen calling in Flutter
            // Get.to(() => Jitsi(event.body));
            print("sdkcmlks");
            print(event.body);
            callController.join(event.body!["id"]);
            break;
          case Event.actionCallDecline:
            // TODO: declined an incoming call
            //   await requestHttp("ACTION_CALL_DECLINE_FROM_DART");
            break;
          case Event.actionCallEnded:
            // TODO: ended an incoming/outgoing call
            break;
          case Event.actionCallTimeout:
            // TODO: missed an incoming call
            break;
          case Event.actionCallCallback:
            // TODO: only Android - click action `Call back` from missed call notification
            break;
          case Event.actionCallToggleHold:
            // TODO: only iOS
            break;
          case Event.actionCallToggleMute:
            // TODO: only iOS
            break;
          case Event.actionCallToggleDmtf:
            // TODO: only iOS
            break;
          case Event.actionCallToggleGroup:
            // TODO: only iOS
            break;
          case Event.actionCallToggleAudioSession:
            // TODO: only iOS
            break;
          case Event.actionDidUpdateDevicePushTokenVoip:
            // TODO: only iOS
            break;
          case Event.actionCallCustom:
            break;
        }
        callback(event);
      });
    } on Exception catch (e) {
      print(e);
    }
  }

  //check with https://webhook.site/#!/2748bc41-8599-4093-b8ad-93fd328f1cd2
  // Future<void> requestHttp(content) async {
  //   get(Uri.parse(
  //       'https://webhook.site/2748bc41-8599-4093-b8ad-93fd328f1cd2?data=$content'));
  // }

  void onEvent(CallEvent event) {
    if (!mounted) return;
    print("Event - ${event}");
  }
}
