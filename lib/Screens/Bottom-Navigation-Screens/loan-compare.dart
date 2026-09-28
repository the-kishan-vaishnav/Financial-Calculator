import 'package:flutter/material.dart';

class LoanCompareScreen extends StatefulWidget {
  const LoanCompareScreen({super.key});

  @override
  State<LoanCompareScreen> createState() => _LoanCompareScreenState();
}

class _LoanCompareScreenState extends State<LoanCompareScreen> {
  // Loan 1 States
  double amount1 = 500000;
  double rate1 = 8.5;
  double tenure1 = 5;

  // Loan 2 States
  double amount2 = 500000;
  double rate2 = 9.5;
  double tenure2 = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF44474b), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Compare Loans",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Color(0xFF44474b)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Comparison Summary Card (The "Savings" Card)
            _buildComparisonSummary(),

            const SizedBox(height: 24),

            // Loan 1 Input Card
            _loanInputCard("Loan Option 1", const Color(0xFF00D09C), amount1, rate1, tenure1, (a, r, t) {
              setState(() { amount1 = a; rate1 = r; tenure1 = t; });
            }),

            const SizedBox(height: 16),

            // Loan 2 Input Card
            _loanInputCard("Loan Option 2", Colors.orangeAccent, amount2, rate2, tenure2, (a, r, t) {
              setState(() { amount2 = a; rate2 = r; tenure2 = t; });
            }),

            const SizedBox(height: 24),

            // Breakdown Table
            _buildComparisonTable(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonSummary() {
    double emi1 = _calculateEMI(amount1, rate1, tenure1);
    double emi2 = _calculateEMI(amount2, rate2, tenure2);
    double diff = (emi1 - emi2).abs();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFf2faf7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00D09C).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF00D09C),
            child: Icon(Icons.bolt, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Difference in Monthly EMI", style: TextStyle(color: Color(0xFF7c7e8c), fontSize: 13)),
                Text(
                  "₹${diff.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF44474b)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _loanInputCard(String title, Color themeColor, double amt, double rt, double tn, Function(double, double, double) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFedf2f7), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 16, decoration: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 16),
          _miniSlider("Amount", amt, 100000, 10000000, (v) => onChanged(v, rt, tn)),
          _miniSlider("Interest (%)", rt, 1, 20, (v) => onChanged(amt, v, tn)),
          _miniSlider("Tenure (Yrs)", tn, 1, 30, (v) => onChanged(amt, rt, v)),
        ],
      ),
    );
  }

  Widget _miniSlider(String label, double val, double min, double max, ValueChanged<double> cb) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF7c7e8c), fontSize: 12)),
            Text(val.toStringAsFixed(label == "Amount" ? 0 : 1), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(trackHeight: 2, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6)),
          child: Slider(value: val, min: min, max: max, activeColor: const Color(0xFF44474b), onChanged: cb),
        ),
      ],
    );
  }

  Widget _buildComparisonTable() {
    double emi1 = _calculateEMI(amount1, rate1, tenure1);
    double emi2 = _calculateEMI(amount2, rate2, tenure2);
    double total1 = emi1 * tenure1 * 12;
    double total2 = emi2 * tenure2 * 12;

    return Column(
      children: [
        _tableRow("Monthly EMI", "₹${emi1.toStringAsFixed(0)}", "₹${emi2.toStringAsFixed(0)}", isHeader: true),
        const Divider(),
        _tableRow("Total Interest", "₹${(total1 - amount1).toStringAsFixed(0)}", "₹${(total2 - amount2).toStringAsFixed(0)}"),
        _tableRow("Total Payment", "₹${total1.toStringAsFixed(0)}", "₹${total2.toStringAsFixed(0)}"),
      ],
    );
  }

  Widget _tableRow(String label, String v1, String v2, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: const Color(0xFF7c7e8c), fontWeight: isHeader ? FontWeight.bold : FontWeight.normal))),
          Expanded(child: Text(v1, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00D09C)))),
          Expanded(child: Text(v2, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent))),
        ],
      ),
    );
  }

  double _calculateEMI(double p, double r, double t) {
    double rate = r / 12 / 100;
    double time = t * 12;
    return (p * rate * MathUtils.pow(1 + rate, time)) / (MathUtils.pow(1 + rate, time) - 1);
  }
}

// Simple helper for math since we can't use dart:math directly in snippets easily
class MathUtils {
  static double pow(double x, double y) {
    double res = 1;
    for (int i = 0; i < y; i++) { res *= x; }
    return res;
  }
}