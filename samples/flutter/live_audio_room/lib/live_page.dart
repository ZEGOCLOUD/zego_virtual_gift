// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';

import 'constant.dart';
import 'gift/components/play_widget.dart';
import 'gift/grid.dart';
import 'gift/manager.dart';

class LivePage extends StatefulWidget {
  final String roomID;
  final bool isHost;

  const LivePage({
    Key? key,
    required this.roomID,
    this.isHost = false,
  }) : super(key: key);

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          ZegoUIKitPrebuiltLiveAudioRoom(
            appID: yourAppID,
            appSign: yourAppSign,
            userID: localUserID,
            userName: 'user_$localUserID',
            roomID: widget.roomID,
            config: (widget.isHost
                ? ZegoUIKitPrebuiltLiveAudioRoomConfig.host()
                : ZegoUIKitPrebuiltLiveAudioRoomConfig.audience())
              ..takeSeatIndexWhenJoining = widget.isHost ? 0 : -1
              ..background = Container(
                color: Colors.black.withOpacity(0.5),
              )
              ..foreground = giftForeground()
              ..bottomMenuBarConfig =
                  ZegoBottomMenuBarConfig(maxCount: 5, audienceExtendButtons: [
                giftButton,
              ]),
          ),
        ],
      ),
    );
  }

  Widget get giftButton => ElevatedButton(
        style: ElevatedButton.styleFrom(shape: const CircleBorder()),
        onPressed: () {
          showSoundEffectSheet(context);
        },
        child: const Icon(Icons.blender),
      );

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
}
