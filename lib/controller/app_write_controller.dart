import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AWController extends GetxController {
  static AWController to = Get.find();

  Client client = Client();
  late Account account;
  Rxn<User> user = Rxn();

  @override
  void onInit() {
    super.onInit();

    client
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject('66a4ff02003c6e678fe4')
        .setSelfSigned(status: true);
    account = Account(client);
  }

  Future<User?> getUser() async {
    try {
      user.value = await account.get();
    } catch (e) {
      user.value = null;
    }
    return user.value;
  }

  Future loginWithNumber(
      String s, context, Function(Token) onDone, Function() onError) async {
    try {
      final token = await account.createPhoneToken(
        userId: ID.unique(),
        phone: s,
      );
      onDone(token);
    } on AppwriteException catch (e) {
      onError();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("${e.message}")));
    } catch (e) {
      onError();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Something went wrong! Please try again later.")));
      rethrow;
    }
  }

  Future verifyOTP({
    required Token verToken,
    required String otp,
    context,
    required Function(Session) onDone,
    required Function() onError,
  }) async {
    try {
      final session = await account.updatePhoneSession(
        userId: verToken.userId,
        secret: otp,
      );
      getUser();
      onDone(session);
    } on AppwriteException catch (e) {
      print(e.message);
      onError();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("${e.message}")));
    } catch (e) {
      onError();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Something went wrong! Please try again later.")));
      rethrow;
    }
  }

  Future logout() async {
    await account.deleteSessions();
    user.value = null;
  }
}
