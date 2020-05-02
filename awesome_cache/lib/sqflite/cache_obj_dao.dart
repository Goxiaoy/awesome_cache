import 'dart:async';

import 'package:awesome_cache/cache_store.dart';
import 'package:floor/floor.dart';
import '../cache_obj.dart';

@dao
abstract class CacheObjDao extends CacheStore{

  @Query('select * from cache where key = :key')
  Future<CacheObj> getByKey(String key);

  @Query('select * from cache where key = :key')
  Stream<CacheObj> getStreamByKey(String key);

  @transaction
  Future<void> insertOrUpdate(CacheObj item) async{
    await super.insertOrUpdate(item);
  }

  @Query('delete from cache where key = :key')
  Future<void> removeByKey(String key);

  @transaction
  Future<void> refresh(String key) async{
    await super.refresh(key);
  }

  @Update(onConflict: OnConflictStrategy.REPLACE)
  Future<void> update(CacheObj item);

  @insert
  Future<void> insertItem(CacheObj item);

  @Query('delete from cache')
  Future<void> deleteAll();

  @Query('delete from cache where expireIn < :currentTime')
  Future<void> deleteExpireItems(int currentTime);

  @delete
  Future<int> deleteList(List<CacheObj> items);

  @Query('select * from cache where latestUpdateTime < :minKeepTime order by expireIn desc limit :batchSize offset :keyCapacity')
  Future<List<CacheObj>> getOverKeyCapacityItems(int minKeepTime,int batchSize,int keyCapacity);

  @transaction
  Future<int> deleteObjectOverKeyCapacity(int keyCapacity,Duration minKeepTimeRelativeToNow) async {
    return await super.deleteObjectOverKeyCapacity(
        keyCapacity, minKeepTimeRelativeToNow);
  }
}