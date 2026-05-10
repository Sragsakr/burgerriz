import 'dart:developer';

import 'package:flutter/foundation.dart';

void appDebugger(val, {String? error}) {
  if (kDebugMode) {
    dPrint(error ?? val.toString());
    if (error != null) {
      log(val, error: error);
    } else {
      log(val.toString());
    }
  }
}

void dPrint(dynamic message, {int level = 1, String? tag}) {
  if (kDebugMode) {
    var a = StackTrace.current;
    final regexCodeLine = RegExp(r" (\(.*\))$");
    var i = regexCodeLine
        .stringMatch(a.toString().split("\n")[level])
        .toString()
        .replaceAll("(", "")
        .replaceAll(")", "")
        .trim() /*.split("/")*/;
    var tPrent = "$i\n${tag != null ? "$tag: " : ""}$message";
    if (message.length > 1000) {
      log(tPrent);
    } else {
      print(tPrent);
    }
  }
}
