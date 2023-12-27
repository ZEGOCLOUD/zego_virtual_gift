import 'package:flutter/material.dart';

import 'play_widget.dart';
import 'player.dart';

class GiftPlayerOverlay extends StatefulWidget {
  const GiftPlayerOverlay({
    Key? key,
  }) : super(key: key);

  @override
  State<GiftPlayerOverlay> createState() => GiftPlayerOverlayState();
}

class GiftPlayerOverlayState extends State<GiftPlayerOverlay> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GiftPlayerData?>(
      valueListenable: ZegoGiftPlayer().playingDataNotifier,
      builder: (context, playData, _) {
        if (null == playData) {
          return const SizedBox.shrink();
        }

        return GiftPlayerWidget(
          key: UniqueKey(),
          data: playData,
          onPlayEnd: () {
            ZegoGiftPlayer().next();
          },
        );
      },
    );
  }
}
