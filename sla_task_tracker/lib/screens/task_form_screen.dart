import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/task_priority.dart';
import '../models/team_member.dart';
import '../services/data_store.dart';
import '../theme/app_colors.dart';
import '../utils/date_utils.dart';
import '../utils/validators.dart';

/// Shared screen for both creating a new task and editing an existing one.
/// Pass [existingTask] to edit; leave it null to create.
class TaskFormScreen extends StatefulWidget {
  final Task? existingTask;
  const TaskFormScreen({super.key, this.existingTask});

  bool get isEditing => existingTask != null;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _categoryController;
  late final TextEditingController _descriptionController;

  DateTime? _startDate;
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.medium;
  TeamMember? _assignee;
  bool _submitting = false;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTask;
    _titleController = TextEditingController(text: t?.title ?? '');
    _categoryController = TextEditingController(text: t?.category ?? '');
    _descriptionController = TextEditingController(text: t?.description ?? '');
    _startDate = t?.startDate ?? DateTime.now();
    _dueDate = t?.dueDate ?? DateTime.now().add(const Duration(days: 3));
    _priority = t?.priority ?? TaskPriority.medium;

    final members = DataStore.instance.members;
    if (t != null) {
      _assignee = DataStore.instance.memberById(t.assigneeId);
    }
    _assignee ??= members.isNotEmpty ? members.first : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? (_startDate ?? DateTime.now()) : (_dueDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _dueDate = picked;
      }
      _dateError = Validators.dueAfterStart(_startDate, _dueDate);
    });
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    final dateError = Validators.dueAfterStart(_startDate, _dueDate);
    setState(() => _dateError = dateError);

    if (!formValid || dateError != null) return;

    if (_assignee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a lead assignee to continue.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      if (widget.isEditing) {
        final updated = widget.existingTask!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _categoryController.text.trim(),
          startDate: _startDate,
          dueDate: _dueDate,
          priority: _priority,
          assigneeId: _assignee!.id,
        );
        await DataStore.instance.updateTask(updated);
      } else {
        await DataStore.instance.createTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _categoryController.text.trim(),
          startDate: _startDate!,
          dueDate: _dueDate!,
          priority: _priority,
          assigneeId: _assignee!.id,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.isEditing ? 'Task updated.' : 'Task created.')),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the task. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = DataStore.instance.members;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Task' : 'Create Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: [
              const _FieldLabel('Task title', required: true),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'Enter a clear task title'),
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.requiredText(v, field: 'Task title'),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Category / Project tag'),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(hintText: 'e.g. Security Audit Q4'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Description'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Add context, requirements, and expected outcomes...',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('Start date'),
                        _DatePickerField(
                          date: _startDate,
                          onTap: () => _pickDate(isStart: true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('Due date', required: true),
                        _DatePickerField(
                          date: _dueDate,
                          onTap: () => _pickDate(isStart: false),
                          hasError: _dateError != null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_dateError != null) ...[
                const SizedBox(height: 6),
                Text(_dateError!, style: const TextStyle(color: AppColors.overdue, fontSize: 12)),
              ],
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Priority & SLA',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text('Required', style: TextStyle(color: AppColors.overdue, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.3,
                children: [
                  for (final p in TaskPriority.values)
                    _PriorityOption(
                      priority: p,
                      selected: _priority == p,
                      onTap: () => setState(() => _priority = p),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textMuted),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'SLA tracking begins immediately once the task is created. '
                        'A task flips to "At Risk" once it is inside its priority\'s '
                        'response window, and "Overdue" once the due date passes.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Resource Allocation',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(
                    '${members.length} available',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const _FieldLabel('Lead assignee', required: true),
              DropdownButtonFormField<TeamMember>(
                initialValue: _assignee,
                isExpanded: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                ),
                items: [
                  for (final m in members)
                    DropdownMenuItem(value: m, child: Text(m.name)),
                ],
                onChanged: (v) => setState(() => _assignee = v),
                validator: (v) => v == null ? 'Select a lead assignee' : null,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _submitting ? null : _submit,
                      icon: _submitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Icon(widget.isEditing ? Icons.save_outlined : Icons.add_rounded, size: 18),
                      label: Text(widget.isEditing ? 'Save Changes' : 'Create Task'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  const _FieldLabel(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 2),
      child: Row(
        children: [
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
          if (required)
            const Padding(
              padding: EdgeInsets.only(left: 3),
              child: Text('*', style: TextStyle(color: AppColors.overdue)),
            ),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onTap;
  final bool hasError;

  const _DatePickerField({required this.date, required this.onTap, this.hasError = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: hasError ? AppColors.overdue : AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date == null ? 'Select date' : AppDateUtils.formatDate(date!),
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityOption extends StatelessWidget {
  final TaskPriority priority;
  final bool selected;
  final VoidCallback onTap;

  const _PriorityOption({required this.priority, required this.selected, required this.onTap});

  IconData get _icon {
    switch (priority) {
      case TaskPriority.low:
        return Icons.arrow_downward_rounded;
      case TaskPriority.medium:
        return Icons.remove_rounded;
      case TaskPriority.high:
        return Icons.arrow_upward_rounded;
      case TaskPriority.critical:
        return Icons.bolt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primaryDark : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(_icon, size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 5),
                Text(priority.label,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                const Spacer(),
                if (selected)
                  const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primaryDark),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              priority.responseLabel,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
