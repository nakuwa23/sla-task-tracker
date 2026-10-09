import 'package:flutter/material.dart';
import '../models/team_member.dart';
import '../services/data_store.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose your profile')),
      body: _members.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Center(child: Text('${_members.length} profiles available.')),
    );
  }
}
