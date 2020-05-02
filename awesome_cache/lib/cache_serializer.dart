
abstract class CacheSerializer{
  String  serialize<T>(T obj);
  T deserialize<T>(String item);
  List<T> deserializeList<T>(String item);
}