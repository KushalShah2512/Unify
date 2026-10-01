import 'package:flutter/material.dart';
import 'package:unify/core/services/api_service.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final ApiService apiService = ApiService();

  List<Map<String, dynamic>> projects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final response = await apiService.getProjects();

      if (response.statusCode == 200) {
        final data = response.data['projects'] as List;

        if (!mounted) return;

        setState(() {
          projects = List<Map<String, dynamic>>.from(data);
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
          content: Text('Failed to load projects'),
        ),
      );
    }
  }

  Future<void> _deleteProject(int id) async {
    try {
      final response = await apiService.deleteProject(id);

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project deleted successfully'),
          ),
        );

        _loadProjects();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete project'),
        ),
      );
    }
  }

  void _showDeleteDialog(Map<String, dynamic> project) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Project'),
          content: Text(
            'Are you sure you want to delete "${project['title']}"?',
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

                _deleteProject(
                  project['id'] as int,
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showProjectDialog({
    Map<String, dynamic>? project,
  }) {
    final titleController = TextEditingController(
      text: project?['title'] ?? '',
    );

    final descriptionController = TextEditingController(
      text: project?['description'] ?? '',
    );

    final technologiesController = TextEditingController(
      text: project?['technologies'] ?? '',
    );

    final projectUrlController = TextEditingController(
      text: project?['projectUrl'] ?? '',
    );

    final isEditing = project != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            isEditing ? 'Edit Project' : 'Add Project',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Project Title',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: technologiesController,
                  decoration: const InputDecoration(
                    labelText: 'Technologies',
                    hintText: 'Flutter, Node.js, PostgreSQL',
                    prefixIcon: Icon(Icons.code),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: projectUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Project URL',
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
                final title = titleController.text.trim();

                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Project title is required'),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                try {
                  if (isEditing) {
                    await apiService.updateProject(
                      id: project['id'] as int,
                      title: title,
                      description:
                          descriptionController.text.trim(),
                      technologies:
                          technologiesController.text.trim(),
                      projectUrl:
                          projectUrlController.text.trim(),
                    );
                  } else {
                    await apiService.addProject(
                      title: title,
                      description:
                          descriptionController.text.trim(),
                      technologies:
                          technologiesController.text.trim(),
                      projectUrl:
                          projectUrlController.text.trim(),
                    );
                  }

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEditing
                            ? 'Project updated successfully'
                            : 'Project added successfully',
                      ),
                    ),
                  );

                  _loadProjects();
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEditing
                            ? 'Failed to update project'
                            : 'Failed to add project',
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showProjectDialog();
        },
        child: const Icon(Icons.add),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : projects.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadProjects,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];

                      return _ProjectCard(
                        project: project,
                        onEdit: () {
                          _showProjectDialog(
                            project: project,
                          );
                        },
                        onDelete: () {
                          _showDeleteDialog(project);
                        },
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 70,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),

            const SizedBox(height: 20),

            const Text(
              'No Projects Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Add your projects to build your career profile.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                _showProjectDialog();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Project'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Map<String, dynamic> project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProjectCard({
    required this.project,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String title =
        project['title']?.toString() ?? 'Untitled Project';

    final String description =
        project['description']?.toString() ?? '';

    final String technologies =
        project['technologies']?.toString() ?? '';

    final String projectUrl =
        project['projectUrl']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  child: Icon(
                    Icons.folder_outlined,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,
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

            if (description.isNotEmpty) ...[
              const SizedBox(height: 14),

              Text(
                description,
                style: const TextStyle(
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),
            ],

            if (technologies.isNotEmpty) ...[
              const SizedBox(height: 14),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: technologies
                    .split(',')
                    .map<Widget>(
                      (tech) => Chip(
                        label: Text(
                          tech.trim(),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],

            if (projectUrl.isNotEmpty) ...[
              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(
                    Icons.link,
                    size: 18,
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: Text(
                      projectUrl,
                      overflow: TextOverflow.ellipsis,
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
}