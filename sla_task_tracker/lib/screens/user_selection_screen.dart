import 'package:flutter/material.dart';
import '../models/team_member.dart';
import '../services/data_store.dart';
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
      body: _members.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Center(child: Text('${_members.length} profiles available.')),
    );
  }
}
