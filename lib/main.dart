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
    const peach = Color(0xFFFFEFDC);        // พื้นหลังครีม
    const peachStrong = Color(0xFFFBD6C3);  // พีชเข้ม (appbar/nav)

    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8D6E63)),
      useMaterial3: true,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => prov.TxnProvider()),
      ],
      child: MaterialApp(
        title: 'SpendLite',
        theme: base.copyWith(
          scaffoldBackgroundColor: peach,
          appBarTheme: const AppBarTheme(
            backgroundColor: peachStrong,
            foregroundColor: Color(0xFF4E342E),
            centerTitle: true,
            elevation: 0,
          ),
          bottomAppBarTheme: const BottomAppBarTheme(color: peachStrong),
          navigationBarTheme: const NavigationBarThemeData(
            backgroundColor: peachStrong,
            indicatorColor: Color(0xFFFFF5E5),
            labelTextStyle: WidgetStatePropertyAll(
              TextStyle(color: Color(0xFF5D4037)),
            ),
          ),
          // กล่อง/ป้ายรายการให้สีขาวเด่นกว่าพื้นหลัง
          cardColor: Colors.white,
          listTileTheme: const ListTileThemeData(
            tileColor: Colors.white,
            iconColor: Colors.black54,
            textColor: Colors.black87,
          ),
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
  final _pages = [const HomePage(), const SummaryPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'รายการ'),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline), selectedIcon: Icon(Icons.pie_chart), label: 'สรุป'),
        ],
        onDestinationSelected: (i) => setState(() => _idx = i),
      ),
    );
  }
}
