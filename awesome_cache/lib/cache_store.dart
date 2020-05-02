import 'cache_obj.dart';

abstract class CacheStore {

  Future<CacheObj> getByKey(String key);

  Stream<CacheObj> getStreamByKey(String key);

  Future<void> insertOrUpdate(CacheObj item) async {
    var find = await getByKey(item.key);
    if (find == null) {
      item.refresh();
      await insertItem(item);
    } else {
      item.refresh();
      await update(item);
    }
  }

  Future<void> removeByKey(String key);

  Future<void> refresh(String key) async {
    var item = await getByKey(key);
    if (item != null) {
      item.refresh();
      await update(item);
    }
  }

  Future<void> update(CacheObj item);

  Future<void> insertItem(CacheObj item);

  Future<void> deleteAll();

  Future<void> deleteExpireItems(int currentTime);

  Future<int> deleteList(List<CacheObj> items);

  Future<List<CacheObj>> getOverKeyCapacityItems(
      int minKeepTime, int batchSize, int keyCapacity);

  Future<int> deleteObjectOverKeyCapacity(
      int keyCapacity, Duration minKeepTimeRelativeToNow) async {
    //default delete batch size to 100
    var items = await getOverKeyCapacityItems(
        DateTime.now()
            .subtract(minKeepTimeRelativeToNow)
            .millisecondsSinceEpoch,
        100,
        keyCapacity);
    if (items.length > 0) {
      return await deleteList(items);
    }
    return 0;
  }
}
