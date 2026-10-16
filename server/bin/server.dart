import 'dart:io';

import 'package:demo_server/demo_server.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

Future<void> main() async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final latencyMs = int.tryParse(Platform.environment['LATENCY_MS'] ?? '') ?? 0;

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(
        buildHandler(
          InMemoryStore(),
          latency: Duration(milliseconds: latencyMs),
        ),
      );

  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  stdout.writeln(
    'Demo API listening on http://${server.address.host}:${server.port}',
  );
}
