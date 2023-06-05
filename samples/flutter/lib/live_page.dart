// Dart imports:

// Flutter imports:
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

//
import 'package:live_streaming_cohost/constants.dart';

// Package imports:
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:http/http.dart' as http;
import 'gift.dart';

class LivePage extends StatefulWidget {
  final String liveID;
  final bool isHost;
  final String localUserID;

  const LivePage({
    Key? key,
    required this.liveID,
    required this.localUserID,
    this.isHost = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => LivePageState();
}

class LivePageState extends State<LivePage> {
  ZegoUIKitPrebuiltLiveStreamingController? liveController;
  final List<StreamSubscription<dynamic>?> subscriptions = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      subscriptions.add(ZegoUIKit()
          .getSignalingPlugin()
          .getInRoomCommandMessageReceivedEventStream()
          .listen((event) {
        onInRoomCommandMessageReceived(event);
      }));
    });
  }

  @override
  void dispose() {
    super.dispose();

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hostConfig = ZegoUIKitPrebuiltLiveStreamingConfig.host(
      plugins: [ZegoUIKitSignalingPlugin()],
    );

    final giftButton = ZegoMenuBarExtendButton(
      index: 0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(shape: const CircleBorder()),
        onPressed: () {
          sendGift();
        },
        child: const Icon(Icons.blender),
      ),
    );

    final audienceConfig = ZegoUIKitPrebuiltLiveStreamingConfig.audience(
      plugins: [ZegoUIKitSignalingPlugin()],
    )
      ..bottomMenuBarConfig.coHostExtendButtons = [giftButton]
      ..bottomMenuBarConfig.audienceExtendButtons = [giftButton];

    return SafeArea(
      child: ZegoUIKitPrebuiltLiveStreaming(
        appID: yourAppID /*input your AppID*/,
        appSign: yourAppSign /*input your AppSign*/,
        userID: localUserID,
        userName: 'user_$localUserID',
        liveID: widget.liveID,
        controller: liveController,
        config: (widget.isHost ? hostConfig : audienceConfig),
      ),
    );
  }

  // if you use unreliable message channel, you need subscription this method.
  void onInRoomCommandMessageReceived(
      ZegoSignalingPluginInRoomCommandMessageReceivedEvent event) {
    final messages = event.messages;

    // You can display different animations according to gift-type
    for (final commandMessage in messages) {
      final senderUserID = commandMessage.senderUserID;
      final message = utf8.decode(commandMessage.message);
      debugPrint('onInRoomCommandMessageReceived: $message');
      if (senderUserID != localUserID) {
        GiftWidget.show(context, "assets/sports-car.svga");
      }
    }
  }

  void sendGift() async {
    final data = json.encode({
      'app_id': yourAppID,
      'server_secret': yourServerSecret,
      'room_id': widget.liveID,
      'user_id': widget.localUserID,
      'user_name': 'user_${widget.localUserID}',
      'gift_type': 1001,
      'gift_count': 1,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    try {
      // const url = 'http://localhost:3000/api/send_gift';
      const url = 'https://zego-virtual-gift.vercel.app/api/send_gift';
      final response = await http.post(Uri.parse(url),
          headers: {'Content-Type': 'application/json'}, body: data);
      if (response.statusCode == 200) {
        GiftWidget.show(context, "assets/sports-car.svga");
      } else {
        debugPrint('[ERROR], Send Gift Fail: ${response.statusCode}');
      }
    } on Exception catch (error) {
      debugPrint("[ERROR], Send Gift Fail, ${error.toString()}");
    }
  }
}
