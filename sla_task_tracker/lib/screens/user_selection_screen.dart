import 'package:flutter/material.dart';
import '../models/team_member.dart';
import '../services/data_store.dart';
import '../theme/app_colors.dart';
import 'main_shell.dart';

class UserSelectionScreen extends StatefulWidget {
  final String email;
  final bool rememberMe;

  const UserSelectionScreen({
    super.key,
    required this.email,
    required this.rememberMe,
  });

  @override
  State<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  List<TeamMember> _members = const [];
  TeamMember? _selectedMember;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final member = await DataStore.instance.findOrCreateMember(widget.email);
    if (!mounted) return;
    setState(() {
      _members = DataStore.instance.members;
      _selectedMember = member;
    });
  }

  Future<void> _continue() async {
    final member = _selectedMember;
    if (member == null) return;

    setState(() => _submitting = true);
    try {
      await DataStore.instance.signIn(member, remember: widget.rememberMe);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Could not complete sign in. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose your profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Who are you?',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select the demo team member you want to use for this session.',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 22),
              Expanded(
                child: _members.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                  itemCount: _members.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final member = _members[index];
                    final selected = member.id == _selectedMember?.id;
                    return Material(
                      color:
                          selected ? AppColors.completedBg : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: _submitting
                            ? null
                            : () => setState(() => _selectedMember = member),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primaryDark
                                  : AppColors.border,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: member.avatarColor,
                                child: Text(
                                  member.initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(member.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${member.role} · ${member.team}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                selected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: selected
                                    ? AppColors.primaryDark
                                    : AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      _selectedMember == null || _submitting ? null : _continue,
                  icon: _submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
