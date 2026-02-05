import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../providers/theme_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const String BASE_URL = 'http://localhost:5000';

  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _isLoading = true;
  bool _isSaving = false; // Added for save button loading state
  String? _errorMessage;

  // User data fields (fetched from API)
  int _heightFt = 0;
  int _heightIn = 0;
  int _weightLbs = 0;
  int _age = 0;
  String _phoneNumber = "";
  String _email = "";
  String _displayName = "";
  String _joined = "";

  // Temporary edit fields (used in edit sheet)
  late String _editDisplayName;
  late String _editEmail;
  late String _editPhoneNumber;
  late int _editHeightFt;
  late int _editHeightIn;
  late int _editWeightLbs;
  late int _editAge;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  /// Fetch user info from the backend API
  Future<void> _fetchUserInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = "No user logged in";
          _isLoading = false;
        });
        return;
      }

      // Get the Firebase ID token
      final idToken = await user.getIdToken();

      final uri = Uri.parse('$BASE_URL/api/auth/get-userInfo');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'];

        setState(() {
          _displayName = data['displayName'] ?? '';
          _email = data['email'] ?? '';
          _phoneNumber = data['phoneNumber'] ?? '';
          _heightFt = int.tryParse(data['heightFt']?.toString() ?? '') ?? 0;
          _heightIn = int.tryParse(data['heightIn']?.toString() ?? '') ?? 0;
          _weightLbs = int.tryParse(data['weight']?.toString() ?? '') ?? 0;
          _age = int.tryParse(data['age']?.toString() ?? '') ?? 0;

          // Format the joined date from createdAt
          if (data['createdAt'] != null) {
            try {
              DateTime createdAt;
              if (data['createdAt'] is Map &&
                  data['createdAt']['_seconds'] != null) {
                // Firestore Timestamp format
                createdAt = DateTime.fromMillisecondsSinceEpoch(
                    data['createdAt']['_seconds'] * 1000);
              } else {
                createdAt = DateTime.parse(data['createdAt'].toString());
              }
              _joined = _formatJoinedDate(createdAt);
            } catch (e) {
              _joined = "Unknown";
            }
          } else {
            _joined = "Unknown";
          }

          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load profile data";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }

  /// Format the createdAt date to "Mon YYYY" format
  String _formatJoinedDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return "${months[date.month - 1]} ${date.year}";
  }

  /// Update user info via the backend API
  Future<bool> _updateUserInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user logged in')),
        );
        return false;
      }

      // Update Firebase Auth profile if displayName changed
      if (_editDisplayName != _displayName && _editDisplayName.isNotEmpty) {
        try {
          await user.updateDisplayName(_editDisplayName);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to update display name in Firebase Auth: $e')),
          );
        }
      }

      // Update Firebase Auth email if changed
      if (_editEmail != _email && _editEmail.isNotEmpty) {
        try {
          await user.verifyBeforeUpdateEmail(_editEmail);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Verification email sent. Please verify your new email address.'),
              duration: Duration(seconds: 4),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to update email in Firebase Auth: $e')),
          );
          // Don't return false here - continue with other updates
        }
      }

      // Get fresh token after potential auth updates
      final idToken = await user.getIdToken(true);

      final uri = Uri.parse('$BASE_URL/api/auth/edit-userInfo');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode({
          'displayName': _editDisplayName,
          'email': _editEmail,
          'phoneNumber': _editPhoneNumber,
          'heightFt': _editHeightFt.toString(),
          'heightIn': _editHeightIn.toString(),
          'weight': _editWeightLbs.toString(),
          'age': _editAge.toString(),
        }),
      );

      if (response.statusCode == 200) {
        // Update local state with new values
        setState(() {
          _displayName = _editDisplayName;
          _email = _editEmail;
          _phoneNumber = _editPhoneNumber;
          _heightFt = _editHeightFt;
          _heightIn = _editHeightIn;
          _weightLbs = _editWeightLbs;
          _age = _editAge;
        });
        return true;
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to update: ${errorData['error'] ?? 'Unknown error'}')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      return false;
    }
  }

  /// Delete user profile via the backend API
  Future<void> _deleteUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user logged in')),
        );
        return;
      }

      final idToken = await user.getIdToken();

      final uri = Uri.parse('$BASE_URL/api/auth/delete-userProfile');
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        // Sign out user
        await FirebaseAuth.instance.signOut();

        // Navigate to login screen
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/', // Navigate to home/root
            (route) => false,
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to delete account: ${errorData['error'] ?? 'Unknown error'}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    //StrongSight colors
    const ivory = Color(0xFFF3EBD3);
    const green = Color(0xFF094941);
    const espresso = Color(0xFF12110F);
    const darkModeGreen = Color(0xFF039E39);
    const lightModeGreen = Color(0xFF094941);

    final bgColor = isDark ? espresso : const Color(0xFFFCF5E3);
    final cardColor = isDark ? const Color(0xFF1A1917) : Colors.white;
    final textColor = isDark ? darkModeGreen : lightModeGreen;
    final subTextColor = isDark ? const Color(0xFFD9CBB8) : Colors.grey[700]!;
    final accentColor = isDark ? darkModeGreen : lightModeGreen;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: ivory,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: green,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: green),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: accentColor),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: subTextColor),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchUserInfo,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildUserCard(cardColor, textColor, subTextColor),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Settings", textColor),
                        const SizedBox(height: 10),
                        _buildSettingsCard(themeProvider, cardColor, textColor,
                            accentColor, subTextColor),
                        const SizedBox(height: 24),
                        _buildSectionTitle(
                            "Progress & Improvements", textColor),
                        const SizedBox(height: 10),
                        _buildProgressSection(
                            cardColor, textColor, accentColor, subTextColor),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ---------- USER CARD ----------
  Widget _buildUserCard(Color cardColor, Color textColor, Color subTextColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage:
                AssetImage('assets/images/profile_placeholder.png'),
          ),
          const SizedBox(height: 16),
          Text(
            _displayName.isNotEmpty ? _displayName : "User",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _email,
            style: TextStyle(color: subTextColor, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Divider(color: textColor.withOpacity(0.4)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _InfoTile(
                  label: "Phone",
                  value: _phoneNumber.isNotEmpty ? _phoneNumber : "N/A",
                  labelColor: textColor,
                  valueColor: subTextColor),
              _InfoTile(
                  label: "Height",
                  value: "${_heightFt}'${_heightIn}\"",
                  labelColor: textColor,
                  valueColor: subTextColor),
              _InfoTile(
                  label: "Weight",
                  value: "${_weightLbs} lbs",
                  labelColor: textColor,
                  valueColor: subTextColor),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _InfoTile(
                  label: "Age",
                  value: "$_age",
                  labelColor: textColor,
                  valueColor: subTextColor),
              _InfoTile(
                  label: "Joined",
                  value: _joined,
                  labelColor: textColor,
                  valueColor: subTextColor),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- SETTINGS ----------
  Widget _buildSettingsCard(
    ThemeProvider themeProvider,
    Color cardColor,
    Color textColor,
    Color accentColor,
    Color subTextColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Notifications ---
            SwitchListTile(
              activeColor: accentColor,
              title:
                  Text("Notifications", style: TextStyle(color: subTextColor)),
              value: _notificationsEnabled,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
            Divider(color: Colors.grey.withOpacity(0.3), height: 0),

            // --- App Sounds ---
            SwitchListTile(
              activeColor: accentColor,
              title: Text("App Sounds", style: TextStyle(color: subTextColor)),
              value: _soundEnabled,
              onChanged: (val) => setState(() => _soundEnabled = val),
            ),
            Divider(color: Colors.grey.withOpacity(0.3), height: 0),

            // --- Dark Mode ---
            SwitchListTile(
              title: Text("Dark Mode", style: TextStyle(color: subTextColor)),
              activeColor: accentColor,
              value: themeProvider.isDarkMode,
              onChanged: (value) => themeProvider.toggleTheme(value),
            ),
            const SizedBox(height: 16),

            // --- Edit Profile Button ---
            ElevatedButton.icon(
              icon: const Icon(Icons.edit, size: 20),
              label: const Text("Edit Profile", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                _showEditProfileSheet(
                    context, cardColor, textColor, accentColor, subTextColor);
              },
            ),
            const SizedBox(height: 12),

            // --- Delete Profile Button ---
            ElevatedButton.icon(
              icon: const Icon(Icons.delete_outline, size: 20),
              label:
                  const Text("Delete Profile", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete Profile?"),
                    content: const Text(
                      "This action cannot be undone. All your data and workouts will be permanently deleted. Are you sure you want to delete your profile?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _deleteUserProfile();
                        },
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------- EDIT PROFILE BOTTOM SHEET ----------
  void _showEditProfileSheet(BuildContext context, Color cardColor,
      Color textColor, Color accentColor, Color subTextColor) {
    // Initialize temporary edit values
    _editDisplayName = _displayName;
    _editEmail = _email;
    _editPhoneNumber = _phoneNumber;
    _editHeightFt = _heightFt;
    _editHeightIn = _heightIn;
    _editWeightLbs = _weightLbs;
    _editAge = _age;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 5,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Input Fields ---
                    _buildEditableTextField(
                      label: "Full Name",
                      initialValue: _editDisplayName,
                      onChanged: (v) {
                        _editDisplayName = v;
                      },
                      textColor: textColor,
                      subTextColor: subTextColor,
                      accentColor: accentColor,
                    ),
                    _buildEditableTextField(
                      label: "Email",
                      initialValue: _editEmail,
                      onChanged: (v) {
                        _editEmail = v;
                      },
                      textColor: textColor,
                      subTextColor: subTextColor,
                      accentColor: accentColor,
                    ),
                    _buildEditableTextField(
                      label: "Phone",
                      initialValue: _editPhoneNumber,
                      onChanged: (v) {
                        _editPhoneNumber = v;
                      },
                      textColor: textColor,
                      subTextColor: subTextColor,
                      accentColor: accentColor,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _buildHeightPickerField(
                            context,
                            textColor,
                            subTextColor,
                            accentColor,
                            setModalState,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildWeightPickerField(
                            context,
                            textColor,
                            subTextColor,
                            accentColor,
                            setModalState,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildAgePickerField(
                      context,
                      textColor,
                      subTextColor,
                      accentColor,
                      setModalState,
                    ),

                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: const Color(0xFFF3EBD3),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _isSaving
                            ? null
                            : () async {
                                setState(() {
                                  _isSaving = true;
                                });
                                setModalState(() {
                                  _isSaving = true;
                                });

                                // Attempt to update user info
                                final success = await _updateUserInfo();

                                setState(() {
                                  _isSaving = false;
                                });

                                if (success) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Profile updated successfully.")),
                                  );
                                } else {
                                  setModalState(() {
                                    _isSaving = false;
                                  });
                                }
                              },
                        child: _isSaving
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Save Changes",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------- HEIGHT PICKER FIELD ----------
  Widget _buildHeightPickerField(BuildContext context, Color textColor,
      Color subTextColor, Color accentColor, StateSetter setModalState) {
    return GestureDetector(
      onTap: () => _showHeightPicker(context, accentColor, setModalState),
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            labelText: "Height",
            hintText: "${_editHeightFt}' ${_editHeightIn}\"",
            suffixIcon: Icon(Icons.height, color: subTextColor),
          ),
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }

  // ---------- HEIGHT SCROLL PICKER ----------
  void _showHeightPicker(
      BuildContext context, Color accentColor, StateSetter setModalState) {
    int tempFt = _editHeightFt;
    int tempIn = _editHeightIn;

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
                        scrollController: FixedExtentScrollController(
                            initialItem: tempFt > 2 ? tempFt - 3 : 0),
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
                        scrollController:
                            FixedExtentScrollController(initialItem: tempIn),
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
                  setModalState(() {
                    _editHeightFt = tempFt;
                    _editHeightIn = tempIn;
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

  // ---------- WEIGHT PICKER FIELD ----------
  Widget _buildWeightPickerField(
    BuildContext context,
    Color textColor,
    Color subTextColor,
    Color accentColor,
    StateSetter setModalState,
  ) {
    return GestureDetector(
      onTap: () => _showWeightPicker(context, accentColor, setModalState),
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            labelText: "Weight",
            hintText: "$_editWeightLbs lbs",
            suffixIcon: Icon(Icons.monitor_weight, color: subTextColor),
          ),
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }

  // ---------- WEIGHT SCROLL PICKER ----------
  void _showWeightPicker(
      BuildContext context, Color accentColor, StateSetter setModalState) {
    int tempWeight = _editWeightLbs;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text(
                "Select Weight",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                    initialItem: tempWeight > 79 ? tempWeight - 80 : 0,
                  ),
                  onSelectedItemChanged: (i) => tempWeight = i + 80,
                  children: List.generate(
                    221, // 80 lbs → 300 lbs
                    (i) => Center(
                      child: Text(
                        "${i + 80} lbs",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                onPressed: () {
                  setModalState(() {
                    _editWeightLbs = tempWeight;
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

  // ---------- AGE PICKER FIELD ----------
  Widget _buildAgePickerField(
    BuildContext context,
    Color textColor,
    Color subTextColor,
    Color accentColor,
    StateSetter setModalState,
  ) {
    return GestureDetector(
      onTap: () => _showAgePicker(context, accentColor, setModalState),
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            labelText: "Age",
            hintText: "$_editAge",
            suffixIcon: Icon(Icons.cake, color: subTextColor),
          ),
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }

  // ---------- AGE SCROLL PICKER ----------
  void _showAgePicker(
      BuildContext context, Color accentColor, StateSetter setModalState) {
    int tempAge = _editAge;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text(
                "Select Age",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                      initialItem: tempAge > 12 ? tempAge - 13 : 0),
                  onSelectedItemChanged: (i) => tempAge = i + 13,
                  children: List.generate(
                    88, // Ages 13 → 100
                    (i) => Center(
                      child: Text(
                        "${i + 13}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                onPressed: () {
                  setModalState(() {
                    _editAge = tempAge;
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

  //Editable text field for phone and email
  Widget _buildEditableTextField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
    required Color textColor,
    required Color subTextColor,
    required Color accentColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: initialValue,
        style: TextStyle(color: textColor),
        cursorColor: accentColor,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: subTextColor),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: subTextColor.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String value, Color textColor,
      Color subTextColor, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        style: TextStyle(color: textColor),
        cursorColor: accentColor,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: subTextColor),
          hintText: value,
          hintStyle: TextStyle(color: subTextColor.withOpacity(0.6)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: subTextColor.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
    );
  }

  // ---------- PROGRESS ----------
  Widget _buildProgressSection(
      Color cardColor, Color textColor, Color accentColor, Color subTextColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProgressBar(
            label: "Bench Press",
            current: 205,
            goal: 225,
            color: textColor, //Progress bars fill color
            subTextColor: subTextColor,
            textColor: subTextColor, //Color for "Bench Press"
          ),
          const SizedBox(height: 14),
          _ProgressBar(
            label: "Squat",
            current: 275,
            goal: 315,
            color: textColor,
            subTextColor: subTextColor,
            textColor: subTextColor,
          ),
          const SizedBox(height: 14),
          _ProgressBar(
            label: "Deadlift",
            current: 315,
            goal: 365,
            color: textColor,
            subTextColor: subTextColor,
            textColor: subTextColor,
          ),
          const SizedBox(height: 14),
          _ProgressBar(
            label: "Body Fat % Reduction",
            current: 18,
            goal: 12,
            color: textColor,
            isPercentage: true,
            subTextColor: subTextColor,
            textColor: subTextColor,
          ),
        ],
      ),
    );
  }
}

// ---------- INFO TILE ----------
class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;

  const _InfoTile(
      {required this.label,
      required this.value,
      required this.labelColor,
      required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: labelColor)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor, //green
          ),
        ),
      ],
    );
  }
}

// ---------- PROGRESS BAR ----------
class _ProgressBar extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final Color color;
  final bool isPercentage;
  final Color subTextColor;
  final Color textColor;

  const _ProgressBar({
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
    required this.textColor,
    required this.subTextColor,
    this.isPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    double progress = current / goal;
    if (isPercentage) progress = (goal - current).abs() / goal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 10,
            color: color,
            backgroundColor: const Color(0xFFDAD7CD),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isPercentage
              ? "${(progress * 100).toStringAsFixed(1)}% complete"
              : "${current.toInt()} / ${goal.toInt()} lbs",
          style: TextStyle(fontSize: 13, color: subTextColor),
        ),
      ],
    );
  }
}
