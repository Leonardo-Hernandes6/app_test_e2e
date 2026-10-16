import 'dart:convert';

import 'package:demo_server/demo_server.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  late Handler api;

  setUp(() => api = buildHandler(InMemoryStore()));

  Future<Response> send(
    String method,
    String path, {
    Object? body,
    String? token,
  }) {
    return Future.value(
      api(
        Request(
          method,
          Uri.parse('http://localhost$path'),
          body: body == null ? null : jsonEncode(body),
          headers: {if (token != null) 'authorization': 'Bearer $token'},
        ),
      ),
    );
  }

  Future<dynamic> decode(Response response) async =>
      jsonDecode(await response.readAsString());

  Future<String> registerAna() async {
    final response = await send(
      'POST',
      '/auth/register',
      body: {'name': 'Ana', 'email': 'ana@demo.com', 'password': '123456'},
    );
    return (await decode(response))['token'] as String;
  }

  group('API /auth', () {
    test('cadastro: devolve a sessão do novo usuário', () async {
      final response = await send(
        'POST',
        '/auth/register',
        body: {'name': 'Ana', 'email': 'Ana@Demo.com', 'password': '123456'},
      );

      expect(response.statusCode, 201);
      final body = await decode(response);
      expect(body['token'], isNotEmpty);
      expect(body['user']['email'], 'ana@demo.com');
    });

    test('cadastro: recusa e-mail já cadastrado', () async {
      await registerAna();
      final response = await send(
        'POST',
        '/auth/register',
        body: {'name': 'Ana', 'email': 'ana@demo.com', 'password': '123456'},
      );

      expect(response.statusCode, 409);
      expect((await decode(response))['code'], 'email_already_in_use');
    });

    test('cadastro: valida nome, e-mail e senha', () async {
      final response = await send(
        'POST',
        '/auth/register',
        body: {'name': '', 'email': 'invalid', 'password': '1'},
      );

      expect(response.statusCode, 422);
    });

    test('login: recusa senha errada', () async {
      await registerAna();
      final response = await send(
        'POST',
        '/auth/login',
        body: {'email': 'ana@demo.com', 'password': 'wrong-password'},
      );

      expect(response.statusCode, 401);
      expect((await decode(response))['code'], 'invalid_credentials');
    });

    test('logout: invalida o token', () async {
      final token = await registerAna();

      expect(
        (await send('POST', '/auth/logout', token: token)).statusCode,
        204,
      );
      expect((await send('GET', '/auth/me', token: token)).statusCode, 401);
    });
  });

  group('API /tasks', () {
    test('exige autenticação', () async {
      expect((await send('GET', '/tasks/')).statusCode, 401);
    });

    test('cria, conclui e exclui uma tarefa', () async {
      final token = await registerAna();

      final created = await decode(
        await send('POST', '/tasks/', body: {'title': 'Ensaiar'}, token: token),
      );
      final id = created['id'] as String;
      expect(created['done'], isFalse);

      final updated = await decode(
        await send('PATCH', '/tasks/$id', body: {'done': true}, token: token),
      );
      expect(updated['done'], isTrue);

      expect(
        (await send('DELETE', '/tasks/$id', token: token)).statusCode,
        204,
      );
      expect(await decode(await send('GET', '/tasks/', token: token)), isEmpty);
    });

    test('usuário não vê tarefas de outro usuário', () async {
      final ana = await registerAna();
      await send('POST', '/tasks/', body: {'title': 'Privada'}, token: ana);

      final bruno =
          (await decode(
                await send(
                  'POST',
                  '/auth/register',
                  body: {
                    'name': 'Bruno',
                    'email': 'bruno@demo.com',
                    'password': '123456',
                  },
                ),
              ))['token']
              as String;

      expect(await decode(await send('GET', '/tasks/', token: bruno)), isEmpty);
    });
  });
}
