import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:unify/core/services/api_service.dart';

class AiTestScreen extends StatefulWidget {
  const AiTestScreen({super.key});

  @override
  State<AiTestScreen> createState() => _AiTestScreenState();
}

class _AiTestScreenState extends State<AiTestScreen> {
  final ApiService apiService = ApiService();

  bool isLoading = false;
  String result = 'Press the button to test the AI readiness API.';

  Future<void> _testAnalysis() async {
    setState(() {
      isLoading = true;
      result = 'Analyzing opportunity...';
    });

    try {
      final response = await apiService.analyzeOpportunityReadiness(
        title: 'Flutter Developer Intern',
        company: 'ABC Technologies',
        requiredSkills: [
          'Flutter',
          'Dart',
          'Firebase',
          'Git',
        ],
      );

      setState(() {
        result = const JsonEncoder.withIndent('  ').convert(response.data);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        result = 'Error:\n$e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI API Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Opportunity Readiness Test',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Flutter Developer Intern\n'
              'ABC Technologies\n\n'
              'Required Skills:\n'
              'Flutter, Dart, Firebase, Git',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _testAnalysis,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Analyze Opportunity'),
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(result),
              ),
            ),
          ],
        ),
      ),
    );
  }
}