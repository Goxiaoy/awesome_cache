import 'package:logging/logging.dart';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;

class KeyBuilder {

  static final Logger logger=Logger("KeyBuilder");
  static String memoizeKey<T>(String keyPrefix,Function func, Map<String, dynamic> positionalArguments,
      [Map<String, dynamic> namedArguments]) {
    //TODO 不知道func.toString()是否能保持唯一
    String subKey='';
    if(positionalArguments!=null){
      for(var kv in positionalArguments.entries) {
        //TODO toString是否能保持唯一
        subKey+=","+kv.key+":"+buildStringValue(kv.value);
      }
    }
    if(namedArguments!=null){
      for(var kv in namedArguments.entries) {
        subKey+=","+kv.key+":"+buildStringValue(kv.value);
      }
    }
    logger.info("build cache key raw: ${keyPrefix},$subKey");
    var ret="${keyPrefix}${generateMd5(subKey)}";
    return ret;
  }

  static Map<Symbol, dynamic> symbolizeKeys(Map<String, dynamic> map) {
    if(map==null){
      return null;
    }
    final result = new Map<Symbol, dynamic>();
    map.forEach((String k, v) {
      result[Symbol(k)] = v;
    });
    return result;
  }
  
  static String buildStringValue(dynamic value){
    var ret= value.toString();
    if(ret.startsWith("Instance of")){
      throw new Exception("Argument can not convert to string. Please override ${value.runtimeType} toString()");
    }
    return ret;
  }

  ///Generate MD5 hash
  static String generateMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var md5 = crypto.md5;
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }
}
