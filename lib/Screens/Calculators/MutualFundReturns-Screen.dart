import 'package:flutter/material.dart';
import 'dart:math';
import 'package:pie_chart/pie_chart.dart';

import '../app-theme.dart';

class MutualFundCalculatorScreen extends StatefulWidget {
  const MutualFundCalculatorScreen({super.key});

  @override
  State<MutualFundCalculatorScreen> createState() => _MutualFundCalculatorScreenState();
}

class _MutualFundCalculatorScreenState extends State<MutualFundCalculatorScreen> {
  final amountController = TextEditingController();
  final yearController = TextEditingController();
  final rateController = TextEditingController();
  final expenseController = TextEditingController(text: "0.5");

  double totalInvestment = 0;
  double totalReturns = 0;
  double estimatedValue = 0;
  double expenseImpact = 0;

  int _currentIndex = 0;
  bool hasResult = false;
  List<Map<String, dynamic>> projection = [];

  void calculateMF() {
    if (amountController.text.isEmpty || rateController.text.isEmpty || yearController.text.isEmpty) return;

    double principal = double.parse(amountController.text);
    double expectedRate = double.parse(rateController.text);
    double expenseRatio = double.tryParse(expenseController.text) ?? 0;
    int years = int.parse(yearController.text);

    // netRate is the actual growth rate after fees
    double netRate = (expectedRate - expenseRatio) / 100;

    // Standard Lumpsum Formula: A = P * (1 + r)^t
    estimatedValue = principal * pow((1 + netRate), years);

    // Calculation without fees to show "Loss" to fees
    double valueWithoutExpense = principal * pow((1 + (expectedRate / 100)), years);

    totalInvestment = principal;
    totalReturns = estimatedValue - totalInvestment;
    expenseImpact = valueWithoutExpense - estimatedValue;

    projection.clear();
    for (int i = 1; i <= years; i++) {
      double yearlyValue = principal * pow((1 + netRate), i);
      projection.add({
        "year": i,
        "value": yearlyValue,
        "gain": yearlyValue - principal,
      });
    }

    setState(() {
      hasResult = true;
    });
    FocusScope.of(context).unfocus();
  }

  // --- UI COMPONENTS ---

  Widget calculatorUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 110, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTheme.buildHeadline("Mutual Fund", "Estimate net returns after fees"),
          const SizedBox(height: AppTheme.elementSpacing),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
            padding: const EdgeInsets.all(AppTheme.cardPadding),
            decoration: AppTheme.premiumCardDecoration,
            child: Column(
              children: [
                buildInput("Investment Amount (₹)", amountController, Icons.account_balance_wallet_outlined),
                buildInput("Expected Return (% p.a.)", rateController, Icons.trending_up),
                buildInput("Expense Ratio (%)", expenseController, Icons.percent),
                buildInput("Tenure (Years)", yearController, Icons.timer_outlined),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: calculateMF,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.growwGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
                    ),
                    child: const Text("Calculate Net Returns", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  const Text("Estimated Net Wealth", style: AppTheme.cardTitleStyle),
                  Text("₹${estimatedValue.toStringAsFixed(0)}", style: AppTheme.resultMainStyle),
                  const Divider(height: 30, color: AppTheme.growwBorder),
                  AppTheme.buildResultRow("Invested Amount", "₹${totalInvestment.toStringAsFixed(0)}"),
                  AppTheme.buildResultRow("Net Capital Gain", "₹${totalReturns.toStringAsFixed(0)}"),
                  AppTheme.buildResultRow("Loss to Expense Ratio", "₹${expenseImpact.toStringAsFixed(0)}"),
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
        AppTheme.buildHeadline("Fund Summary", "Portfolio Distribution"),
        const SizedBox(height: 40),
        PieChart(
          dataMap: {
            "Investment": totalInvestment,
            "Profit": totalReturns,
            "Fees": expenseImpact,
          },
          colorList: [AppTheme.chartPrincipal, AppTheme.growwGreen, Colors.redAccent],
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
        AppTheme.buildHeadline("Growth Timeline", "Yearly Net Value"),
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
                    AppTheme.buildResultRow("Total Profit", "₹${data["gain"].toStringAsFixed(0)}"),
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
          Icon(Icons.analytics_outlined, size: 80, color: AppTheme.growwBorder),
          SizedBox(height: 16),
          Text("Calculate on first tab to see data", style: AppTheme.subHeadlineStyle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define the list of screens correctly here
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
        title: const Text("Mutual Fund Returns", style: TextStyle(color: AppTheme.growwText, fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppTheme.growwText),
            onPressed: () => Navigator.pop(context)
        ),
      ),
      // Use the _currentIndex to select from the screens list
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppTheme.growwGreen,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: "Calculator"),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: "Growth"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Yearly"),
        ],
      ),
    );
  }
}