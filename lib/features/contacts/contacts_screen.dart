// lib/features/contacts/contacts_screen.dart
//
// Displays a list of the user's contacts.

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Your contacts will be listed here.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to an "Add Contact" screen
        },
        child: const Icon(CupertinoIcons.add),
        tooltip: 'Add Contact',
      ),
    );
  }
}
