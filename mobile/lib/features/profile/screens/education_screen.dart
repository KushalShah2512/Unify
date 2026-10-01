import 'package:flutter/material.dart';
import 'package:unify/core/services/api_service.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final ApiService _apiService = ApiService();

  List<dynamic> _educationList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEducation();
  }

  // ------------------------------------------------------------
  // LOAD EDUCATION
  // ------------------------------------------------------------

  Future<void> _loadEducation() async {
    try {
      final response = await _apiService.getEducation();

      if (!mounted) return;

      setState(() {
        _educationList = response.data['education'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load education: $e'),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // MONTH / YEAR PICKER
  // ------------------------------------------------------------

  Future<DateTime?> _pickMonthYear(
    BuildContext context, {
    DateTime? initialDate,
  }) async {
    final now = DateTime.now();

    DateTime selectedDate = initialDate ?? now;

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return showDialog<DateTime>(
      context: context,
      builder: (dialogContext) {
        int selectedMonth = selectedDate.month;
        int selectedYear = selectedDate.year;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Month and Year'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // MONTH
                  DropdownButton<int>(
                    value: selectedMonth,
                    items: List.generate(
                      12,
                      (index) => DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text(months[index]),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedMonth = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(width: 20),

                  // YEAR
                  DropdownButton<int>(
                    value: selectedYear,
                    items: List.generate(
                      81,
                      (index) {
                        final year = now.year - index;

                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        );
                      },
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedYear = value;
                        });
                      }
                    },
                  ),
                ],
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
                    Navigator.pop(
                      dialogContext,
                      DateTime(
                        selectedYear,
                        selectedMonth,
                        1,
                      ),
                    );
                  },
                  child: const Text('Select'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------
  // FORMAT DATE AS MM/YYYY
  // ------------------------------------------------------------

  String _formatMonthYear(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return '$month/${date.year}';
  }

  // ------------------------------------------------------------
  // PARSE API DATE
  // ------------------------------------------------------------

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) {
      return value;
    }

    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  // ------------------------------------------------------------
  // EDUCATION DIALOG
  // ------------------------------------------------------------

  Future<void> _showEducationDialog({
    Map<String, dynamic>? education,
  }) async {
    final institutionController = TextEditingController(
      text: education?['institution'] ?? '',
    );

    final degreeController = TextEditingController(
      text: education?['degree'] ?? '',
    );

    final fieldController = TextEditingController(
      text: education?['fieldOfStudy'] ?? '',
    );

    final descriptionController = TextEditingController(
      text: education?['description'] ?? '',
    );

    DateTime? startDate = _parseDate(
      education?['startDate'],
    );

    DateTime? endDate = _parseDate(
      education?['endDate'],
    );

    final isEditing = education != null;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEditing ? 'Edit Education' : 'Add Education',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ------------------------------------------------
                    // INSTITUTION
                    // ------------------------------------------------

                    TextField(
                      controller: institutionController,
                      decoration: const InputDecoration(
                        labelText: 'Institution *',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ------------------------------------------------
                    // DEGREE
                    // ------------------------------------------------

                    TextField(
                      controller: degreeController,
                      decoration: const InputDecoration(
                        labelText: 'Degree *',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ------------------------------------------------
                    // FIELD OF STUDY
                    // ------------------------------------------------

                    TextField(
                      controller: fieldController,
                      decoration: const InputDecoration(
                        labelText: 'Field of Study',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ------------------------------------------------
                    // START DATE
                    // ------------------------------------------------

                    InkWell(
                      onTap: () async {
                        final picked = await _pickMonthYear(
                          context,
                          initialDate: startDate,
                        );

                        if (picked != null) {
                          setDialogState(() {
                            startDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(
                            Icons.calendar_month,
                          ),
                        ),
                        child: Text(
                          startDate != null
                              ? _formatMonthYear(startDate!)
                              : 'Select month and year',
                          style: TextStyle(
                            color: startDate != null
                                ? Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ------------------------------------------------
                    // END DATE
                    // ------------------------------------------------

                    InkWell(
                      onTap: () async {
                        final picked = await _pickMonthYear(
                          context,
                          initialDate: endDate,
                        );

                        if (picked != null) {
                          setDialogState(() {
                            endDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(
                            Icons.calendar_month,
                          ),
                        ),
                        child: Text(
                          endDate != null
                              ? _formatMonthYear(endDate!)
                              : 'Select month and year',
                          style: TextStyle(
                            color: endDate != null
                                ? Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ------------------------------------------------
                    // DESCRIPTION
                    // ------------------------------------------------

                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),

              // ------------------------------------------------------
              // ACTIONS
              // ------------------------------------------------------

              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          // ------------------------------------------
                          // VALIDATION
                          // ------------------------------------------

                          if (institutionController.text
                                  .trim()
                                  .isEmpty ||
                              degreeController.text
                                  .trim()
                                  .isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Institution and degree are required',
                                ),
                              ),
                            );

                            return;
                          }

                          // ------------------------------------------
                          // DATE VALIDATION
                          // ------------------------------------------

                          if (startDate != null &&
                              endDate != null &&
                              endDate!.isBefore(startDate!)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'End date cannot be before start date',
                                ),
                              ),
                            );

                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            // ----------------------------------------
                            // UPDATE
                            // ----------------------------------------

                            if (isEditing) {
                              await _apiService.updateEducation(
                                id: education['id'],
                                institution:
                                    institutionController.text.trim(),
                                degree:
                                    degreeController.text.trim(),
                                fieldOfStudy:
                                    fieldController.text.trim().isEmpty
                                        ? null
                                        : fieldController.text.trim(),
                                startDate: startDate,
                                endDate: endDate,
                                description:
                                    descriptionController.text
                                            .trim()
                                            .isEmpty
                                        ? null
                                        : descriptionController.text
                                            .trim(),
                              );
                            }

                            // ----------------------------------------
                            // ADD
                            // ----------------------------------------

                            else {
                              await _apiService.addEducation(
                                institution:
                                    institutionController.text.trim(),
                                degree:
                                    degreeController.text.trim(),
                                fieldOfStudy:
                                    fieldController.text.trim().isEmpty
                                        ? null
                                        : fieldController.text.trim(),
                                startDate: startDate,
                                endDate: endDate,
                                description:
                                    descriptionController.text
                                            .trim()
                                            .isEmpty
                                        ? null
                                        : descriptionController.text
                                            .trim(),
                              );
                            }

                            if (!dialogContext.mounted) return;

                            Navigator.pop(dialogContext);

                            await _loadEducation();

                            if (!mounted) return;

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEditing
                                      ? 'Education updated successfully'
                                      : 'Education added successfully',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!dialogContext.mounted) return;

                            setDialogState(() {
                              isSaving = false;
                            });

                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Operation failed: $e',
                                ),
                              ),
                            );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEditing ? 'Update' : 'Add',
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    // IMPORTANT:
    // Keep this deferred disposal because it fixed the
    // '_dependents.isEmpty' assertion that occurred previously.

    WidgetsBinding.instance.addPostFrameCallback((_) {
      institutionController.dispose();
      degreeController.dispose();
      fieldController.dispose();
      descriptionController.dispose();
    });
  }

  // ------------------------------------------------------------
  // DELETE EDUCATION
  // ------------------------------------------------------------

  Future<void> _deleteEducation(int id) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Education'),
          content: const Text(
            'Are you sure you want to delete this education record?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await _apiService.deleteEducation(id);

      if (!mounted) return;

      await _loadEducation();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Education deleted successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete education: $e',
          ),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // EDUCATION CARD
  // ------------------------------------------------------------

  Widget _buildEducationCard(
    Map<String, dynamic> education,
  ) {
    final institution = education['institution'] ?? '';
    final degree = education['degree'] ?? '';
    final fieldOfStudy = education['fieldOfStudy'];
    final description = education['description'];

    final startDate = _parseDate(
      education['startDate'],
    );

    final endDate = _parseDate(
      education['endDate'],
    );

    String duration = '';

    if (startDate != null && endDate != null) {
      duration =
          '${_formatMonthYear(startDate)} - ${_formatMonthYear(endDate)}';
    } else if (startDate != null) {
      duration =
          '${_formatMonthYear(startDate)} - Present';
    } else if (endDate != null) {
      duration = _formatMonthYear(endDate);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  child: Icon(Icons.school),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        degree,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        institution,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEducationDialog(
                        education: education,
                      );
                    } else if (value == 'delete') {
                      _deleteEducation(
                        education['id'],
                      );
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

            if (fieldOfStudy != null &&
                fieldOfStudy.toString().isNotEmpty) ...[
              const SizedBox(height: 12),

              Text(
                'Field: $fieldOfStudy',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],

            if (duration.isNotEmpty) ...[
              const SizedBox(height: 6),

              Text(
                'Duration: $duration',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],

            if (description != null &&
                description.toString().isNotEmpty) ...[
              const SizedBox(height: 12),

              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Education'),
        actions: [
          IconButton(
            onPressed: _loadEducation,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEducationDialog(),
        child: const Icon(Icons.add),
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadEducation,
              child: _educationList.isEmpty
                  ? ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 180),

                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 64,
                              ),

                              SizedBox(height: 16),

                              Text(
                                'No education records yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              SizedBox(height: 8),

                              Text(
                                'Tap + to add your education',
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: _educationList.length,
                      itemBuilder: (context, index) {
                        return _buildEducationCard(
                          Map<String, dynamic>.from(
                            _educationList[index],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}