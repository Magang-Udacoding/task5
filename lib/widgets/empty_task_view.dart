import 'package:flutter/material.dart';

class EmptyTaskView extends StatelessWidget {
  final String title;
  final String description;

  const EmptyTaskView({
    super.key,
    this.title = 'Empty task',
    this.description = 'Add new task.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 36,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFEDEEFF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.checklist_rounded,
                size: 36,
                color: Color(0xFF5B5FEF),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B1D2A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF74788A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
