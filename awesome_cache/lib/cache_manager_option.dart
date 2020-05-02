
class CacheManagerOption{

  String storeName='cache';
  ///max key capacity
  int keyCapacity=1000;
  // when over key capacity, delete items over capacity except items latest update time greater then this value
  Duration minKeepRelativeDurationOverKeyCapacity=Duration(days: 1);
  Duration cleanExpireInterval=Duration(seconds: 30);
}