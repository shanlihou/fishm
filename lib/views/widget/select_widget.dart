import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/log.dart';
import '../../utils/utils_general.dart';

class SelectMenuItem {
  String label;
  String chapterId;

  SelectMenuItem({required this.label, required this.chapterId});
}

class SelectWidget extends StatefulWidget {
  final ValueChanged<String>? valueChanged;
  final List<SelectMenuItem> items;
  final int defaultIndex;

  const SelectWidget(
      {super.key,
      this.valueChanged,
      required this.items,
      this.defaultIndex = -1});

  @override
  State<SelectWidget> createState() => _SelectWidgetState();
}

class _SelectWidgetState extends State<SelectWidget> {
  String label = '';
  bool isExpand = false;

  @override
  void initState() {
    super.initState();

    if (widget.defaultIndex >= 0 && widget.defaultIndex < widget.items.length) {
      label = widget.items[widget.defaultIndex].label;
    } else {
      label = widget.items[0].label;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SelectMenuItem>(
      // initialValue: currentValue,
      color: Colors.white,
      offset: const Offset(25, 30),
      enableFeedback: true,
      child: Listener(
        onPointerDown: (event) {
          setState(() {
            isExpand = !isExpand;
          });
        },
        child: Container(
          color: Colors.white,
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.7),
                    fontSize: vh(20.spMin, 48.spMin)),
              ),
              isExpand
                  ? const Icon(Icons.arrow_drop_up)
                  : const Icon(Icons.arrow_drop_down)
            ],
          ),
        ),
      ),
      onSelected: (value) {
        Log.instance.d("select $value");

        label = value.label;
        widget.valueChanged?.call(value.chapterId);
        setState(() {
          // currentValue = value;
          isExpand = !isExpand;
        });
      },
      onCanceled: () {
        setState(() {
          isExpand = false;
        });
      },
      itemBuilder: (context) {
        return widget.items
            .map(
              (item) => PopupMenuItem<SelectMenuItem>(
                height: 90.h,
                value: item,
                child: Text(
                  item.label,
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: vh(20.spMin, 38.spMin)),
                ),
              ),
            )
            .toList();
      },
    );
  }
}
