import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../const/general_const.dart';

class GestureProcessor {
  final Offset startOffset;
  final double scrollPos;
  Offset? currentOffset;
  bool isTap = true;

  GestureProcessor(this.startOffset, this.scrollPos);

  void update(Offset pos) {
    currentOffset = pos;

    // if the distance of two points is beyond the threshold, then we need to update the scroll position
    if ((currentOffset! - startOffset).distance > tapThreshold) {
      isTap = false;
    }
  }

  double toNewScrollPosY() {
    return scrollPos + (currentOffset!.dy - startOffset.dy);
  }

  void end(Offset pos) {
    currentOffset = pos;
  }

  GestureResult getResult() {
    if (isTap) {
      if (startOffset.dx < 0.2.sw) {
        return GestureResult.prevTap;
      } else if (startOffset.dx > 0.8.sw) {
        return GestureResult.nextTap;
      }
    }
    return GestureResult.none;
  }
}
