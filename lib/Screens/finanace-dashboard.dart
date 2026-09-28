// DUPLICATE DASHBOARD
// ONLY FOR PARTICULAR USER

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// --- Your existing imports ---
import 'Bottom-Navigation-Screens/date-Calculator.dart';
import 'Bottom-Navigation-Screens/loan-compare.dart';
import 'Calculators/CarBikeLoanEMI-Screen.dart';
import 'Calculators/EducationLoanEMI-Screen.dart';
import 'Calculators/FDCalculator-Screen.dart';
import 'Calculators/HomeLoan-Screen.dart';
import 'Calculators/LumpsumInvestment-Screen.dart';
import 'Calculators/MutualFundReturns-Screen.dart';
import 'Calculators/PersonalLoanEMI-Screen.dart';
import 'Calculators/PostOfficeFDCalculator-Screen.dart';
import 'Calculators/PostOfficeRDCalculator-Screen.dart';
import 'Calculators/RDCalculatorScreen.dart';
import 'Calculators/SIPCalculator-Screen.dart';
import 'Calculators/StockReturnCalculator-Screen.dart';
import 'Drawer-Screens/about-us-screen.dart';
import 'Drawer-Screens/currency-converter.dart';
import 'Drawer-Screens/settings-screen.dart';
import 'Drawer-Screens/unit-converter-screen.dart';
import 'Drawer-Screens/user-profile.dart';

class FinanceDashboard extends StatefulWidget {
  const FinanceDashboard({super.key});

  @override
  State<FinanceDashboard> createState() => _FinanceDashboardState();
}

class _FinanceDashboardState extends State<FinanceDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Helper to check if a section should be visible
  bool _isSectionVisible(List<dynamic> allowed, List<String> sectionTitles) {
    return sectionTitles.any((title) => allowed.contains(title));
  }

  // Helper to build conditional items
  Widget _buildPermittedItem(String title, IconData icon, Widget page, List<dynamic> allowed) {
    if (!allowed.contains(title)) return const SizedBox.shrink();
    return gestureCard(title, icon, page);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      // Listening to the current user's document for real-time access updates
      stream: FirebaseFirestore.instance.collection('user').doc(currentUser?.uid).snapshots(),
      builder: (context, snapshot) {
        List<dynamic> allowedCalculators = [];

        if (snapshot.hasData && snapshot.data!.exists) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          allowedCalculators = data['accessibleCalculators'] ?? [];
        }

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          drawer: _buildDrawer(), // Drawer logic remains same
          appBar: _buildAppBar(allowedCalculators),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- LOAN SECTION ---
                if (_isSectionVisible(allowedCalculators, ["Home Loan EMI", "Personal Loan EMI", "Car / Bike Loan EMI", "Education Loan EMI"])) ...[
                  sectionTitle("Loan & Debt Calculators"),
                  _buildPermittedItem("Home Loan EMI", Icons.home_outlined, const HomeLoanScreen(), allowedCalculators),
                  _buildPermittedItem("Personal Loan EMI", Icons.person_outline, const PersonalLoanScreen(), allowedCalculators),
                  _buildPermittedItem("Car / Bike Loan EMI", Icons.directions_car_outlined, const VehicleLoanScreen(), allowedCalculators),
                  _buildPermittedItem("Education Loan EMI", Icons.school_outlined, const EducationalLoanScreen(), allowedCalculators),
                ],

                // --- INVESTMENT SECTION ---
                if (_isSectionVisible(allowedCalculators, ["SIP Calculator", "Mutual Fund Return", "Lumpsum Investment", "Stock Return"])) ...[
                  sectionTitle("Investment & Wealth Calculators"),
                  _buildPermittedItem("SIP Calculator", Icons.trending_up, const SIPCalculatorScreen(), allowedCalculators),
                  _buildPermittedItem("Mutual Fund Return", Icons.bar_chart, const MutualFundCalculatorScreen(), allowedCalculators),
                  _buildPermittedItem("Lumpsum Investment", Icons.pie_chart_outline, const LumpsumCalculatorScreen(), allowedCalculators),
                  _buildPermittedItem("Stock Return", Icons.show_chart, const StockReturnCalculatorScreen(), allowedCalculators),
                ],

                // --- BANKING SECTION ---
                if (_isSectionVisible(allowedCalculators, ["Fixed Deposit (FD)", "Recurring Deposit (RD)", "Post Office RD", "Post Office FD"])) ...[
                  sectionTitle("Banking & Deposit Calculators"),
                  _buildPermittedItem("Fixed Deposit (FD)", Icons.savings_outlined, const FDCalculatorScreen(), allowedCalculators),
                  _buildPermittedItem("Recurring Deposit (RD)", Icons.calculate_outlined, const RDCalculatorScreen(), allowedCalculators),
                  _buildPermittedItem("Post Office RD", Icons.account_balance_outlined, const PostOfficeRDCalculator(), allowedCalculators),
                  _buildPermittedItem("Post Office FD", Icons.attach_money, const PostOfficeFDCalculator(), allowedCalculators),
                ],

                // Fallback if nothing is allowed
                if (allowedCalculators.isEmpty && snapshot.connectionState == ConnectionState.active)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Text("No calculators assigned. Contact Admin.", style: TextStyle(color: Colors.grey)),
                    ),
                  ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  // --- UI Components (Same as your original code) ---

  PreferredSizeWidget _buildAppBar(List<dynamic> allowed) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Color(0xFF44474b)),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: const Text("FinSphere Calc", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Color(0xFF44474b))),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF44474b)),
          onPressed: () => showSearch(context: context, delegate: CalculatorSearchDelegate(allowed)),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Color(0xFFf2faf7)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Text("FinSphere Calc", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text("v1.0.4", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          drawerItem(Icons.settings_outlined, "Settings", const SettingsScreen()),
          drawerItem(Icons.currency_exchange_outlined, "Currency Converter", const CurrencyConverterScreen()),
          drawerItem(Icons.straighten_outlined, "Unit Converter", const UnitConverterScreen()),
          const Divider(),
          drawerItem(Icons.info_outline, "About Us", const AboutUsScreen()),
          drawerItem(Icons.person_outline, "User Profile", const UserProfileScreen()),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: const Color(0xFF00D09C),
      onTap: (index) {
        if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (context) => const LoanCompareScreen()));
        if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (context) => const DateCalculatorScreen()));
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Explore"),
        BottomNavigationBarItem(icon: Icon(Icons.compare_arrows_sharp), label: "Loan Compare"),
        BottomNavigationBarItem(icon: Icon(Icons.date_range_sharp), label: "Date Calculator"),
      ],
    );
  }

  Widget drawerItem(IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF44474b)),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12, left: 4),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF7c7e8c))),
    );
  }

  Widget gestureCard(String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFedf2f7), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFf2faf7), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: const Color(0xFF00D09C), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 15, color: Color(0xFF44474b), fontWeight: FontWeight.w600))),
            const Icon(Icons.keyboard_arrow_right, size: 20, color: Color(0xFF7c7e8c)),
          ],
        ),
      ),
    );
  }
}

