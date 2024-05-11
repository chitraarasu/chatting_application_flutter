import 'package:chatting_application/screens/onboarding/privacy_policy.dart';
import 'package:chatting_application/screens/onboarding/user_profile_input_screen.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:rive/rive.dart';

import '../../controller/controller.dart';

enum screen {
  number,
  otp,
}

class PhoneNumberAndOtp extends StatefulWidget {
  const PhoneNumberAndOtp({Key? key}) : super(key: key);

  @override
  State<PhoneNumberAndOtp> createState() => _PhoneNumberAndOtpState();
}

class _PhoneNumberAndOtpState extends State<PhoneNumberAndOtp> {
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  RiveAnimationController? _controller;
  RiveAnimationController? _controller1;
  RiveAnimationController? _controller2;
  bool _isPlaying = false;
  bool _isPlaying1 = false;
  bool _isPlaying2 = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  var verificationId;

  @override
  void dispose() {
    // phoneNumberController.dispose();
    // otpTextEditingController.dispose();
    _controller!.dispose();
    _controller1!.dispose();
    _controller2!.dispose();
    super.dispose();
  }

  // late OTPTextEditController controller;

  getPrivacyPolicy() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            const TextSpan(
              text: 'By logging in, you are accepting our ',
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFFb8bbc4),
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: '\nPrivacy Policy.',
              style: const TextStyle(
                fontSize: 12.5,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Get.to(
                    () => PrivacyPolicyScreen(),
                    transition: Transition.fadeIn,
                  );
                },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = OneShotAnimation(
      'Look_down_right',
      autoplay: false,
      onStop: () => setState(() => _isPlaying = false),
      onStart: () => setState(() => _isPlaying = true),
    );
    _controller1 = OneShotAnimation(
      'success',
      autoplay: false,
      onStop: () => setState(() => _isPlaying1 = false),
      onStart: () => setState(() => _isPlaying1 = true),
    );
    _controller2 = OneShotAnimation(
      'fail',
      autoplay: false,
      onStop: () => setState(() => _isPlaying2 = false),
      onStart: () => setState(() => _isPlaying2 = true),
    );

