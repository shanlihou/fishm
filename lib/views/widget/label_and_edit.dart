import 'package:flutter/cupertino.dart';

class LabelAndEdit extends StatefulWidget {
  final String label;
  final String initialValue;
  final Function(String)? onChanged;

  const LabelAndEdit({
    super.key,
    required this.label,
    required this.initialValue,
    this.onChanged,
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
    return Row(
      children: [
        Expanded(flex: 2, child: Text(widget.label)),
        Expanded(
          flex: 8,
          child: CupertinoTextFormFieldRow(
            controller: _controller,
            placeholder: widget.label,
            focusNode: _focusNode,
          ),
        ),
      ],
    );
  }
}
