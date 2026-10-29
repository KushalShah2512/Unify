import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unify/core/routes/route_names.dart';
import 'package:unify/core/services/api_service.dart';

class OpportunitiesScreen extends StatefulWidget {
  final int initialTab;

  const OpportunitiesScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  late TabController _tabController;

  // Opportunities state
  bool _isLoadingOpps = true;
  String? _oppsError;
  List<dynamic> _allOpportunities = [];
  List<dynamic> _filteredOpportunities = [];

  // Search & Filter state
  final TextEditingController _searchController = TextEditingController();
  String _selectedTypeFilter = 'All';
  String _selectedWorkModeFilter = 'All';
  bool _showOnlySaved = false;
  Set<int> _savedOpportunityIds = {};

  // Applications state
  bool _isLoadingApps = true;
  String? _appsError;
  List<dynamic> _myApplications = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
    _tabController.addListener(_handleTabChange);

    _searchController.addListener(_applyFilters);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  int _lastTabIndex = 0;

  void _handleTabChange() {
    if (_tabController.index != _lastTabIndex) {
      _lastTabIndex = _tabController.index;
      if (_lastTabIndex == 1) {
        _loadMyApplications();
      }
    }
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadOpportunities(),
      _loadMyApplications(),
    ]);
  }

  Future<void> _loadOpportunities() async {
    setState(() {
      _isLoadingOpps = true;
      _oppsError = null;
    });

    try {
      final response = await _apiService.getOpportunities();
      if (response.statusCode == 200) {
        final list = (response.data['opportunities'] as List?) ?? [];
        if (mounted) {
          setState(() {
            _allOpportunities = list;
            _isLoadingOpps = false;
          });
        }
      }

      // Fetch saved opportunities
      try {
        final savedRes = await _apiService.getSavedOpportunities();
        if (savedRes.statusCode == 200) {
          final savedList = (savedRes.data['data'] as List?) ??
              (savedRes.data['savedOpportunities'] as List?) ??
              [];
          final ids = savedList
              .map<int?>((s) => (s['opportunityId'] ?? s['id']) is int
                  ? (s['opportunityId'] ?? s['id']) as int
                  : int.tryParse((s['opportunityId'] ?? s['id']).toString()))
              .whereType<int>()
              .toSet();
          if (mounted) {
            setState(() {
              _savedOpportunityIds = ids;
            });
          }
        }
      } catch (_) {}

      if (mounted) _applyFilters();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingOpps = false;
          _oppsError = 'Failed to load opportunities';
        });
      }
    }
  }

  Future<void> _toggleSaveOpportunity(int id) async {
    final wasSaved = _savedOpportunityIds.contains(id);
    setState(() {
      if (wasSaved) {
        _savedOpportunityIds.remove(id);
      } else {
        _savedOpportunityIds.add(id);
      }
      _applyFilters();
    });

    try {
      final res = await _apiService.toggleSaveOpportunity(id);
      if (mounted) {
        final isSaved = res.data['saved'] == true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSaved ? 'Opportunity saved to bookmarks' : 'Removed from bookmarks'),
            duration: const Duration(seconds: 2),
            backgroundColor: isSaved ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
          ),
        );
      }
    } catch (e) {
      // Revert if error
      if (mounted) {
        setState(() {
          if (wasSaved) {
            _savedOpportunityIds.add(id);
          } else {
            _savedOpportunityIds.remove(id);
          }
          _applyFilters();
        });
      }
    }
  }

  Future<void> _loadMyApplications() async {
    setState(() {
      _isLoadingApps = true;
      _appsError = null;
    });

    try {
      final response = await _apiService.getMyApplications();
      if (response.statusCode == 200) {
        final list = (response.data['applications'] as List?) ?? [];
        if (mounted) {
          setState(() {
            _myApplications = list;
            _isLoadingApps = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingApps = false;
          _appsError = 'Failed to load your applications';
        });
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredOpportunities = _allOpportunities.where((opp) {
        final title = (opp['title'] ?? '').toString().toLowerCase();
        final company = (opp['companyName'] ?? '').toString().toLowerCase();
        final type = (opp['type'] ?? '').toString().toLowerCase();
        final workMode = (opp['workMode'] ?? '').toString().toLowerCase();
        final skills = List<String>.from(opp['requiredSkills'] ?? [])
            .map((s) => s.toLowerCase())
            .join(' ');

        final oppId = opp['id'] is int
            ? opp['id'] as int
            : int.tryParse(opp['id'].toString()) ?? 0;

        // Keyword query
        final matchesQuery = query.isEmpty ||
            title.contains(query) ||
            company.contains(query) ||
            skills.contains(query);

        // Type filter
        final matchesType = _selectedTypeFilter == 'All' ||
            type.contains(_selectedTypeFilter.toLowerCase());

        // Work mode filter
        final matchesWorkMode = _selectedWorkModeFilter == 'All' ||
            workMode.contains(_selectedWorkModeFilter.toLowerCase());

        // Saved filter
        final matchesSaved = !_showOnlySaved || _savedOpportunityIds.contains(oppId);

        return matchesQuery && matchesType && matchesWorkMode && matchesSaved;
      }).toList();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACCEPTED':
        return const Color(0xFF10B981);
      case 'SHORTLISTED':
        return const Color(0xFF8B5CF6);
      case 'UNDER_REVIEW':
      case 'REVIEWING':
        return const Color(0xFF0284C7);
      case 'REJECTED':
        return const Color(0xFFEF4444);
      case 'APPLIED':
      case 'PENDING':
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _formatStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'UNDER_REVIEW':
        return 'Under Review';
      case 'SHORTLISTED':
        return 'Shortlisted';
      case 'ACCEPTED':
        return 'Offer Accepted';
      case 'REJECTED':
        return 'Not Selected';
      case 'APPLIED':
      default:
        return 'Applied';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Opportunities',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4F46E5),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF4F46E5),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            const Tab(
              icon: Icon(Icons.explore_outlined, size: 20),
              text: 'Explore Jobs',
            ),
            Tab(
              icon: const Icon(Icons.send_outlined, size: 20),
              text: 'My Applications (${_myApplications.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExploreTab(),
          _buildApplicationsTab(),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: Explore Opportunities & Filters
  // ==========================================
  Widget _buildExploreTab() {
    return RefreshIndicator(
      onRefresh: _loadOpportunities,
      child: Column(
        children: [
          // Search & Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search roles, skills, or companies...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Filter Pills Horizontal List
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All Types', 'All', _selectedTypeFilter, (val) {
                        setState(() => _selectedTypeFilter = val);
                        _applyFilters();
                      }),
                      const SizedBox(width: 8),
                      _buildFilterChip('Internship', 'Internship', _selectedTypeFilter, (val) {
                        setState(() => _selectedTypeFilter = val);
                        _applyFilters();
                      }),
                      const SizedBox(width: 8),
                      _buildFilterChip('Full-time', 'Full-time', _selectedTypeFilter, (val) {
                        setState(() => _selectedTypeFilter = val);
                        _applyFilters();
                      }),
                      const SizedBox(width: 8),
                      Container(height: 20, width: 1, color: const Color(0xFFCBD5E1)),
                      const SizedBox(width: 8),
                      _buildFilterChip('All Modes', 'All', _selectedWorkModeFilter, (val) {
                        setState(() => _selectedWorkModeFilter = val);
                        _applyFilters();
                      }),
                      const SizedBox(width: 8),
                      _buildFilterChip('Remote', 'Remote', _selectedWorkModeFilter, (val) {
                        setState(() => _selectedWorkModeFilter = val);
                        _applyFilters();
                      }),
                      const SizedBox(width: 8),
                      _buildFilterChip('On-site', 'On-site', _selectedWorkModeFilter, (val) {
                        setState(() => _selectedWorkModeFilter = val);
                        _applyFilters();
                      }),
                      const SizedBox(width: 8),
                      Container(height: 20, width: 1, color: const Color(0xFFCBD5E1)),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        avatar: Icon(
                          _showOnlySaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          size: 14,
                          color: _showOnlySaved ? Colors.white : const Color(0xFF4F46E5),
                        ),
                        label: Text('Saved (${_savedOpportunityIds.length})'),
                        selected: _showOnlySaved,
                        onSelected: (val) {
                          setState(() => _showOnlySaved = val);
                          _applyFilters();
                        },
                        selectedColor: const Color(0xFF4F46E5),
                        backgroundColor: const Color(0xFFF1F5F9),
                        labelStyle: TextStyle(
                          color: _showOnlySaved ? Colors.white : const Color(0xFF4F46E5),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(
                          color: _showOnlySaved ? const Color(0xFF4F46E5) : const Color(0xFFC7D2FE),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content Area
          Expanded(
            child: _buildOpportunitiesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    String currentSelection,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = currentSelection.toLowerCase() == value.toLowerCase();

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      selectedColor: const Color(0xFF4F46E5),
      backgroundColor: const Color(0xFFF1F5F9),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF475569),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      side: BorderSide(
        color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
      ),
    );
  }

  Widget _buildOpportunitiesList() {
    if (_isLoadingOpps) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
    }

    if (_oppsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 12),
            Text(_oppsError!, style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOpportunities,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_filteredOpportunities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 54, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              const Text(
                'No matching opportunities found',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 6),
              const Text(
                'Try adjusting your search terms or filters',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredOpportunities.length,
      itemBuilder: (context, index) {
        final opportunity = _filteredOpportunities[index];
        final oppId = opportunity['id'] is int
            ? opportunity['id'] as int
            : int.tryParse(opportunity['id'].toString()) ?? 0;
        final isSaved = _savedOpportunityIds.contains(oppId);

        return _OpportunityCard(
          opportunity: opportunity,
          isSaved: isSaved,
          onToggleSave: () => _toggleSaveOpportunity(oppId),
          onTap: () async {
            final applied = await context.push(
              RouteNames.opportunityDetails,
              extra: Map<String, dynamic>.from(opportunity),
            );
            if (mounted) {
              _loadMyApplications();
              if (applied == true) {
                _tabController.animateTo(1);
              }
            }
          },
        );
      },
    );
  }

  // ==========================================
  // TAB 2: My Applications Pipeline
  // ==========================================
  Widget _buildApplicationsTab() {
    return RefreshIndicator(
      onRefresh: _loadMyApplications,
      child: _buildApplicationsList(),
    );
  }

  Widget _buildApplicationsList() {
    if (_isLoadingApps) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
    }

    if (_appsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 12),
            Text(_appsError!, style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMyApplications,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_myApplications.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEEF2FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_outlined, size: 42, color: Color(0xFF4F46E5)),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No applications yet',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Browse available roles in the Explore tab and submit your Career Passport to start interviewing.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _tabController.animateTo(0),
                        icon: const Icon(Icons.explore, size: 18),
                        label: const Text('Explore Open Roles'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myApplications.length,
      itemBuilder: (context, index) {
        final app = _myApplications[index];
        final opp = (app['opportunity'] as Map?)?.cast<String, dynamic>() ?? {};
        final status = (app['status'] ?? 'APPLIED').toString();
        final statusColor = _getStatusColor(status);
        final statusLabel = _formatStatusLabel(status);
        final title = opp['title'] ?? 'Role';
        final company = opp['companyName'] ?? 'Company';
        final coverLetter = app['coverLetter']?.toString();
        final appliedAt = app['appliedAt'] != null
            ? DateTime.tryParse(app['appliedAt'].toString())
            : null;

        final dateFormatted = appliedAt != null
            ? '${appliedAt.day}/${appliedAt.month}/${appliedAt.year}'
            : 'Recently';

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Role + Status Pill
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            company.toString(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // Cover letter snippet if present
                if (coverLetter != null && coverLetter.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      'Cover note: "$coverLetter"',
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Footer Row: Date + View Details Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Text(
                          'Applied on $dateFormatted',
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () async {
                        await context.push(
                          RouteNames.opportunityDetails,
                          extra: opp,
                        );
                        if (mounted) {
                          _loadMyApplications();
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Posting',
                            style: TextStyle(
                              color: Color(0xFF4F46E5),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF4F46E5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  final dynamic opportunity;
  final bool isSaved;
  final VoidCallback onToggleSave;
  final VoidCallback? onTap;

  const _OpportunityCard({
    required this.opportunity,
    required this.isSaved,
    required this.onToggleSave,
    this.onTap,
  });

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
    final title = opportunity['title'] ?? 'Untitled Opportunity';
    final company = opportunity['companyName'] ?? 'Unknown Company';
    final type = opportunity['type'] ?? 'Opportunity';
    final location = opportunity['location'];
    final workMode = opportunity['workMode'];
    final stipend = opportunity['stipend'];
    final salary = opportunity['salary'];
    final requiredSkills = List<String>.from(opportunity['requiredSkills'] ?? []);

    final compensation = stipend ?? salary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap ?? () {
            context.push(
              RouteNames.opportunityDetails,
              extra: Map<String, dynamic>.from(opportunity),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Bookmark + Arrow
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: isSaved ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: isSaved ? 'Remove bookmark' : 'Save opportunity',
                      onPressed: onToggleSave,
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.arrow_forward_ios, size: 13, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Company
                Text(
                  company,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                // Chips (Type, Work Mode, Salary/Stipend)
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _InfoChip(label: type, color: const Color(0xFF4F46E5)),
                    if (workMode != null && workMode.toString().isNotEmpty)
                      _InfoChip(label: workMode.toString(), color: const Color(0xFF0284C7)),
                    if (compensation != null && compensation.toString().isNotEmpty)
                      _InfoChip(
                        label: _formatCurrency(compensation),
                        color: const Color(0xFF10B981),
                      ),
                  ],
                ),

                if (location != null && location.toString().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(
                        location.toString(),
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      ),
                    ],
                  ),
                ],

                // Skills tags
                if (requiredSkills.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: requiredSkills.take(3).map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
