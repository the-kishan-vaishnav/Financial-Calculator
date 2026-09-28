import 'package:flutter/material.dart';
import 'dart:math';
import 'package:pie_chart/pie_chart.dart';

import '../app-theme.dart';

class PostOfficeRDCalculator extends StatefulWidget {
  const PostOfficeRDCalculator({super.key});

  @override
  State<PostOfficeRDCalculator> createState() => _PostOfficeRDCalculatorState();
}

class _PostOfficeRDCalculatorState extends State<PostOfficeRDCalculator> {
  final amountController = TextEditingController();
  // Post Office RD rates change quarterly, usually around 6.7%
  final rateController = TextEditingController(text: "6.7");

  double totalInvested = 0;
  double totalInterest = 0;
  double maturityValue = 0;

  int _currentIndex = 0;
  bool hasResult = false;

  void calculatePORD() {
    if (amountController.text.isEmpty || rateController.text.isEmpty) return;

    double monthlyDeposit = double.parse(amountController.text);
    double annualRate = double.parse(rateController.text);

    // Post Office RD is strictly for 5 years (60 months)
    const int totalMonths = 60;

    // Calculation based on Quarterly Compounding logic
    // Formula: M = R * [(1+i)^n - 1] / [1 - (1+i)^(-1/3)]
    double i = annualRate / 400; // Quarterly interest rate
    double n = totalMonths / 3;  // Total Quarters (20 quarters)

    maturityValue = monthlyDeposit * (pow(1 + i, n) - 1) / (1 - pow(1 + i, -1 / 3));

    totalInvested = monthlyDeposit * totalMonths;
    totalInterest = maturityValue - totalInvested;

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
          AppTheme.buildHeadline("Post Office RD", "Fixed 5-Year Government Savings"),
          const SizedBox(height: AppTheme.elementSpacing),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
            padding: const EdgeInsets.all(AppTheme.cardPadding),
            decoration: AppTheme.premiumCardDecoration,
            child: Column(
              children: [
                buildInput("Monthly Deposit (₹)", amountController, Icons.account_balance_outlined),
                buildInput("Interest Rate (% p.a.)", rateController, Icons.percent),
                const SizedBox(height: 10),
                const Text(
                  "Note: Post Office RD has a mandatory 5-year tenure.",
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: calculatePORD,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.growwGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
                    ),
                    child: const Text("Calculate 5-Year Maturity", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  const Text("Value after 5 Years", style: AppTheme.cardTitleStyle),
                  Text("₹${maturityValue.toStringAsFixed(0)}", style: AppTheme.resultMainStyle),
                  const Divider(height: 30, color: AppTheme.growwBorder),
                  AppTheme.buildResultRow("Total Invested", "₹${totalInvested.toStringAsFixed(0)}"),
                  AppTheme.buildResultRow("Total Interest", "₹${totalInterest.toStringAsFixed(0)}"),
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
        AppTheme.buildHeadline("Composition", "Investment vs 5-Year Growth"),
        const SizedBox(height: 40),
        PieChart(
          dataMap: {
            "Total Principal": totalInvested,
            "Interest Earned": totalInterest,
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
          Icon(Icons.mark_as_unread_outlined, size: 80, color: AppTheme.growwBorder),
          SizedBox(height: 16),
          Text("Calculate to see maturity value", style: AppTheme.subHeadlineStyle),
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
        title: const Text("Post Office RD", style: TextStyle(color: AppTheme.growwText, fontWeight: FontWeight.bold)),
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