import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:unify/core/services/storage_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // =====================================================
  // Logout
  // =====================================================

  Future<void> _logout(BuildContext context) async {
    await StorageService.clearToken();

    if (!context.mounted) return;

    context.go('/login');
  }

  // =====================================================
  // Logout Confirmation Dialog
  // =====================================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),

          titlePadding: const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            8,
          ),

          contentPadding: const EdgeInsets.fromLTRB(
            24,
            0,
            24,
            12,
          ),

          actionsPadding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16,
          ),

          title: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),

          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Colors.black87,
            ),
          ),

          actions: [
            Row(
              children: [
                // Cancel
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),

                const SizedBox(width: 12),

                // Logout
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);

                      await _logout(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // Build
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // =====================================================
            // Profile Header
            // =====================================================

            const CircleAvatar(
              radius: 50,
              child: Icon(
                Icons.person,
                size: 55,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Student',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'student@test.com',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 30),

            // =====================================================
            // Profile Options
            // =====================================================

            _ProfileOption(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              subtitle: 'Update your personal information',
              onTap: () {
                // TODO: Navigate to Edit Profile
              },
            ),

            _ProfileOption(
              icon: Icons.work_outline,
              title: 'My Jobs',
              subtitle: 'View your applied and saved jobs',
              onTap: () {
                context.push('/jobs');
              },
            ),

            _ProfileOption(
              icon: Icons.school_outlined,
              title: 'Education',
              subtitle: 'Manage your education details',
              onTap: () {
                // TODO: Education screen
              },
            ),

            _ProfileOption(
              icon: Icons.code_outlined,
              title: 'Skills',
              subtitle: 'Manage your technical skills',
              onTap: () {
                // TODO: Skills screen
              },
            ),

            _ProfileOption(
              icon: Icons.workspace_premium_outlined,
              title: 'Certifications',
              subtitle: 'Manage your certifications',
              onTap: () {
                // TODO: Certifications screen
              },
            ),

            _ProfileOption(
              icon: Icons.badge_outlined,
              title: 'Career Passport',
              subtitle: 'View your career profile',
              onTap: () {
                // TODO: Career Passport screen
              },
            ),

            _ProfileOption(
              icon: Icons.settings_outlined,
              title: 'Settings',
              subtitle: 'Manage app preferences',
              onTap: () {
                context.push('/settings');
              },
            ),

            const SizedBox(height: 10),

            // =====================================================
            // Logout
            // =====================================================

            _ProfileOption(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              iconColor: Colors.red,
              titleColor: Colors.red,
              onTap: () {
                _showLogoutDialog(context);
              },
            ),

            const SizedBox(height: 20),

            Text(
              'Unify',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Your career, unified.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// Profile Option Widget
// =====================================================

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconColor;
  final Color titleColor;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor = Colors.indigo,
    this.titleColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      elevation: 1,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        // Icon
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(
            alpha: 0.10,
          ),

          child: Icon(
            icon,
            color: iconColor,
          ),
        ),

        // Title
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: titleColor,
            fontSize: 16,
          ),
        ),

        // Subtitle
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),

        // Arrow
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade600,
        ),

        onTap: onTap,
      ),
    );
  }
}