import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Mock State Variables
  String selectedCurrency = "INR (₹)";
  String selectedLanguage = "English";
  String selectedNumberFormat = "India (00,00,000.00)";
  String selectedDecimals = "123.45";
  bool bioLock = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF44474b),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xFF44474b),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _settingsHeader("REGIONAL SETTINGS"),
          _settingsTile(
            icon: Icons.currency_rupee,
            title: "Default Currency",
            subtitle: selectedCurrency,
            onTap: () => _showSelectionDialog(
              "Currency",
              ["INR (₹)", "USD (\$)", "EUR (€)", "GBP (£)"],
              (val) {
                setState(() => selectedCurrency = val);
              },
            ),
          ),
          _settingsTile(
            icon: Icons.language,
            title: "Language",
            subtitle: selectedLanguage,
            onTap: () => _showSelectionDialog(
              "Language",
              ["English", "Hindi", "Spanish", "French"],
              (val) {
                setState(() => selectedLanguage = val);
              },
            ),
          ),

          const SizedBox(height: 24),
          _settingsHeader("FORMATTING"),
          _settingsTile(
            icon: Icons.format_list_numbered,
            title: "Number Format",
            subtitle: selectedNumberFormat,
            onTap: () => _showSelectionDialog(
              "Number Format",
              [
                "India (00,00,000.00)",
                "Western (0,000,000.00)",
                "European (1.000.000,00)",
              ],
              (val) {
                setState(() => selectedNumberFormat = val);
              },
            ),
          ),
          _settingsTile(
            icon: Icons.add,
            title: "Decimal Precision",
            subtitle: selectedDecimals,
            onTap: () => _showSelectionDialog(
              "Decimal Precision",
              ["123 (Zero)", "123.4 (One)", "123.45 (Two)", "123.456 (Three)"],
              (val) {
                setState(() => selectedDecimals = val);
              },
            ),
          ),

          const SizedBox(height: 24),
          _settingsHeader("SECURITY & APP"),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint, color: Color(0xFF44474b)),
            title: const Text(
              "Biometric Lock",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            activeColor: const Color(0xFF00D09C),
            value: bioLock,
            onChanged: (val) => setState(() => bioLock = val),
          ),
          _settingsTile(
            icon: Icons.dark_mode_outlined,
            title: "Theme",
            subtitle: "Light Mode",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.delete_outline,
            title: "Clear Calculation History",
            subtitle: "Wipe all saved data",
            isDanger: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _settingsHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF7c7e8c),
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDanger
              ? Colors.red.withOpacity(0.05)
              : const Color(0xFFf8f9fb),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDanger ? Colors.red : const Color(0xFF44474b),
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: isDanger ? Colors.red : const Color(0xFF44474b),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF7c7e8c), fontSize: 13),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF7c7e8c),
        size: 18,
      ),
      onTap: onTap,
    );
  }

  // Simple bottom sheet for selection
  void _showSelectionDialog(
    String title,
    List<String> options,
    Function(String) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select $title",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Divider(),
              ...options.map(
                (option) => ListTile(
                  title: Text(option),
                  onTap: () {
                    onSelect(option);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
