import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onChanged,
    this.onTap,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _checkboxController;

  late final Animation<double> _checkboxScale;

  @override
  void initState() {
    super.initState();

    _checkboxController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );

    _checkboxScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0).chain(
          CurveTween(curve: Curves.elasticOut),
        ),
        weight: 60,
      ),
    ]).animate(_checkboxController);
  }

  @override
  void didUpdateWidget(
    covariant TaskCard oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.task.isCompleted != widget.task.isCompleted) {
      _checkboxController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _checkboxController.dispose();
    super.dispose();
  }

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
    final isCompleted = widget.task.isCompleted;

    final titleColor =
        isCompleted ? const Color(0xFF9B9EAA) : const Color(0xFF1B1D2A);

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFFF8F8FA) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted
                    ? const Color(0xFFD4D7E0)
                    : const Color(0xFFE7E9F0),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                ScaleTransition(
                  scale: _checkboxScale,
                  child: Checkbox(
                    value: isCompleted,
                    onChanged: widget.onChanged,
                    activeColor: const Color(0xFF5B5FEF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: titleColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_outlined,
                            size: 14,
                            color: Color(
                              0xFF8A8E9D,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _formatDate(
                              widget.task.createdAt,
                            ),
                            style: const TextStyle(
                              color: Color(
                                0xFF8A8E9D,
                              ),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  Container(
                    margin: const EdgeInsets.only(
                      left: 10,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFE7F7F0,
                      ),
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Color(
                          0xFF2C9A6C,
                        ),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
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
}
