import 'package:flutter/material.dart';
import 'package:live_streaming_cohost/gift/defines.dart';
import 'package:live_streaming_cohost/gift/manager.dart';
import 'package:live_streaming_cohost/gift/mp4_player_manager.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class ZegoMp4PlayerWidget extends StatefulWidget {
  const ZegoMp4PlayerWidget(
      {Key? key,
      required this.onPlayEnd,
      required this.playData,
      this.size,
      this.textStyle})
      : super(key: key);

  final VoidCallback onPlayEnd;
  final PlayData playData;

  /// restrict the display area size for the gift animation
  final Size? size;

  /// the gift count text style
  final TextStyle? textStyle;

  @override
  State<ZegoMp4PlayerWidget> createState() => ZegoMp4PlayerWidgetState();
}

class ZegoMp4PlayerWidgetState extends State<ZegoMp4PlayerWidget>
    with SingleTickerProviderStateMixin {
  Widget? _mediaPlayerWidget;

  double get fontSize => 15;

  Size get displaySize => null != widget.size
      ? Size(
          (widget.size!.width) -
              widget.playData.count.toString().length * fontSize,
          widget.size!.height,
        )
      : MediaQuery.of(context).size;

  Size get countSize => Size(
        (widget.playData.count.toString().length + 2) * fontSize * 1.2,
        fontSize + 2,
      );

  @override
  void initState() {
    super.initState();

    debugPrint('load ${widget.playData} begin:${DateTime.now().toString()}');
    Mp4PlayerManager().registerCallbacks(
      onMediaPlayerStateUpdate: (state, errorCode) {
        if (!context.mounted) {
          return;
        }

        debugPrint('Media Player State: $state');
        switch (state) {
          case ZegoMediaPlayerState.NoPlay:
            break;
          case ZegoMediaPlayerState.Playing:
            setState(() {});
            break;
          case ZegoMediaPlayerState.Pausing:
            break;
          case ZegoMediaPlayerState.PlayEnded:
            Mp4PlayerManager().unregisterCallbacks();
            Mp4PlayerManager().clearView();
            widget.onPlayEnd();
            break;
        }
      },
      onMediaPlayerFirstFrameEvent: (event) {
        debugPrint('onMediaPlayerFirstFrameEvent, $event');
        if (event == ZegoMediaPlayerFirstFrameEvent.VideoRendered) {}
      },
    );

    Mp4PlayerManager()
        .createMediaPlayer(reusePlayerView: true)
        .then((view) async {
      _mediaPlayerWidget = view;
      var url = await ZegoGiftManager()
          .cache
          .getFilePathFromCache(widget.playData.giftItem.sourceURL);
      url ??= widget.playData.giftItem.sourceURL;
      Mp4PlayerManager()
          .loadResource(url, layoutType: ZegoAlphaLayoutType.Left)
          .then((value) {
        Mp4PlayerManager().startMediaPlayer();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final countWidget = widget.playData.count > 1
        ? SizedBox.fromSize(
            size: countSize,
            child: Text(
              'x ${widget.playData.count}',
              style: widget.textStyle ??
                  TextStyle(
                    fontSize: fontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          )
        : const SizedBox.shrink();

    if (displaySize.width < MediaQuery.of(context).size.width) {
      /// width < 1/2
      return Row(
        children: [
          SizedBox.fromSize(
            size: displaySize,
            child: _mediaPlayerWidget,
          ),
          countWidget,
        ],
      );
    }

    return SizedBox.fromSize(
      size: displaySize,
      child: Stack(children: [
        Center(
          child: SizedBox.fromSize(
            size: displaySize,
            child: _mediaPlayerWidget,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: countWidget,
        ),
      ]),
    );
  }
}
