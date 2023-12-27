import 'package:flutter/material.dart';

import 'package:svgaplayer_flutter/parser.dart';
import 'package:svgaplayer_flutter/player.dart';
import 'package:svgaplayer_flutter/proto/svga.pb.dart';

import 'cache.dart';
import 'player.dart';

class GiftPlayerWidget extends StatefulWidget {
  const GiftPlayerWidget({
    Key? key,
    required this.onPlayEnd,
    required this.data,
  }) : super(key: key);

  final VoidCallback onPlayEnd;
  final GiftPlayerData data;

  @override
  State<GiftPlayerWidget> createState() => GiftPlayerWidgetState();
}

class GiftPlayerWidgetState extends State<GiftPlayerWidget>
    with SingleTickerProviderStateMixin {
  SVGAAnimationController? animationController;

  final loadedNotifier = ValueNotifier<bool>(false);
  late Future<MovieEntity> movieEntity;

  @override
  void initState() {
    super.initState();

    debugPrint('load ${widget.data} begin:${DateTime.now().toString()}');
    switch (widget.data.source) {
      case GiftPlayerSource.url:
        ZegoGiftCache()
            .readFromURL(url: widget.data.value as String? ?? '')
            .then((byteData) {
          movieEntity = SVGAParser.shared.decodeFromBuffer(byteData);

          loadedNotifier.value = true;
          setState(() {});
        });
        break;
      case GiftPlayerSource.asset:
        ZegoGiftCache()
            .readFromAsset(assetPath: widget.data.value as String? ?? '')
            .then((byteData) {
          movieEntity = SVGAParser.shared.decodeFromBuffer(byteData);

          loadedNotifier.value = true;
          setState(() {});
        });
        break;
      case GiftPlayerSource.bytes:
        movieEntity = SVGAParser.shared
            .decodeFromBuffer(widget.data.value as List<int>? ?? []);

        loadedNotifier.value = true;
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

        debugPrint('load ${widget.data} done:${DateTime.now().toString()}');

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
