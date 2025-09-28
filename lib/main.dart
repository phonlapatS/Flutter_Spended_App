// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/txn_providers.dart';

// ตั้ง alias กันชื่อชน
import 'pages/home_page.dart' as hp;
import 'pages/summary_page.dart' as sp;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TxnProvider()..load(),
      child: const SpendLiteApp(),
    ),
  );
}

class SpendLiteApp extends StatelessWidget {
  const SpendLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpendLite',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFFFD9C5),
      ),
      home: const RootTabs(),
    );
  }
}

class RootTabs extends StatefulWidget {
  const RootTabs({super.key});
  @override
  State<RootTabs> createState() => _RootTabsState();
}

class _RootTabsState extends State<RootTabs> {
  int _idx = 0;

  // อ้างผ่าน alias ให้ชัดเจน
  final _pages = const [
    hp.HomePage(),
    sp.SummaryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'รายการ',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'สรุป',
          ),
        ],
        onDestinationSelected: (i) => setState(() => _idx = i),
      ),
    );
  }
}
