import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:unify/core/services/api_service.dart';
import 'package:unify/core/services/storage_service.dart';

import '../widgets/auth_button.dart';
import '../widgets/auth_textfield.dart';
import '../widgets/social_login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  bool obscurePassword = true;

  bool rememberMe = false;

  final ApiService apiService = ApiService();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
  final email = emailController.text.trim();
  final password = passwordController.text;

  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please enter email and password"),
      ),
    );

    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    final response = await apiService.login(
      email: email,
      password: password,
    );

    final data = response.data;

    if (response.statusCode == 200 &&
        data["token"] != null) {
      await StorageService.saveToken(
        data["token"],
      );

      if (!mounted) return;

      final role = data["user"]["role"];

        context.go(
          '/home',
          extra: role,
      );
    }
  } on DioException catch (e) {
    String message = "Login failed";

    if (e.response?.data != null) {
      message =
          e.response?.data["message"] ?? "Login failed";
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Something went wrong"),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 30,
          ),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 20),

              Center(
                child: Image.asset(
                  "assets/images/logo.png",
                  height: 90,
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "Welcome Back 👋",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Sign in to continue your journey with Unify.",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 35),

              AuthTextField(
                controller: emailController,
                hintText: "Email Address",
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,

                decoration: InputDecoration(

                  hintText: "Password",

                  prefixIcon: const Icon(Icons.lock_outline),

                  suffixIcon: IconButton(

                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),

                    onPressed: () {

                      setState(() {

                        obscurePassword =
                            !obscurePassword;

                      });

                    },

                  ),

                  border: OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(14),

                  ),
                ),
              ),

              const SizedBox(height: 10),

              Row(

                children: [

                  Checkbox(

                    value: rememberMe,

                    onChanged: (value) {

                      setState(() {

                        rememberMe = value!;

                      });

                    },

                  ),

                  const Text("Remember Me"),

                  const Spacer(),

                  TextButton(

                    onPressed: () {

                    },

                    child: const Text(
                      "Forgot Password?",
                    ),

                  )

                ],

              ),

              const SizedBox(height: 10),

              AuthButton(
                title: isLoading ? "Signing In..." : "Sign In",
                onPressed: login,
              ),

              const SizedBox(height: 30),

              Row(

                children: [

                  const Expanded(child: Divider()),

                  Padding(

                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),

                    child: Text(
                      "OR",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),

                  ),

                  const Expanded(child: Divider()),

                ],

              ),

              const SizedBox(height: 30),

              SocialLoginButton(

                icon: Icons.g_mobiledata,

                title: "Continue with Google",

                onPressed: () {},

              ),

              const SizedBox(height: 40),

              Row(

                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  const Text(
                    "Don't have an account?",
                  ),

                  TextButton(

                    onPressed: () {

                    },

                    child: const Text(
                      "Create Account",
                    ),

                  )

                ],

              ),

            ],

          ),

        ),

      ),

    );

  }

}