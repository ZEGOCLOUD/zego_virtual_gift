class ZegoGiftItem {
  String name;
  String icon;
  String sourceURL;
  ZegoGiftSource source;
  int weight;

  ZegoGiftItem({
    required this.sourceURL,
    required this.weight,
    this.name = '',
    this.icon = '',
    this.source = ZegoGiftSource.url,
  });
}

enum ZegoGiftSource {
  url,
  asset,
}
