import 'package:crypto/crypto.dart';
import 'package:lua_dardo_co/lua.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:crypton/crypton.dart';

class CryptoLib {
  static const Map<String, DartFunction> _cryptoFuncs = {
    "base64encode": _base64Encode,
    "base64decode": _base64Decode,
    "rsa_decrypt": _rsaDecrypt,
    "hmac_sha256": _hmacSha256,
  };

  static int openCryptoLib(LuaState ls) {
    ls.newLib(_cryptoFuncs);
    return 1;
  }

  static int _base64Encode(LuaState ls) {
    Userdata? bytes = ls.toUserdata(-1);
    if (bytes == null) {
      ls.pushNil();
      return 1;
    }

    if (bytes.data is Uint8List) {
      Uint8List data = bytes.data as Uint8List;
      String encoded = base64Encode(data);
      ls.pushString(encoded);
    } else {
      ls.pushNil();
    }

    return 1;
  }

  static int _base64Decode(LuaState ls) {
    String? encoded = ls.toStr(-1);
    if (encoded == null) {
      ls.pushNil();
      return 1;
    }

    try {
      Uint8List decoded = base64Decode(encoded);
      Userdata ud = ls.newUserdata();
      ud.data = decoded;
    } catch (e) {
      ls.pushNil();
    }

    return 1;
  }

  static int _rsaDecrypt(LuaState ls) {
    String? key = ls.toStr(1);
    Userdata? content = ls.toUserdata(2);

    if (key == null || content == null) {
      ls.pushNil();
      return 1;
    }

    if (content.data is! Uint8List) {
      ls.pushNil();
      return 1;
    }

    try {
      RSAKeypair rsaKeypair = RSAKeypair(RSAPrivateKey.fromString(key));
      Uint8List decrypted =
          rsaKeypair.privateKey.decryptData(content.data as Uint8List);
      Userdata ud = ls.newUserdata();
      ud.data = decrypted;
    } catch (e) {
      ls.pushNil();
    }
    return 1;
  }

  static int _hmacSha256(LuaState ls) {
    String key = ls.checkString(1)!;
    String data = ls.checkString(2)!;

    var utf8Key = utf8.encode(key);
    var utf8Data = utf8.encode(data);
    var hmacSha256 = Hmac(sha256, utf8Key);
    var digest = hmacSha256.convert(utf8Data);

    ls.pushString(digest.toString());

    return 1;
  }
}
