import 'dart:async';

withCacheDisable<T>(Future<T> func){
  return runZoned(() {
    print(Zone.current[#key]);
  }, zoneValues: { #key: 'cacheEnabled' });

}