import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LabelAndEdit extends StatefulWidget {
  final String label;
  final String initialValue;
  final Function(String)? onChanged;
  final bool isFirst;

  const LabelAndEdit({
    super.key,
    required this.label,
    required this.initialValue,
    this.onChanged,
    required this.isFirst,
  });

  @override
  State<LabelAndEdit> createState() => _LabelAndEditState();
}

class _LabelAndEditState extends State<LabelAndEdit> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue;
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        widget.onChanged?.call(_controller.text);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 40.w, right: 40.w, top: 20.h, bottom: 0.h),
      child: Column(
        children: [
          if (!widget.isFirst)
            Container(
              height: 1.h,
              color: CupertinoColors.black.withOpacity(0.3),
            ),
          Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text(widget.label,
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
              Expanded(
                flex: 8,
                child: CupertinoTextFormFieldRow(
                  controller: _controller,
                  placeholder: widget.label,
                  focusNode: _focusNode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
