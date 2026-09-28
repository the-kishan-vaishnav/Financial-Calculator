import 'package:flutter/material.dart';
import 'dart:math';
import 'package:pie_chart/pie_chart.dart';

import '../app-theme.dart';

class RDCalculatorScreen extends StatefulWidget {
  const RDCalculatorScreen({super.key});

  @override
  State<RDCalculatorScreen> createState() => _RDCalculatorScreenState();
}

class _RDCalculatorScreenState extends State<RDCalculatorScreen> {
  final amountController = TextEditingController();
  final rateController = TextEditingController();
  final monthController = TextEditingController();

  double totalInvested = 0;
  double totalInterest = 0;
  double maturityValue = 0;

  int _currentIndex = 0;
  bool hasResult = false;
  List<Map<String, dynamic>> yearlyProjection = [];

  void calculateRD() {
    if (amountController.text.isEmpty || rateController.text.isEmpty || monthController.text.isEmpty) return;

    double monthlyDeposit = double.parse(amountController.text);
    double annualRate = double.parse(rateController.text);
    int totalMonths = int.parse(monthController.text);

    // RD Formula used by Indian Banks (Quarterly Compounding)
    // M = R * [(1+i)^n - 1] / [1 - (1+i)^(-1/3)]
    // Where R = monthly deposit, i = annual rate/400, n = number of quarters

    double i = annualRate / 400;
    double n = totalMonths / 3; // Total Quarters

    maturityValue = monthlyDeposit * (pow(1 + i, n) - 1) / (1 - pow(1 + i, -1 / 3));

    totalInvested = monthlyDeposit * totalMonths;
    totalInterest = maturityValue - totalInvested;

    // Generate simple yearly projection for the "Timeline" tab
    yearlyProjection.clear();
    int totalYears = (totalMonths / 12).ceil();
    for (int y = 1; y <= totalYears; y++) {
      int monthsPassed = (y * 12) > totalMonths ? totalMonths : (y * 12);
      double tempN = monthsPassed / 3;
      double tempMaturity = monthlyDeposit * (pow(1 + i, tempN) - 1) / (1 - pow(1 + i, -1 / 3));

      yearlyProjection.add({
        "year": y,
        "invested": monthlyDeposit * monthsPassed,
        "value": tempMaturity,
      });
    }

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
          AppTheme.buildHeadline("Recurring Deposit", "Save small amounts, earn big interest"),
          const SizedBox(height: AppTheme.elementSpacing),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
            padding: const EdgeInsets.all(AppTheme.cardPadding),
            decoration: AppTheme.premiumCardDecoration,
            child: Column(
              children: [
                buildInput("Monthly Deposit (₹)", amountController, Icons.calendar_month_outlined),
                buildInput("Interest Rate (% p.a.)", rateController, Icons.trending_up),
                buildInput("Tenure (Months)", monthController, Icons.timer_outlined),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: calculateRD,
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
                  const Text("Maturity Amount", style: AppTheme.cardTitleStyle),
                  Text("₹${maturityValue.toStringAsFixed(0)}", style: AppTheme.resultMainStyle),
                  const Divider(height: 30, color: AppTheme.growwBorder),
                  AppTheme.buildResultRow("Total Investment", "₹${totalInvested.toStringAsFixed(0)}"),
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
        AppTheme.buildHeadline("RD Composition", "Investment vs Earnings"),
        const SizedBox(height: 40),
        PieChart(
          dataMap: {
            "Total Investment": totalInvested,
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

  Widget timelineUI() {
    if (!hasResult) return emptyState();
    return Column(
      children: [
        const SizedBox(height: 110),
        AppTheme.buildHeadline("Yearly Projection", "Watch your savings accumulate"),
        Expanded(
          child: ListView.builder(
            itemCount: yearlyProjection.length,
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemBuilder: (context, index) {
              var data = yearlyProjection[index];
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
                        Text("Value: ₹${data["value"].toStringAsFixed(0)}",
                            style: const TextStyle(color: AppTheme.growwGreen, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(),
                    AppTheme.buildResultRow("Invested so far", "₹${data["invested"].toStringAsFixed(0)}"),
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
          Icon(Icons.history_edu, size: 80, color: AppTheme.growwBorder),
          SizedBox(height: 16),
          Text("Enter RD details to see projection", style: AppTheme.subHeadlineStyle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [calculatorUI(), chartUI(), timelineUI()];

    return Scaffold(
      backgroundColor: AppTheme.growwBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        title: const Text("RD Calculator", style: TextStyle(color: AppTheme.growwText, fontWeight: FontWeight.bold)),
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
          BottomNavigationBarItem(icon: Icon(Icons.timeline), label: "Timeline"),
        ],
      ),
    );
  }
}