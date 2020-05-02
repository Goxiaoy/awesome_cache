// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorCacheDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$CacheDatabaseBuilder databaseBuilder(String name) =>
      _$CacheDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$CacheDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$CacheDatabaseBuilder(null);
}

class _$CacheDatabaseBuilder {
  _$CacheDatabaseBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

  /// Adds migrations to the builder.
  _$CacheDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$CacheDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<CacheDatabase> build() async {
    final path = name != null
        ? join(await sqflite.getDatabasesPath(), name)
        : ':memory:';
    final database = _$CacheDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$CacheDatabase extends CacheDatabase {
  _$CacheDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  CacheObjDao _cacheObjDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
    return sqflite.openDatabase(
      path,
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `cache` (`key` TEXT, `content` TEXT, `expireIn` INTEGER, `latestUpdateTime` INTEGER, `slidingExpire` INTEGER, PRIMARY KEY (`key`))');

        await callback?.onCreate?.call(database, version);
      },
    );
  }

  @override
  CacheObjDao get cacheObjDao {
    return _cacheObjDaoInstance ??= _$CacheObjDao(database, changeListener);
  }
}

class _$CacheObjDao extends CacheObjDao {
  _$CacheObjDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _cacheObjInsertionAdapter = InsertionAdapter(
            database,
            'cache',
            (CacheObj item) => <String, dynamic>{
                  'key': item.key,
                  'content': item.content,
                  'expireIn': item.expireIn,
                  'latestUpdateTime': item.latestUpdateTime,
                  'slidingExpire': item.slidingExpire
                },
            changeListener),
        _cacheObjUpdateAdapter = UpdateAdapter(
            database,
            'cache',
            ['key'],
            (CacheObj item) => <String, dynamic>{
                  'key': item.key,
                  'content': item.content,
                  'expireIn': item.expireIn,
                  'latestUpdateTime': item.latestUpdateTime,
                  'slidingExpire': item.slidingExpire
                },
            changeListener),
        _cacheObjDeletionAdapter = DeletionAdapter(
            database,
            'cache',
            ['key'],
            (CacheObj item) => <String, dynamic>{
                  'key': item.key,
                  'content': item.content,
                  'expireIn': item.expireIn,
                  'latestUpdateTime': item.latestUpdateTime,
                  'slidingExpire': item.slidingExpire
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _cacheMapper = (Map<String, dynamic> row) => CacheObj(
      row['key'] as String,
      row['content'] as String,
      row['expireIn'] as int,
      row['slidingExpire'] as int);

  final InsertionAdapter<CacheObj> _cacheObjInsertionAdapter;

  final UpdateAdapter<CacheObj> _cacheObjUpdateAdapter;

  final DeletionAdapter<CacheObj> _cacheObjDeletionAdapter;

  @override
  Future<CacheObj> getByKey(String key) async {
    return _queryAdapter.query('select * from cache where key = ?',
        arguments: <dynamic>[key], mapper: _cacheMapper);
  }

  @override
  Stream<CacheObj> getStreamByKey(String key) {
    return _queryAdapter.queryStream('select * from cache where key = ?',
        arguments: <dynamic>[key], tableName: 'cache', mapper: _cacheMapper);
  }

  @override
  Future<void> removeByKey(String key) async {
    await _queryAdapter.queryNoReturn('delete from cache where key = ?',
        arguments: <dynamic>[key]);
  }

  @override
  Future<void> deleteAll() async {
    await _queryAdapter.queryNoReturn('delete from cache');
  }

  @override
  Future<void> deleteExpireItems(int currentTime) async {
    await _queryAdapter.queryNoReturn('delete from cache where expireIn < ?',
        arguments: <dynamic>[currentTime]);
  }

  @override
  Future<List<CacheObj>> getOverKeyCapacityItems(
      int minKeepTime, int batchSize, int keyCapacity) async {
    return _queryAdapter.queryList(
        'select * from cache where latestUpdateTime < ? order by expireIn desc limit ? offset ?',
        arguments: <dynamic>[minKeepTime, batchSize, keyCapacity],
        mapper: _cacheMapper);
  }

  @override
  Future<void> insertItem(CacheObj item) async {
    await _cacheObjInsertionAdapter.insert(
        item, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<void> update(CacheObj item) async {
    await _cacheObjUpdateAdapter.update(
        item, sqflite.ConflictAlgorithm.replace);
  }

  @override
  Future<int> deleteList(List<CacheObj> items) {
    return _cacheObjDeletionAdapter.deleteListAndReturnChangedRows(items);
  }

  @override
  Future<void> insertOrUpdate(CacheObj item) async {
    if (database is sqflite.Transaction) {
      await super.insertOrUpdate(item);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$CacheDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.cacheObjDao.insertOrUpdate(item);
      });
    }
  }

  @override
  Future<void> refresh(String key) async {
    if (database is sqflite.Transaction) {
      await super.refresh(key);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$CacheDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.cacheObjDao.refresh(key);
      });
    }
  }

  @override
  Future<int> deleteObjectOverKeyCapacity(
      int keyCapacity, Duration minKeepTimeRelativeToNow) async {
    if (database is sqflite.Transaction) {
      await super
          .deleteObjectOverKeyCapacity(keyCapacity, minKeepTimeRelativeToNow);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$CacheDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.cacheObjDao
            .deleteObjectOverKeyCapacity(keyCapacity, minKeepTimeRelativeToNow);
      });
    }
  }
}
