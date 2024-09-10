import 'package:lua_dardo_co/lua.dart';
import './pb_const.dart';

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
