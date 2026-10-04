import 'package:flutter/material.dart';
import 'package:unify/core/services/api_service.dart';
import 'package:go_router/go_router.dart';
import 'package:unify/core/routes/route_names.dart';

class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _opportunities = [];

  @override
  void initState() {
    super.initState();
    _loadOpportunities();
  }

  Future<void> _loadOpportunities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getOpportunities();

      setState(() {
        _opportunities = response.data['opportunities'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load opportunities';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunities'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOpportunities,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_opportunities.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadOpportunities,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 300),
            Center(
              child: Text('No opportunities available'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOpportunities,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _opportunities.length,
        itemBuilder: (context, index) {
          final opportunity = _opportunities[index];

          return _OpportunityCard(
            opportunity: opportunity,
          );
        },
      ),
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  final dynamic opportunity;

  const _OpportunityCard({
    required this.opportunity,
  });

  @override
  Widget build(BuildContext context) {
    final title = opportunity['title'] ?? 'Untitled Opportunity';
    final company = opportunity['companyName'] ?? 'Unknown Company';
    final type = opportunity['type'] ?? 'Opportunity';
    final location = opportunity['location'];
    final workMode = opportunity['workMode'];
    final stipend = opportunity['stipend'];
    final salary = opportunity['salary'];
    final requiredSkills =
        List<String>.from(opportunity['requiredSkills'] ?? []);

    final compensation = stipend ?? salary;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + arrow
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                    onPressed: () {
                        context.push(
                        RouteNames.opportunityDetails,
                        extra: Map<String, dynamic>.from(opportunity),
                        );
                    },
                    icon: const Icon(
                        Icons.arrow_forward_ios,
                        size: 17,
                    ),
                    tooltip: 'View details',
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Company
            Row(
              children: [
                Icon(
                  Icons.business_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    company,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Type + work mode
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.work_outline,
                  label: type,
                ),
                if (workMode != null && workMode.toString().isNotEmpty)
                  _InfoChip(
                    icon: Icons.laptop_outlined,
                    label: workMode.toString(),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Location + compensation
            if (location != null ||
                compensation != null) ...[
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (location != null &&
                      location.toString().isNotEmpty)
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      text: location.toString(),
                    ),
                  if (compensation != null &&
                      compensation.toString().isNotEmpty)
                    _DetailRow(
                      icon: Icons.payments_outlined,
                      text: compensation.toString(),
                    ),
                ],
              ),
            ],

            // Skills
            if (requiredSkills.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Required Skills',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: requiredSkills
                    .map(
                      (skill) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                        child: Text(
                          skill,
                          style:
                              Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],

            const SizedBox(height: 16),

            // View details
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                    context.push(
                        RouteNames.opportunityDetails,
                        extra: Map<String, dynamic>.from(opportunity),
                    );
                },
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
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
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context)
            .colorScheme
            .primaryContainer,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}