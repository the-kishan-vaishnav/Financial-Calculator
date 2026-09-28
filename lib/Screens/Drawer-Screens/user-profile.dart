import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Login-Signin/login-screen.dart'; // Import your shared constants and helpers

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controllers for the input fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Fetch details directly from the current logged-in Firebase user
    User? user = _auth.currentUser;

    _nameController = TextEditingController(text: user?.displayName ?? "");
    _emailController = TextEditingController(text: user?.email ?? "");
  }

  Future<void> _showLogoutConfirmation() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Are you sure you want to log out of FinSphere?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  // Navigate back to login and remove all previous routes
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                  );
                }
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProfile() async {
    // 1. Password Confirmation Check
    if (_newPasswordController.text.isNotEmpty) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match!")),
        );
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      User? user = _auth.currentUser;

      // 2. Update Username (Display Name)
      if (_nameController.text != user?.displayName) {
        await user?.updateDisplayName(_nameController.text);
      }

      // 3. Update Email (Firebase sends a verification to the new email)
      if (_emailController.text != user?.email) {
        await user?.verifyBeforeUpdateEmail(_emailController.text);
      }

      // 4. Update Password
      if (_newPasswordController.text.isNotEmpty) {
        await user?.updatePassword(_newPasswordController.text);
      }

      // Refresh the UI with new data
      await user?.reload();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
        // Clear password fields after success
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "An error occurred")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: _showLogoutConfirmation,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: primaryGreen.withOpacity(0.1),
                    child: const Icon(Icons.person, size: 50, color: primaryGreen),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            buildLabel("Full Name"),
            buildTextField("User Name", Icons.person_outline, _nameController),
            const SizedBox(height: 20),
            buildLabel("Email Address"),
            buildTextField("Email", Icons.email_outlined, _emailController),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),
            const Text("Change Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
            const SizedBox(height: 16),
            buildLabel("New Password"),
            buildTextField("Min. 6 characters", Icons.lock_outline, _newPasswordController, isPassword: true),
            const SizedBox(height: 20),
            buildLabel("Confirm New Password"),
            buildTextField("Repeat password", Icons.lock_reset, _confirmPasswordController, isPassword: true),
            const SizedBox(height: 40),
            buildButton("Save Profile Updates", _isLoading, _updateProfile),
            const SizedBox(height: 20),
          ],
        ),
      ),

    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}