import 'package:lua_dardo_co/lua.dart';
import './pb_const.dart';
import 'dart:typed_data';

int gettype(int v) {
  return v & 0x7;
}

// #define pb_gettag(v)       ((v) >> 3)a
int gettag(int v) {
  return v >> 3;
}

int relindex(idx, offset) {
  if (idx < 0 && idx > luaRegistryIndex) {
    return idx - offset;
  }
  return idx;
}

int pbPair(int tag, int type) {
  return (tag << 3) | (type & 0x7);
}

int pbWtypebytype(int type) {
    switch (type) {
    case PB_Tdouble:    return PB_T64BIT;
    case PB_Tfloat:     return PB_T32BIT;
    case PB_Tint64:     return PB_TVARINT;
    case PB_Tuint64:    return PB_TVARINT;
    case PB_Tint32:     return PB_TVARINT;
    case PB_Tfixed64:   return PB_T64BIT;
    case PB_Tfixed32:   return PB_T32BIT;
    case PB_Tbool:      return PB_TVARINT;
    case PB_Tstring:    return PB_TBYTES;
    case PB_Tmessage:   return PB_TBYTES;
    case PB_Tbytes:     return PB_TBYTES;
    case PB_Tuint32:    return PB_TVARINT;
    case PB_Tenum:      return PB_TVARINT;
    case PB_Tsfixed32:  return PB_T32BIT;
    case PB_Tsfixed64:  return PB_T64BIT;
    case PB_Tsint32:    return PB_TVARINT;
    case PB_Tsint64:    return PB_TVARINT;
    default:            return PB_TWIRECOUNT;
    }
}

int refTable(LuaState ls, int ref) {
  if (ref != LUA_NOREF) {
    ls.rawGetI(luaRegistryIndex, ref);
    return ref;
  }
  else {
    ls.newTable();
    ls.pushValue(-1);
    return ls.ref(luaRegistryIndex);
  }
}

void pushInteger(LuaState ls, int n, bool u, int mode) {
  if (mode != LPB_NUMBER && ((u && n < 0) || n < INT_MIN || n > UINT_MAX)) {
    List<int> buff = List<int>.filled(32, 0);
    int p = 32 - 1;
    bool neg = !u && n < 0;
    int un = (!u && neg) ? ~n + 1 : n;

    if (mode == LPB_STRING) {
      for (; un > 0; un ~/= 10) {
        buff[p--] = un % 10 + 48; // '0'
      }
    }
    else if (mode == LPB_HEXSTRING) {
      for (; un > 0; un ~/= 16) {
          int d = un % 16;
          buff[p--] = d + (d < 10 ? 48 : 87); // '0' : 'a' - 10
      }
      buff[p--] = 120; // 'x'
      buff[p--] = 48; // '0'
    }

    if (neg) {
      buff[p--] = 45; // '-'
    }

    buff[p] = 35;// '#' ascii is 35
    ls.pushString(String.fromCharCodes(buff.sublist(p)));
  }
  else {
    ls.pushInteger(n);
  }
}

bool setMetaTable(LuaState ls, int objIndex) {
  // TODO: implement setMetaTable
  return false;
}

int pbDecodeSint32(int n) {
  return (n >> 1) ^ -(n & 1);
}

int pbDecodeSint64(int n) {
  return (n >> 1) ^ -(n & 1);
}

double pbDecodeFloat(int n) {
  ByteData bd = ByteData(4);
  bd.setInt32(0, n);
  return bd.getFloat32(0);
}

double pbDecodeDouble(int n) {
  ByteData bd = ByteData(8);
  bd.setInt64(0, n);
  return bd.getFloat64(0);
}
