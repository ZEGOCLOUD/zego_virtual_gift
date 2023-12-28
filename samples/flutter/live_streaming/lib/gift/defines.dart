class ZegoGiftItem {
  String name;
  String icon;
  String sourceURL;
  ZegoGiftSource source;

  ZegoGiftItem({
    required this.sourceURL,
    this.name = '',
    this.icon = '',
    this.source = ZegoGiftSource.url,
  });
}

enum ZegoGiftSource {
  url,
  asset,
}
