import 'package:flutter/material.dart';
import 'dart:math';
import 'package:pie_chart/pie_chart.dart';

import '../app-theme.dart';

class PostOfficeFDCalculator extends StatefulWidget {
  const PostOfficeFDCalculator({super.key});

  @override
  State<PostOfficeFDCalculator> createState() => _PostOfficeFDCalculatorState();
}

class _PostOfficeFDCalculatorState extends State<PostOfficeFDCalculator> {
  final amountController = TextEditingController();
  final rateController = TextEditingController();

  // Post Office TD allows only 1, 2, 3, or 5 years
  int selectedTenure = 1;

  double totalInvested = 0;
  double totalInterest = 0;
  double maturityValue = 0;

  int _currentIndex = 0;
  bool hasResult = false;

  void calculatePOTD() {
    if (amountController.text.isEmpty || rateController.text.isEmpty) return;

    double principal = double.parse(amountController.text);
    double annualRate = double.parse(rateController.text);
    int years = selectedTenure;

    // Post Office Time Deposit (POTD) Formula
    // Interest is compounded quarterly: A = P(1 + r/4)^4n
    double r = annualRate / 100;
    maturityValue = principal * pow((1 + r / 4), (4 * years));

    totalInvested = principal;
    totalInterest = maturityValue - principal;

    setState(() => hasResult = true);
    FocusScope.of(context).unfocus();
  }

  // --- UI COMPONENTS ---

  Widget calculatorUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 110, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTheme.buildHeadline("Post Office FD", "Time Deposit (POTD) Growth"),
          const SizedBox(height: AppTheme.elementSpacing),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
            padding: const EdgeInsets.all(AppTheme.cardPadding),
            decoration: AppTheme.premiumCardDecoration,
            child: Column(
              children: [
                buildInput("Investment Amount (₹)", amountController, Icons.account_balance_wallet_outlined),
                buildInput("Interest Rate (% p.a.)", rateController, Icons.percent),

                const SizedBox(height: 10),
                // Tenure Selection Dropdown
                DropdownButtonFormField<int>(
                  value: selectedTenure,
                  decoration: AppTheme.inputDecoration("Tenure (Years)", Icons.calendar_today),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("1 Year")),
                    DropdownMenuItem(value: 2, child: Text("2 Years")),
                    DropdownMenuItem(value: 3, child: Text("3 Years")),
                    DropdownMenuItem(value: 5, child: Text("5 Years")),
                  ],
                  onChanged: (val) => setState(() => selectedTenure = val!),
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: calculatePOTD,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.growwGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
                    ),
                    child: const Text("Calculate Maturity", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          if (hasResult) ...[
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
              padding: const EdgeInsets.all(AppTheme.cardPadding),
              decoration: AppTheme.premiumCardDecoration,
              child: Column(
                children: [
                  const Text("Maturity Value", style: AppTheme.cardTitleStyle),
                  Text("₹${maturityValue.toStringAsFixed(0)}", style: AppTheme.resultMainStyle),
                  const Divider(height: 30, color: AppTheme.growwBorder),
                  AppTheme.buildResultRow("Principal Amount", "₹${totalInvested.toStringAsFixed(0)}"),
                  AppTheme.buildResultRow("Total Interest", "₹${totalInterest.toStringAsFixed(0)}"),
                  if (selectedTenure == 5)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        "* 5-Year TD is eligible for 80C tax deduction",
                        style: TextStyle(fontSize: 12, color: AppTheme.growwGreen, fontWeight: FontWeight.w500),
                      ),
                    ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget chartUI() {
    if (!hasResult) return emptyState();
    return Column(
      children: [
        const SizedBox(height: 120),
        AppTheme.buildHeadline("Analysis", "Capital vs Earnings"),
        const SizedBox(height: 40),
        PieChart(
          dataMap: {
            "Principal": totalInvested,
            "Interest": totalInterest,
          },
          colorList: [AppTheme.chartPrincipal, AppTheme.growwGreen],
          chartRadius: 180,
          chartType: ChartType.ring,
          ringStrokeWidth: 35,
          legendOptions: const LegendOptions(legendPosition: LegendPosition.bottom, showLegendsInRow: true),
        ),
      ],
    );
  }

  // --- HELPERS ---

  Widget buildInput(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: AppTheme.inputDecoration(label, icon),
      ),
    );
  }

  Widget emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.account_balance_outlined, size: 80, color: AppTheme.growwBorder),
          SizedBox(height: 16),
          Text("Calculate to see Post Office TD returns", style: AppTheme.subHeadlineStyle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [calculatorUI(), chartUI()];

    return Scaffold(
      backgroundColor: AppTheme.growwBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        title: const Text("Post Office TD", style: TextStyle(color: AppTheme.growwText, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: AppTheme.growwText), onPressed: () => Navigator.pop(context)),
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppTheme.growwGreen,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: "Calculator"),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: "Analysis"),
        ],
      ),
    );
  }
}