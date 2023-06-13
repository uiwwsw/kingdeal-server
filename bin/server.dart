import 'dart:async';

import 'package:dotenv/dotenv.dart';

import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

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
  // for (var d in res) {
  //   print(d.title);
  // }
  return Response.ok(res);
}

Middleware authRequests(
        {void Function(String message, bool isError)? logger}) =>
    (innerHandler) {
      return (request) {
        return Future.sync(() => innerHandler(request)).then((response) {
          final res = request.headers[HttpHeaders.authorizationHeader] ==
              env['SECRET_KEY'];
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
  final overrideHeaders = {
    ACCESS_CONTROL_ALLOW_ORIGIN: '*',
  };
  // final ddd = await CrawlerService().getData();
  // print(ddd);
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline()
      .addMiddleware(corsHeaders(headers: overrideHeaders))
      .addMiddleware(logRequests())
      .addMiddleware(authRequests())
      .addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(env['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
