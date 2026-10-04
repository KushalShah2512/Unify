import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unify/core/routes/route_names.dart';
import 'package:url_launcher/url_launcher.dart';

class OpportunityDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> opportunity;

  const OpportunityDetailsScreen({
    super.key,
    required this.opportunity,
  });

  Future<void> _apply(BuildContext context) async {
  final applicationUrl = opportunity['applicationUrl'];

  if (applicationUrl == null ||
      applicationUrl.toString().trim().isEmpty) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Application link is not available.'),
      ),
    );
    return;
  }

  final uri = Uri.tryParse(applicationUrl.toString());

    if (uri == null) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Invalid application link.'),
        ),
        );
        return;
    }

    try {
        final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        );

        if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
            content: Text('Unable to open application link.'),
            ),
        );
        }
    } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Unable to open application link.'),
            ),
        );
    }
    }

  @override
  Widget build(BuildContext context) {
    final title = opportunity['title'] ?? 'Untitled Opportunity';
    final company = opportunity['companyName'] ?? 'Unknown Company';
    final description = opportunity['description'];
    final type = opportunity['type'];
    final location = opportunity['location'];
    final workMode = opportunity['workMode'];
    final stipend = opportunity['stipend'];
    final salary = opportunity['salary'];
    final experience = opportunity['experience'];
    final preferredSkills = opportunity['preferredSkills'];

    final requiredSkills =
        List<String>.from(opportunity['requiredSkills'] ?? []);

    final compensation = stipend ?? salary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunity Details'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Icon(
                          Icons.business_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            company,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Tags
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (type != null &&
                            type.toString().isNotEmpty)
                          _InfoChip(
                            icon: Icons.work_outline,
                            label: type.toString(),
                          ),
                        if (workMode != null &&
                            workMode.toString().isNotEmpty)
                          _InfoChip(
                            icon: Icons.laptop_outlined,
                            label: workMode.toString(),
                          ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Quick information
                    _InformationCard(
                      children: [
                        if (location != null &&
                            location.toString().isNotEmpty)
                          _InformationRow(
                            icon: Icons.location_on_outlined,
                            title: 'Location',
                            value: location.toString(),
                          ),
                        if (compensation != null &&
                            compensation.toString().isNotEmpty)
                          _InformationRow(
                            icon: Icons.payments_outlined,
                            title: 'Compensation',
                            value: compensation.toString(),
                          ),
                        if (experience != null &&
                            experience.toString().isNotEmpty)
                          _InformationRow(
                            icon: Icons.school_outlined,
                            title: 'Experience',
                            value: experience.toString(),
                          ),
                      ],
                    ),

                    // Description
                    if (description != null &&
                        description.toString().isNotEmpty) ...[
                      const SizedBox(height: 28),
                      _SectionTitle(title: 'About the Opportunity'),
                      const SizedBox(height: 10),
                      Text(
                        description.toString(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                            ),
                      ),
                    ],

                    // Required skills
                    if (requiredSkills.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      const _SectionTitle(title: 'Required Skills'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: requiredSkills
                            .map(
                              (skill) => _SkillChip(
                                label: skill,
                              ),
                            )
                            .toList(),
                      ),
                    ],

                    // Preferred skills
                    if (preferredSkills != null &&
                        preferredSkills.toString().isNotEmpty) ...[
                      const SizedBox(height: 28),
                      const _SectionTitle(title: 'Preferred Skills'),
                      const SizedBox(height: 10),
                      Text(
                        preferredSkills.toString(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // AI Readiness button
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: SizedBox(
                    width: double.infinity,
                    height: 52,
                        child: OutlinedButton.icon(
                            onPressed: () {
                                context.push(
                                    RouteNames.opportunityReadiness,
                                    extra: Map<String, dynamic>.from(opportunity),
                                );
                            },
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text(
                                'Check My AI Readiness',
                                style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                            ),
                        ),
                    ),
                ),
            ),

            // Apply button
            Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                BoxShadow(
                    blurRadius: 12,
                    color: Colors.black.withValues(alpha: 0.08),
                    offset: const Offset(0, -3),
                ),
                ],
            ),
            child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                onPressed: () => _apply(context),
                icon: const Icon(Icons.open_in_new),
                label: const Text(
                    'Apply Now',
                    style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    ),
                    ),
                    ),
                ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;

  const _SkillChip({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
      ),
      child: Text(label),
    );
  }
}

class _InformationCard extends StatelessWidget {
  final List<Widget> children;

  const _InformationCard({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InformationRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 21,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                    ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}