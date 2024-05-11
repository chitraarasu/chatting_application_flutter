import 'package:chatting_application/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../ads/ad_state.dart';
import '../../controller/payment_controller.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  final isFromInsideApp;

  PrivacyPolicyScreen({this.isFromInsideApp = false});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
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

    return Scaffold(
      backgroundColor: widget.isFromInsideApp ? null : Colors.deepOrange,
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: TextStyle(
              color: widget.isFromInsideApp ? Colors.black : Colors.white),
        ),
        elevation: 0,
        backgroundColor:
            widget.isFromInsideApp ? Colors.white : Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: widget.isFromInsideApp ? Colors.black : Colors.white,
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color:
                  widget.isFromInsideApp ? null : Colors.white.withOpacity(0.9),
              child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Html(data: """<div style="background:#eee;">
              <div class="container">
                  <div class="main-container">
                      <h2 style="margin-top:0;">Jabber Privacy Policy</h2>
                      <div id="content">
                          <p>                   Chitraarasu built the Jabber app as                   an Open Source app. This SERVICE is provided by                   Chitraarasu at no cost and is intended for use as                   is.                 </p> <p>                   This page is used to inform visitors regarding my                   policies with the collection, use, and disclosure of Personal                   Information if anyone decided to use my Service.                 </p> <p>                   If you choose to use my Service, then you agree to                   the collection and use of information in relation to this                   policy. The Personal Information that I collect is                   used for providing and improving the Service. I will not use or share your information with                   anyone except as described in this Privacy Policy.                 </p> <p>                   The terms used in this Privacy Policy have the same meanings                   as in our Terms and Conditions, which are accessible at                   Jabber unless otherwise defined in this Privacy Policy.                 </p> <p><strong>Information Collection and Use</strong></p> <p>                   For a better experience, while using our Service, I                   may require you to provide us with certain personally                   identifiable information. The information that                   I request will be retained on your device and is not collected by me in any way.                 </p> <div><p>                     The app does use third-party services that may collect                     information used to identify you.                   </p> <p>                     Link to the privacy policy of third-party service providers used                     by the app                   </p> <ul><li><a href="https://www.google.com/policies/privacy/" target="_blank" rel="noopener noreferrer">Google Play Services</a></li><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----></ul></div> <p><strong>Log Data</strong></p> <p>                   I want to inform you that whenever you                   use my Service, in a case of an error in the app                   I collect data and information (through third-party                   products) on your phone called Log Data. This Log Data may                   include information such as your device Internet Protocol                   (“IP”) address, device name, operating system version, the                   configuration of the app when utilizing my Service,                   the time and date of your use of the Service, and other                   statistics.                 </p> <p><strong>Cookies</strong></p> <p>                   Cookies are files with a small amount of data that are                   commonly used as anonymous unique identifiers. These are sent                   to your browser from the websites that you visit and are                   stored on your device's internal memory.                 </p> <p>                   This Service does not use these “cookies” explicitly. However,                   the app may use third-party code and libraries that use                   “cookies” to collect information and improve their services.                   You have the option to either accept or refuse these cookies                   and know when a cookie is being sent to your device. If you                   choose to refuse our cookies, you may not be able to use some                   portions of this Service.                 </p> <p><strong>Service Providers</strong></p> <p>                   I may employ third-party companies and                   individuals due to the following reasons:                 </p> <ul><li>To facilitate our Service;</li> <li>To provide the Service on our behalf;</li> <li>To perform Service-related services; or</li> <li>To assist us in analyzing how our Service is used.</li></ul> <p>                   I want to inform users of this Service                   that these third parties have access to their Personal                   Information. The reason is to perform the tasks assigned to                   them on our behalf. However, they are obligated not to                   disclose or use the information for any other purpose.                 </p> <p><strong>Security</strong></p> <p>                   I value your trust in providing us your                   Personal Information, thus we are striving to use commercially                   acceptable means of protecting it. But remember that no method                   of transmission over the internet, or method of electronic                   storage is 100% secure and reliable, and I cannot                   guarantee its absolute security.                 </p> <p><strong>Links to Other Sites</strong></p> <p>                   This Service may contain links to other sites. If you click on                   a third-party link, you will be directed to that site. Note                   that these external sites are not operated by me.                   Therefore, I strongly advise you to review the                   Privacy Policy of these websites. I have                   no control over and assume no responsibility for the content,                   privacy policies, or practices of any third-party sites or                   services.                 </p> <p><strong>Children’s Privacy</strong></p> <div><p>                     These Services do not address anyone under the age of 13.                     I do not knowingly collect personally                     identifiable information from children under 13 years of age. In the case                     I discover that a child under 13 has provided                     me with personal information, I immediately                     delete this from our servers. If you are a parent or guardian                     and you are aware that your child has provided us with                     personal information, please contact me so that                     I will be able to do the necessary actions.                   </p></div> <!----> <p><strong>Changes to This Privacy Policy</strong></p> <p>                   I may update our Privacy Policy from                   time to time. Thus, you are advised to review this page                   periodically for any changes. I will                   notify you of any changes by posting the new Privacy Policy on                   this page.                 </p> <p>This policy is effective as of 2023-06-10</p> <p><strong>Contact Us</strong></p> <p>                   If you have any questions or suggestions about my                   Privacy Policy, do not hesitate to contact me at kchitraarasu@gmail.com.                 </p> <p>This privacy policy page was created at <a href="https://privacypolicytemplate.net" target="_blank" rel="noopener noreferrer">privacypolicytemplate.net </a>and modified/generated by <a href="https://app-privacy-policy-generator.nisrulz.com/" target="_blank" rel="noopener noreferrer">App Privacy Policy Generator</a></p>
                      </div>
                  </div>

              </div>
          </div>""", style: {
                    // "h2": Style(color: Colors.deepOrange),
                    // "strong": Style(color: Colors.deepOrange),
                    "div": Style(color: Colors.black),
                    "hr": Style(color: Colors.black),
                    "a": Style(color: Colors.blue),
                  })),
            ),
          ),
          homeController.getAdsWidget(),
        ],
      ),
    );
  }
}
