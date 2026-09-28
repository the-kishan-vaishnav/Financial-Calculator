import 'package:flutter/material.dart';
import 'dart:math';
import 'package:pie_chart/pie_chart.dart';

import '../app-theme.dart';

class SIPCalculatorScreen extends StatefulWidget {
  const SIPCalculatorScreen({super.key});

  @override
  State<SIPCalculatorScreen> createState() => _SIPCalculatorScreenState();
}

class _SIPCalculatorScreenState extends State<SIPCalculatorScreen> {
  final investmentController = TextEditingController();
  final yearController = TextEditingController();
  final rateController = TextEditingController();
  final stepUpController = TextEditingController(text: "10");

  bool isStepUp = false;
  double totalInvestment = 0;
  double totalReturns = 0;
  double estimatedValue = 0;

  int _currentIndex = 0;
  bool hasResult = false;
  List<Map<String, dynamic>> projection = [];

  // --- THE CALCULATION LOGIC ---
  void calculateSIP() {
    // 1. Validate Inputs
    if (investmentController.text.isEmpty ||
        rateController.text.isEmpty ||
        yearController.text.isEmpty) {
      return;
    }

    // 2. Parse values
    double monthlyInvestment = double.parse(investmentController.text);
    double expectedRate = double.parse(rateController.text);
    int years = int.parse(yearController.text);
    double annualStepUp = double.tryParse(stepUpController.text) ?? 0;

    double monthlyRate = expectedRate / 12 / 100;
    double currentMonthlyInv = monthlyInvestment;
    double tempTotalValue = 0;
    double tempTotalInvested = 0;

    List<Map<String, dynamic>> tempProjection = [];

    // 3. Loop through years to calculate Compound Interest
    for (int year = 1; year <= years; year++) {
      for (int month = 1; month <= 12; month++) {
        // Compound Interest Formula applied monthly
        tempTotalValue = (tempTotalValue + currentMonthlyInv) * (1 + monthlyRate);
        tempTotalInvested += currentMonthlyInv;
      }

      tempProjection.add({
        "year": year,
        "invested": tempTotalInvested,
        "value": tempTotalValue,
        "monthly": currentMonthlyInv,
      });

      // Increase monthly investment if Step-up is enabled
      if (isStepUp) {
        currentMonthlyInv += (currentMonthlyInv * annualStepUp / 100);
      }
    }

    // 4. Update UI state
    setState(() {
      estimatedValue = tempTotalValue;
      totalInvestment = tempTotalInvested;
      totalReturns = estimatedValue - totalInvestment;
      projection = tempProjection;
      hasResult = true;
    });

    // Hide keyboard after calculation
    FocusScope.of(context).unfocus();
  }

  // --- UI SCREENS ---

  Widget calculatorUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 110, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTheme.buildHeadline("SIP Calculator", "Grow your wealth systematically"),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding, vertical: 10),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text("Regular SIP"),
                  selected: !isStepUp,
                  onSelected: (val) => setState(() { isStepUp = false; hasResult = false; }),
                  selectedColor: AppTheme.growwGreen.withOpacity(0.2),
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text("Step-up SIP"),
                  selected: isStepUp,
                  onSelected: (val) => setState(() { isStepUp = true; hasResult = false; }),
                  selectedColor: AppTheme.growwGreen.withOpacity(0.2),
                ),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
            padding: const EdgeInsets.all(AppTheme.cardPadding),
            decoration: AppTheme.premiumCardDecoration,
            child: Column(
              children: [
                buildInput("Monthly Investment (₹)", investmentController, Icons.savings_outlined),
                if (isStepUp) buildInput("Annual Step-up (%)", stepUpController, Icons.trending_up),
                buildInput("Expected Return Rate (% p.a.)", rateController, Icons.auto_graph),
                buildInput("Time Period (Years)", yearController, Icons.timer_outlined),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: calculateSIP,
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
        AppTheme.buildHeadline("Investment Breakdown", "See your money grow"),
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
          chartValuesOptions: const ChartValuesOptions(showChartValuesInPercentage: true),
        ),
      ],
    );
  }

  Widget breakdownUI() {
    if (!hasResult || projection.isEmpty) return emptyState();
    return Column(
      children: [
        const SizedBox(height: 110),
        AppTheme.buildHeadline("Growth Journey", "Yearly value projection"),
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
                    AppTheme.buildResultRow("Total Invested", "₹${data["invested"].toStringAsFixed(0)}"),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- COMMON HELPERS ---

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
          Icon(Icons.insights, size: 80, color: AppTheme.growwBorder),
          SizedBox(height: 16),
          Text("Calculate on the first tab\nto see charts & breakdown",
              textAlign: TextAlign.center,
              style: AppTheme.subHeadlineStyle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // List of widgets to display based on index
    final List<Widget> screens = [calculatorUI(), chartUI(), breakdownUI()];

    return Scaffold(
      backgroundColor: AppTheme.growwBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        title: const Text("SIP Calculator", style: TextStyle(color: AppTheme.growwText, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: AppTheme.growwText), onPressed: () => Navigator.pop(context)),
      ),
      body: screens[_currentIndex], // Fixed indexing
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppTheme.growwGreen,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: "Calculator"),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: "Wealth"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Yearly"),
        ],
      ),
    );
  }
}