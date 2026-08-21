import 'package:flutter/material.dart';
import 'package:task5/services/task_storage.dart';

import '../models/task.dart';
import '../widgets/empty_task_view.dart';
import '../widgets/task_cart.dart';
import '../models/task_filter.dart';
import '../widgets/task_filter.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  Future<bool> _confirmDelete(Task task) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Hapus task?',
          ),
          content: Text(
            'Apakah task "${task.title}" ingin dihapus?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Batal',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD64545),
              ),
              child: const Text('Hapus'),
            )
          ],
        );
      },
    );
    return result ?? false;
  }

  final TextEditingController _taskController = TextEditingController();

  final FocusNode _taskFocusNode = FocusNode();

  final List<Task> _tasks = [];
  TaskFilter _currentFilter = TaskFilter.all;

  final TaskStorage _taskStorage = TaskStorage();
  bool _isLoading = true;

  List<Task> get _filteredTasks {
    switch (_currentFilter) {
      case TaskFilter.all:
        return _tasks;
      case TaskFilter.active:
        return _tasks
            .where(
              (task) => !task.isCompleted,
            )
            .toList();
      case TaskFilter.completed:
        return _tasks
            .where(
              (task) => task.isCompleted,
            )
            .toList();
    }
  }

  @override
  void initState() {
    super.initState();

    debugPrint('TaskScreen: initState');
    _loadTasks();
  }

  @override
  void dispose() {
    debugPrint('TaskScreen: dispose');

    _taskController.dispose();
    _taskFocusNode.dispose();

    super.dispose();
  }

  int get _completedCount {
    return _tasks.where((task) => task.isCompleted).length;
  }

  int get _remainingCount {
    return _tasks.length - _completedCount;
  }

  double get _progress {
    if (_tasks.isEmpty) {
      return 0;
    }

    return _completedCount / _tasks.length;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('TaskScreen: build');

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : Column(
                children: [
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: TaskFilterBar(
                      selectedFilter: _currentFilter,
                      onFilterChanged: (filter) {
                        setState(() {
                          _currentFilter = filter;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildTaskArea(),
                  ),
                  _buildComposer(),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _focusTaskInput,
        tooltip: 'Tambah tugas',
        backgroundColor: const Color(0xFF5B5FEF),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        24,
        24,
        18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GOOD MORNING',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: Color(0xFF74788A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'What are we finishing today?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B1D2A),
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 18),
          _buildSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF5B5FEF),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final total = _tasks.length;
    final completed = _completedCount;
    final remaining = _remainingCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5B5FEF),
            Color(0xFF7B7FF5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR PROGRESS',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            total == 0
                ? 'Ready for your first task'
                : '$remaining tasks remaining',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            total == 0
                ? 'Add your first task to get started.'
                : '$completed of $total tasks completed',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 7,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskArea() {
    final filteredTask = _filteredTasks;

    if (filteredTask.isEmpty) {
      return _buildFilteredEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        20,
        10,
        20,
        20,
      ),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];

        return Dismissible(
          key: ValueKey(task.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            return _confirmDelete(task);
          },
          onDismissed: (_) {
            _deleteTask(task.id);
          },
          background: _buildDeleteBackground(),
          child: TaskCard(
            task: task,
            onChanged: (value) {
              _toggleTask(task.id);
            },
          ),
        );
      },
    );
  }

  Widget _buildComposer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _taskController,
              focusNode: _taskFocusNode,
              textInputAction: TextInputAction.done,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tulis task baru...',
                prefixIcon: Icon(
                  Icons.edit_outlined,
                ),
              ),
              onSubmitted: (_) {
                _addTask();
              },
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF5B5FEF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: IconButton(
              onPressed: _addTask,
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.only(
        right: 24,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFD64545),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.centerRight,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.delete_outline,
            color: Colors.white,
          ),
          SizedBox(width: 8),
          Text(
            'Hapus',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredEmptyState() {
    switch (_currentFilter) {
      case TaskFilter.all:
        return const EmptyTaskView(
          title: 'Belum ada tugas',
          description: 'Tambahkan sesuatu yang ingin kamu selesaikan hari ini',
        );
      case TaskFilter.active:
        return const EmptyTaskView(
          title: 'Tidak ada tugas aktif',
          description: 'Semua tugas sudah selesai',
        );
      case TaskFilter.completed:
        return const EmptyTaskView(
          title: 'Belum ada tugas selesai',
          description: 'Selesaikan tugas untuk melihatnya disini',
        );
    }
  }

  Future<void> _addTask() async {
    final title = _taskController.text.trim();

    if (title.isEmpty) {
      _showValidationMessage();
      return;
    }

    final task = Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      createdAt: DateTime.now(),
    );

    setState(() {
      _tasks.insert(0, task);
    });

    await _taskStorage.saveTasks(_tasks);

    _taskController.clear();
    _taskFocusNode.unfocus();
  }

  Future<void> _deleteTask(String taskId) async {
    setState(() {
      _tasks.removeWhere(
        (task) => task.id == taskId,
      );
    });

    await _taskStorage.saveTasks(_tasks);
  }

  Future<void> _toggleTask(
    String taskId,
  ) async {
    final index = _tasks.indexWhere(
      (task) => task.id == taskId,
    );

    if (index == -1) {
      return;
    }

    setState(() {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(
        isCompleted: !task.isCompleted,
      );
    });
    await _taskStorage.saveTasks(_tasks);
  }

  void _showValidationMessage() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Task tidak boleh kosong',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _loadTasks() async {
    final savedTasks = await _taskStorage.loadTasks();

    if (!mounted) {
      return;
    }

    setState(() {
      _tasks
        ..clear()
        ..addAll(savedTasks);

      _isLoading = false;
    });
  }

  void _focusTaskInput() {
    _taskFocusNode.requestFocus();
  }
}
