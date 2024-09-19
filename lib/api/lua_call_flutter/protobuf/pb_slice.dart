import './utils.dart';
import './pb_const.dart';
import 'dart:typed_data';
import 'dart:convert';


class PbSlice {
  Uint8List buffer;
  int _current = 0;
  int start;
  int end;

  static PbSlice empty() {
    return PbSlice(Uint8List(0), 0, 0);
  }

  PbSlice(this.buffer, this.start, this.end, {int current = 0}) {
    _current = current;
  }

  static PbSlice fromString(String str, int start, int end) {
    return PbSlice(Uint8List.fromList(str.codeUnits), start, end, current: start);
  }

  PbSlice sub(int start, int end) {
    return PbSlice(buffer, start, end);
  }

  void reset(PbSlice slice) {
    _current = slice._current;
    buffer = slice.buffer;
    start = slice.start;
    end = slice.end;
  }

  int get current => buffer[_current];

  int pos() {
    return _current - start;
  }

  int len() {
    return end - _current;
  }

  (int, int) readvarint32Fallback() {
    int original = _current;
    int p = _current;
    int b, n;
    for (;;) {
      //     n = *p++ - 0x80, n += (b = *p++) <<  7; if (!(b & 0x80)) break;
      n = buffer[p++] - 0x80;
      n += (b = buffer[p++]) << 7;
      if (!(b & 0x80 != 0)) {
        break;
      }
      //     n -= 0x80 <<  7, n += (b = *p++) << 14; if (!(b & 0x80)) break;
      n -= 0x80 << 7;
      n += (b = buffer[p++]) << 14;
      if (!(b & 0x80 != 0)) {
        break;
      }
      //     n -= 0x80 << 14, n += (b = *p++) << 21; if (!(b & 0x80)) break;
      n -= 0x80 << 14;
      n += (b = buffer[p++]) << 21;
      if (!(b & 0x80 != 0)) {
        break;
      }
      //     n -= 0x80 << 21, n += (b = *p++) << 28; if (!(b & 0x80)) break;
      n -= 0x80 << 21;
      n += (b = buffer[p++]) << 28;
      if (!(b & 0x80 != 0)) {
        break;
      }
      //     /* n -= 0x80 << 28; */
      n -= 0x80 << 28;
      //     if (!(*p++ & 0x80)) break;
      if (!(buffer[p++] & 0x80 != 0)) {
        break;
      }
      //     if (!(*p++ & 0x80)) break;
      if (!(buffer[p++] & 0x80 != 0)) {
        break;
      }
      //     if (!(*p++ & 0x80)) break;
      if (!(buffer[p++] & 0x80 != 0)) {
        break;
      }
      //     if (!(*p++ & 0x80)) break;
      if (!(buffer[p++] & 0x80 != 0)) {
        break;
      }
      //     if (!(*p++ & 0x80)) break;
      if (!(buffer[p++] & 0x80 != 0)) {
        break;
      }
      return (0, 0);
    }

    _current = p;
    return (n, _current - original);
  }


  (int, int) readvarint64Fallback() {
    int p = _current;
    int original = _current;
    int b, n1, n2 = 0, n3 = 0;
    for (;;) {
      //         n1 = *p++ - 0x80, n1 += (b = *p++) <<  7; if (!(b & 0x80)) break;
      n1 = buffer[p++] - 0x80;
      n1 += (b = buffer[p++]) << 7;
      if (!(b & 0x80 != 0)) {
        break;
      }
      //         n1 -= 0x80 <<  7, n1 += (b = *p++) << 14; if (!(b & 0x80)) break;
      n1 -= 0x80 << 7;
      n1 += (b = buffer[p++]) << 14;
      if (!(b & 0x80 != 0)) {
        break;
      }
      //         n1 -= 0x80 << 14, n1 += (b = *p++) << 21; if (!(b & 0x80)) break;
      n1 -= 0x80 << 14;
      n1 += (b = buffer[p++]) << 21;
      if (!(b & 0x80 != 0)) {
        break;
      }
      //         n1 -= 0x80 << 21, n2 += (b = *p++)      ; if (!(b & 0x80)) break;
      n1 -= 0x80 << 21;
      n2 += (b = buffer[p++]);
      if (!(b & 0x80 != 0)) {
        break;
      }
      //         n2 -= 0x80      , n2 += (b = *p++) <<  7; if (!(b & 0x80)) break;
      n2 -= 0x80;
      n2 += (b = buffer[p++]) << 7;
      if (!(b & 0x80 != 0)) {
        break;
      }
      //         n2 -= 0x80 <<  7, n2 += (b = *p++) << 14; if (!(b & 0x80)) break;
      n2 -= 0x80 << 7;
      n2 += (b = buffer[p++]) << 14;
      if (!(b & 0x80 != 0)) {
        break;
      }
      //         n2 -= 0x80 << 14, n2 += (b = *p++) << 21; if (!(b & 0x80)) break;
      n2 -= 0x80 << 14;
      n2 += (b = buffer[p++]) << 21;
      if (!(b & 0x80 != 0)) {
        break;
      }
      //         n2 -= 0x80 << 21, n3 += (b = *p++)      ; if (!(b & 0x80)) break;
      n2 -= 0x80 << 21;
      n3 += (b = buffer[p++]);
      if (!(b & 0x80 != 0)) {
        break;
      }
      //         n3 -= 0x80      , n3 += (b = *p++) <<  7; if (!(b & 0x80)) break;
      n3 -= 0x80;
      n3 += (b = buffer[p++]) << 7;
      if (!(b & 0x80 != 0)) {
        break;
      }
      //         return 0;
      return (0, 0);
    }
    //     *pv = n1 | ((uint64_t)n2 << 28) | ((uint64_t)n3 << 56);
    //     s->p = (const char*)p;
    //     return p - o;
    // }
    int ret = n1 | (n2 << 28) | (n3 << 56);
    _current = p;
    return (ret, _current - original);
  }

