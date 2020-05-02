import 'cache_database.dart';
import 'package:awesome_cache/cache_manager.dart';
import 'package:awesome_cache/cache_manager_option.dart';

Future initCouchbaseCache(CacheManagerOption option) async{
  await CacheManager.init(()async{
    var db=await getCouchbaseCacheDb(option.storeName);
    return db;
  },option);
}