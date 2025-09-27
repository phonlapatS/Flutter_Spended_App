// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spended/providers/txn_providers.dart' as prov;

import 'pages/home_page.dart';
import 'pages/summary_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SpendLiteApp());
}

class SpendLiteApp extends StatelessWidget {
  const SpendLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => prov.TxnProvider()),
      ],
      child: MaterialApp(
        title: 'Spended จ่ายแล้วจด',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
          useMaterial3: true,
        ),
        home: const _RootTabs(),
      ),
    );
  }
}

class _RootTabs extends StatefulWidget {
  const _RootTabs();
  @override
  State<_RootTabs> createState() => _RootTabsState();
}

class _RootTabsState extends State<_RootTabs> {
  int _idx = 0;
  final _pages = const [HomePage(), SummaryPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), label: 'รายการ'),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline), label: 'สรุป'),
        ],
        onDestinationSelected: (i) => setState(() => _idx = i),
      ),
    );
  }
}
