import 'package:flutter/material.dart';

enum GiftPlayerSource {
  url,
  asset,
  bytes,
}

class GiftPlayerData {
  GiftPlayerSource source = GiftPlayerSource.asset;
  dynamic value = '';

  GiftPlayerData(
    this.source,
    this.value,
  );

  @override
  String toString() {
    return 'GiftPlayerData:{'
        'source:$source, '
        'value:$value, '
        '}';
  }
}

class ZegoGiftPlayer {
  static final ZegoGiftPlayer _singleton = ZegoGiftPlayer._internal();

  factory ZegoGiftPlayer() {
    return _singleton;
  }

  ZegoGiftPlayer._internal();

  final playingDataNotifier = ValueNotifier<GiftPlayerData?>(null);
  List<GiftPlayerData> pendingPlaylist = [];

  void next() {
    if (pendingPlaylist.isEmpty) {
      playingDataNotifier.value = null;
    } else {
      playingDataNotifier.value = pendingPlaylist.removeAt(0);
    }
  }

  void add(
    GiftPlayerData data,
  ) {
    if (playingDataNotifier.value != null) {
      pendingPlaylist.add(data);
      return;
    }
    playingDataNotifier.value = data;
  }

  bool clear() {
    playingDataNotifier.value = null;
    pendingPlaylist.clear();

    return true;
  }
}
