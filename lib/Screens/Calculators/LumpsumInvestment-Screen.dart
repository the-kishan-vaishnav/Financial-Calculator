
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:pie_chart/pie_chart.dart';

import '../app-theme.dart';

class LumpsumCalculatorScreen extends StatefulWidget {
  const LumpsumCalculatorScreen({super.key});

  @override
  State<LumpsumCalculatorScreen> createState() => _LumpsumCalculatorScreenState();
}

class _LumpsumCalculatorScreenState extends State<LumpsumCalculatorScreen> {
  final amountController = TextEditingController();
  final yearController = TextEditingController();
  final rateController = TextEditingController();

  double totalInvestment = 0;
  double totalReturns = 0;
  double estimatedValue = 0;

  int _currentIndex = 0;
  bool hasResult = false;
  List<Map<String, dynamic>> projection = [];

  void calculateLumpsum() {
    if (amountController.text.isEmpty || rateController.text.isEmpty || yearController.text.isEmpty) return;

    double principal = double.parse(amountController.text);
    double annualRate = double.parse(rateController.text);
    int years = int.parse(yearController.text);

    // Standard Math: A = P * (1 + r/n)^(nt)
    // Compounded Monthly (n=12) for higher precision
    double monthlyRate = annualRate / 100 / 12;
    int months = years * 12;

    estimatedValue = principal * pow(1 + monthlyRate, months);
    totalInvestment = principal;
    totalReturns = estimatedValue - totalInvestment;

    projection.clear();
    for (int i = 1; i <= years; i++) {
      double yearlyValue = principal * pow(1 + monthlyRate, i * 12);
      projection.add({
        "year": i,
        "value": yearlyValue,
        "gain": yearlyValue - principal,
      });
    }

    setState(() {
      hasResult = true;
    });

    // Closes keyboard
    FocusScope.of(context).unfocus();
  }

  // --- UI SCREENS ---

  Widget calculatorUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 110, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTheme.buildHeadline("Lumpsum Calculator", "Project your one-time investment growth"),
          const SizedBox(height: AppTheme.elementSpacing),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
            padding: const EdgeInsets.all(AppTheme.cardPadding),
            decoration: AppTheme.premiumCardDecoration,
            child: Column(
              children: [
                buildInput("Investment Amount (₹)", amountController, Icons.account_balance_wallet_outlined),
                buildInput("Expected Return Rate (% p.a.)", rateController, Icons.show_chart),
                buildInput("Time Period (Years)", yearController, Icons.av_timer),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: calculateLumpsum,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.growwGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
                    ),
                    child: const Text("Calculate Wealth", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  const Text("Estimated Wealth", style: AppTheme.cardTitleStyle),
                  Text("₹${estimatedValue.toStringAsFixed(0)}", style: AppTheme.resultMainStyle),
                  const Divider(height: 30, color: AppTheme.growwBorder),
                  AppTheme.buildResultRow("Invested Amount", "₹${totalInvestment.toStringAsFixed(0)}"),
                  AppTheme.buildResultRow("Est. Returns", "₹${totalReturns.toStringAsFixed(0)}"),
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
        AppTheme.buildHeadline("Wealth Breakdown", "Investment vs Total Growth"),
        const SizedBox(height: 40),
        PieChart(
          dataMap: {
            "Investment": totalInvestment,
            "Returns": totalReturns,
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

  Widget breakdownUI() {
    if (!hasResult) return emptyState();
    return Column(
      children: [
        const SizedBox(height: 110),
        AppTheme.buildHeadline("Timeline", "Yearly value projection"),
        Expanded(
          child: ListView.builder(
            itemCount: projection.length,
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemBuilder: (context, index) {
              var data = projection[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding, vertical: 5),
                padding: const EdgeInsets.all(15),
                decoration: AppTheme.premiumCardDecoration,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Year ${data["year"]}", style: AppTheme.valueStyle),
                        Text("₹${data["value"].toStringAsFixed(0)}",
                            style: const TextStyle(color: AppTheme.growwGreen, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(),
                    AppTheme.buildResultRow("Accumulated Profit", "₹${data["gain"].toStringAsFixed(0)}"),
                  ],
                ),
              );
            },
          ),
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
          Icon(Icons.query_stats, size: 80, color: AppTheme.growwBorder),
          SizedBox(height: 16),
          Text("Calculate on the first tab\nto see charts and data", style: AppTheme.subHeadlineStyle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // FIXED: The list must contain all 3 widgets to match BottomNavigationBar indexes
    final List<Widget> screens = [
      calculatorUI(),
      chartUI(),
      breakdownUI(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.growwBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        title: const Text("Lumpsum Investment", style: TextStyle(color: AppTheme.growwText, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: AppTheme.growwText), onPressed: () => Navigator.pop(context)),
      ),
      // Accessing by index ensures no range error
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppTheme.growwGreen,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: "Calculator"),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: "Wealth"),
          BottomNavigationBarItem(icon: Icon(Icons.timeline), label: "Timeline"),
        ],
      ),
    );
  }
}