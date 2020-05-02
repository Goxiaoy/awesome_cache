import 'cache_entry_option.dart';
import 'cache_interface.dart';
import 'key_builder.dart';
import 'dart:async';

extension CacheExtension on CacheStream {
  Stream<String> getItemStreamAndForceUpdate(
      String key, Future<String> Function() itemFactory,
      {CacheEntryOption Function() optionFactory}) {
    var ret = this.getItemStream(key);
    //async refresh
    itemFactory().then((newValue) async {
      await this.setItem(key, newValue,
          option: optionFactory == null ? null : optionFactory());
      //this will trigger previous stream update
    });
    return ret;
  }

  // call function and then update cache database
  Future<String> memoizeCallOnce(String keyPrefix, Function func, Map<String, dynamic> positionalArguments,
      {Map<String, dynamic> namedArguments,
        CacheEntryOption Function() optionFactory}) async{
    var key = KeyBuilder.memoizeKey(
        keyPrefix, func, positionalArguments, namedArguments);
    var listPositional=positionalArguments==null?[]:positionalArguments.values.toList();
    var data=await (Function.apply(func, listPositional,
        KeyBuilder.symbolizeKeys(namedArguments))) as String;
    await this.setItem(key, data,option: optionFactory == null ? null : optionFactory());
    return data;
  }


  ///func 必须是一个闭包的函数,注意positionalArguments参数的顺序很重要
  Stream<String> memoizeCall(
      String keyPrefix, Function func, Map<String, dynamic> positionalArguments,
      {Map<String, dynamic> namedArguments,
      CacheEntryOption Function() optionFactory}) {
    var key = KeyBuilder.memoizeKey(
        keyPrefix, func, positionalArguments, namedArguments);
    var listPositional=positionalArguments==null?[]:positionalArguments.values.toList();
    return this.getItemStreamAndForceUpdate(key, () async {
      return await (Function.apply(func, listPositional,
          KeyBuilder.symbolizeKeys(namedArguments))) as String;
    }, optionFactory: optionFactory);
  }
}

extension CacheTypedExtension on CacheTypedStream {
  Stream<T> getItemTypedStreamAndForceUpdate<T extends Object>(
      String key, Future<T> Function() itemFactory,
      {CacheEntryOption Function() optionFactory}) {
    var ret = this.getItemTypedStream<T>(key);
    //async refresh
    itemFactory().then((newValue) async {
      await this.setItemTyped(key, newValue,
          option: optionFactory == null ? null : optionFactory());
      //this will trigger previous stream update
    });
    return ret;
  }

  ///func 必须是一个闭包的函数,注意positionalArguments参数的顺序很重要
  Stream<T> memoizeCallTyped<T>(
      String keyPrefix, Function func, Map<String, dynamic> positionalArguments,
      {Map<String, dynamic> namedArguments,
      CacheEntryOption Function() optionFactory}) {
    var key = KeyBuilder.memoizeKey(
        keyPrefix, func, positionalArguments, namedArguments);
    var listPositional=positionalArguments==null?[]:positionalArguments.values.toList();
    return this.getItemTypedStreamAndForceUpdate<T>(key, () async {
      return await (Function.apply(func, listPositional,
          KeyBuilder.symbolizeKeys(namedArguments))) as T;
    }, optionFactory: optionFactory);
  }

  ///call function and then update cache database
  Future<T> memoizeCallTypedOnce<T>(
      String keyPrefix, Function func, Map<String, dynamic> positionalArguments,
      {Map<String, dynamic> namedArguments,
        CacheEntryOption Function() optionFactory}) async{
    var key = KeyBuilder.memoizeKey(
        keyPrefix, func, positionalArguments, namedArguments);
    var listPositional=positionalArguments==null?[]:positionalArguments.values.toList();
    var data=await (Function.apply(func, listPositional,
        KeyBuilder.symbolizeKeys(namedArguments))) as T;
    await this.setItemTyped(key, data,option: optionFactory == null ? null : optionFactory());
    return data;
  }
}
