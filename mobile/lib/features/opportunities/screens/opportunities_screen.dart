import 'package:flutter/material.dart';
import 'package:unify/core/services/api_service.dart';

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
      return const Center(
        child: Text('No opportunities available'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOpportunities,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _opportunities.length,
        itemBuilder: (context, index) {
          final opportunity = _opportunities[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                opportunity['title'] ?? 'Untitled Opportunity',
              ),
              subtitle: Text(
                opportunity['companyName'] ?? 'Unknown Company',
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
            ),
          );
        },
      ),
    );
  }
}