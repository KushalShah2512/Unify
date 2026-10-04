import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unify/core/services/api_service.dart';
import 'package:unify/core/services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService apiService = ApiService();

  String fullName = "Student";
  String email = "Loading...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await apiService.getStudentProfile();

      if (response.statusCode == 200) {
        final profile = response.data["profile"];

        if (!mounted) return;

        setState(() {
            fullName = profile["fullName"] ?? "Student";
            email = profile["user"]?["email"] ?? "student@test.com";
            isLoading = false;
        });
      }
    } catch (e) {
      // If profile API doesn't return email,
      // temporarily use the logged-in email.
      if (!mounted) return;

      setState(() {
        email = "student@test.com";
        isLoading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    await StorageService.clearToken();

    if (!context.mounted) return;

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(
                      Icons.person,
                      size: 55,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    email,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 30),

                  _ProfileOption(
                    icon: Icons.person_outline,
                    title: "Edit Profile",
                    subtitle: "Update your personal information",
                    onTap: () {
                        context.push('/edit-profile');
                    },
                  ),

                 _ProfileOption(
                    icon: Icons.work_outline,
                    title: "My Projects",
                    subtitle: "View and manage your projects",
                    onTap: () {
                        context.push('/projects');
                    },
                ),

                  _ProfileOption(
                    icon: Icons.school_outlined,
                    title: "Education",
                    subtitle: "Manage your education details",
                    onTap: () {
                        context.push('/education');
                    },
                  ),

                  _ProfileOption(
                    icon: Icons.code_outlined,
                    title: "Skills",
                    subtitle: "Manage your technical skills",
                    onTap: () {
                        context.push('/skills');
                    },
                  ),

                  _ProfileOption(
                    icon: Icons.workspace_premium_outlined,
                    title: "Certifications",
                    subtitle: "Manage your certifications",
                    onTap: () {
                        context.push('/certifications');
                    },
                  ),

                  _ProfileOption(
                    icon: Icons.badge_outlined,
                    title: "Career Passport",
                    subtitle: "View your career profile",
                    onTap: () {
                      context.push('/career-passport');
                    },
                  ),

                  _ProfileOption(
                    icon: Icons.work_outline,
                    title: "Opportunities",
                    subtitle: "Find internships and job opportunities",
                    onTap: () {
                      context.push('/opportunities');
                    },
                  ),

                  _ProfileOption(
                    icon: Icons.settings_outlined,
                    title: "Settings",
                    subtitle: "Manage app preferences",
                    onTap: () {
                      context.push('/settings');
                    },
                  ),

                  const SizedBox(height: 10),

                  _ProfileOption(
                    icon: Icons.logout,
                    title: "Logout",
                    subtitle: "Sign out of your account",
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                  ),
                ],
              ),
            ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),

          title: const Text(
            "Logout",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),

          content: const Text(
            "Are you sure you want to logout?",
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
            ),
          ),

          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text("Cancel"),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);

                      await _logout(context);
                    },
                    child: const Text("Logout"),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),

        leading: CircleAvatar(
          backgroundColor:
              primaryColor.withValues(alpha: 0.1),

          child: Icon(
            icon,
            color: primaryColor,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Text(subtitle),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),

        onTap: onTap,
      ),
    );
  }
}