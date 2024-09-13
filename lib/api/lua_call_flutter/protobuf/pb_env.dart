import 'package:lua_dardo_co/lua.dart';
import './state/pb_state.dart';
import './state/pb_type.dart';
import './state/pb_field.dart';
import './utils.dart';
import './common/pb_buffer.dart';
import './pb_const.dart';
import './pb_slice.dart';

class PbEnv {
  final LuaState ls;
  final PbState ps;
  final PbBuffer b;
  PbSlice s;

  PbEnv(this.ls, this.ps, this.b, this.s);

  int pbEnum(PbField f, List<bool>? pexit, int idx) {
    var type = ls.type(idx);
    PbField? ev;
    String? ename = ls.checkString(idx);
    if (type == LuaType.luaNumber) {
      int v = ls.toInteger(idx);
      if (pexit != null) {
        pexit[0] = (v != 0);
      }
      return b.addVarint64(v);
    }
    else if ((ev = f.type!.findField(ename!)) != null) {
      if (pexit != null) {
        pexit[0] = ev!.number != 0;
      }
      return b.addVarint32(ev!.number);
    }
    else {
      throw Exception("Unknown enum value: $ename");
    }
  }

  int field(PbField f, List<bool>? pexit, int idx) {
      switch(f.typeId) {
        case PB_Tenum:
          return pbEnum(f, pexit, idx);
        case PB_Tmessage:
          if (ls.type(idx) != LuaType.luaTable) {
            throw Exception("Table expected for field ${f.name}");
          }
          b.addVarint32(0);
          int len = b.length();
          encode(f.type!, idx);
          if (pexit != null) {
            pexit[0] = (len < b.length());
          }
          return b.addLength(len, 1);
        default:
          int len = b.addType(ls, idx, f.typeId, pexit);
          if (len <= 0) {
            throw Exception("${(f.typeId)} expected for field '${f.name}', got ${ls.type(idx)}");
          }
          return len;
      }
  }

  void tagField(PbField f, int ignorezero, int idx) {
    int hlen = b.addVarint32(pbPair(f.number, pbWtypebytype(f.typeId)));
    List<bool> pexit = [false];
    int ignoredlen = field(f, pexit, idx);
    if (!ps.encodeDefaultValues && !pexit[0] && ignorezero != 0) {
      b.minusLength(ignoredlen + hlen);
    }
  }

  void map(PbField field, int idx) {
    final PbField? kf = field.type!.fieldTags[1];
    final PbField? vf = field.type!.fieldTags[2];
    if (kf == null || vf == null) {
      return;
    }

    if (ls.type(idx) != LuaType.luaTable) {
      return;
    }

    ls.pushNil();
    while(ls.next(relindex(idx, 1))) {
      b.addVarint32(pbPair(field.number, PB_TBYTES));
      b.addVarint32(0);
      int len = b.length();
      tagField(kf, 1, -2);
      tagField(vf, 1, -1);
      b.addLength(len, 1);
      ls.pop(1);
    }
  }

  void repeated(PbField f, int idx) {
    int i;
    if (f.packed != 0) {
      int len;
      int buffLen = b.length();
      b.addVarint32(pbPair(f.number, PB_TBYTES));
      b.addVarint32(0);
      len = b.length();
      for (i = 1; ls.rawGetI(idx, i) != LuaType.luaNil; i++) {
        field(f, null, -1);
        ls.pop(1);
      }

      if (i == 1 && (!ps.encodeDefaultValues)) {
        b.resetLength(buffLen);
      } else {
        b.addLength(len, 1);
      }
    }
    else {
      for (i = 1; ls.rawGetI(idx, i) != LuaType.luaNil; i++) {
        tagField(f, 0, -1);
        ls.pop(1);
      }
    }

    ls.pop(1);
  }

  void encodeOneField(PbType pt, PbField field, int idx) {
    if (field.type != null && field.type!.isMap) {
      map(field, idx);
    }
    else if (field.repeated) {
      repeated(field, idx);
    }
    else {
      int ignorezero = pt.isProto3 && (field.oneofIdx == 0) && (field.typeId != PB_Tmessage) ? 1 : 0;
      tagField(field, ignorezero, idx);
    }
  }

  void encode(PbType pt, int idx) {
    if (ps.encodeOrder) {
      throw Exception("Not implemented encode order");
    } else {
      ls.pushNil();
      while(ls.next(relindex(idx, 1))) {
        if (ls.type(-2) == LuaType.luaString) {
          var field = pt.findField(ls.checkString(-2)!);
          if (field != null) {
            encodeOneField(pt, field, -1);
          }
        }
        ls.pop(1);
      }
    }
  }

