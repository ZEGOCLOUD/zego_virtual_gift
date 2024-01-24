// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

// Project imports:
import 'constants.dart';
import 'live_page.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  /// Users who use the same liveID can join the same live streaming.
  final liveTextCtrl =
      TextEditingController(text: Random().nextInt(10000).toString());

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      fixedSize: const Size(200, 60),
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User ID:$localUserID'),
            TextFormField(
              controller: liveTextCtrl,
              decoration: const InputDecoration(labelText: 'join a live by id'),
            ),
            const SizedBox(height: 20),
            // click me to navigate to LivePage
            ElevatedButton(
              style: buttonStyle,
              child: const Text('Start a live'),
              onPressed: () {
                if (ZegoUIKitPrebuiltLiveStreamingController()
                    .minimize
                    .isMinimizing) {
                  /// when the application is minimized (in a minimized state),
                  /// disable button clicks to prevent multiple PrebuiltLiveStreaming components from being created.
                  return;
                }

                jumpToLivePage(
                  context,
                  liveID: liveTextCtrl.text,
                  isHost: true,
                );
              },
            ),
            const SizedBox(height: 20),
            // click me to navigate to LivePage
            ElevatedButton(
              style: buttonStyle,
              child: const Text('Watch a live'),
              onPressed: () {
                if (ZegoUIKitPrebuiltLiveStreamingController()
                    .minimize
                    .isMinimizing) {
                  /// when the application is minimized (in a minimized state),
                  /// disable button clicks to prevent multiple PrebuiltLiveStreaming components from being created.
                  return;
                }

                jumpToLivePage(
                  context,
                  liveID: liveTextCtrl.text,
                  isHost: false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void jumpToLivePage(BuildContext context,
      {required String liveID, required bool isHost}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivePage(
          liveID: liveID,
          isHost: isHost,
        ),
      ),
    );
  }
}
