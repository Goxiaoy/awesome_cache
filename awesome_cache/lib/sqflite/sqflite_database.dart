import 'package:awesome_cache/cache_manager_option.dart';
import 'cache_database.dart';
import 'package:awesome_cache/cache_manager.dart';

Future initInMemorySqfilteCache(CacheManagerOption option) async{
  await CacheManager.init(()async{
    var db=await getSqliteCacheDb(true,option.storeName);
    return db.cacheObjDao;
  },option);
}

Future initFileSqfilteCache(CacheManagerOption option) async{
  await CacheManager.init(()async{
    var db=await getSqliteCacheDb(true,option.storeName);
    return db.cacheObjDao;
  },option);
}


