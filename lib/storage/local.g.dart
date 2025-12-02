// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local.dart';

// ignore_for_file: type=lint
class $LyricsTable extends Lyrics with TableInfo<$LyricsTable, Lyric> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LyricsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _namespaceMeta = const VerificationMeta(
    'namespace',
  );
  @override
  late final GeneratedColumn<String> namespace = GeneratedColumn<String>(
    'namespace',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant("originid"),
  );
  static const VerificationMeta _originIdMeta = const VerificationMeta(
    'originId',
  );
  @override
  late final GeneratedColumn<String> originId = GeneratedColumn<String>(
    'origin_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _interlinkedMeta = const VerificationMeta(
    'interlinked',
  );
  @override
  late final GeneratedColumn<int> interlinked = GeneratedColumn<int>(
    'interlinked',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES lyrics (id)',
    ),
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<int> language = GeneratedColumn<int>(
    'language',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<double> duration = GeneratedColumn<double>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instrumentalMeta = const VerificationMeta(
    'instrumental',
  );
  @override
  late final GeneratedColumn<bool> instrumental = GeneratedColumn<bool>(
    'instrumental',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("instrumental" IN (0, 1))',
    ),
  );
  static const VerificationMeta _lyricsVersionMeta = const VerificationMeta(
    'lyricsVersion',
  );
  @override
  late final GeneratedColumn<int> lyricsVersion = GeneratedColumn<int>(
    'lyrics_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(-1),
  );
  static const VerificationMeta _lyricsMeta = const VerificationMeta('lyrics');
  @override
  late final GeneratedColumn<String> lyrics = GeneratedColumn<String>(
    'lyrics',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attachmentsMeta = const VerificationMeta(
    'attachments',
  );
  @override
  late final GeneratedColumn<String> attachments = GeneratedColumn<String>(
    'attachments',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    namespace,
    originId,
    interlinked,
    language,
    title,
    artist,
    album,
    duration,
    instrumental,
    lyricsVersion,
    lyrics,
    attachments,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lyrics';
  @override
  VerificationContext validateIntegrity(
    Insertable<Lyric> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('namespace')) {
      context.handle(
        _namespaceMeta,
        namespace.isAcceptableOrUnknown(data['namespace']!, _namespaceMeta),
      );
    }
    if (data.containsKey('origin_id')) {
      context.handle(
        _originIdMeta,
        originId.isAcceptableOrUnknown(data['origin_id']!, _originIdMeta),
      );
    }
    if (data.containsKey('interlinked')) {
      context.handle(
        _interlinkedMeta,
        interlinked.isAcceptableOrUnknown(
          data['interlinked']!,
          _interlinkedMeta,
        ),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('instrumental')) {
      context.handle(
        _instrumentalMeta,
        instrumental.isAcceptableOrUnknown(
          data['instrumental']!,
          _instrumentalMeta,
        ),
      );
    }
    if (data.containsKey('lyrics_version')) {
      context.handle(
        _lyricsVersionMeta,
        lyricsVersion.isAcceptableOrUnknown(
          data['lyrics_version']!,
          _lyricsVersionMeta,
        ),
      );
    }
    if (data.containsKey('lyrics')) {
      context.handle(
        _lyricsMeta,
        lyrics.isAcceptableOrUnknown(data['lyrics']!, _lyricsMeta),
      );
    }
    if (data.containsKey('attachments')) {
      context.handle(
        _attachmentsMeta,
        attachments.isAcceptableOrUnknown(
          data['attachments']!,
          _attachmentsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lyric map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lyric(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      namespace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}namespace'],
      )!,
      originId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_id'],
      ),
      interlinked: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interlinked'],
      ),
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}language'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      ),
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}duration'],
      )!,
      instrumental: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}instrumental'],
      ),
      lyricsVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lyrics_version'],
      )!,
      lyrics: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lyrics'],
      ),
      attachments: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachments'],
      ),
    );
  }

  @override
  $LyricsTable createAlias(String alias) {
    return $LyricsTable(attachedDatabase, alias);
  }
}

