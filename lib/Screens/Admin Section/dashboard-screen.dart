// ORIGINAL DASHBOARD
// ONLY FOR ADMIN

import 'package:finspere_calculator/Screens/Drawer-Screens/user-profile.dart';
import 'package:flutter/material.dart';

import '../Bottom-Navigation-Screens/date-Calculator.dart';
import '../Bottom-Navigation-Screens/loan-compare.dart';
import '../Calculators/CarBikeLoanEMI-Screen.dart';
import '../Calculators/EducationLoanEMI-Screen.dart';
import '../Calculators/FDCalculator-Screen.dart';
import '../Calculators/HomeLoan-Screen.dart';
import '../Calculators/LumpsumInvestment-Screen.dart';
import '../Calculators/MutualFundReturns-Screen.dart';
import '../Calculators/PersonalLoanEMI-Screen.dart';
import '../Calculators/PostOfficeFDCalculator-Screen.dart';
import '../Calculators/PostOfficeRDCalculator-Screen.dart';
import '../Calculators/RDCalculatorScreen.dart';
import '../Calculators/SIPCalculator-Screen.dart';
import '../Calculators/StockReturnCalculator-Screen.dart';
import '../Drawer-Screens/about-us-screen.dart';
import '../Drawer-Screens/currency-converter.dart';
import '../Drawer-Screens/settings-screen.dart';
import '../Drawer-Screens/unit-converter-screen.dart';


class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FinanceDashboard(),
    );
  }
}

class FinanceDashboard extends StatefulWidget {
  const FinanceDashboard({super.key});

  @override
  State<FinanceDashboard> createState() => _FinanceDashboardState();
}

class _FinanceDashboardState extends State<FinanceDashboard> {
  // Global key to open drawer via the custom menu icon
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,

      // --- DRAWER IMPLEMENTATION ---
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFf2faf7),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "FinSphere Calc",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Text("v1.0.4", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            drawerItem(Icons.settings_outlined, "Settings", SettingsScreen()),
            drawerItem(
              Icons.currency_exchange_outlined,
              "Currency Converter",
              CurrencyConverterScreen(),
            ),
            drawerItem(
              Icons.straighten_outlined,
              "Unit Converter",
              UnitConverterScreen(),
            ),
            const Divider(height: 1, color: Color(0xFFedf2f7)),
            drawerItem(
              Icons.star_border_rounded,
              "Rate Us",
              CurrencyConverterScreen(),
            ),
            drawerItem(
              Icons.share_outlined,
              "Share with Friends",
              CurrencyConverterScreen(),
            ),
            drawerItem(
                Icons.info_outline,
                "About Us",
                AboutUsScreen()
            ),
            drawerItem(
                Icons.info_outline,
                "User Profile",
                UserProfileScreen()
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Made for Investors",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF44474b)),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          "FinSphere Calc",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xFF44474b),
          ),
        ),
        // --- ADDED SEARCH BUTTON HERE ---
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF44474b)),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CalculatorSearchDelegate(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle("Loan & Debt Calculators"),
            rowItem("Home Loan EMI", Icons.home_outlined, HomeLoanScreen()),
            rowItem(
              "Personal Loan EMI",
              Icons.person_outline,
              PersonalLoanScreen(),
            ),
            rowItem(
              "Car / Bike Loan EMI",
              Icons.directions_car_outlined,
              VehicleLoanScreen(),
            ),
            rowItem(
              "Education Loan EMI",
              Icons.school_outlined,
              EducationalLoanScreen(),
            ),

            sectionTitle("Investment & Wealth Calculators"),
            rowItem("SIP Calculator", Icons.trending_up, SIPCalculatorScreen()),
            rowItem("Mutual Fund Return", Icons.bar_chart, MutualFundCalculatorScreen()),
            rowItem(
              "Lumpsum Investment",
              Icons.pie_chart_outline,
              LumpsumCalculatorScreen(),
            ),
            rowItem("Stock Return", Icons.show_chart, StockReturnCalculatorScreen()),

            sectionTitle("Banking & Deposit Calculators"),
            rowItem(
              "Fixed Deposit (FD)",
              Icons.savings_outlined,
              FDCalculatorScreen(),
            ),
            rowItem(
              "Recurring Deposit (RD)",
              Icons.calculate_outlined,
              RDCalculatorScreen(),
            ),
            rowItem(
              "Post Office RD",
              Icons.account_balance_outlined,
              PostOfficeRDCalculator(),
            ),
            rowItem("Post Office FD", Icons.attach_money, PostOfficeFDCalculator()),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00D09C),
        unselectedItemColor: Colors.grey.shade500,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoanCompareScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DateCalculatorScreen()),
            );
          }
        },
        // FIX 2 & 3: Remove 'const' from the list literal because
        // Navigator logic makes this block non-constant.
        items: [
           BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "Explore"
          ),
           BottomNavigationBarItem(
              icon: Icon(Icons.compare_arrows_sharp),
              label: "Loan Compare"
          ),
           BottomNavigationBarItem(
              icon: Icon(Icons.date_range_sharp),
              label: "Date Calculator"
          ),
        ], // FIX 3: Ensure the closing bracket matches the items list
      ),
    );
  }

  // Helper for Drawer Tiles
  Widget drawerItem(IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF44474b)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF44474b),
        ),
      ),
      onTap: () {
        // Handle navigation or close drawer
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Color(0xFF7c7e8c),
        ),
      ),
    );
  }

  Widget rowItem(String title, IconData icon, Widget page) {
    return gestureCard(title, icon, page);
  }

  Widget gestureCard(String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFedf2f7), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFf2faf7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF00D09C), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF44474b),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_right,
              size: 20,
              color: Color(0xFF7c7e8c),
            ),
          ],
        ),
      ),
    );
  }
}


class CalculatorSearchDelegate extends SearchDelegate {
  // List of all calculators with their names and target screens
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
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '', // Clear search text
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null), // Close search
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    // Filter list based on search query
    final suggestions = calculators.where((calc) {
      return calc['title'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final item = suggestions[index];
        return ListTile(
          leading: Icon(item['icon'], color: const Color(0xFF00D09C)),
          title: Text(item['title']),
          onTap: () {
            close(context, null); // Close search bar
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => item['page']),
            );
          },
        );
      },
    );
  }
}