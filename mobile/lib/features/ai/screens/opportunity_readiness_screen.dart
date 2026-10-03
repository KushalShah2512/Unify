import 'package:flutter/material.dart';
import 'package:unify/core/services/api_service.dart';

class OpportunityReadinessScreen extends StatefulWidget {
  const OpportunityReadinessScreen({super.key});

  @override
  State<OpportunityReadinessScreen> createState() =>
      _OpportunityReadinessScreenState();
}

class _OpportunityReadinessScreenState
    extends State<OpportunityReadinessScreen> {
  final ApiService apiService = ApiService();

  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic>? analysis;

  @override
  void initState() {
    super.initState();
    _analyzeOpportunity();
  }

  Future<void> _analyzeOpportunity() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response =
          await apiService.analyzeOpportunityReadiness(
        title: 'Flutter Developer Intern',
        company: 'ABC Technologies',
        requiredSkills: [
          'Flutter',
          'Dart',
          'Firebase',
          'Git',
        ],
      );

      if (response.statusCode == 200) {
        final data = response.data;

        setState(() {
          analysis = Map<String, dynamic>.from(
            data['analysis'] ?? {},
          );
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              response.data?['message'] ??
              'Failed to analyze opportunity';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage =
            'Unable to analyze this opportunity. Please try again.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunity Readiness'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return _buildErrorState();
    }

    if (analysis == null) {
      return const Center(
        child: Text('No analysis available'),
      );
    }

    final student =
        Map<String, dynamic>.from(
      analysis!['student'] ?? {},
    );

    final opportunity =
        Map<String, dynamic>.from(
      analysis!['opportunity'] ?? {},
    );

    final matchingSkills =
        List<dynamic>.from(
      analysis!['matchingSkills'] ?? [],
    );

    final missingSkills =
        List<dynamic>.from(
      analysis!['missingSkills'] ?? [],
    );

    final readinessPercentage =
        (analysis!['readinessPercentage'] ?? 0) as num;

    final recommendation =
        analysis!['recommendation']?.toString() ??
        'No recommendation available';

    return RefreshIndicator(
      onRefresh: _analyzeOpportunity,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _buildOpportunityCard(opportunity),
          const SizedBox(height: 16),

          _buildReadinessCard(
            readinessPercentage.toDouble(),
          ),
          const SizedBox(height: 16),

          _buildSkillsCard(
            title: 'Matching Skills',
            icon: Icons.check_circle_outline,
            skills: matchingSkills,
            emptyMessage: 'No matching skills found.',
          ),
          const SizedBox(height: 16),

          _buildSkillsCard(
            title: 'Skill Gaps',
            icon: Icons.school_outlined,
            skills: missingSkills,
            emptyMessage: 'No skill gaps identified.',
          ),
          const SizedBox(height: 16),

          _buildRecommendationCard(recommendation),
          const SizedBox(height: 16),

          _buildStudentInfoCard(student),
        ],
      ),
    );
  }

  Widget _buildOpportunityCard(
    Map<String, dynamic> opportunity,
  ) {
    final title =
        opportunity['title']?.toString() ??
        'Opportunity';

    final company =
        opportunity['company']?.toString();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.work_outline,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      if (company != null &&
                          company.isNotEmpty)
                        Padding(
                          padding:
                              const EdgeInsets.only(
                            top: 4,
                          ),
                          child: Text(
                            company,
                            style:
                                const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'AI-powered analysis of your profile against this opportunity.',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadinessCard(
    double percentage,
  ) {
    final score =
        percentage.clamp(0, 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Opportunity Readiness',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child:
                        CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 12,
                    ),
                  ),
                  Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Text(
                        '$score%',
                        style:
                            const TextStyle(
                          fontSize: 32,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Ready',
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getReadinessMessage(score),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getReadinessMessage(int score) {
    if (score >= 80) {
      return 'Your profile matches most of the required skills.';
    }

    if (score >= 50) {
      return 'You have a partial skill match. Focus on the identified skill gaps.';
    }

    return 'Develop the missing skills to improve your readiness for this opportunity.';
  }

  Widget _buildSkillsCard({
    required String title,
    required IconData icon,
    required List<dynamic> skills,
    required String emptyMessage,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (skills.isEmpty)
              Text(emptyMessage)
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills.map((skill) {
                  return Chip(
                    label: Text(
                      _capitalize(
                        skill.toString(),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(
    String recommendation,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb_outline),
                SizedBox(width: 10),
                Text(
                  'Recommendation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              recommendation,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfoCard(
    Map<String, dynamic> student,
  ) {
    final name =
        student['name']?.toString() ??
        'Student';

    final careerGoal =
        student['careerGoal']?.toString();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_outline),
                SizedBox(width: 10),
                Text(
                  'Profile Used',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
            if (careerGoal != null &&
                careerGoal.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Career Goal: $careerGoal',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 52,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage ??
                  'Something went wrong.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _analyzeOpportunity,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() +
        value.substring(1);
  }
}