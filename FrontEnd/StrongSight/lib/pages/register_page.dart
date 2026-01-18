import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/theme_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // ---- Controllers ----
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightFtController = TextEditingController();
  final TextEditingController _heightInController = TextEditingController();

  // ---- Toggle visibility ----
  bool _passwordVisible = false;
  bool _confirmVisible = false;

  String? _selectedGender;
  bool _isLoading = false;

  // Replace with your backend URL (no trailing slash).
  // For Android emulator use 10.0.2.2 if backend runs on localhost of the host machine.
  static const String BASE_URL = 'http://localhost:5000';

  Future<http.Response> _signupToApi({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? gender,
    String? weight,
    String? heightFt,
    String? heightIn,
  }) async {
    final uri = Uri.parse('$BASE_URL/api/auth/signup');

    final body = {
      'displayName': name,
      'email': email,
      'password': password,
      'phoneNumber': phone,
      'gender': gender,
      'weight': weight,
      'heightFt': heightFt,
      'heightIn': heightIn,
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    return response;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {

      final phoneWithCountryCode = '+1${_phoneController.text}';
      final response = await _signupToApi(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone: phoneWithCountryCode,
        gender: _selectedGender,
        weight: _weightController.text,
        heightFt: _heightFtController.text,
        heightIn: _heightInController.text,
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // --- StrongSight Colors ---
    const ivory = Color(0xFFF3EBD3);
    const espresso = Color(0xFF12110F);
    const lightModeGreen = Color(0xFF094941);
    const darkModeGreen = Color(0xFF039E39);
    const darkCard = Color(0xFF1A1917);

    final bgColor = isDark ? espresso : const Color(0xFFFCF5E3);
    final cardColor = isDark ? darkCard : Colors.white;
    final textColor = isDark ? darkModeGreen : lightModeGreen;
    final subTextColor = isDark ? const Color(0xFFD9CBB8) : Colors.grey[700]!;
    final accentColor = isDark ? darkModeGreen : lightModeGreen;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? espresso : ivory,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          "Create Account",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      // --------------- BODY ---------------
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                Text(
                  "Let's Get Training!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 24),

                // ---------- Name ----------
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: textColor),
                  decoration: _inputDecoration(
                      "Full Name", cardColor, subTextColor, accentColor),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 14),

                // ---------- Email ----------
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: textColor),
                  decoration: _inputDecoration(
                      "Email", cardColor, subTextColor, accentColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your email';
                    } else if (!value.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ---------- Password ----------
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  style: TextStyle(color: textColor),
                  decoration: _inputDecoration(
                          "Password", cardColor, subTextColor, accentColor)
                      .copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: subTextColor,
                      ),
                      onPressed: () {
                        setState(() => _passwordVisible = !_passwordVisible);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ---------- Confirm Password ----------
                TextFormField(
                  controller: _confirmController,
                  obscureText: !_confirmVisible,
                  style: TextStyle(color: textColor),
                  decoration: _inputDecoration("Confirm Password", cardColor,
                          subTextColor, accentColor)
                      .copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _confirmVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: subTextColor,
                      ),
                      onPressed: () {
                        setState(() => _confirmVisible = !_confirmVisible);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Re-enter your password';
                    } else if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ---------- Phone ----------
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: textColor),
                  decoration: _inputDecoration(
                      "Phone Number", cardColor, subTextColor, accentColor),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter your phone number'
                      : null,
                ),
                const SizedBox(height: 14),

                // ---------- Gender ----------
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  dropdownColor: cardColor,
                  style: TextStyle(color: textColor, fontSize: 15),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) => setState(() => _selectedGender = value),
                  decoration: _inputDecoration(
                      "Gender", cardColor, subTextColor, accentColor),
                  validator: (value) =>
                      value == null ? 'Select your gender' : null,
                ),
                const SizedBox(height: 14),

                // ---------- Weight ----------
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: textColor),
                  decoration: _inputDecoration(
                      "Weight (lbs)", cardColor, subTextColor, accentColor),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter your weight'
                      : null,
                ),
                const SizedBox(height: 14),

                // ---------- Height ----------
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _heightFtController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textColor),
                        decoration: _inputDecoration("Height (ft)", cardColor,
                            subTextColor, accentColor),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'ft' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _heightInController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textColor),
                        decoration: _inputDecoration("Height (in)", cardColor,
                            subTextColor, accentColor),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'in' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // ---------- Continue Button ----------
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: ivory,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadowColor: isDark
                          ? Colors.transparent
                          : Colors.black.withOpacity(0.15),
                      elevation: isDark ? 0 : 3,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ivory,
                            ),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Reusable Input Decoration ----------
  InputDecoration _inputDecoration(
      String hint, Color cardColor, Color subTextColor, Color accentColor) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: subTextColor),
      filled: true,
      fillColor: cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: accentColor.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: accentColor, width: 1.8),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _phoneController.dispose();
    _weightController.dispose();
    _heightFtController.dispose();
    _heightInController.dispose();
    super.dispose();
  }
}
