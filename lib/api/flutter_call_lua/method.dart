import 'dart:async';
import "../../types/manager/completer.dart";
import "../../types/manager/actions.dart";
import "./payload/gallery.dart";
import "./payload/get_detail.dart";


Future<List<Object>> gallery() async {
  Completer<Object> completer = Completer<Object>();
  int retId = completerManager.genCompleteId();

  actionsManager.addAction(Gallery.toAction(retId, "ddv"));

  completerManager.addCompleter(retId, completer);
  var ret = await completer.future;

  return ret as List<Object>;
}

Future<void> getDetail(Map<String, dynamic> extra) async {
  Completer<Object> completer = Completer<Object>();
  int retId = completerManager.genCompleteId();

  actionsManager.addAction(GetDetail.toAction(retId, "ddv", extra));

  completerManager.addCompleter(retId, completer);
  await completer.future;
}
