import 'package:logging/logging.dart';

mixin LoggerMixin {
  Logger _log;

  Logger get log {
    if (_log == null) {
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((LogRecord rec) {
        print('${rec.level.name}: ${rec.time}: ${rec.message}');
      });
      _log = Logger(runtimeType.toString());
    }
    return _log;
  }
}
