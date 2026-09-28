import 'package:flutter/material.dart';

enum CalculationMode { difference, addDuration }

class DateCalculatorScreen extends StatefulWidget {
  const DateCalculatorScreen({super.key});

  @override
  State<DateCalculatorScreen> createState() => _DateCalculatorScreenState();
}

class _DateCalculatorScreenState extends State<DateCalculatorScreen> {
  CalculationMode _mode = CalculationMode.difference;

  // State for Difference Mode
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 1));

  // State for Add Duration Mode
  int addYears = 0;
  int addMonths = 0;
  int addDays = 0;

  String resultText = "";

  @override
  void initState() {
    super.initState();
    calculate();
  }

  void calculate() {
    setState(() {
      if (_mode == CalculationMode.difference) {
        _calculateDifference();
      } else {
        _calculateFutureDate();
      }
    });
  }

  void _calculateDifference() {
    int years = endDate.year - startDate.year;
    int months = endDate.month - startDate.month;
    int days = endDate.day - startDate.day;

    if (days < 0) {
      months -= 1;
      days += DateTime(endDate.year, endDate.month, 0).day;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }

    if (endDate.isBefore(startDate)) {
      resultText = "End date must be after start date";
    } else {
      resultText = "$years Years, $months Months, $days Days";
    }
  }

  void _calculateFutureDate() {
    DateTime futureDate = DateTime(
      startDate.year + addYears,
      startDate.month + addMonths,
      startDate.day + addDays,
    );

    resultText = "${futureDate.day} / ${futureDate.month} / ${futureDate.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Date Calculator",
          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF44474b)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CHOICE CHIPS FOR MODE SELECTION ---
            Row(
              children: [
                ChoiceChip(
                  label: const Text("Difference"),
                  selected: _mode == CalculationMode.difference,
                  selectedColor: const Color(0xFF00D09C).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF00D09C),
                  labelStyle: TextStyle(
                    color: _mode == CalculationMode.difference ? const Color(0xFF00D09C) : const Color(0xFF7c7e8c),
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() {
                        _mode = CalculationMode.difference;
                        calculate();
                      });
                    }
                  },
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text("Add Duration"),
                  selected: _mode == CalculationMode.addDuration,
                  selectedColor: const Color(0xFF00D09C).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF00D09C),
                  labelStyle: TextStyle(
                    color: _mode == CalculationMode.addDuration ? const Color(0xFF00D09C) : const Color(0xFF7c7e8c),
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() {
                        _mode = CalculationMode.addDuration;
                        calculate();
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 25),

            const Text(
              "Start Date",
              style: TextStyle(color: Color(0xFF7c7e8c), fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _dateCard(startDate, () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: startDate,
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  startDate = picked;
                  calculate();
                });
              }
            }),

            const SizedBox(height: 20),

            // --- CONDITIONAL INPUTS ---
            if (_mode == CalculationMode.difference) ...[
              const Text(
                "End Date",
                style: TextStyle(color: Color(0xFF7c7e8c), fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _dateCard(endDate, () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: endDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    endDate = picked;
                    calculate();
                  });
                }
              }),
            ] else ...[
              const Text(
                "Time to Add",
                style: TextStyle(color: Color(0xFF7c7e8c), fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _durationInput("Years", (val) => setState(() { addYears = int.tryParse(val) ?? 0; calculate(); })),
                  const SizedBox(width: 10),
                  _durationInput("Months", (val) => setState(() { addMonths = int.tryParse(val) ?? 0; calculate(); })),
                  const SizedBox(width: 10),
                  _durationInput("Days", (val) => setState(() { addDays = int.tryParse(val) ?? 0; calculate(); })),
                ],
              ),
            ],

            const SizedBox(height: 40),

            // --- RESULT SECTION ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFFf2faf7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00D09C).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    _mode == CalculationMode.difference ? "TOTAL DURATION" : "NEXT DATE",
                    style: const TextStyle(color: Color(0xFF00D09C), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    resultText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF44474b),
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateCard(DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFedf2f7), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${date.day} / ${date.month} / ${date.year}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF44474b)),
            ),
            const Icon(Icons.calendar_today_rounded, color: Color(0xFF00D09C), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _durationInput(String label, Function(String) onChanged) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF7c7e8c))),
          const SizedBox(height: 5),
          TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFedf2f7)),
              ),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}