// --- UPDATED SEARCH DELEGATE ---
class CalculatorSearchDelegate extends SearchDelegate {
  final List<dynamic> allowedCalculators;
  CalculatorSearchDelegate(this.allowedCalculators);

  final List<Map<String, dynamic>> calculators = [
    {"title": "Home Loan EMI", "icon": Icons.home_outlined, "page": const HomeLoanScreen()},
    {"title": "Personal Loan EMI", "icon": Icons.person_outline, "page": const PersonalLoanScreen()},
    {"title": "Car / Bike Loan EMI", "icon": Icons.directions_car_outlined, "page": const VehicleLoanScreen()},
    {"title": "Education Loan EMI", "icon": Icons.school_outlined, "page": const EducationalLoanScreen()},
    {"title": "SIP Calculator", "icon": Icons.trending_up, "page": const SIPCalculatorScreen()},
    {"title": "Mutual Fund Return", "icon": Icons.bar_chart, "page": const MutualFundCalculatorScreen()},
    {"title": "Lumpsum Investment", "icon": Icons.pie_chart_outline, "page": const LumpsumCalculatorScreen()},
    {"title": "Stock Return", "icon": Icons.show_chart, "page": const StockReturnCalculatorScreen()},
    {"title": "Fixed Deposit (FD)", "icon": Icons.savings_outlined, "page": const FDCalculatorScreen()},
    {"title": "Recurring Deposit (RD)", "icon": Icons.calculate_outlined, "page": const RDCalculatorScreen()},
    {"title": "Post Office RD", "icon": Icons.account_balance_outlined, "page": const PostOfficeRDCalculator()},
    {"title": "Post Office FD", "icon": Icons.attach_money, "page": const PostOfficeFDCalculator()},
  ];

  @override
  List<Widget>? buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    // Filters by text search AND by admin permissions
    final suggestions = calculators.where((calc) {
      bool matchesSearch = calc['title'].toLowerCase().contains(query.toLowerCase());
      bool isAllowed = allowedCalculators.contains(calc['title']);
      return matchesSearch && isAllowed;
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final item = suggestions[index];
        return ListTile(
          leading: Icon(item['icon'], color: const Color(0xFF00D09C)),
          title: Text(item['title']),
          onTap: () {
            close(context, null);
            Navigator.push(context, MaterialPageRoute(builder: (context) => item['page']));
          },
        );
      },
    );
  }
}