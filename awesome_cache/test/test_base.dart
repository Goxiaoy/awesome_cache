import 'package:awesome_cache/cache_manager_option.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_ffi_test/sqflite_ffi_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logging/logging.dart';
import 'package:awesome_cache/awesome_cache.dart';

Future startUp() async{
  await startUpBase();
  await initInMemorySqfilteCache(CacheManagerOption());
}

Future startUpBase() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  Logger.root.level =Level.FINE;
  Logger.root.onRecord.listen((LogRecord rec) {
    print(
        '[${rec.level.name}][${rec.time}][${rec.loggerName}]: ${rec.message}');
  });
  sqfliteFfiTestInit();
  Sqflite.devSetDebugModeOn(true);

}