// connection.dart
import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import "none.dart"
    if (dart.library.js_interop) "web.dart"
    if (dart.library.io) "native.dart";

LazyDatabase openConnection(String name) {
  return LazyDatabase(() => openPlatformConnection(name));
}



class MusicNotificationService {
  static get notifications => NotificationConnection.notifications;

  static Future<Image?> getImage() =>
      NotificationConnection.getImage();

  static Future<bool?> hasNotificationAccess() =>
      NotificationConnection.hasNotificationAccess();

  static Future getNowPlaying() =>
      NotificationConnection.getNowPlaying();

  static Future<void> play() => NotificationConnection.play();

  static Future<void> pause() => NotificationConnection.pause();

  static togglePause() => NotificationConnection.togglePause();

  static Future<void> openNotificationAccessSettings() => NotificationConnection.openNotificationAccessSettings();

  static Future<Duration> getPosition() =>
      NotificationConnection.getPosition();

  static Future<void> seekTo(Duration du) =>
      NotificationConnection.seekTo(du);
}
