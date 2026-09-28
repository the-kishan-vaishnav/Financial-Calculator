import 'package:flutter/material.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  String fromCurrency = "USD";
  String toCurrency = "INR";
  double inputAmount = 1.0;
  double exchangeRate = 83.25; // Example static rate

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
          "Currency Converter",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xFF44474b),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Check live exchange rates",
              style: TextStyle(color: Color(0xFF7c7e8c), fontSize: 14),
            ),
            const SizedBox(height: 30),

            // Input Card
            currencyCard("Amount to Convert", fromCurrency, true),

            // Swap Button
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 15),
                decoration: const BoxDecoration(
                  color: Color(0xFF00D09C),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.swap_vert, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      String temp = fromCurrency;
                      fromCurrency = toCurrency;
                      toCurrency = temp;
                    });
                  },
                ),
              ),
            ),

            // Output Card
            currencyCard("Converted Amount", toCurrency, false),

            const SizedBox(height: 40),

            // Info Row
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFf2faf7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF00D09C), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "1 $fromCurrency = $exchangeRate $toCurrency",
                      style: const TextStyle(
                        color: Color(0xFF44474b),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Convert Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D09C),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Refresh Rates",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget currencyCard(String label, String currencyCode, bool isInput) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFedf2f7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF7c7e8c), fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Currency Dropdown/Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFf8f9fb),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      currencyCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF44474b),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Color(0xFF7c7e8c)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Text Input
              Expanded(
                child: TextField(
                  readOnly: !isInput,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF44474b),
                  ),
                  decoration: InputDecoration(
                    hintText: isInput ? "0.00" : "${inputAmount * exchangeRate}",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}