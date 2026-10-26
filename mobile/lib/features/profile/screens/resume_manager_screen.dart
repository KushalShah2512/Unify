import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:unify/core/routes/route_names.dart';
import 'package:unify/core/services/api_service.dart';

class ResumeManagerScreen extends StatefulWidget {
  const ResumeManagerScreen({super.key});

  @override
  State<ResumeManagerScreen> createState() => _ResumeManagerScreenState();
}

class _ResumeManagerScreenState extends State<ResumeManagerScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isUploading = false;
  Map<String, dynamic>? _resumeData;

  @override
  void initState() {
    super.initState();
    _fetchResume();
  }

  Future<void> _fetchResume() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getStudentResume();
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _resumeData = response.data['data'] as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      debugPrint('Error fetching resume: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadResume() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc', 'txt'],
      );

      if (files.isEmpty) return;

      final file = files.first;
      final bytes = await file.readAsBytes();
      final fileName = file.name;

      // Max 10MB check
      if (bytes.length > 10 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File exceeds 10MB limit. Please select a smaller file.'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
        }
        return;
      }

      setState(() => _isUploading = true);

      final response = await _apiService.uploadStudentResume(
        bytes: bytes,
        fileName: fileName,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _resumeData = response.data['data'] as Map<String, dynamic>?;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Resume uploaded successfully! Submitted for verification.'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload resume: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteResume() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Resume?'),
        content: const Text(
          'Are you sure you want to delete your uploaded resume? Recruiters will not be able to view it until you upload a new one.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final response = await _apiService.deleteStudentResume();
      if (response.statusCode == 200) {
        setState(() {
          _resumeData = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Resume removed'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete resume: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openResumeUrl(String rawUrl) async {
    try {
      // If relative URL, prepend baseUrl
      final fullUrl = rawUrl.startsWith('http')
          ? rawUrl
          : '${ApiService.baseUrl}$rawUrl';

      final uri = Uri.parse(fullUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open resume link: $fullUrl'),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching resume: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  String _formatBytes(dynamic size) {
    if (size == null) return '';
    final numBytes = size is int ? size : int.tryParse(size.toString()) ?? 0;
    if (numBytes < 1024) return '$numBytes B';
    if (numBytes < 1024 * 1024) return '${(numBytes / 1024).toStringAsFixed(1)} KB';
    return '${(numBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr.toString()).toLocal();
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasResume = _resumeData != null && _resumeData!['resumeUrl'] != null;
    final resumeName = _resumeData?['resumeName'] ?? 'Official_Resume.pdf';
    final resumeUrl = _resumeData?['resumeUrl'] as String?;
    final resumeSize = _resumeData?['resumeSize'];
    final updatedAt = _resumeData?['resumeUpdatedAt'];
    final isVerified = _resumeData?['isResumeVerified'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Resume & Verification',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
            )
          : RefreshIndicator(
              onRefresh: _fetchResume,
              color: const Color(0xFF4F46E5),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header banner
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified_user_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Campus & Recruiter Verified',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Upload your master CV. Admin verification signals high trust to employers on Unify.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section Title
                    const Text(
                      'ACTIVE RESUME',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (_isUploading)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Color(0xFF4F46E5)),
                              SizedBox(height: 16),
                              Text(
                                'Uploading & processing resume...',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (hasResume)
                      // Uploaded Resume Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isVerified ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                            width: isVerified ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.description_rounded,
                                    color: Color(0xFF4F46E5),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        resumeName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: Color(0xFF1E293B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_formatBytes(resumeSize)} • Updated ${_formatDate(updatedAt)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            const SizedBox(height: 14),

                            // Verification Badge Banner
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isVerified
                                    ? const Color(0xFFECFDF5)
                                    : const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isVerified
                                      ? const Color(0xFFA7F3D0)
                                      : const Color(0xFFFDE68A),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isVerified
                                        ? Icons.check_circle_rounded
                                        : Icons.hourglass_top_rounded,
                                    size: 18,
                                    color: isVerified
                                        ? const Color(0xFF059669)
                                        : const Color(0xFFD97706),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isVerified
                                              ? 'Verified by Unify Admin'
                                              : 'Under Review by Admin',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: isVerified
                                                ? const Color(0xFF065F46)
                                                : const Color(0xFF92400E),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          isVerified
                                              ? 'Your credentials have been checked and verified.'
                                              : 'Your resume is visible to recruiters while verification is in progress.',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isVerified
                                                ? const Color(0xFF047857)
                                                : const Color(0xFFB45309),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: resumeUrl != null
                                        ? () => _openResumeUrl(resumeUrl)
                                        : null,
                                    icon: const Icon(Icons.visibility_outlined, size: 16),
                                    label: const Text('View Document'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF4F46E5),
                                      side: const BorderSide(color: Color(0xFFC7D2FE)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  tooltip: 'Replace Resume',
                                  onPressed: _pickAndUploadResume,
                                  icon: const Icon(Icons.file_upload_outlined, color: Color(0xFF4F46E5)),
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFFEEF2FF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  tooltip: 'Delete Resume',
                                  onPressed: _deleteResume,
                                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFFFEF2F2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    else
                      // Empty state / Upload box
                      InkWell(
                        onTap: _pickAndUploadResume,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFCBD5E1),
                              width: 1.5,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEEF2FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 36,
                                  color: Color(0xFF4F46E5),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Upload Official Resume',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'PDF, DOCX, DOC up to 10 MB',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _pickAndUploadResume,
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const Text('Browse Files'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Quick AI ATS check card (Unstop / Naukri style)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Color(0xFFD97706),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Want higher shortlists?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Test your resume against ATS scanner before applying.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push(RouteNames.atsChecker),
                            child: const Text(
                              'Run ATS',
                              style: TextStyle(
                                color: Color(0xFF4F46E5),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Naukri / Top Platform Best Practice Guidelines
                    const Text(
                      'PRO TIPS FOR VERIFICATION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTipTile(
                      icon: Icons.check_circle_outline_rounded,
                      title: 'Single-Column Layout',
                      description: 'Use standard fonts and standard sections (Education, Skills, Experience, Projects) for clean ATS parsing.',
                    ),
                    const SizedBox(height: 8),
                    _buildTipTile(
                      icon: Icons.link_rounded,
                      title: 'Include Live Project Links',
                      description: 'Add GitHub repositories or live URLs for high credibility during admin review.',
                    ),
                    const SizedBox(height: 8),
                    _buildTipTile(
                      icon: Icons.security_rounded,
                      title: 'Accurate Academic Scores',
                      description: 'Ensure CGPA and graduation dates match your official college records to prevent verification rejection.',
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTipTile({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4F46E5)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.35,
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
