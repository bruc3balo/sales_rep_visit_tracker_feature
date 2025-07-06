import 'dart:io';
import 'dart:async';
import 'package:logger/logger.dart';

/// Singleton Logger
class AppLog {
  AppLog._(this._logger);

  static late final AppLog _instance;
  final Logger _logger;

  factory AppLog({
    LogOutput? output,
    LogPrinter? printer,
    Level level = Level.info,
  }) {
    _instance = AppLog._(
      Logger(
        output: output ?? ConsoleOutput(),
        printer: printer ?? TagPrinter(),
        level: level,
      ),
    );
    return _instance;
  }

  static AppLog get I => _instance;

  void d(String tag, dynamic message) => _logger.d('[$tag] $message');

  void i(String tag, dynamic message) => _logger.i('[$tag] $message');

  void w(String tag, dynamic message) => _logger.w('[$tag] $message');

  void e(String tag, dynamic message, {dynamic error, StackTrace? trace}) =>
      _logger.e('[$tag] $message', error: error, stackTrace: trace);

  void f(String tag, dynamic message) => _logger.f('[$tag] $message');
}


class TagPrinter extends LogPrinter {
  final String? defaultTag;
  final bool includeTimestamp;

  TagPrinter({this.defaultTag, this.includeTimestamp = false});

  static const String _bold = '\x1B[1m';
  static const String _reset = '\x1B[0m';

  @override
  List<String> log(LogEvent event) {
    final rawMessage = event.message?.toString() ?? '';
    final tagMatch = RegExp(r'^\[(.*?)\]').firstMatch(rawMessage);
    final tag = tagMatch?.group(1) ?? defaultTag ?? 'APP';
    final cleanMessage = rawMessage.replaceFirst(RegExp(r'^\[.*?\]\s*'), '');

    final timestamp = includeTimestamp
        ? '[${DateTime.now().toIso8601String()}] '
        : '';

    final color = event.level.colorCode;
    final formattedLine =
        '$color$timestamp{${event.level.name.toUpperCase()}} - [$tag] - $cleanMessage$_reset';

    final lines = [formattedLine];

    if (event.error != null) {
      lines.add('$color🔴 ${_bold}ERROR$_reset: ${event.error}');
    }

    if (event.stackTrace != null) {
      lines.add('$color📌 ${_bold}STACKTRACE$_reset:\n${event.stackTrace}');
    }

    return lines;
  }
}

extension LogLevelFormat on Level {
  static const String _bold = '\x1B[1m';
  static const String _reset = '\x1B[0m';

  String get coloredName => '$colorCode$_bold${name.toUpperCase()}$_reset';

  String get colorCode =>
      switch (this) {
        Level.all => '\x1B[37m', // White
        Level.verbose => '\x1B[90m', // Gray
        Level.trace => '\x1B[36m', // Cyan
        Level.debug => '\x1B[34m', // Blue
        Level.info => '\x1B[32m', // Green
        Level.warning => '\x1B[33m', // Yellow
        Level.error => '\x1B[31m', // Red
        Level.wtf => '\x1B[91m', // Bright Red
        Level.fatal => '\x1B[91m', // Bright Red
        Level.nothing => '',
        Level.off => '',
      };
}


class FileLogOutput extends ConsoleOutput {
  final String path;
  IOSink? _sink;

  FileLogOutput(this.path) {
    _init();
  }

  void _init() {
    final file = File(path);
    _sink = file.openWrite(mode: FileMode.append);
  }

  @override
  void output(OutputEvent event) {
    super.output(event);
    if (_sink == null) return;
    for (var line in event.lines) {
      _sink!.writeln(line);
    }
  }

  void dispose() async {
    await _sink?.flush();
    await _sink?.close();
  }
}