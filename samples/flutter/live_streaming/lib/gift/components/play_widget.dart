import 'package:flutter/material.dart';
import 'package:live_streaming_cohost/gift/manager.dart';

import 'package:svgaplayer_flutter/parser.dart';
import 'package:svgaplayer_flutter/player.dart';
import 'package:svgaplayer_flutter/proto/svga.pb.dart';

import '../defines.dart';

class ZegoGiftPlayerWidget extends StatefulWidget {
  const ZegoGiftPlayerWidget({
    Key? key,
    required this.onPlayEnd,
    required this.giftData,
  }) : super(key: key);

  final VoidCallback onPlayEnd;
  final ZegoGiftItem giftData;

  @override
  State<ZegoGiftPlayerWidget> createState() => ZegoGiftPlayerWidgetState();
}

class ZegoGiftPlayerWidgetState extends State<ZegoGiftPlayerWidget>
    with SingleTickerProviderStateMixin {
  SVGAAnimationController? animationController;

  final loadedNotifier = ValueNotifier<bool>(false);
  late Future<MovieEntity> movieEntity;

  @override
  void initState() {
    super.initState();

    debugPrint('load ${widget.giftData} begin:${DateTime.now().toString()}');
    switch (widget.giftData.source) {
      case ZegoGiftSource.url:
        ZegoGiftManager()
            .cache
            .readFromURL(url: widget.giftData.sourceURL)
            .then((byteData) {
          movieEntity = SVGAParser.shared.decodeFromBuffer(byteData);

          loadedNotifier.value = true;
          setState(() {});
        });
        break;
      case ZegoGiftSource.asset:
        ZegoGiftManager()
            .cache
            .readFromAsset(widget.giftData.sourceURL)
            .then((byteData) {
          movieEntity = SVGAParser.shared.decodeFromBuffer(byteData);

          loadedNotifier.value = true;
          setState(() {});
        });
        break;
    }
  }

  @override
  void dispose() {
    if (animationController?.isAnimating ?? false) {
      animationController?.stop();
      widget.onPlayEnd();
    }

    animationController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: loadedNotifier,
      builder: (context, isLoaded, _) {
        if (!isLoaded) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.red,
            ),
          );
        }

        debugPrint('load ${widget.giftData} done:${DateTime.now().toString()}');

        return FutureBuilder<MovieEntity>(
          future: movieEntity,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              animationController ??= (SVGAAnimationController(vsync: this)
                ..videoItem = snapshot.data as MovieEntity
                ..forward().whenComplete(() {
                  widget.onPlayEnd();
                }));
              return SVGAImage(animationController!);
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        );
      },
    );
  }
}
