import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management_app/services/task_dao.dart';
import 'package:task_management_app/models/task.dart';
import 'package:task_management_app/widgets/task_card.dart';
import 'package:task_management_app/screens/task_form_screen.dart';
import 'package:task_management_app/services/debouncer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Debouncer _searchDebouncer = Debouncer(milliseconds: 300);
  String _searchQuery = '';
  String? _selectedStatusFilter;
  List<Task> _filteredTasks = [];

  @override
  void initState() {
    super.initState();
    _filteredTasks = [];
    _searchDebouncer.run(() {
      // Debounced search will update here
    });
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskDao = Provider.of<TaskDao>(context);
    final allTasks = taskDao.tasks;

    // Filter tasks based on search and status
    _filteredTasks = allTasks.where((task) {
      // Search filter (case insensitive)
      final matchesSearch = _searchQuery.isEmpty ||
          task.title.toLowerCase().contains(_searchQuery.toLowerCase());

      // Status filter
      final matchesStatus = _selectedStatusFilter == null ||
          task.status.displayName == _selectedStatusFilter;

      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TaskFormScreen(),
                ),
              );
              // Refresh after returning from form
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterBar(),
          Expanded(
            child: _filteredTasks.isEmpty
                ? const Center(
                    child: Text('No tasks found. Add a new task to get started!'),
                  )
                : ListView.builder(
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = _filteredTasks[index];
                      final isBlocked = taskDao.isTaskBlocked(task.blockedById);
                      return TaskCard(
                        task: task,
                        isBlocked: isBlocked,
                        onTaskTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TaskFormScreen(task: task),
                            ),
                          );
                          setState(() {});
                        },
                        onDelete: () async {
                          await taskDao.deleteTask(task.id);
                          setState(() {});
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search tasks by title...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) {
          _searchDebouncer.run(() {
            if (mounted) {
              setState(() {
                _searchQuery = value;
              });
            }
          });
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DropdownButtonFormField<String?>(
        value: _selectedStatusFilter,
        decoration: InputDecoration(
          labelText: 'Filter by Status',
          prefixIcon: const Icon(Icons.filter_list),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: [
          DropdownMenuItem<String?>(
            value: null,
            child: const Text('All Status'),
          ),
          DropdownMenuItem<String?>(
            value: 'To-Do',
            child: const Text('To-Do'),
          ),
          DropdownMenuItem<String?>(
            value: 'In Progress',
            child: const Text('In Progress'),
          ),
          DropdownMenuItem<String?>(
            value: 'Done',
            child: const Text('Done'),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _selectedStatusFilter = value;
          });
        },
      ),
    );
  }
}