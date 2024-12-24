import 'package:lua_dardo_co/lua.dart';
import '../pb_const.dart';
import 'dart:typed_data';
import '../pb_slice.dart';

class PbBuffer {
  final List<int> _buffer = [];

  int length() {
    return _buffer.length;
  }

  int write32(int n) {
    int p, c = 0;
    do {
      p = n & 0x7F;
      if ((n >>= 7) == 0) break;
      _buffer.add(p | 0x80);
      ++c;
      p = n & 0x7F;
      if ((n >>= 7) == 0) break;
      _buffer.add(p | 0x80);
      ++c;
      p = n & 0x7F;
      if ((n >>= 7) == 0) break;
      _buffer.add(p | 0x80);
      ++c;
      p = n & 0x7F;
      if ((n >>= 7) == 0) break;
      _buffer.add(p | 0x80);
      ++c;
      p = n;
    } while (false);
    _buffer.add(p);
    return ++c;
  }

  int write64(int n) {
    int p, c = 0;
    do {
      p = n & 0x7F;
      if ((n >>= 7) == 0) break;
      _buffer.add(p | 0x80);
      ++c;
      p = n & 0x7F;
      if ((n >>= 7) == 0) break;
      _buffer.add(p | 0x80);
      ++c;
      p = n & 0x7F;
      if ((n >>= 7) == 0) break;
      _buffer.add(p | 0x80);
      ++c;
      p = n & 0x7F;
      if ((n >>= 7) == 0) break;
      _buffer.add(p | 0x80);
      ++c;
      p = n & 0x7F;
      if ((n >>= 7) == 0) break;
      _buffer.add(p | 0x80);
      ++c;
      p = n & 0x7F;
      if ((n >>= 7) == 0) break;
      _buffer.add(p | 0x80);
      ++c;
      p = n & 0x7F;
      if ((n >>= 7) == 0) break;
      _buffer.add(p | 0x80);
      ++c;
      p = n & 0x7F;
      if ((n >>= 7) == 0) break;
      _buffer.add(p | 0x80);
      ++c;
      p = n & 0x7F;
      if ((n >>= 7) == 0) break;
      _buffer.add(p | 0x80);
      ++c;
      p = n & 0x7f;
    } while (false);

    _buffer.add(p);
    return ++c;
  }

  int addDouble(double d) {
    ByteData bd = ByteData(8);
    bd.setFloat64(0, d);
    return addByteData(bd, 8);
  }

  int addFloat(double d) {
    ByteData bd = ByteData(4);
    bd.setFloat32(0, d);
    return addByteData(bd, 4);
  }

  int addFixed64(int n) {
    ByteData bd = ByteData(8);
    bd.setUint64(0, n);
    return addByteData(bd, 8);
  }

  int addFixed32(int n) {
    ByteData bd = ByteData(4);
    bd.setUint32(0, n);
    return addByteData(bd, 4);
  }

  int addVarint32(int n) {
    return write32(n);
  }

  int addVarint64(int n) {
    return write64(n);
  }

  void _copyFromOtherBuffer(PbBuffer other, int offset, int len) {
    for (int i = 0; i < len; i++) {
      _buffer[offset + i] = other._buffer[i];
    }
  }

  int addByteData(ByteData bd, int len) {
    for (int i = 0; i < len; i++) {
      _buffer.add(bd.getUint8(i));
    }
    return len;
  }

  int addLength(int len, int prealloc) {
    PbBuffer tmp = PbBuffer();
    int bl;
    if ((bl = length()) < len) {
      return 0;
    }

    int writePos = len - prealloc;
    int ml = tmp.write64(bl - len);
    assert(ml >= prealloc);

    if (ml > prealloc) {
      for (int i = 0; i < ml - prealloc; i++) {
        _buffer.insert(writePos, 0);
      }
    }

    _copyFromOtherBuffer(tmp, writePos, ml);
    return ml + (bl - len);
  }

