import 'dart:async';
import "../../types/manager/completer.dart";
import "../../types/manager/actions.dart";
import "./payload/gallery.dart";


Future<String> gallery() async {
  Completer<Object> completer = Completer<Object>();
  int retId = completerManager.genCompleteId();

  actionsManager.addAction(Gallery.toAction(retId, "dmzj"));

  completerManager.addCompleter(retId, completer);
  var ret = await completer.future;

  return ret.toString();
}
