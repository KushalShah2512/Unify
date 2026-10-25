import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:unify/core/services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ApiService apiService = ApiService();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final bioController = TextEditingController();
  final educationController = TextEditingController();
  final careerGoalController = TextEditingController();
  final availabilityController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    bioController.dispose();
    educationController.dispose();
    careerGoalController.dispose();
    availabilityController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await apiService.getStudentProfile();

      if (response.statusCode == 200 && response.data["profile"] != null) {
        final profile = response.data["profile"];

        fullNameController.text = profile["fullName"]?.toString() ?? "";
        emailController.text = profile["user"]?["email"]?.toString() ?? "";
        phoneController.text = profile["phone"]?.toString() ?? "";
        locationController.text = profile["location"]?.toString() ?? "";
        bioController.text = profile["bio"]?.toString() ?? "";
        educationController.text = profile["education"]?.toString() ?? "";
        careerGoalController.text = profile["careerGoal"]?.toString() ?? "";
        availabilityController.text = profile["availability"]?.toString() ?? "";
      }
    } catch (_) {
      // Don't interrupt user with error snackbar on empty initial profile
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Full name is required"),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final response = await apiService.updateStudentProfile(
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        location: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
        bio: bioController.text.trim().isEmpty ? null : bioController.text.trim(),
        education: educationController.text.trim().isEmpty ? null : educationController.text.trim(),
        careerGoal: careerGoalController.text.trim().isEmpty ? null : careerGoalController.text.trim(),
        availability: availabilityController.text.trim().isEmpty ? null : availabilityController.text.trim(),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully"),
            backgroundColor: Color(0xFF10B981),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;

      String errorMsg = "Failed to update profile";
      if (e is DioException) {
        final serverMsg = e.response?.data?["message"];
        if (serverMsg != null && serverMsg.toString().isNotEmpty) {
          errorMsg = serverMsg.toString();
        } else if (e.message != null && e.message!.isNotEmpty) {
          errorMsg = e.message!;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildField(
                    controller: fullNameController,
                    label: "Full Name",
                    icon: Icons.person_outline,
                  ),

                  const SizedBox(height: 16),

                _buildField(
                    controller: emailController,
                    label: "Email",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    readOnly: true, // Make email field read-only
                ),

                const SizedBox(height: 16),

                  _buildField(
                    controller: phoneController,
                    label: "Phone",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 16),

                  _buildField(
                    controller: locationController,
                    label: "Location",
                    icon: Icons.location_on_outlined,
                  ),

                  const SizedBox(height: 16),

                  _buildField(
                    controller: bioController,
                    label: "Bio",
                    icon: Icons.info_outline,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 16),

                  _buildField(
                    controller: educationController,
                    label: "Education",
                    icon: Icons.school_outlined,
                  ),

                  const SizedBox(height: 16),

                  _buildField(
                    controller: careerGoalController,
                    label: "Career Goal",
                    icon: Icons.flag_outlined,
                  ),

                  const SizedBox(height: 16),

                  _buildField(
                    controller: availabilityController,
                    label: "Availability",
                    icon: Icons.access_time,
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _updateProfile,
                      child: isSaving
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Save Changes",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

    Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    }) {
        return TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            readOnly: readOnly,
            decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                ),
            ),
        );
    }
}