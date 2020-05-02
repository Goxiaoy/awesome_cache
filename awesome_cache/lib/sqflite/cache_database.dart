import 'package:floor/floor.dart';
import 'dart:async';
import 'package:path/path.dart';
import '../cache_obj.dart';
import 'cache_obj_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
part 'cache_database.g.dart';

Future<CacheDatabase> getSqliteCacheDb(bool inMemory, String storeName) async {
//  // create migration
//  final migration1to2 = Migration(1, 2, (database) async {
//
//  });
  if (inMemory) {
    final database =
        await $FloorCacheDatabase.inMemoryDatabaseBuilder().build();
    return database;
  } else {
    final database = await $FloorCacheDatabase
        .databaseBuilder(storeName + ".db")
//      .addMigrations([migration1to2])
        .build();
    return database;
  }
}

@Database(version: 1, entities: [CacheObj])
abstract class CacheDatabase extends FloorDatabase {
  // DAO getters
  CacheObjDao get cacheObjDao;
}
