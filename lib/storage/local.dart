import 'package:drift/drift.dart';
import 'package:lyrium/service/service.dart';

part 'local.g.dart';
 

class Lyrics extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get namespace => text()();
  TextColumn get originId => text().nullable()();
  IntColumn get interlinked =>
      integer().nullable().references(Lyrics, #id)(); 
  IntColumn get language => integer().nullable()();
  TextColumn get title => text()();
  TextColumn get artist => text().nullable()();
  TextColumn get album => text().nullable()();
  RealColumn get duration =>
      real()(); // seconds.milliseconds as double (e.g. 15.123)
  BoolColumn get instrumental => boolean().nullable()();
  IntColumn get lyricsVersion => integer().withDefault(const Constant(-1))();
  TextColumn get lyrics => text().nullable()();
  TextColumn get attachments => text().nullable()();
}


@DriftDatabase(tables: [Lyrics])
class AppDatabase extends _$AppDatabase {
  final String name;
  AppDatabase({this.name = "lyrium"}) : super(_openConnection(name));

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection(String name) {
  return openConnection(name);
}
