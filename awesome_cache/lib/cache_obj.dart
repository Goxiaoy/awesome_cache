
import 'package:floor/floor.dart';

@Entity(tableName: "cache")
class CacheObj{
  ///cache key
  @primaryKey
  String key;
  ///cached content
  String content;
  ///expire time in
  int expireIn;

  int latestUpdateTime;

  @ColumnInfo(name: 'slidingExpire', nullable: true)
  int slidingExpire;

  CacheObj(this.key,this.content,this.expireIn,this.slidingExpire);

  CacheObj.absolute(this.key,this.content,DateTime expireIn):this.expireIn=expireIn?.millisecondsSinceEpoch;

  CacheObj.relative(this.key,this.content,Duration slidingExpire):this.slidingExpire=slidingExpire.inMilliseconds;

//  String get contentStr =>String.fromCharCodes(content);
//  set contentStr(String value)=>content=Uint8List.fromList(value.codeUnits);

  void refresh(){
    if(slidingExpire!=null){
      expireIn=DateTime.now().millisecondsSinceEpoch+slidingExpire;
    }
    latestUpdateTime=DateTime.now().millisecondsSinceEpoch;
  }

  CacheObj.fromJson(Map<String, dynamic> json) {
    if(json==null){
      return;
    }
    key = json['key'] as String;
    content = json['content'] as String;
    expireIn = json['expireIn'] as int;
    latestUpdateTime = json['latestUpdateTime'] as int;
    slidingExpire = json['slidingExpire'] as int;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['content'] = this.content;
    data['expireIn'] = this.expireIn;
    data['latestUpdateTime'] = this.latestUpdateTime;
    data['slidingExpire'] = this.slidingExpire;
    return data;
  }

}

