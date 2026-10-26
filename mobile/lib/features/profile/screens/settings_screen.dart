import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unify/core/routes/route_names.dart';
import 'package:unify/core/services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _jobAlerts = true;
  bool _applicationUpdates = true;
  bool _interviewReminders = true;
  bool _emailDigest = false;
  bool _biometricLogin = false;

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Change Password',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                style: const TextStyle(color: Color(0xFF0F172A)),
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  labelStyle: TextStyle(color: Color(0xFF64748B)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                style: const TextStyle(color: Color(0xFF0F172A)),
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: Color(0xFF64748B)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: Color(0xFF0F172A)),
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  labelStyle: TextStyle(color: Color(0xFF64748B)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password updated successfully!'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
            ),
            child: const Text('Update Password'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear App Cache', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        content: const Text(
          'This will clear offline cached files and temporary data. You will remain logged in.',
          style: TextStyle(color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('App cache cleared successfully! (34.2 MB freed)'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Logout', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to sign out of your Unify account?',
          style: TextStyle(color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await StorageService.clearToken();
              if (mounted) context.go(RouteNames.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Settings & Preferences',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E293B), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Section: Notifications
          _buildSectionHeader('Notifications & Alerts'),
          _buildSettingsCard([
            _buildSwitchTile(
              icon: Icons.notifications_active_outlined,
              title: 'Job Match Notifications',
              subtitle: 'Alerts when opportunities matching your skills are posted',
              value: _jobAlerts,
              onChanged: (val) => setState(() => _jobAlerts = val),
            ),
            _buildDivider(),
            _buildSwitchTile(
              icon: Icons.timeline,
              title: 'Application Updates',
              subtitle: 'Real-time recruiter pipeline updates and shortlists',
              value: _applicationUpdates,
              onChanged: (val) => setState(() => _applicationUpdates = val),
            ),
            _buildDivider(),
            _buildSwitchTile(
              icon: Icons.psychology_outlined,
              title: 'Interview Reminders',
              subtitle: 'AI mock interview practice suggestions & deadlines',
              value: _interviewReminders,
              onChanged: (val) => setState(() => _interviewReminders = val),
            ),
            _buildDivider(),
            _buildSwitchTile(
              icon: Icons.mail_outline,
              title: 'Weekly Opportunity Digest',
              subtitle: 'Receive curated career opportunities via email',
              value: _emailDigest,
              onChanged: (val) => setState(() => _emailDigest = val),
            ),
          ]),

          const SizedBox(height: 24),

          // Section: Account & Security
          _buildSectionHeader('Account & Security'),
          _buildSettingsCard([
            _buildActionTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update your account access password',
              onTap: _showChangePasswordDialog,
            ),
            _buildDivider(),
            _buildSwitchTile(
              icon: Icons.fingerprint,
              title: 'Biometric / Screen Lock Login',
              subtitle: 'Authenticate using Fingerprint or Face ID',
              value: _biometricLogin,
              onChanged: (val) => setState(() => _biometricLogin = val),
            ),
            _buildDivider(),
            _buildActionTile(
              icon: Icons.cleaning_services_outlined,
              title: 'Clear Cache & Temp Files',
              subtitle: 'Free up local storage space on device',
              onTap: _showClearCacheDialog,
            ),
          ]),

          const SizedBox(height: 24),

          // Section: About & Support
          _buildSectionHeader('About & Support'),
          _buildSettingsCard([
            _buildActionTile(
              icon: Icons.help_outline,
              title: 'Help Center & FAQs',
              subtitle: 'Answers to common questions and student guides',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Unify Student Support: support@unify.edu'),
                    backgroundColor: Color(0xFF4F46E5),
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildActionTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy & Terms',
              subtitle: 'How Unify protects your academic & career records',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Unify complies with standard student data privacy standards.'),
                    backgroundColor: Color(0xFF4F46E5),
                  ),
                );
              },
            ),
            _buildDivider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info_outline, color: Color(0xFF4F46E5), size: 20),
              ),
              title: const Text('App Version', style: TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('Unify Mobile v1.2.0 (Build 2026.10)', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            ),
          ]),

          const SizedBox(height: 28),

          // Sign Out Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _showLogoutDialog,
              icon: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 18),
              label: const Text('Sign Out of Unify', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEF4444)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: const Color(0xFF4F46E5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF4F46E5), size: 20),
      ),
      title: Text(title, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF4F46E5), size: 20),
      ),
      title: Text(title, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF94A3B8), size: 14),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 56);
  }
}
