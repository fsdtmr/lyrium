import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyrium/api.dart';
import 'package:lyrium/datahelper.dart';
import 'package:lyrium/service/service.dart';
import 'package:lyrium/models.dart';
import 'package:lyrium/utils/duration.dart';

class MusicController extends ChangeNotifier {
  TrackInfo? info;
  String? package;
  Duration? duration;
  Duration? progress;
  bool isPlaying = false;
  LyricsTrack? lyrics;

  bool? _hasAccess = false;
  bool get hasAccess => _hasAccess ?? false;

  StreamSubscription? _notificationSubscription;
  Timer? _polling;

  bool isReady = false;

  bool showTrack = false;

  late GlobalKey rebuildKey;

  MusicController() {
    _init();
  }

  Future<void> _init() async {
    //TODO: fix too much work on startup
    await Future.delayed(Duration(seconds: 2));
    await _checkAccessAndStream();
    _startPolling();
  }

  void _startPolling() {
    _polling = Timer.periodic(const Duration(seconds: 5), (t) async {
      try {
        final data = await MusicNotificationService.getNowPlaying();
        _setData(data);
      } catch (e) {
        debugPrint('Polling error: $e');
        t.cancel();
      }
    });
  }

  Future<void> _checkAccessAndStream() async {
    try {
      _hasAccess = await MusicNotificationService.hasNotificationAccess();
      isReady = true;
      notifyListeners();

      if (hasAccess) {
        _notificationSubscription = MusicNotificationService.notifications
            .listen(_setData);
        final data = await MusicNotificationService.getNowPlaying();

        if (data != null) {
          try {
            final playing = data["isPlaying"] as bool? ?? false;
            if (playing) {
              showTrack = true;
            }
          } catch (e) {
            debugPrint(e.toString());
          }
        }

        _setData(data);
      }
    } on PlatformException catch (e) {
      debugPrint("Access check failed: ${e.message}");
    }
  }

  void _setData(Map<dynamic, dynamic>? data) async {
    if (data == null) {
      info = null;
      lyrics = null;
      duration = null;
      progress = null;
      isPlaying = false;
      return;
    } else {
      final prevName = info?.trackName;

      package = data["package"];
      duration = Duration(milliseconds: (data["duration"] as int?) ?? 0);
      progress = Duration(milliseconds: (data["progress"] as int?) ?? 0);
      isPlaying = data["isPlaying"] as bool? ?? false;

      info = TrackInfo(
        artistName: data["artist"],
        trackName: data["title"],
        albumName: data["album"],
        durationseconds: duration.inDouble,
      );

      if (prevName != info?.trackName) {
        await _onTrackChanged();
      }
    }

    notifyListeners();
  }

  Future<void> _onTrackChanged() async {
    if (info == null) {
      lyrics = null;
    } else {
      lyrics = await DataHelper.instance.getTrack(info!);
    }
    notifyListeners();
  }


  Future<void> fetchAndSaveLyrics() async {
    if (info == null) return;

    final api = ApiHandler();
    final lyricsData = await api.find(info!);

    await DataHelper.instance.saveTrack(lyricsData.first, info);
    setLyrics(lyricsData.first);
  }

  Future<void> saveLyrics(LyricsTrack track) async {
    await DataHelper.instance.saveTrack(track, info);
    setLyrics(track);
  }

  void setLyrics(LyricsTrack? track) {
    lyrics = track;
    notifyListeners();
  }

  /// Control playback
  Future<void> play() async => await MusicNotificationService.play();
  Future<void> pause() async => await MusicNotificationService.pause();
  Future<void> togglePause({bool? pause}) async => pause == null
      ? MusicNotificationService.togglePause()
      : pause
      ? MusicNotificationService.pause()
      : MusicNotificationService.play();

  Future<void> seek(double fraction) async {
    if (duration == null) return;
    await MusicNotificationService.seekTo(duration! * fraction);
  }

  Future<void> seekTo(Duration? du) async {
    if (du == null) return;
    await MusicNotificationService.seekTo(du);
  }

  Future<Duration> position() async {
    return await MusicNotificationService.getPosition();
  }

  /// Open system settings for access
  Future<void> openNotificationAccessSettings() async {
    await MusicNotificationService.openNotificationAccessSettings();
    await _checkAccessAndStream();
  }


  double get progressValue => duration != null && duration!.inMilliseconds > 0
      ? (progress?.inMilliseconds ?? 0) / (duration!.inMilliseconds)
      : 0.0;

  String formatDuration(Duration? d) {
    if (d == null) return '00:00';
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _polling?.cancel();
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void setShowTrackMode(bool mode) {
    showTrack = mode;
    notifyListeners();
  }

  void setInfo(TrackInfo? newinfo) {
    info = newinfo;
    notifyListeners();
  }
}
