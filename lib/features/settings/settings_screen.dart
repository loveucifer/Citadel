// lib/features/settings/settings_screen.dart
//
// Provides options for user to manage their account and app settings.

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../core/identity/citadel_identity.dart';
import '../../core/storage/secure_storage_service.dart';
import '../onboarding/generate_identity_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We can get the identity here to display user info
    final identity = Provider.of<CitadelIdentity>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Citizen Name'),
            // This is a placeholder for the user's handle [ID1]
            subtitle: Text(
              'YourName#${identity.identityKey.publicKey.sublist(0, 4).map((b) => b.toRadixString(16).padLeft(2, '0')).join()}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text('Show QR Code'),
            onTap: () {
              // TODO: Implement [CO2] In-Person Verification via QR Code
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup & Restore'),
            onTap: () {
              // TODO: Implement [D1] User-Controlled Encrypted Backups
            },
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Appearance'),
            onTap: () {
              // TODO: Implement [UX5] Theming
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade400),
            title: Text(
              'Logout',
              style: TextStyle(color: Colors.red.shade400),
            ),
            onTap: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text(
              'Are you sure you want to log out? You will need your 12-word recovery phrase to log back in.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                final storage = GetIt.instance<SecureStorageService>();
                await storage.deleteMnemonic();
                
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const GenerateIdentityScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
