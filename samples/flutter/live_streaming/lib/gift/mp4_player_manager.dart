import 'package:flutter/cupertino.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class Mp4PlayerManager {
  static final Mp4PlayerManager _instance = Mp4PlayerManager._internal();
  factory Mp4PlayerManager() {
    return _instance;
  }
  Mp4PlayerManager._internal();

  Widget? _mediaplayerWidget;
  ZegoMediaPlayer? _mediaPlayer;
  int _mediaPlayerViewID = -1;

  /// callbacks
  static void Function(ZegoMediaPlayerState state, int errorCode)?
      onMediaPlayerStateUpdate;
  static void Function(ZegoMediaPlayerFirstFrameEvent event)?
      onMediaPlayerFirstFrameEvent;

  /// create media player
  Future<Widget?> createMediaPlayer({bool reusePlayerView = false}) async {
    _initCallback();

    _mediaPlayer ??= await ZegoExpressEngine.instance.createMediaPlayer();

    if (!reusePlayerView) {
      destroyPlayerView();
    }
    // create or reuse old widget
    if (_mediaPlayerViewID == -1) {
      _mediaplayerWidget =
          await ZegoExpressEngine.instance.createCanvasView((viewID) {
        _mediaPlayerViewID = viewID;
        _mediaPlayer?.setPlayerCanvas(ZegoCanvas(viewID, alphaBlend: true));
      });
    } else {
      _mediaPlayer
          ?.setPlayerCanvas(ZegoCanvas(_mediaPlayerViewID, alphaBlend: true));
    }
    return _mediaplayerWidget;
  }

  void _initCallback() {
    ZegoExpressEngine.onMediaPlayerStateUpdate =
        (mediaPlayer, state, errorCode) {
      onMediaPlayerStateUpdate?.call(state, errorCode);
    };
    ZegoExpressEngine.onMediaPlayerFirstFrameEvent = (mediaPlayer, event) {
      onMediaPlayerFirstFrameEvent?.call(event);
    };
  }

  void destroyMediaPlayer() {
    if (_mediaPlayer != null) {
      ZegoExpressEngine.instance.destroyMediaPlayer(_mediaPlayer!);
      _mediaPlayer = null;
    }
    destroyPlayerView();
  }

  void destroyPlayerView() {
    if (_mediaPlayerViewID != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(_mediaPlayerViewID);
      _mediaPlayerViewID = -1;
    }
  }

  Future<int> loadResource(String url,
      {ZegoAlphaLayoutType layoutType = ZegoAlphaLayoutType.Left}) async {
    debugPrint('Mp4 Player loadResource: $url');
    int ret = -1;
    if (_mediaPlayer != null) {
      ZegoMediaPlayerResource source = ZegoMediaPlayerResource.defaultConfig();
      source.filePath = url;
      source.loadType = ZegoMultimediaLoadType.FilePath;
      source.alphaLayout = layoutType;
      var result = await _mediaPlayer!.loadResourceWithConfig(source);
      ret = result.errorCode;
    }
    return ret;
  }

  void startMediaPlayer() {
    if (_mediaPlayer != null) {
      _mediaPlayer!.start();
    }
  }

  void pauseMediaPlayer() {
    if (_mediaPlayer != null) {
      _mediaPlayer!.pause();
    }
  }

  void resumeMediaPlayer() {
    if (_mediaPlayer != null) {
      _mediaPlayer!.resume();
    }
  }

  void stopMediaPlayer() {
    if (_mediaPlayer != null) {
      _mediaPlayer!.stop();
    }
  }
}
