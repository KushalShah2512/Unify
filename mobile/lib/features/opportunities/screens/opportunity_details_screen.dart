import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:unify/core/routes/route_names.dart';
import 'package:unify/core/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class OpportunityDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> opportunity;

  const OpportunityDetailsScreen({
    super.key,
    required this.opportunity,
  });

  @override
  State<OpportunityDetailsScreen> createState() => _OpportunityDetailsScreenState();
}

class _OpportunityDetailsScreenState extends State<OpportunityDetailsScreen> {
  final ApiService _apiService = ApiService();
  bool _isSaved = false;
  bool _isApplying = false;
  bool _hasApplied = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
    _checkIfApplied();
  }

  Future<void> _checkIfApplied() async {
    try {
      final oppId = widget.opportunity['id'] is int
          ? widget.opportunity['id'] as int
          : int.tryParse(widget.opportunity['id'].toString()) ?? 0;

      final res = await _apiService.getMyApplications();
      if (res.statusCode == 200 && res.data['applications'] != null) {
        final list = (res.data['applications'] as List?) ?? [];
        final isApplied = list.any((app) {
          final id = app['opportunityId'] ??
              (app['opportunity'] is Map ? app['opportunity']['id'] : null);
          return id == oppId;
        });
        if (mounted && isApplied) {
          setState(() => _hasApplied = true);
        }
      }
    } catch (_) {}
  }

  Future<void> _checkIfSaved() async {
    try {
      final oppId = widget.opportunity['id'] is int
          ? widget.opportunity['id'] as int
          : int.tryParse(widget.opportunity['id'].toString()) ?? 0;

      final res = await _apiService.getSavedOpportunities();
      if (res.statusCode == 200 && res.data['data'] != null) {
        final list = (res.data['data'] as List?) ?? [];
        final isFound = list.any((s) => (s['opportunityId'] as int) == oppId);
        if (mounted) setState(() => _isSaved = isFound);
      }
    } catch (_) {}
  }

  Future<void> _toggleSave() async {
    final oppId = widget.opportunity['id'] is int
        ? widget.opportunity['id'] as int
        : int.tryParse(widget.opportunity['id'].toString());
    if (oppId == null) return;

    setState(() => _isSaved = !_isSaved);

    try {
      final res = await _apiService.toggleSaveOpportunity(oppId);
      final saved = res.data['saved'] == true;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(saved ? 'Opportunity bookmarked' : 'Removed from bookmarks'),
            backgroundColor: saved ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _isSaved = !_isSaved);
    }
  }

  Future<void> _apply() async {
    final int? oppId = widget.opportunity['id'] is int
        ? widget.opportunity['id'] as int
        : int.tryParse(widget.opportunity['id'].toString());
    final applicationUrl = widget.opportunity['applicationUrl'];

    setState(() => _isApplying = true);

    if (oppId != null) {
      try {
        final response = await _apiService.applyToOpportunity(opportunityId: oppId);
        if (!mounted) return;
        setState(() => _hasApplied = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? 'Application submitted successfully!'),
            backgroundColor: const Color(0xFF10B981),
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                context.pop(true);
              },
            ),
          ),
        );
      } on DioException catch (e) {
        if (!mounted) return;
        if (e.response?.statusCode == 409) {
          setState(() => _hasApplied = true);
        }
        final responseData = e.response?.data;
        final message = responseData is Map && responseData['message'] != null
            ? responseData['message'].toString()
            : 'Unable to submit your application. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to submit your application. Please try again.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      } finally {
        if (mounted) setState(() => _isApplying = false);
      }
    }

    if (applicationUrl != null && applicationUrl.toString().trim().isNotEmpty) {
      final uri = Uri.tryParse(applicationUrl.toString());
      if (uri != null) {
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (_) {}
      }
    }
  }

  void _showReportDialog() {
    final int? oppId = widget.opportunity['id'] is int
        ? widget.opportunity['id'] as int
        : int.tryParse(widget.opportunity['id'].toString());
    if (oppId == null) return;

    String selectedReason = 'Asking for upfront money or payment';
    final detailsController = TextEditingController();

    final reasons = [
      'Asking for upfront money or payment',
      'Fake company / Non-existent recruiter',
      'Misleading salary, role or job duties',
      'Offensive, abusive or discriminatory content',
      'Suspicious link or phishing attempt',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEE2E2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.report_problem_rounded,
                            color: Color(0xFFDC2626),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Report Opportunity',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                'Help us keep the Unify campus platform safe and fraud-free.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),
                    const Text(
                      'Select Reason:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...reasons.map((r) {
                      final isSelected = selectedReason == r;
                      return InkWell(
                        onTap: () => setModalState(() => selectedReason = r),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFF87171) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                size: 18,
                                color: isSelected ? const Color(0xFFDC2626) : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  r,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    color: isSelected ? const Color(0xFF991B1B) : const Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    const Text(
                      'Additional details (optional):',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: detailsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Describe why this opportunity seems suspicious or fraudulent...',
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          Navigator.pop(ctx);
                          try {
                            await _apiService.reportOpportunity(
                              opportunityId: oppId,
                              reason: selectedReason,
                              details: detailsController.text.trim(),
                            );
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Report submitted. Admin moderation team will review this listing.'),
                                backgroundColor: Color(0xFF10B981),
                              ),
                            );
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Report submission failed: $e'),
                                backgroundColor: const Color(0xFFEF4444),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Submit Report to Admin',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatCurrency(dynamic val) {
    if (val == null) return '';
    final s = val.toString().trim();
    if (s.isEmpty) return '';
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
    final title = widget.opportunity['title'] ?? 'Untitled Opportunity';
    final company = widget.opportunity['companyName'] ?? 'Unknown Company';
    final description = widget.opportunity['description'];
    final type = widget.opportunity['type'];
    final location = widget.opportunity['location'];
    final workMode = widget.opportunity['workMode'];
    final stipend = widget.opportunity['stipend'];
    final salary = widget.opportunity['salary'];
    final experience = widget.opportunity['experience'];
    final preferredSkills = widget.opportunity['preferredSkills'];

    final requiredSkills = List<String>.from(widget.opportunity['requiredSkills'] ?? []);
    final compensation = stipend ?? salary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(_hasApplied),
        ),
        title: const Text(
          'Opportunity Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        actions: [
          IconButton(
            tooltip: _isSaved ? 'Bookmarked' : 'Bookmark',
            icon: Icon(
              _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _isSaved ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
            ),
            onPressed: _toggleSave,
          ),
          IconButton(
            tooltip: 'Report Suspicious Listing',
            icon: const Icon(
              Icons.flag_outlined,
              color: Color(0xFFEF4444),
            ),
            onPressed: _showReportDialog,
          ),
          const SizedBox(width: 4),
        ],
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
                    // Header card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.business_rounded, color: Color(0xFF4F46E5), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  company,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (type != null && type.toString().isNotEmpty)
                                _InfoChip(
                                  icon: Icons.work_outline,
                                  label: type.toString(),
                                  color: const Color(0xFF4F46E5),
                                ),
                              if (workMode != null && workMode.toString().isNotEmpty)
                                _InfoChip(
                                  icon: Icons.apartment,
                                  label: workMode.toString(),
                                  color: const Color(0xFF0284C7),
                                ),
                              if (compensation != null && compensation.toString().isNotEmpty)
                                _InfoChip(
                                  icon: Icons.payments_outlined,
                                  label: _formatCurrency(compensation),
                                  color: const Color(0xFF059669),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Quick Specs
                    _InformationCard(
                      children: [
                        if (location != null && location.toString().isNotEmpty)
                          _InformationRow(
                            icon: Icons.location_on_outlined,
                            title: 'Location',
                            value: location.toString(),
                          ),
                        if (experience != null && experience.toString().isNotEmpty)
                          _InformationRow(
                            icon: Icons.history_edu_outlined,
                            title: 'Experience Required',
                            value: experience.toString(),
                          ),
                        if (compensation != null && compensation.toString().isNotEmpty)
                          _InformationRow(
                            icon: Icons.currency_rupee,
                            title: type?.toString().toLowerCase().contains('intern') == true
                                ? 'Monthly Stipend'
                                : 'Annual CTC',
                            value: _formatCurrency(compensation),
                          ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Required Skills
                    if (requiredSkills.isNotEmpty) ...[
                      const _SectionTitle(title: 'Required Skills'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: requiredSkills
                            .map((skill) => _SkillChip(label: skill))
                            .toList(),
                      ),
                      const SizedBox(height: 22),
                    ],

                    // Preferred Skills
                    if (preferredSkills != null && preferredSkills.toString().isNotEmpty) ...[
                      const _SectionTitle(title: 'Preferred Qualifications'),
                      const SizedBox(height: 10),
                      Text(
                        preferredSkills.toString(),
                        style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.5),
                      ),
                      const SizedBox(height: 22),
                    ],

                    // Job Description
                    if (description != null && description.toString().isNotEmpty) ...[
                      const _SectionTitle(title: 'Role Description & Scope'),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          description.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF334155),
                            height: 1.55,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Trust & Safety Disclaimer Card (Unstop / Naukri style)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.shield_outlined, color: Color(0xFF16A34A), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Unify Campus Safety Promise',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF166534),
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Legitimate campus recruiters will never ask for registration fees, deposit payments, or training money. If asked, report this listing immediately.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF15803D),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // AI Readiness Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push(
                      RouteNames.opportunityReadiness,
                      extra: Map<String, dynamic>.from(widget.opportunity),
                    );
                  },
                  icon: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF4F46E5), size: 18),
                  label: const Text(
                    'Check My AI Readiness Match',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFC7D2FE), width: 1.5),
                    backgroundColor: const Color(0xFFEEF2FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            // Apply Button Bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isApplying || _hasApplied ? null : _apply,
                  icon: _isApplying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(
                    _isApplying
                        ? 'Submitting...'
                        : _hasApplied
                            ? 'Application Submitted'
                            : 'Apply for Opportunity',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
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

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E293B),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;

  const _SkillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFF1F5F9),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF334155),
        ),
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  final List<Widget> children;

  const _InformationCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(children: children),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF4F46E5)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
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
