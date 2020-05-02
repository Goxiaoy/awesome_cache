import 'package:test/test.dart';
import 'package:awesome_cache/awesome_cache.dart';
import 'test_base.dart';

class _A{

  final CacheImplement store;
  _A(this.store);

  Future<String> add(int a,int b,{int c=0}) async{
    await Future.delayed(Duration(milliseconds: 100));
    return Future.value((a+b+c).toString());
  }
}

void main() async {

  group("Cache extension test", (){
    setUpAll(() async {
      await startUp();
    });
    tearDownAll(() async {});
    test("cache extension test", () async {
      await startUp();
      var cacheStore=CacheImplement();
      Future<String> Function() f=() async{
        await Future.delayed(Duration(milliseconds: 100));
        return Future.value('3');
      };

      var key='test1';
      List<String> values=new List();

      var stream=cacheStore.getItemStreamAndForceUpdate(key,f).listen((p){
        values.add(p);
      });

      await Future.delayed(Duration(seconds: 1));
      print(values);
      stream.cancel();
      expect(values.length, 1);
      expect(values.first, '3');
    });
    test("cache extension memoize test", () async {
      await startUp();
      var cacheStore=CacheImplement();

      List<String> values=new List();

      var stream=cacheStore.memoizeCall("Add",_A(cacheStore).add, {"a":1,"b":2}, namedArguments:{'c':3}).listen((p){
        values.add(p);
      });

      await Future.delayed(Duration(seconds: 1));
      print(values);
      stream.cancel();
      expect(values.length, 1);
      expect(values.first, '6');
    });
  });

}