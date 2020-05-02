import 'dart:async';


import 'package:awesome_cache/cache_manager.dart';
import 'package:awesome_cache/cache_store.dart';
import 'package:rxdart/rxdart.dart';

import 'cache_entry_option.dart';
import 'cache_obj.dart';
import 'sqflite/cache_obj_dao.dart';
import 'cache_option.dart';

import 'cache_interface.dart';
import 'sqflite/cache_database.dart';
import 'cache_serializer.dart';
import 'package:logging/logging.dart';

class CacheImplement implements Cache,CacheTyped,CacheStream,CacheTypedStream{

  final CacheSerializer _cacheSerializer;
  final CacheOption _cacheOption;
  final Logger _logger=Logger("CacheImplement");
  final CacheStore _store;

  CacheImplement([CacheSerializer cacheSerializer,CacheOption cacheOption,CacheStore store]):
        this._cacheSerializer=cacheSerializer,
        this._cacheOption=cacheOption??CacheOption(),
        this._store=store??CacheManager().database;

  CacheStore get _m=>_store;

  @override
  Future<String> getItem(String key) async{
    //TODO handle refresh
    var cacheObj= await _m.getByKey(key);
    if(cacheObj!=null){
      if(cacheObj.expireIn>=DateTime.now().millisecondsSinceEpoch){
        return cacheObj.content;
      }
    }
    return null;
  }

  @override
  Future<String> getOrAddItem(String key,Future<String> Function() itemFactory,{CacheEntryOption Function() optionFactory}) async{
    var item=await getItem(key);
    if(item!=null){
      return item;
    }
    //TODO 并发问题
    item=await itemFactory();
    await setItem(key, item, option:optionFactory==null?null:optionFactory());
    return item;
  }

  @override
  Future refreshItem(String key) async{
    await _m.refresh(key);
  }

  @override
  Future removeItem(String key) async{
    await _m.removeByKey(key);
  }

  @override
  Future setItem(String key, String value, {CacheEntryOption option}) async{
    var normalizedOption=getOption(option);
    //TODO relative
    var cacheObj=CacheObj.absolute(key,value,normalizedOption.absoluteExpiration);
    _logger.info("update cache key $key");
    await _m.insertOrUpdate(cacheObj);
  }

  @override
  Stream<String> getItemStream(String key) {
    return _m.getStreamByKey(key).transform<String>(StreamTransformer.fromHandlers(handleData: (a,b){
      b.add(a?.content);
    })).distinct((a,b)=>a==b);
  }

  @override
  Future<T> getItemTyped<T extends Object> (String key) async{
    var item=await getItem(key);
    return _stingToTyped<T>(item);
  }

  @override
  Stream<T> getItemTypedStream<T extends Object>(String key) {
    return getItemStream(key).transform<T>( StreamTransformer<String, T>.fromHandlers(handleData: (String data, sink){
      sink.add(_stingToTyped(data));
    }));
  }

//  @override
//  Stream<String> getOrAddItemStream(String key,Future<String> Function() itemFactory,CacheEntryOption Function() optionFactory) {
//
//  }

  @override
  Future<T> getOrAddItemTyped<T extends Object>(String key,Future<String> Function() itemFactory,{CacheEntryOption Function() optionFactory}) async{
    var item=await getOrAddItem(key, itemFactory, optionFactory: optionFactory);
    return _stingToTyped(item);
  }

//  @override
//  Stream<T> getOrAddItemTypedStream<T extends Object>(String key,Future<String> Function() itemFactory,CacheEntryOption Function() optionFactory) {
//    return getOrAddItemStream(key, itemFactory, optionFactory).transform<T>( StreamTransformer<String, T>.fromHandlers(handleData: (String data, sink){
//      sink.add(_stingToTyped(data));
//    }));
//  }

  @override
  Future setItemTyped<T>(String key, T value, {CacheEntryOption option}) {
    return setItem(key, _cacheSerializer.serialize(value), option:option);
  }

  T _stingToTyped<T extends Object>(String item){
    return item==null?null:_cacheSerializer.deserialize<T>(item);
  }

  CacheEntryOption getOption(CacheEntryOption option){
    var ret=option;
    if(ret==null){
      ret=new CacheEntryOption();
      ret.absoluteExpirationRelativeToNow=_cacheOption.defaultExpireTime;
    }
    if(ret.slidingExpiration!=null){
      throw ArgumentError.value(ret.slidingExpiration,"slidingExpiration","Not implemrnt");
    }
    if(ret.absoluteExpirationRelativeToNow!=null){
      ret.absoluteExpiration=DateTime.now().add(ret.absoluteExpirationRelativeToNow);
    }
    if(ret.absoluteExpiration==null){
      ret.absoluteExpiration=DateTime.now().add(_cacheOption.defaultExpireTime);
    }
    return ret;
  }

  @override
  Future removeAllItems() async{
    await _m.deleteAll();
  }
}

