import 'package:flutter/material.dart';
import 'package:live_streaming_cohost/gift/manager.dart';

import 'components/play_widget.dart';
import 'defines.dart';

class ZegoGiftPlayer extends StatefulWidget {
  const ZegoGiftPlayer({
    Key? key,
  }) : super(key: key);

  @override
  State<ZegoGiftPlayer> createState() => ZegoGiftPlayerState();
}

class ZegoGiftPlayerState extends State<ZegoGiftPlayer> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ZegoGiftItem?>(
      valueListenable: ZegoGiftManager().playList.playingDataNotifier,
      builder: (context, giftData, _) {
        if (null == giftData) {
          return const SizedBox.shrink();
        }

        return ZegoGiftPlayerWidget(
          key: UniqueKey(),
          giftData: giftData,
          onPlayEnd: () {
            ZegoGiftManager().playList.next();
          },
        );
      },
    );
  }
}
