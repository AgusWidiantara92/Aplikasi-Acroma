import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/router_provider.dart';
import '../models/router_profile.dart';
import '../utils/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _showEditRouterDialog(BuildContext context, RouterProfile router, RouterProvider provider) {
    final nicknameController = TextEditingController(text: router.nickname);
    final hostController = TextEditingController(text: router.host);
    final portController = TextEditingController(text: router.port.toString());
    final usernameController = TextEditingController(text: router.username);
    final passwordController = TextEditingController(text: router.password);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('EDIT ROUTER CONFIG', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nicknameController, decoration: const InputDecoration(labelText: 'Nickname')),
              const SizedBox(height: 10),
              TextField(controller: hostController, decoration: const InputDecoration(labelText: 'IP / Host')),
              const SizedBox(height: 10),
              TextField(controller: portController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Port')),
              const SizedBox(height: 10),
              TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Username')),
              const SizedBox(height: 10),
              TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(
            onPressed: () {
              if (nicknameController.text.isEmpty || hostController.text.isEmpty) return;
              
              final updatedProfile = router.copyWith(
                nickname: nicknameController.text.trim(),
                host: hostController.text.trim(),
                port: int.tryParse(portController.text) ?? 8728,
                username: usernameController.text.trim(),
                password: passwordController.text,
              );
              
              // In demo mode or live, saves changes
              provider.addRouter(
                updatedProfile.nickname,
                updatedProfile.host,
                updatedProfile.port,
                updatedProfile.username,
                updatedProfile.password,
              );
              
              // Select updated router to refresh
              provider.selectRouter(updatedProfile);
              
              Navigator.pop(dialogCtx);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Router configuration updated successfully!')),
              );
            },
            child: const Text('SAVE CHANGES'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RouterProvider>(context);
    final selected = provider.selectedRouter;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: selected == null
          ? const Center(child: Text('No active router configured.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'ROUTER INFORMATION',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 10),

                  // Information Cards
                  _buildInfoCard('Router Nickname', selected.nickname, Icons.label_important_outline),
                  const SizedBox(height: 8),
                  _buildInfoCard('IP Address', selected.host, Icons.dns_outlined),
                  const SizedBox(height: 8),
                  _buildInfoCard('Port', '${selected.port}', Icons.electrical_services_outlined),
                  const SizedBox(height: 8),
                  _buildInfoCard('Username', selected.username, Icons.person_outline),
                  const SizedBox(height: 8),
                  _buildInfoCard('Status', selected.isOnline ? 'ONLINE' : 'OFFLINE', Icons.signal_cellular_alt),
                  
                  const Spacer(),

                  // Edit Router button
                  ElevatedButton.icon(
                    onPressed: () => _showEditRouterDialog(context, selected, provider),
                    icon: const Icon(Icons.edit, size: 20),
                    label: const Text('EDIT ROUTER CONFIG'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 22),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
