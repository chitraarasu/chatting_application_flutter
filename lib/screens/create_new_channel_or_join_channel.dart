import 'package:animations/animations.dart';
import 'package:appwrite/models.dart' as aw;
import 'package:chatting_application/controller/app_write_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/controller.dart';
import '../widget/create_channel.dart';
import '../widget/custom_chip.dart';
import '../widget/join_channel.dart';

enum screen {
  join,
  create,
}

class CreateNewChannelOrJoinChannel extends StatelessWidget {
  const CreateNewChannelOrJoinChannel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var currentScreen = screen.join.obs;
    final aw.User _auth = AWController.to.user.value!;
    HomeController homeController = Get.find();

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
          "Add Channel",
          style: TextStyle(
            color: Colors.black,
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Obx(
              () => Row(
                children: [
                  CustomChip(
                    'Join',
                    Icons.add,
                    currentScreen.value == screen.join,
                    () {
                      currentScreen.value = screen.join;
                    },
                  ),
                  CustomChip(
                    'Create',
                    Icons.create_new_folder,
                    currentScreen.value == screen.create,
                    () {
                      currentScreen.value = screen.create;
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () => PageTransitionSwitcher(
                duration: const Duration(milliseconds: 300),
                reverse: currentScreen.value != screen.join,
                transitionBuilder: (
                  Widget child,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                ) {
                  return SharedAxisTransition(
                    child: child,
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.scaled,
                  );
                },
                child: currentScreen.value == screen.join
                    ? JoinChannel(
                        auth: _auth,
                      )
                    : CreateChannel(
                        auth: _auth,
                        getController: homeController,
                      ),
              ),
            ),
          ),
          // Obx(() {
          //   if (currentScreen.value == screen.join) {
          //     return JoinChannel(
          //       auth: _auth,
          //     );
          //   } else {
          //     return CreateChannel(
          //       auth: _auth,
          //       getController: getController,
          //     );
          //   }
          // })
        ],
      ),
    );
  }
}
