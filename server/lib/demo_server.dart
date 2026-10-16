import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'src/data/in_memory_store.dart';
import 'src/http_utils.dart';
import 'src/routes/auth_routes.dart';
import 'src/routes/task_routes.dart';

export 'src/data/in_memory_store.dart' show InMemoryStore;

Handler buildHandler(InMemoryStore store, {Duration latency = Duration.zero}) {
  final router = Router()
    ..get('/health', (_) => jsonResponse(200, {'status': 'ok'}))
    ..post('/test/reset', (_) {
      store.reset();
      return Response(204);
    })
    ..mount('/auth', AuthRoutes(store).router.call)
    ..mount('/tasks', TaskRoutes(store).handler);

  return const Pipeline()
      .addMiddleware(_artificialLatency(latency))
      .addHandler(router.call);
}

Middleware _artificialLatency(Duration latency) {
  return (inner) => (request) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    return inner(request);
  };
}
