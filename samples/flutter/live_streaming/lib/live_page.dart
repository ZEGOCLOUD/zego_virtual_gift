import 'package:flutter/material.dart';

import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'constants.dart';

import 'gift/grid.dart';
import 'gift/player.dart';
import 'gift/player_overlay.dart';
import 'gift/service.dart';

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

  ZegoGiftService get giftService => ZegoGiftService();

  @override
  void initState() {
    super.initState();

    giftService.recvNotifier.addListener(onGiftReceived);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //  todo
      giftService.init(
        appID: yourAppID,
        appSecret: yourServerSecret,
        liveID: widget.liveID,
        localUserID: widget.localUserID,
        localUserName: 'user_${widget.localUserID}',
      );
    });
  }

  @override
  void dispose() {
    super.dispose();

    giftService.recvNotifier.removeListener(onGiftReceived);
    giftService.uninit();
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
          showSoundEffectSheet(context);
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
        config: (widget.isHost ? hostConfig : audienceConfig)
          ..foreground = const Stack(
            children: [
              GiftPlayerOverlay(),
            ],
          )
          ..onLiveStreamingStateUpdate = (state) {
            if (ZegoLiveStreamingState.idle == state) {
              ZegoGiftPlayer().clear();
            }
          },
      ),
    );
  }

  void onGiftReceived() {
    final giftData = giftService.recvNotifier.value ?? ZegoGiftData.empty();
    // ZegoGiftPlayer().play(
    //   context,
    //   giftData,
    // );
  }
}
