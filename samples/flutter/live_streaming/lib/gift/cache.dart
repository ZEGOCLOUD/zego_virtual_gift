import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:live_streaming_cohost/gift/player.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

import 'grid.dart';

class ZegoGiftCache {
  static final ZegoGiftCache _singleton = ZegoGiftCache._internal();

  factory ZegoGiftCache() {
    return _singleton;
  }

  ZegoGiftCache._internal();

  void cache(List<ZegoGiftSheetListItemData> cacheList) {
    cacheList.forEach((itemData) {
      debugPrint('${DateTime.now()} try cache ${itemData.url}');
      switch (itemData.source) {
        case GiftPlayerSource.url:
          readFromURL(url: itemData.url).then((value) {
            debugPrint('${DateTime.now()} cache done: ${itemData.url} ');
          });
          break;
        case GiftPlayerSource.asset:
          readFromAsset(assetPath: itemData.url).then((value) {
            debugPrint('${DateTime.now()} cache done: ${itemData.url} ');
          });
          break;
        case GiftPlayerSource.bytes:
          debugPrint('${DateTime.now()} cache done: ${itemData.url} ');
          break;
      }
    });
  }

  Future<List<int>> readFromURL({required String url}) async {
    List<int> result = kTransparentImage.toList();
    final FileInfo? info = await DefaultCacheManager().getFileFromCache(
      url,
      // ignoreMemCache: true,
    );
    if (info == null) {
      try {
        final Uri uri = Uri.parse(url);
        final http.Response response = await http.get(uri);
        if (response.statusCode == HttpStatus.ok) {
          result = response.bodyBytes.toList();
          await DefaultCacheManager().putFile(url, response.bodyBytes);
          print("cache download done:$url");
        } else {}
      } on Exception catch (e, s) {
        print("cache read Exception: $e $s, url:$url");
      }
    } else {
      result = info.file.readAsBytesSync().toList();
    }

    return Future<List<int>>.value(result);
  }

  Future<List<int>> readFromAsset({required String assetPath}) async {
    List<int> result = kTransparentImage.toList();
    final FileInfo? info = await DefaultCacheManager().getFileFromCache(
      assetPath,
      // ignoreMemCache: true,
    );
    if (info == null) {
      await _loadAssetData(assetPath).then((bytesData) async {
        result = bytesData;
        await DefaultCacheManager().putFile(assetPath, bytesData);
      });
    } else {
      result = info.file.readAsBytesSync().toList();
    }

    return Future<List<int>>.value(result);
  }

  Future<Uint8List> _loadAssetData(String assetPath) async {
    ByteData assetData = await rootBundle.load(assetPath);
    Uint8List data = assetData.buffer.asUint8List();
    return data;
  }
}
