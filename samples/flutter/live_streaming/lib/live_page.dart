import 'package:flutter/material.dart';
import 'package:live_streaming_cohost/gift/manager.dart';

import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'constants.dart';

import 'gift/grid.dart';
import 'gift/player.dart';

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

  @override
  void initState() {
    super.initState();

    ZegoGiftManager().service.recvNotifier.addListener(onGiftReceived);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //  todo
      ZegoGiftManager().service.init(
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

    ZegoGiftManager().service.recvNotifier.removeListener(onGiftReceived);
    ZegoGiftManager().service.uninit();
  }

  @override
  Widget build(BuildContext context) {
    final hostConfig = ZegoUIKitPrebuiltLiveStreamingConfig.host(
      plugins: [ZegoUIKitSignalingPlugin()],
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
              ZegoGiftPlayer(),
            ],
          )
          ..onLiveStreamingStateUpdate = (state) {
            if (ZegoLiveStreamingState.idle == state) {
              ZegoGiftManager().playList.clear();
            }
          },
      ),
    );
  }

  ZegoMenuBarExtendButton get giftButton => ZegoMenuBarExtendButton(
        index: 0,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(shape: const CircleBorder()),
          onPressed: () {
            showSoundEffectSheet(context);
          },
          child: const Icon(Icons.blender),
        ),
      );

  void onGiftReceived() {
    final giftData = ZegoGiftManager().service.recvNotifier.value ??
        ZegoGiftProtocolItem.empty();

    // ZegoGiftPlayer().play(
    //   context,
    //   giftData,
    // );
  }
}
