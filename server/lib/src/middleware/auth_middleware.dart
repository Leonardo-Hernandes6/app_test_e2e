import 'package:shelf/shelf.dart';

import '../data/in_memory_store.dart';
import '../http_utils.dart';

const _userKey = 'demo_server.user';
const _tokenKey = 'demo_server.token';

Middleware requireAuth(InMemoryStore store) {
  return (inner) => (request) {
    final header = request.headers['authorization'] ?? '';
    final token = header.startsWith('Bearer ') ? header.substring(7) : '';
    final user = token.isEmpty ? null : store.findUserByToken(token);

    if (user == null) {
      return errorResponse(401, 'unauthorized', 'Sessão inválida ou expirada.');
    }
    return inner(request.change(context: {_userKey: user, _tokenKey: token}));
  };
}

extension AuthenticatedRequest on Request {
  UserRecord get user => context[_userKey]! as UserRecord;
  String get token => context[_tokenKey]! as String;
}
