import 'package:flutter/material.dart';

import 'data.dart';
import 'defines.dart';
import 'manager.dart';

void showSoundEffectSheet(
  BuildContext context,
) {
  showModalBottomSheet(
    backgroundColor: Colors.black.withOpacity(0.5),
    context: context,
    useRootNavigator: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(32.0),
        topRight: Radius.circular(32.0),
      ),
    ),
    isDismissible: true,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets,
        duration: const Duration(milliseconds: 50),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: ZegoGiftSheet(
              itemDataList: giftItemList,
            ),
          ),
        ),
      );
    },
  );
}

class ZegoGiftSheet extends StatefulWidget {
  const ZegoGiftSheet({
    Key? key,
    required this.itemDataList,
  }) : super(key: key);

  final List<ZegoGiftItem> itemDataList;

  @override
  State<ZegoGiftSheet> createState() => _ZegoGiftSheetState();
}

class _ZegoGiftSheetState extends State<ZegoGiftSheet> {
  @override
  Widget build(BuildContext context) {
    return giftList();
  }

  Widget giftList() {
    return CustomScrollView(
      scrollDirection: Axis.horizontal,
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: widget.itemDataList
                .map((item) {
                  return GestureDetector(
                    onTap: () {
                      onGiftTap(item);
                    },
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(2)),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          width: 50,
                          height: 50,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: Image.asset(item.icon),
                          ),
                        ),
                        Text(
                          item.name,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  );
                })
                .map((item) => Row(
                      children: [
                        item,
                        Container(width: 20),
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  void onGiftTap(ZegoGiftItem item) {
    Navigator.of(context).pop();

    /// local play
    ZegoGiftManager().playList.add(item);

    /// notify remote host
    ZegoGiftManager().service.sendGift(name: item.name, count: 1);
  }
}
