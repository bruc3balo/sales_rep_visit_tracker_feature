import 'dart:async';

import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';

class GlobalToastMessage {

  GlobalToastMessage._();
  static final GlobalToastMessage _instance = GlobalToastMessage._();

  //Toast
  final StreamController<ToastMessage> _toastStreamController = StreamController.broadcast();
  Stream<ToastMessage> get toastStream => _toastStreamController.stream;

  factory GlobalToastMessage() => _instance;

  void add(ToastMessage toast) {
    if(!_toastStreamController.hasListener) return;
    _toastStreamController.add(toast);
  }

  void dispose() {
    _toastStreamController.close();
  }

}