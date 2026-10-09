import 'package:flutter/material.dart';
import '../models/sla_status.dart';
import '../models/task.dart';
import '../services/data_store.dart';
import '../services/sla_calculator.dart';
import '../theme/app_colors.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_card.dart';
import 'task_details_screen.dart';
import 'task_form_screen.dart';

enum _FilterOption { all, onTrack, atRisk, overdue, completed }

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  _FilterOption _filter = _FilterOption.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Task> get _filteredTasks {
    final store = DataStore.instance;
    Iterable<Task> result = store.tasks;

    switch (_filter) {
      case _FilterOption.all:
        break;
      case _FilterOption.onTrack:
        result = result.where((t) => SlaCalculator.statusFor(t) == SlaStatus.onTrack);
        break;
      case _FilterOption.atRisk:
        result = result.where((t) => SlaCalculator.statusFor(t) == SlaStatus.atRisk);
        break;
      case _FilterOption.overdue:
        result = result.where((t) => SlaCalculator.statusFor(t) == SlaStatus.overdue);
        break;
      case _FilterOption.completed:
        result = result.where((t) => t.isCompleted);
        break;
    }

    if (_query.trim().isNotEmpty) {
      final q = _query.trim().toLowerCase();
      result = result.where((t) =>
          t.title.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q) ||
          t.id.toLowerCase().contains(q));
    }

    final list = result.toList();
    // Most urgent first: overdue > at risk > on track > completed, then by due date.
    int rank(Task t) {
      switch (SlaCalculator.statusFor(t)) {
        case SlaStatus.overdue:
          return 0;
        case SlaStatus.atRisk:
          return 1;
        case SlaStatus.onTrack:
          return 2;
        case SlaStatus.completed:
          return 3;
      }
    }

    list.sort((a, b) {
      final r = rank(a).compareTo(rank(b));
      if (r != 0) return r;
      return a.dueDate.compareTo(b.dueDate);
    });
    return list;
  }

  Future<void> _openTask(Task task) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskDetailsScreen(taskId: task.id)),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openCreateTask() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TaskFormScreen()),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final store = DataStore.instance;
    final tasks = _filteredTasks;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Tasks'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                store.currentUser?.team ?? 'All projects',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Search tasks',
                      prefixIcon: Icon(Icons.search_rounded, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _SquareIconButton(
                  icon: Icons.tune_rounded,
                  onTap: () => _showSortSheet(context),
                ),
                const SizedBox(width: 8),
                _SquareIconButton(
                  icon: Icons.add_rounded,
                  filled: true,
                  onTap: _openCreateTask,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'All ${store.totalCount}',
                  selected: _filter == _FilterOption.all,
                  onTap: () => setState(() => _filter = _FilterOption.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'On Track',
                  selected: _filter == _FilterOption.onTrack,
                  onTap: () => setState(() => _filter = _FilterOption.onTrack),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'At Risk',
                  selected: _filter == _FilterOption.atRisk,
                  onTap: () => setState(() => _filter = _FilterOption.atRisk),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Overdue',
                  selected: _filter == _FilterOption.overdue,
                  onTap: () => setState(() => _filter = _FilterOption.overdue),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Completed',
                  selected: _filter == _FilterOption.completed,
                  onTap: () => setState(() => _filter = _FilterOption.completed),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: tasks.isEmpty
                ? ListView(
                    children: [
                      EmptyState(
                        icon: Icons.inbox_outlined,
                        title: store.totalCount == 0 ? 'No tasks yet' : 'No matching tasks',
                        message: store.totalCount == 0
                            ? 'Create your first task to start tracking SLA status.'
                            : 'Try a different search term or filter.',
                        action: store.totalCount == 0
                            ? ElevatedButton.icon(
                                onPressed: _openCreateTask,
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const Text('Create Task'),
                              )
                            : null,
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final task = tasks[i];
                      return TaskCard(
                        task: task,
                        assignee: store.memberById(task.assigneeId),
                        onTap: () => _openTask(task),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sorting', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              SizedBox(height: 10),
              Text(
                'Tasks are automatically sorted by urgency: Overdue, then At '
                'Risk, then On Track, then Completed — and by closest due '
                'date within each group.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _SquareIconButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? AppColors.primaryDark : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: filled ? Colors.white : AppColors.textPrimary, size: 22),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDark : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primaryDark : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
