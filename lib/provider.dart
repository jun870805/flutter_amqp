import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'amqp.dart';

class AMQPMessage with ChangeNotifier {
  String _receiveMessage = "";

  get receiveMessage => _receiveMessage;

  // Change receive message
  void changeReceiveMessage(String message){
    _receiveMessage = message;
    notifyListeners();
  }
}