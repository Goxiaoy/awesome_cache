import 'cache_store.dart';
import 'cache_manager_option.dart';
import 'package:logging/logging.dart';
import 'dart:async';

import 'sqflite/cache_database.dart';

Completer<CacheStore> _dbCompleter;

class CacheManager{

  ///database instance
  final CacheStore _database;
  final Logger _log=Logger('CacheManager');
  static CacheManager _instance;

  CacheStore get database=>_database;

  factory CacheManager() {
    if(_instance==null){
      throw Exception("Call CacheManager.init before use ");
    }
    return _instance;
  }

  CacheManager._internal(this._database,CacheManagerOption option){
    _startExpireTimer(option);
  }

  static Future<void> init(Future<CacheStore> Function() dbFuture,CacheManagerOption option) async{
    if(_dbCompleter!=null){
      return await _dbCompleter.future;
    }
    _dbCompleter=Completer();
    CacheStore database=await dbFuture();
    _instance=CacheManager._internal(database,option);
    _dbCompleter.complete(database);
  }

  Timer _cleanExpireTimer;
  void _startExpireTimer(CacheManagerOption option){
    //TODO automatically adjust timer and batch size
    //1. 过期的数量过多,加快清理的速度，过期的数量少，减慢清理的速度
    //2. 动态调整batch size,因为像有些数据库，sqlite是会加锁的，如果读写速度比较频繁，降低batch size,如果比较空闲，则提高batch size
    _cleanExpireTimer=Timer.periodic(option.cleanExpireInterval, (a) async=>await cleanCacheJob(option));
  }

  Future cleanCacheJob(CacheManagerOption option) async{
    _log.fine("start clean cache items");
    await this._database.deleteExpireItems(DateTime.now().millisecondsSinceEpoch);
    _log.fine("clean expire cache success");
    if(option.keyCapacity!=null){
      var overCount=await this._database.deleteObjectOverKeyCapacity(option.keyCapacity, option.minKeepRelativeDurationOverKeyCapacity);
      _log.fine("clean $overCount over capacity cache items success");
    }

  }

}