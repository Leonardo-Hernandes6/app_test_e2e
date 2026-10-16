import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../data/in_memory_store.dart';
import '../http_utils.dart';
import '../middleware/auth_middleware.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
const _minPasswordLength = 6;

class AuthRoutes {
  AuthRoutes(this._store);

  final InMemoryStore _store;

  Router get router {
    final protected = const Pipeline().addMiddleware(requireAuth(_store));

    return Router()
      ..post('/register', _register)
      ..post('/login', _login)
      ..get('/me', protected.addHandler(_me))
      ..post('/logout', protected.addHandler(_logout));
  }

  Future<Response> _register(Request request) async {
    final body = await readJsonObject(request);
    if (body == null) return invalidBody();

    final name = (body['name'] as String? ?? '').trim();
    final email = (body['email'] as String? ?? '').trim();
    final password = body['password'] as String? ?? '';

    if (name.isEmpty ||
        !_emailPattern.hasMatch(email) ||
        password.length < _minPasswordLength) {
      return errorResponse(
        422,
        'validation_error',
        'Nome, e-mail ou senha inválidos.',
      );
    }
    if (_store.findUserByEmail(email) != null) {
      return errorResponse(
        409,
        'email_already_in_use',
        'Já existe uma conta com este e-mail.',
      );
    }

    final user = _store.createUser(
      name: name,
      email: email,
      password: password,
    );
    return _session(201, user);
  }

  Future<Response> _login(Request request) async {
    final body = await readJsonObject(request);
    if (body == null) return invalidBody();

    final user = _store.findUserByEmail(body['email'] as String? ?? '');
    final password = body['password'] as String? ?? '';

    if (user == null || !_store.checkPassword(user, password)) {
      return errorResponse(
        401,
        'invalid_credentials',
        'E-mail ou senha incorretos.',
      );
    }
    return _session(200, user);
  }

  Response _me(Request request) => jsonResponse(200, request.user.toJson());

  Response _logout(Request request) {
    _store.closeSession(request.token);
    return Response(204);
  }

  Response _session(int statusCode, UserRecord user) => jsonResponse(
    statusCode,
    {'token': _store.openSession(user), 'user': user.toJson()},
  );
}
