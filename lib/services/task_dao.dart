import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import 'package:task_management_app/utils/date_extensions.dart';

class TaskDao {
  static const _boxName = 'tasksBox';
  late Box<Task> _box;

  // Factory constructor that initializes asynchronously
  static Future<TaskDao> create() async {
    final dao = TaskDao._internal();
    await dao._init();
    return dao;
  }

  TaskDao._internal();

  Future<void> _init() async {
    _box = await Hive.openBox<Task>(_boxName);
  }

  Future<Task> createTask(Task task) async {
    // Simulate 2-second delay
    await Future.delayed(const Duration(seconds: 2));
    final taskId = task.id.isEmpty ? Uuid().v4() : task.id;
    final newTask = task.copyWith(id: taskId);
    await _box.put(taskId, newTask);
    return newTask;
  }

  List<Task> getAllTasks() {
    return _box.values.toList();
  }

  Task? getTaskById(String id) {
    return _box.get(id);
  }

  Future<void> updateTask(Task task) async {
    // Simulate 2-second delay
    await Future.delayed(const Duration(seconds: 2));
    await _box.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }

  List<Task> get tasks => _box.values.toList();

  String blockingTaskStatus(String? blockedById) {
    if (blockedById == null) return TaskStatus.todo.displayName;
    final blockingTask = _box.get(blockedById);
    return blockingTask?.status?.displayName ?? TaskStatus.todo.displayName;
  }

  bool isTaskBlocked(String? blockedById) {
    return blockedById != null &&
           _box.get(blockedById)?.status != TaskStatus.done;
  }
}