class Lyric extends DataClass implements Insertable<Lyric> {
  final int id;
  final String namespace;
  final String? originId;
  final int? interlinked;
  final int? language;
  final String title;
  final String? artist;
  final String? album;
  final double duration;
  final bool? instrumental;
  final int lyricsVersion;
  final String? lyrics;
  final String? attachments;
  const Lyric({
    required this.id,
    required this.namespace,
    this.originId,
    this.interlinked,
    this.language,
    required this.title,
    this.artist,
    this.album,
    required this.duration,
    this.instrumental,
    required this.lyricsVersion,
    this.lyrics,
    this.attachments,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['namespace'] = Variable<String>(namespace);
    if (!nullToAbsent || originId != null) {
      map['origin_id'] = Variable<String>(originId);
    }
    if (!nullToAbsent || interlinked != null) {
      map['interlinked'] = Variable<int>(interlinked);
    }
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<int>(language);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    map['duration'] = Variable<double>(duration);
    if (!nullToAbsent || instrumental != null) {
      map['instrumental'] = Variable<bool>(instrumental);
    }
    map['lyrics_version'] = Variable<int>(lyricsVersion);
    if (!nullToAbsent || lyrics != null) {
      map['lyrics'] = Variable<String>(lyrics);
    }
    if (!nullToAbsent || attachments != null) {
      map['attachments'] = Variable<String>(attachments);
    }
    return map;
  }

  LyricsCompanion toCompanion(bool nullToAbsent) {
    return LyricsCompanion(
      id: Value(id),
      namespace: Value(namespace),
      originId: originId == null && nullToAbsent
          ? const Value.absent()
          : Value(originId),
      interlinked: interlinked == null && nullToAbsent
          ? const Value.absent()
          : Value(interlinked),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
      title: Value(title),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      album: album == null && nullToAbsent
          ? const Value.absent()
          : Value(album),
      duration: Value(duration),
      instrumental: instrumental == null && nullToAbsent
          ? const Value.absent()
          : Value(instrumental),
      lyricsVersion: Value(lyricsVersion),
      lyrics: lyrics == null && nullToAbsent
          ? const Value.absent()
          : Value(lyrics),
      attachments: attachments == null && nullToAbsent
          ? const Value.absent()
          : Value(attachments),
    );
  }

  factory Lyric.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lyric(
      id: serializer.fromJson<int>(json['id']),
      namespace: serializer.fromJson<String>(json['namespace']),
      originId: serializer.fromJson<String?>(json['originId']),
      interlinked: serializer.fromJson<int?>(json['interlinked']),
      language: serializer.fromJson<int?>(json['language']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String?>(json['artist']),
      album: serializer.fromJson<String?>(json['album']),
      duration: serializer.fromJson<double>(json['duration']),
      instrumental: serializer.fromJson<bool?>(json['instrumental']),
      lyricsVersion: serializer.fromJson<int>(json['lyricsVersion']),
      lyrics: serializer.fromJson<String?>(json['lyrics']),
      attachments: serializer.fromJson<String?>(json['attachments']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'namespace': serializer.toJson<String>(namespace),
      'originId': serializer.toJson<String?>(originId),
      'interlinked': serializer.toJson<int?>(interlinked),
      'language': serializer.toJson<int?>(language),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String?>(artist),
      'album': serializer.toJson<String?>(album),
      'duration': serializer.toJson<double>(duration),
      'instrumental': serializer.toJson<bool?>(instrumental),
      'lyricsVersion': serializer.toJson<int>(lyricsVersion),
      'lyrics': serializer.toJson<String?>(lyrics),
      'attachments': serializer.toJson<String?>(attachments),
    };
  }

  Lyric copyWith({
    int? id,
    String? namespace,
    Value<String?> originId = const Value.absent(),
    Value<int?> interlinked = const Value.absent(),
    Value<int?> language = const Value.absent(),
    String? title,
    Value<String?> artist = const Value.absent(),
    Value<String?> album = const Value.absent(),
    double? duration,
    Value<bool?> instrumental = const Value.absent(),
    int? lyricsVersion,
    Value<String?> lyrics = const Value.absent(),
    Value<String?> attachments = const Value.absent(),
  }) => Lyric(
    id: id ?? this.id,
    namespace: namespace ?? this.namespace,
    originId: originId.present ? originId.value : this.originId,
    interlinked: interlinked.present ? interlinked.value : this.interlinked,
    language: language.present ? language.value : this.language,
    title: title ?? this.title,
    artist: artist.present ? artist.value : this.artist,
    album: album.present ? album.value : this.album,
    duration: duration ?? this.duration,
    instrumental: instrumental.present ? instrumental.value : this.instrumental,
    lyricsVersion: lyricsVersion ?? this.lyricsVersion,
    lyrics: lyrics.present ? lyrics.value : this.lyrics,
    attachments: attachments.present ? attachments.value : this.attachments,
  );
  Lyric copyWithCompanion(LyricsCompanion data) {
    return Lyric(
      id: data.id.present ? data.id.value : this.id,
      namespace: data.namespace.present ? data.namespace.value : this.namespace,
      originId: data.originId.present ? data.originId.value : this.originId,
      interlinked: data.interlinked.present
          ? data.interlinked.value
          : this.interlinked,
      language: data.language.present ? data.language.value : this.language,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      duration: data.duration.present ? data.duration.value : this.duration,
      instrumental: data.instrumental.present
          ? data.instrumental.value
          : this.instrumental,
      lyricsVersion: data.lyricsVersion.present
          ? data.lyricsVersion.value
          : this.lyricsVersion,
      lyrics: data.lyrics.present ? data.lyrics.value : this.lyrics,
      attachments: data.attachments.present
          ? data.attachments.value
          : this.attachments,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lyric(')
          ..write('id: $id, ')
          ..write('namespace: $namespace, ')
          ..write('originId: $originId, ')
          ..write('interlinked: $interlinked, ')
          ..write('language: $language, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('duration: $duration, ')
          ..write('instrumental: $instrumental, ')
          ..write('lyricsVersion: $lyricsVersion, ')
          ..write('lyrics: $lyrics, ')
          ..write('attachments: $attachments')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    namespace,
    originId,
    interlinked,
    language,
    title,
    artist,
    album,
    duration,
    instrumental,
    lyricsVersion,
    lyrics,
    attachments,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lyric &&
          other.id == this.id &&
          other.namespace == this.namespace &&
          other.originId == this.originId &&
          other.interlinked == this.interlinked &&
          other.language == this.language &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.duration == this.duration &&
          other.instrumental == this.instrumental &&
          other.lyricsVersion == this.lyricsVersion &&
          other.lyrics == this.lyrics &&
          other.attachments == this.attachments);
}

class LyricsCompanion extends UpdateCompanion<Lyric> {
  final Value<int> id;
  final Value<String> namespace;
  final Value<String?> originId;
  final Value<int?> interlinked;
  final Value<int?> language;
  final Value<String> title;
  final Value<String?> artist;
  final Value<String?> album;
  final Value<double> duration;
  final Value<bool?> instrumental;
  final Value<int> lyricsVersion;
  final Value<String?> lyrics;
  final Value<String?> attachments;
  const LyricsCompanion({
    this.id = const Value.absent(),
    this.namespace = const Value.absent(),
    this.originId = const Value.absent(),
    this.interlinked = const Value.absent(),
    this.language = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.duration = const Value.absent(),
    this.instrumental = const Value.absent(),
    this.lyricsVersion = const Value.absent(),
    this.lyrics = const Value.absent(),
    this.attachments = const Value.absent(),
  });
  LyricsCompanion.insert({
    this.id = const Value.absent(),
    this.namespace = const Value.absent(),
    this.originId = const Value.absent(),
    this.interlinked = const Value.absent(),
    this.language = const Value.absent(),
    required String title,
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    required double duration,
    this.instrumental = const Value.absent(),
    this.lyricsVersion = const Value.absent(),
    this.lyrics = const Value.absent(),
    this.attachments = const Value.absent(),
  }) : title = Value(title),
       duration = Value(duration);
  static Insertable<Lyric> custom({
    Expression<int>? id,
    Expression<String>? namespace,
    Expression<String>? originId,
    Expression<int>? interlinked,
    Expression<int>? language,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<double>? duration,
    Expression<bool>? instrumental,
    Expression<int>? lyricsVersion,
    Expression<String>? lyrics,
    Expression<String>? attachments,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (namespace != null) 'namespace': namespace,
      if (originId != null) 'origin_id': originId,
      if (interlinked != null) 'interlinked': interlinked,
      if (language != null) 'language': language,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (duration != null) 'duration': duration,
      if (instrumental != null) 'instrumental': instrumental,
      if (lyricsVersion != null) 'lyrics_version': lyricsVersion,
      if (lyrics != null) 'lyrics': lyrics,
      if (attachments != null) 'attachments': attachments,
    });
  }

  LyricsCompanion copyWith({
    Value<int>? id,
    Value<String>? namespace,
    Value<String?>? originId,
    Value<int?>? interlinked,
    Value<int?>? language,
    Value<String>? title,
    Value<String?>? artist,
    Value<String?>? album,
    Value<double>? duration,
    Value<bool?>? instrumental,
    Value<int>? lyricsVersion,
    Value<String?>? lyrics,
    Value<String?>? attachments,
  }) {
    return LyricsCompanion(
      id: id ?? this.id,
      namespace: namespace ?? this.namespace,
      originId: originId ?? this.originId,
      interlinked: interlinked ?? this.interlinked,
      language: language ?? this.language,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      instrumental: instrumental ?? this.instrumental,
      lyricsVersion: lyricsVersion ?? this.lyricsVersion,
      lyrics: lyrics ?? this.lyrics,
      attachments: attachments ?? this.attachments,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (namespace.present) {
      map['namespace'] = Variable<String>(namespace.value);
    }
    if (originId.present) {
      map['origin_id'] = Variable<String>(originId.value);
    }
    if (interlinked.present) {
      map['interlinked'] = Variable<int>(interlinked.value);
    }
    if (language.present) {
      map['language'] = Variable<int>(language.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (duration.present) {
      map['duration'] = Variable<double>(duration.value);
    }
    if (instrumental.present) {
      map['instrumental'] = Variable<bool>(instrumental.value);
    }
    if (lyricsVersion.present) {
      map['lyrics_version'] = Variable<int>(lyricsVersion.value);
    }
    if (lyrics.present) {
      map['lyrics'] = Variable<String>(lyrics.value);
    }
    if (attachments.present) {
      map['attachments'] = Variable<String>(attachments.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LyricsCompanion(')
          ..write('id: $id, ')
          ..write('namespace: $namespace, ')
          ..write('originId: $originId, ')
          ..write('interlinked: $interlinked, ')
          ..write('language: $language, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('duration: $duration, ')
          ..write('instrumental: $instrumental, ')
          ..write('lyricsVersion: $lyricsVersion, ')
          ..write('lyrics: $lyrics, ')
          ..write('attachments: $attachments')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LyricsTable lyrics = $LyricsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [lyrics];
}

typedef $$LyricsTableCreateCompanionBuilder =
    LyricsCompanion Function({
      Value<int> id,
      Value<String> namespace,
      Value<String?> originId,
      Value<int?> interlinked,
      Value<int?> language,
      required String title,
      Value<String?> artist,
      Value<String?> album,
      required double duration,
      Value<bool?> instrumental,
      Value<int> lyricsVersion,
      Value<String?> lyrics,
      Value<String?> attachments,
    });
typedef $$LyricsTableUpdateCompanionBuilder =
    LyricsCompanion Function({
      Value<int> id,
      Value<String> namespace,
      Value<String?> originId,
      Value<int?> interlinked,
      Value<int?> language,
      Value<String> title,
      Value<String?> artist,
      Value<String?> album,
      Value<double> duration,
      Value<bool?> instrumental,
      Value<int> lyricsVersion,
      Value<String?> lyrics,
      Value<String?> attachments,
    });

final class $$LyricsTableReferences
    extends BaseReferences<_$AppDatabase, $LyricsTable, Lyric> {
  $$LyricsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LyricsTable _interlinkedTable(_$AppDatabase db) => db.lyrics
      .createAlias($_aliasNameGenerator(db.lyrics.interlinked, db.lyrics.id));

  $$LyricsTableProcessedTableManager? get interlinked {
    final $_column = $_itemColumn<int>('interlinked');
    if ($_column == null) return null;
    final manager = $$LyricsTableTableManager(
      $_db,
      $_db.lyrics,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_interlinkedTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LyricsTableFilterComposer
    extends Composer<_$AppDatabase, $LyricsTable> {
  $$LyricsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get namespace => $composableBuilder(
    column: $table.namespace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originId => $composableBuilder(
    column: $table.originId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get instrumental => $composableBuilder(
    column: $table.instrumental,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lyricsVersion => $composableBuilder(
    column: $table.lyricsVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lyrics => $composableBuilder(
    column: $table.lyrics,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachments => $composableBuilder(
    column: $table.attachments,
    builder: (column) => ColumnFilters(column),
  );

  $$LyricsTableFilterComposer get interlinked {
    final $$LyricsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.interlinked,
      referencedTable: $db.lyrics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LyricsTableFilterComposer(
            $db: $db,
            $table: $db.lyrics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LyricsTableOrderingComposer
    extends Composer<_$AppDatabase, $LyricsTable> {
  $$LyricsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get namespace => $composableBuilder(
    column: $table.namespace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originId => $composableBuilder(
    column: $table.originId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get instrumental => $composableBuilder(
    column: $table.instrumental,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lyricsVersion => $composableBuilder(
    column: $table.lyricsVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lyrics => $composableBuilder(
    column: $table.lyrics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachments => $composableBuilder(
    column: $table.attachments,
    builder: (column) => ColumnOrderings(column),
  );

  $$LyricsTableOrderingComposer get interlinked {
    final $$LyricsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.interlinked,
      referencedTable: $db.lyrics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LyricsTableOrderingComposer(
            $db: $db,
            $table: $db.lyrics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LyricsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LyricsTable> {
  $$LyricsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get namespace =>
      $composableBuilder(column: $table.namespace, builder: (column) => column);

  GeneratedColumn<String> get originId =>
      $composableBuilder(column: $table.originId, builder: (column) => column);

  GeneratedColumn<int> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<double> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<bool> get instrumental => $composableBuilder(
    column: $table.instrumental,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lyricsVersion => $composableBuilder(
    column: $table.lyricsVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lyrics =>
      $composableBuilder(column: $table.lyrics, builder: (column) => column);

  GeneratedColumn<String> get attachments => $composableBuilder(
    column: $table.attachments,
    builder: (column) => column,
  );

  $$LyricsTableAnnotationComposer get interlinked {
    final $$LyricsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.interlinked,
      referencedTable: $db.lyrics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LyricsTableAnnotationComposer(
            $db: $db,
            $table: $db.lyrics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LyricsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LyricsTable,
          Lyric,
          $$LyricsTableFilterComposer,
          $$LyricsTableOrderingComposer,
          $$LyricsTableAnnotationComposer,
          $$LyricsTableCreateCompanionBuilder,
          $$LyricsTableUpdateCompanionBuilder,
          (Lyric, $$LyricsTableReferences),
          Lyric,
          PrefetchHooks Function({bool interlinked})
        > {
  $$LyricsTableTableManager(_$AppDatabase db, $LyricsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LyricsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LyricsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LyricsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> namespace = const Value.absent(),
                Value<String?> originId = const Value.absent(),
                Value<int?> interlinked = const Value.absent(),
                Value<int?> language = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<double> duration = const Value.absent(),
                Value<bool?> instrumental = const Value.absent(),
                Value<int> lyricsVersion = const Value.absent(),
                Value<String?> lyrics = const Value.absent(),
                Value<String?> attachments = const Value.absent(),
              }) => LyricsCompanion(
                id: id,
                namespace: namespace,
                originId: originId,
                interlinked: interlinked,
                language: language,
                title: title,
                artist: artist,
                album: album,
                duration: duration,
                instrumental: instrumental,
                lyricsVersion: lyricsVersion,
                lyrics: lyrics,
                attachments: attachments,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> namespace = const Value.absent(),
                Value<String?> originId = const Value.absent(),
                Value<int?> interlinked = const Value.absent(),
                Value<int?> language = const Value.absent(),
                required String title,
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                required double duration,
                Value<bool?> instrumental = const Value.absent(),
                Value<int> lyricsVersion = const Value.absent(),
                Value<String?> lyrics = const Value.absent(),
                Value<String?> attachments = const Value.absent(),
              }) => LyricsCompanion.insert(
                id: id,
                namespace: namespace,
                originId: originId,
                interlinked: interlinked,
                language: language,
                title: title,
                artist: artist,
                album: album,
                duration: duration,
                instrumental: instrumental,
                lyricsVersion: lyricsVersion,
                lyrics: lyrics,
                attachments: attachments,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$LyricsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({interlinked = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (interlinked) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.interlinked,
                                referencedTable: $$LyricsTableReferences
                                    ._interlinkedTable(db),
                                referencedColumn: $$LyricsTableReferences
                                    ._interlinkedTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LyricsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LyricsTable,
      Lyric,
      $$LyricsTableFilterComposer,
      $$LyricsTableOrderingComposer,
      $$LyricsTableAnnotationComposer,
      $$LyricsTableCreateCompanionBuilder,
      $$LyricsTableUpdateCompanionBuilder,
      (Lyric, $$LyricsTableReferences),
      Lyric,
      PrefetchHooks Function({bool interlinked})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LyricsTableTableManager get lyrics =>
      $$LyricsTableTableManager(_db, _db.lyrics);
}
