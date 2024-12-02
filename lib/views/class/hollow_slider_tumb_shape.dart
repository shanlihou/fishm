import 'package:flutter/material.dart';

class HollowSliderThumbShape extends SliderComponentShape {
  final double radius;
  final Color color;
  final double borderWidth;

  HollowSliderThumbShape({
    this.radius = 16,
    this.color = Colors.white,
    this.borderWidth = 2,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(radius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    var r = getPreferredSize(true, false).width / 2;

    // 绘制一个圆形的滑动按钮
    canvas.drawCircle(center, r, paint);
    //中间是白色圆心
    paint.color = Colors.white;
    canvas.drawCircle(center, r - borderWidth, paint);
  }
}
