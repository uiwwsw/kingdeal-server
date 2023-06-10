import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'crawler.dart';

// Configure routes.
final _router = Router()
  ..get('/healthy', _rootHandler)
  ..get('/getDatas', _dataHandler);

Response _rootHandler(Request req) {
  return Response.ok('ok');
}

Future<Response> _dataHandler(Request request) async {
  // File file = File('convenienceData.json');
  // final message = request.params['message'];
  final res = CrawlerService().getData();

  //read
  return Response.ok(jsonEncode(res));
}

void main(List<String> args) async {
  CrawlerService().setScheduler();
  await CrawlerService().fetch();

  // final ddd = await CrawlerService().getData();
  // print(ddd);
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '80');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
