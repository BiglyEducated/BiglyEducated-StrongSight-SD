import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    //StrongSight colors
    const ivory = Color(0xFFF3EBD3);
    const green = Color(0xFF094941);
    const espresso = Color(0xFF12110F);
    const darkModeGreen = Color(0xFF039E39); //lighter pastel green
    const lightModeGreen = Color(0xFF094941); //darker deep green


    final bgColor = isDark ? espresso : const Color(0xFFFCF5E3);
    final cardColor = isDark ? const Color(0xFF1A1917) : Colors.white;
    
    final textColor = isDark ? darkModeGreen : lightModeGreen;
    final subTextColor = isDark ? const Color(0xFFD9CBB8) : Colors.grey[700]!;
    final accentColor = isDark ? darkModeGreen : lightModeGreen;


    return Scaffold(
      backgroundColor: bgColor,

      //Ivory top bar with green text
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

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUserCard(cardColor, textColor, subTextColor),
              const SizedBox(height: 24),
              _buildSectionTitle("Settings", textColor),
              const SizedBox(height: 10),
              _buildSettingsCard(themeProvider, cardColor, textColor, accentColor, subTextColor),
              const SizedBox(height: 24),
              _buildSectionTitle("Progress & Improvements", textColor),
              const SizedBox(height: 10),
              _buildProgressSection(cardColor, textColor, accentColor, subTextColor),
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
            backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
          ),
          const SizedBox(height: 16),
          Text(
            "Yoendry Ferro",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "yoendry@example.com",
            style: TextStyle(color: subTextColor, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Divider(color: textColor.withOpacity(0.4)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _InfoTile(label: "Phone", value: "(407) 555-1234", labelColor: textColor, valueColor: subTextColor),
              _InfoTile(label: "Height", value: "5'10\"", labelColor: textColor, valueColor: subTextColor),
              _InfoTile(label: "Weight", value: "160 lbs", labelColor: textColor, valueColor: subTextColor),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _InfoTile(label: "Age", value: "23", labelColor: textColor, valueColor: subTextColor),
              _InfoTile(label: "Goal", value: "Muscle Gain", labelColor: textColor, valueColor: subTextColor),
              _InfoTile(label: "Joined", value: "Feb 2025", labelColor: textColor, valueColor: subTextColor),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- SETTINGS ----------
  Widget _buildSettingsCard(ThemeProvider themeProvider, Color cardColor, Color textColor, Color accentColor, Color subTextColor) {
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
      child: Column(
        children: [
          SwitchListTile(
            activeColor: accentColor,
            title: Text("Notifications", style: TextStyle(color: subTextColor)),
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),
          Divider(color: Colors.grey.withOpacity(0.3), height: 0),
          SwitchListTile(
            activeColor: accentColor,
            title: Text("App Sounds", style: TextStyle(color: subTextColor)),
            value: _soundEnabled,
            onChanged: (val) => setState(() => _soundEnabled = val),
          ),
          Divider(color: Colors.grey.withOpacity(0.3), height: 0),
          SwitchListTile(
            title: Text("Dark Mode", style: TextStyle(color: subTextColor)),
            activeColor: accentColor,
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(value),
          ),
        ],
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
  Widget _buildProgressSection(Color cardColor, Color textColor, Color accentColor, Color subTextColor) {
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
            color: textColor,  //Progress bars fill color
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

  const _InfoTile({required this.label, required this.value, required this.labelColor, required this.valueColor});

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
