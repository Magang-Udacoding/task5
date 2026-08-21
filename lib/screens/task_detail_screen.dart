import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({
    super.key,
    required this.task,
  });

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');

    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year • $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Task Detail'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Hero(
            tag: 'task-${task.id}',
            createRectTween: (
              begin,
              end,
            ) {
              return MaterialRectArcTween(
                begin: begin,
                end: end,
              );
            },
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFE7E9F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFEDEEFF,
                        ),
                        borderRadius: BorderRadius.circular(
                          16,
                        ),
                      ),
                      child: const Icon(
                        Icons.task_alt,
                        color: Color(
                          0xFF5B5FEF,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(
                          0xFF1B1D2A,
                        ),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_outlined,
                          size: 18,
                          color: Color(
                            0xFF74788A,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Created ${_formatDate(task.createdAt)}',
                          style: const TextStyle(
                            color: Color(
                              0xFF74788A,
                            ),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? const Color(
                                0xFFE7F7F0,
                              )
                            : const Color(
                                0xFFEDEEFF,
                              ),
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: Text(
                        task.isCompleted ? 'Completed' : 'Active',
                        style: TextStyle(
                          color: task.isCompleted
                              ? const Color(
                                  0xFF2C9A6C,
                                )
                              : const Color(
                                  0xFF5B5FEF,
                                ),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
