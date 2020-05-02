import 'package:awesome_cache/cache_obj.dart';
import 'package:awesome_cache/cache_store.dart';
import 'package:couchbase_lite/couchbase_lite.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:logging/logging.dart';
import 'observable_response.dart';

Future<CouchbaseStore> getCouchbaseCacheDb(String dbName) async {
  var database = await Database.initWithName(dbName);
  return CouchbaseStore(CouchbaseDatabase(dbName, database));
}

typedef ResultSetCallback = void Function(ResultSet results);

class CouchbaseDatabase {
  final Logger _log = Logger("CouchbaseDatabase");

  List<Future> pendingListeners = List();
  ListenerToken _replicatorListenerToken;
  final Database database;
  Replicator replicator;
  final String dbName;

  CouchbaseDatabase(this.dbName, this.database);

  Future<Document> createDocumentIfNotExists(
      String id, Map<String, dynamic> map) async {
    try {
      var oldDoc = await database.document(id);
      if (oldDoc != null) return oldDoc;
      var newDoc = MutableDocument(id: id, data: map);
      if (await database.saveDocument(newDoc)) {
        return newDoc;
      } else {
        return null;
      }
    } on PlatformException {
      return null;
    }
  }


  ObservableResponse<T> buildObservableQueryResponse<T>(
      BehaviorSubject<T> subject,
      Query query,
      ResultSetCallback resultsCallback) {
    final futureToken = query.addChangeListener((change) {
      if (change.results != null) {
        resultsCallback(change.results);
      }
    });

    final removeListener = () {
      final newFuture = futureToken.then((token) async {
        if (token != null) {
          await query.removeChangeListener(token);
        }
      });

      pendingListeners.add(newFuture);
      newFuture.whenComplete(() {
        pendingListeners.remove(newFuture);
      });
    };

    try {
      query.execute().then(resultsCallback);
    } on PlatformException {
      removeListener();
      rethrow;
    }

    return ObservableResponse<T>(subject, () {
      removeListener();
      subject.close();
    });
  }
}

class CouchbaseStore extends CacheStore {
  Database get db => _couchDb.database;

  final CouchbaseDatabase _couchDb;
  final String _alias = "mydocs";
  CouchbaseStore(this._couchDb);

  @override
  Future<void> deleteAll() async {
    await db.delete();
  }

  @override
  Future<void> deleteExpireItems(int currentTime) async {
    final Query query = QueryBuilder.select([SelectResult.all().from(_alias)])
        .from(_couchDb.dbName, as: _alias)
        .where(Expression.property("expireIn")
            .from(_alias)
            .lessThan(Expression.value(currentTime)));
    var retSet = await query.execute();
    var list = retSet.map((p) {
      var m = p.toMap();
      return CacheObj.fromJson(m[_alias] as Map<String, dynamic>);
    }).toList();
    await deleteList(list);
  }

  @override
  Future<int> deleteList(List<CacheObj> items) async {
    ArgumentError.checkNotNull(items);
    var ret = 0;
    for (var i in items) {
      ArgumentError.checkNotNull(i.key);
      var success = await _deleteDoc(i.key);
      if (success) {
        ret++;
      }
    }
    return ret;
  }

  @override
  Future<CacheObj> getByKey(String key) async {
    var doc = await db.document(key);
    return CacheObj.fromJson(doc?.toMap());
  }

  @override
  Future<List<CacheObj>> getOverKeyCapacityItems(
      int minKeepTime, int batchSize, int keyCapacity) async {
    final Query query = QueryBuilder.select([SelectResult.all().from(_alias)])
        .from(_couchDb.dbName, as: _alias)
        .where(Expression.property("latestUpdateTime")
            .from(_alias)
            .lessThan(Expression.value(minKeepTime)))
        .orderBy([
      Ordering.expression(Expression.property("expireIn").from(_alias))
          .descending()
    ]).limit(Expression.value(batchSize),
            offset: Expression.value(keyCapacity));
    var retSet = await query.execute();
    var list = retSet.map((p) {
      var m = p.toMap();
      return CacheObj.fromJson(m[_alias] as Map<String, dynamic>);
    }).toList();
    return list;
  }

  @override
  Stream<CacheObj> getStreamByKey(String key) {
    final stream = BehaviorSubject<CacheObj>();
    // Execute a query and then post results and all changes to the stream

    final Query query = QueryBuilder.select([SelectResult.all().from(_alias)])
        .from(_couchDb.dbName, as: _alias)
        .where(Meta.id.from(_alias).equalTo(Expression.string(key)));

    final processResults = (ResultSet results) {
      if (!stream.isClosed) {
        var items=results.map((p) {
          var m = p.toMap();
          return CacheObj.fromJson(m[_alias] as Map<String, dynamic>);
        });
        if(items.length>0){
          stream.add(items.first);
        }else{
          //TODO should trigger stream?
          stream.add(null);
        }
      }
    };
    //TODO release BehaviorSubject
    return _couchDb.buildObservableQueryResponse(stream, query, processResults).stream;
  }

  @override
  Future<void> insertItem(CacheObj item) async {
    var newDoc = MutableDocument(id: item.key, data: item.toJson());
    var success = await _couchDb.database.saveDocument(newDoc);
  }

  @override
  Future<void> removeByKey(String key) async {
    await _deleteDoc(key);
  }

  @override
  Future<void> update(CacheObj item)  async{
    var newDoc = MutableDocument(id: item.key, data: item.toJson());
    var success = await _couchDb.database.saveDocument(newDoc);
  }

  Future<bool> _deleteDoc(String key) async {
    return await db.deleteDocument(key);
  }
}
