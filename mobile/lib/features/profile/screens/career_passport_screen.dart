import 'package:flutter/material.dart';
import 'package:unify/core/services/api_service.dart';

class CareerPassportScreen extends StatefulWidget {
  const CareerPassportScreen({super.key});

  @override
  State<CareerPassportScreen> createState() => _CareerPassportScreenState();
}

class _CareerPassportScreenState extends State<CareerPassportScreen> {
  final ApiService apiService = ApiService();

  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic>? passport;

  @override
  void initState() {
    super.initState();
    _loadCareerPassport();
  }

  Future<void> _loadCareerPassport() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await apiService.getCareerPassport();

      if (response.statusCode == 200) {
        final data = response.data;

        setState(() {
          passport = Map<String, dynamic>.from(
            data['careerPassport'] ?? {},
          );
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              response.data?['message'] ?? 'Failed to load Career Passport';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Unable to load Career Passport. Please try again.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Passport'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCareerPassport,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCareerPassport,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (passport == null || passport!.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 250),
          Center(
            child: Text('No Career Passport data available'),
          ),
        ],
      );
    }

    final personalInformation =
        Map<String, dynamic>.from(
      passport!['personalInformation'] ?? {},
    );

    final careerInformation =
        Map<String, dynamic>.from(
      passport!['careerInformation'] ?? {},
    );

    final skills =
        List<dynamic>.from(
      passport!['skills'] ?? [],
    );

    final projects =
        List<dynamic>.from(
      passport!['projects'] ?? [],
    );

    final certifications =
        List<dynamic>.from(
      passport!['certifications'] ?? [],
    );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(personalInformation),
        const SizedBox(height: 16),

        _buildPersonalInformation(personalInformation),
        const SizedBox(height: 16),

        _buildCareerInformation(careerInformation),
        const SizedBox(height: 16),

        _buildSkillsSection(skills),
        const SizedBox(height: 16),

        _buildProjectsSection(projects),
        const SizedBox(height: 16),

        _buildCertificationsSection(certifications),
      ],
    );
  }

  Widget _buildHeader(Map<String, dynamic> personalInformation) {
    final fullName =
        personalInformation['fullName']?.toString() ?? 'Student';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 38,
              child: Text(
                _getInitials(fullName),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              fullName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Career Passport',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInformation(
    Map<String, dynamic> information,
  ) {
    return _buildSectionCard(
      title: 'Personal Information',
      icon: Icons.person_outline,
      children: [
        _buildInfoRow(
          Icons.phone_outlined,
          'Phone',
          information['phone'],
        ),
        _buildInfoRow(
          Icons.location_on_outlined,
          'Location',
          information['location'],
        ),
        _buildInfoRow(
          Icons.info_outline,
          'Bio',
          information['bio'],
        ),
      ],
    );
  }

  Widget _buildCareerInformation(
    Map<String, dynamic> information,
  ) {
    return _buildSectionCard(
      title: 'Career Information',
      icon: Icons.work_outline,
      children: [
        _buildInfoRow(
          Icons.school_outlined,
          'Education',
          information['education'],
        ),
        _buildInfoRow(
          Icons.flag_outlined,
          'Career Goal',
          information['careerGoal'],
        ),
        _buildInfoRow(
          Icons.schedule_outlined,
          'Availability',
          information['availability'],
        ),
      ],
    );
  }

  Widget _buildSkillsSection(List<dynamic> skills) {
    return _buildSectionCard(
      title: 'Skills',
      icon: Icons.code_outlined,
      children: [
        if (skills.isEmpty)
          const Text('No skills added yet.')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((skill) {
              final name = skill['name']?.toString() ?? 'Unknown';

              return Chip(
                avatar: const Icon(
                  Icons.check_circle_outline,
                  size: 18,
                ),
                label: Text(name),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildProjectsSection(List<dynamic> projects) {
    return _buildSectionCard(
      title: 'Projects',
      icon: Icons.folder_outlined,
      children: [
        if (projects.isEmpty)
          const Text('No projects added yet.')
        else
          ...projects.map(
            (project) => _buildProjectCard(project),
          ),
      ],
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    final name =
        project['name']?.toString() ?? 'Untitled Project';

    final description =
        project['description']?.toString();

    final technologies =
        project['technologies']?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (description != null &&
                description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(description),
            ],
            if (technologies != null &&
                technologies.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Technologies: $technologies',
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCertificationsSection(
    List<dynamic> certifications,
  ) {
    return _buildSectionCard(
      title: 'Certifications',
      icon: Icons.verified_outlined,
      children: [
        if (certifications.isEmpty)
          const Text('No certifications added yet.')
        else
          ...certifications.map(
            (certification) =>
                _buildCertificationCard(certification),
          ),
      ],
    );
  }

  Widget _buildCertificationCard(
    Map<String, dynamic> certification,
  ) {
    final name =
        certification['name']?.toString() ??
        'Certification';

    final issuingOrg =
        certification['issuingOrg']?.toString();

    final issueDate =
        certification['issueDate']?.toString();

    final credentialUrl =
        certification['credentialUrl']?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (issuingOrg != null &&
                issuingOrg.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Issued by: $issuingOrg'),
            ],
            if (issueDate != null &&
                issueDate.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Issue Date: ${_formatDate(issueDate)}'),
            ],
            if (credentialUrl != null &&
                credentialUrl.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Credential: $credentialUrl',
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    dynamic value,
  ) {
    final text = value?.toString();

    if (text == null || text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'S';
    }

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);

      return '${parsedDate.day.toString().padLeft(2, '0')}/'
          '${parsedDate.month.toString().padLeft(2, '0')}/'
          '${parsedDate.year}';
    } catch (_) {
      return date;
    }
  }
}