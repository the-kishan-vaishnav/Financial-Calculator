import 'package:finspere_calculator/Screens/finanace-dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Admin Section/admin-panel.dart';

// --- Shared Design Constants ---
const Color primaryGreen = Color(0xFF00D09C);
const Color darkText = Color(0xFF2D3137);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // Role selection for login (Optional: Helps app know where to look first)
  String _selectedRole = 'user';

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar("Please fill in all fields");
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. Authenticate with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Verify if the user exists in the selected collection
      String uid = userCredential.user!.uid;
      String collectionPath = _selectedRole == 'admin' ? 'admin' : 'user';

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection(collectionPath)
          .doc(uid)
          .get();

      if (userDoc.exists) {
        if (mounted) {
          // 3. NAVIGATION LOGIC BASED ON ROLE
          Widget nextScreen;
          if (_selectedRole == 'admin') {
            nextScreen = const AdminPanelScreen(); // Redirect to Admin Panel
          } else {
            nextScreen = const FinanceDashboard(); // Redirect to User Dashboard
          }

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => nextScreen),
                (route) => false,
          );
        }
      } else {
        // Validation: If account exists but not in the chosen role collection
        await FirebaseAuth.instance.signOut();
        _showSnackBar("Access Denied: You are not registered as an $_selectedRole");
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Authentication failed");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.trending_up_rounded, size: 48, color: primaryGreen),
                ),
              ),
              const SizedBox(height: 32),
              const Text("Welcome Back",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: darkText)),
              const SizedBox(height: 24),

              buildLabel("Login as"),
              roleToggleRow(),

              const SizedBox(height: 20),
              buildLabel("Email Address"),
              buildTextField("name@email.com", Icons.email_outlined, _emailController),
              const SizedBox(height: 20),
              buildLabel("Password"),
              buildTextField(
                "Enter password",
                Icons.lock_outline,
                _passwordController,
                isPassword: true,
                isObscured: !_isPasswordVisible,
                onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              const SizedBox(height: 24),
              buildButton("Login", _isLoading, _login),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("New to FinSphere?", style: TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())),
                    child: const Text("Register Now", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget roleToggleRow() {
    return Row(
      children: [
        Expanded(child: roleOption("User", "user", _selectedRole, (val) => setState(() => _selectedRole = val))),
        const SizedBox(width: 12),
        Expanded(child: roleOption("Admin", "admin", _selectedRole, (val) => setState(() => _selectedRole = val))),
      ],
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String _selectedRole = 'user'; // Default selection

  Future<void> _signup() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      // 1. Create User in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Prepare Data
      String uid = userCredential.user!.uid;
      Map<String, dynamic> userData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'enroll': _selectedRole, // Role stored as 'enroll' per your request
        'uid': uid,
      };

      // 3. Save to specific collection
      await FirebaseFirestore.instance
          .collection(_selectedRole == 'admin' ? 'admin' : 'user')
          .doc(uid)
          .set(userData);

      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const FinanceDashboard()),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Registration failed")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Create Account", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: darkText)),
            const SizedBox(height: 24),

            buildLabel("Register as"),
            Row(
              children: [
                Expanded(child: roleOption("User", "user", _selectedRole, (val) => setState(() => _selectedRole = val))),
                const SizedBox(width: 12),
                Expanded(child: roleOption("Admin", "admin", _selectedRole, (val) => setState(() => _selectedRole = val))),
              ],
            ),

            const SizedBox(height: 20),
            buildLabel("Full Name"),
            buildTextField("Enter your name", Icons.person_outline, _nameController),
            const SizedBox(height: 20),
            buildLabel("Email Address"),
            buildTextField("name@email.com", Icons.email_outlined, _emailController),
            const SizedBox(height: 20),
            buildLabel("Password"),
            buildTextField(
              "Create password",
              Icons.lock_outline,
              _passwordController,
              isPassword: true,
              isObscured: !_isPasswordVisible,
              onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            const SizedBox(height: 40),
            buildButton("Register", _isLoading, _signup),
          ],
        ),
      ),
    );
  }
}

// --- Helper Widgets ---

Widget roleOption(String title, String value, String currentSelected, Function(String) onTap) {
  bool isSelected = currentSelected == value;
  return GestureDetector(
    onTap: () => onTap(value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isSelected ? primaryGreen : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? primaryGreen : Colors.grey.shade200),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}

Widget buildLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0, left: 4),
    child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: darkText.withOpacity(0.8))),
  );
}

Widget buildTextField(String hint, IconData icon, TextEditingController controller, {bool isPassword = false, bool isObscured = false, VoidCallback? onToggleVisibility}) {
  return TextField(
    controller: controller,
    obscureText: isPassword ? isObscured : false,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: primaryGreen, size: 20),
      suffixIcon: isPassword ? IconButton(icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20), onPressed: onToggleVisibility) : null,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryGreen, width: 1.5)),
    ),
  );
}

Widget buildButton(String label, bool isLoading, VoidCallback onPressed) {
  return SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ),
  );
}