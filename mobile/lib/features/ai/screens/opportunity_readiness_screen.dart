import 'package:flutter/material.dart';
import 'package:unify/core/services/api_service.dart';

class OpportunityReadinessScreen extends StatefulWidget {
  final Map<String, dynamic> opportunity;

  const OpportunityReadinessScreen({
    super.key,
    required this.opportunity,
  });

  @override
  State<OpportunityReadinessScreen> createState() =>
      _OpportunityReadinessScreenState();
}

class _OpportunityReadinessScreenState
    extends State<OpportunityReadinessScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic>? _analysis;

  @override
  void initState() {
    super.initState();
    _analyzeReadiness();
  }

  Future<void> _analyzeReadiness() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final requiredSkills = List<String>.from(
        widget.opportunity['requiredSkills'] ?? [],
      );

      final response =
          await _apiService.analyzeOpportunityReadiness(
        title: widget.opportunity['title'] ?? 'Opportunity',
        company: widget.opportunity['companyName'],
        requiredSkills: requiredSkills,
      );

      setState(() {
        _analysis = Map<String, dynamic>.from(
          response.data['analysis'] ?? {},
        );

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Unable to analyze your opportunity readiness.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Opportunity Readiness'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Analyzing your profile...',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 52,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _analyzeReadiness,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_analysis == null) {
      return const Center(
        child: Text('No analysis available'),
      );
    }

    final readiness =
        (_analysis!['readinessPercentage'] ?? 0) as num;

    final matchingSkills = List<String>.from(
      _analysis!['matchingSkills'] ?? [],
    );

    final missingSkills = List<String>.from(
      _analysis!['missingSkills'] ?? [],
    );

    final recommendation =
        _analysis!['recommendation'] ??
            'No recommendation available';

    final readinessMessage =
        _analysis!['readinessMessage'] ??
            'No additional readiness information available.';

    final recommendedActions = List<String>.from(
      _analysis!['recommendedActions'] ?? [],
    );

    final student = Map<String, dynamic>.from(
      _analysis!['student'] ?? {},
    );

    final opportunity = Map<String, dynamic>.from(
      _analysis!['opportunity'] ?? {},
    );

    return RefreshIndicator(
      onRefresh: _analyzeReadiness,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          _buildOpportunityHeader(
            opportunity,
          ),

          const SizedBox(height: 24),

          _buildReadinessCard(
            readiness.toDouble(),
          ),

          const SizedBox(height: 24),

          _buildSkillsSection(
            title: 'Matching Skills',
            skills: matchingSkills,
            icon: Icons.check_circle_outline,
          ),

          const SizedBox(height: 20),

          _buildSkillsSection(
            title: 'Skill Gaps',
            skills: missingSkills,
            icon: Icons.warning_amber_rounded,
          ),

          const SizedBox(height: 24),

          _buildRecommendationCard(
            recommendation.toString(),
          ),

          const SizedBox(height: 20),

          _buildReadinessMessageCard(
            readinessMessage.toString(),
          ),

          const SizedBox(height: 20),

          _buildRecommendedActionsCard(
            recommendedActions,
          ),

          const SizedBox(height: 24),

          _buildProfileCard(
            student,
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunityHeader(
    Map<String, dynamic> opportunity,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer,
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
                    opportunity['title'] ??
                        'Opportunity',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    opportunity['company'] ??
                        'Company',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadinessCard(
    double readiness,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Your Opportunity Readiness',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: 170,
              height: 170,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 170,
                    height: 170,
                    child: CircularProgressIndicator(
                      value: readiness / 100,
                      strokeWidth: 14,
                      backgroundColor:
                          Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                    ),
                  ),

                  Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        '${readiness.round()}%',
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.w700,
                            ),
                      ),
                      const Text(
                        'Ready',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              _readinessMessage(readiness),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  String _readinessMessage(double readiness) {
    if (readiness >= 80) {
      return 'You have a strong skill match for this opportunity.';
    }

    if (readiness >= 50) {
      return 'You have a moderate skill match. Consider improving the missing skills.';
    }

    return 'Focus on developing the missing skills before applying.';
  }

  Widget _buildSkillsSection({
    required String title,
    required List<String> skills,
    required IconData icon,
  }) {
    if (skills.isEmpty) {
      return Card(
        elevation: 0,
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$title: None',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills
              .map(
                (skill) => Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(20),
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                  ),
                  child: Text(skill),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(
    String recommendation,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 28,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Recommendation',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recommendation,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadinessMessageCard(
    String message,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              size: 28,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why This Matters',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedActionsCard(
    List<String> actions,
  ) {
    if (actions.isEmpty) {
      return Card(
        elevation: 0,
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Padding(
          padding: EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No specific actions are required. Your current skills cover the opportunity requirements.',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Recommended Actions',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            ...List.generate(
              actions.length,
              (index) {
                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 14,
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment:
                            Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                        ),
                        child: Text(
                          '${index + 1}',
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          actions[index],
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                height: 1.4,
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    Map<String, dynamic> student,
  ) {
    return Card(
      elevation: 0,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(
              Icons.person_outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile Used',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student['name'] ?? 'Student',
                  ),
                  if (student['careerGoal'] !=
                      null)
                    Text(
                      student['careerGoal']
                          .toString(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}