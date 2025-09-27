import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit profile
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profile coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          if (user == null) {
            return const Center(
              child: Text('No user data available'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            user.firstName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.fullName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(user.role.value.toUpperCase()),
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // User Information
                Card(
                  child: Column(
                    children: [
                      _ProfileTile(
                        icon: Icons.email,
                        title: 'Email',
                        subtitle: user.email,
                      ),
                      if (user.phone != null)
                        _ProfileTile(
                          icon: Icons.phone,
                          title: 'Phone',
                          subtitle: user.phone!,
                        ),
                      if (user.address != null)
                        _ProfileTile(
                          icon: Icons.location_on,
                          title: 'Address',
                          subtitle: user.address!,
                        ),
                      _ProfileTile(
                        icon: Icons.calendar_today,
                        title: 'Member Since',
                        subtitle: '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Settings
                Card(
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.notifications,
                        title: 'Notifications',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notification settings coming soon!')),
                          );
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.privacy_tip,
                        title: 'Privacy Policy',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Privacy policy coming soon!')),
                          );
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.help,
                        title: 'Help & Support',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Help & support coming soon!')),
                          );
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.info,
                        title: 'About',
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'Pet Grooming',
                            applicationVersion: '1.0.0',
                            applicationIcon: const Icon(Icons.pets, size: 48),
                            children: const [
                              Text('A mobile app for pet grooming service booking.'),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();

              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}