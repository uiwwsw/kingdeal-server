import 'dart:async';

import 'package:dotenv/dotenv.dart';

import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'crawler.dart';

var env = DotEnv(includePlatformEnvironment: true)..load();

// Configure routes.
final _router = Router()
  ..get('/healthy', _rootHandler)
  ..get('/getDatas', _dataHandler);

Response _rootHandler(Request req) {
  return Response.ok('ok');
}

Future<Response> _dataHandler(Request request) async {
  // try {
  //   print(env['SECRET_KET']);
  //   final token = request.headers[HttpHeaders.authorizationHeader];
  //   final jwt = JWT.verify(token!, SecretKey('secret passphrase'));

  // } catch (_) {
  //   return Response.ok([]);
  // }
  final res = CrawlerService().getData();
  return Response.ok(jsonEncode(res));
}

Middleware authRequests(
        {void Function(String message, bool isError)? logger}) =>
    (innerHandler) {
      return (request) {
        return Future.sync(() => innerHandler(request)).then((response) {
          final res = request.headers[HttpHeaders.authorizationHeader] ==
              env['SECRET_KEY'];
          print(request.headers[HttpHeaders.authorizationHeader]);
          if (res) {
            return response;
          } else {
            throw Error();
          }
        }, onError: (Object error, StackTrace stackTrace) {
          throw error;
        });
      };
    };

void main(List<String> args) async {
  CrawlerService().setScheduler();

  // final ddd = await CrawlerService().getData();
  // print(ddd);
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(authRequests())
      .addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '80');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
