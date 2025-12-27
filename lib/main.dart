import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_expenses_tracker/data_entry/data_entry_page.dart';
import 'package:monthly_expenses_tracker/expenses_by_month/expenses_by_month_page.dart';
import 'package:monthly_expenses_tracker/expenses_by_year/expenses_by_year_page.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data_repository.dart';
import 'package:monthly_expenses_tracker/expenses_export/expenses_export_page.dart';
import 'package:monthly_expenses_tracker/expenses_import/expenses_import_page.dart';
import 'package:monthly_expenses_tracker/menu/menu_sidebar.dart';

late ExpensesDataRepository repository;

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MONTHLY EXPENSES TRACKER',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.amber),
        textTheme: GoogleFonts.lexendTextTheme(),
      ),
      home: ExpensesDataRepositoryLoader(child: MyHomePage()),
    );
  }
}

typedef Page = ({
  String label,
  IconData icon,
  Widget Function() create,
  bool needsData,
  bool showOnTop,
});

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final pages = <Page>[
    (
      label: 'Add Expenses',
      icon: FontAwesomeIcons.moneyBill,
      create: () => DataEntryPage(),
      needsData: false,
      showOnTop: true,
    ),
    (
      label: 'Monthly Expenses',
      icon: FontAwesomeIcons.chartBar,
      create: () => ExpensesByMonthPage(),
      needsData: true,
      showOnTop: true,
    ),
    (
      label: 'Yearly Expenses',
      icon: FontAwesomeIcons.chartColumn,
      create: () => ExpensesByYearPage(),
      needsData: true,
      showOnTop: true,
    ),
    (
      label: 'Import Expenses',
      icon: FontAwesomeIcons.fileImport,
      create: () => ExpensesImportPage(),
      needsData: false,
      showOnTop: false,
    ),
    (
      label: 'Export Expenses',
      icon: FontAwesomeIcons.fileExport,
      create: () => ExpensesExportPage(),
      needsData: true,
      showOnTop: false,
    ),
  ];

  late ExpensesDataRepository repository;
  bool repositoryHadData = false;
  late Page selectedPage;

  @override
  void initState() {
    super.initState();
    selectedPage = pages[0];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      repository = ExpensesDataRepositoryProvider.of(context).repository;
      repositoryHadData = repository.hasData;
      repository.addListener(_repositoryStateChanged);
    });
  }

  @override
  void dispose() {
    repository.removeListener(_repositoryStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repository = ExpensesDataRepositoryProvider.of(context).repository;
    final backgroundColor = HSLColor.fromColor(
      theme.colorScheme.primary,
    ).withLightness(0.4).toColor();
    final menuItems = pages
        .map(
          (page) => (
            showOnTop: page.showOnTop,
            item: (
              label: page.label,
              icon: page.icon,
              selected: page == selectedPage,
              selectable: !page.needsData || repository.hasData,
              onSelected: !page.needsData || repository.hasData
                  ? () => setState(() => selectedPage = page)
                  : () {},
            ),
          ),
        )
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        bool useNarrowLayout = constraints.maxWidth < 900;
        final menu = Container(
          color: backgroundColor,
          child: Padding(
            padding: useNarrowLayout
                ? const EdgeInsets.all(0.0)
                : const EdgeInsets.all(10.0),
            child: SizedBox(
              width: 300,
              child: Container(
                color: theme.colorScheme.inversePrimary,
                child: MenuSidebar(
                  topItems: menuItems
                      .where((it) => it.showOnTop)
                      .map((it) => it.item)
                      .toList(),
                  bottomItems: menuItems
                      .where((it) => !it.showOnTop)
                      .map((it) => it.item)
                      .toList(),
                ),
              ),
            ),
          ),
        );

        return Scaffold(
          appBar: AppBar(
            foregroundColor: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.inversePrimary,
            title: Text(
              'MONTHLY EXPENSES TRACKER',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.primaryColor,
              ),
            ),
          ),
          drawer: useNarrowLayout ? Drawer(child: menu) : null,
          body: Row(
            children: [
              if (!useNarrowLayout) menu,
              Expanded(
                child: Container(
                  color: backgroundColor,
                  child: Padding(
                    padding: useNarrowLayout
                        ? const EdgeInsets.only()
                        : const EdgeInsets.only(
                            top: 10.0,
                            right: 10.0,
                            bottom: 10.0,
                          ),
                    child: selectedPage.create(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// There are certain pages which should be made inaccessible when there's no data.
  /// This listener callback changes the selected page when all of the data is deleted.
  void _repositoryStateChanged() {
    // Don't do anything if the repository's state of has/doesn't have data didn't change.
    if (repository.hasData == repositoryHadData) {
      return;
    }

    if (repository.hasData) {
      // The repository didn't have data, but now it does.
      setState(() => repositoryHadData = repository.hasData);
    } else {
      // The repository had data, but now it doesn't.
      setState(() {
        repositoryHadData = repository.hasData;
        selectedPage = pages[0];
      });
    }
  }
}