  (int, int) readvarintSlow() {
    int p = _current;
    int n = 0;
    int i = 0;
    while (_current < end && i < 10) {
      int b = buffer[_current++];
      n |= (b & 0x7f) << (7 * i++);
      if (b & 0x80 == 0) {
        return (n, i);
      }
    }

    _current = p;
    return (0, 0);
  }

  (int, int) readvarint64() {
    if (_current >= end) {
      return (0, 0);
    }

    if (!(current & 0x80 != 0)) {
      return (buffer[_current++], 1);
    }

    if (len() >= 10 || (!(buffer[end - 1] & 0x80 != 0))) {
      return readvarint64Fallback();
    }

    return readvarintSlow();
  }

  (PbSlice, int) readbytes() {
    int p = _current;
    int sz, length;
    (length, sz) = readvarint64();
    if (sz == 0 || len() < length) {
      _current = p;
      return (PbSlice(Uint8List(0), 0, 0), 0);
    }

    PbSlice pv = PbSlice(buffer, start, _current + length, current: _current);
    _current = pv.end;

    return (pv, _current - p);
  }

  // return num, size
  (int, int) readvarint32() {
    if (_current >= end) {
      return (0, 0);
    }

    if (!(current & 0x80 != 0)) {
      return (buffer[_current++], 1);
    }

    if (len() >= 10 || (!(buffer[end - 1] & 0x80 != 0))) {
      return readvarint32Fallback();
    }

    return readvarintSlow();
  }

  int skipvarint() {
    int p = _current;
    int original = _current;
    while (p < end && (buffer[p] & 0x80 != 0)) {
      p++;
    }
    if (p >= end) {
      return 0;
    }
    _current = ++p;
    return p - original;
  }

  int skipslice(int len) {
    if (_current + len > end) {
      return 0;
    }
    _current += len;
    return len;
  }

  int skipbytes() {
    int p = _current;
    int value;
    int sz;
    (value, sz) = readvarint64();
    if (sz == 0) {
      return 0;
    }

    if (len() < value) {
      _current = p;
      return 0;
    }
    _current += value;
    return _current - p;
  }

  (PbSlice, int) readgroup(int tag) {
    int p = _current;
    int newtag = 0;
    int count;
    int sz;
    assert(gettype(tag) == PB_TGSTART);

    while (true) {
      (newtag, sz) = readvarint32();
      count = sz;
      if (sz == 0) {
        break;
      }

      if (gettype(newtag) == PB_TGEND) {
        if (gettag(newtag) != gettag(tag)) {
          break;
        }

        return (PbSlice(buffer, start, _current - count, current: p), _current - p);
      }

      if (skipvalue(newtag) == 0) {
        break;
      }
    }

    _current = p;
    return (PbSlice(Uint8List(0), 0, 0), 0);
  }

  int skipvalue(int tag) {
    int p = _current;
    int ret = 0;
    switch (gettype(tag)) {
      case PB_TVARINT:
        ret = skipvarint();
        break;
      case PB_T64BIT:
        ret = skipslice(8);
        break;
      case PB_TBYTES:
        ret = skipbytes();
        break;
      case PB_T32BIT:
        ret = skipslice(4);
        break;
      case PB_TGSTART:
        (_, ret) = readgroup(tag);
        break;
      default:
        break;
    }

    if (ret == 0) {
      _current = p;
    }

    return ret;
  }

  (int, int) readfixed32() {
    int n = 0;
    if (_current + 4 > end) {
      return (0, 0);
    }

    for (int i = 3; i >= 0; i--) {
      n = (n << 8) | (buffer[_current + i] & 0xff);
    }

    _current += 4;
    return (n, 4);
  }

  (int, int) readfixed64() {
    int n = 0;
    if (_current + 8 > end) {
      return (0, 0);
    }

    for (int i = 7; i >= 0; i--) {
      n = (n << 8) | (buffer[_current + i] & 0xff);
    }

    _current += 8;
    return (n, 8);
  }

  bool isSameString(String val) {
    return toString() == val;
  }

  @override
  String toString() {
    return utf8.decode(buffer.sublist(_current, end));
  }

  int charAt(int index) {
    return buffer[_current + index];
  }
}
