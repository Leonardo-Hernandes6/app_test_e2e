import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class UserRecord {
  UserRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.salt,
  });

  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final String salt;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}

class TaskRecord {
  TaskRecord({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.createdAt,
    this.done = false,
  });

  final String id;
  final String ownerId;
  final DateTime createdAt;
  String title;
  bool done;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'done': done,
    'created_at': createdAt.toUtc().toIso8601String(),
  };
}

class InMemoryStore {
  final _random = Random.secure();
  final _usersByEmail = <String, UserRecord>{};
  final _sessions = <String, String>{};
  final _tasks = <String, TaskRecord>{};

  UserRecord? findUserByEmail(String email) => _usersByEmail[_normalize(email)];

  UserRecord? findUserByToken(String token) {
    final userId = _sessions[token];
    if (userId == null) return null;
    for (final user in _usersByEmail.values) {
      if (user.id == userId) return user;
    }
    return null;
  }

  UserRecord createUser({
    required String name,
    required String email,
    required String password,
  }) {
    final salt = _randomToken(16);
    final user = UserRecord(
      id: _randomToken(8),
      name: name.trim(),
      email: _normalize(email),
      passwordHash: _hash(password, salt),
      salt: salt,
    );
    _usersByEmail[user.email] = user;
    return user;
  }

  bool checkPassword(UserRecord user, String password) =>
      _hash(password, user.salt) == user.passwordHash;

  String openSession(UserRecord user) {
    final token = _randomToken(32);
    _sessions[token] = user.id;
    return token;
  }

  void closeSession(String token) => _sessions.remove(token);

  List<TaskRecord> tasksOf(String ownerId) =>
      _tasks.values.where((task) => task.ownerId == ownerId).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  TaskRecord? taskOf(String ownerId, String taskId) {
    final task = _tasks[taskId];
    return task?.ownerId == ownerId ? task : null;
  }

  TaskRecord createTask(String ownerId, String title) {
    final task = TaskRecord(
      id: _randomToken(8),
      ownerId: ownerId,
      title: title.trim(),
      createdAt: DateTime.now(),
    );
    _tasks[task.id] = task;
    return task;
  }

  void deleteTask(String taskId) => _tasks.remove(taskId);

  void reset() {
    _usersByEmail.clear();
    _sessions.clear();
    _tasks.clear();
  }

  String _normalize(String email) => email.trim().toLowerCase();

  String _hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  String _randomToken(int bytes) => List.generate(
    bytes,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}