  int addString(String s) {
    int len = s.length;
    for (int i = 0; i < len; i++) {
      _buffer.add(s.codeUnitAt(i));
    }
    return len;
  }

  int addBytes(String s) {
    int len = s.length;
    addVarint32(len);
    return len + addString(s);
  }

  int addType(LuaState ls, int idx, int type, List<bool>? pexist) {
    int ret = 0;
    int hasData = 1;
    int len = 0;
    switch (type) {
      case PB_Tbool:
        int ret = ls.toBoolean(idx) ? 1 : 0;
        len = addVarint32(ret);
        ret = 1;
        break;

      case PB_Tdouble:
        double? d = ls.toNumberX(idx);
        len = addDouble(d!);
        ret = 1;

        if (d == 0.0) {
          hasData = 0;
        }
        break;

      case PB_Tfloat:
        double? d = ls.toNumberX(idx);
        len = addFloat(d!);
        ret = 1;

        if (d == 0.0) {
          hasData = 0;
        }
        break;

      case PB_Tfixed32:
        int? n = ls.toIntegerX(idx);
        len = addFixed32(n!);
        ret = 1;

        if (n == 0) {
          hasData = 0;
        }
        break;

      case PB_Tsfixed32:
        int? n = ls.toIntegerX(idx);
        len = addFixed32(n!);
        ret = 1;

        if (n == 0) {
          hasData = 0;
        }
        break;

      case PB_Tint32:
        int? n = ls.toIntegerX(idx);
        len = addVarint64(n!);
        ret = 1;

        if (n == 0) {
          hasData = 0;
        }
        break;

      case PB_Tuint32:
        int? n = ls.toIntegerX(idx);
        len = addVarint32(n!);
        ret = 1;

        if (n == 0) {
          hasData = 0;
        }
        break;

      case PB_Tsint32:
        int? n = ls.toIntegerX(idx)!;
        len = addVarint32((n << 1) ^ (n >> 31));
        ret = 1;

        if (n == 0) {
          hasData = 0;
        }
        break;

      case PB_Tfixed64:
        int? n = ls.toIntegerX(idx)!;
        len = addFixed64(n);
        ret = 1;

        if (n == 0) {
          hasData = 0;
        }
        break;

      case PB_Tsfixed64:
        int? n = ls.toIntegerX(idx)!;
        len = addFixed64(n);
        ret = 1;

        if (n == 0) {
          hasData = 0;
        }
        break;

      case PB_Tint64:
      case PB_Tuint64:
        int? n = ls.toIntegerX(idx)!;
        len = addVarint64(n);
        ret = 1;

        if (n == 0) {
          hasData = 0;
        }
        break;

      case PB_Tsint64:
        int? n = ls.toIntegerX(idx)!;
        len = addVarint64((n << 1) ^ (n >> 63));
        ret = 1;

        if (n == 0) {
          hasData = 0;
        }
        break;

      case PB_Tbytes:
      case PB_Tstring:
        if (ls.type(idx) == LuaType.luaString) {
          String s = ls.checkString(idx)!;
          len = addBytes(s);

          if (s.isEmpty) {
            hasData = 0;
          }

          ret = 1;
        } else {
          hasData = 0;
        }
        break;

      default:
        throw Exception("Unknown type: $type");
    }
    if (pexist != null) {
      pexist[0] = (ret != 0) && (hasData != 0);
    }

    return ret != 0 ? len : 0;
  }

  void minusLength(int len) {
    _buffer.length -= len;
  }

  void resetLength(int len) {
    _buffer.length = len;
  }

  void addSlice(PbSlice slice) {
    for (int i = 0; i < slice.len(); i++) {
      _buffer.add(slice.charAt(i));
    }
  }

  Uint8List toBytes() {
    return Uint8List.fromList(_buffer);
  }

  String bytesToString() {
    return String.fromCharCodes(_buffer);
  }
}
