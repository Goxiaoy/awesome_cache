class CacheEntryOption{
  DateTime absoluteExpiration;
  Duration _absoluteExpirationRelativeToNow;
  Duration _slidingExpiration;

  Duration get absoluteExpirationRelativeToNow=>_absoluteExpirationRelativeToNow;
  Duration get slidingExpiration=>_slidingExpiration;

  set absoluteExpirationRelativeToNow(Duration duration){
    if(duration!=null){
      if(duration<Duration.zero){
        throw ArgumentError.value(duration,"duration","duration should be greater then zero");
      }
    }
    _absoluteExpirationRelativeToNow=duration;
  }
  set slidingExpiration(Duration duration){
    if(duration!=null){
      if(duration<Duration.zero){
        throw ArgumentError.value(duration,"duration","duration should be greater then zero");
      }
    }
    _slidingExpiration=duration;
  }

  CacheEntryOption({this.absoluteExpiration,Duration absoluteExpirationRelativeToNow}){
    this.absoluteExpirationRelativeToNow=absoluteExpirationRelativeToNow;
  }
}