import 'defines.dart';

final List<ZegoGiftItem> giftItemList = [
  ZegoGiftItem(
    name: 'Music Box1',
    icon: 'assets/gift/musicBox.png',
    sourceURL:
        'https://storage.zego.im/sdk-doc/Pics/zegocloud/gift/music_box.mp4',
    source: ZegoGiftSource.url,
    type: ZegoGiftType.mp4,
    weight: 1,
  ),
  ZegoGiftItem(
    name: 'Music Box2',
    icon: 'assets/gift/musicBox.png',
    sourceURL:
        'https://storage.zego.im/sdk-doc/Pics/zegocloud/gift/music_box.mp4',
    source: ZegoGiftSource.url,
    type: ZegoGiftType.mp4,
    weight: 10,
  ),
  ZegoGiftItem(
    name: 'Music Box3',
    icon: 'assets/gift/musicBox.png',
    sourceURL:
        'https://storage.zego.im/sdk-doc/Pics/zegocloud/gift/music_box.mp4',
    source: ZegoGiftSource.url,
    type: ZegoGiftType.mp4,
    weight: 100,
  ),
  ZegoGiftItem(
    name: 'Airplane',
    icon: 'assets/gift/airplane.png',
    sourceURL: 'assets/gift/airplane.svga',
    source: ZegoGiftSource.asset,
    weight: 100,
  ),
  ZegoGiftItem(
    name: 'Kiss',
    icon: 'assets/gift/kiss.png',
    sourceURL: 'assets/gift/kiss.svga',
    source: ZegoGiftSource.asset,
    weight: 1,
  ),
  ZegoGiftItem(
    name: 'Park',
    icon: 'assets/gift/park.png',
    sourceURL: 'assets/gift/park.svga',
    source: ZegoGiftSource.asset,
    weight: 10,
  ),
  ZegoGiftItem(
    name: 'Race Car',
    icon: 'assets/gift/racecar.png',
    sourceURL: 'assets/gift/racecar.svga',
    source: ZegoGiftSource.asset,
    weight: 10,
  ),
  ZegoGiftItem(
    name: 'Rocket',
    icon: 'assets/gift/rocket.png',
    sourceURL: 'assets/gift/rocket.svga',
    source: ZegoGiftSource.asset,
    weight: 10,
  ),
  ZegoGiftItem(
    name: 'Rose',
    icon: 'assets/gift/rose.png',
    sourceURL: 'assets/gift/rose.svga',
    source: ZegoGiftSource.asset,
    weight: 1,
  ),
  ZegoGiftItem(
    name: 'Yacht',
    icon: 'assets/gift/yacht.png',
    sourceURL: 'assets/gift/yacht.svga',
    source: ZegoGiftSource.asset,
    weight: 100,
  ),
];

ZegoGiftItem? queryGiftInItemList(String name) {
  final index = giftItemList.indexWhere((item) => item.name == name);
  return -1 != index ? giftItemList.elementAt(index) : null;
}
