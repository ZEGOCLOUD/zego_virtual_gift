part of '../manager.dart';

mixin PlayList {
  final _playListImpl = PlayListImpl();

  PlayListImpl get playList => _playListImpl;
}

class PlayListImpl {
  final playingDataNotifier = ValueNotifier<ZegoGiftItem?>(null);
  List<ZegoGiftItem> pendingPlaylist = [];

  void next() {
    if (pendingPlaylist.isEmpty) {
      playingDataNotifier.value = null;
    } else {
      playingDataNotifier.value = pendingPlaylist.removeAt(0);
    }
  }

  void add(
    ZegoGiftItem data,
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
