import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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

                title: "Sign In",

                onPressed: () {

                },

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