import 'dart:convert';

import 'package:shelf/shelf.dart';

const _jsonHeaders = {'content-type': 'application/json; charset=utf-8'};

Response jsonResponse(int statusCode, Object? body) =>
    Response(statusCode, body: jsonEncode(body), headers: _jsonHeaders);

Response errorResponse(int statusCode, String code, String message) =>
    jsonResponse(statusCode, {'code': code, 'message': message});

Future<Map<String, dynamic>?> readJsonObject(Request request) async {
  try {
    final decoded = jsonDecode(await request.readAsString());
    return decoded is Map<String, dynamic> ? decoded : null;
  } on FormatException {
    return null;
  }
}

Response invalidBody() =>
    errorResponse(400, 'invalid_body', 'O corpo da requisição é inválido.');
