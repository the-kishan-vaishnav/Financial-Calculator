import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Login-Signin/login-screen.dart';
import 'dashboard-screen.dart';

const Color primaryGreen = Color(0xFF00D09C);
const Color darkText = Color(0xFF2D3137);
const Color subText = Color(0xFF7C828A);
const Color cardBg = Color(0xFFF9FAFB);

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  final List<Map<String, dynamic>> allCalculators = const [
    {"title": "Home Loan EMI", "icon": Icons.home_outlined},
    {"title": "Personal Loan EMI", "icon": Icons.person_outline},
    {"title": "Car / Bike Loan EMI", "icon": Icons.directions_car_outlined},
    {"title": "Education Loan EMI", "icon": Icons.school_outlined},
    {"title": "SIP Calculator", "icon": Icons.trending_up},
    {"title": "Mutual Fund Return", "icon": Icons.bar_chart},
    {"title": "Lumpsum Investment", "icon": Icons.pie_chart_outline},
    {"title": "Stock Return", "icon": Icons.show_chart},
    {"title": "Fixed Deposit (FD)", "icon": Icons.savings_outlined},
    {"title": "Recurring Deposit (RD)", "icon": Icons.calculate_outlined},
    {"title": "Post Office RD", "icon": Icons.account_balance_outlined},
    {"title": "Post Office FD", "icon": Icons.attach_money},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Admin Panel",
            style: TextStyle(color: darkText, fontWeight: FontWeight.w800, fontSize: 22)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Option to see User Dashboard
          IconButton(
            icon: const Icon(Icons.dashboard_outlined, color: darkText),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FinanceDashboard()));
            },
            tooltip: "View Dashboard",
          ),
          // Logout Option
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
            tooltip: "Logout",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('user').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: primaryGreen));

          final users = snapshot.data!.docs;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text("${users.length} Total Users",
                    style: const TextStyle(color: subText, fontWeight: FontWeight.w600)),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var userData = users[index].data() as Map<String, dynamic>;
                    String userId = users[index].id;
                    List granted = userData['accessibleCalculators'] ?? [];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEDF2F7)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: primaryGreen.withOpacity(0.1),
                          child: Text(userData['name']?[0].toUpperCase() ?? "U",
                              style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        title: Text(userData['name'] ?? "Unknown User",
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: darkText)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(userData['email'] ?? "", style: const TextStyle(color: subText, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text("ID: $userId", style: TextStyle(color: subText.withOpacity(0.5), fontSize: 10)),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_forward_ios, size: 14, color: subText),
                            const SizedBox(height: 4),
                            Text("${granted.length} active", style: const TextStyle(color: primaryGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        onTap: () => _showManageAccess(context, userId, userData['name'] ?? "User", granted),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showManageAccess(BuildContext context, String uid, String name, List current) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 15),
                Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10))),
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("User Permissions", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: darkText)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: CircleAvatar(backgroundColor: cardBg, child: const Icon(Icons.close, color: darkText, size: 20)),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: allCalculators.length,
                    itemBuilder: (context, index) {
                      final calc = allCalculators[index];
                      bool isSelected = current.contains(calc['title']);

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryGreen.withOpacity(0.05) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CheckboxListTile(
                          value: isSelected,
                          activeColor: primaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          title: Text(calc['title'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          secondary: Icon(calc['icon'], color: isSelected ? primaryGreen : subText),
                          onChanged: (val) async {
                            if (val == true) {
                              current.add(calc['title']);
                            } else {
                              current.remove(calc['title']);
                            }
                            await FirebaseFirestore.instance.collection('user').doc(uid).update({
                              'accessibleCalculators': current,
                            });
                            setModalState(() {});
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        });
      },
    );
  }
}