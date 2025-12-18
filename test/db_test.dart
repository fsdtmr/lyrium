import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyrium/storage/local.dart';
import 'package:lyrium/utils/duration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  test('Insert Test', () async {
    final db = AppDatabase.memory();
    final total = 100;
    for (var i = 0; i < total; i++) {
      await db.insertDemo(i);
    }

    final list = await db.select(db.lyrics).get();

    assert(list.length == total);
  });
}

extension LyricsDatabase on AppDatabase {
  Future<int> insertDemo(int i) {
    return into(lyrics).insert(
      Lyric(
        id: i,
        namespace: "test",
        title: "name$i",
        duration: Durations.extralong1.toDouble(),
        lyricsVersion: 0,
      ),
    );
  }
}
