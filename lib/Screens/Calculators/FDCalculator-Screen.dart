import 'package:flutter/material.dart';
import 'dart:math';
import 'package:pie_chart/pie_chart.dart';

import '../app-theme.dart';

class FDCalculatorScreen extends StatefulWidget {
  const FDCalculatorScreen({super.key});

  @override
  State<FDCalculatorScreen> createState() => _FDCalculatorScreenState();
}

class _FDCalculatorScreenState extends State<FDCalculatorScreen> {
  final amountController = TextEditingController();
  final rateController = TextEditingController();
  final yearController = TextEditingController();

  double totalInvested = 0;
  double totalInterest = 0;
  double maturityValue = 0;

  // Compounding frequency: 4 = Quarterly, 1 = Annually, 12 = Monthly
  int compoundingFrequency = 4;

  int _currentIndex = 0;
  bool hasResult = false;

  void calculateFD() {
    if (amountController.text.isEmpty || rateController.text.isEmpty || yearController.text.isEmpty) return;

    double principal = double.parse(amountController.text);
    double annualRate = double.parse(rateController.text);
    double years = double.parse(yearController.text);

    // FD Formula: A = P(1 + r/n)^(n*t)
    // r = annual interest rate (decimal)
    // n = number of times interest compounds per year
    // t = time in years

    double r = annualRate / 100;
    int n = compoundingFrequency;

    maturityValue = principal * pow((1 + r / n), (n * years));
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
          AppTheme.buildHeadline("Fixed Deposit", "Secure returns on your savings"),
          const SizedBox(height: AppTheme.elementSpacing),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
            padding: const EdgeInsets.all(AppTheme.cardPadding),
            decoration: AppTheme.premiumCardDecoration,
            child: Column(
              children: [
                buildInput("Investment Amount (₹)", amountController, Icons.account_balance),
                buildInput("Interest Rate (% p.a.)", rateController, Icons.percent),
                buildInput("Tenure (Years)", yearController, Icons.calendar_today),

                // Compounding Dropdown
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: compoundingFrequency,
                  decoration: AppTheme.inputDecoration("Compounding Frequency", Icons.update),
                  items: const [
                    DropdownMenuItem(value: 12, child: Text("Monthly")),
                    DropdownMenuItem(value: 4, child: Text("Quarterly")),
                    DropdownMenuItem(value: 1, child: Text("Annually")),
                  ],
                  onChanged: (val) => setState(() => compoundingFrequency = val!),
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: calculateFD,
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
        AppTheme.buildHeadline("FD Breakdown", "Principal vs Interest Earned"),
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
          Icon(Icons.account_balance_wallet_outlined, size: 80, color: AppTheme.growwBorder),
          SizedBox(height: 16),
          Text("Calculate to see your FD growth", style: AppTheme.subHeadlineStyle),
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
        title: const Text("FD Calculator", style: TextStyle(color: AppTheme.growwText, fontWeight: FontWeight.bold)),
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