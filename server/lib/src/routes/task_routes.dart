import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../data/in_memory_store.dart';
import '../http_utils.dart';
import '../middleware/auth_middleware.dart';

class TaskRoutes {
  TaskRoutes(this._store);

  final InMemoryStore _store;

  Handler get handler {
    final router = Router()
      ..get('/', _list)
      ..post('/', _create)
      ..patch('/<id>', _update)
      ..delete('/<id>', _delete);

    return const Pipeline()
        .addMiddleware(requireAuth(_store))
        .addHandler(router.call);
  }

  Response _list(Request request) => jsonResponse(
    200,
    _store.tasksOf(request.user.id).map((task) => task.toJson()).toList(),
  );

  Future<Response> _create(Request request) async {
    final body = await readJsonObject(request);
    if (body == null) return invalidBody();

    final title = (body['title'] as String? ?? '').trim();
    if (title.isEmpty) {
      return errorResponse(
        422,
        'validation_error',
        'O título da tarefa é obrigatório.',
      );
    }
    return jsonResponse(
      201,
      _store.createTask(request.user.id, title).toJson(),
    );
  }

  Future<Response> _update(Request request, String id) async {
    final task = _store.taskOf(request.user.id, id);
    if (task == null) return _notFound();

    final body = await readJsonObject(request);
    if (body == null) return invalidBody();

    final title = body['title'];
    final done = body['done'];
    if (title is String && title.trim().isNotEmpty) task.title = title.trim();
    if (done is bool) task.done = done;

    return jsonResponse(200, task.toJson());
  }

  Response _delete(Request request, String id) {
    if (_store.taskOf(request.user.id, id) == null) return _notFound();
    _store.deleteTask(id);
    return Response(204);
  }

  Response _notFound() =>
      errorResponse(404, 'not_found', 'Tarefa não encontrada.');
}
