import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyrium/api.dart';
import 'package:lyrium/datahelper.dart';
import 'package:lyrium/editor.dart';
import 'package:lyrium/service/service.dart';
import 'package:lyrium/models.dart';
import 'package:lyrium/utils/duration.dart';
import 'package:lyrium/widgets/submit_form.dart';

class AppController extends ChangeNotifier {
  bool hasNotificationAccess;
  Track? info;
  Duration? duration;
  Duration? progress;
  bool isPlaying = false;
  LyricsTrack? lyrics;

  StreamSubscription? _notificationSubscription;
  Timer? _polling;

  // bool isReady = false;

  bool showTrack = false;

  late GlobalKey rebuildKey;

  AppController(this.hasNotificationAccess) {
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(Duration(seconds: 2));
    await _checkAccessAndStream();
    _startPolling();
  }

  void _startPolling() {
    _polling = Timer.periodic(const Duration(seconds: 5), (t) async {
      try {
        await MusicNotificationService.update();
      } catch (e) {
        debugPrint('Polling error: $e');
        t.cancel();
      }
    });
  }

  Future<void> _checkAccessAndStream() async {
    try {
      late Function(Map<dynamic, dynamic>? data) reader;

      reader = (Map<dynamic, dynamic>? data) {
        _setData(data);

        if (isPlaying) {
          showTrack = true;
        }

        reader = (Map<dynamic, dynamic>? data) => _setData(data);
      };

      if (hasNotificationAccess) {
        _notificationSubscription = MusicNotificationService.notifications
            .listen((m) => reader(m));
      }
    } on PlatformException catch (e) {
      debugPrint("Access check failed: ${e.message}");
    }
  }

  var IS_PLAYING = 'isPlaying';

  void _setData(Map<dynamic, dynamic>? data) async {
    if (data == null) {
      info = null;
      lyrics = null;
      duration = null;
      progress = null;
      return;
    } else {
      final prevName = info?.trackName;

      info = parseData(data);

      if (prevName != info?.trackName && !unattachedMode) {
        await _onTrackChanged();
      }
    }

    notifyListeners();
  }

  Track parseData(Map<dynamic, dynamic> data) {
    duration = Duration(milliseconds: (data["duration"] as int?) ?? 0);
    progress = Duration(milliseconds: (data["position"] as int?) ?? 0);
    isPlaying = data[IS_PLAYING] as bool? ?? false;
    return Track(
      namespace: data["package"] ?? "Device",
      artistName: data["artist"] ?? "Invalid",
      trackName: data["title"] ?? "Invalid",
      albumName: data["album"] ?? "Invalid",
      duration: duration?.inDouble ?? 1,
    );
  }

  Future<Image?>? image;

  Future<void> _onTrackChanged() async {
    if (info == null) {
      image = null;
      lyrics = null;
    } else {
      image = MusicNotificationService.getImage().then((v) async {
        if (v == null) {
          await Future.delayed(Durations.extralong3);
          return MusicNotificationService.getImage();
        }
        return v;
      });
      lyrics = await DataHelper.instance.getTrack(info!);
    }
    notifyListeners();
  }

  Future<void> autoLoad() async {
    if (info == null) return;

    final api = ApiHandler();
    final lyricsData = await api.get(info!);

    startLyricsSaved(lyricsData.first, true);
  }

  Future<void> startLyricsSaved(
    LyricsTrack track, [
    bool attached = false,
  ]) async {
    await DataHelper.instance.saveTrack(track, info);
    setLyrics(track, attached);
  }

  var unattachedMode = false;
  void setLyrics(LyricsTrack? track, [bool attached = false]) {
    lyrics = track?.fallBackDuration();
    unattachedMode = !attached;
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

  void setInfo(Track? newinfo) {
    info = newinfo;
    notifyListeners();
  }

  openEditor(context, Track? initailQuery) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (c) => LyricsEditor(track: LyricsTrack.empty(initailQuery)),
      ),
    );
  }

  void submitLyrics(BuildContext context) {
    if (lyrics is DraftTrack) opensubmitform(context, lyrics as DraftTrack);
  }

  void openLyrics(LyricsTrack song) {
    setLyrics(song);
    if (hasNotificationAccess) {
      setInfo(null);
      setShowTrackMode(true);
    }

    notifyListeners();
  }

  void setHasAccess(bool? ac) {
    hasNotificationAccess = ac ?? false;

    notifyListeners();
  }

  // Future<void> rebuildUntil(bool Function() param0) async {
  //   while (param0()) {
  //     hasNotificationAccess =
  //         await MusicNotificationService.hasNotificationAccess();
  //     notifyListeners();
  //     Future.delayed(Durations.extralong4);
  //   }
  // }
}

extension on LyricsTrack {
  LyricsTrack fallBackDuration() {
    if (track.duration.toDuration() < Durations.extralong4) {
      return copyWith(duration: Duration(hours: 1).toDouble());
    }
    return this;
  }
}

abstract class NonListeningController {
  final LyricsTrack lyrics;

  NonListeningController({required this.lyrics});
  Future<void> togglePause(bool b);
  Future<void> seek(Duration duration);
  Future<Duration> getPosition();

  bool get isPlaying;
  Duration? get atPosition;
  Duration get duration;
}

class TempController extends NonListeningController {
  final Future<void> Function(bool) onTogglePause;
  final Future<void> Function(Duration) onSeek;
  final Future<Duration> Function() getPrimaryPosition;
  @override
  final Duration? atPosition;
  @override
  final bool isPlaying;
  TempController({
    required super.lyrics,
    required this.onTogglePause,
    required this.onSeek,
    required this.getPrimaryPosition,
    required this.isPlaying,
    this.atPosition,
  });

  @override
  Future<Duration> getPosition() => getPrimaryPosition();
  @override
  Future<void> seek(Duration duration) => onSeek(duration);
  @override
  Future<void> togglePause(bool b) => onTogglePause(b);
  @override
  Duration get duration =>
      lyrics.track.duration.toDuration() ?? Duration(hours: 1);
}

class NoOpController extends NonListeningController {
  NoOpController({required super.lyrics});

  @override
  Duration? get atPosition => Duration.zero;

  @override
  Future<Duration> getPosition() async => Duration.zero;
  @override
  bool get isPlaying => true;

  @override
  Future<void> seek(Duration duration) async {}

  @override
  Future<void> togglePause(bool b) async {}

  @override
  Duration get duration =>
      lyrics.track.duration.toDuration() ?? Duration(hours: 1);
}
