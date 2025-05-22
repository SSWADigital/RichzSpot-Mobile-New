/*
 *   Webkul Software.
 *   @package Mobikul Application Code.
 *   @Category Mobikul
 *   @author Webkul <support@webkul.com>
 *   @Copyright (c) Webkul Software Private Limited (https://webkul.com)
 *   @license https://store.webkul.com/license.html
 *   @link https://store.webkul.com/license.html
 */


import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class ShowMessage {
  static void successNotification(String msg, BuildContext context) {
  showSimpleNotification(
    Text(
      msg,
      style: const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    context: context,
    background: const Color.fromRGBO(140, 194, 74, 1.0), // Perbaiki nilai alpha menjadi 1.0 (opaque) atau nilai lain sesuai keinginan
    leading: const Icon(
      Icons.check_circle_outline,
      color: Colors.white,
    ),
    slideDismissDirection: DismissDirection.up,
    // subtitle: Text(msg, style: const TextStyle(color: Colors.white)), // Hapus subtitle yang duplikat
  );
}
  static errorNotification(String msg, BuildContext context) {
    return showSimpleNotification(Text("Failed", style: const TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold,color: Colors.white)),
        context: context,
        background: Colors.red,
        leading: const Icon(
          Icons.cancel_outlined,
          color: Colors.white,
        ),
        slideDismissDirection: DismissDirection.up,
        subtitle: Text(msg,style: const TextStyle(color: Colors.white),));
  }
  static warningNotification(String msg, BuildContext context, {String? title}) {
    return showSimpleNotification(Text(title ?? "Warning",style: const TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold,color: Colors.white)),
        context: context,
        background: Colors.amber,
        leading: const Icon(
          Icons.warning_amber,
          color: Colors.white,
        ),
        slideDismissDirection: DismissDirection.up,
        subtitle: Text(msg,style: const TextStyle(color: Colors.white),));
  }

  static showNotification(
      String? title, String? message, Color? color, Icon icon) {
    return showSimpleNotification(
        Text(
          title!,
          style: const TextStyle(
              fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        background: color,
        leading: icon,
        slideDismissDirection: DismissDirection.up,
        subtitle: Text(
          message ?? "Something Wrong!",
          style: const TextStyle(color: Colors.white),
        ));
  }
}
