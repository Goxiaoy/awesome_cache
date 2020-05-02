import 'package:awesome_cache/cache_manager_option.dart';
import 'package:awesome_cache/sqflite/sqflite_database.dart';
import 'package:test/test.dart';
import 'package:awesome_cache/awesome_cache.dart';
import 'test_base.dart';

void main() async {
  test("cacheStore test clean up", () async {
    await startUpBase();
    await initInMemorySqfilteCache(CacheManagerOption()
      ..keyCapacity = 1
      ..cleanExpireInterval = Duration(milliseconds: 10)
      ..minKeepRelativeDurationOverKeyCapacity = Duration(days: -1));
    var testKey = "test";
    var cacheStore = CacheImplement();
    for (int i = 0; i < 50; i++) {
      await cacheStore.setItem(testKey + i.toString(), i.toString());
    }
    await Future.delayed(Duration(seconds: 1));
    expect(await cacheStore.getItem(testKey + 49.toString()) != null, true);
    expect(await cacheStore.getItem(testKey + 48.toString()) == null, true);
  });
}
