import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

Future<StoppableIsolate> spawnIsolate() async {
  if(kIsWeb){
    Timer.periodic(new Duration(seconds: 1), (Timer t) {
      int tic =  t.tick;
      print('timer = $tic');
      if(tic == 10){
        print('stop !');
        t.cancel();
      }
    });
  } else {
    ReceivePort receivePort = new ReceivePort();
    Isolate isolate = await Isolate.spawn(
            (message) => checkTimer(sendPort: message), receivePort.sendPort);
    return StoppableIsolate(isolate, receivePort);
  }
}

void checkTimer({SendPort sendPort}) async {
  int _counter = 0;
  Timer.periodic(new Duration(seconds: 1), (Timer t) {
    _counter++;
    String msg = _counter.toString();
    print('SEND: ' + msg);
    if (_counter % 10 == 0) {
      sendPort.send(msg);
    }
  });
}

class StoppableIsolate {
  final Isolate isolate;
  final ReceivePort receivePort;

  StoppableIsolate(this.isolate, this.receivePort);

  void stop() {
    receivePort.close();
    isolate.kill(priority: Isolate.immediate);
  }
}
