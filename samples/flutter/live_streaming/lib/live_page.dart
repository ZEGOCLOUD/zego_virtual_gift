import 'package:flutter/material.dart';
import 'package:live_streaming_cohost/gift/manager.dart';

import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'constants.dart';

import 'gift/components/play_widget.dart';
import 'gift/data.dart';
import 'gift/grid.dart';

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
          ..foreground = giftForeground()
          ..onLiveStreamingStateUpdate = (state) {
            if (ZegoLiveStreamingState.idle == state) {
              ZegoGiftManager().playList.clear();
            }
          },
      ),
    );
  }

  Widget giftForeground() {
    return ValueListenableBuilder<PlayData?>(
      valueListenable: ZegoGiftManager().playList.playingDataNotifier,
      builder: (context, playData, _) {
        if (null == playData) {
          return const SizedBox.shrink();
        }

        /// you can define the area and size for displaying your own
        /// animations here
        int level = 1;
        if (playData.giftItem.weight < 10) {
          level = 1;
        } else if (playData.giftItem.weight < 100) {
          level = 2;
        } else {
          level = 3;
        }
        switch (level) {
          case 2:
            return Positioned(
              top: 100,
              bottom: 100,
              left: 10,
              right: 10,
              child: ZegoGiftPlayerWidget(
                key: UniqueKey(),
                playData: playData,
                onPlayEnd: () {
                  ZegoGiftManager().playList.next();
                },
              ),
            );
          case 3:
            return ZegoGiftPlayerWidget(
              key: UniqueKey(),
              playData: playData,
              onPlayEnd: () {
                ZegoGiftManager().playList.next();
              },
            );
        }
        // level 1
        return Positioned(
          bottom: 200,
          left: 10,
          child: ZegoGiftPlayerWidget(
            key: UniqueKey(),
            size: const Size(100, 100),
            playData: playData,
            onPlayEnd: () {
              /// if there is another gift animation, then play
              ZegoGiftManager().playList.next();
            },
          ),
        );
      },
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
    final receivedGift = ZegoGiftManager().service.recvNotifier.value ??
        ZegoGiftProtocolItem.empty();
    final giftData = queryGiftInItemList(receivedGift.name);
    if (null == giftData) {
      debugPrint('not ${receivedGift.name} exist');
      return;
    }

    ZegoGiftManager().playList.add(PlayData(
          giftItem: giftData,
          count: receivedGift.count,
        ));
  }
}
