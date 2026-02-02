import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // ✅ ADDED (for CupertinoPicker)
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../providers/theme_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---- Controllers ----
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightFtController = TextEditingController();
  final TextEditingController _heightInController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  // ---- Wheel-selected values ---- ✅ ADDED
  int? _heightFt;
  int? _heightIn;
  int? _weightLbs;
  int? _age;

  // ---- Toggle visibility ----
  bool _passwordVisible = false;
  bool _confirmVisible = false;

  String? _selectedGender;
  bool _isLoading = false;

  static const String BASE_URL = 'http://localhost:5000';

  /// Create user in Firebase Auth, then store additional fields in backend
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Step 1: Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to create user');
      }

      // Step 2: Update display name in Firebase
      await user.updateDisplayName(_nameController.text);

      // Step 3: Store additional user data in backend
      final phoneWithCountryCode = '+1${_phoneController.text}';
      await _storeUserDataInBackend(
        uid: user.uid,
        email: _emailController.text.trim(),
        displayName: _nameController.text,
        phoneNumber: phoneWithCountryCode,
        gender: _selectedGender,

        // ✅ CHANGED: send wheel values (what the user actually picked)
        weight: _weightLbs?.toString(),
        age: _age?.toString(),
        heightFt: _heightFt?.toString(),
        heightIn: _heightIn?.toString(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      // This will catch all errors, including FirebaseAuthException on web
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

  /// Store additional user data in backend
  Future<void> _storeUserDataInBackend({
    required String uid,
    required String email,
    required String displayName,
    required String phoneNumber,
    String? gender,
    String? weight,
    String? age,
    String? heightFt,
    String? heightIn,
  }) async {
    final uri = Uri.parse('$BASE_URL/api/auth/signup');

    final body = {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'weight': weight,
      'age': age,
      'heightFt': heightFt,
      'heightIn': heightIn,
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to store user data: ${response.body}');
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
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          "Create Account",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
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
                      color: textColor),
                ),
                const SizedBox(height: 24),
                _textField(_nameController, "Full Name", cardColor, textColor,
                    subTextColor, accentColor,
                    validator: (v) => v!.isEmpty ? 'Enter your name' : null),
                _textField(_emailController, "Email", cardColor, textColor,
                    subTextColor, accentColor,
                    validator: (v) =>
                        v!.contains('@') ? null : 'Enter valid email'),
                _passwordField(_passwordController, "Password", cardColor,
                    textColor, subTextColor, accentColor,
                    visible: _passwordVisible,
                    toggle: () =>
                        setState(() => _passwordVisible = !_passwordVisible)),
                _passwordField(_confirmController, "Confirm Password",
                    cardColor, textColor, subTextColor, accentColor,
                    visible: _confirmVisible,
                    toggle: () =>
                        setState(() => _confirmVisible = !_confirmVisible),
                    validator: (v) => v == _passwordController.text
                        ? null
                        : "Passwords do not match"),
                _textField(_phoneController, "Phone Number", cardColor,
                    textColor, subTextColor, accentColor,
                    validator: (v) => v!.isEmpty ? 'Enter phone number' : null),
                const SizedBox(height: 14),
                _buildAgePickerField(
                    context, cardColor, textColor, subTextColor, accentColor),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  dropdownColor: cardColor,
                  style: TextStyle(color: textColor),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (v) => setState(() => _selectedGender = v),
                  decoration: _inputDecoration(
                      "Gender", cardColor, subTextColor, accentColor),
                  validator: (v) => v == null ? 'Select gender' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildHeightPickerField(context, cardColor,
                          textColor, subTextColor, accentColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildWeightPickerField(context, cardColor,
                          textColor, subTextColor, accentColor),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: ivory,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: ivory),
                          )
                        : const Text("Continue",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= PICKER FIELDS =================

  Widget _buildHeightPickerField(BuildContext context, Color cardColor,
      Color textColor, Color subTextColor, Color accentColor) {
    final display = (_heightFt != null && _heightIn != null)
        ? "${_heightFt}' ${_heightIn}\""
        : "Select height";

    return GestureDetector(
      onTap: () => _showHeightPicker(context, accentColor),
      child: AbsorbPointer(
        child: TextFormField(
          decoration:
              _inputDecoration("Height", cardColor, subTextColor, accentColor)
                  .copyWith(
                      hintText: display,
                      suffixIcon: Icon(Icons.height, color: subTextColor)),
          style: TextStyle(color: textColor),
          validator: (_) =>
              (_heightFt == null || _heightIn == null) ? "Select height" : null,
        ),
      ),
    );
  }

  Widget _buildWeightPickerField(BuildContext context, Color cardColor,
      Color textColor, Color subTextColor, Color accentColor) {
    final display = _weightLbs != null ? "${_weightLbs} lbs" : "Select weight";

    return GestureDetector(
      onTap: () => _showWeightPicker(context, accentColor),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: _inputDecoration(
                  "Weight", cardColor, subTextColor, accentColor)
              .copyWith(
                  hintText: display,
                  suffixIcon: Icon(Icons.monitor_weight, color: subTextColor)),
          style: TextStyle(color: textColor),
          validator: (_) => _weightLbs == null ? "Select weight" : null,
        ),
      ),
    );
  }

  Widget _buildAgePickerField(BuildContext context, Color cardColor,
      Color textColor, Color subTextColor, Color accentColor) {
    final display = _age != null ? "$_age" : "Select age";

    return GestureDetector(
      onTap: () => _showAgePicker(context, accentColor),
      child: AbsorbPointer(
        child: TextFormField(
          decoration:
              _inputDecoration("Age", cardColor, subTextColor, accentColor)
                  .copyWith(
                      hintText: display,
                      suffixIcon: Icon(Icons.cake, color: subTextColor)),
          style: TextStyle(color: textColor),
          validator: (_) => _age == null ? "Select age" : null,
        ),
      ),
    );
  }

  // ================= WHEELS =================

  void _showHeightPicker(BuildContext context, Color accentColor) {
    int tempFt = _heightFt ?? 5;
    int tempIn = _heightIn ?? 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text("Select Height",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 40,
                        onSelectedItemChanged: (i) => tempFt = i + 3,
                        children: List.generate(
                            8,
                            (i) => Center(
                                child: Text("${i + 3} ft",
                                    style:
                                        const TextStyle(color: Colors.white)))),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 40,
                        onSelectedItemChanged: (i) => tempIn = i,
                        children: List.generate(
                            12,
                            (i) => Center(
                                child: Text("$i in",
                                    style:
                                        const TextStyle(color: Colors.white)))),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                onPressed: () {
                  setState(() {
                    _heightFt = tempFt;
                    _heightIn = tempIn;

                    // (optional) keep controllers in sync
                    _heightFtController.text = tempFt.toString();
                    _heightInController.text = tempIn.toString();
                  });
                  Navigator.pop(context);
                },
                child: const Text("Done"),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showWeightPicker(BuildContext context, Color accentColor) {
    int tempWeight = _weightLbs ?? 150;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text("Select Weight",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  onSelectedItemChanged: (i) => tempWeight = i + 80,
                  children: List.generate(
                      221,
                      (i) => Center(
                          child: Text("${i + 80} lbs",
                              style: const TextStyle(color: Colors.white)))),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                onPressed: () {
                  setState(() {
                    _weightLbs = tempWeight;

                    // (optional) keep controller in sync
                    _weightController.text = tempWeight.toString();
                  });
                  Navigator.pop(context);
                },
                child: const Text("Done"),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showAgePicker(BuildContext context, Color accentColor) {
    int tempAge = _age ?? 25;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text("Select Age",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  onSelectedItemChanged: (i) => tempAge = i + 13,
                  children: List.generate(
                      88,
                      (i) => Center(
                          child: Text("${i + 13}",
                              style: const TextStyle(color: Colors.white)))),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                onPressed: () {
                  setState(() {
                    _age = tempAge;

                    // (optional) keep controller in sync
                    _ageController.text = tempAge.toString();
                  });
                  Navigator.pop(context);
                },
                child: const Text("Done"),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // ================= INPUT DECORATION =================

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

  Widget _textField(
    TextEditingController controller,
    String hint,
    Color cardColor,
    Color textColor,
    Color subTextColor,
    Color accentColor, {
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: textColor),
        decoration:
            _inputDecoration(hint, cardColor, subTextColor, accentColor),
        validator: validator,
      ),
    );
  }

  Widget _passwordField(
    TextEditingController controller,
    String hint,
    Color cardColor,
    Color textColor,
    Color subTextColor,
    Color accentColor, {
    required bool visible,
    required VoidCallback toggle,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: !visible,
        style: TextStyle(color: textColor),
        decoration: _inputDecoration(hint, cardColor, subTextColor, accentColor)
            .copyWith(
          suffixIcon: IconButton(
            icon: Icon(visible ? Icons.visibility : Icons.visibility_off,
                color: subTextColor),
            onPressed: toggle,
          ),
        ),
        validator: validator,
      ),
    );
  }
}
