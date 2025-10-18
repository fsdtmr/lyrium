
import 'package:flutter/widgets.dart';

openPlatformConnection(String name) {
  throw UnimplementedError();
}

class NotificationConnection {
  static Stream<Map?> get notifications async* {
    throw UnimplementedError();
  }

  static Future<void> openNotificationAccessSettings() async {
    throw UnimplementedError();
  }

  static Future<Map?> getNowPlaying() async {
    throw UnimplementedError();
  }

  static Future<bool> seekTo(Duration position) async {
    throw UnimplementedError();
  }

  static Future<Duration> getPosition() async {
    throw UnimplementedError();
  }

  static Future<Image?> getImage() async {
    throw UnimplementedError();
 
  }

  static bool imaginepause = true;
  static togglePause() {
    throw UnimplementedError();
 
  }

  static Future<bool> play() async {
    throw UnimplementedError();
  }

  static Future<bool> pause() async {
    throw UnimplementedError();
  }

  static Future<bool> hasNotificationAccess() async {
    throw UnimplementedError();
  }
}
