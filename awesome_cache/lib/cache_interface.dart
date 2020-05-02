import 'cache_entry_option.dart';

abstract class Cache{
  Future<String> getItem(String key);
  Future<String> getOrAddItem(String key,Future<String> Function() itemFactory,{CacheEntryOption Function() optionFactory});
  Future setItem(String key,String value,{CacheEntryOption option});
  /// Refreshes the cache value of the given key, and resets its sliding expiration timeout.
  Future refreshItem(String key);
  Future removeItem(String key);
  ///remove all caches
  Future removeAllItems();
  }

abstract class CacheStream extends Cache{
  Stream<String> getItemStream(String key);
}

abstract class CacheTyped extends Cache{
  Future<T> getItemTyped<T extends Object>(String key);
  Future<T> getOrAddItemTyped<T extends Object>(String key,Future<String> Function() itemFactory,{CacheEntryOption Function() optionFactory});
  Future setItemTyped<T>(String key,T value,{CacheEntryOption option});
}

abstract class CacheTypedStream extends CacheTyped implements CacheStream{
  Stream<T> getItemTypedStream<T extends Object>(String key);
}
