import 'package:lyrium/storage/local.dart';

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

  static List<String> advertisement = ["Advertisement"];
  static List<String> clearArtists = ["Recommended for you", "•"];
  TrackInfo? clearTemplates() {
    String clearedTrack = trackName;
    String clearedArtist = artistName;
    String clearedAlbum = albumName;

    for (var e in advertisement) {
      clearedTrack = clearedTrack.replaceFirst(e, "").trim();
    }

    for (var e in clearArtists) {
      clearedArtist = clearedArtist.replaceFirst(e, "").trim();
    }

    if (advertisement.any((e) => clearedArtist.contains(e))) {
      return null;
    }

    if (trackName == "") {
      return null;
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
  });

  factory LyricsTrack.fromJson(Map<String, dynamic> json) {
    return LyricsTrack(
      id: json['id'] as int,
      trackName: json['trackName'] as String? ?? 'Unknown Track',
      artistName: json['artistName'] as String?,
      albumName: json['albumName'] as String?,
      duration: json['duration'] as double?,
      instrumental: json['instrumental'] as bool?,
      plainLyrics: json['plainLyrics'] as String?,
      syncedLyrics: json['syncedLyrics'] as String?,
      // url:
      //     'artist_name=${Uri.encodeComponent(json['artistName'])}&track_name=${Uri.encodeComponent(json['trackName'])}&album_name=${Uri.encodeComponent(json['albumName'])}&duration=${json['duration']}',
    );
  }
  @override
  String toString() {
    return toMap().toString();
  }

  static LyricsTrack fromMap(Map<String, dynamic> map) {
    return LyricsTrack(
      id: map['id'],
      trackName: map['trackName'],
      artistName: map['artistName'],
      albumName: map['albumName'],
      duration: map['duration'],
      instrumental: map['instrumental'] == 1,
      plainLyrics: map['plainLyrics'],
      syncedLyrics: map['syncedLyrics'],
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
    );
  }
}
