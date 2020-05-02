import 'package:test/test.dart';
import 'package:awesome_cache/awesome_cache.dart';
import 'test_base.dart';

void main() async {
  group("CacheImplement test", () {
    setUpAll(() async {
      await startUp();
    });
    tearDownAll(() async {});
    test("cacheStore test get set", () async {
      var cacheStore = CacheImplement();
      var testKey = "test1";
      var item = await cacheStore.getItem(testKey);
      expect(item, null);
      //set expired item test
      await cacheStore.setItem(testKey, "1",
          option: CacheEntryOption()
            ..absoluteExpiration =
            DateTime.now().add(Duration(milliseconds: -1)));
      expect(await cacheStore.getItem(testKey), null);
      //set item test
      await cacheStore.setItem(testKey, "1", option: CacheEntryOption());
      var getItem = await cacheStore.getItem(testKey);
      expect(getItem, '1');
      //remove test
      await cacheStore.removeItem(testKey);
      expect(await cacheStore.getItem(testKey), null);

      var newItem = await cacheStore.getOrAddItem(testKey, () async {
        return Future.value("1");
      });
      expect(newItem, '1');
      expect(await cacheStore.getItem(testKey), '1');

      await cacheStore.removeAllItems();
      expect(await cacheStore.getItem(testKey), null);
    });
    test("cacheStore stream test", () async {
      var cacheStore = CacheImplement();
      var testKey = "test1";

      List<String> values = new List();
      var stream = cacheStore.getItemStream(testKey).listen((p) {
        values.add(p);
      });
      //set item
      await cacheStore.setItem(testKey, "1");
      //set duplicate item
      await cacheStore.setItem(testKey, "1");
      //remove item
      await cacheStore.removeItem(testKey);
      //set new item
      await cacheStore.setItem(testKey, "2");
      //set new item
      await cacheStore.setItem(testKey, "3");

      await Future.delayed(Duration(seconds: 1));
      values.forEach((f) {
        print(f);
      });
      expect(values.length, 3);

      stream.cancel();

      values.clear();
      stream = cacheStore
          .getItemStreamAndForceUpdate(testKey, () async => Future.value("4"))
          .listen((p) {
        values.add(p);
      });
      await Future.delayed(Duration(seconds: 1));
      values.forEach((f) {
        print(f);
      });
      expect(values.length, 2);
      expect(values[0], "3");
      expect(values[1], "4");
    });
  });
}
