
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../models/todo_model.dart';
import '../utils/app_theme.dart';

class TodoCard extends StatelessWidget {
  final TodoModel todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final int index;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
    required this.index,
  });

  Color _getPriorityColor() {
    switch (todo.priority) {
      case TodoPriority.high:
        return AppTheme.accentColor;
      case TodoPriority.medium:
        return const Color(0xFFFFA940);
      case TodoPriority.low:
        return AppTheme.secondaryColor;
    }
  }

  String _getPriorityLabel() {
    switch (todo.priority) {
      case TodoPriority.high:
        return 'High';
      case TodoPriority.medium:
        return 'Medium';
      case TodoPriority.low:
        return 'Low';
    }
  }

  IconData _getCategoryIcon() {
    switch (todo.category) {
      case TodoCategory.work:
        return Icons.work_outline_rounded;
      case TodoCategory.shopping:
        return Icons.shopping_bag_outlined;
      case TodoCategory.health:
        return Icons.favorite_outline_rounded;
      case TodoCategory.other:
        return Icons.category_outlined;
      case TodoCategory.personal:
        return Icons.person_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = _getPriorityColor();

    return Animate(
      effects: [
        FadeEffect(delay: (index * 50).ms, duration: 400.ms),
        SlideEffect(delay: (index * 50).ms, duration: 400.ms, begin: const Offset(0.1, 0)),
      ],
      child: Dismissible(
        key: Key(todo.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: AppTheme.accentColor, size: 28),
        ),
        confirmDismiss: (_) async {
          return await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Do you want to delete it?', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              content: Text(
                '"${todo.title}" Do You Want To Delete?',
                style: GoogleFonts.poppins(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('No', style: GoogleFonts.poppins(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
                  child: Text('Yes, delete IT', style: GoogleFonts.poppins()),
                ),
              ],
            ),
          );
        },
        onDismissed: (_) => onDelete(),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: todo.isCompleted
                    ? Colors.transparent
                    : priorityColor.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : priorityColor.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Checkbox
                  GestureDetector(
                    onTap: onToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: todo.isCompleted ? AppTheme.primaryColor : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: todo.isCompleted ? AppTheme.primaryColor : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: todo.isCompleted
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                          : null,
                    ),
                  ),

                  const Gap(14),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todo.title,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                            color: todo.isCompleted ? Colors.grey : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (todo.description != null && todo.description!.isNotEmpty) ...[
                          const Gap(4),
                          Text(
                            todo.description!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const Gap(10),
                        Row(
                          children: [
                            // Category icon
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(_getCategoryIcon(), size: 12, color: AppTheme.primaryColor),
                                  const Gap(4),
                                  Text(
                                    todo.category.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(8),
                            // Priority badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getPriorityLabel(),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: priorityColor,
                                ),
                              ),
                            ),
                            if (todo.dueDate != null) ...[
                              const Gap(8),
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 11,
                                color: _isDueOverdue() ? AppTheme.accentColor : Colors.grey,
                              ),
                              const Gap(3),
                              Text(
                                DateFormat('dd MMM').format(todo.dueDate!),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: _isDueOverdue() ? AppTheme.accentColor : Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Right arrow
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.withOpacity(0.5),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isDueOverdue() {
    if (todo.dueDate == null || todo.isCompleted) return false;
    return todo.dueDate!.isBefore(DateTime.now());
  }
}
