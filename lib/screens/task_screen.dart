import 'package:flutter/material.dart';
import 'package:task5/screens/task_detail_screen.dart';
import 'package:task5/services/task_storage.dart';
import 'package:task5/widgets/bounce_fab.dart';
import 'package:task5/widgets/task_skeleton.dart';

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

  final GlobalKey<AnimatedListState> _animatedListKey =
      GlobalKey<AnimatedListState>();

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
      floatingActionButton: _isLoading
          ? null
          : BounceFab(
              onPressed: () {
                if (_taskController.text.trim().isNotEmpty) {
                  _addTask();
                } else {
                  _focusTaskInput();
                }
              },
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
    return const TaskSkeletonList();
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
    final filteredTasks = _filteredTasks;

    if (filteredTasks.isEmpty) {
      return _buildFilteredEmptyState();
    }

    return AnimatedList(
      key: _animatedListKey,
      padding: const EdgeInsets.fromLTRB(
        20,
        10,
        20,
        20,
      ),
      initialItemCount: filteredTasks.length,
      itemBuilder: (
        context,
        index,
        animation,
      ) {
        final task = filteredTasks[index];

        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return SizeTransition(
          sizeFactor: curvedAnimation,
          axisAlignment: 0.0,
          child: FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.4),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: Dismissible(
                key: ValueKey(task.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) async {
                  final confirmed = await _confirmDelete(task);

                  if (confirmed) {
                    await _deleteTask(task.id);
                  }

                  return false;
                },
                background: _buildDeleteBackground(),
                child: _buildTaskItem(task),
              ),
            ),
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
        crossAxisAlignment: CrossAxisAlignment.center,
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
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _addTask();
              },
              child: Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B5FEF),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5B5FEF).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 28,
                ),
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


  Widget _buildTaskItem(Task task) {
    return Hero(
      tag: 'task-${task.id}',
      child: TaskCard(
        task: task,
        onChanged: (value) {
          _toggleTask(task.id);
        },
        onTap: () {
          _openTaskDetail(task);
        },
      ),
    );
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

    // Switch filter to 'all' if user is currently on 'completed' tab so the new task is shown
    if (_currentFilter == TaskFilter.completed) {
      _currentFilter = TaskFilter.all;
    }

    final wasEmpty = _filteredTasks.isEmpty;

    setState(() {
      _tasks.insert(0, task);
    });

    if (!wasEmpty) {
      _animatedListKey.currentState?.insertItem(
        0,
        duration: const Duration(
          milliseconds: 350,
        ),
      );
    }

    await _taskStorage.saveTasks(_tasks);

    _taskController.clear();
    _taskFocusNode.unfocus();
  }

  Future<void> _deleteTask(String taskId) async {
    final filteredTasks = List<Task>.from(_filteredTasks);

    final index = filteredTasks.indexWhere(
      (task) => task.id == taskId,
    );

    if (index == -1) {
      return;
    }

    final removedTask = filteredTasks[index];

    setState(() {
      _tasks.removeWhere(
        (task) => task.id == taskId,
      );
    });

    _animatedListKey.currentState?.removeItem(
      index,
      (
        context,
        animation,
      ) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );

        return SizeTransition(
          sizeFactor: curvedAnimation,
          axisAlignment: 0.0,
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.75,
                end: 1.0,
              ).animate(curvedAnimation),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1.0),
                  end: Offset.zero,
                ).animate(curvedAnimation),
                child: _buildTaskItem(
                  removedTask,
                ),
              ),
            ),
          ),
        );
      },
      duration: const Duration(
        milliseconds: 450,
      ),
    );

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

    await Future.delayed(const Duration(milliseconds: 600));

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

  void _openTaskDetail(Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(task: task),
      ),
    );
  }
}
