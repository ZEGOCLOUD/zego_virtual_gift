// Flutter imports:
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:live_streaming_cohost/gift/player.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

import 'cache.dart';
import 'grid.dart';
import 'dart:typed_data';

class ZegoGiftService {
  static final ZegoGiftService _singleton = ZegoGiftService._internal();

  factory ZegoGiftService() {
    return _singleton;
  }

  ZegoGiftService._internal();

  int _appID = 0;
  String _appSecret = '';
  String _liveID = '';
  String _localUserID = '';
  String _localUserName = '';

  List<StreamSubscription<dynamic>?> _subscriptions = [];

  final recvNotifier = ValueNotifier<ZegoGiftData?>(null);

  void init({
    required int appID,
    required String appSecret,
    required String liveID,
    required String localUserID,
    required String localUserName,
  }) {
    _appID = appID;
    _appSecret = appSecret;
    _liveID = liveID;
    _localUserID = localUserID;
    _localUserName = localUserName;

    _subscriptions.add(ZegoUIKit()
        .getSignalingPlugin()
        .getInRoomCommandMessageReceivedEventStream()
        .listen((event) {
      onInRoomCommandMessageReceived(event);
    }));
  }

  void uninit() {
    for (final subscription in _subscriptions) {
      subscription?.cancel();
    }
  }

  Future<bool> sendGift({
    required String name,
    required int count,
  }) async {
    final data = ZegoGiftProtocol(
      appID: _appID,
      appSecret: _appSecret,
      liveID: _liveID,
      localUserID: _localUserID,
      localUserName: _localUserName,
      giftData: ZegoGiftData(
        giftName: name,
        giftCount: count,
      ),
    ).toJson();

    debugPrint('try send gift, name:$name, count:$count, data:$data');
    ZegoUIKit()
        .getSignalingPlugin()
        .sendInRoomCommandMessage(
          roomID: _liveID,
          message: _stringToUint8List(data),
        )
        .then((result) {
      debugPrint('send gift result:$result');
    });

    return true;
  }

  Uint8List _stringToUint8List(String input) {
    List<int> utf8Bytes = utf8.encode(input);
    Uint8List uint8List = Uint8List.fromList(utf8Bytes);
    return uint8List;
  }

  // if you use unreliable message channel, you need subscription this method.
  void onInRoomCommandMessageReceived(
      ZegoSignalingPluginInRoomCommandMessageReceivedEvent event) {
    final messages = event.messages;

    // You can display different animations according to gift-type
    for (final commandMessage in messages) {
      final senderUserID = commandMessage.senderUserID;
      final message = utf8.decode(commandMessage.message);
      debugPrint('onInRoomCommandMessageReceived: $message');
      if (senderUserID != _localUserID) {
        //  todo
        recvNotifier.value = ZegoGiftData(
          giftName: 'xx',
          giftCount: 1,
        );
      }
    }
  }
}

class ZegoGiftData {
  String giftName = '';
  int giftCount = 0;

  ZegoGiftData({
    required this.giftName,
    required this.giftCount,
  });

  ZegoGiftData.empty();
}

class ZegoGiftProtocol {
  int appID = 0;
  String appSecret = '';
  String liveID = '';
  String localUserID = '';
  String localUserName = '';
  ZegoGiftData giftData;

  ZegoGiftProtocol({
    required this.appID,
    required this.appSecret,
    required this.liveID,
    required this.localUserID,
    required this.localUserName,
    required this.giftData,
  });

  String toJson() => json.encode({
        'app_id': appID,
        'server_secret': appSecret,
        'room_id': liveID,
        'user_id': localUserID,
        'user_name': localUserName,
        'gift_name': giftData.giftName,
        'gift_count': giftData.giftCount,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

  factory ZegoGiftProtocol.fromJson(Map<String, dynamic> json) {
    return ZegoGiftProtocol(
      appID: json['app_id'] ?? 0,
      appSecret: json['server_secret'] ?? '',
      liveID: json['room_id'] ?? '',
      localUserID: json['user_id'] ?? '',
      localUserName: json['user_name'] ?? '',
      giftData: ZegoGiftData(
        giftName: json['gift_name'] ?? 0,
        giftCount: json['gift_count'] ?? 0,
      ),
    );
  }
}
