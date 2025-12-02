import 'package:lyrium/storage/local.dart';
import 'package:lyrium/utils/string.dart';

class TrackInfo {
  final String artistName;
  final String trackName;
  final String albumName;
  final double durationseconds;

  TrackInfo({
    required this.artistName,
    required this.trackName,
    required this.albumName,
    required this.durationseconds,
  });

  static List<String> advertisement = ["Advertisement", "Sponsored"];
  static List<String> clearArtists = [
    "•",
    "Recommended for you",
    "Unknown Artist",
  ];

  static List<String> replacewithSpace = ["/"];
  TrackInfo clearTemplates() {
    String clearedTrack = trackName;
    String clearedArtist = artistName;
    String clearedAlbum = albumName;

    for (var e in advertisement) {
      clearedTrack = replaceFirstCaseInsensitive(clearedTrack, e).trim();
    }

    for (var e in clearArtists) {
      clearedArtist = replaceFirstCaseInsensitive(clearedArtist, e).trim();
    }

    for (var e in replacewithSpace) {
      clearedArtist = replaceFirstCaseInsensitive(clearedArtist, e, " ").trim();
    }

    return TrackInfo(
      artistName: clearedArtist,
      trackName: clearedTrack,
      albumName: clearedAlbum,
      durationseconds: durationseconds,
    );
  }
}

class LyricsTrack {
  final int id;
  final String namespace;
  final String trackName;
  final String? artistName;
  final String? albumName;
  final double? duration;
  final bool? instrumental;
  final String? plainLyrics;
  final String? syncedLyrics;

  LyricsTrack({
    required this.id,
    required this.trackName,
    this.artistName,
    this.albumName,
    this.duration,
    this.instrumental,
    this.plainLyrics,
    this.syncedLyrics,
    required this.namespace,
  });
  @override
  String toString() {
    return toMap().toString();
  }

  static LyricsTrack fromMap(String namespace, Map<String, dynamic> map) {
    return LyricsTrack(
      id: map['id'],
      trackName: map['trackName'],
      artistName: map['artistName'],
      albumName: map['albumName'],
      duration: map['duration'],
      instrumental: map['instrumental'] == 1,
      plainLyrics: map['plainLyrics'],
      syncedLyrics: map['syncedLyrics'],
      namespace: namespace,
    );
  }

  Map<String, dynamic> toMap({TrackInfo? info}) {
    return {
      'id': id,
      'trackName': info?.trackName ?? trackName,
      'artistName': info?.artistName ?? artistName,
      'albumName': info?.albumName ?? albumName,
      'duration': info?.durationseconds ?? duration,
      'instrumental': instrumental == true ? 1 : 0,
      'plainLyrics': plainLyrics,
      'syncedLyrics': syncedLyrics,
    };
  }

  static LyricsTrack fromDrift(Lyric lyric) {
    return LyricsTrack(
      id: lyric.id,
      trackName: lyric.title,
      artistName: lyric.artist,
      albumName: lyric.album,
      duration: lyric.duration,
      instrumental: lyric.instrumental ?? false,
      plainLyrics: lyric.lyrics,
      syncedLyrics: lyric.lyrics,
      namespace: 'local',
    );
  }

  TrackInfo toInfo() {
    return TrackInfo(
      trackName: trackName,
      artistName: artistName ?? "Not Set",
      albumName: albumName ?? "Not Set",
      durationseconds: duration ?? 0,
    );
  }

  static empty() {
    return LyricsTrack(id: -1, trackName: "", namespace: "Template");
  }

  LyricsTrack copyWith({
    int? id,
    String? namespace,
    String? trackName,
    String? artistName,
    String? albumName,
    double? duration,
    bool? instrumental,
    String? plainLyrics,
    String? syncedLyrics,
  }) {
    return LyricsTrack(
      id: id ?? this.id,
      namespace: namespace ?? this.namespace,
      trackName: trackName ?? this.trackName,
      artistName: artistName ?? this.artistName,
      albumName: albumName ?? this.albumName,
      duration: duration ?? this.duration,
      instrumental: instrumental ?? this.instrumental,
      plainLyrics: plainLyrics ?? this.plainLyrics,
      syncedLyrics: syncedLyrics ?? this.syncedLyrics,
    );
  }
}
