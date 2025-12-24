import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_expenses_tracker/data_entry/data_entry_page.dart';
import 'package:monthly_expenses_tracker/expenses_by_month/expenses_by_month_page.dart';
import 'package:monthly_expenses_tracker/expenses_by_year/expenses_by_year_page.dart';
import 'package:monthly_expenses_tracker/expenses_data/expenses_data_repository.dart';
import 'package:monthly_expenses_tracker/expenses_export/expenses_export_page.dart';
import 'package:monthly_expenses_tracker/expenses_import/expenses_import_page.dart';

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
      title: 'Monthly Expenses Tracker',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.amber),
        textTheme: GoogleFonts.lexendTextTheme(),
      ),
      home: ExpensesDataRepositoryLoader(child: DataEntryPage()),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: ExpensesImportPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
