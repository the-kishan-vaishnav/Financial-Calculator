import 'package:flutter/material.dart';
import 'dart:math';
import 'package:pie_chart/pie_chart.dart';

import '../app-theme.dart';

class EducationalLoanScreen extends StatefulWidget {
  const EducationalLoanScreen({super.key});

  @override
  State<EducationalLoanScreen> createState() => _EducationalLoanScreenState();
}

class _EducationalLoanScreenState extends State<EducationalLoanScreen> {
  final amountController = TextEditingController();
  final yearController = TextEditingController(); // Education loans usually 7-15 years
  final rateController = TextEditingController();

  // Note: Most education loans have a moratorium period (Course Duration + 6-12 months)
  // For this version, we calculate the standard EMI post-moratorium.

  double emi = 0;
  double totalInterest = 0;
  double totalAmount = 0;

  int _currentIndex = 0;
  bool hasResult = false;
  List<Map<String, dynamic>> breakdown = [];

  void calculateEMI() {
    if (amountController.text.isEmpty || rateController.text.isEmpty || yearController.text.isEmpty) return;

    double principal = double.parse(amountController.text);
    double annualRate = double.parse(rateController.text);
    double years = double.parse(yearController.text);

    double monthlyRate = annualRate / 12 / 100;
    int months = (years * 12).toInt();

    // EMI Formula: [P x R x (1+R)^N]/[(1+R)^N-1]
    double emiValue = (principal * monthlyRate * pow(1 + monthlyRate, months)) /
        (pow(1 + monthlyRate, months) - 1);

    totalAmount = emiValue * months;
    totalInterest = totalAmount - principal;

    breakdown.clear();
    double balance = principal;
    for (int i = 1; i <= months; i++) {
      double interest = balance * monthlyRate;
      double principalPay = emiValue - interest;
      balance -= principalPay;
      breakdown.add({
        "month": i,
        "interest": interest,
        "principal": principalPay,
        "remaining": balance < 0 ? 0 : balance,
      });
    }

    setState(() => hasResult = true);
    emi = emiValue;
  }

  // --- UI SCREENS ---

  Widget calculatorUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 110, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTheme.buildHeadline("Education Loan", "Invest in your future career"),
          const SizedBox(height: AppTheme.elementSpacing),

          // Input Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
            padding: const EdgeInsets.all(AppTheme.cardPadding),
            decoration: AppTheme.premiumCardDecoration,
            child: Column(
              children: [
                buildInput("Loan Amount (₹)", amountController, Icons.school_outlined),
                buildInput("Repayment Tenure (Years)", yearController, Icons.calendar_month_outlined),
                buildInput("Interest Rate (% p.a.)", rateController, Icons.percent_outlined),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: calculateEMI,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.growwGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
                      elevation: 0,
                    ),
                    child: const Text("Calculate EMI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  const Text("Monthly EMI (Post-Moratorium)", style: AppTheme.cardTitleStyle),
                  Text("₹${emi.toStringAsFixed(0)}", style: AppTheme.resultMainStyle),
                  const Divider(height: 30, color: AppTheme.growwBorder),
                  AppTheme.buildResultRow("Principal Amount", "₹${(totalAmount - totalInterest).toStringAsFixed(0)}"),
                  AppTheme.buildResultRow("Total Interest", "₹${totalInterest.toStringAsFixed(0)}"),
                  AppTheme.buildResultRow("Total Payable", "₹${totalAmount.toStringAsFixed(0)}"),
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
        AppTheme.buildHeadline("Loan Composition", "Principal vs Total Interest"),
        const SizedBox(height: 40),
        PieChart(
          dataMap: {
            "Principal": totalAmount - totalInterest,
            "Interest": totalInterest,
          },
          colorList: [AppTheme.chartPrincipal, AppTheme.chartInterest],
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
        AppTheme.buildHeadline("Repayment Schedule", "Step-by-step balance reduction"),
        Expanded(
          child: ListView.builder(
            itemCount: breakdown.length,
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemBuilder: (context, index) {
              var data = breakdown[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding, vertical: 5),
                padding: const EdgeInsets.all(15),
                decoration: AppTheme.premiumCardDecoration,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Month ${data["month"]}", style: AppTheme.valueStyle),
                        Text("Balance: ₹${data["remaining"].toStringAsFixed(0)}", style: const TextStyle(color: AppTheme.growwGreen, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(),
                    AppTheme.buildResultRow("Principal", "₹${data["principal"].toStringAsFixed(0)}"),
                    AppTheme.buildResultRow("Interest", "₹${data["interest"].toStringAsFixed(0)}"),
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
          Icon(Icons.menu_book_outlined, size: 80, color: AppTheme.growwBorder),
          SizedBox(height: 16),
          Text("Calculate EMI to see details", style: AppTheme.subHeadlineStyle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.growwBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        title: const Text("Education Loan EMI", style: TextStyle(color: AppTheme.growwText, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: AppTheme.growwText), onPressed: () => Navigator.pop(context)),
      ),
      body: [_currentIndex == 0 ? calculatorUI() : _currentIndex == 1 ? chartUI() : breakdownUI()][0],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppTheme.growwGreen,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: "Calculator"),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: "Stats"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Schedule"),
        ],
      ),
    );
  }
}