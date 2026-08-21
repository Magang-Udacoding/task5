import 'package:flutter/material.dart';

import '../models/task_filter.dart';

class TaskFilterBar extends StatelessWidget {
  final TaskFilter selectedFilter;
  final ValueChanged<TaskFilter> onFilterChanged;
  const TaskFilterBar(
      {super.key, required this.selectedFilter, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FilterButton(
            label: 'Semua',
            isSelected: selectedFilter == TaskFilter.all,
            onTap: () {
              onFilterChanged(TaskFilter.all);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _FilterButton(
            label: 'Aktif',
            isSelected: selectedFilter == TaskFilter.active,
            onTap: () {
              onFilterChanged(TaskFilter.active);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _FilterButton(
            label: 'Selesai',
            isSelected: selectedFilter == TaskFilter.completed,
            onTap: () {
              onFilterChanged(TaskFilter.completed);
            },
          ),
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterButton(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFF5B5FEF) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 11,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF5B5FEF)
                  : const Color(0xFFE7E9F0),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF74788A),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
