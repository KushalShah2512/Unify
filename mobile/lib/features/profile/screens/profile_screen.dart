import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unify/core/routes/route_names.dart';
import 'package:unify/core/services/api_service.dart';
import 'package:unify/core/services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;

  // Profile data
  String _fullName = "Student";
  String _email = "";
  String _phone = "";
  String _location = "";
  String _bio = "";
  String _careerGoal = "Software Engineer";
  String _availability = "Immediate";

  // Counters
  int _projectsCount = 0;
  int _skillsCount = 0;
  int _educationCount = 0;
  int _certificationsCount = 0;

  // Profile completion score (0.0 to 1.0)
  double _profileCompletion = 0.2;
  String _completionBadge = "Getting Started";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      // 1. Fetch Career Passport for rich counters & personal details
      try {
        final passportRes = await _apiService.getCareerPassport();
        if (passportRes.statusCode == 200 && passportRes.data["careerPassport"] != null) {
          final cp = passportRes.data["careerPassport"] as Map<String, dynamic>;
          final personal = (cp["personalInformation"] as Map<String, dynamic>?) ?? {};
          final career = (cp["careerInformation"] as Map<String, dynamic>?) ?? {};
          final skills = (cp["skills"] as List?) ?? [];
          final projects = (cp["projects"] as List?) ?? [];
          final certs = (cp["certifications"] as List?) ?? [];
          final edu = (cp["educationRecords"] as List?) ?? [];

          final name = personal["fullName"]?.toString() ?? "";
          if (name.isNotEmpty && name != "Student") {
            _fullName = name;
          }
          _phone = personal["phone"]?.toString() ?? "";
          _location = personal["location"]?.toString() ?? "";
          _bio = personal["bio"]?.toString() ?? "";

          final goal = career["careerGoal"]?.toString() ?? "";
          if (goal.isNotEmpty) _careerGoal = goal;
          _availability = career["availability"]?.toString() ?? "Immediate";

          _skillsCount = skills.length;
          _projectsCount = projects.length;
          _certificationsCount = certs.length;
          _educationCount = edu.length;
        }
      } catch (_) {}

      // 2. Fetch Student Profile for email & user record
      try {
        final profileRes = await _apiService.getStudentProfile();
        if (profileRes.statusCode == 200 && profileRes.data["profile"] != null) {
          final p = profileRes.data["profile"] as Map<String, dynamic>;
          final name = p["fullName"]?.toString() ?? "";
          if (name.isNotEmpty && name != "Student") {
            _fullName = name;
          }
          _email = p["user"]?["email"]?.toString() ?? _email;
          if (_phone.isEmpty) _phone = p["phone"]?.toString() ?? "";
          if (_location.isEmpty) _location = p["location"]?.toString() ?? "";
          if (_bio.isEmpty) _bio = p["bio"]?.toString() ?? "";
          if (p["careerGoal"] != null && p["careerGoal"].toString().isNotEmpty) {
            _careerGoal = p["careerGoal"].toString();
          }
        }
      } catch (_) {}

      // Calculate dynamic strength
      double score = 0.2;
      if (_fullName.isNotEmpty && _fullName != "Student") score += 0.2;
      if (_bio.isNotEmpty || _phone.isNotEmpty) score += 0.2;
      if (_skillsCount > 0) score += 0.2;
      if (_projectsCount > 0) score += 0.1;
      if (_educationCount > 0 || _certificationsCount > 0) score += 0.1;

      _profileCompletion = score.clamp(0.2, 1.0);
      if (_profileCompletion >= 0.9) {
        _completionBadge = "All-Star Candidate";
      } else if (_profileCompletion >= 0.6) {
        _completionBadge = "Advanced Profile";
      } else {
        _completionBadge = "Intermediate Profile";
      }
    } catch (e) {
      debugPrint("Error loading profile screen: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await StorageService.clearToken();
    if (mounted) context.go(RouteNames.login);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Sign Out",
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to sign out of Unify? You will need to log back in to access your Career Passport and applications.",
          style: TextStyle(color: Color(0xFF475569), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text("Sign Out", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "U";
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
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
          "Profile & Career Center",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Settings",
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF475569)),
            onPressed: () async {
              await context.push(RouteNames.settings);
              _loadProfile();
            },
          ),
          IconButton(
            tooltip: "Sign Out",
            icon: const Icon(Icons.logout_outlined, color: Color(0xFFEF4444)),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
            )
          : RefreshIndicator(
              onRefresh: _loadProfile,
              color: const Color(0xFF4F46E5),
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Hero Card with Profile Information
                    _buildHeroCard(),

                    const SizedBox(height: 16),

                    // 2. Profile Strength Banner
                    _buildProfileStrengthCard(),

                    const SizedBox(height: 20),

                    // 3. Quick Stats Counter Bar
                    _buildStatsRow(),

                    const SizedBox(height: 24),

                    // 4. Section 1: Portfolio & Credentials
                    _buildSectionHeader("Portfolio & Credentials"),
                    _buildMenuCard([
                      _buildMenuItem(
                        icon: Icons.work_outline,
                        iconColor: const Color(0xFF4F46E5),
                        title: "My Projects",
                        subtitle: "$_projectsCount projects • Codebases, apps & demos",
                        onTap: () async {
                          await context.push(RouteNames.projects);
                          _loadProfile();
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.code,
                        iconColor: const Color(0xFF0284C7),
                        title: "Technical Skills",
                        subtitle: "$_skillsCount verified skills & proficiency levels",
                        onTap: () async {
                          await context.push(RouteNames.skills);
                          _loadProfile();
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.school_outlined,
                        iconColor: const Color(0xFFD97706),
                        title: "Education History",
                        subtitle: "$_educationCount records • Degrees & academic credentials",
                        onTap: () async {
                          await context.push(RouteNames.education);
                          _loadProfile();
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.workspace_premium_outlined,
                        iconColor: const Color(0xFFDB2777),
                        title: "Certifications",
                        subtitle: "$_certificationsCount certifications & verified licenses",
                        onTap: () async {
                          await context.push(RouteNames.certifications);
                          _loadProfile();
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.description_outlined,
                        iconColor: const Color(0xFF2563EB),
                        title: "Official Resume & Verification",
                        subtitle: "Upload master resume for admin & recruiter verification",
                        badge: "Verified",
                        badgeColor: const Color(0xFF2563EB),
                        onTap: () async {
                          await context.push(RouteNames.resumeManager);
                          _loadProfile();
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.badge_outlined,
                        iconColor: const Color(0xFF059669),
                        title: "Digital Career Passport",
                        subtitle: "View digital verified credential & export PDF",
                        badge: "Official",
                        badgeColor: const Color(0xFF059669),
                        onTap: () => context.push(RouteNames.careerPassport),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.document_scanner_outlined,
                        iconColor: const Color(0xFF7C3AED),
                        title: "ATS Resume Scanner",
                        subtitle: "Upload PDF/DOCX or analyze profile keywords",
                        badge: "AI Powered",
                        badgeColor: const Color(0xFF7C3AED),
                        onTap: () => context.push(RouteNames.atsChecker),
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // 5. Section 2: Career Pipeline & Activity
                    _buildSectionHeader("Opportunities & Activity"),
                    _buildMenuCard([
                      _buildMenuItem(
                        icon: Icons.assignment_turned_in_outlined,
                        iconColor: const Color(0xFF2563EB),
                        title: "My Applications Tracker",
                        subtitle: "Track interview stages, shortlists & offers",
                        badge: "Pipeline",
                        badgeColor: const Color(0xFF2563EB),
                        onTap: () => context.push(
                          RouteNames.opportunities,
                          extra: {'initialTab': 1},
                        ),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.search,
                        iconColor: const Color(0xFF0D9488),
                        title: "Explore Opportunities",
                        subtitle: "Search high-match internships & jobs",
                        onTap: () => context.push(
                          RouteNames.opportunities,
                          extra: {'initialTab': 0},
                        ),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.psychology_outlined,
                        iconColor: const Color(0xFF9333EA),
                        title: "AI Career Coach & Mock Interview",
                        subtitle: "Practice multi-round questions with live scoring",
                        badge: "Gemini",
                        badgeColor: const Color(0xFF9333EA),
                        onTap: () => context.push(RouteNames.aiAssistant),
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // 6. Section 3: Preferences & Security
                    _buildSectionHeader("App Preferences & Support"),
                    _buildMenuCard([
                      _buildMenuItem(
                        icon: Icons.settings_outlined,
                        iconColor: const Color(0xFF475569),
                        title: "Settings & Security",
                        subtitle: "Notifications, password change & storage cache",
                        onTap: () async {
                          await context.push(RouteNames.settings);
                          _loadProfile();
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.support_agent_outlined,
                        iconColor: const Color(0xFF0284C7),
                        title: "Help & Support",
                        subtitle: "Contact Unify campus career desk & FAQs",
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Unify Campus Support: support@unify.edu"),
                              backgroundColor: Color(0xFF4F46E5),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.logout,
                        iconColor: const Color(0xFFEF4444),
                        title: "Sign Out",
                        subtitle: "Safely log out of your session on this device",
                        isDestructive: true,
                        onTap: _showLogoutDialog,
                      ),
                    ]),

                    const SizedBox(height: 28),

                    // App Version Footer
                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: 22,
                                  height: 22,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.hub,
                                    size: 22,
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Unify Student Career Operating System",
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Version 1.2.0 • Build 2026",
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  // Hero Card - Clean Light Aesthetic
  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with gradient
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _getInitials(_fullName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Name & Career Goal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _fullName,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, color: Color(0xFF0284C7), size: 18),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _careerGoal,
                      style: const TextStyle(
                        color: Color(0xFF4F46E5),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_availability.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Text(
                          "Available: $_availability",
                          style: const TextStyle(
                            color: Color(0xFF059669),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Contact Pills
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (_email.isNotEmpty)
                _buildInfoPill(Icons.mail_outline, _email),
              if (_phone.isNotEmpty)
                _buildInfoPill(Icons.phone_outlined, _phone),
              if (_location.isNotEmpty)
                _buildInfoPill(Icons.location_on_outlined, _location),
            ],
          ),

          if (_bio.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _bio,
              style: const TextStyle(color: Color(0xFF475569), fontSize: 13, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 16),

          // Edit Profile Action Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () async {
                await context.push(RouteNames.editProfile);
                _loadProfile();
              },
              icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.white),
              label: const Text(
                "Edit Profile Details",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF64748B)),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(color: Color(0xFF334155), fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Profile Strength Card - Clean Light
  Widget _buildProfileStrengthCard() {
    final int percentInt = (_profileCompletion * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.speed, color: Color(0xFF4F46E5), size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Profile Strength",
                    style: TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Text(
                  _completionBadge,
                  style: const TextStyle(color: Color(0xFF4F46E5), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _profileCompletion,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$percentInt% Completed",
                style: const TextStyle(color: Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                percentInt < 100 ? "Add projects & certs for 100%" : "Top Candidate Status 🌟",
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Quick Stats Row (4-Grid)
  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard("Projects", _projectsCount.toString(), Icons.folder_outlined, const Color(0xFF4F46E5), () async {
          await context.push(RouteNames.projects);
          _loadProfile();
        }),
        const SizedBox(width: 8),
        _buildStatCard("Skills", _skillsCount.toString(), Icons.bolt, const Color(0xFF0284C7), () async {
          await context.push(RouteNames.skills);
          _loadProfile();
        }),
        const SizedBox(width: 8),
        _buildStatCard("Education", _educationCount.toString(), Icons.school_outlined, const Color(0xFFD97706), () async {
          await context.push(RouteNames.education);
          _loadProfile();
        }),
        const SizedBox(width: 8),
        _buildStatCard("Certs", _certificationsCount.toString(), Icons.workspace_premium_outlined, const Color(0xFFDB2777), () async {
          await context.push(RouteNames.certifications);
          _loadProfile();
        }),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
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

  Widget _buildMenuCard(List<Widget> children) {
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

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badge,
    Color? badgeColor,
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isDestructive ? const Color(0xFFEF4444) : const Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (badgeColor ?? const Color(0xFF4F46E5)).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: (badgeColor ?? const Color(0xFF4F46E5)).withValues(alpha: 0.3)),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: badgeColor ?? const Color(0xFF4F46E5),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Color(0xFF94A3B8),
        size: 14,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 56);
  }
}