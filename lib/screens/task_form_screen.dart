import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management_app/models/task.dart';
import 'package:task_management_app/services/task_dao.dart';
import 'package:task_management_app/utils/date_extensions.dart';
import 'package:uuid/uuid.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TaskStatus _selectedStatus;
  String? _selectedBlockedById;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
        text: widget.task?.description ?? '');
    _selectedDate = widget.task?.dueDate ?? DateTime.now();
    _selectedStatus = widget.task?.status ?? TaskStatus.todo;
    _selectedBlockedById = widget.task?.blockedById;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final taskDao = Provider.of<TaskDao>(context);
    final availableTasks = _getAvailableBlockedByTasks(taskDao);

    // Validate: selectedBlockedById must exist in available tasks, else reset to null
    if (_selectedBlockedById != null &&
        !availableTasks.any((task) => task.id == _selectedBlockedById)) {
      setState(() {
        _selectedBlockedById = null;
      });
    }
  }

  List<Task> _getAvailableBlockedByTasks(TaskDao taskDao) {
    final allTasks = taskDao.tasks;
    // Deduplicate by task ID and exclude current task
    final taskMap = <String, Task>{};
    for (var task in allTasks) {
      if (task.id != widget.task?.id) {
        taskMap[task.id] = task; // Last duplicate wins (unlikely)
      }
    }
    return taskMap.values.toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _saveDraft();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskDao = Provider.of<TaskDao>(context);

    return WillPopScope(
      onWillPop: () async {
        await _saveDraft();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.task == null ? 'Create Task' : 'Edit Task'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDatePicker(),
                      const SizedBox(height: 16),
                      _buildStatusDropdown(),
                      const SizedBox(height: 16),
                      _buildBlockedByDropdown(taskDao),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => _isLoading = true);

                                  final task = Task(
                                    id: widget.task?.id ?? '',
                                    title: _titleController.text,
                                    description: _descriptionController.text,
                                    dueDate: _selectedDate,
                                    status: _selectedStatus,
                                    blockedById: _selectedBlockedById,
                                  );

                                  try {
                                    if (widget.task == null) {
                                      await taskDao.createTask(task);
                                    } else {
                                      await taskDao.updateTask(task);
                                    }

                                    if (mounted) {
                                      Navigator.pop(context);
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text('Error: $e')),
                                      );
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isLoading = false);
                                    }
                                  }
                                }
                              },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            widget.task == null ? 'Create Task' : 'Update Task',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Due Date',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          _selectedDate.formattedDate,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<TaskStatus>(
      value: _selectedStatus,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
      ),
      items: TaskStatus.values
          .map(
            (status) => DropdownMenuItem(
              value: status,
              child: Text(status.displayName),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedStatus = value;
          });
        }
      },
    );
  }

  Widget _buildBlockedByDropdown(TaskDao taskDao) {
    final availableTasks = _getAvailableBlockedByTasks(taskDao);

    return DropdownButtonFormField<String?>(
      value: _selectedBlockedById,
      decoration: const InputDecoration(
        labelText: 'Blocked By (Optional)',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('None'),
        ),
        ...availableTasks.map(
          (task) => DropdownMenuItem<String?>(
            value: task.id,
            child: Text(
              task.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedBlockedById = value;
        });
      },
    );
  }

  Future<void> _saveDraft() async {
    // Save current form state for restoration
  }
}