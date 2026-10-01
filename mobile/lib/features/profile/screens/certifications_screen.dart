import 'package:flutter/material.dart';
import 'package:unify/core/services/api_service.dart';

class CertificationsScreen extends StatefulWidget {
  const CertificationsScreen({super.key});

  @override
  State<CertificationsScreen> createState() =>
      _CertificationsScreenState();
}

class _CertificationsScreenState extends State<CertificationsScreen> {
  final ApiService apiService = ApiService();

  List<Map<String, dynamic>> certifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCertifications();
  }

  // =====================================================
  // Load Certifications
  // =====================================================

  Future<void> _loadCertifications() async {
    try {
      final response = await apiService.getCertifications();

      if (response.statusCode == 200) {
        final data = response.data['certifications'] as List;

        if (!mounted) return;

        setState(() {
          certifications =
              List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load certifications'),
        ),
      );
    }
  }

  // =====================================================
  // Delete Certification
  // =====================================================

  Future<void> _deleteCertification(int id) async {
    try {
      final response =
          await apiService.deleteCertification(id);

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Certification deleted successfully',
            ),
          ),
        );

        _loadCertifications();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to delete certification',
          ),
        ),
      );
    }
  }

  // =====================================================
  // Delete Confirmation
  // =====================================================

  void _showDeleteDialog(
    Map<String, dynamic> certification,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Certification',
          ),
          content: Text(
            'Are you sure you want to delete '
            '"${certification['name']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                _deleteCertification(
                  certification['id'] as int,
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // Add / Edit Certification
  // =====================================================

  void _showCertificationDialog({
    Map<String, dynamic>? certification,
  }) {
    final nameController = TextEditingController(
      text: certification?['name']?.toString() ?? '',
    );

    final issuingOrgController = TextEditingController(
      text: certification?['issuingOrg']?.toString() ?? '',
    );

    final credentialUrlController = TextEditingController(
      text: certification?['credentialUrl']?.toString() ?? '',
    );

    DateTime? selectedDate;

    if (certification?['issueDate'] != null) {
      selectedDate = DateTime.tryParse(
        certification!['issueDate'].toString(),
      );
    }

    final isEditing = certification != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              title: Text(
                isEditing
                    ? 'Edit Certification'
                    : 'Add Certification',
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Certification Name
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Certification Name',
                        prefixIcon:
                            Icon(Icons.workspace_premium_outlined),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Issuing Organization
                    TextField(
                      controller: issuingOrgController,
                      decoration: const InputDecoration(
                        labelText: 'Issuing Organization',
                        prefixIcon:
                            Icon(Icons.business_outlined),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Issue Date
                    InkWell(
                      onTap: () async {
                        final pickedDate =
                            await showDatePicker(
                          context: context,
                          initialDate:
                              selectedDate ?? DateTime.now(),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );

                        if (pickedDate != null) {
                          setDialogState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Issue Date',
                          prefixIcon:
                              Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(
                          selectedDate == null
                              ? 'Select issue date'
                              : _formatDate(selectedDate!),
                          style: TextStyle(
                            color: selectedDate == null
                                ? Colors.grey
                                : null,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Credential URL
                    TextField(
                      controller: credentialUrlController,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Credential URL',
                        hintText: 'https://example.com/certificate',
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final name =
                        nameController.text.trim();

                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Certification name is required',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext);

                    try {
                      final issueDate =
                          selectedDate?.toIso8601String();

                      if (isEditing) {
                        await apiService.updateCertification(
                          id: certification['id'] as int,
                          name: name,
                          issuingOrg:
                              issuingOrgController.text.trim(),
                          issueDate: issueDate,
                          credentialUrl:
                              credentialUrlController.text.trim(),
                        );
                      } else {
                        await apiService.addCertification(
                          name: name,
                          issuingOrg:
                              issuingOrgController.text.trim(),
                          issueDate: issueDate,
                          credentialUrl:
                              credentialUrlController.text.trim(),
                        );
                      }

                      if (!mounted) return;

                      ScaffoldMessenger.of(this.context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Certification updated successfully'
                                : 'Certification added successfully',
                          ),
                        ),
                      );

                      _loadCertifications();
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(this.context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Failed to update certification'
                                : 'Failed to add certification',
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    isEditing ? 'Update' : 'Add',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =====================================================
  // Date Formatting
  // =====================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // =====================================================
  // Build
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certifications'),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCertificationDialog();
        },
        child: const Icon(Icons.add),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : certifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadCertifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: certifications.length,
                    itemBuilder: (context, index) {
                      final certification =
                          certifications[index];

                      return _CertificationCard(
                        certification: certification,
                        onEdit: () {
                          _showCertificationDialog(
                            certification: certification,
                          );
                        },
                        onDelete: () {
                          _showDeleteDialog(
                            certification,
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }

  // =====================================================
  // Empty State
  // =====================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: 70,
              color:
                  Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 20),

            const Text(
              'No Certifications Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Add your certifications to build '
              'your career profile.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                _showCertificationDialog();
              },
              icon: const Icon(Icons.add),
              label: const Text(
                'Add Certification',
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// =====================================================
// Certification Card
// =====================================================

class _CertificationCard extends StatelessWidget {
  final Map<String, dynamic> certification;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CertificationCard({
    required this.certification,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String name =
        certification['name']?.toString() ??
            'Untitled Certification';

    final String issuingOrg =
        certification['issuingOrg']?.toString() ?? '';

    final String credentialUrl =
        certification['credentialUrl']?.toString() ?? '';

    final String issueDate =
        certification['issueDate']?.toString() ?? '';

    DateTime? parsedDate;

    if (issueDate.isNotEmpty) {
      parsedDate = DateTime.tryParse(issueDate);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 14),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),

                  child: Icon(
                    Icons.workspace_premium_outlined,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },

                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),

            if (issuingOrg.isNotEmpty) ...[
              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(
                    Icons.business_outlined,
                    size: 18,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      issuingOrg,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (parsedDate != null) ...[
              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    'Issued: ${_formatCardDate(parsedDate)}',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],

            if (credentialUrl.isNotEmpty) ...[
              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(
                    Icons.link,
                    size: 18,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      credentialUrl,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatCardDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}