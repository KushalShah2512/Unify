import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:unify/core/services/api_service.dart';

class AtsResumeCheckerScreen extends StatefulWidget {
  const AtsResumeCheckerScreen({super.key});

  @override
  State<AtsResumeCheckerScreen> createState() => _AtsResumeCheckerScreenState();
}

class _AtsResumeCheckerScreenState extends State<AtsResumeCheckerScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _targetRoleController = TextEditingController();
  final TextEditingController _resumeTextController = TextEditingController();

  PlatformFile? _selectedFile;
  int _selectedFileSize = 0;
  Uint8List? _selectedFileBytes;
  bool _isLoading = false;
  Map<String, dynamic>? _atsReport;

  Future<void> _pickFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc', 'txt'],
      );

      if (files.isNotEmpty) {
        final file = files.first;
        final bytes = await file.readAsBytes();
        final size = file.lengthSync() ?? bytes.length;

        setState(() {
          _selectedFile = file;
          _selectedFileSize = size;
          _selectedFileBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick file: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _selectedFileSize = 0;
      _selectedFileBytes = null;
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }

  Future<void> _runAtsCheck() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.atsResumeChecker(
        targetRole: _targetRoleController.text.trim().isEmpty ? null : _targetRoleController.text.trim(),
        customResumeText: _resumeTextController.text.trim().isEmpty ? null : _resumeTextController.text.trim(),
        filePath: _selectedFile?.path,
        fileBytes: _selectedFileBytes,
        fileName: _selectedFile?.name,
      );

      if (mounted) {
        setState(() {
          _atsReport = response.data['atsReport'] as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error running ATS audit. Please try again.';
        if (e is DioException) {
          final serverMsg = e.response?.data?['message'];
          if (serverMsg != null && serverMsg.toString().isNotEmpty) {
            errorMessage = serverMsg.toString();
          } else if (e.message != null && e.message!.isNotEmpty) {
            errorMessage = e.message!;
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  void dispose() {
    _targetRoleController.dispose();
    _resumeTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'ATS Resume Checker',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF283548)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.fact_check, color: Color(0xFF6366F1), size: 36),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ATS Match & Optimization',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Upload your resume file (PDF, Word, TXT) or test against your Unify profile to identify keyword gaps and missing ATS criteria.',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Target Role input
            TextField(
              controller: _targetRoleController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Target Job Title (Optional)',
                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                hintText: 'e.g. Data Analyst, Flutter Developer, Software Engineer',
                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                prefixIcon: const Icon(Icons.work_outline, color: Color(0xFF6366F1)),
              ),
            ),

            const SizedBox(height: 18),

            // Resume File Upload Section
            const Text(
              'Upload Resume File',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (_selectedFile == null)
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.5),
                      width: 1.5,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF818CF8), size: 30),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tap to Browse & Upload Resume',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Supports PDF, DOCX, DOC, and TXT (Max 10MB)',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.6), width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _selectedFile!.name.toLowerCase().endsWith('.pdf')
                            ? const Color(0xFFEF4444).withOpacity(0.15)
                            : const Color(0xFF3B82F6).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _selectedFile!.name.toLowerCase().endsWith('.pdf')
                            ? Icons.picture_as_pdf
                            : Icons.description,
                        color: _selectedFile!.name.toLowerCase().endsWith('.pdf')
                            ? const Color(0xFFF87171)
                            : const Color(0xFF60A5FA),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFile!.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                _formatFileSize(_selectedFileSize),
                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Ready to Scan',
                                  style: TextStyle(color: Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 20),
                      onPressed: _removeFile,
                      tooltip: 'Remove file',
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 18),

            // Optional custom text toggle or input
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(top: 8),
                title: const Text(
                  'Or Paste Resume Content Manually (Optional)',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
                ),
                collapsedIconColor: const Color(0xFF94A3B8),
                iconColor: const Color(0xFF6366F1),
                children: [
                  TextField(
                    controller: _resumeTextController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Paste resume text here if you prefer not uploading a file...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Analyze Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _runAtsCheck,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.analytics, color: Colors.white),
                label: Text(
                  _isLoading
                      ? 'Analyzing Resume...'
                      : _selectedFile != null
                          ? 'Audit Uploaded File (${_selectedFile!.name.length > 18 ? "${_selectedFile!.name.substring(0, 15)}..." : _selectedFile!.name})'
                          : 'Audit Resume with ATS Engine',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                ),
              ),
            ),

            if (_atsReport != null) ...[
              const SizedBox(height: 28),

              // Score Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _getScoreColor(_atsReport!['overallScore'] ?? 0).withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    if (_atsReport!['fileName'] != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.attachment, color: Color(0xFF818CF8), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Audited file: ${_atsReport!['fileName']}',
                            style: const TextStyle(color: Color(0xFF818CF8), fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      'Overall ATS Compatibility',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${_atsReport!['overallScore'] ?? 0}',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: _getScoreColor(_atsReport!['overallScore'] ?? 0),
                          ),
                        ),
                        const Text('/100', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getScoreColor(_atsReport!['overallScore'] ?? 0).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _atsReport!['scoreRating'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(_atsReport!['overallScore'] ?? 0),
                        ),
                      ),
                    ),

                    const Divider(color: Color(0xFF334155), height: 32),

                    // Sub-scores
                    if (_atsReport!['breakdown'] != null) ...[
                      _buildMetricRow('Keyword Relevance', _atsReport!['breakdown']['keywordMatch'] ?? 0),
                      const SizedBox(height: 10),
                      _buildMetricRow('Structure & Experience', _atsReport!['breakdown']['sectionStructure'] ?? 0),
                      const SizedBox(height: 10),
                      _buildMetricRow('Action Verbs & Impact', _atsReport!['breakdown']['impactAndMetrics'] ?? 0),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Matched Keywords
              const Text('Matched Keywords', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ((_atsReport!['matchedKeywords'] as List?) ?? []).map((k) {
                  return Chip(
                    label: Text(k.toString(), style: const TextStyle(fontSize: 12, color: Color(0xFF10B981))),
                    backgroundColor: const Color(0xFF064E3B).withOpacity(0.5),
                    avatar: const Icon(Icons.check_circle, size: 16, color: Color(0xFF10B981)),
                    side: const BorderSide(color: Color(0xFF059669)),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Missing Keywords
              const Text('Missing Keywords to Add', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ((_atsReport!['missingKeywords'] as List?) ?? []).map((k) {
                  return Chip(
                    label: Text(k.toString(), style: const TextStyle(fontSize: 12, color: Color(0xFFF59E0B))),
                    backgroundColor: const Color(0xFF78350F).withOpacity(0.5),
                    avatar: const Icon(Icons.add_circle_outline, size: 16, color: Color(0xFFF59E0B)),
                    side: const BorderSide(color: Color(0xFFD97706)),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Actionable Recommendations
              const Text('Actionable Fixes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              ...((_atsReport!['feedback'] as List?) ?? []).map((fb) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Color(0xFF6366F1), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          fb.toString(),
                          style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              if (_atsReport!['aiCritique'] != null) ...[
                const SizedBox(height: 20),
                const Text('AI Specialist Critique', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1B4B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF4F46E5)),
                  ),
                  child: Text(
                    _atsReport!['aiCritique'].toString(),
                    style: const TextStyle(color: Color(0xFFE0E7FF), fontSize: 13, height: 1.5),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            Text('$value%', style: TextStyle(color: _getScoreColor(value), fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: const Color(0xFF334155),
            valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(value)),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
