import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose your profile')),
      body: const Center(child: Text('Select a profile to continue.')),
    );
  }
}
