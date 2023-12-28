import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter/services.dart';

import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

import 'components/play_widget.dart';
import 'defines.dart';

part 'mixin/play_list.dart';

part 'mixin/service.dart';

part 'mixin/cache.dart';

class ZegoGiftManager with Cache, PlayList, Service {
  static final ZegoGiftManager _singleton = ZegoGiftManager._internal();

  factory ZegoGiftManager() {
    return _singleton;
  }

  ZegoGiftManager._internal();
}