    // OTPInteractor()
    //     .getAppSignature()
    //     .then((value) => print('signature - $value'));
    // controller = OTPTextEditController(
    //   codeLength: 6,
    //   onCodeReceive: (code) => print('Your Application receive code - $code'),
    // )..startListenUserConsent(
    //     (code) {
    //       final exp = RegExp(r'(\d{6})');
    //       return exp.stringMatch(code ?? '') ?? '';
    //     },
    //   );
  }

  var currentScreen = screen.number.obs;

  Future<void> signInWithPhoneAuthCredentials(
      PhoneAuthCredential phoneAuthCredential) async {
    try {
      final authCredentials =
          await _auth.signInWithCredential(phoneAuthCredential);

      if (authCredentials.user != null) {
        LogInResult result =
            await Purchases.logIn(authCredentials.user?.uid ?? "");
        // print(result.customerInfo);
        Get.to(
            () => UserProfileInputScreen(phoneNumberController.text,
                Get.find<HomeController>().selectedDialogCountry.phoneCode),
            transition: Transition.fadeIn);
      }
    } on FirebaseAuthException catch (error) {
      _isPlaying2 ? null : _controller2?.isActive = true;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("${error.message}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    var mainScreen = false;

    Widget _buildDialogItem(Country country) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          CountryPickerUtils.getDefaultFlagImage(country),
          const SizedBox(width: 8.0),
          Text("+${country.phoneCode}"),
          const SizedBox(width: 8.0),
          if (mainScreen) Flexible(child: Text(country.name))
        ],
      );
    }

    Future _openCountryPickerDialog() {
      mainScreen = true;
      return showDialog(
        context: context,
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(primaryColor: Colors.pink),
          child: CountryPickerDialog(
            titlePadding: const EdgeInsets.all(8.0),
            searchCursorColor: Colors.pinkAccent,
            searchInputDecoration: const InputDecoration(hintText: 'Search...'),
            isSearchable: true,
            title: const Text('Select your phone code'),
            onValuePicked: (Country country) {
              Get.find<HomeController>().setCountry(country);
            },
            itemBuilder: _buildDialogItem,
            priorityList: [
              CountryPickerUtils.getCountryByIsoCode('TR'),
              CountryPickerUtils.getCountryByIsoCode('US'),
            ],
          ),
        ),
      ).then((value) {
        mainScreen = false;
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          currentScreen.value == screen.number
              ? "Phone Number"
              : "Verification",
          style: const TextStyle(
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
      backgroundColor: Colors.deepOrange,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 275,
              child: RiveAnimation.asset(
                "assets/animations/teddy.riv",
                animations: const ['idle', 'curves'],
                controllers: [_controller!, _controller1!, _controller2!],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Obx(
                        () => Text(
                          currentScreen.value == screen.number
                              ? "Step 01/03"
                              : "Step 02/03",
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFFb8bbc4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Obx(
                        () => currentScreen.value == screen.number
                            ? Column(
                                children: [
                                  const Text(
                                    "Your phone number",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text(
                                    "We'll send you a code to your phone number",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFFb8bbc4),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 20,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: const Color(0xFFb8bbc4),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: _openCountryPickerDialog,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  border: Border.all(
                                                    color:
                                                        const Color(0xFFb8bbc4),
                                                    width: 1,
                                                  ),
                                                ),
                                                child:
                                                    GetBuilder<HomeController>(
                                                  init: HomeController(),
                                                  builder: (chatController) =>
                                                      _buildDialogItem(
                                                          chatController
                                                              .selectedDialogCountry),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Expanded(
                                            child: TextField(
                                              controller: phoneNumberController,
                                              // focusNode: phoneNumberFocusNode,
                                              decoration: const InputDecoration(
                                                contentPadding: EdgeInsets.zero,
                                                border: InputBorder.none,
                                                hintText: "Phone number",
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (val) {
                                                _isPlaying
                                                    ? null
                                                    : _controller?.isActive =
                                                        true;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GetBuilder<HomeController>(
                                    builder: (getController) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20,
                                        horizontal: 70,
                                      ),
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all(
                                              const EdgeInsets.all(20.0)),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.blue),
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(35.0),
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          FocusScope.of(context).unfocus();
                                          if (!getController.isLoading) {
                                            getController.setIsLoading(true);
                                            if (phoneNumberController
                                                        .text.length <
                                                    10 ||
                                                phoneNumberController
                                                        .text.length >
                                                    10) {
                                              _isPlaying2
                                                  ? null
                                                  : _controller2?.isActive =
                                                      true;
                                              getController.setIsLoading(false);
                                            } else {
                                              _isPlaying1
                                                  ? null
                                                  : _controller1?.isActive =
                                                      true;
                                              HomeController homeController =
                                                  Get.find();
                                              final phno =
                                                  "+${homeController.selectedDialogCountry.phoneCode}${phoneNumberController.text}";
                                              await _auth.verifyPhoneNumber(
                                                phoneNumber: phno,
                                                verificationCompleted:
                                                    (verificationCompleted) async {
                                                  getController
                                                      .setIsLoading(false);
                                                },
                                                verificationFailed:
                                                    (verificationFailed) async {
                                                  _isPlaying2
                                                      ? null
                                                      : _controller2?.isActive =
                                                          true;
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              "${verificationFailed.message}")));
                                                  getController
                                                      .setIsLoading(false);
                                                },
                                                codeSent: (verificationToken,
                                                    resendToken) async {
                                                  currentScreen.value =
                                                      screen.otp;
                                                  verificationId =
                                                      verificationToken;
                                                  getController
                                                      .setIsLoading(false);
                                                },
                                                codeAutoRetrievalTimeout:
                                                    (codeAutoRetrievalTimeout) async {
                                                  getController
                                                      .setIsLoading(false);
                                                },
                                              );
                                            }
                                          }
                                        },
                                        child: getController.isLoading == true
                                            ? SizedBox(
                                                width: 30,
                                                height: 30,
                                                child:
                                                    const CircularProgressIndicator(
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: const [
                                                  Text(
                                                    "Send code",
                                                    style: TextStyle(
                                                      fontSize: 22,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.send_rounded,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  const Text(
                                    "Verifying your number",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  GetBuilder<HomeController>(
                                    builder: (getController) => Center(
                                      child: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'Enter the otp sent to ',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Color(0xFFb8bbc4),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  '+${getController.selectedDialogCountry.phoneCode} ${phoneNumberController.text.substring(0, 5)} ${phoneNumberController.text.substring(5)}.',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Get.back();
                                    },
                                    child: const Text(
                                      'Wrong number?',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: PinCodeTextField(
                                      length: 6,
                                      obscureText: true,
                                      keyboardType: TextInputType.number,
                                      animationType: AnimationType.fade,
                                      pinTheme: PinTheme(
                                        shape: PinCodeFieldShape.box,
                                        borderRadius: BorderRadius.circular(5),
                                        fieldHeight: 50,
                                        fieldWidth: 40,
                                        inactiveColor: Colors.orange,
                                        inactiveFillColor: Colors.orange,
                                        activeFillColor: Colors.white,
                                        selectedColor: const Color(0xFFd6e2ea),
                                        selectedFillColor:
                                            const Color(0xFFd6e2ea),
                                      ),
                                      animationDuration:
                                          Duration(milliseconds: 300),
                                      enableActiveFill: true,
                                      // errorAnimationController: errorController,
                                      controller: otpController,
                                      onCompleted: (v) {
                                        print(otpController.text);
                                      },
                                      onChanged: (value) {},
                                      beforeTextPaste: (text) {
                                        return true;
                                      },
                                      appContext: context,
                                    ),
                                  ),
                                  GetBuilder<HomeController>(
                                    builder: (getController) => Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all(
                                              const EdgeInsets.symmetric(
                                            horizontal: 40.0,
                                            vertical: 15,
                                          )),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.blue),
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(35.0),
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          if (!getController.isLoading) {
                                            getController.setIsLoading(true);
                                            if (otpController.text.length < 6) {
                                              _isPlaying2
                                                  ? null
                                                  : _controller2?.isActive =
                                                      true;
                                            } else {
                                              _isPlaying1
                                                  ? null
                                                  : _controller1?.isActive =
                                                      true;
                                              PhoneAuthCredential
                                                  phoneAuthCredential =
                                                  PhoneAuthProvider.credential(
                                                      verificationId:
                                                          verificationId,
                                                      smsCode:
                                                          otpController.text);
                                              await signInWithPhoneAuthCredentials(
                                                  phoneAuthCredential);
                                            }
                                            getController.setIsLoading(false);
                                          }
                                        },
                                        child: getController.isLoading == true
                                            ? SizedBox(
                                                width: 30,
                                                height: 30,
                                                child:
                                                    const CircularProgressIndicator(
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Text(
                                                "Verify",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      getPrivacyPolicy(),
                      SizedBox(
                        height: 10,
                      )
                    ],
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
