
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';
import '../models/todo_model.dart';
import '../utils/app_theme.dart';

class AddTodoSheet extends StatefulWidget {
  final TodoModel? existingTodo;

  const AddTodoSheet({super.key, this.existingTodo});

  @override
  State<AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<AddTodoSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  TodoPriority _priority = TodoPriority.medium;
  TodoCategory _category = TodoCategory.personal;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    if (widget.existingTodo != null) {
      _titleController.text = widget.existingTodo!.title;
      _descController.text = widget.existingTodo!.description ?? '';
      _priority = widget.existingTodo!.priority;
      _category = widget.existingTodo!.category;
      _dueDate = widget.existingTodo!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Title দাও!', style: GoogleFonts.poppins()),
          backgroundColor: AppTheme.accentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final todo = widget.existingTodo?.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
          priority: _priority,
          category: _category,
          dueDate: _dueDate,
        ) ??
        TodoModel(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
          priority: _priority,
          category: _category,
          createdAt: DateTime.now(),
          dueDate: _dueDate,
        );

    Navigator.pop(context, todo);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.existingTodo != null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(20),

            Text(
              isEditing ? 'Edit' : '✨ New Task',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),

            const Gap(20),

            // Title
            TextField(
              controller: _titleController,
              autofocus: !isEditing,
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Task Name',
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                prefixIcon: const Icon(Icons.title_rounded, color: AppTheme.primaryColor),
              ),
            ).animate().fadeIn(delay: 100.ms),

            const Gap(12),

            // Description
            TextField(
              controller: _descController,
              maxLines: 2,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Task Details (optional)...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                prefixIcon: const Icon(Icons.notes_rounded, color: AppTheme.primaryColor),
              ),
            ).animate().fadeIn(delay: 150.ms),

            const Gap(20),

            // Priority
            Text('Priority', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
            const Gap(10),
            Row(
              children: TodoPriority.values.map((p) {
                final isSelected = _priority == p;
                final color = p == TodoPriority.high
                    ? AppTheme.accentColor
                    : p == TodoPriority.medium
                        ? const Color(0xFFFFA940)
                        : AppTheme.secondaryColor;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? color : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          p.name[0].toUpperCase() + p.name.substring(1),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                            color: isSelected ? color : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 200.ms),

            const Gap(20),

            // Category
            Text('Category', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
            const Gap(10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: TodoCategory.values.map((c) {
                  final isSelected = _category == c;
                  return GestureDetector(
                    onTap: () => setState(() => _category = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryColor : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        c.name[0].toUpperCase() + c.name.substring(1),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          color: isSelected ? AppTheme.primaryColor : Colors.grey,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ).animate().fadeIn(delay: 250.ms),

            const Gap(20),

            // Due Date
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.primaryColor),
                    ),
                    child: child!,
                  ),
                );
                if (date != null) setState(() => _dueDate = date);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: _dueDate != null
                      ? Border.all(color: AppTheme.primaryColor.withOpacity(0.5), width: 1.5)
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      color: _dueDate != null ? AppTheme.primaryColor : Colors.grey,
                      size: 20,
                    ),
                    const Gap(12),
                    Text(
                      _dueDate != null
                          ? 'Due: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                          : 'Add Due date (optional)',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _dueDate != null ? AppTheme.primaryColor : Colors.grey,
                        fontWeight: _dueDate != null ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    if (_dueDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _dueDate = null),
                        child: const Icon(Icons.close_rounded, color: Colors.grey, size: 18),
                      ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),

            const Gap(28),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(
                  isEditing ? 'Update Task' : 'Add Task',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }
}
