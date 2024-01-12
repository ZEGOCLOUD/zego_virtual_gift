// Flutter imports:
import 'package:flutter/material.dart';

import 'package:zego_uikit/zego_uikit.dart';

// Package imports:
import 'home_page.dart';
import 'gift/gift.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  ZegoGiftManager().cache.cache(giftItemList);

  ZegoUIKit().initLog().then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Demo', home: HomePage());
  }
}
