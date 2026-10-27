// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalRoutesTable extends LocalRoutes
    with TableInfo<$LocalRoutesTable, LocalRoute> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalRoutesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverUuidMeta =
      const VerificationMeta('serverUuid');
  @override
  late final GeneratedColumn<String> serverUuid = GeneratedColumn<String>(
      'server_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _distanceKmMeta =
      const VerificationMeta('distanceKm');
  @override
  late final GeneratedColumn<double> distanceKm = GeneratedColumn<double>(
      'distance_km', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _estimatedDurationMinutesMeta =
      const VerificationMeta('estimatedDurationMinutes');
  @override
  late final GeneratedColumn<int> estimatedDurationMinutes =
      GeneratedColumn<int>('estimated_duration_minutes', aliasedName, false,
          type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isDownloadedMeta =
      const VerificationMeta('isDownloaded');
  @override
  late final GeneratedColumn<bool> isDownloaded = GeneratedColumn<bool>(
      'is_downloaded', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_downloaded" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _packageVersionMeta =
      const VerificationMeta('packageVersion');
  @override
  late final GeneratedColumn<int> packageVersion = GeneratedColumn<int>(
      'package_version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _downloadedAtMeta =
      const VerificationMeta('downloadedAt');
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
      'downloaded_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverUuid,
        name,
        description,
        difficulty,
        distanceKm,
        estimatedDurationMinutes,
        isDownloaded,
        packageVersion,
        downloadedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_routes';
  @override
  VerificationContext validateIntegrity(Insertable<LocalRoute> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_uuid')) {
      context.handle(
          _serverUuidMeta,
          serverUuid.isAcceptableOrUnknown(
              data['server_uuid']!, _serverUuidMeta));
    } else if (isInserting) {
      context.missing(_serverUuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('distance_km')) {
      context.handle(
          _distanceKmMeta,
          distanceKm.isAcceptableOrUnknown(
              data['distance_km']!, _distanceKmMeta));
    } else if (isInserting) {
      context.missing(_distanceKmMeta);
    }
    if (data.containsKey('estimated_duration_minutes')) {
      context.handle(
          _estimatedDurationMinutesMeta,
          estimatedDurationMinutes.isAcceptableOrUnknown(
              data['estimated_duration_minutes']!,
              _estimatedDurationMinutesMeta));
    } else if (isInserting) {
      context.missing(_estimatedDurationMinutesMeta);
    }
    if (data.containsKey('is_downloaded')) {
      context.handle(
          _isDownloadedMeta,
          isDownloaded.isAcceptableOrUnknown(
              data['is_downloaded']!, _isDownloadedMeta));
    }
    if (data.containsKey('package_version')) {
      context.handle(
          _packageVersionMeta,
          packageVersion.isAcceptableOrUnknown(
              data['package_version']!, _packageVersionMeta));
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
          _downloadedAtMeta,
          downloadedAt.isAcceptableOrUnknown(
              data['downloaded_at']!, _downloadedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalRoute map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalRoute(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_uuid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}difficulty'])!,
      distanceKm: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}distance_km'])!,
      estimatedDurationMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}estimated_duration_minutes'])!,
      isDownloaded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_downloaded'])!,
      packageVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}package_version'])!,
      downloadedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}downloaded_at']),
    );
  }

  @override
  $LocalRoutesTable createAlias(String alias) {
    return $LocalRoutesTable(attachedDatabase, alias);
  }
}

class LocalRoute extends DataClass implements Insertable<LocalRoute> {
  final int id;
  final String serverUuid;
  final String name;
  final String description;
  final String difficulty;
  final double distanceKm;
  final int estimatedDurationMinutes;
  final bool isDownloaded;
  final int packageVersion;
  final DateTime? downloadedAt;
  const LocalRoute(
      {required this.id,
      required this.serverUuid,
      required this.name,
      required this.description,
      required this.difficulty,
      required this.distanceKm,
      required this.estimatedDurationMinutes,
      required this.isDownloaded,
      required this.packageVersion,
      this.downloadedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['server_uuid'] = Variable<String>(serverUuid);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['difficulty'] = Variable<String>(difficulty);
    map['distance_km'] = Variable<double>(distanceKm);
    map['estimated_duration_minutes'] = Variable<int>(estimatedDurationMinutes);
    map['is_downloaded'] = Variable<bool>(isDownloaded);
    map['package_version'] = Variable<int>(packageVersion);
    if (!nullToAbsent || downloadedAt != null) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    }
    return map;
  }

  LocalRoutesCompanion toCompanion(bool nullToAbsent) {
    return LocalRoutesCompanion(
      id: Value(id),
      serverUuid: Value(serverUuid),
      name: Value(name),
      description: Value(description),
      difficulty: Value(difficulty),
      distanceKm: Value(distanceKm),
      estimatedDurationMinutes: Value(estimatedDurationMinutes),
      isDownloaded: Value(isDownloaded),
      packageVersion: Value(packageVersion),
      downloadedAt: downloadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadedAt),
    );
  }

  factory LocalRoute.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalRoute(
      id: serializer.fromJson<int>(json['id']),
      serverUuid: serializer.fromJson<String>(json['serverUuid']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      distanceKm: serializer.fromJson<double>(json['distanceKm']),
      estimatedDurationMinutes:
          serializer.fromJson<int>(json['estimatedDurationMinutes']),
      isDownloaded: serializer.fromJson<bool>(json['isDownloaded']),
      packageVersion: serializer.fromJson<int>(json['packageVersion']),
      downloadedAt: serializer.fromJson<DateTime?>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverUuid': serializer.toJson<String>(serverUuid),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'difficulty': serializer.toJson<String>(difficulty),
      'distanceKm': serializer.toJson<double>(distanceKm),
      'estimatedDurationMinutes':
          serializer.toJson<int>(estimatedDurationMinutes),
      'isDownloaded': serializer.toJson<bool>(isDownloaded),
      'packageVersion': serializer.toJson<int>(packageVersion),
      'downloadedAt': serializer.toJson<DateTime?>(downloadedAt),
    };
  }

  LocalRoute copyWith(
          {int? id,
          String? serverUuid,
          String? name,
          String? description,
          String? difficulty,
          double? distanceKm,
          int? estimatedDurationMinutes,
          bool? isDownloaded,
          int? packageVersion,
          Value<DateTime?> downloadedAt = const Value.absent()}) =>
      LocalRoute(
        id: id ?? this.id,
        serverUuid: serverUuid ?? this.serverUuid,
        name: name ?? this.name,
        description: description ?? this.description,
        difficulty: difficulty ?? this.difficulty,
        distanceKm: distanceKm ?? this.distanceKm,
        estimatedDurationMinutes:
            estimatedDurationMinutes ?? this.estimatedDurationMinutes,
        isDownloaded: isDownloaded ?? this.isDownloaded,
        packageVersion: packageVersion ?? this.packageVersion,
        downloadedAt:
            downloadedAt.present ? downloadedAt.value : this.downloadedAt,
      );
  LocalRoute copyWithCompanion(LocalRoutesCompanion data) {
    return LocalRoute(
      id: data.id.present ? data.id.value : this.id,
      serverUuid:
          data.serverUuid.present ? data.serverUuid.value : this.serverUuid,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      distanceKm:
          data.distanceKm.present ? data.distanceKm.value : this.distanceKm,
      estimatedDurationMinutes: data.estimatedDurationMinutes.present
          ? data.estimatedDurationMinutes.value
          : this.estimatedDurationMinutes,
      isDownloaded: data.isDownloaded.present
          ? data.isDownloaded.value
          : this.isDownloaded,
      packageVersion: data.packageVersion.present
          ? data.packageVersion.value
          : this.packageVersion,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalRoute(')
          ..write('id: $id, ')
          ..write('serverUuid: $serverUuid, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('difficulty: $difficulty, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('estimatedDurationMinutes: $estimatedDurationMinutes, ')
          ..write('isDownloaded: $isDownloaded, ')
          ..write('packageVersion: $packageVersion, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverUuid,
      name,
      description,
      difficulty,
      distanceKm,
      estimatedDurationMinutes,
      isDownloaded,
      packageVersion,
      downloadedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalRoute &&
          other.id == this.id &&
          other.serverUuid == this.serverUuid &&
          other.name == this.name &&
          other.description == this.description &&
          other.difficulty == this.difficulty &&
          other.distanceKm == this.distanceKm &&
          other.estimatedDurationMinutes == this.estimatedDurationMinutes &&
          other.isDownloaded == this.isDownloaded &&
          other.packageVersion == this.packageVersion &&
          other.downloadedAt == this.downloadedAt);
}

class LocalRoutesCompanion extends UpdateCompanion<LocalRoute> {
  final Value<int> id;
  final Value<String> serverUuid;
  final Value<String> name;
  final Value<String> description;
  final Value<String> difficulty;
  final Value<double> distanceKm;
  final Value<int> estimatedDurationMinutes;
  final Value<bool> isDownloaded;
  final Value<int> packageVersion;
  final Value<DateTime?> downloadedAt;
  const LocalRoutesCompanion({
    this.id = const Value.absent(),
    this.serverUuid = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.estimatedDurationMinutes = const Value.absent(),
    this.isDownloaded = const Value.absent(),
    this.packageVersion = const Value.absent(),
    this.downloadedAt = const Value.absent(),
  });
  LocalRoutesCompanion.insert({
    this.id = const Value.absent(),
    required String serverUuid,
    required String name,
    required String description,
    required String difficulty,
    required double distanceKm,
    required int estimatedDurationMinutes,
    this.isDownloaded = const Value.absent(),
    this.packageVersion = const Value.absent(),
    this.downloadedAt = const Value.absent(),
  })  : serverUuid = Value(serverUuid),
        name = Value(name),
        description = Value(description),
        difficulty = Value(difficulty),
        distanceKm = Value(distanceKm),
        estimatedDurationMinutes = Value(estimatedDurationMinutes);
  static Insertable<LocalRoute> custom({
    Expression<int>? id,
    Expression<String>? serverUuid,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? difficulty,
    Expression<double>? distanceKm,
    Expression<int>? estimatedDurationMinutes,
    Expression<bool>? isDownloaded,
    Expression<int>? packageVersion,
    Expression<DateTime>? downloadedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverUuid != null) 'server_uuid': serverUuid,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (difficulty != null) 'difficulty': difficulty,
      if (distanceKm != null) 'distance_km': distanceKm,
      if (estimatedDurationMinutes != null)
        'estimated_duration_minutes': estimatedDurationMinutes,
      if (isDownloaded != null) 'is_downloaded': isDownloaded,
      if (packageVersion != null) 'package_version': packageVersion,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
    });
  }

  LocalRoutesCompanion copyWith(
      {Value<int>? id,
      Value<String>? serverUuid,
      Value<String>? name,
      Value<String>? description,
      Value<String>? difficulty,
      Value<double>? distanceKm,
      Value<int>? estimatedDurationMinutes,
      Value<bool>? isDownloaded,
      Value<int>? packageVersion,
      Value<DateTime?>? downloadedAt}) {
    return LocalRoutesCompanion(
      id: id ?? this.id,
      serverUuid: serverUuid ?? this.serverUuid,
      name: name ?? this.name,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      packageVersion: packageVersion ?? this.packageVersion,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverUuid.present) {
      map['server_uuid'] = Variable<String>(serverUuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (distanceKm.present) {
      map['distance_km'] = Variable<double>(distanceKm.value);
    }
    if (estimatedDurationMinutes.present) {
      map['estimated_duration_minutes'] =
          Variable<int>(estimatedDurationMinutes.value);
    }
    if (isDownloaded.present) {
      map['is_downloaded'] = Variable<bool>(isDownloaded.value);
    }
    if (packageVersion.present) {
      map['package_version'] = Variable<int>(packageVersion.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalRoutesCompanion(')
          ..write('id: $id, ')
          ..write('serverUuid: $serverUuid, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('difficulty: $difficulty, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('estimatedDurationMinutes: $estimatedDurationMinutes, ')
          ..write('isDownloaded: $isDownloaded, ')
          ..write('packageVersion: $packageVersion, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalScenesTable extends LocalScenes
    with TableInfo<$LocalScenesTable, LocalScene> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalScenesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverUuidMeta =
      const VerificationMeta('serverUuid');
  @override
  late final GeneratedColumn<String> serverUuid = GeneratedColumn<String>(
      'server_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _routeServerUuidMeta =
      const VerificationMeta('routeServerUuid');
  @override
  late final GeneratedColumn<String> routeServerUuid = GeneratedColumn<String>(
      'route_server_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _panoramaLocalPathMeta =
      const VerificationMeta('panoramaLocalPath');
  @override
  late final GeneratedColumn<String> panoramaLocalPath =
      GeneratedColumn<String>('panorama_local_path', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _thumbnailLocalPathMeta =
      const VerificationMeta('thumbnailLocalPath');
  @override
  late final GeneratedColumn<String> thumbnailLocalPath =
      GeneratedColumn<String>('thumbnail_local_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _sequenceMeta =
      const VerificationMeta('sequence');
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
      'sequence', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverUuid,
        routeServerUuid,
        title,
        description,
        panoramaLocalPath,
        thumbnailLocalPath,
        latitude,
        longitude,
        sequence
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_scenes';
  @override
  VerificationContext validateIntegrity(Insertable<LocalScene> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_uuid')) {
      context.handle(
          _serverUuidMeta,
          serverUuid.isAcceptableOrUnknown(
              data['server_uuid']!, _serverUuidMeta));
    } else if (isInserting) {
      context.missing(_serverUuidMeta);
    }
    if (data.containsKey('route_server_uuid')) {
      context.handle(
          _routeServerUuidMeta,
          routeServerUuid.isAcceptableOrUnknown(
              data['route_server_uuid']!, _routeServerUuidMeta));
    } else if (isInserting) {
      context.missing(_routeServerUuidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('panorama_local_path')) {
      context.handle(
          _panoramaLocalPathMeta,
          panoramaLocalPath.isAcceptableOrUnknown(
              data['panorama_local_path']!, _panoramaLocalPathMeta));
    } else if (isInserting) {
      context.missing(_panoramaLocalPathMeta);
    }
    if (data.containsKey('thumbnail_local_path')) {
      context.handle(
          _thumbnailLocalPathMeta,
          thumbnailLocalPath.isAcceptableOrUnknown(
              data['thumbnail_local_path']!, _thumbnailLocalPathMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('sequence')) {
      context.handle(_sequenceMeta,
          sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalScene map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalScene(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_uuid'])!,
      routeServerUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}route_server_uuid'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      panoramaLocalPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}panorama_local_path'])!,
      thumbnailLocalPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}thumbnail_local_path']),
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      sequence: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sequence'])!,
    );
  }

  @override
  $LocalScenesTable createAlias(String alias) {
    return $LocalScenesTable(attachedDatabase, alias);
  }
}

class LocalScene extends DataClass implements Insertable<LocalScene> {
  final int id;
  final String serverUuid;
  final String routeServerUuid;
  final String title;
  final String description;
  final String panoramaLocalPath;
  final String? thumbnailLocalPath;
  final double? latitude;
  final double? longitude;
  final int sequence;
  const LocalScene(
      {required this.id,
      required this.serverUuid,
      required this.routeServerUuid,
      required this.title,
      required this.description,
      required this.panoramaLocalPath,
      this.thumbnailLocalPath,
      this.latitude,
      this.longitude,
      required this.sequence});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['server_uuid'] = Variable<String>(serverUuid);
    map['route_server_uuid'] = Variable<String>(routeServerUuid);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['panorama_local_path'] = Variable<String>(panoramaLocalPath);
    if (!nullToAbsent || thumbnailLocalPath != null) {
      map['thumbnail_local_path'] = Variable<String>(thumbnailLocalPath);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['sequence'] = Variable<int>(sequence);
    return map;
  }

  LocalScenesCompanion toCompanion(bool nullToAbsent) {
    return LocalScenesCompanion(
      id: Value(id),
      serverUuid: Value(serverUuid),
      routeServerUuid: Value(routeServerUuid),
      title: Value(title),
      description: Value(description),
      panoramaLocalPath: Value(panoramaLocalPath),
      thumbnailLocalPath: thumbnailLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailLocalPath),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      sequence: Value(sequence),
    );
  }

  factory LocalScene.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalScene(
      id: serializer.fromJson<int>(json['id']),
      serverUuid: serializer.fromJson<String>(json['serverUuid']),
      routeServerUuid: serializer.fromJson<String>(json['routeServerUuid']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      panoramaLocalPath: serializer.fromJson<String>(json['panoramaLocalPath']),
      thumbnailLocalPath:
          serializer.fromJson<String?>(json['thumbnailLocalPath']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      sequence: serializer.fromJson<int>(json['sequence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverUuid': serializer.toJson<String>(serverUuid),
      'routeServerUuid': serializer.toJson<String>(routeServerUuid),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'panoramaLocalPath': serializer.toJson<String>(panoramaLocalPath),
      'thumbnailLocalPath': serializer.toJson<String?>(thumbnailLocalPath),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'sequence': serializer.toJson<int>(sequence),
    };
  }

  LocalScene copyWith(
          {int? id,
          String? serverUuid,
          String? routeServerUuid,
          String? title,
          String? description,
          String? panoramaLocalPath,
          Value<String?> thumbnailLocalPath = const Value.absent(),
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          int? sequence}) =>
      LocalScene(
        id: id ?? this.id,
        serverUuid: serverUuid ?? this.serverUuid,
        routeServerUuid: routeServerUuid ?? this.routeServerUuid,
        title: title ?? this.title,
        description: description ?? this.description,
        panoramaLocalPath: panoramaLocalPath ?? this.panoramaLocalPath,
        thumbnailLocalPath: thumbnailLocalPath.present
            ? thumbnailLocalPath.value
            : this.thumbnailLocalPath,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        sequence: sequence ?? this.sequence,
      );
  LocalScene copyWithCompanion(LocalScenesCompanion data) {
    return LocalScene(
      id: data.id.present ? data.id.value : this.id,
      serverUuid:
          data.serverUuid.present ? data.serverUuid.value : this.serverUuid,
      routeServerUuid: data.routeServerUuid.present
          ? data.routeServerUuid.value
          : this.routeServerUuid,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      panoramaLocalPath: data.panoramaLocalPath.present
          ? data.panoramaLocalPath.value
          : this.panoramaLocalPath,
      thumbnailLocalPath: data.thumbnailLocalPath.present
          ? data.thumbnailLocalPath.value
          : this.thumbnailLocalPath,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalScene(')
          ..write('id: $id, ')
          ..write('serverUuid: $serverUuid, ')
          ..write('routeServerUuid: $routeServerUuid, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('panoramaLocalPath: $panoramaLocalPath, ')
          ..write('thumbnailLocalPath: $thumbnailLocalPath, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('sequence: $sequence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverUuid,
      routeServerUuid,
      title,
      description,
      panoramaLocalPath,
      thumbnailLocalPath,
      latitude,
      longitude,
      sequence);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalScene &&
          other.id == this.id &&
          other.serverUuid == this.serverUuid &&
          other.routeServerUuid == this.routeServerUuid &&
          other.title == this.title &&
          other.description == this.description &&
          other.panoramaLocalPath == this.panoramaLocalPath &&
          other.thumbnailLocalPath == this.thumbnailLocalPath &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.sequence == this.sequence);
}

class LocalScenesCompanion extends UpdateCompanion<LocalScene> {
  final Value<int> id;
  final Value<String> serverUuid;
  final Value<String> routeServerUuid;
  final Value<String> title;
  final Value<String> description;
  final Value<String> panoramaLocalPath;
  final Value<String?> thumbnailLocalPath;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<int> sequence;
  const LocalScenesCompanion({
    this.id = const Value.absent(),
    this.serverUuid = const Value.absent(),
    this.routeServerUuid = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.panoramaLocalPath = const Value.absent(),
    this.thumbnailLocalPath = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.sequence = const Value.absent(),
  });
  LocalScenesCompanion.insert({
    this.id = const Value.absent(),
    required String serverUuid,
    required String routeServerUuid,
    required String title,
    this.description = const Value.absent(),
    required String panoramaLocalPath,
    this.thumbnailLocalPath = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.sequence = const Value.absent(),
  })  : serverUuid = Value(serverUuid),
        routeServerUuid = Value(routeServerUuid),
        title = Value(title),
        panoramaLocalPath = Value(panoramaLocalPath);
  static Insertable<LocalScene> custom({
    Expression<int>? id,
    Expression<String>? serverUuid,
    Expression<String>? routeServerUuid,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? panoramaLocalPath,
    Expression<String>? thumbnailLocalPath,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? sequence,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverUuid != null) 'server_uuid': serverUuid,
      if (routeServerUuid != null) 'route_server_uuid': routeServerUuid,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (panoramaLocalPath != null) 'panorama_local_path': panoramaLocalPath,
      if (thumbnailLocalPath != null)
        'thumbnail_local_path': thumbnailLocalPath,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (sequence != null) 'sequence': sequence,
    });
  }

  LocalScenesCompanion copyWith(
      {Value<int>? id,
      Value<String>? serverUuid,
      Value<String>? routeServerUuid,
      Value<String>? title,
      Value<String>? description,
      Value<String>? panoramaLocalPath,
      Value<String?>? thumbnailLocalPath,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<int>? sequence}) {
    return LocalScenesCompanion(
      id: id ?? this.id,
      serverUuid: serverUuid ?? this.serverUuid,
      routeServerUuid: routeServerUuid ?? this.routeServerUuid,
      title: title ?? this.title,
      description: description ?? this.description,
      panoramaLocalPath: panoramaLocalPath ?? this.panoramaLocalPath,
      thumbnailLocalPath: thumbnailLocalPath ?? this.thumbnailLocalPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      sequence: sequence ?? this.sequence,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverUuid.present) {
      map['server_uuid'] = Variable<String>(serverUuid.value);
    }
    if (routeServerUuid.present) {
      map['route_server_uuid'] = Variable<String>(routeServerUuid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (panoramaLocalPath.present) {
      map['panorama_local_path'] = Variable<String>(panoramaLocalPath.value);
    }
    if (thumbnailLocalPath.present) {
      map['thumbnail_local_path'] = Variable<String>(thumbnailLocalPath.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalScenesCompanion(')
          ..write('id: $id, ')
          ..write('serverUuid: $serverUuid, ')
          ..write('routeServerUuid: $routeServerUuid, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('panoramaLocalPath: $panoramaLocalPath, ')
          ..write('thumbnailLocalPath: $thumbnailLocalPath, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('sequence: $sequence')
          ..write(')'))
        .toString();
  }
}

class $LocalHotspotsTable extends LocalHotspots
    with TableInfo<$LocalHotspotsTable, LocalHotspot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalHotspotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverUuidMeta =
      const VerificationMeta('serverUuid');
  @override
  late final GeneratedColumn<String> serverUuid = GeneratedColumn<String>(
      'server_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _sourceSceneUuidMeta =
      const VerificationMeta('sourceSceneUuid');
  @override
  late final GeneratedColumn<String> sourceSceneUuid = GeneratedColumn<String>(
      'source_scene_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetSceneUuidMeta =
      const VerificationMeta('targetSceneUuid');
  @override
  late final GeneratedColumn<String> targetSceneUuid = GeneratedColumn<String>(
      'target_scene_uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('navigation'));
  static const VerificationMeta _yawMeta = const VerificationMeta('yaw');
  @override
  late final GeneratedColumn<double> yaw = GeneratedColumn<double>(
      'yaw', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _pitchMeta = const VerificationMeta('pitch');
  @override
  late final GeneratedColumn<double> pitch = GeneratedColumn<double>(
      'pitch', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverUuid,
        sourceSceneUuid,
        targetSceneUuid,
        type,
        yaw,
        pitch,
        title,
        content
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_hotspots';
  @override
  VerificationContext validateIntegrity(Insertable<LocalHotspot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_uuid')) {
      context.handle(
          _serverUuidMeta,
          serverUuid.isAcceptableOrUnknown(
              data['server_uuid']!, _serverUuidMeta));
    } else if (isInserting) {
      context.missing(_serverUuidMeta);
    }
    if (data.containsKey('source_scene_uuid')) {
      context.handle(
          _sourceSceneUuidMeta,
          sourceSceneUuid.isAcceptableOrUnknown(
              data['source_scene_uuid']!, _sourceSceneUuidMeta));
    } else if (isInserting) {
      context.missing(_sourceSceneUuidMeta);
    }
    if (data.containsKey('target_scene_uuid')) {
      context.handle(
          _targetSceneUuidMeta,
          targetSceneUuid.isAcceptableOrUnknown(
              data['target_scene_uuid']!, _targetSceneUuidMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('yaw')) {
      context.handle(
          _yawMeta, yaw.isAcceptableOrUnknown(data['yaw']!, _yawMeta));
    }
    if (data.containsKey('pitch')) {
      context.handle(
          _pitchMeta, pitch.isAcceptableOrUnknown(data['pitch']!, _pitchMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalHotspot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalHotspot(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_uuid'])!,
      sourceSceneUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}source_scene_uuid'])!,
      targetSceneUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}target_scene_uuid']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      yaw: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}yaw'])!,
      pitch: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pitch'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
    );
  }

  @override
  $LocalHotspotsTable createAlias(String alias) {
    return $LocalHotspotsTable(attachedDatabase, alias);
  }
}

class LocalHotspot extends DataClass implements Insertable<LocalHotspot> {
  final int id;
  final String serverUuid;
  final String sourceSceneUuid;
  final String? targetSceneUuid;
  final String type;
  final double yaw;
  final double pitch;
  final String title;
  final String content;
  const LocalHotspot(
      {required this.id,
      required this.serverUuid,
      required this.sourceSceneUuid,
      this.targetSceneUuid,
      required this.type,
      required this.yaw,
      required this.pitch,
      required this.title,
      required this.content});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['server_uuid'] = Variable<String>(serverUuid);
    map['source_scene_uuid'] = Variable<String>(sourceSceneUuid);
    if (!nullToAbsent || targetSceneUuid != null) {
      map['target_scene_uuid'] = Variable<String>(targetSceneUuid);
    }
    map['type'] = Variable<String>(type);
    map['yaw'] = Variable<double>(yaw);
    map['pitch'] = Variable<double>(pitch);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    return map;
  }

  LocalHotspotsCompanion toCompanion(bool nullToAbsent) {
    return LocalHotspotsCompanion(
      id: Value(id),
      serverUuid: Value(serverUuid),
      sourceSceneUuid: Value(sourceSceneUuid),
      targetSceneUuid: targetSceneUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(targetSceneUuid),
      type: Value(type),
      yaw: Value(yaw),
      pitch: Value(pitch),
      title: Value(title),
      content: Value(content),
    );
  }

  factory LocalHotspot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalHotspot(
      id: serializer.fromJson<int>(json['id']),
      serverUuid: serializer.fromJson<String>(json['serverUuid']),
      sourceSceneUuid: serializer.fromJson<String>(json['sourceSceneUuid']),
      targetSceneUuid: serializer.fromJson<String?>(json['targetSceneUuid']),
      type: serializer.fromJson<String>(json['type']),
      yaw: serializer.fromJson<double>(json['yaw']),
      pitch: serializer.fromJson<double>(json['pitch']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverUuid': serializer.toJson<String>(serverUuid),
      'sourceSceneUuid': serializer.toJson<String>(sourceSceneUuid),
      'targetSceneUuid': serializer.toJson<String?>(targetSceneUuid),
      'type': serializer.toJson<String>(type),
      'yaw': serializer.toJson<double>(yaw),
      'pitch': serializer.toJson<double>(pitch),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
    };
  }

  LocalHotspot copyWith(
          {int? id,
          String? serverUuid,
          String? sourceSceneUuid,
          Value<String?> targetSceneUuid = const Value.absent(),
          String? type,
          double? yaw,
          double? pitch,
          String? title,
          String? content}) =>
      LocalHotspot(
        id: id ?? this.id,
        serverUuid: serverUuid ?? this.serverUuid,
        sourceSceneUuid: sourceSceneUuid ?? this.sourceSceneUuid,
        targetSceneUuid: targetSceneUuid.present
            ? targetSceneUuid.value
            : this.targetSceneUuid,
        type: type ?? this.type,
        yaw: yaw ?? this.yaw,
        pitch: pitch ?? this.pitch,
        title: title ?? this.title,
        content: content ?? this.content,
      );
  LocalHotspot copyWithCompanion(LocalHotspotsCompanion data) {
    return LocalHotspot(
      id: data.id.present ? data.id.value : this.id,
      serverUuid:
          data.serverUuid.present ? data.serverUuid.value : this.serverUuid,
      sourceSceneUuid: data.sourceSceneUuid.present
          ? data.sourceSceneUuid.value
          : this.sourceSceneUuid,
      targetSceneUuid: data.targetSceneUuid.present
          ? data.targetSceneUuid.value
          : this.targetSceneUuid,
      type: data.type.present ? data.type.value : this.type,
      yaw: data.yaw.present ? data.yaw.value : this.yaw,
      pitch: data.pitch.present ? data.pitch.value : this.pitch,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalHotspot(')
          ..write('id: $id, ')
          ..write('serverUuid: $serverUuid, ')
          ..write('sourceSceneUuid: $sourceSceneUuid, ')
          ..write('targetSceneUuid: $targetSceneUuid, ')
          ..write('type: $type, ')
          ..write('yaw: $yaw, ')
          ..write('pitch: $pitch, ')
          ..write('title: $title, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, serverUuid, sourceSceneUuid,
      targetSceneUuid, type, yaw, pitch, title, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalHotspot &&
          other.id == this.id &&
          other.serverUuid == this.serverUuid &&
          other.sourceSceneUuid == this.sourceSceneUuid &&
          other.targetSceneUuid == this.targetSceneUuid &&
          other.type == this.type &&
          other.yaw == this.yaw &&
          other.pitch == this.pitch &&
          other.title == this.title &&
          other.content == this.content);
}

class LocalHotspotsCompanion extends UpdateCompanion<LocalHotspot> {
  final Value<int> id;
  final Value<String> serverUuid;
  final Value<String> sourceSceneUuid;
  final Value<String?> targetSceneUuid;
  final Value<String> type;
  final Value<double> yaw;
  final Value<double> pitch;
  final Value<String> title;
  final Value<String> content;
  const LocalHotspotsCompanion({
    this.id = const Value.absent(),
    this.serverUuid = const Value.absent(),
    this.sourceSceneUuid = const Value.absent(),
    this.targetSceneUuid = const Value.absent(),
    this.type = const Value.absent(),
    this.yaw = const Value.absent(),
    this.pitch = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
  });
  LocalHotspotsCompanion.insert({
    this.id = const Value.absent(),
    required String serverUuid,
    required String sourceSceneUuid,
    this.targetSceneUuid = const Value.absent(),
    this.type = const Value.absent(),
    this.yaw = const Value.absent(),
    this.pitch = const Value.absent(),
    required String title,
    this.content = const Value.absent(),
  })  : serverUuid = Value(serverUuid),
        sourceSceneUuid = Value(sourceSceneUuid),
        title = Value(title);
  static Insertable<LocalHotspot> custom({
    Expression<int>? id,
    Expression<String>? serverUuid,
    Expression<String>? sourceSceneUuid,
    Expression<String>? targetSceneUuid,
    Expression<String>? type,
    Expression<double>? yaw,
    Expression<double>? pitch,
    Expression<String>? title,
    Expression<String>? content,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverUuid != null) 'server_uuid': serverUuid,
      if (sourceSceneUuid != null) 'source_scene_uuid': sourceSceneUuid,
      if (targetSceneUuid != null) 'target_scene_uuid': targetSceneUuid,
      if (type != null) 'type': type,
      if (yaw != null) 'yaw': yaw,
      if (pitch != null) 'pitch': pitch,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
    });
  }

  LocalHotspotsCompanion copyWith(
      {Value<int>? id,
      Value<String>? serverUuid,
      Value<String>? sourceSceneUuid,
      Value<String?>? targetSceneUuid,
      Value<String>? type,
      Value<double>? yaw,
      Value<double>? pitch,
      Value<String>? title,
      Value<String>? content}) {
    return LocalHotspotsCompanion(
      id: id ?? this.id,
      serverUuid: serverUuid ?? this.serverUuid,
      sourceSceneUuid: sourceSceneUuid ?? this.sourceSceneUuid,
      targetSceneUuid: targetSceneUuid ?? this.targetSceneUuid,
      type: type ?? this.type,
      yaw: yaw ?? this.yaw,
      pitch: pitch ?? this.pitch,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverUuid.present) {
      map['server_uuid'] = Variable<String>(serverUuid.value);
    }
    if (sourceSceneUuid.present) {
      map['source_scene_uuid'] = Variable<String>(sourceSceneUuid.value);
    }
    if (targetSceneUuid.present) {
      map['target_scene_uuid'] = Variable<String>(targetSceneUuid.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (yaw.present) {
      map['yaw'] = Variable<double>(yaw.value);
    }
    if (pitch.present) {
      map['pitch'] = Variable<double>(pitch.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalHotspotsCompanion(')
          ..write('id: $id, ')
          ..write('serverUuid: $serverUuid, ')
          ..write('sourceSceneUuid: $sourceSceneUuid, ')
          ..write('targetSceneUuid: $targetSceneUuid, ')
          ..write('type: $type, ')
          ..write('yaw: $yaw, ')
          ..write('pitch: $pitch, ')
          ..write('title: $title, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }
}

class $PendingReportsTable extends PendingReports
    with TableInfo<$PendingReportsTable, PendingReport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _localUuidMeta =
      const VerificationMeta('localUuid');
  @override
  late final GeneratedColumn<String> localUuid = GeneratedColumn<String>(
      'local_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _serverUuidMeta =
      const VerificationMeta('serverUuid');
  @override
  late final GeneratedColumn<String> serverUuid = GeneratedColumn<String>(
      'server_uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _routeUuidMeta =
      const VerificationMeta('routeUuid');
  @override
  late final GeneratedColumn<String> routeUuid = GeneratedColumn<String>(
      'route_uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _accuracyMetersMeta =
      const VerificationMeta('accuracyMeters');
  @override
  late final GeneratedColumn<double> accuracyMeters = GeneratedColumn<double>(
      'accuracy_meters', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _capturedAtMeta =
      const VerificationMeta('capturedAt');
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
      'captured_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _localImagePathMeta =
      const VerificationMeta('localImagePath');
  @override
  late final GeneratedColumn<String> localImagePath = GeneratedColumn<String>(
      'local_image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _syncErrorMeta =
      const VerificationMeta('syncError');
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
      'sync_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        localUuid,
        serverUuid,
        userId,
        routeUuid,
        category,
        description,
        latitude,
        longitude,
        accuracyMeters,
        capturedAt,
        localImagePath,
        syncStatus,
        syncError,
        syncedAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_reports';
  @override
  VerificationContext validateIntegrity(Insertable<PendingReport> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('local_uuid')) {
      context.handle(_localUuidMeta,
          localUuid.isAcceptableOrUnknown(data['local_uuid']!, _localUuidMeta));
    } else if (isInserting) {
      context.missing(_localUuidMeta);
    }
    if (data.containsKey('server_uuid')) {
      context.handle(
          _serverUuidMeta,
          serverUuid.isAcceptableOrUnknown(
              data['server_uuid']!, _serverUuidMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('route_uuid')) {
      context.handle(_routeUuidMeta,
          routeUuid.isAcceptableOrUnknown(data['route_uuid']!, _routeUuidMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('accuracy_meters')) {
      context.handle(
          _accuracyMetersMeta,
          accuracyMeters.isAcceptableOrUnknown(
              data['accuracy_meters']!, _accuracyMetersMeta));
    }
    if (data.containsKey('captured_at')) {
      context.handle(
          _capturedAtMeta,
          capturedAt.isAcceptableOrUnknown(
              data['captured_at']!, _capturedAtMeta));
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('local_image_path')) {
      context.handle(
          _localImagePathMeta,
          localImagePath.isAcceptableOrUnknown(
              data['local_image_path']!, _localImagePathMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('sync_error')) {
      context.handle(_syncErrorMeta,
          syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingReport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingReport(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      localUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_uuid'])!,
      serverUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_uuid']),
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id']),
      routeUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}route_uuid']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      accuracyMeters: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}accuracy_meters']),
      capturedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}captured_at'])!,
      localImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_image_path']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      syncError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_error']),
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PendingReportsTable createAlias(String alias) {
    return $PendingReportsTable(attachedDatabase, alias);
  }
}

class PendingReport extends DataClass implements Insertable<PendingReport> {
  final int id;
  final String localUuid;
  final String? serverUuid;
  final int? userId;
  final String? routeUuid;
  final String category;
  final String description;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final DateTime capturedAt;
  final String? localImagePath;
  final String syncStatus;
  final String? syncError;
  final DateTime? syncedAt;
  final DateTime createdAt;
  const PendingReport(
      {required this.id,
      required this.localUuid,
      this.serverUuid,
      this.userId,
      this.routeUuid,
      required this.category,
      required this.description,
      this.latitude,
      this.longitude,
      this.accuracyMeters,
      required this.capturedAt,
      this.localImagePath,
      required this.syncStatus,
      this.syncError,
      this.syncedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['local_uuid'] = Variable<String>(localUuid);
    if (!nullToAbsent || serverUuid != null) {
      map['server_uuid'] = Variable<String>(serverUuid);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<int>(userId);
    }
    if (!nullToAbsent || routeUuid != null) {
      map['route_uuid'] = Variable<String>(routeUuid);
    }
    map['category'] = Variable<String>(category);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || accuracyMeters != null) {
      map['accuracy_meters'] = Variable<double>(accuracyMeters);
    }
    map['captured_at'] = Variable<DateTime>(capturedAt);
    if (!nullToAbsent || localImagePath != null) {
      map['local_image_path'] = Variable<String>(localImagePath);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingReportsCompanion toCompanion(bool nullToAbsent) {
    return PendingReportsCompanion(
      id: Value(id),
      localUuid: Value(localUuid),
      serverUuid: serverUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUuid),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      routeUuid: routeUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(routeUuid),
      category: Value(category),
      description: Value(description),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      accuracyMeters: accuracyMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracyMeters),
      capturedAt: Value(capturedAt),
      localImagePath: localImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(localImagePath),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      createdAt: Value(createdAt),
    );
  }

  factory PendingReport.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingReport(
      id: serializer.fromJson<int>(json['id']),
      localUuid: serializer.fromJson<String>(json['localUuid']),
      serverUuid: serializer.fromJson<String?>(json['serverUuid']),
      userId: serializer.fromJson<int?>(json['userId']),
      routeUuid: serializer.fromJson<String?>(json['routeUuid']),
      category: serializer.fromJson<String>(json['category']),
      description: serializer.fromJson<String>(json['description']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      accuracyMeters: serializer.fromJson<double?>(json['accuracyMeters']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      localImagePath: serializer.fromJson<String?>(json['localImagePath']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncError: serializer.fromJson<String?>(json['syncError']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'localUuid': serializer.toJson<String>(localUuid),
      'serverUuid': serializer.toJson<String?>(serverUuid),
      'userId': serializer.toJson<int?>(userId),
      'routeUuid': serializer.toJson<String?>(routeUuid),
      'category': serializer.toJson<String>(category),
      'description': serializer.toJson<String>(description),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'accuracyMeters': serializer.toJson<double?>(accuracyMeters),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'localImagePath': serializer.toJson<String?>(localImagePath),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncError': serializer.toJson<String?>(syncError),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingReport copyWith(
          {int? id,
          String? localUuid,
          Value<String?> serverUuid = const Value.absent(),
          Value<int?> userId = const Value.absent(),
          Value<String?> routeUuid = const Value.absent(),
          String? category,
          String? description,
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          Value<double?> accuracyMeters = const Value.absent(),
          DateTime? capturedAt,
          Value<String?> localImagePath = const Value.absent(),
          String? syncStatus,
          Value<String?> syncError = const Value.absent(),
          Value<DateTime?> syncedAt = const Value.absent(),
          DateTime? createdAt}) =>
      PendingReport(
        id: id ?? this.id,
        localUuid: localUuid ?? this.localUuid,
        serverUuid: serverUuid.present ? serverUuid.value : this.serverUuid,
        userId: userId.present ? userId.value : this.userId,
        routeUuid: routeUuid.present ? routeUuid.value : this.routeUuid,
        category: category ?? this.category,
        description: description ?? this.description,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        accuracyMeters:
            accuracyMeters.present ? accuracyMeters.value : this.accuracyMeters,
        capturedAt: capturedAt ?? this.capturedAt,
        localImagePath:
            localImagePath.present ? localImagePath.value : this.localImagePath,
        syncStatus: syncStatus ?? this.syncStatus,
        syncError: syncError.present ? syncError.value : this.syncError,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  PendingReport copyWithCompanion(PendingReportsCompanion data) {
    return PendingReport(
      id: data.id.present ? data.id.value : this.id,
      localUuid: data.localUuid.present ? data.localUuid.value : this.localUuid,
      serverUuid:
          data.serverUuid.present ? data.serverUuid.value : this.serverUuid,
      userId: data.userId.present ? data.userId.value : this.userId,
      routeUuid: data.routeUuid.present ? data.routeUuid.value : this.routeUuid,
      category: data.category.present ? data.category.value : this.category,
      description:
          data.description.present ? data.description.value : this.description,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      accuracyMeters: data.accuracyMeters.present
          ? data.accuracyMeters.value
          : this.accuracyMeters,
      capturedAt:
          data.capturedAt.present ? data.capturedAt.value : this.capturedAt,
      localImagePath: data.localImagePath.present
          ? data.localImagePath.value
          : this.localImagePath,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingReport(')
          ..write('id: $id, ')
          ..write('localUuid: $localUuid, ')
          ..write('serverUuid: $serverUuid, ')
          ..write('userId: $userId, ')
          ..write('routeUuid: $routeUuid, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accuracyMeters: $accuracyMeters, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      localUuid,
      serverUuid,
      userId,
      routeUuid,
      category,
      description,
      latitude,
      longitude,
      accuracyMeters,
      capturedAt,
      localImagePath,
      syncStatus,
      syncError,
      syncedAt,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingReport &&
          other.id == this.id &&
          other.localUuid == this.localUuid &&
          other.serverUuid == this.serverUuid &&
          other.userId == this.userId &&
          other.routeUuid == this.routeUuid &&
          other.category == this.category &&
          other.description == this.description &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.accuracyMeters == this.accuracyMeters &&
          other.capturedAt == this.capturedAt &&
          other.localImagePath == this.localImagePath &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError &&
          other.syncedAt == this.syncedAt &&
          other.createdAt == this.createdAt);
}

class PendingReportsCompanion extends UpdateCompanion<PendingReport> {
  final Value<int> id;
  final Value<String> localUuid;
  final Value<String?> serverUuid;
  final Value<int?> userId;
  final Value<String?> routeUuid;
  final Value<String> category;
  final Value<String> description;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<double?> accuracyMeters;
  final Value<DateTime> capturedAt;
  final Value<String?> localImagePath;
  final Value<String> syncStatus;
  final Value<String?> syncError;
  final Value<DateTime?> syncedAt;
  final Value<DateTime> createdAt;
  const PendingReportsCompanion({
    this.id = const Value.absent(),
    this.localUuid = const Value.absent(),
    this.serverUuid = const Value.absent(),
    this.userId = const Value.absent(),
    this.routeUuid = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.accuracyMeters = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.localImagePath = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PendingReportsCompanion.insert({
    this.id = const Value.absent(),
    required String localUuid,
    this.serverUuid = const Value.absent(),
    this.userId = const Value.absent(),
    this.routeUuid = const Value.absent(),
    required String category,
    required String description,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.accuracyMeters = const Value.absent(),
    required DateTime capturedAt,
    this.localImagePath = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : localUuid = Value(localUuid),
        category = Value(category),
        description = Value(description),
        capturedAt = Value(capturedAt);
  static Insertable<PendingReport> custom({
    Expression<int>? id,
    Expression<String>? localUuid,
    Expression<String>? serverUuid,
    Expression<int>? userId,
    Expression<String>? routeUuid,
    Expression<String>? category,
    Expression<String>? description,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? accuracyMeters,
    Expression<DateTime>? capturedAt,
    Expression<String>? localImagePath,
    Expression<String>? syncStatus,
    Expression<String>? syncError,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localUuid != null) 'local_uuid': localUuid,
      if (serverUuid != null) 'server_uuid': serverUuid,
      if (userId != null) 'user_id': userId,
      if (routeUuid != null) 'route_uuid': routeUuid,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (accuracyMeters != null) 'accuracy_meters': accuracyMeters,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (localImagePath != null) 'local_image_path': localImagePath,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PendingReportsCompanion copyWith(
      {Value<int>? id,
      Value<String>? localUuid,
      Value<String?>? serverUuid,
      Value<int?>? userId,
      Value<String?>? routeUuid,
      Value<String>? category,
      Value<String>? description,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<double?>? accuracyMeters,
      Value<DateTime>? capturedAt,
      Value<String?>? localImagePath,
      Value<String>? syncStatus,
      Value<String?>? syncError,
      Value<DateTime?>? syncedAt,
      Value<DateTime>? createdAt}) {
    return PendingReportsCompanion(
      id: id ?? this.id,
      localUuid: localUuid ?? this.localUuid,
      serverUuid: serverUuid ?? this.serverUuid,
      userId: userId ?? this.userId,
      routeUuid: routeUuid ?? this.routeUuid,
      category: category ?? this.category,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      capturedAt: capturedAt ?? this.capturedAt,
      localImagePath: localImagePath ?? this.localImagePath,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      syncedAt: syncedAt ?? this.syncedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (localUuid.present) {
      map['local_uuid'] = Variable<String>(localUuid.value);
    }
    if (serverUuid.present) {
      map['server_uuid'] = Variable<String>(serverUuid.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (routeUuid.present) {
      map['route_uuid'] = Variable<String>(routeUuid.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (accuracyMeters.present) {
      map['accuracy_meters'] = Variable<double>(accuracyMeters.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (localImagePath.present) {
      map['local_image_path'] = Variable<String>(localImagePath.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingReportsCompanion(')
          ..write('id: $id, ')
          ..write('localUuid: $localUuid, ')
          ..write('serverUuid: $serverUuid, ')
          ..write('userId: $userId, ')
          ..write('routeUuid: $routeUuid, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accuracyMeters: $accuracyMeters, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SafetyChecklistsTable extends SafetyChecklists
    with TableInfo<$SafetyChecklistsTable, SafetyChecklist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SafetyChecklistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _recommendationKeyMeta =
      const VerificationMeta('recommendationKey');
  @override
  late final GeneratedColumn<String> recommendationKey =
      GeneratedColumn<String>('recommendation_key', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _isCheckedMeta =
      const VerificationMeta('isChecked');
  @override
  late final GeneratedColumn<bool> isChecked = GeneratedColumn<bool>(
      'is_checked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_checked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, recommendationKey, isChecked, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'safety_checklists';
  @override
  VerificationContext validateIntegrity(Insertable<SafetyChecklist> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recommendation_key')) {
      context.handle(
          _recommendationKeyMeta,
          recommendationKey.isAcceptableOrUnknown(
              data['recommendation_key']!, _recommendationKeyMeta));
    } else if (isInserting) {
      context.missing(_recommendationKeyMeta);
    }
    if (data.containsKey('is_checked')) {
      context.handle(_isCheckedMeta,
          isChecked.isAcceptableOrUnknown(data['is_checked']!, _isCheckedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SafetyChecklist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SafetyChecklist(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      recommendationKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}recommendation_key'])!,
      isChecked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_checked'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SafetyChecklistsTable createAlias(String alias) {
    return $SafetyChecklistsTable(attachedDatabase, alias);
  }
}

class SafetyChecklist extends DataClass implements Insertable<SafetyChecklist> {
  final int id;
  final String recommendationKey;
  final bool isChecked;
  final DateTime updatedAt;
  const SafetyChecklist(
      {required this.id,
      required this.recommendationKey,
      required this.isChecked,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recommendation_key'] = Variable<String>(recommendationKey);
    map['is_checked'] = Variable<bool>(isChecked);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SafetyChecklistsCompanion toCompanion(bool nullToAbsent) {
    return SafetyChecklistsCompanion(
      id: Value(id),
      recommendationKey: Value(recommendationKey),
      isChecked: Value(isChecked),
      updatedAt: Value(updatedAt),
    );
  }

  factory SafetyChecklist.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SafetyChecklist(
      id: serializer.fromJson<int>(json['id']),
      recommendationKey: serializer.fromJson<String>(json['recommendationKey']),
      isChecked: serializer.fromJson<bool>(json['isChecked']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recommendationKey': serializer.toJson<String>(recommendationKey),
      'isChecked': serializer.toJson<bool>(isChecked),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SafetyChecklist copyWith(
          {int? id,
          String? recommendationKey,
          bool? isChecked,
          DateTime? updatedAt}) =>
      SafetyChecklist(
        id: id ?? this.id,
        recommendationKey: recommendationKey ?? this.recommendationKey,
        isChecked: isChecked ?? this.isChecked,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SafetyChecklist copyWithCompanion(SafetyChecklistsCompanion data) {
    return SafetyChecklist(
      id: data.id.present ? data.id.value : this.id,
      recommendationKey: data.recommendationKey.present
          ? data.recommendationKey.value
          : this.recommendationKey,
      isChecked: data.isChecked.present ? data.isChecked.value : this.isChecked,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SafetyChecklist(')
          ..write('id: $id, ')
          ..write('recommendationKey: $recommendationKey, ')
          ..write('isChecked: $isChecked, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, recommendationKey, isChecked, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SafetyChecklist &&
          other.id == this.id &&
          other.recommendationKey == this.recommendationKey &&
          other.isChecked == this.isChecked &&
          other.updatedAt == this.updatedAt);
}

class SafetyChecklistsCompanion extends UpdateCompanion<SafetyChecklist> {
  final Value<int> id;
  final Value<String> recommendationKey;
  final Value<bool> isChecked;
  final Value<DateTime> updatedAt;
  const SafetyChecklistsCompanion({
    this.id = const Value.absent(),
    this.recommendationKey = const Value.absent(),
    this.isChecked = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SafetyChecklistsCompanion.insert({
    this.id = const Value.absent(),
    required String recommendationKey,
    this.isChecked = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : recommendationKey = Value(recommendationKey);
  static Insertable<SafetyChecklist> custom({
    Expression<int>? id,
    Expression<String>? recommendationKey,
    Expression<bool>? isChecked,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recommendationKey != null) 'recommendation_key': recommendationKey,
      if (isChecked != null) 'is_checked': isChecked,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SafetyChecklistsCompanion copyWith(
      {Value<int>? id,
      Value<String>? recommendationKey,
      Value<bool>? isChecked,
      Value<DateTime>? updatedAt}) {
    return SafetyChecklistsCompanion(
      id: id ?? this.id,
      recommendationKey: recommendationKey ?? this.recommendationKey,
      isChecked: isChecked ?? this.isChecked,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recommendationKey.present) {
      map['recommendation_key'] = Variable<String>(recommendationKey.value);
    }
    if (isChecked.present) {
      map['is_checked'] = Variable<bool>(isChecked.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SafetyChecklistsCompanion(')
          ..write('id: $id, ')
          ..write('recommendationKey: $recommendationKey, ')
          ..write('isChecked: $isChecked, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalCheckpointRegistrationsTable extends LocalCheckpointRegistrations
    with
        TableInfo<$LocalCheckpointRegistrationsTable,
            LocalCheckpointRegistration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCheckpointRegistrationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _localUuidMeta =
      const VerificationMeta('localUuid');
  @override
  late final GeneratedColumn<String> localUuid = GeneratedColumn<String>(
      'local_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _serverUuidMeta =
      const VerificationMeta('serverUuid');
  @override
  late final GeneratedColumn<String> serverUuid = GeneratedColumn<String>(
      'server_uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _checkpointNameMeta =
      const VerificationMeta('checkpointName');
  @override
  late final GeneratedColumn<String> checkpointName = GeneratedColumn<String>(
      'checkpoint_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue:
          const Constant('Garita de Control Huaguruncho - Abra Huachón'));
  static const VerificationMeta _visitorNameMeta =
      const VerificationMeta('visitorName');
  @override
  late final GeneratedColumn<String> visitorName = GeneratedColumn<String>(
      'visitor_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _documentTypeMeta =
      const VerificationMeta('documentType');
  @override
  late final GeneratedColumn<String> documentType = GeneratedColumn<String>(
      'document_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('DNI'));
  static const VerificationMeta _documentNumberMeta =
      const VerificationMeta('documentNumber');
  @override
  late final GeneratedColumn<String> documentNumber = GeneratedColumn<String>(
      'document_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneNumberMeta =
      const VerificationMeta('phoneNumber');
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
      'phone_number', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _groupSizeMeta =
      const VerificationMeta('groupSize');
  @override
  late final GeneratedColumn<int> groupSize = GeneratedColumn<int>(
      'group_size', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _routeNameMeta =
      const VerificationMeta('routeName');
  @override
  late final GeneratedColumn<String> routeName = GeneratedColumn<String>(
      'route_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Nevado Huaguruncho - Ruta Glaciar'));
  static const VerificationMeta _guideNameMeta =
      const VerificationMeta('guideName');
  @override
  late final GeneratedColumn<String> guideName = GeneratedColumn<String>(
      'guide_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _entryDateTimeMeta =
      const VerificationMeta('entryDateTime');
  @override
  late final GeneratedColumn<DateTime> entryDateTime =
      GeneratedColumn<DateTime>('entry_date_time', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _entryRangerNameMeta =
      const VerificationMeta('entryRangerName');
  @override
  late final GeneratedColumn<String> entryRangerName = GeneratedColumn<String>(
      'entry_ranger_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _plasticBottlesInMeta =
      const VerificationMeta('plasticBottlesIn');
  @override
  late final GeneratedColumn<int> plasticBottlesIn = GeneratedColumn<int>(
      'plastic_bottles_in', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _cansInMeta = const VerificationMeta('cansIn');
  @override
  late final GeneratedColumn<int> cansIn = GeneratedColumn<int>(
      'cans_in', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _plasticWrappersInMeta =
      const VerificationMeta('plasticWrappersIn');
  @override
  late final GeneratedColumn<int> plasticWrappersIn = GeneratedColumn<int>(
      'plastic_wrappers_in', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _plasticBagsInMeta =
      const VerificationMeta('plasticBagsIn');
  @override
  late final GeneratedColumn<int> plasticBagsIn = GeneratedColumn<int>(
      'plastic_bags_in', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _batteriesInMeta =
      const VerificationMeta('batteriesIn');
  @override
  late final GeneratedColumn<int> batteriesIn = GeneratedColumn<int>(
      'batteries_in', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _gasCanistersInMeta =
      const VerificationMeta('gasCanistersIn');
  @override
  late final GeneratedColumn<int> gasCanistersIn = GeneratedColumn<int>(
      'gas_canisters_in', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _otherWasteDetailsInMeta =
      const VerificationMeta('otherWasteDetailsIn');
  @override
  late final GeneratedColumn<String> otherWasteDetailsIn =
      GeneratedColumn<String>('other_waste_details_in', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _totalItemsInMeta =
      const VerificationMeta('totalItemsIn');
  @override
  late final GeneratedColumn<int> totalItemsIn = GeneratedColumn<int>(
      'total_items_in', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _exitDateTimeMeta =
      const VerificationMeta('exitDateTime');
  @override
  late final GeneratedColumn<DateTime> exitDateTime = GeneratedColumn<DateTime>(
      'exit_date_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _exitRangerNameMeta =
      const VerificationMeta('exitRangerName');
  @override
  late final GeneratedColumn<String> exitRangerName = GeneratedColumn<String>(
      'exit_ranger_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _plasticBottlesOutMeta =
      const VerificationMeta('plasticBottlesOut');
  @override
  late final GeneratedColumn<int> plasticBottlesOut = GeneratedColumn<int>(
      'plastic_bottles_out', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _cansOutMeta =
      const VerificationMeta('cansOut');
  @override
  late final GeneratedColumn<int> cansOut = GeneratedColumn<int>(
      'cans_out', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _plasticWrappersOutMeta =
      const VerificationMeta('plasticWrappersOut');
  @override
  late final GeneratedColumn<int> plasticWrappersOut = GeneratedColumn<int>(
      'plastic_wrappers_out', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _plasticBagsOutMeta =
      const VerificationMeta('plasticBagsOut');
  @override
  late final GeneratedColumn<int> plasticBagsOut = GeneratedColumn<int>(
      'plastic_bags_out', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _batteriesOutMeta =
      const VerificationMeta('batteriesOut');
  @override
  late final GeneratedColumn<int> batteriesOut = GeneratedColumn<int>(
      'batteries_out', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _gasCanistersOutMeta =
      const VerificationMeta('gasCanistersOut');
  @override
  late final GeneratedColumn<int> gasCanistersOut = GeneratedColumn<int>(
      'gas_canisters_out', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalItemsOutMeta =
      const VerificationMeta('totalItemsOut');
  @override
  late final GeneratedColumn<int> totalItemsOut = GeneratedColumn<int>(
      'total_items_out', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _wasteComplianceStatusMeta =
      const VerificationMeta('wasteComplianceStatus');
  @override
  late final GeneratedColumn<String> wasteComplianceStatus =
      GeneratedColumn<String>('waste_compliance_status', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('pending_checkout'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('en_montana'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _syncErrorMeta =
      const VerificationMeta('syncError');
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
      'sync_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        localUuid,
        serverUuid,
        checkpointName,
        visitorName,
        documentType,
        documentNumber,
        phoneNumber,
        groupSize,
        routeName,
        guideName,
        entryDateTime,
        entryRangerName,
        plasticBottlesIn,
        cansIn,
        plasticWrappersIn,
        plasticBagsIn,
        batteriesIn,
        gasCanistersIn,
        otherWasteDetailsIn,
        totalItemsIn,
        exitDateTime,
        exitRangerName,
        plasticBottlesOut,
        cansOut,
        plasticWrappersOut,
        plasticBagsOut,
        batteriesOut,
        gasCanistersOut,
        totalItemsOut,
        wasteComplianceStatus,
        status,
        notes,
        syncStatus,
        syncError,
        syncedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_checkpoint_registrations';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalCheckpointRegistration> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('local_uuid')) {
      context.handle(_localUuidMeta,
          localUuid.isAcceptableOrUnknown(data['local_uuid']!, _localUuidMeta));
    } else if (isInserting) {
      context.missing(_localUuidMeta);
    }
    if (data.containsKey('server_uuid')) {
      context.handle(
          _serverUuidMeta,
          serverUuid.isAcceptableOrUnknown(
              data['server_uuid']!, _serverUuidMeta));
    }
    if (data.containsKey('checkpoint_name')) {
      context.handle(
          _checkpointNameMeta,
          checkpointName.isAcceptableOrUnknown(
              data['checkpoint_name']!, _checkpointNameMeta));
    }
    if (data.containsKey('visitor_name')) {
      context.handle(
          _visitorNameMeta,
          visitorName.isAcceptableOrUnknown(
              data['visitor_name']!, _visitorNameMeta));
    } else if (isInserting) {
      context.missing(_visitorNameMeta);
    }
    if (data.containsKey('document_type')) {
      context.handle(
          _documentTypeMeta,
          documentType.isAcceptableOrUnknown(
              data['document_type']!, _documentTypeMeta));
    }
    if (data.containsKey('document_number')) {
      context.handle(
          _documentNumberMeta,
          documentNumber.isAcceptableOrUnknown(
              data['document_number']!, _documentNumberMeta));
    } else if (isInserting) {
      context.missing(_documentNumberMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
          _phoneNumberMeta,
          phoneNumber.isAcceptableOrUnknown(
              data['phone_number']!, _phoneNumberMeta));
    }
    if (data.containsKey('group_size')) {
      context.handle(_groupSizeMeta,
          groupSize.isAcceptableOrUnknown(data['group_size']!, _groupSizeMeta));
    }
    if (data.containsKey('route_name')) {
      context.handle(_routeNameMeta,
          routeName.isAcceptableOrUnknown(data['route_name']!, _routeNameMeta));
    }
    if (data.containsKey('guide_name')) {
      context.handle(_guideNameMeta,
          guideName.isAcceptableOrUnknown(data['guide_name']!, _guideNameMeta));
    }
    if (data.containsKey('entry_date_time')) {
      context.handle(
          _entryDateTimeMeta,
          entryDateTime.isAcceptableOrUnknown(
              data['entry_date_time']!, _entryDateTimeMeta));
    } else if (isInserting) {
      context.missing(_entryDateTimeMeta);
    }
    if (data.containsKey('entry_ranger_name')) {
      context.handle(
          _entryRangerNameMeta,
          entryRangerName.isAcceptableOrUnknown(
              data['entry_ranger_name']!, _entryRangerNameMeta));
    }
    if (data.containsKey('plastic_bottles_in')) {
      context.handle(
          _plasticBottlesInMeta,
          plasticBottlesIn.isAcceptableOrUnknown(
              data['plastic_bottles_in']!, _plasticBottlesInMeta));
    }
    if (data.containsKey('cans_in')) {
      context.handle(_cansInMeta,
          cansIn.isAcceptableOrUnknown(data['cans_in']!, _cansInMeta));
    }
    if (data.containsKey('plastic_wrappers_in')) {
      context.handle(
          _plasticWrappersInMeta,
          plasticWrappersIn.isAcceptableOrUnknown(
              data['plastic_wrappers_in']!, _plasticWrappersInMeta));
    }
    if (data.containsKey('plastic_bags_in')) {
      context.handle(
          _plasticBagsInMeta,
          plasticBagsIn.isAcceptableOrUnknown(
              data['plastic_bags_in']!, _plasticBagsInMeta));
    }
    if (data.containsKey('batteries_in')) {
      context.handle(
          _batteriesInMeta,
          batteriesIn.isAcceptableOrUnknown(
              data['batteries_in']!, _batteriesInMeta));
    }
    if (data.containsKey('gas_canisters_in')) {
      context.handle(
          _gasCanistersInMeta,
          gasCanistersIn.isAcceptableOrUnknown(
              data['gas_canisters_in']!, _gasCanistersInMeta));
    }
    if (data.containsKey('other_waste_details_in')) {
      context.handle(
          _otherWasteDetailsInMeta,
          otherWasteDetailsIn.isAcceptableOrUnknown(
              data['other_waste_details_in']!, _otherWasteDetailsInMeta));
    }
    if (data.containsKey('total_items_in')) {
      context.handle(
          _totalItemsInMeta,
          totalItemsIn.isAcceptableOrUnknown(
              data['total_items_in']!, _totalItemsInMeta));
    }
    if (data.containsKey('exit_date_time')) {
      context.handle(
          _exitDateTimeMeta,
          exitDateTime.isAcceptableOrUnknown(
              data['exit_date_time']!, _exitDateTimeMeta));
    }
    if (data.containsKey('exit_ranger_name')) {
      context.handle(
          _exitRangerNameMeta,
          exitRangerName.isAcceptableOrUnknown(
              data['exit_ranger_name']!, _exitRangerNameMeta));
    }
    if (data.containsKey('plastic_bottles_out')) {
      context.handle(
          _plasticBottlesOutMeta,
          plasticBottlesOut.isAcceptableOrUnknown(
              data['plastic_bottles_out']!, _plasticBottlesOutMeta));
    }
    if (data.containsKey('cans_out')) {
      context.handle(_cansOutMeta,
          cansOut.isAcceptableOrUnknown(data['cans_out']!, _cansOutMeta));
    }
    if (data.containsKey('plastic_wrappers_out')) {
      context.handle(
          _plasticWrappersOutMeta,
          plasticWrappersOut.isAcceptableOrUnknown(
              data['plastic_wrappers_out']!, _plasticWrappersOutMeta));
    }
    if (data.containsKey('plastic_bags_out')) {
      context.handle(
          _plasticBagsOutMeta,
          plasticBagsOut.isAcceptableOrUnknown(
              data['plastic_bags_out']!, _plasticBagsOutMeta));
    }
    if (data.containsKey('batteries_out')) {
      context.handle(
          _batteriesOutMeta,
          batteriesOut.isAcceptableOrUnknown(
              data['batteries_out']!, _batteriesOutMeta));
    }
    if (data.containsKey('gas_canisters_out')) {
      context.handle(
          _gasCanistersOutMeta,
          gasCanistersOut.isAcceptableOrUnknown(
              data['gas_canisters_out']!, _gasCanistersOutMeta));
    }
    if (data.containsKey('total_items_out')) {
      context.handle(
          _totalItemsOutMeta,
          totalItemsOut.isAcceptableOrUnknown(
              data['total_items_out']!, _totalItemsOutMeta));
    }
    if (data.containsKey('waste_compliance_status')) {
      context.handle(
          _wasteComplianceStatusMeta,
          wasteComplianceStatus.isAcceptableOrUnknown(
              data['waste_compliance_status']!, _wasteComplianceStatusMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('sync_error')) {
      context.handle(_syncErrorMeta,
          syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCheckpointRegistration map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCheckpointRegistration(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      localUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_uuid'])!,
      serverUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_uuid']),
      checkpointName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}checkpoint_name'])!,
      visitorName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}visitor_name'])!,
      documentType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}document_type'])!,
      documentNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}document_number'])!,
      phoneNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_number'])!,
      groupSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}group_size'])!,
      routeName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}route_name'])!,
      guideName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}guide_name']),
      entryDateTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}entry_date_time'])!,
      entryRangerName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}entry_ranger_name']),
      plasticBottlesIn: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}plastic_bottles_in'])!,
      cansIn: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cans_in'])!,
      plasticWrappersIn: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}plastic_wrappers_in'])!,
      plasticBagsIn: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}plastic_bags_in'])!,
      batteriesIn: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}batteries_in'])!,
      gasCanistersIn: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gas_canisters_in'])!,
      otherWasteDetailsIn: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}other_waste_details_in']),
      totalItemsIn: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_items_in'])!,
      exitDateTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}exit_date_time']),
      exitRangerName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}exit_ranger_name']),
      plasticBottlesOut: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}plastic_bottles_out'])!,
      cansOut: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cans_out'])!,
      plasticWrappersOut: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}plastic_wrappers_out'])!,
      plasticBagsOut: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}plastic_bags_out'])!,
      batteriesOut: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}batteries_out'])!,
      gasCanistersOut: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gas_canisters_out'])!,
      totalItemsOut: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_items_out'])!,
      wasteComplianceStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}waste_compliance_status'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      syncError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_error']),
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LocalCheckpointRegistrationsTable createAlias(String alias) {
    return $LocalCheckpointRegistrationsTable(attachedDatabase, alias);
  }
}

class LocalCheckpointRegistration extends DataClass
    implements Insertable<LocalCheckpointRegistration> {
  final int id;
  final String localUuid;
  final String? serverUuid;
  final String checkpointName;
  final String visitorName;
  final String documentType;
  final String documentNumber;
  final String phoneNumber;
  final int groupSize;
  final String routeName;
  final String? guideName;
  final DateTime entryDateTime;
  final String? entryRangerName;
  final int plasticBottlesIn;
  final int cansIn;
  final int plasticWrappersIn;
  final int plasticBagsIn;
  final int batteriesIn;
  final int gasCanistersIn;
  final String? otherWasteDetailsIn;
  final int totalItemsIn;
  final DateTime? exitDateTime;
  final String? exitRangerName;
  final int plasticBottlesOut;
  final int cansOut;
  final int plasticWrappersOut;
  final int plasticBagsOut;
  final int batteriesOut;
  final int gasCanistersOut;
  final int totalItemsOut;
  final String wasteComplianceStatus;
  final String status;
  final String? notes;
  final String syncStatus;
  final String? syncError;
  final DateTime? syncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalCheckpointRegistration(
      {required this.id,
      required this.localUuid,
      this.serverUuid,
      required this.checkpointName,
      required this.visitorName,
      required this.documentType,
      required this.documentNumber,
      required this.phoneNumber,
      required this.groupSize,
      required this.routeName,
      this.guideName,
      required this.entryDateTime,
      this.entryRangerName,
      required this.plasticBottlesIn,
      required this.cansIn,
      required this.plasticWrappersIn,
      required this.plasticBagsIn,
      required this.batteriesIn,
      required this.gasCanistersIn,
      this.otherWasteDetailsIn,
      required this.totalItemsIn,
      this.exitDateTime,
      this.exitRangerName,
      required this.plasticBottlesOut,
      required this.cansOut,
      required this.plasticWrappersOut,
      required this.plasticBagsOut,
      required this.batteriesOut,
      required this.gasCanistersOut,
      required this.totalItemsOut,
      required this.wasteComplianceStatus,
      required this.status,
      this.notes,
      required this.syncStatus,
      this.syncError,
      this.syncedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['local_uuid'] = Variable<String>(localUuid);
    if (!nullToAbsent || serverUuid != null) {
      map['server_uuid'] = Variable<String>(serverUuid);
    }
    map['checkpoint_name'] = Variable<String>(checkpointName);
    map['visitor_name'] = Variable<String>(visitorName);
    map['document_type'] = Variable<String>(documentType);
    map['document_number'] = Variable<String>(documentNumber);
    map['phone_number'] = Variable<String>(phoneNumber);
    map['group_size'] = Variable<int>(groupSize);
    map['route_name'] = Variable<String>(routeName);
    if (!nullToAbsent || guideName != null) {
      map['guide_name'] = Variable<String>(guideName);
    }
    map['entry_date_time'] = Variable<DateTime>(entryDateTime);
    if (!nullToAbsent || entryRangerName != null) {
      map['entry_ranger_name'] = Variable<String>(entryRangerName);
    }
    map['plastic_bottles_in'] = Variable<int>(plasticBottlesIn);
    map['cans_in'] = Variable<int>(cansIn);
    map['plastic_wrappers_in'] = Variable<int>(plasticWrappersIn);
    map['plastic_bags_in'] = Variable<int>(plasticBagsIn);
    map['batteries_in'] = Variable<int>(batteriesIn);
    map['gas_canisters_in'] = Variable<int>(gasCanistersIn);
    if (!nullToAbsent || otherWasteDetailsIn != null) {
      map['other_waste_details_in'] = Variable<String>(otherWasteDetailsIn);
    }
    map['total_items_in'] = Variable<int>(totalItemsIn);
    if (!nullToAbsent || exitDateTime != null) {
      map['exit_date_time'] = Variable<DateTime>(exitDateTime);
    }
    if (!nullToAbsent || exitRangerName != null) {
      map['exit_ranger_name'] = Variable<String>(exitRangerName);
    }
    map['plastic_bottles_out'] = Variable<int>(plasticBottlesOut);
    map['cans_out'] = Variable<int>(cansOut);
    map['plastic_wrappers_out'] = Variable<int>(plasticWrappersOut);
    map['plastic_bags_out'] = Variable<int>(plasticBagsOut);
    map['batteries_out'] = Variable<int>(batteriesOut);
    map['gas_canisters_out'] = Variable<int>(gasCanistersOut);
    map['total_items_out'] = Variable<int>(totalItemsOut);
    map['waste_compliance_status'] = Variable<String>(wasteComplianceStatus);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalCheckpointRegistrationsCompanion toCompanion(bool nullToAbsent) {
    return LocalCheckpointRegistrationsCompanion(
      id: Value(id),
      localUuid: Value(localUuid),
      serverUuid: serverUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUuid),
      checkpointName: Value(checkpointName),
      visitorName: Value(visitorName),
      documentType: Value(documentType),
      documentNumber: Value(documentNumber),
      phoneNumber: Value(phoneNumber),
      groupSize: Value(groupSize),
      routeName: Value(routeName),
      guideName: guideName == null && nullToAbsent
          ? const Value.absent()
          : Value(guideName),
      entryDateTime: Value(entryDateTime),
      entryRangerName: entryRangerName == null && nullToAbsent
          ? const Value.absent()
          : Value(entryRangerName),
      plasticBottlesIn: Value(plasticBottlesIn),
      cansIn: Value(cansIn),
      plasticWrappersIn: Value(plasticWrappersIn),
      plasticBagsIn: Value(plasticBagsIn),
      batteriesIn: Value(batteriesIn),
      gasCanistersIn: Value(gasCanistersIn),
      otherWasteDetailsIn: otherWasteDetailsIn == null && nullToAbsent
          ? const Value.absent()
          : Value(otherWasteDetailsIn),
      totalItemsIn: Value(totalItemsIn),
      exitDateTime: exitDateTime == null && nullToAbsent
          ? const Value.absent()
          : Value(exitDateTime),
      exitRangerName: exitRangerName == null && nullToAbsent
          ? const Value.absent()
          : Value(exitRangerName),
      plasticBottlesOut: Value(plasticBottlesOut),
      cansOut: Value(cansOut),
      plasticWrappersOut: Value(plasticWrappersOut),
      plasticBagsOut: Value(plasticBagsOut),
      batteriesOut: Value(batteriesOut),
      gasCanistersOut: Value(gasCanistersOut),
      totalItemsOut: Value(totalItemsOut),
      wasteComplianceStatus: Value(wasteComplianceStatus),
      status: Value(status),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalCheckpointRegistration.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCheckpointRegistration(
      id: serializer.fromJson<int>(json['id']),
      localUuid: serializer.fromJson<String>(json['localUuid']),
      serverUuid: serializer.fromJson<String?>(json['serverUuid']),
      checkpointName: serializer.fromJson<String>(json['checkpointName']),
      visitorName: serializer.fromJson<String>(json['visitorName']),
      documentType: serializer.fromJson<String>(json['documentType']),
      documentNumber: serializer.fromJson<String>(json['documentNumber']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      groupSize: serializer.fromJson<int>(json['groupSize']),
      routeName: serializer.fromJson<String>(json['routeName']),
      guideName: serializer.fromJson<String?>(json['guideName']),
      entryDateTime: serializer.fromJson<DateTime>(json['entryDateTime']),
      entryRangerName: serializer.fromJson<String?>(json['entryRangerName']),
      plasticBottlesIn: serializer.fromJson<int>(json['plasticBottlesIn']),
      cansIn: serializer.fromJson<int>(json['cansIn']),
      plasticWrappersIn: serializer.fromJson<int>(json['plasticWrappersIn']),
      plasticBagsIn: serializer.fromJson<int>(json['plasticBagsIn']),
      batteriesIn: serializer.fromJson<int>(json['batteriesIn']),
      gasCanistersIn: serializer.fromJson<int>(json['gasCanistersIn']),
      otherWasteDetailsIn:
          serializer.fromJson<String?>(json['otherWasteDetailsIn']),
      totalItemsIn: serializer.fromJson<int>(json['totalItemsIn']),
      exitDateTime: serializer.fromJson<DateTime?>(json['exitDateTime']),
      exitRangerName: serializer.fromJson<String?>(json['exitRangerName']),
      plasticBottlesOut: serializer.fromJson<int>(json['plasticBottlesOut']),
      cansOut: serializer.fromJson<int>(json['cansOut']),
      plasticWrappersOut: serializer.fromJson<int>(json['plasticWrappersOut']),
      plasticBagsOut: serializer.fromJson<int>(json['plasticBagsOut']),
      batteriesOut: serializer.fromJson<int>(json['batteriesOut']),
      gasCanistersOut: serializer.fromJson<int>(json['gasCanistersOut']),
      totalItemsOut: serializer.fromJson<int>(json['totalItemsOut']),
      wasteComplianceStatus:
          serializer.fromJson<String>(json['wasteComplianceStatus']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncError: serializer.fromJson<String?>(json['syncError']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'localUuid': serializer.toJson<String>(localUuid),
      'serverUuid': serializer.toJson<String?>(serverUuid),
      'checkpointName': serializer.toJson<String>(checkpointName),
      'visitorName': serializer.toJson<String>(visitorName),
      'documentType': serializer.toJson<String>(documentType),
      'documentNumber': serializer.toJson<String>(documentNumber),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'groupSize': serializer.toJson<int>(groupSize),
      'routeName': serializer.toJson<String>(routeName),
      'guideName': serializer.toJson<String?>(guideName),
      'entryDateTime': serializer.toJson<DateTime>(entryDateTime),
      'entryRangerName': serializer.toJson<String?>(entryRangerName),
      'plasticBottlesIn': serializer.toJson<int>(plasticBottlesIn),
      'cansIn': serializer.toJson<int>(cansIn),
      'plasticWrappersIn': serializer.toJson<int>(plasticWrappersIn),
      'plasticBagsIn': serializer.toJson<int>(plasticBagsIn),
      'batteriesIn': serializer.toJson<int>(batteriesIn),
      'gasCanistersIn': serializer.toJson<int>(gasCanistersIn),
      'otherWasteDetailsIn': serializer.toJson<String?>(otherWasteDetailsIn),
      'totalItemsIn': serializer.toJson<int>(totalItemsIn),
      'exitDateTime': serializer.toJson<DateTime?>(exitDateTime),
      'exitRangerName': serializer.toJson<String?>(exitRangerName),
      'plasticBottlesOut': serializer.toJson<int>(plasticBottlesOut),
      'cansOut': serializer.toJson<int>(cansOut),
      'plasticWrappersOut': serializer.toJson<int>(plasticWrappersOut),
      'plasticBagsOut': serializer.toJson<int>(plasticBagsOut),
      'batteriesOut': serializer.toJson<int>(batteriesOut),
      'gasCanistersOut': serializer.toJson<int>(gasCanistersOut),
      'totalItemsOut': serializer.toJson<int>(totalItemsOut),
      'wasteComplianceStatus': serializer.toJson<String>(wasteComplianceStatus),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncError': serializer.toJson<String?>(syncError),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalCheckpointRegistration copyWith(
          {int? id,
          String? localUuid,
          Value<String?> serverUuid = const Value.absent(),
          String? checkpointName,
          String? visitorName,
          String? documentType,
          String? documentNumber,
          String? phoneNumber,
          int? groupSize,
          String? routeName,
          Value<String?> guideName = const Value.absent(),
          DateTime? entryDateTime,
          Value<String?> entryRangerName = const Value.absent(),
          int? plasticBottlesIn,
          int? cansIn,
          int? plasticWrappersIn,
          int? plasticBagsIn,
          int? batteriesIn,
          int? gasCanistersIn,
          Value<String?> otherWasteDetailsIn = const Value.absent(),
          int? totalItemsIn,
          Value<DateTime?> exitDateTime = const Value.absent(),
          Value<String?> exitRangerName = const Value.absent(),
          int? plasticBottlesOut,
          int? cansOut,
          int? plasticWrappersOut,
          int? plasticBagsOut,
          int? batteriesOut,
          int? gasCanistersOut,
          int? totalItemsOut,
          String? wasteComplianceStatus,
          String? status,
          Value<String?> notes = const Value.absent(),
          String? syncStatus,
          Value<String?> syncError = const Value.absent(),
          Value<DateTime?> syncedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      LocalCheckpointRegistration(
        id: id ?? this.id,
        localUuid: localUuid ?? this.localUuid,
        serverUuid: serverUuid.present ? serverUuid.value : this.serverUuid,
        checkpointName: checkpointName ?? this.checkpointName,
        visitorName: visitorName ?? this.visitorName,
        documentType: documentType ?? this.documentType,
        documentNumber: documentNumber ?? this.documentNumber,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        groupSize: groupSize ?? this.groupSize,
        routeName: routeName ?? this.routeName,
        guideName: guideName.present ? guideName.value : this.guideName,
        entryDateTime: entryDateTime ?? this.entryDateTime,
        entryRangerName: entryRangerName.present
            ? entryRangerName.value
            : this.entryRangerName,
        plasticBottlesIn: plasticBottlesIn ?? this.plasticBottlesIn,
        cansIn: cansIn ?? this.cansIn,
        plasticWrappersIn: plasticWrappersIn ?? this.plasticWrappersIn,
        plasticBagsIn: plasticBagsIn ?? this.plasticBagsIn,
        batteriesIn: batteriesIn ?? this.batteriesIn,
        gasCanistersIn: gasCanistersIn ?? this.gasCanistersIn,
        otherWasteDetailsIn: otherWasteDetailsIn.present
            ? otherWasteDetailsIn.value
            : this.otherWasteDetailsIn,
        totalItemsIn: totalItemsIn ?? this.totalItemsIn,
        exitDateTime:
            exitDateTime.present ? exitDateTime.value : this.exitDateTime,
        exitRangerName:
            exitRangerName.present ? exitRangerName.value : this.exitRangerName,
        plasticBottlesOut: plasticBottlesOut ?? this.plasticBottlesOut,
        cansOut: cansOut ?? this.cansOut,
        plasticWrappersOut: plasticWrappersOut ?? this.plasticWrappersOut,
        plasticBagsOut: plasticBagsOut ?? this.plasticBagsOut,
        batteriesOut: batteriesOut ?? this.batteriesOut,
        gasCanistersOut: gasCanistersOut ?? this.gasCanistersOut,
        totalItemsOut: totalItemsOut ?? this.totalItemsOut,
        wasteComplianceStatus:
            wasteComplianceStatus ?? this.wasteComplianceStatus,
        status: status ?? this.status,
        notes: notes.present ? notes.value : this.notes,
        syncStatus: syncStatus ?? this.syncStatus,
        syncError: syncError.present ? syncError.value : this.syncError,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LocalCheckpointRegistration copyWithCompanion(
      LocalCheckpointRegistrationsCompanion data) {
    return LocalCheckpointRegistration(
      id: data.id.present ? data.id.value : this.id,
      localUuid: data.localUuid.present ? data.localUuid.value : this.localUuid,
      serverUuid:
          data.serverUuid.present ? data.serverUuid.value : this.serverUuid,
      checkpointName: data.checkpointName.present
          ? data.checkpointName.value
          : this.checkpointName,
      visitorName:
          data.visitorName.present ? data.visitorName.value : this.visitorName,
      documentType: data.documentType.present
          ? data.documentType.value
          : this.documentType,
      documentNumber: data.documentNumber.present
          ? data.documentNumber.value
          : this.documentNumber,
      phoneNumber:
          data.phoneNumber.present ? data.phoneNumber.value : this.phoneNumber,
      groupSize: data.groupSize.present ? data.groupSize.value : this.groupSize,
      routeName: data.routeName.present ? data.routeName.value : this.routeName,
      guideName: data.guideName.present ? data.guideName.value : this.guideName,
      entryDateTime: data.entryDateTime.present
          ? data.entryDateTime.value
          : this.entryDateTime,
      entryRangerName: data.entryRangerName.present
          ? data.entryRangerName.value
          : this.entryRangerName,
      plasticBottlesIn: data.plasticBottlesIn.present
          ? data.plasticBottlesIn.value
          : this.plasticBottlesIn,
      cansIn: data.cansIn.present ? data.cansIn.value : this.cansIn,
      plasticWrappersIn: data.plasticWrappersIn.present
          ? data.plasticWrappersIn.value
          : this.plasticWrappersIn,
      plasticBagsIn: data.plasticBagsIn.present
          ? data.plasticBagsIn.value
          : this.plasticBagsIn,
      batteriesIn:
          data.batteriesIn.present ? data.batteriesIn.value : this.batteriesIn,
      gasCanistersIn: data.gasCanistersIn.present
          ? data.gasCanistersIn.value
          : this.gasCanistersIn,
      otherWasteDetailsIn: data.otherWasteDetailsIn.present
          ? data.otherWasteDetailsIn.value
          : this.otherWasteDetailsIn,
      totalItemsIn: data.totalItemsIn.present
          ? data.totalItemsIn.value
          : this.totalItemsIn,
      exitDateTime: data.exitDateTime.present
          ? data.exitDateTime.value
          : this.exitDateTime,
      exitRangerName: data.exitRangerName.present
          ? data.exitRangerName.value
          : this.exitRangerName,
      plasticBottlesOut: data.plasticBottlesOut.present
          ? data.plasticBottlesOut.value
          : this.plasticBottlesOut,
      cansOut: data.cansOut.present ? data.cansOut.value : this.cansOut,
      plasticWrappersOut: data.plasticWrappersOut.present
          ? data.plasticWrappersOut.value
          : this.plasticWrappersOut,
      plasticBagsOut: data.plasticBagsOut.present
          ? data.plasticBagsOut.value
          : this.plasticBagsOut,
      batteriesOut: data.batteriesOut.present
          ? data.batteriesOut.value
          : this.batteriesOut,
      gasCanistersOut: data.gasCanistersOut.present
          ? data.gasCanistersOut.value
          : this.gasCanistersOut,
      totalItemsOut: data.totalItemsOut.present
          ? data.totalItemsOut.value
          : this.totalItemsOut,
      wasteComplianceStatus: data.wasteComplianceStatus.present
          ? data.wasteComplianceStatus.value
          : this.wasteComplianceStatus,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCheckpointRegistration(')
          ..write('id: $id, ')
          ..write('localUuid: $localUuid, ')
          ..write('serverUuid: $serverUuid, ')
          ..write('checkpointName: $checkpointName, ')
          ..write('visitorName: $visitorName, ')
          ..write('documentType: $documentType, ')
          ..write('documentNumber: $documentNumber, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('groupSize: $groupSize, ')
          ..write('routeName: $routeName, ')
          ..write('guideName: $guideName, ')
          ..write('entryDateTime: $entryDateTime, ')
          ..write('entryRangerName: $entryRangerName, ')
          ..write('plasticBottlesIn: $plasticBottlesIn, ')
          ..write('cansIn: $cansIn, ')
          ..write('plasticWrappersIn: $plasticWrappersIn, ')
          ..write('plasticBagsIn: $plasticBagsIn, ')
          ..write('batteriesIn: $batteriesIn, ')
          ..write('gasCanistersIn: $gasCanistersIn, ')
          ..write('otherWasteDetailsIn: $otherWasteDetailsIn, ')
          ..write('totalItemsIn: $totalItemsIn, ')
          ..write('exitDateTime: $exitDateTime, ')
          ..write('exitRangerName: $exitRangerName, ')
          ..write('plasticBottlesOut: $plasticBottlesOut, ')
          ..write('cansOut: $cansOut, ')
          ..write('plasticWrappersOut: $plasticWrappersOut, ')
          ..write('plasticBagsOut: $plasticBagsOut, ')
          ..write('batteriesOut: $batteriesOut, ')
          ..write('gasCanistersOut: $gasCanistersOut, ')
          ..write('totalItemsOut: $totalItemsOut, ')
          ..write('wasteComplianceStatus: $wasteComplianceStatus, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        localUuid,
        serverUuid,
        checkpointName,
        visitorName,
        documentType,
        documentNumber,
        phoneNumber,
        groupSize,
        routeName,
        guideName,
        entryDateTime,
        entryRangerName,
        plasticBottlesIn,
        cansIn,
        plasticWrappersIn,
        plasticBagsIn,
        batteriesIn,
        gasCanistersIn,
        otherWasteDetailsIn,
        totalItemsIn,
        exitDateTime,
        exitRangerName,
        plasticBottlesOut,
        cansOut,
        plasticWrappersOut,
        plasticBagsOut,
        batteriesOut,
        gasCanistersOut,
        totalItemsOut,
        wasteComplianceStatus,
        status,
        notes,
        syncStatus,
        syncError,
        syncedAt,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCheckpointRegistration &&
          other.id == this.id &&
          other.localUuid == this.localUuid &&
          other.serverUuid == this.serverUuid &&
          other.checkpointName == this.checkpointName &&
          other.visitorName == this.visitorName &&
          other.documentType == this.documentType &&
          other.documentNumber == this.documentNumber &&
          other.phoneNumber == this.phoneNumber &&
          other.groupSize == this.groupSize &&
          other.routeName == this.routeName &&
          other.guideName == this.guideName &&
          other.entryDateTime == this.entryDateTime &&
          other.entryRangerName == this.entryRangerName &&
          other.plasticBottlesIn == this.plasticBottlesIn &&
          other.cansIn == this.cansIn &&
          other.plasticWrappersIn == this.plasticWrappersIn &&
          other.plasticBagsIn == this.plasticBagsIn &&
          other.batteriesIn == this.batteriesIn &&
          other.gasCanistersIn == this.gasCanistersIn &&
          other.otherWasteDetailsIn == this.otherWasteDetailsIn &&
          other.totalItemsIn == this.totalItemsIn &&
          other.exitDateTime == this.exitDateTime &&
          other.exitRangerName == this.exitRangerName &&
          other.plasticBottlesOut == this.plasticBottlesOut &&
          other.cansOut == this.cansOut &&
          other.plasticWrappersOut == this.plasticWrappersOut &&
          other.plasticBagsOut == this.plasticBagsOut &&
          other.batteriesOut == this.batteriesOut &&
          other.gasCanistersOut == this.gasCanistersOut &&
          other.totalItemsOut == this.totalItemsOut &&
          other.wasteComplianceStatus == this.wasteComplianceStatus &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError &&
          other.syncedAt == this.syncedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalCheckpointRegistrationsCompanion
    extends UpdateCompanion<LocalCheckpointRegistration> {
  final Value<int> id;
  final Value<String> localUuid;
  final Value<String?> serverUuid;
  final Value<String> checkpointName;
  final Value<String> visitorName;
  final Value<String> documentType;
  final Value<String> documentNumber;
  final Value<String> phoneNumber;
  final Value<int> groupSize;
  final Value<String> routeName;
  final Value<String?> guideName;
  final Value<DateTime> entryDateTime;
  final Value<String?> entryRangerName;
  final Value<int> plasticBottlesIn;
  final Value<int> cansIn;
  final Value<int> plasticWrappersIn;
  final Value<int> plasticBagsIn;
  final Value<int> batteriesIn;
  final Value<int> gasCanistersIn;
  final Value<String?> otherWasteDetailsIn;
  final Value<int> totalItemsIn;
  final Value<DateTime?> exitDateTime;
  final Value<String?> exitRangerName;
  final Value<int> plasticBottlesOut;
  final Value<int> cansOut;
  final Value<int> plasticWrappersOut;
  final Value<int> plasticBagsOut;
  final Value<int> batteriesOut;
  final Value<int> gasCanistersOut;
  final Value<int> totalItemsOut;
  final Value<String> wasteComplianceStatus;
  final Value<String> status;
  final Value<String?> notes;
  final Value<String> syncStatus;
  final Value<String?> syncError;
  final Value<DateTime?> syncedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const LocalCheckpointRegistrationsCompanion({
    this.id = const Value.absent(),
    this.localUuid = const Value.absent(),
    this.serverUuid = const Value.absent(),
    this.checkpointName = const Value.absent(),
    this.visitorName = const Value.absent(),
    this.documentType = const Value.absent(),
    this.documentNumber = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.groupSize = const Value.absent(),
    this.routeName = const Value.absent(),
    this.guideName = const Value.absent(),
    this.entryDateTime = const Value.absent(),
    this.entryRangerName = const Value.absent(),
    this.plasticBottlesIn = const Value.absent(),
    this.cansIn = const Value.absent(),
    this.plasticWrappersIn = const Value.absent(),
    this.plasticBagsIn = const Value.absent(),
    this.batteriesIn = const Value.absent(),
    this.gasCanistersIn = const Value.absent(),
    this.otherWasteDetailsIn = const Value.absent(),
    this.totalItemsIn = const Value.absent(),
    this.exitDateTime = const Value.absent(),
    this.exitRangerName = const Value.absent(),
    this.plasticBottlesOut = const Value.absent(),
    this.cansOut = const Value.absent(),
    this.plasticWrappersOut = const Value.absent(),
    this.plasticBagsOut = const Value.absent(),
    this.batteriesOut = const Value.absent(),
    this.gasCanistersOut = const Value.absent(),
    this.totalItemsOut = const Value.absent(),
    this.wasteComplianceStatus = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LocalCheckpointRegistrationsCompanion.insert({
    this.id = const Value.absent(),
    required String localUuid,
    this.serverUuid = const Value.absent(),
    this.checkpointName = const Value.absent(),
    required String visitorName,
    this.documentType = const Value.absent(),
    required String documentNumber,
    this.phoneNumber = const Value.absent(),
    this.groupSize = const Value.absent(),
    this.routeName = const Value.absent(),
    this.guideName = const Value.absent(),
    required DateTime entryDateTime,
    this.entryRangerName = const Value.absent(),
    this.plasticBottlesIn = const Value.absent(),
    this.cansIn = const Value.absent(),
    this.plasticWrappersIn = const Value.absent(),
    this.plasticBagsIn = const Value.absent(),
    this.batteriesIn = const Value.absent(),
    this.gasCanistersIn = const Value.absent(),
    this.otherWasteDetailsIn = const Value.absent(),
    this.totalItemsIn = const Value.absent(),
    this.exitDateTime = const Value.absent(),
    this.exitRangerName = const Value.absent(),
    this.plasticBottlesOut = const Value.absent(),
    this.cansOut = const Value.absent(),
    this.plasticWrappersOut = const Value.absent(),
    this.plasticBagsOut = const Value.absent(),
    this.batteriesOut = const Value.absent(),
    this.gasCanistersOut = const Value.absent(),
    this.totalItemsOut = const Value.absent(),
    this.wasteComplianceStatus = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : localUuid = Value(localUuid),
        visitorName = Value(visitorName),
        documentNumber = Value(documentNumber),
        entryDateTime = Value(entryDateTime);
  static Insertable<LocalCheckpointRegistration> custom({
    Expression<int>? id,
    Expression<String>? localUuid,
    Expression<String>? serverUuid,
    Expression<String>? checkpointName,
    Expression<String>? visitorName,
    Expression<String>? documentType,
    Expression<String>? documentNumber,
    Expression<String>? phoneNumber,
    Expression<int>? groupSize,
    Expression<String>? routeName,
    Expression<String>? guideName,
    Expression<DateTime>? entryDateTime,
    Expression<String>? entryRangerName,
    Expression<int>? plasticBottlesIn,
    Expression<int>? cansIn,
    Expression<int>? plasticWrappersIn,
    Expression<int>? plasticBagsIn,
    Expression<int>? batteriesIn,
    Expression<int>? gasCanistersIn,
    Expression<String>? otherWasteDetailsIn,
    Expression<int>? totalItemsIn,
    Expression<DateTime>? exitDateTime,
    Expression<String>? exitRangerName,
    Expression<int>? plasticBottlesOut,
    Expression<int>? cansOut,
    Expression<int>? plasticWrappersOut,
    Expression<int>? plasticBagsOut,
    Expression<int>? batteriesOut,
    Expression<int>? gasCanistersOut,
    Expression<int>? totalItemsOut,
    Expression<String>? wasteComplianceStatus,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<String>? syncStatus,
    Expression<String>? syncError,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localUuid != null) 'local_uuid': localUuid,
      if (serverUuid != null) 'server_uuid': serverUuid,
      if (checkpointName != null) 'checkpoint_name': checkpointName,
      if (visitorName != null) 'visitor_name': visitorName,
      if (documentType != null) 'document_type': documentType,
      if (documentNumber != null) 'document_number': documentNumber,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (groupSize != null) 'group_size': groupSize,
      if (routeName != null) 'route_name': routeName,
      if (guideName != null) 'guide_name': guideName,
      if (entryDateTime != null) 'entry_date_time': entryDateTime,
      if (entryRangerName != null) 'entry_ranger_name': entryRangerName,
      if (plasticBottlesIn != null) 'plastic_bottles_in': plasticBottlesIn,
      if (cansIn != null) 'cans_in': cansIn,
      if (plasticWrappersIn != null) 'plastic_wrappers_in': plasticWrappersIn,
      if (plasticBagsIn != null) 'plastic_bags_in': plasticBagsIn,
      if (batteriesIn != null) 'batteries_in': batteriesIn,
      if (gasCanistersIn != null) 'gas_canisters_in': gasCanistersIn,
      if (otherWasteDetailsIn != null)
        'other_waste_details_in': otherWasteDetailsIn,
      if (totalItemsIn != null) 'total_items_in': totalItemsIn,
      if (exitDateTime != null) 'exit_date_time': exitDateTime,
      if (exitRangerName != null) 'exit_ranger_name': exitRangerName,
      if (plasticBottlesOut != null) 'plastic_bottles_out': plasticBottlesOut,
      if (cansOut != null) 'cans_out': cansOut,
      if (plasticWrappersOut != null)
        'plastic_wrappers_out': plasticWrappersOut,
      if (plasticBagsOut != null) 'plastic_bags_out': plasticBagsOut,
      if (batteriesOut != null) 'batteries_out': batteriesOut,
      if (gasCanistersOut != null) 'gas_canisters_out': gasCanistersOut,
      if (totalItemsOut != null) 'total_items_out': totalItemsOut,
      if (wasteComplianceStatus != null)
        'waste_compliance_status': wasteComplianceStatus,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LocalCheckpointRegistrationsCompanion copyWith(
      {Value<int>? id,
      Value<String>? localUuid,
      Value<String?>? serverUuid,
      Value<String>? checkpointName,
      Value<String>? visitorName,
      Value<String>? documentType,
      Value<String>? documentNumber,
      Value<String>? phoneNumber,
      Value<int>? groupSize,
      Value<String>? routeName,
      Value<String?>? guideName,
      Value<DateTime>? entryDateTime,
      Value<String?>? entryRangerName,
      Value<int>? plasticBottlesIn,
      Value<int>? cansIn,
      Value<int>? plasticWrappersIn,
      Value<int>? plasticBagsIn,
      Value<int>? batteriesIn,
      Value<int>? gasCanistersIn,
      Value<String?>? otherWasteDetailsIn,
      Value<int>? totalItemsIn,
      Value<DateTime?>? exitDateTime,
      Value<String?>? exitRangerName,
      Value<int>? plasticBottlesOut,
      Value<int>? cansOut,
      Value<int>? plasticWrappersOut,
      Value<int>? plasticBagsOut,
      Value<int>? batteriesOut,
      Value<int>? gasCanistersOut,
      Value<int>? totalItemsOut,
      Value<String>? wasteComplianceStatus,
      Value<String>? status,
      Value<String?>? notes,
      Value<String>? syncStatus,
      Value<String?>? syncError,
      Value<DateTime?>? syncedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return LocalCheckpointRegistrationsCompanion(
      id: id ?? this.id,
      localUuid: localUuid ?? this.localUuid,
      serverUuid: serverUuid ?? this.serverUuid,
      checkpointName: checkpointName ?? this.checkpointName,
      visitorName: visitorName ?? this.visitorName,
      documentType: documentType ?? this.documentType,
      documentNumber: documentNumber ?? this.documentNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      groupSize: groupSize ?? this.groupSize,
      routeName: routeName ?? this.routeName,
      guideName: guideName ?? this.guideName,
      entryDateTime: entryDateTime ?? this.entryDateTime,
      entryRangerName: entryRangerName ?? this.entryRangerName,
      plasticBottlesIn: plasticBottlesIn ?? this.plasticBottlesIn,
      cansIn: cansIn ?? this.cansIn,
      plasticWrappersIn: plasticWrappersIn ?? this.plasticWrappersIn,
      plasticBagsIn: plasticBagsIn ?? this.plasticBagsIn,
      batteriesIn: batteriesIn ?? this.batteriesIn,
      gasCanistersIn: gasCanistersIn ?? this.gasCanistersIn,
      otherWasteDetailsIn: otherWasteDetailsIn ?? this.otherWasteDetailsIn,
      totalItemsIn: totalItemsIn ?? this.totalItemsIn,
      exitDateTime: exitDateTime ?? this.exitDateTime,
      exitRangerName: exitRangerName ?? this.exitRangerName,
      plasticBottlesOut: plasticBottlesOut ?? this.plasticBottlesOut,
      cansOut: cansOut ?? this.cansOut,
      plasticWrappersOut: plasticWrappersOut ?? this.plasticWrappersOut,
      plasticBagsOut: plasticBagsOut ?? this.plasticBagsOut,
      batteriesOut: batteriesOut ?? this.batteriesOut,
      gasCanistersOut: gasCanistersOut ?? this.gasCanistersOut,
      totalItemsOut: totalItemsOut ?? this.totalItemsOut,
      wasteComplianceStatus:
          wasteComplianceStatus ?? this.wasteComplianceStatus,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      syncedAt: syncedAt ?? this.syncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (localUuid.present) {
      map['local_uuid'] = Variable<String>(localUuid.value);
    }
    if (serverUuid.present) {
      map['server_uuid'] = Variable<String>(serverUuid.value);
    }
    if (checkpointName.present) {
      map['checkpoint_name'] = Variable<String>(checkpointName.value);
    }
    if (visitorName.present) {
      map['visitor_name'] = Variable<String>(visitorName.value);
    }
    if (documentType.present) {
      map['document_type'] = Variable<String>(documentType.value);
    }
    if (documentNumber.present) {
      map['document_number'] = Variable<String>(documentNumber.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (groupSize.present) {
      map['group_size'] = Variable<int>(groupSize.value);
    }
    if (routeName.present) {
      map['route_name'] = Variable<String>(routeName.value);
    }
    if (guideName.present) {
      map['guide_name'] = Variable<String>(guideName.value);
    }
    if (entryDateTime.present) {
      map['entry_date_time'] = Variable<DateTime>(entryDateTime.value);
    }
    if (entryRangerName.present) {
      map['entry_ranger_name'] = Variable<String>(entryRangerName.value);
    }
    if (plasticBottlesIn.present) {
      map['plastic_bottles_in'] = Variable<int>(plasticBottlesIn.value);
    }
    if (cansIn.present) {
      map['cans_in'] = Variable<int>(cansIn.value);
    }
    if (plasticWrappersIn.present) {
      map['plastic_wrappers_in'] = Variable<int>(plasticWrappersIn.value);
    }
    if (plasticBagsIn.present) {
      map['plastic_bags_in'] = Variable<int>(plasticBagsIn.value);
    }
    if (batteriesIn.present) {
      map['batteries_in'] = Variable<int>(batteriesIn.value);
    }
    if (gasCanistersIn.present) {
      map['gas_canisters_in'] = Variable<int>(gasCanistersIn.value);
    }
    if (otherWasteDetailsIn.present) {
      map['other_waste_details_in'] =
          Variable<String>(otherWasteDetailsIn.value);
    }
    if (totalItemsIn.present) {
      map['total_items_in'] = Variable<int>(totalItemsIn.value);
    }
    if (exitDateTime.present) {
      map['exit_date_time'] = Variable<DateTime>(exitDateTime.value);
    }
    if (exitRangerName.present) {
      map['exit_ranger_name'] = Variable<String>(exitRangerName.value);
    }
    if (plasticBottlesOut.present) {
      map['plastic_bottles_out'] = Variable<int>(plasticBottlesOut.value);
    }
    if (cansOut.present) {
      map['cans_out'] = Variable<int>(cansOut.value);
    }
    if (plasticWrappersOut.present) {
      map['plastic_wrappers_out'] = Variable<int>(plasticWrappersOut.value);
    }
    if (plasticBagsOut.present) {
      map['plastic_bags_out'] = Variable<int>(plasticBagsOut.value);
    }
    if (batteriesOut.present) {
      map['batteries_out'] = Variable<int>(batteriesOut.value);
    }
    if (gasCanistersOut.present) {
      map['gas_canisters_out'] = Variable<int>(gasCanistersOut.value);
    }
    if (totalItemsOut.present) {
      map['total_items_out'] = Variable<int>(totalItemsOut.value);
    }
    if (wasteComplianceStatus.present) {
      map['waste_compliance_status'] =
          Variable<String>(wasteComplianceStatus.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCheckpointRegistrationsCompanion(')
          ..write('id: $id, ')
          ..write('localUuid: $localUuid, ')
          ..write('serverUuid: $serverUuid, ')
          ..write('checkpointName: $checkpointName, ')
          ..write('visitorName: $visitorName, ')
          ..write('documentType: $documentType, ')
          ..write('documentNumber: $documentNumber, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('groupSize: $groupSize, ')
          ..write('routeName: $routeName, ')
          ..write('guideName: $guideName, ')
          ..write('entryDateTime: $entryDateTime, ')
          ..write('entryRangerName: $entryRangerName, ')
          ..write('plasticBottlesIn: $plasticBottlesIn, ')
          ..write('cansIn: $cansIn, ')
          ..write('plasticWrappersIn: $plasticWrappersIn, ')
          ..write('plasticBagsIn: $plasticBagsIn, ')
          ..write('batteriesIn: $batteriesIn, ')
          ..write('gasCanistersIn: $gasCanistersIn, ')
          ..write('otherWasteDetailsIn: $otherWasteDetailsIn, ')
          ..write('totalItemsIn: $totalItemsIn, ')
          ..write('exitDateTime: $exitDateTime, ')
          ..write('exitRangerName: $exitRangerName, ')
          ..write('plasticBottlesOut: $plasticBottlesOut, ')
          ..write('cansOut: $cansOut, ')
          ..write('plasticWrappersOut: $plasticWrappersOut, ')
          ..write('plasticBagsOut: $plasticBagsOut, ')
          ..write('batteriesOut: $batteriesOut, ')
          ..write('gasCanistersOut: $gasCanistersOut, ')
          ..write('totalItemsOut: $totalItemsOut, ')
          ..write('wasteComplianceStatus: $wasteComplianceStatus, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalRoutesTable localRoutes = $LocalRoutesTable(this);
  late final $LocalScenesTable localScenes = $LocalScenesTable(this);
  late final $LocalHotspotsTable localHotspots = $LocalHotspotsTable(this);
  late final $PendingReportsTable pendingReports = $PendingReportsTable(this);
  late final $SafetyChecklistsTable safetyChecklists =
      $SafetyChecklistsTable(this);
  late final $LocalCheckpointRegistrationsTable localCheckpointRegistrations =
      $LocalCheckpointRegistrationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        localRoutes,
        localScenes,
        localHotspots,
        pendingReports,
        safetyChecklists,
        localCheckpointRegistrations
      ];
}

typedef $$LocalRoutesTableCreateCompanionBuilder = LocalRoutesCompanion
    Function({
  Value<int> id,
  required String serverUuid,
  required String name,
  required String description,
  required String difficulty,
  required double distanceKm,
  required int estimatedDurationMinutes,
  Value<bool> isDownloaded,
  Value<int> packageVersion,
  Value<DateTime?> downloadedAt,
});
typedef $$LocalRoutesTableUpdateCompanionBuilder = LocalRoutesCompanion
    Function({
  Value<int> id,
  Value<String> serverUuid,
  Value<String> name,
  Value<String> description,
  Value<String> difficulty,
  Value<double> distanceKm,
  Value<int> estimatedDurationMinutes,
  Value<bool> isDownloaded,
  Value<int> packageVersion,
  Value<DateTime?> downloadedAt,
});

class $$LocalRoutesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalRoutesTable> {
  $$LocalRoutesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverUuid => $composableBuilder(
      column: $table.serverUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get distanceKm => $composableBuilder(
      column: $table.distanceKm, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedDurationMinutes => $composableBuilder(
      column: $table.estimatedDurationMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDownloaded => $composableBuilder(
      column: $table.isDownloaded, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get packageVersion => $composableBuilder(
      column: $table.packageVersion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalRoutesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalRoutesTable> {
  $$LocalRoutesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverUuid => $composableBuilder(
      column: $table.serverUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get distanceKm => $composableBuilder(
      column: $table.distanceKm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedDurationMinutes => $composableBuilder(
      column: $table.estimatedDurationMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDownloaded => $composableBuilder(
      column: $table.isDownloaded,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get packageVersion => $composableBuilder(
      column: $table.packageVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$LocalRoutesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalRoutesTable> {
  $$LocalRoutesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverUuid => $composableBuilder(
      column: $table.serverUuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<double> get distanceKm => $composableBuilder(
      column: $table.distanceKm, builder: (column) => column);

  GeneratedColumn<int> get estimatedDurationMinutes => $composableBuilder(
      column: $table.estimatedDurationMinutes, builder: (column) => column);

  GeneratedColumn<bool> get isDownloaded => $composableBuilder(
      column: $table.isDownloaded, builder: (column) => column);

  GeneratedColumn<int> get packageVersion => $composableBuilder(
      column: $table.packageVersion, builder: (column) => column);

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt, builder: (column) => column);
}

class $$LocalRoutesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalRoutesTable,
    LocalRoute,
    $$LocalRoutesTableFilterComposer,
    $$LocalRoutesTableOrderingComposer,
    $$LocalRoutesTableAnnotationComposer,
    $$LocalRoutesTableCreateCompanionBuilder,
    $$LocalRoutesTableUpdateCompanionBuilder,
    (LocalRoute, BaseReferences<_$AppDatabase, $LocalRoutesTable, LocalRoute>),
    LocalRoute,
    PrefetchHooks Function()> {
  $$LocalRoutesTableTableManager(_$AppDatabase db, $LocalRoutesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalRoutesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalRoutesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalRoutesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> serverUuid = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> difficulty = const Value.absent(),
            Value<double> distanceKm = const Value.absent(),
            Value<int> estimatedDurationMinutes = const Value.absent(),
            Value<bool> isDownloaded = const Value.absent(),
            Value<int> packageVersion = const Value.absent(),
            Value<DateTime?> downloadedAt = const Value.absent(),
          }) =>
              LocalRoutesCompanion(
            id: id,
            serverUuid: serverUuid,
            name: name,
            description: description,
            difficulty: difficulty,
            distanceKm: distanceKm,
            estimatedDurationMinutes: estimatedDurationMinutes,
            isDownloaded: isDownloaded,
            packageVersion: packageVersion,
            downloadedAt: downloadedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String serverUuid,
            required String name,
            required String description,
            required String difficulty,
            required double distanceKm,
            required int estimatedDurationMinutes,
            Value<bool> isDownloaded = const Value.absent(),
            Value<int> packageVersion = const Value.absent(),
            Value<DateTime?> downloadedAt = const Value.absent(),
          }) =>
              LocalRoutesCompanion.insert(
            id: id,
            serverUuid: serverUuid,
            name: name,
            description: description,
            difficulty: difficulty,
            distanceKm: distanceKm,
            estimatedDurationMinutes: estimatedDurationMinutes,
            isDownloaded: isDownloaded,
            packageVersion: packageVersion,
            downloadedAt: downloadedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalRoutesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalRoutesTable,
    LocalRoute,
    $$LocalRoutesTableFilterComposer,
    $$LocalRoutesTableOrderingComposer,
    $$LocalRoutesTableAnnotationComposer,
    $$LocalRoutesTableCreateCompanionBuilder,
    $$LocalRoutesTableUpdateCompanionBuilder,
    (LocalRoute, BaseReferences<_$AppDatabase, $LocalRoutesTable, LocalRoute>),
    LocalRoute,
    PrefetchHooks Function()>;
typedef $$LocalScenesTableCreateCompanionBuilder = LocalScenesCompanion
    Function({
  Value<int> id,
  required String serverUuid,
  required String routeServerUuid,
  required String title,
  Value<String> description,
  required String panoramaLocalPath,
  Value<String?> thumbnailLocalPath,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<int> sequence,
});
typedef $$LocalScenesTableUpdateCompanionBuilder = LocalScenesCompanion
    Function({
  Value<int> id,
  Value<String> serverUuid,
  Value<String> routeServerUuid,
  Value<String> title,
  Value<String> description,
  Value<String> panoramaLocalPath,
  Value<String?> thumbnailLocalPath,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<int> sequence,
});

class $$LocalScenesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalScenesTable> {
  $$LocalScenesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverUuid => $composableBuilder(
      column: $table.serverUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get routeServerUuid => $composableBuilder(
      column: $table.routeServerUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get panoramaLocalPath => $composableBuilder(
      column: $table.panoramaLocalPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailLocalPath => $composableBuilder(
      column: $table.thumbnailLocalPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sequence => $composableBuilder(
      column: $table.sequence, builder: (column) => ColumnFilters(column));
}

class $$LocalScenesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalScenesTable> {
  $$LocalScenesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverUuid => $composableBuilder(
      column: $table.serverUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get routeServerUuid => $composableBuilder(
      column: $table.routeServerUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get panoramaLocalPath => $composableBuilder(
      column: $table.panoramaLocalPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailLocalPath => $composableBuilder(
      column: $table.thumbnailLocalPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sequence => $composableBuilder(
      column: $table.sequence, builder: (column) => ColumnOrderings(column));
}

class $$LocalScenesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalScenesTable> {
  $$LocalScenesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverUuid => $composableBuilder(
      column: $table.serverUuid, builder: (column) => column);

  GeneratedColumn<String> get routeServerUuid => $composableBuilder(
      column: $table.routeServerUuid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get panoramaLocalPath => $composableBuilder(
      column: $table.panoramaLocalPath, builder: (column) => column);

  GeneratedColumn<String> get thumbnailLocalPath => $composableBuilder(
      column: $table.thumbnailLocalPath, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);
}

class $$LocalScenesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalScenesTable,
    LocalScene,
    $$LocalScenesTableFilterComposer,
    $$LocalScenesTableOrderingComposer,
    $$LocalScenesTableAnnotationComposer,
    $$LocalScenesTableCreateCompanionBuilder,
    $$LocalScenesTableUpdateCompanionBuilder,
    (LocalScene, BaseReferences<_$AppDatabase, $LocalScenesTable, LocalScene>),
    LocalScene,
    PrefetchHooks Function()> {
  $$LocalScenesTableTableManager(_$AppDatabase db, $LocalScenesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalScenesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalScenesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalScenesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> serverUuid = const Value.absent(),
            Value<String> routeServerUuid = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> panoramaLocalPath = const Value.absent(),
            Value<String?> thumbnailLocalPath = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<int> sequence = const Value.absent(),
          }) =>
              LocalScenesCompanion(
            id: id,
            serverUuid: serverUuid,
            routeServerUuid: routeServerUuid,
            title: title,
            description: description,
            panoramaLocalPath: panoramaLocalPath,
            thumbnailLocalPath: thumbnailLocalPath,
            latitude: latitude,
            longitude: longitude,
            sequence: sequence,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String serverUuid,
            required String routeServerUuid,
            required String title,
            Value<String> description = const Value.absent(),
            required String panoramaLocalPath,
            Value<String?> thumbnailLocalPath = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<int> sequence = const Value.absent(),
          }) =>
              LocalScenesCompanion.insert(
            id: id,
            serverUuid: serverUuid,
            routeServerUuid: routeServerUuid,
            title: title,
            description: description,
            panoramaLocalPath: panoramaLocalPath,
            thumbnailLocalPath: thumbnailLocalPath,
            latitude: latitude,
            longitude: longitude,
            sequence: sequence,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalScenesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalScenesTable,
    LocalScene,
    $$LocalScenesTableFilterComposer,
    $$LocalScenesTableOrderingComposer,
    $$LocalScenesTableAnnotationComposer,
    $$LocalScenesTableCreateCompanionBuilder,
    $$LocalScenesTableUpdateCompanionBuilder,
    (LocalScene, BaseReferences<_$AppDatabase, $LocalScenesTable, LocalScene>),
    LocalScene,
    PrefetchHooks Function()>;
typedef $$LocalHotspotsTableCreateCompanionBuilder = LocalHotspotsCompanion
    Function({
  Value<int> id,
  required String serverUuid,
  required String sourceSceneUuid,
  Value<String?> targetSceneUuid,
  Value<String> type,
  Value<double> yaw,
  Value<double> pitch,
  required String title,
  Value<String> content,
});
typedef $$LocalHotspotsTableUpdateCompanionBuilder = LocalHotspotsCompanion
    Function({
  Value<int> id,
  Value<String> serverUuid,
  Value<String> sourceSceneUuid,
  Value<String?> targetSceneUuid,
  Value<String> type,
  Value<double> yaw,
  Value<double> pitch,
  Value<String> title,
  Value<String> content,
});

class $$LocalHotspotsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalHotspotsTable> {
  $$LocalHotspotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverUuid => $composableBuilder(
      column: $table.serverUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceSceneUuid => $composableBuilder(
      column: $table.sourceSceneUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetSceneUuid => $composableBuilder(
      column: $table.targetSceneUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get yaw => $composableBuilder(
      column: $table.yaw, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pitch => $composableBuilder(
      column: $table.pitch, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));
}

class $$LocalHotspotsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalHotspotsTable> {
  $$LocalHotspotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverUuid => $composableBuilder(
      column: $table.serverUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceSceneUuid => $composableBuilder(
      column: $table.sourceSceneUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetSceneUuid => $composableBuilder(
      column: $table.targetSceneUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get yaw => $composableBuilder(
      column: $table.yaw, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pitch => $composableBuilder(
      column: $table.pitch, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));
}

class $$LocalHotspotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalHotspotsTable> {
  $$LocalHotspotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverUuid => $composableBuilder(
      column: $table.serverUuid, builder: (column) => column);

  GeneratedColumn<String> get sourceSceneUuid => $composableBuilder(
      column: $table.sourceSceneUuid, builder: (column) => column);

  GeneratedColumn<String> get targetSceneUuid => $composableBuilder(
      column: $table.targetSceneUuid, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get yaw =>
      $composableBuilder(column: $table.yaw, builder: (column) => column);

  GeneratedColumn<double> get pitch =>
      $composableBuilder(column: $table.pitch, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);
}

class $$LocalHotspotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalHotspotsTable,
    LocalHotspot,
    $$LocalHotspotsTableFilterComposer,
    $$LocalHotspotsTableOrderingComposer,
    $$LocalHotspotsTableAnnotationComposer,
    $$LocalHotspotsTableCreateCompanionBuilder,
    $$LocalHotspotsTableUpdateCompanionBuilder,
    (
      LocalHotspot,
      BaseReferences<_$AppDatabase, $LocalHotspotsTable, LocalHotspot>
    ),
    LocalHotspot,
    PrefetchHooks Function()> {
  $$LocalHotspotsTableTableManager(_$AppDatabase db, $LocalHotspotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalHotspotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalHotspotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalHotspotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> serverUuid = const Value.absent(),
            Value<String> sourceSceneUuid = const Value.absent(),
            Value<String?> targetSceneUuid = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<double> yaw = const Value.absent(),
            Value<double> pitch = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> content = const Value.absent(),
          }) =>
              LocalHotspotsCompanion(
            id: id,
            serverUuid: serverUuid,
            sourceSceneUuid: sourceSceneUuid,
            targetSceneUuid: targetSceneUuid,
            type: type,
            yaw: yaw,
            pitch: pitch,
            title: title,
            content: content,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String serverUuid,
            required String sourceSceneUuid,
            Value<String?> targetSceneUuid = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<double> yaw = const Value.absent(),
            Value<double> pitch = const Value.absent(),
            required String title,
            Value<String> content = const Value.absent(),
          }) =>
              LocalHotspotsCompanion.insert(
            id: id,
            serverUuid: serverUuid,
            sourceSceneUuid: sourceSceneUuid,
            targetSceneUuid: targetSceneUuid,
            type: type,
            yaw: yaw,
            pitch: pitch,
            title: title,
            content: content,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalHotspotsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalHotspotsTable,
    LocalHotspot,
    $$LocalHotspotsTableFilterComposer,
    $$LocalHotspotsTableOrderingComposer,
    $$LocalHotspotsTableAnnotationComposer,
    $$LocalHotspotsTableCreateCompanionBuilder,
    $$LocalHotspotsTableUpdateCompanionBuilder,
    (
      LocalHotspot,
      BaseReferences<_$AppDatabase, $LocalHotspotsTable, LocalHotspot>
    ),
    LocalHotspot,
    PrefetchHooks Function()>;
typedef $$PendingReportsTableCreateCompanionBuilder = PendingReportsCompanion
    Function({
  Value<int> id,
  required String localUuid,
  Value<String?> serverUuid,
  Value<int?> userId,
  Value<String?> routeUuid,
  required String category,
  required String description,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<double?> accuracyMeters,
  required DateTime capturedAt,
  Value<String?> localImagePath,
  Value<String> syncStatus,
  Value<String?> syncError,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
});
typedef $$PendingReportsTableUpdateCompanionBuilder = PendingReportsCompanion
    Function({
  Value<int> id,
  Value<String> localUuid,
  Value<String?> serverUuid,
  Value<int?> userId,
  Value<String?> routeUuid,
  Value<String> category,
  Value<String> description,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<double?> accuracyMeters,
  Value<DateTime> capturedAt,
  Value<String?> localImagePath,
  Value<String> syncStatus,
  Value<String?> syncError,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
});

class $$PendingReportsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingReportsTable> {
  $$PendingReportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localUuid => $composableBuilder(
      column: $table.localUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverUuid => $composableBuilder(
      column: $table.serverUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get routeUuid => $composableBuilder(
      column: $table.routeUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get accuracyMeters => $composableBuilder(
      column: $table.accuracyMeters,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncError => $composableBuilder(
      column: $table.syncError, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PendingReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingReportsTable> {
  $$PendingReportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localUuid => $composableBuilder(
      column: $table.localUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverUuid => $composableBuilder(
      column: $table.serverUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get routeUuid => $composableBuilder(
      column: $table.routeUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get accuracyMeters => $composableBuilder(
      column: $table.accuracyMeters,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncError => $composableBuilder(
      column: $table.syncError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PendingReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingReportsTable> {
  $$PendingReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localUuid =>
      $composableBuilder(column: $table.localUuid, builder: (column) => column);

  GeneratedColumn<String> get serverUuid => $composableBuilder(
      column: $table.serverUuid, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get routeUuid =>
      $composableBuilder(column: $table.routeUuid, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get accuracyMeters => $composableBuilder(
      column: $table.accuracyMeters, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => column);

  GeneratedColumn<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PendingReportsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PendingReportsTable,
    PendingReport,
    $$PendingReportsTableFilterComposer,
    $$PendingReportsTableOrderingComposer,
    $$PendingReportsTableAnnotationComposer,
    $$PendingReportsTableCreateCompanionBuilder,
    $$PendingReportsTableUpdateCompanionBuilder,
    (
      PendingReport,
      BaseReferences<_$AppDatabase, $PendingReportsTable, PendingReport>
    ),
    PendingReport,
    PrefetchHooks Function()> {
  $$PendingReportsTableTableManager(
      _$AppDatabase db, $PendingReportsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingReportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> localUuid = const Value.absent(),
            Value<String?> serverUuid = const Value.absent(),
            Value<int?> userId = const Value.absent(),
            Value<String?> routeUuid = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<double?> accuracyMeters = const Value.absent(),
            Value<DateTime> capturedAt = const Value.absent(),
            Value<String?> localImagePath = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> syncError = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PendingReportsCompanion(
            id: id,
            localUuid: localUuid,
            serverUuid: serverUuid,
            userId: userId,
            routeUuid: routeUuid,
            category: category,
            description: description,
            latitude: latitude,
            longitude: longitude,
            accuracyMeters: accuracyMeters,
            capturedAt: capturedAt,
            localImagePath: localImagePath,
            syncStatus: syncStatus,
            syncError: syncError,
            syncedAt: syncedAt,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String localUuid,
            Value<String?> serverUuid = const Value.absent(),
            Value<int?> userId = const Value.absent(),
            Value<String?> routeUuid = const Value.absent(),
            required String category,
            required String description,
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<double?> accuracyMeters = const Value.absent(),
            required DateTime capturedAt,
            Value<String?> localImagePath = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> syncError = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PendingReportsCompanion.insert(
            id: id,
            localUuid: localUuid,
            serverUuid: serverUuid,
            userId: userId,
            routeUuid: routeUuid,
            category: category,
            description: description,
            latitude: latitude,
            longitude: longitude,
            accuracyMeters: accuracyMeters,
            capturedAt: capturedAt,
            localImagePath: localImagePath,
            syncStatus: syncStatus,
            syncError: syncError,
            syncedAt: syncedAt,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PendingReportsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PendingReportsTable,
    PendingReport,
    $$PendingReportsTableFilterComposer,
    $$PendingReportsTableOrderingComposer,
    $$PendingReportsTableAnnotationComposer,
    $$PendingReportsTableCreateCompanionBuilder,
    $$PendingReportsTableUpdateCompanionBuilder,
    (
      PendingReport,
      BaseReferences<_$AppDatabase, $PendingReportsTable, PendingReport>
    ),
    PendingReport,
    PrefetchHooks Function()>;
typedef $$SafetyChecklistsTableCreateCompanionBuilder
    = SafetyChecklistsCompanion Function({
  Value<int> id,
  required String recommendationKey,
  Value<bool> isChecked,
  Value<DateTime> updatedAt,
});
typedef $$SafetyChecklistsTableUpdateCompanionBuilder
    = SafetyChecklistsCompanion Function({
  Value<int> id,
  Value<String> recommendationKey,
  Value<bool> isChecked,
  Value<DateTime> updatedAt,
});

class $$SafetyChecklistsTableFilterComposer
    extends Composer<_$AppDatabase, $SafetyChecklistsTable> {
  $$SafetyChecklistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recommendationKey => $composableBuilder(
      column: $table.recommendationKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isChecked => $composableBuilder(
      column: $table.isChecked, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SafetyChecklistsTableOrderingComposer
    extends Composer<_$AppDatabase, $SafetyChecklistsTable> {
  $$SafetyChecklistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recommendationKey => $composableBuilder(
      column: $table.recommendationKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isChecked => $composableBuilder(
      column: $table.isChecked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SafetyChecklistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SafetyChecklistsTable> {
  $$SafetyChecklistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recommendationKey => $composableBuilder(
      column: $table.recommendationKey, builder: (column) => column);

  GeneratedColumn<bool> get isChecked =>
      $composableBuilder(column: $table.isChecked, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SafetyChecklistsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SafetyChecklistsTable,
    SafetyChecklist,
    $$SafetyChecklistsTableFilterComposer,
    $$SafetyChecklistsTableOrderingComposer,
    $$SafetyChecklistsTableAnnotationComposer,
    $$SafetyChecklistsTableCreateCompanionBuilder,
    $$SafetyChecklistsTableUpdateCompanionBuilder,
    (
      SafetyChecklist,
      BaseReferences<_$AppDatabase, $SafetyChecklistsTable, SafetyChecklist>
    ),
    SafetyChecklist,
    PrefetchHooks Function()> {
  $$SafetyChecklistsTableTableManager(
      _$AppDatabase db, $SafetyChecklistsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SafetyChecklistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SafetyChecklistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SafetyChecklistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> recommendationKey = const Value.absent(),
            Value<bool> isChecked = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SafetyChecklistsCompanion(
            id: id,
            recommendationKey: recommendationKey,
            isChecked: isChecked,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String recommendationKey,
            Value<bool> isChecked = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SafetyChecklistsCompanion.insert(
            id: id,
            recommendationKey: recommendationKey,
            isChecked: isChecked,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SafetyChecklistsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SafetyChecklistsTable,
    SafetyChecklist,
    $$SafetyChecklistsTableFilterComposer,
    $$SafetyChecklistsTableOrderingComposer,
    $$SafetyChecklistsTableAnnotationComposer,
    $$SafetyChecklistsTableCreateCompanionBuilder,
    $$SafetyChecklistsTableUpdateCompanionBuilder,
    (
      SafetyChecklist,
      BaseReferences<_$AppDatabase, $SafetyChecklistsTable, SafetyChecklist>
    ),
    SafetyChecklist,
    PrefetchHooks Function()>;
typedef $$LocalCheckpointRegistrationsTableCreateCompanionBuilder
    = LocalCheckpointRegistrationsCompanion Function({
  Value<int> id,
  required String localUuid,
  Value<String?> serverUuid,
  Value<String> checkpointName,
  required String visitorName,
  Value<String> documentType,
  required String documentNumber,
  Value<String> phoneNumber,
  Value<int> groupSize,
  Value<String> routeName,
  Value<String?> guideName,
  required DateTime entryDateTime,
  Value<String?> entryRangerName,
  Value<int> plasticBottlesIn,
  Value<int> cansIn,
  Value<int> plasticWrappersIn,
  Value<int> plasticBagsIn,
  Value<int> batteriesIn,
  Value<int> gasCanistersIn,
  Value<String?> otherWasteDetailsIn,
  Value<int> totalItemsIn,
  Value<DateTime?> exitDateTime,
  Value<String?> exitRangerName,
  Value<int> plasticBottlesOut,
  Value<int> cansOut,
  Value<int> plasticWrappersOut,
  Value<int> plasticBagsOut,
  Value<int> batteriesOut,
  Value<int> gasCanistersOut,
  Value<int> totalItemsOut,
  Value<String> wasteComplianceStatus,
  Value<String> status,
  Value<String?> notes,
  Value<String> syncStatus,
  Value<String?> syncError,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$LocalCheckpointRegistrationsTableUpdateCompanionBuilder
    = LocalCheckpointRegistrationsCompanion Function({
  Value<int> id,
  Value<String> localUuid,
  Value<String?> serverUuid,
  Value<String> checkpointName,
  Value<String> visitorName,
  Value<String> documentType,
  Value<String> documentNumber,
  Value<String> phoneNumber,
  Value<int> groupSize,
  Value<String> routeName,
  Value<String?> guideName,
  Value<DateTime> entryDateTime,
  Value<String?> entryRangerName,
  Value<int> plasticBottlesIn,
  Value<int> cansIn,
  Value<int> plasticWrappersIn,
  Value<int> plasticBagsIn,
  Value<int> batteriesIn,
  Value<int> gasCanistersIn,
  Value<String?> otherWasteDetailsIn,
  Value<int> totalItemsIn,
  Value<DateTime?> exitDateTime,
  Value<String?> exitRangerName,
  Value<int> plasticBottlesOut,
  Value<int> cansOut,
  Value<int> plasticWrappersOut,
  Value<int> plasticBagsOut,
  Value<int> batteriesOut,
  Value<int> gasCanistersOut,
  Value<int> totalItemsOut,
  Value<String> wasteComplianceStatus,
  Value<String> status,
  Value<String?> notes,
  Value<String> syncStatus,
  Value<String?> syncError,
  Value<DateTime?> syncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$LocalCheckpointRegistrationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCheckpointRegistrationsTable> {
  $$LocalCheckpointRegistrationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localUuid => $composableBuilder(
      column: $table.localUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverUuid => $composableBuilder(
      column: $table.serverUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checkpointName => $composableBuilder(
      column: $table.checkpointName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get visitorName => $composableBuilder(
      column: $table.visitorName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get documentType => $composableBuilder(
      column: $table.documentType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get documentNumber => $composableBuilder(
      column: $table.documentNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get groupSize => $composableBuilder(
      column: $table.groupSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get routeName => $composableBuilder(
      column: $table.routeName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get guideName => $composableBuilder(
      column: $table.guideName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get entryDateTime => $composableBuilder(
      column: $table.entryDateTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryRangerName => $composableBuilder(
      column: $table.entryRangerName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get plasticBottlesIn => $composableBuilder(
      column: $table.plasticBottlesIn,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cansIn => $composableBuilder(
      column: $table.cansIn, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get plasticWrappersIn => $composableBuilder(
      column: $table.plasticWrappersIn,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get plasticBagsIn => $composableBuilder(
      column: $table.plasticBagsIn, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get batteriesIn => $composableBuilder(
      column: $table.batteriesIn, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gasCanistersIn => $composableBuilder(
      column: $table.gasCanistersIn,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get otherWasteDetailsIn => $composableBuilder(
      column: $table.otherWasteDetailsIn,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalItemsIn => $composableBuilder(
      column: $table.totalItemsIn, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get exitDateTime => $composableBuilder(
      column: $table.exitDateTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exitRangerName => $composableBuilder(
      column: $table.exitRangerName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get plasticBottlesOut => $composableBuilder(
      column: $table.plasticBottlesOut,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cansOut => $composableBuilder(
      column: $table.cansOut, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get plasticWrappersOut => $composableBuilder(
      column: $table.plasticWrappersOut,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get plasticBagsOut => $composableBuilder(
      column: $table.plasticBagsOut,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get batteriesOut => $composableBuilder(
      column: $table.batteriesOut, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gasCanistersOut => $composableBuilder(
      column: $table.gasCanistersOut,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalItemsOut => $composableBuilder(
      column: $table.totalItemsOut, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wasteComplianceStatus => $composableBuilder(
      column: $table.wasteComplianceStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncError => $composableBuilder(
      column: $table.syncError, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalCheckpointRegistrationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCheckpointRegistrationsTable> {
  $$LocalCheckpointRegistrationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localUuid => $composableBuilder(
      column: $table.localUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverUuid => $composableBuilder(
      column: $table.serverUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checkpointName => $composableBuilder(
      column: $table.checkpointName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get visitorName => $composableBuilder(
      column: $table.visitorName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get documentType => $composableBuilder(
      column: $table.documentType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get documentNumber => $composableBuilder(
      column: $table.documentNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get groupSize => $composableBuilder(
      column: $table.groupSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get routeName => $composableBuilder(
      column: $table.routeName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get guideName => $composableBuilder(
      column: $table.guideName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get entryDateTime => $composableBuilder(
      column: $table.entryDateTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryRangerName => $composableBuilder(
      column: $table.entryRangerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get plasticBottlesIn => $composableBuilder(
      column: $table.plasticBottlesIn,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cansIn => $composableBuilder(
      column: $table.cansIn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get plasticWrappersIn => $composableBuilder(
      column: $table.plasticWrappersIn,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get plasticBagsIn => $composableBuilder(
      column: $table.plasticBagsIn,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get batteriesIn => $composableBuilder(
      column: $table.batteriesIn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gasCanistersIn => $composableBuilder(
      column: $table.gasCanistersIn,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get otherWasteDetailsIn => $composableBuilder(
      column: $table.otherWasteDetailsIn,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalItemsIn => $composableBuilder(
      column: $table.totalItemsIn,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get exitDateTime => $composableBuilder(
      column: $table.exitDateTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exitRangerName => $composableBuilder(
      column: $table.exitRangerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get plasticBottlesOut => $composableBuilder(
      column: $table.plasticBottlesOut,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cansOut => $composableBuilder(
      column: $table.cansOut, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get plasticWrappersOut => $composableBuilder(
      column: $table.plasticWrappersOut,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get plasticBagsOut => $composableBuilder(
      column: $table.plasticBagsOut,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get batteriesOut => $composableBuilder(
      column: $table.batteriesOut,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gasCanistersOut => $composableBuilder(
      column: $table.gasCanistersOut,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalItemsOut => $composableBuilder(
      column: $table.totalItemsOut,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wasteComplianceStatus => $composableBuilder(
      column: $table.wasteComplianceStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncError => $composableBuilder(
      column: $table.syncError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalCheckpointRegistrationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCheckpointRegistrationsTable> {
  $$LocalCheckpointRegistrationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localUuid =>
      $composableBuilder(column: $table.localUuid, builder: (column) => column);

  GeneratedColumn<String> get serverUuid => $composableBuilder(
      column: $table.serverUuid, builder: (column) => column);

  GeneratedColumn<String> get checkpointName => $composableBuilder(
      column: $table.checkpointName, builder: (column) => column);

  GeneratedColumn<String> get visitorName => $composableBuilder(
      column: $table.visitorName, builder: (column) => column);

  GeneratedColumn<String> get documentType => $composableBuilder(
      column: $table.documentType, builder: (column) => column);

  GeneratedColumn<String> get documentNumber => $composableBuilder(
      column: $table.documentNumber, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => column);

  GeneratedColumn<int> get groupSize =>
      $composableBuilder(column: $table.groupSize, builder: (column) => column);

  GeneratedColumn<String> get routeName =>
      $composableBuilder(column: $table.routeName, builder: (column) => column);

  GeneratedColumn<String> get guideName =>
      $composableBuilder(column: $table.guideName, builder: (column) => column);

  GeneratedColumn<DateTime> get entryDateTime => $composableBuilder(
      column: $table.entryDateTime, builder: (column) => column);

  GeneratedColumn<String> get entryRangerName => $composableBuilder(
      column: $table.entryRangerName, builder: (column) => column);

  GeneratedColumn<int> get plasticBottlesIn => $composableBuilder(
      column: $table.plasticBottlesIn, builder: (column) => column);

  GeneratedColumn<int> get cansIn =>
      $composableBuilder(column: $table.cansIn, builder: (column) => column);

  GeneratedColumn<int> get plasticWrappersIn => $composableBuilder(
      column: $table.plasticWrappersIn, builder: (column) => column);

  GeneratedColumn<int> get plasticBagsIn => $composableBuilder(
      column: $table.plasticBagsIn, builder: (column) => column);

  GeneratedColumn<int> get batteriesIn => $composableBuilder(
      column: $table.batteriesIn, builder: (column) => column);

  GeneratedColumn<int> get gasCanistersIn => $composableBuilder(
      column: $table.gasCanistersIn, builder: (column) => column);

  GeneratedColumn<String> get otherWasteDetailsIn => $composableBuilder(
      column: $table.otherWasteDetailsIn, builder: (column) => column);

  GeneratedColumn<int> get totalItemsIn => $composableBuilder(
      column: $table.totalItemsIn, builder: (column) => column);

  GeneratedColumn<DateTime> get exitDateTime => $composableBuilder(
      column: $table.exitDateTime, builder: (column) => column);

  GeneratedColumn<String> get exitRangerName => $composableBuilder(
      column: $table.exitRangerName, builder: (column) => column);

  GeneratedColumn<int> get plasticBottlesOut => $composableBuilder(
      column: $table.plasticBottlesOut, builder: (column) => column);

  GeneratedColumn<int> get cansOut =>
      $composableBuilder(column: $table.cansOut, builder: (column) => column);

  GeneratedColumn<int> get plasticWrappersOut => $composableBuilder(
      column: $table.plasticWrappersOut, builder: (column) => column);

  GeneratedColumn<int> get plasticBagsOut => $composableBuilder(
      column: $table.plasticBagsOut, builder: (column) => column);

  GeneratedColumn<int> get batteriesOut => $composableBuilder(
      column: $table.batteriesOut, builder: (column) => column);

  GeneratedColumn<int> get gasCanistersOut => $composableBuilder(
      column: $table.gasCanistersOut, builder: (column) => column);

  GeneratedColumn<int> get totalItemsOut => $composableBuilder(
      column: $table.totalItemsOut, builder: (column) => column);

  GeneratedColumn<String> get wasteComplianceStatus => $composableBuilder(
      column: $table.wasteComplianceStatus, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalCheckpointRegistrationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalCheckpointRegistrationsTable,
    LocalCheckpointRegistration,
    $$LocalCheckpointRegistrationsTableFilterComposer,
    $$LocalCheckpointRegistrationsTableOrderingComposer,
    $$LocalCheckpointRegistrationsTableAnnotationComposer,
    $$LocalCheckpointRegistrationsTableCreateCompanionBuilder,
    $$LocalCheckpointRegistrationsTableUpdateCompanionBuilder,
    (
      LocalCheckpointRegistration,
      BaseReferences<_$AppDatabase, $LocalCheckpointRegistrationsTable,
          LocalCheckpointRegistration>
    ),
    LocalCheckpointRegistration,
    PrefetchHooks Function()> {
  $$LocalCheckpointRegistrationsTableTableManager(
      _$AppDatabase db, $LocalCheckpointRegistrationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCheckpointRegistrationsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCheckpointRegistrationsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCheckpointRegistrationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> localUuid = const Value.absent(),
            Value<String?> serverUuid = const Value.absent(),
            Value<String> checkpointName = const Value.absent(),
            Value<String> visitorName = const Value.absent(),
            Value<String> documentType = const Value.absent(),
            Value<String> documentNumber = const Value.absent(),
            Value<String> phoneNumber = const Value.absent(),
            Value<int> groupSize = const Value.absent(),
            Value<String> routeName = const Value.absent(),
            Value<String?> guideName = const Value.absent(),
            Value<DateTime> entryDateTime = const Value.absent(),
            Value<String?> entryRangerName = const Value.absent(),
            Value<int> plasticBottlesIn = const Value.absent(),
            Value<int> cansIn = const Value.absent(),
            Value<int> plasticWrappersIn = const Value.absent(),
            Value<int> plasticBagsIn = const Value.absent(),
            Value<int> batteriesIn = const Value.absent(),
            Value<int> gasCanistersIn = const Value.absent(),
            Value<String?> otherWasteDetailsIn = const Value.absent(),
            Value<int> totalItemsIn = const Value.absent(),
            Value<DateTime?> exitDateTime = const Value.absent(),
            Value<String?> exitRangerName = const Value.absent(),
            Value<int> plasticBottlesOut = const Value.absent(),
            Value<int> cansOut = const Value.absent(),
            Value<int> plasticWrappersOut = const Value.absent(),
            Value<int> plasticBagsOut = const Value.absent(),
            Value<int> batteriesOut = const Value.absent(),
            Value<int> gasCanistersOut = const Value.absent(),
            Value<int> totalItemsOut = const Value.absent(),
            Value<String> wasteComplianceStatus = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> syncError = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              LocalCheckpointRegistrationsCompanion(
            id: id,
            localUuid: localUuid,
            serverUuid: serverUuid,
            checkpointName: checkpointName,
            visitorName: visitorName,
            documentType: documentType,
            documentNumber: documentNumber,
            phoneNumber: phoneNumber,
            groupSize: groupSize,
            routeName: routeName,
            guideName: guideName,
            entryDateTime: entryDateTime,
            entryRangerName: entryRangerName,
            plasticBottlesIn: plasticBottlesIn,
            cansIn: cansIn,
            plasticWrappersIn: plasticWrappersIn,
            plasticBagsIn: plasticBagsIn,
            batteriesIn: batteriesIn,
            gasCanistersIn: gasCanistersIn,
            otherWasteDetailsIn: otherWasteDetailsIn,
            totalItemsIn: totalItemsIn,
            exitDateTime: exitDateTime,
            exitRangerName: exitRangerName,
            plasticBottlesOut: plasticBottlesOut,
            cansOut: cansOut,
            plasticWrappersOut: plasticWrappersOut,
            plasticBagsOut: plasticBagsOut,
            batteriesOut: batteriesOut,
            gasCanistersOut: gasCanistersOut,
            totalItemsOut: totalItemsOut,
            wasteComplianceStatus: wasteComplianceStatus,
            status: status,
            notes: notes,
            syncStatus: syncStatus,
            syncError: syncError,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String localUuid,
            Value<String?> serverUuid = const Value.absent(),
            Value<String> checkpointName = const Value.absent(),
            required String visitorName,
            Value<String> documentType = const Value.absent(),
            required String documentNumber,
            Value<String> phoneNumber = const Value.absent(),
            Value<int> groupSize = const Value.absent(),
            Value<String> routeName = const Value.absent(),
            Value<String?> guideName = const Value.absent(),
            required DateTime entryDateTime,
            Value<String?> entryRangerName = const Value.absent(),
            Value<int> plasticBottlesIn = const Value.absent(),
            Value<int> cansIn = const Value.absent(),
            Value<int> plasticWrappersIn = const Value.absent(),
            Value<int> plasticBagsIn = const Value.absent(),
            Value<int> batteriesIn = const Value.absent(),
            Value<int> gasCanistersIn = const Value.absent(),
            Value<String?> otherWasteDetailsIn = const Value.absent(),
            Value<int> totalItemsIn = const Value.absent(),
            Value<DateTime?> exitDateTime = const Value.absent(),
            Value<String?> exitRangerName = const Value.absent(),
            Value<int> plasticBottlesOut = const Value.absent(),
            Value<int> cansOut = const Value.absent(),
            Value<int> plasticWrappersOut = const Value.absent(),
            Value<int> plasticBagsOut = const Value.absent(),
            Value<int> batteriesOut = const Value.absent(),
            Value<int> gasCanistersOut = const Value.absent(),
            Value<int> totalItemsOut = const Value.absent(),
            Value<String> wasteComplianceStatus = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> syncError = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              LocalCheckpointRegistrationsCompanion.insert(
            id: id,
            localUuid: localUuid,
            serverUuid: serverUuid,
            checkpointName: checkpointName,
            visitorName: visitorName,
            documentType: documentType,
            documentNumber: documentNumber,
            phoneNumber: phoneNumber,
            groupSize: groupSize,
            routeName: routeName,
            guideName: guideName,
            entryDateTime: entryDateTime,
            entryRangerName: entryRangerName,
            plasticBottlesIn: plasticBottlesIn,
            cansIn: cansIn,
            plasticWrappersIn: plasticWrappersIn,
            plasticBagsIn: plasticBagsIn,
            batteriesIn: batteriesIn,
            gasCanistersIn: gasCanistersIn,
            otherWasteDetailsIn: otherWasteDetailsIn,
            totalItemsIn: totalItemsIn,
            exitDateTime: exitDateTime,
            exitRangerName: exitRangerName,
            plasticBottlesOut: plasticBottlesOut,
            cansOut: cansOut,
            plasticWrappersOut: plasticWrappersOut,
            plasticBagsOut: plasticBagsOut,
            batteriesOut: batteriesOut,
            gasCanistersOut: gasCanistersOut,
            totalItemsOut: totalItemsOut,
            wasteComplianceStatus: wasteComplianceStatus,
            status: status,
            notes: notes,
            syncStatus: syncStatus,
            syncError: syncError,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalCheckpointRegistrationsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LocalCheckpointRegistrationsTable,
        LocalCheckpointRegistration,
        $$LocalCheckpointRegistrationsTableFilterComposer,
        $$LocalCheckpointRegistrationsTableOrderingComposer,
        $$LocalCheckpointRegistrationsTableAnnotationComposer,
        $$LocalCheckpointRegistrationsTableCreateCompanionBuilder,
        $$LocalCheckpointRegistrationsTableUpdateCompanionBuilder,
        (
          LocalCheckpointRegistration,
          BaseReferences<_$AppDatabase, $LocalCheckpointRegistrationsTable,
              LocalCheckpointRegistration>
        ),
        LocalCheckpointRegistration,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalRoutesTableTableManager get localRoutes =>
      $$LocalRoutesTableTableManager(_db, _db.localRoutes);
  $$LocalScenesTableTableManager get localScenes =>
      $$LocalScenesTableTableManager(_db, _db.localScenes);
  $$LocalHotspotsTableTableManager get localHotspots =>
      $$LocalHotspotsTableTableManager(_db, _db.localHotspots);
  $$PendingReportsTableTableManager get pendingReports =>
      $$PendingReportsTableTableManager(_db, _db.pendingReports);
  $$SafetyChecklistsTableTableManager get safetyChecklists =>
      $$SafetyChecklistsTableTableManager(_db, _db.safetyChecklists);
  $$LocalCheckpointRegistrationsTableTableManager
      get localCheckpointRegistrations =>
          $$LocalCheckpointRegistrationsTableTableManager(
              _db, _db.localCheckpointRegistrations);
}