  void dCheckType(PbField f, int tag) {
    if (pbWtypebytype(f.typeId) == gettype(tag)) {
      return;
    }
    throw Exception("Type mismatch: $f.typeId != ${tag & 0x7}");
  }

  void dRawField(PbField f) {
    int u64;
    int len;
    PbField? ev;
    switch (f.typeId) {
      case PB_Tenum:
        (u64, len) = s.readvarint64();
        if (len == 0) {
          throw Exception("invalid varint value at offset ${s.pos()}");
        }

        if (!ps.enumAsValue) {
          ev = f.type!.findFieldByTag(u64);
        }

        if (ev != null) {
          ls.pushString(ev.name);
        }
        else {
          pushInteger(ls, u64, true, ps.int64Mode);
        }

        if (ps.useDecHooks) {
          throw Exception("Not implemented useDecHooks");
        }

        break;

      case PB_Tmessage:
        PbSlice? sv;
        (sv, len) = s.readbytes();
        if (f.type == null || f.type!.isDead) {
          ls.pushNil();
        }
        else {
          ps.pushTypeTable(ls, f.type!);
          PbSlice s = this.s;
          this.s = sv;
          dMessage(f.type!);
          this.s = s;
        }
        break;

      default:
        ps.readType(ls, f.typeId, s);
    }
  }

  void dField(PbField f, int tag) {
    dCheckType(f, tag);
    dRawField(f);
  }

  void dMap(PbField f) {
    int top = ls.getTop();
    int len;
    int tag;
    PbSlice p;
    (p, len) = s.readbytes();
    if (f.type == null) {
      return;
    }

    ls.pushNil();
    ls.pushNil();

    int mask = 0;
    while (true) {
      (tag, len) = p.readvarint32();
      if (len == 0) {
        break;
      }

      int n = gettag(tag);
      if (n == 1 || n == 2) {
        mask |= n;
        PbSlice tmps = s;
        s = p;
        dField(f.type!.findFieldByTag(n)!, tag);
        s = tmps;

        ls.replace(top + n);
      }
    }

    if ((mask & 1) == 0 && ps.pushDefField(ls, f.type!.findFieldByTag(1), true)) {
      ls.replace(top + 1);
      mask |= 1;
    }

    if ((mask & 2) == 0 && ps.pushDefField(ls, f.type!.findFieldByTag(2), true)) {
      ls.replace(top + 2);
      mask |= 2;
    }

    if (mask == 3) {
      ls.rawSet(-3);
    }
    else {
      ls.pop(2);
    }
  }

  void dRepeated(PbField f, int tag) {
    if (gettype(tag) != PB_TBYTES || (f.packed == 0 && pbWtypebytype(f.typeId) == PB_TBYTES)) {
      dField(f, tag);
      ls.rawSetI(-2, ls.rawLen(-2) + 1);
    }
    else {
      int len = ls.rawLen(-1);
      PbSlice p;
      (p, _) = s.readbytes();
      while (p.len() > 0) {
        PbSlice tmps = s;
        s = p;
        dRawField(f);
        s = tmps;
        ls.rawSetI(-2, ++len);
      }
    }
  }

  bool dMessage(PbType t) {
    int tag;
    int size;

    while (true) {
      (tag, size) = s.readvarint32();
      if (size == 0) {
        break;
      }

      var f = t.findFieldByTag(gettag(tag));
      if (f == null) {
        s.skipvalue(tag);
      }
      else if (f.type != null && f.type!.isMap) {
        ps.fetchTable(ls, f, ps.arrayType);
        dCheckType(f, tag);
        dMap(f);
        ls.pop(1);
      }
      else if (f.repeated){
        ps.fetchTable(ls, f, ps.arrayType);
        dRepeated(f, tag);
        ls.pop(1);
      }
      else {
        ls.pushString(f.name);
        if (f.oneofIdx != 0) {
          ls.pushString(t.oneofIndex[f.oneofIdx]!.name);
          ls.pushValue(-2);
          ls.rawSet(-4);
        }

        dField(f, tag);
        ls.rawSet(-3);
      }
    }

    if (ps.useDecHooks) {
      throw Exception("Not implemented useDecHooks");
    }

    return true;
  }
}
