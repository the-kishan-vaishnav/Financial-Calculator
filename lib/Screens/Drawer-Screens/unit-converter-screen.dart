import 'package:flutter/material.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  // Categories for the unit converter
  final List<Map<String, dynamic>> categories = [
    {"name": "Length", "icon": Icons.straighten},
    {"name": "Area", "icon": Icons.layers_outlined},
    {"name": "Weight", "icon": Icons.monitor_weight_outlined},
    {"name": "Volume", "icon": Icons.opacity},
    {"name": "Temp", "icon": Icons.thermostat},
  ];

  String selectedCategory = "Length";
  String fromUnit = "Meters";
  String toUnit = "Feet";
  double inputValue = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF44474b),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Unit Converter",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xFF44474b),
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. Horizontal Category Selector
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedCategory == categories[index]['name'];
                return GestureDetector(
                  onTap: () => setState(
                    () => selectedCategory = categories[index]['name'],
                  ),
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFf2faf7)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF00D09C)
                            : const Color(0xFFedf2f7),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          categories[index]['icon'],
                          color: isSelected
                              ? const Color(0xFF00D09C)
                              : const Color(0xFF7c7e8c),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          categories[index]['name'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF44474b)
                                : const Color(0xFF7c7e8c),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // From Card
                  unitCard("From", fromUnit, true),

                  // Swap Button
                  Transform.translate(
                    offset: const Offset(0, 0),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00D09C),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.swap_vert,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                  // To Card
                  unitCard("To", toUnit, false),

                  const SizedBox(height: 30),

                  // Conversion formula display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFf8f9fb),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFedf2f7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Formula",
                          style: TextStyle(
                            color: Color(0xFF7c7e8c),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Multiply the length value by 3.281",
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget unitCard(String label, String unit, bool isInput) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFedf2f7), width: 1.5),
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
              Expanded(
                child: TextField(
                  readOnly: !isInput,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF44474b),
                  ),
                  decoration: InputDecoration(
                    hintText: isInput ? "1.0" : "3.2808",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Unit Selector
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFf2faf7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      unit,
                      style: const TextStyle(
                        color: Color(0xFF00D09C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF00D09C),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
