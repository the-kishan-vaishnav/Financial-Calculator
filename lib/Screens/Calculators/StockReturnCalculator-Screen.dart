import 'package:flutter/material.dart';
import 'dart:math';
import 'package:pie_chart/pie_chart.dart';

import '../app-theme.dart';

class StockReturnCalculatorScreen extends StatefulWidget {
  const StockReturnCalculatorScreen({super.key});

  @override
  State<StockReturnCalculatorScreen> createState() => _StockReturnCalculatorScreenState();
}

class _StockReturnCalculatorScreenState extends State<StockReturnCalculatorScreen> {
  final buyPriceController = TextEditingController();
  final sellPriceController = TextEditingController();
  final quantityController = TextEditingController();
  final durationController = TextEditingController(); // In Years

  double totalInvested = 0;
  double totalValue = 0;
  double totalProfit = 0;
  double absoluteReturn = 0;
  double cagr = 0;

  int _currentIndex = 0;
  bool hasResult = false;

  void calculateStockReturns() {
    if (buyPriceController.text.isEmpty ||
        sellPriceController.text.isEmpty ||
        quantityController.text.isEmpty) return;

    double buyPrice = double.parse(buyPriceController.text);
    double sellPrice = double.parse(sellPriceController.text);
    int quantity = int.parse(quantityController.text);
    double years = double.tryParse(durationController.text) ?? 1;

    totalInvested = buyPrice * quantity;
    totalValue = sellPrice * quantity;
    totalProfit = totalValue - totalInvested;

    // Absolute Return %
    absoluteReturn = (totalProfit / totalInvested) * 100;

    // CAGR Formula: [(Current Value / Initial Value) ^ (1 / Years)] - 1
    if (years > 0) {
      cagr = (pow((totalValue / totalInvested), (1 / years)) - 1) * 100;
    }

    setState(() {
      hasResult = true;
    });
    FocusScope.of(context).unfocus();
  }

  // --- UI SCREENS ---

  Widget calculatorUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 110, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTheme.buildHeadline("Stock Returns", "Calculate profit & annualized growth"),
          const SizedBox(height: AppTheme.elementSpacing),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
            padding: const EdgeInsets.all(AppTheme.cardPadding),
            decoration: AppTheme.premiumCardDecoration,
            child: Column(
              children: [
                buildInput("Buy Price (₹)", buyPriceController, Icons.shopping_cart_outlined),
                buildInput("Sell/Current Price (₹)", sellPriceController, Icons.sell_outlined),
                buildInput("Quantity", quantityController, Icons.layers_outlined),
                buildInput("Holding Period (Years)", durationController, Icons.timer_outlined),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: calculateStockReturns,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.growwGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
                    ),
                    child: const Text("Calculate Profit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  const Text("Total Profit/Loss", style: AppTheme.cardTitleStyle),
                  Text("₹${totalProfit.toStringAsFixed(0)}",
                      style: AppTheme.resultMainStyle.copyWith(
                          color: totalProfit >= 0 ? AppTheme.growwGreen : Colors.redAccent
                      )),
                  const Divider(height: 30, color: AppTheme.growwBorder),
                  AppTheme.buildResultRow("Total Invested", "₹${totalInvested.toStringAsFixed(0)}"),
                  AppTheme.buildResultRow("Current Value", "₹${totalValue.toStringAsFixed(0)}"),
                  AppTheme.buildResultRow("Absolute Return", "${absoluteReturn.toStringAsFixed(2)}%"),
                  AppTheme.buildResultRow("CAGR (Annualized)", "${cagr.toStringAsFixed(2)}%"),
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
        AppTheme.buildHeadline("Return Analysis", "Capital vs Profit"),
        const SizedBox(height: 40),
        PieChart(
          dataMap: {
            "Invested": totalInvested,
            "Profit": totalProfit > 0 ? totalProfit : 0,
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
          Icon(Icons.query_stats, size: 80, color: AppTheme.growwBorder),
          SizedBox(height: 16),
          Text("Calculate returns to see charts", style: AppTheme.subHeadlineStyle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      calculatorUI(),
      chartUI(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.growwBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        title: const Text("Stock Returns", style: TextStyle(color: AppTheme.growwText, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: AppTheme.growwText), onPressed: () => Navigator.pop(context)),
      ),
      body: screens[_currentIndex >= screens.length ? 0 : _currentIndex],
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