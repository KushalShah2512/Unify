import 'package:flutter/material.dart';
import 'package:unify/core/services/api_service.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final ApiService apiService = ApiService();

  List<Map<String, dynamic>> skills = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  // =====================================================
  // LOAD SKILLS
  // =====================================================

  Future<void> _loadSkills() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await apiService.getSkills();

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data["skills"] ?? [];

        setState(() {
          skills = data
              .map(
                (skill) => Map<String, dynamic>.from(skill),
              )
              .toList();

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });

        _showMessage(
          response.data["message"] ?? "Failed to load skills",
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage("Failed to load skills");
    }
  }

  // =====================================================
  // ADD / UPDATE SKILL
  // =====================================================

  Future<void> _saveSkill({
    int? skillId,
    required String name,
    required String level,
  }) async {
    try {
      if (skillId == null) {
        await apiService.addSkill(
          name: name,
          level: level,
        );
      } else {
        await apiService.updateSkill(
          id: skillId,
          name: name,
          level: level,
        );
      }

      if (!mounted) return;

      Navigator.pop(context);

      _showMessage(
        skillId == null
            ? "Skill added successfully"
            : "Skill updated successfully",
      );

      await _loadSkills();
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        "Failed to ${skillId == null ? "add" : "update"} skill",
      );
    }
  }

  // =====================================================
  // DELETE SKILL
  // =====================================================

  Future<void> _deleteSkill(int skillId) async {
    try {
      await apiService.deleteSkill(skillId);

      if (!mounted) return;

      _showMessage("Skill deleted successfully");

      await _loadSkills();
    } catch (e) {
      if (!mounted) return;

      _showMessage("Failed to delete skill");
    }
  }

  // =====================================================
  // SKILL DIALOG
  // =====================================================

  void _showSkillDialog({
    Map<String, dynamic>? skill,
  }) {
    final bool isEditing = skill != null;

    final nameController = TextEditingController(
      text: skill?["name"] ?? "",
    );

    String selectedLevel = skill?["level"] ?? "Beginner";

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                isEditing ? "Edit Skill" : "Add Skill",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Skill Name",
                        hintText: "e.g. Flutter",
                        prefixIcon: const Icon(
                          Icons.code,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: selectedLevel,
                      decoration: InputDecoration(
                        labelText: "Skill Level",
                        prefixIcon: const Icon(
                          Icons.trending_up,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "Beginner",
                          child: Text("Beginner"),
                        ),
                        DropdownMenuItem(
                          value: "Intermediate",
                          child: Text("Intermediate"),
                        ),
                        DropdownMenuItem(
                          value: "Advanced",
                          child: Text("Advanced"),
                        ),
                        DropdownMenuItem(
                          value: "Expert",
                          child: Text("Expert"),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedLevel = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();

                    if (name.isEmpty) {
                      _showMessage(
                        "Please enter a skill name",
                      );
                      return;
                    }

                    _saveSkill(
                      skillId: skill?["id"],
                      name: name,
                      level: selectedLevel,
                    );
                  },
                  child: Text(
                    isEditing ? "Update" : "Add",
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
  // DELETE CONFIRMATION
  // =====================================================

  void _showDeleteDialog(
    Map<String, dynamic> skill,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Delete Skill",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${skill["name"]}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                final int skillId = skill["id"];

                await _deleteSkill(skillId);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // MESSAGE
  // =====================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Skills"),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showSkillDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Skill"),
      ),

      body: RefreshIndicator(
        onRefresh: _loadSkills,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : skills.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: skills.length,
                    itemBuilder: (context, index) {
                      final skill = skills[index];

                      return _buildSkillCard(skill);
                    },
                  ),
      ),
    );
  }

  // =====================================================
  // EMPTY STATE
  // =====================================================

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
        ),

        const Icon(
          Icons.code_outlined,
          size: 70,
          color: Colors.grey,
        ),

        const SizedBox(height: 20),

        const Center(
          child: Text(
            "No skills added yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 8),

        const Center(
          child: Text(
            "Add your technical skills to build your profile.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // SKILL CARD
  // =====================================================

  Widget _buildSkillCard(
    Map<String, dynamic> skill,
  ) {
    final String name =
        skill["name"]?.toString() ?? "Unknown Skill";

    final String level =
        skill["level"]?.toString() ?? "Not specified";

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.1),
          child: Icon(
            Icons.code,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),
        ),

        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            level,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ),

        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == "edit") {
              _showSkillDialog(
                skill: skill,
              );
            }

            if (value == "delete") {
              _showDeleteDialog(skill);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: "edit",
              child: Row(
                children: [
                  Icon(Icons.edit_outlined),
                  SizedBox(width: 10),
                  Text("Edit"),
                ],
              ),
            ),
            PopupMenuItem(
              value: "delete",
              child: Row(
                children: [
                  Icon(Icons.delete_outline),
                  SizedBox(width: 10),
                  Text("Delete"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}