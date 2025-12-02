import 'package:drift/drift.dart';
import 'package:lyrium/storage/local.dart';
import 'package:lyrium/models.dart';
import 'package:lyrium/utils/search_terms.dart';
import 'package:lyrium/utils/string.dart';

class DataHelper {
  DataHelper._privateConstructor();
  static final DataHelper instance = DataHelper._privateConstructor();

  final AppDatabase db = AppDatabase();

  /// Insert a new track and its lyrics
  Future<int> saveTrack(LyricsTrack track, TrackInfo? extra) async {
    final lyricId = await db
        .into(db.lyrics)
        .insert(
          LyricsCompanion.insert(
            originId: Value("${track.id}"),
            title: track.trackName,
            artist: Value(track.artistName),
            album: Value(track.albumName),
            duration: track.duration ?? extra?.durationseconds ?? 0,
            instrumental: Value(track.instrumental == true),
            lyrics: Value(track.syncedLyrics ?? track.plainLyrics ?? ''),
          ),
        );
    return lyricId;
  }

  Future<List<LyricsTrack>> getAllTracks() async {
    final allLyrics =
        await (db.select(db.lyrics)..orderBy([
              (u) => OrderingTerm(expression: u.id, mode: OrderingMode.desc),
              (u) => OrderingTerm(expression: u.id),
            ]))
            .get();

    return allLyrics.map((e) => LyricsTrack.fromDrift(e)).toList();
  }

  /// Search for tracks
  Future<List<LyricsTrack>> searchTracks(String text) async {
    if (text.trim().isEmpty) return getAllTracks();
    final terms = SearchTerms.parse(text);

    final filter = db.buildSearchFilter(terms);

    final q = db.select(db.lyrics)..where((tbl) => filter);
    final result = await q.get();

    return result.map((e) => LyricsTrack.fromDrift(e)).toList();
  }

  Future<LyricsTrack?> getTrack(TrackInfo trackInfo) async {
    final q = db.select(db.lyrics)
      ..where(
        (t) =>
            t.title.equals(trackInfo.trackName) &
            t.artist.equals(trackInfo.artistName) &
            t.album.equals(trackInfo.albumName),
      )
      ..limit(1);

    final result = await q.getSingleOrNull();
    return result == null ? null : LyricsTrack.fromDrift(result);
  }

  Future<bool> updateTrack(LyricsTrack track) async {
    final q = db.update(db.lyrics)..where((t) => t.id.equals(track.id));

    final updated = await q.write(
      LyricsCompanion(
        title: Value(track.trackName),
        artist: Value(track.albumName ?? ''),
        album: Value(track.albumName ?? ''),
        duration: Value(track.duration ?? 0),
        instrumental: Value(track.instrumental ?? false),
        lyrics: Value(track.syncedLyrics ?? track.plainLyrics ?? ''),
      ),
    );

    return updated > 0;
  }

  Future delete(LyricsTrack track) async {
    return db.delete(db.lyrics)
      ..where((t) => t.id.equals(track.id))
      ..go();
  }

  /// Close database connection
  Future<void> close() => db.close();

  Future<List<Lyric>> insertDraft(title, artist, lyrics) {
    return db
        .into(db.lyrics)
        .insert(
          LyricsCompanion.insert(
            title: title,
            artist: Value(artist),
            duration: 0.0,
            lyrics: Value(lyrics),
          ),
        )
        .then((c) {
          return (db.select(db.lyrics)..where((u) => u.id.equals(c))).get();
        });
  }
}

extension SearchQuery on AppDatabase {
  Expression<bool> buildSearchFilter(SearchTerms terms) {
    final conditions = <Expression<bool>>[];

    if (terms.firstTerm.isValid) {
      conditions.add(lyrics.title.like('%${terms.firstTerm!}%'));
    }

    if (terms.firstTerm.isValid) {
      conditions.add(lyrics.title.like('%${terms.firstTerm!}%'));
    }

    for (final q in terms.quotedTerms) {
      if (q.isValid) {
        conditions.add(lyrics.lyrics.like('%${q}%'));
      }
    }

    // // any unquoted extras
    // for (final u in terms.unquotedExtras) {
    //   conditions.add(
    //     name.like('%$u%') | description.like('%$u%')
    //   );
    // }

    return conditions.fold(const Constant(true), (prev, expr) => prev & expr);
  }
}
