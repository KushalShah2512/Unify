import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unify/core/routes/route_names.dart';
import 'package:unify/core/services/api_service.dart';
import 'package:unify/core/services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String _studentName = 'Student';
  String _careerGoal = 'Career Ready';
  double _profileCompletion = 0.2;
  String _profileTip = 'Add your skills and projects to unlock full ATS readiness.';

  int _skillsCount = 0;
  int _projectsCount = 0;
  int _certificationsCount = 0;
  int _applicationsCount = 0;
  int _unreadNotificationsCount = 0;

  List<Map<String, dynamic>> _recommendedOpportunities = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // 1. Fetch Career Passport / Profile
      try {
        final passportRes = await _apiService.getCareerPassport();
        if (passportRes.statusCode == 200 && passportRes.data['careerPassport'] != null) {
          final cp = passportRes.data['careerPassport'] as Map<String, dynamic>;
          final personal = (cp['personalInformation'] as Map<String, dynamic>?) ?? {};
          final career = (cp['careerInformation'] as Map<String, dynamic>?) ?? {};
          final skills = (cp['skills'] as List?) ?? [];
          final projects = (cp['projects'] as List?) ?? [];
          final certs = (cp['certifications'] as List?) ?? [];
          final edu = (cp['educationRecords'] as List?) ?? [];

          final name = personal['fullName']?.toString() ?? 'Student';
          final goal = career['careerGoal']?.toString() ?? 'Software Engineering';

          // Calculate dynamic profile completion
          double score = 0.0;
          if (name.isNotEmpty && name != 'Student') score += 0.2;
          if (personal['bio'] != null && personal['bio'].toString().isNotEmpty) score += 0.2;
          if (skills.isNotEmpty) score += 0.2;
          if (projects.isNotEmpty) score += 0.2;
          if (certs.isNotEmpty || edu.isNotEmpty) score += 0.2;
          score = score.clamp(0.2, 1.0);

          String tip = 'Add projects and skills to boost your ATS match score.';
          if (score >= 1.0) {
            tip = 'Your Career Passport is fully verified and recruiter-ready!';
          } else if (skills.isEmpty) {
            tip = 'Add your core technical skills to unlock job matching.';
          } else if (projects.isEmpty) {
            tip = 'Showcase 1-2 portfolio projects to increase interview calls.';
          }

          if (mounted) {
            setState(() {
              _studentName = name;
              _careerGoal = goal;
              _profileCompletion = score;
              _profileTip = tip;
              _skillsCount = skills.length;
              _projectsCount = projects.length;
              _certificationsCount = certs.length;
            });
          }
        }
      } catch (_) {
        // If passport doesn't exist yet, fallback to getStudentProfile
        try {
          final profileRes = await _apiService.getStudentProfile();
          if (profileRes.statusCode == 200 && profileRes.data['profile'] != null) {
            final p = profileRes.data['profile'] as Map<String, dynamic>;
            if (mounted) {
              setState(() {
                _studentName = p['fullName']?.toString() ?? 'Student';
                _careerGoal = p['careerGoal']?.toString() ?? 'Software Developer';
              });
            }
          }
        } catch (_) {}
      }

      // 2. Fetch My Applications
      try {
        final appsRes = await _apiService.getMyApplications();
        if (appsRes.statusCode == 200 && appsRes.data['applications'] != null) {
          final apps = (appsRes.data['applications'] as List?) ?? [];
          if (mounted) {
            setState(() {
              _applicationsCount = apps.length;
            });
          }
        }
      } catch (_) {}

      // 3. Fetch Opportunities
      try {
        final oppsRes = await _apiService.getOpportunities();
        if (oppsRes.statusCode == 200 && oppsRes.data['opportunities'] != null) {
          final opps = (oppsRes.data['opportunities'] as List?) ?? [];
          if (mounted) {
            setState(() {
              _recommendedOpportunities = opps.take(3).cast<Map<String, dynamic>>().toList();
            });
          }
        }
      } catch (_) {}

      // 4. Fetch Notifications Count
      try {
        final notifRes = await _apiService.getNotifications();
        if (notifRes.statusCode == 200 && notifRes.data['data'] != null) {
          final list = (notifRes.data['data'] as List?) ?? [];
          final unread = list.where((item) => item['isRead'] == false).length;
          if (mounted) {
            setState(() {
              _unreadNotificationsCount = unread;
            });
          }
        }
      } catch (_) {}
    } catch (e) {
      debugPrint('Error loading home dashboard: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to sign out of Unify?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
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

  String _formatCurrency(dynamic val) {
    if (val == null) return 'Competitive';
    final s = val.toString().trim();
    if (s.isEmpty) return 'Competitive';
    if (s.startsWith('₹')) {
      return s.replaceAll(RegExp(r'^₹+'), '₹');
    }
    if (s.startsWith('Rs') || s.startsWith(r'$')) {
      return s;
    }
    return '₹$s';
  }

  @override
  Widget build(BuildContext context) {
    final int percentInt = (_profileCompletion * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/logo.jpeg',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Unify',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () async {
              await context.push(RouteNames.notifications);
              _loadDashboardData();
            },
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF475569),
                  size: 26,
                ),
                if (_unreadNotificationsCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _unreadNotificationsCount > 9 ? '9+' : '$_unreadNotificationsCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'View Profile',
            onPressed: () => context.push(RouteNames.profile),
            icon: const Icon(
              Icons.account_circle_outlined,
              color: Color(0xFF475569),
              size: 26,
            ),
          ),
          IconButton(
            tooltip: 'Sign Out',
            onPressed: _showLogoutDialog,
            icon: const Icon(
              Icons.logout_outlined,
              color: Color(0xFF475569),
              size: 24,
            ),
          ),
          const SizedBox(width: 6),
        ],
        bottom: _isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: Color(0xFF4F46E5),
                  backgroundColor: Colors.transparent,
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF4F46E5),
          onRefresh: _loadDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Welcome Greeting
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back, ${_studentName.split(" ").first} 👋',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _careerGoal.isNotEmpty
                                ? 'Career Target: $_careerGoal'
                                : 'Accelerate your career with AI guidance',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 2. Dynamic Profile Readiness & Completion Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4338CA), Color(0xFF6366F1), Color(0xFF7C3AED)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.verified_user_outlined, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 8),
                                const Flexible(
                                  child: Text(
                                    'Profile Readiness',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$percentInt% Complete',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _profileCompletion,
                          minHeight: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _profileTip,
                        style: const TextStyle(
                          color: Color(0xFFE0E7FF),
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: () => context.push(RouteNames.profile),
                          icon: const Icon(Icons.edit_note, size: 18),
                          label: Text(
                            percentInt >= 100 ? 'View Complete Profile' : 'Enhance Profile & Add Skills',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF4338CA),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // 3. Live Stats Counter Grid
                Row(
                  children: [
                    _StatTile(
                      label: 'Skills',
                      count: '$_skillsCount',
                      icon: Icons.psychology_outlined,
                      color: const Color(0xFF3B82F6),
                      onTap: () => context.push(RouteNames.skills),
                    ),
                    const SizedBox(width: 10),
                    _StatTile(
                      label: 'Projects',
                      count: '$_projectsCount',
                      icon: Icons.folder_outlined,
                      color: const Color(0xFF10B981),
                      onTap: () => context.push(RouteNames.projects),
                    ),
                    const SizedBox(width: 10),
                    _StatTile(
                      label: 'Certs',
                      count: '$_certificationsCount',
                      icon: Icons.workspace_premium_outlined,
                      color: const Color(0xFFF59E0B),
                      onTap: () => context.push(RouteNames.certifications),
                    ),
                    const SizedBox(width: 10),
                    _StatTile(
                      label: 'Applied',
                      count: '$_applicationsCount',
                      icon: Icons.send_outlined,
                      color: const Color(0xFF8B5CF6),
                      onTap: () => context.push(
                        RouteNames.opportunities,
                        extra: {'initialTab': 1},
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                // 4. AI Career Suite Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'AI Career Suite',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Gemini Powered',
                        style: TextStyle(
                          color: Color(0xFF6366F1),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Accelerate your job search with personalized AI feedback.',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _AiSuiteFeatureCard(
                        title: 'AI Career Coach',
                        subtitle: 'Mock interviews, roadmaps & tips',
                        badge: 'Interactive',
                        icon: Icons.auto_awesome,
                        gradientColors: const [Color(0xFF4F46E5), Color(0xFF6366F1)],
                        onTap: () => context.push(RouteNames.aiAssistant),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _AiSuiteFeatureCard(
                        title: 'ATS Resume Audit',
                        subtitle: 'Upload PDF / DOCX for keyword score',
                        badge: 'File Upload',
                        icon: Icons.fact_check_outlined,
                        gradientColors: const [Color(0xFF0F172A), Color(0xFF1E293B)],
                        onTap: () => context.push(RouteNames.atsChecker),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                // 5. Career Passport Banner
                InkWell(
                  onTap: () => context.push(RouteNames.careerPassport),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.badge_outlined,
                            color: Color(0xFF4F46E5),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Digital Career Passport',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Export verified resume & portfolio as PDF/JSON',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 15,
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                // 6. Quick Actions Hub
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.05,
                  children: [
                    _QuickHubItem(
                      icon: Icons.person_outline,
                      title: 'Profile',
                      color: const Color(0xFF4F46E5),
                      onTap: () => context.push(RouteNames.profile),
                    ),
                    _QuickHubItem(
                      icon: Icons.psychology_outlined,
                      title: 'Skills',
                      color: const Color(0xFF0EA5E9),
                      onTap: () => context.push(RouteNames.skills),
                    ),
                    _QuickHubItem(
                      icon: Icons.folder_outlined,
                      title: 'Projects',
                      color: const Color(0xFF10B981),
                      onTap: () => context.push(RouteNames.projects),
                    ),
                    _QuickHubItem(
                      icon: Icons.school_outlined,
                      title: 'Education',
                      color: const Color(0xFFF59E0B),
                      onTap: () => context.push(RouteNames.education),
                    ),
                    _QuickHubItem(
                      icon: Icons.workspace_premium_outlined,
                      title: 'Certifications',
                      color: const Color(0xFFEC4899),
                      onTap: () => context.push(RouteNames.certifications),
                    ),
                    _QuickHubItem(
                      icon: Icons.work_outline,
                      title: 'Jobs',
                      color: const Color(0xFF8B5CF6),
                      onTap: () => context.push(RouteNames.opportunities),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                // 7. Recommended Opportunities
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Opportunities',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push(RouteNames.opportunities),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: Color(0xFF4F46E5),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (_recommendedOpportunities.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.work_history_outlined, size: 36, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          const Text(
                            'Explore active openings on the job board',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: () => context.push(RouteNames.opportunities),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4F46E5),
                              side: const BorderSide(color: Color(0xFF4F46E5)),
                            ),
                            child: const Text('Browse Opportunities'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._recommendedOpportunities.map((opp) {
                    final title = opp['title'] ?? 'Role';
                    final company = opp['company'] ?? 'Company';
                    final type = opp['type'] ?? 'Internship';
                    final stipend = _formatCurrency(opp['stipend'] ?? opp['salary']);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => context.push(RouteNames.opportunityDetails, extra: opp),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.business_center_outlined, color: Color(0xFF4F46E5), size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title.toString(),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        company.toString(),
                                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEEF2FF),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              type.toString(),
                                              style: const TextStyle(color: Color(0xFF4F46E5), fontSize: 11, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            stipend,
                                            style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF94A3B8)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4F46E5),
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        onTap: (index) {
          if (index == 1) {
            context.push(RouteNames.profile);
          } else if (index == 2) {
            context.push(RouteNames.opportunities);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Jobs',
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatTile({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 5),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiSuiteFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _AiSuiteFeatureCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white, size: 26),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickHubItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickHubItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}