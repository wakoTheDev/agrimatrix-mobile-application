import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';



void main() {
  runApp(const AgriFinancePlannerApp());
}

class AgriFinancePlannerApp extends StatelessWidget {
  const AgriFinancePlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriFinance Planner',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AgriFinancePlannerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AgriFinancePlannerScreen extends StatefulWidget {
  const AgriFinancePlannerScreen({super.key});

  @override
  _AgriFinancePlannerScreenState createState() => _AgriFinancePlannerScreenState();
}

class _AgriFinancePlannerScreenState extends State<AgriFinancePlannerScreen> {
  int _selectedIndex = 0;
  final FinanceDataManager _dataManager = FinanceDataManager();

  static const List<Widget> _widgetOptions = <Widget>[
    BudgetBuilderScreen(),
    ProfitabilityCalculatorScreen(),
    SavingsGoalsScreen(),
    LoanRepaymentScreen(),
    CashFlowDashboardScreen(),
    FinancialDiaryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriFinance Planner'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportData,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // Language selection logic
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'en', child: Text('English')),
              PopupMenuItem(value: 'sw', child: Text('Kiswahili')),
              PopupMenuItem(value: 'luo', child: Text('Luo')),
            ],
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Profitability',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings),
            label: 'Savings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Loans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Cash Flow',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Diary',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[800],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Future<void> _exportData() async {
    try {
      final data = await _dataManager.exportAllData();
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/agri_finance_export.json');
      await file.writeAsString(jsonEncode(data));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data exported successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }
}

// Data Models
class Budget {
  String id;
  String name;
  String season;
  DateTime startDate;
  DateTime endDate;
  Map<String, double> categories;
  double totalBudget;

  Budget({
    required this.id,
    required this.name,
    required this.season,
    required this.startDate,
    required this.endDate,
    required this.categories,
    required this.totalBudget,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'season': season,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'categories': categories,
    'totalBudget': totalBudget,
  };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
    id: json['id'],
    name: json['name'],
    season: json['season'],
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    categories: Map<String, double>.from(json['categories']),
    totalBudget: json['totalBudget'].toDouble(),
  );
}

class SavingsGoal {
  String id;
  String name;
  String description;
  double targetAmount;
  double currentAmount;
  DateTime targetDate;
  DateTime createdDate;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.createdDate,
  });

  double get progress => currentAmount / targetAmount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'targetDate': targetDate.toIso8601String(),
    'createdDate': createdDate.toIso8601String(),
  };

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    targetAmount: json['targetAmount'].toDouble(),
    currentAmount: json['currentAmount'].toDouble(),
    targetDate: DateTime.parse(json['targetDate']),
    createdDate: DateTime.parse(json['createdDate']),
  );
}

class FinancialTransaction {
  String id;
  String category;
  String description;
  double amount;
  DateTime date;
  String type; // income or expense

  FinancialTransaction({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'description': description,
    'amount': amount,
    'date': date.toIso8601String(),
    'type': type,
  };

  factory FinancialTransaction.fromJson(Map<String, dynamic> json) => FinancialTransaction(
    id: json['id'],
    category: json['category'],
    description: json['description'],
    amount: json['amount'].toDouble(),
    date: DateTime.parse(json['date']),
    type: json['type'],
  );
}

class Loan {
  String id;
  String lenderName;
  double principalAmount;
  double interestRate;
  int termMonths;
  DateTime startDate;
  double monthlyPayment;
  double remainingBalance;

  Loan({
    required this.id,
    required this.lenderName,
    required this.principalAmount,
    required this.interestRate,
    required this.termMonths,
    required this.startDate,
    required this.monthlyPayment,
    required this.remainingBalance,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'lenderName': lenderName,
    'principalAmount': principalAmount,
    'interestRate': interestRate,
    'termMonths': termMonths,
    'startDate': startDate.toIso8601String(),
    'monthlyPayment': monthlyPayment,
    'remainingBalance': remainingBalance,
  };

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
    id: json['id'],
    lenderName: json['lenderName'],
    principalAmount: json['principalAmount'].toDouble(),
    interestRate: json['interestRate'].toDouble(),
    termMonths: json['termMonths'],
    startDate: DateTime.parse(json['startDate']),
    monthlyPayment: json['monthlyPayment'].toDouble(),
    remainingBalance: json['remainingBalance'].toDouble(),
  );
}

// Data Manager
class FinanceDataManager {
  static final FinanceDataManager _instance = FinanceDataManager._internal();
  factory FinanceDataManager() => _instance;
  FinanceDataManager._internal();

  List<Budget> _budgets = [];
  List<SavingsGoal> _savingsGoals = [];
  List<FinancialTransaction> _transactions = [];
  List<Loan> _loans = [];

  // Budget methods
  List<Budget> get budgets => _budgets;
  
  void addBudget(Budget budget) {
    _budgets.add(budget);
    _saveData();
  }

  void updateBudget(Budget budget) {
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      _budgets[index] = budget;
      _saveData();
    }
  }

  void deleteBudget(String id) {
    _budgets.removeWhere((b) => b.id == id);
    _saveData();
  }

  // Savings Goals methods
  List<SavingsGoal> get savingsGoals => _savingsGoals;
  
  void addSavingsGoal(SavingsGoal goal) {
    _savingsGoals.add(goal);
    _saveData();
  }

  void updateSavingsGoal(SavingsGoal goal) {
    final index = _savingsGoals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _savingsGoals[index] = goal;
      _saveData();
    }
  }

  // Transactions methods
  List<FinancialTransaction> get transactions => _transactions;
  
  void addTransaction(FinancialTransaction transaction) {
    _transactions.add(transaction);
    _saveData();
  }

  // Loans methods
  List<Loan> get loans => _loans;
  
  void addLoan(Loan loan) {
    _loans.add(loan);
    _saveData();
  }

  void updateLoan(Loan loan) {
    final index = _loans.indexWhere((l) => l.id == loan.id);
    if (index != -1) {
      _loans[index] = loan;
      _saveData();
    }
  }

  // Analytics methods
  double getTotalIncome(DateTime startDate, DateTime endDate) {
    return _transactions
        .where((t) => t.type == 'income' && 
               t.date.isAfter(startDate) && 
               t.date.isBefore(endDate))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalExpenses(DateTime startDate, DateTime endDate) {
    return _transactions
        .where((t) => t.type == 'expense' && 
               t.date.isAfter(startDate) && 
               t.date.isBefore(endDate))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<String, double> getExpensesByCategory(DateTime startDate, DateTime endDate) {
    final expenses = _transactions
        .where((t) => t.type == 'expense' && 
               t.date.isAfter(startDate) && 
               t.date.isBefore(endDate))
        .toList();
    
    Map<String, double> categories = {};
    for (var expense in expenses) {
      categories[expense.category] = (categories[expense.category] ?? 0) + expense.amount;
    }
    return categories;
  }

  Future<void> _saveData() async {
    // Save data to local storage
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/agri_finance_data.json');
      
      final data = {
        'budgets': _budgets.map((b) => b.toJson()).toList(),
        'savingsGoals': _savingsGoals.map((g) => g.toJson()).toList(),
        'transactions': _transactions.map((t) => t.toJson()).toList(),
        'loans': _loans.map((l) => l.toJson()).toList(),
      };
      
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  Future<void> loadData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/agri_finance_data.json');
      
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final data = jsonDecode(jsonString);
        
        _budgets = (data['budgets'] as List?)
            ?.map((b) => Budget.fromJson(b))
            .toList() ?? [];
        
        _savingsGoals = (data['savingsGoals'] as List?)
            ?.map((g) => SavingsGoal.fromJson(g))
            .toList() ?? [];
        
        _transactions = (data['transactions'] as List?)
            ?.map((t) => FinancialTransaction.fromJson(t))
            .toList() ?? [];
        
        _loans = (data['loans'] as List?)
            ?.map((l) => Loan.fromJson(l))
            .toList() ?? [];
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  Future<Map<String, dynamic>> exportAllData() async {
    return {
      'budgets': _budgets.map((b) => b.toJson()).toList(),
      'savingsGoals': _savingsGoals.map((g) => g.toJson()).toList(),
      'transactions': _transactions.map((t) => t.toJson()).toList(),
      'loans': _loans.map((l) => l.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }
}

// Budget Builder Screen
class BudgetBuilderScreen extends StatefulWidget {
  const BudgetBuilderScreen({Key? key}) : super(key: key);

  @override
  _BudgetBuilderScreenState createState() => _BudgetBuilderScreenState();
}

class _BudgetBuilderScreenState extends State<BudgetBuilderScreen> {
  final FinanceDataManager _dataManager = FinanceDataManager();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _seasonController = TextEditingController();
  
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 365));
  
  final Map<String, TextEditingController> _categoryControllers = {
    'Seeds': TextEditingController(),
    'Fertilizers': TextEditingController(),
    'Pesticides': TextEditingController(),
    'Labor': TextEditingController(),
    'Transport': TextEditingController(),
    'Storage': TextEditingController(),
    'Equipment': TextEditingController(),
    'Other': TextEditingController(),
  };

  @override
  void dispose() {
    _nameController.dispose();
    _seasonController.dispose();
    _categoryControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet, 
                         color: Colors.green[700], size: 30),
                    const SizedBox(width: 12),
                    Text(
                      'Budget Builder',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Budget List and Form
            Expanded(
              child: Row(
                children: [
                  // Existing Budgets List
                  Expanded(
                    flex: 1,
                    child: _buildBudgetsList(),
                  ),
                  const SizedBox(width: 16),
                  
                  // Budget Form
                  Expanded(
                    flex: 2,
                    child: _buildBudgetForm(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Existing Budgets',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _dataManager.budgets.length,
                itemBuilder: (context, index) {
                  final budget = _dataManager.budgets[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(budget.name),
                      subtitle: Text(
                        '${budget.season} - KES ${NumberFormat('#,##0').format(budget.totalBudget)}'
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editBudget(budget),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteBudget(budget.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New Budget',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Basic Information
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Budget Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a budget name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _seasonController,
                      decoration: const InputDecoration(
                        labelText: 'Season/Crop',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter season or crop';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Date Selection
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Start Date'),
                      subtitle: Text(DateFormat('MMM dd, yyyy').format(_startDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('End Date'),
                      subtitle: Text(DateFormat('MMM dd, yyyy').format(_endDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Budget Categories
              const Text(
                'Budget Categories (KES)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _categoryControllers.length,
                  itemBuilder: (context, index) {
                    final category = _categoryControllers.keys.elementAt(index);
                    final controller = _categoryControllers[category]!;
                    
                    return TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: category,
                        border: const OutlineInputBorder(),
                        prefixText: 'KES ',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Total and Submit
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: Colors.green[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'Total Budget',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'KES ${NumberFormat('#,##0').format(_calculateTotal())}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveBudget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: const Text('Save Budget'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateTotal() {
    double total = 0;
    for (var controller in _categoryControllers.values) {
      final value = double.tryParse(controller.text) ?? 0;
      total += value;
    }
    return total;
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1095)),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _saveBudget() {
    if (_formKey.currentState!.validate()) {
      final categories = <String, double>{};
      _categoryControllers.forEach((category, controller) {
        final value = double.tryParse(controller.text) ?? 0;
        if (value > 0) {
          categories[category] = value;
        }
      });

      final budget = Budget(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        season: _seasonController.text,
        startDate: _startDate,
        endDate: _endDate,
        categories: categories,
        totalBudget: _calculateTotal(),
      );

      _dataManager.addBudget(budget);
      _clearForm();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget saved successfully!')),
      );

      setState(() {});
    }
  }

  void _clearForm() {
    _nameController.clear();
    _seasonController.clear();
    for (var controller in _categoryControllers.values) {
      controller.clear();
    }
  }

  void _editBudget(Budget budget) {
    _nameController.text = budget.name;
    _seasonController.text = budget.season;
    _startDate = budget.startDate;
    _endDate = budget.endDate;
    
    budget.categories.forEach((category, amount) {
      if (_categoryControllers.containsKey(category)) {
        _categoryControllers[category]!.text = amount.toString();
      }
    });
    
    setState(() {});
  }

  void _deleteBudget(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: const Text('Are you sure you want to delete this budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _dataManager.deleteBudget(id);
              Navigator.pop(context);
              setState(() {});
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Budget deleted successfully!')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Profitability Calculator Screen
class ProfitabilityCalculatorScreen extends StatefulWidget {
  const ProfitabilityCalculatorScreen({super.key});

  @override
  _ProfitabilityCalculatorScreenState createState() => _ProfitabilityCalculatorScreenState();
}

class _ProfitabilityCalculatorScreenState extends State<ProfitabilityCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cropController = TextEditingController();
  final _acreageController = TextEditingController();
  final _yieldController = TextEditingController();
  final _priceController = TextEditingController();
  final _inputCostController = TextEditingController();
  final _laborCostController = TextEditingController();
  final _transportCostController = TextEditingController();
  final _otherCostController = TextEditingController();

  double _revenue = 0;
  double _totalCosts = 0;
  double _profit = 0;
  double _roi = 0;
  double _profitMargin = 0;

  @override
  void dispose() {
    _cropController.dispose();
    _acreageController.dispose();
    _yieldController.dispose();
    _priceController.dispose();
    _inputCostController.dispose();
    _laborCostController.dispose();
    _transportCostController.dispose();
    _otherCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.trending_up, 
                         color: Colors.green[700], size: 30),
                    const SizedBox(width: 12),
                    Text(
                      'Profitability Calculator',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: Row(
                children: [
                  // Input Form
                  Expanded(
                    flex: 2,
                    child: _buildInputForm(),
                  ),
                  const SizedBox(width: 16),
                  
                  // Results Display
                  Expanded(
                    flex: 1,
                    child: _buildResultsDisplay(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Farm Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Crop and Acreage
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cropController,
                      decoration: const InputDecoration(
                        labelText: 'Crop/Produce',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Maize, Tomatoes',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter crop type';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _acreageController,
                      decoration: const InputDecoration(
                        labelText: 'Acreage',
                        border: OutlineInputBorder(),
                        suffixText: 'acres',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter acreage';
                        }
                        return null;
                      },
                      onChanged: (value) => _calculateProfitability(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Yield and Price
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yieldController,
                      decoration: const InputDecoration(
                        labelText: 'Expected Yield',
                        border: OutlineInputBorder(),
                        suffixText: 'kg/acre',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter expected yield';
                        }
                        return null;
                      },
                      onChanged: (value) => _calculateProfitability(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Market Price',
                        border: OutlineInputBorder(),
                        prefixText: 'KES ',
                        suffixText: '/kg',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter market price';
                        }
                        return null;
                      },
                      onChanged: (value) => _calculateProfitability(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Cost Breakdown (KES)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Cost inputs
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _inputCostController,
                            decoration: const InputDecoration(
                              labelText: 'Input Costs',
                              border: OutlineInputBorder(),
                              prefixText: 'KES ',
                              hintText: 'Seeds, fertilizer, pesticides',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => _calculateProfitability(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _laborCostController,
                            decoration: const InputDecoration(
                              labelText: 'Labor Costs',
                              border: OutlineInputBorder(),
                              prefixText: 'KES ',
                              hintText: 'Planting, weeding, harvesting',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => _calculateProfitability(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _transportCostController,
                            decoration: const InputDecoration(
                              labelText: 'Transport Costs',
                              border: OutlineInputBorder(),
                              prefixText: 'KES ',
                              hintText: 'To market/storage',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => _calculateProfitability(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _otherCostController,
                            decoration: const InputDecoration(
                              labelText: 'Other Costs',
                              border: OutlineInputBorder(),
                              prefixText: 'KES ',
                              hintText: 'Storage, packaging, etc.',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => _calculateProfitability(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Calculate Button
              Center(
                child: ElevatedButton(
                  onPressed: _calculateProfitability,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Calculate Profitability'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsDisplay() {
    return Column(
      children: [
        // Summary Card
        Card(
          color: Colors.green[50],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profitability Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildResultRow('Total Revenue', _revenue, Colors.green),
                _buildResultRow('Total Costs', _totalCosts, Colors.orange),
                const Divider(thickness: 2),
                _buildResultRow('Net Profit', _profit, 
                    _profit >= 0 ? Colors.green : Colors.red),
                const SizedBox(height: 16),
                
                _buildMetricRow('ROI', '${_roi.toStringAsFixed(1)}%'),
                _buildMetricRow('Profit Margin', '${_profitMargin.toStringAsFixed(1)}%'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Recommendations Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recommendations',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                ..._generateRecommendations().map((recommendation) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb, size: 16, color: Colors.amber),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            recommendation,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultRow(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            'KES ${NumberFormat('#,##0').format(value)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  void _calculateProfitability() {
    final acreage = double.tryParse(_acreageController.text) ?? 0;
    final yield = double.tryParse(_yieldController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    final inputCost = double.tryParse(_inputCostController.text) ?? 0;
    final laborCost = double.tryParse(_laborCostController.text) ?? 0;
    final transportCost = double.tryParse(_transportCostController.text) ?? 0;
    final otherCost = double.tryParse(_otherCostController.text) ?? 0;

    setState(() {
      _revenue = acreage * yield * price;
      _totalCosts = inputCost + laborCost + transportCost + otherCost;
      _profit = _revenue - _totalCosts;
      _roi = _totalCosts > 0 ? (_profit / _totalCosts) * 100 : 0;
      _profitMargin = _revenue > 0 ? (_profit / _revenue) * 100 : 0;
    });
  }

  List<String> _generateRecommendations() {
    List<String> recommendations = [];
    
    if (_roi < 10) {
      recommendations.add('Consider reducing input costs or finding higher-value markets.');
    }
    if (_profitMargin < 20) {
      recommendations.add('Explore value addition opportunities to increase profit margins.');
    }
    if (_profit < 0) {
      recommendations.add('Review your cost structure - this crop may not be profitable.');
    }
    if (_roi > 50) {
      recommendations.add('Excellent returns! Consider expanding this crop.');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('Good profitability. Monitor market prices regularly.');
    }
    
    return recommendations;
  }
}

// Savings Goals Screen
class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  _SavingsGoalsScreenState createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  final FinanceDataManager _dataManager = FinanceDataManager();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _contributionController = TextEditingController();
  
  DateTime _targetDate = DateTime.now().add(const Duration(days: 365));

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _contributionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.savings, 
                         color: Colors.green[700], size: 30),
                    const SizedBox(width: 12),
                    Text(
                      'Savings Goals',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: Row(
                children: [
                  // Goals List
                  Expanded(
                    flex: 2,
                    child: _buildGoalsList(),
                  ),
                  const SizedBox(width: 16),
                  
                  // New Goal Form
                  Expanded(
                    flex: 1,
                    child: _buildGoalForm(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Savings Goals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: ListView.builder(
                itemCount: _dataManager.savingsGoals.length,
                itemBuilder: (context, index) {
                  final goal = _dataManager.savingsGoals[index];
                  return _buildGoalCard(goal);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(SavingsGoal goal) {
    final progress = goal.progress.clamp(0.0, 1.0);
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: progress >= 1.0 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Text(
              goal.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            
            // Progress Bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KES ${NumberFormat('#,##0').format(goal.currentAmount)} / ${NumberFormat('#,##0').format(goal.targetAmount)}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  daysLeft > 0 ? '$daysLeft days left' : 'Overdue',
                  style: TextStyle(
                    fontSize: 12,
                    color: daysLeft > 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _addContribution(goal),
                  child: const Text('Add Money'),
                ),
                TextButton(
                  onPressed: () => _editGoal(goal),
                  child: const Text('Edit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New Goal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Goal Name',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., New Tractor',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter goal name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _targetAmountController,
                decoration: const InputDecoration(
                  labelText: 'Target Amount',
                  border: OutlineInputBorder(),
                  prefixText: 'KES ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter target amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              ListTile(
                title: const Text('Target Date'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(_targetDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectTargetDate,
              ),
              const SizedBox(height: 16),
              
              ElevatedButton(
                onPressed: _createGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Create Goal'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectTargetDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
    );
    
    if (picked != null) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  void _createGoal() {
    if (_formKey.currentState!.validate()) {
      final goal = SavingsGoal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        targetAmount: double.parse(_targetAmountController.text),
        currentAmount: 0,
        targetDate: _targetDate,
        createdDate: DateTime.now(),
      );

      _dataManager.addSavingsGoal(goal);
      _clearForm();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Savings goal created successfully!')),
      );

      setState(() {});
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _targetAmountController.clear();
    _targetDate = DateTime.now().add(const Duration(days: 365));
  }

  void _addContribution(SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Contribution'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add money to: ${goal.name}'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contributionController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixText: 'KES ',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(_contributionController.text) ?? 0;
              if (amount > 0) {
                goal.currentAmount += amount;
                _dataManager.updateSavingsGoal(goal);
                _contributionController.clear();
                Navigator.pop(context);
                setState(() {});
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contribution added successfully!')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editGoal(SavingsGoal goal) {
    _nameController.text = goal.name;
    _descriptionController.text = goal.description;
    _targetAmountController.text = goal.targetAmount.toString();
    _targetDate = goal.targetDate;
    
    // Implementation for editing would be similar to create
  }
}

// Loan Repayment Screen
class LoanRepaymentScreen extends StatefulWidget {
  const LoanRepaymentScreen({super.key});

  @override
  _LoanRepaymentScreenState createState() => _LoanRepaymentScreenState();
}

class _LoanRepaymentScreenState extends State<LoanRepaymentScreen> {
  final FinanceDataManager _dataManager = FinanceDataManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.payment, 
                         color: Colors.green[700], size: 30),
                    const SizedBox(width: 12),
                    Text(
                      'Loan Repayment Tracker',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Summary Cards
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Total Loans', _dataManager.loans.length.toString(), Icons.account_balance)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('Total Balance', 'KES ${NumberFormat('#,##0').format(_getTotalBalance())}', Icons.money)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('Monthly Payment', 'KES ${NumberFormat('#,##0').format(_getTotalMonthlyPayment())}', Icons.calendar_month)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Loans List
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Your Loans',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _addNewLoan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                            ),
                            child: const Text('Add Loan'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Expanded(
                        child: ListView.builder(
                          itemCount: _dataManager.loans.length,
                          itemBuilder: (context, index) {
                            final loan = _dataManager.loans[index];
                            return _buildLoanCard(loan);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: Colors.green[700], size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanCard(Loan loan) {
    final progress = (loan.principalAmount - loan.remainingBalance) / loan.principalAmount;
    final monthsElapsed = DateTime.now().difference(loan.startDate).inDays ~/ 30;
    final remainingMonths = loan.termMonths - monthsElapsed;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loan.lenderName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${loan.interestRate.toStringAsFixed(1)}% APR',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Progress Bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remaining Balance',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      'KES ${NumberFormat('#,##0').format(loan.remainingBalance)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Monthly Payment',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      'KES ${NumberFormat('#,##0').format(loan.monthlyPayment)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Remaining: $remainingMonths months',
                  style: const TextStyle(fontSize: 12),
                ),
                TextButton(
                  onPressed: () => _makePayment(loan),
                  child: const Text('Make Payment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _getTotalBalance() {
    return _dataManager.loans.fold(0, (sum, loan) => sum + loan.remainingBalance);
  }

  double _getTotalMonthlyPayment() {
    return _dataManager.loans.fold(0, (sum, loan) => sum + loan.monthlyPayment);
  }

  void _addNewLoan() {
    // Implementation for adding new loan
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Loan'),
        content: const Text('Loan addition form would be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _makePayment(Loan loan) {
    // Implementation for making payment
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Make Payment'),
        content: const Text('Payment processing would be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Cash Flow Dashboard Screen
// Cash Flow Dashboard Screen
class CashFlowDashboardScreen extends StatefulWidget {
  const CashFlowDashboardScreen({super.key});

  @override
  _CashFlowDashboardScreenState createState() => _CashFlowDashboardScreenState();
}

class _CashFlowDashboardScreenState extends State<CashFlowDashboardScreen> {
  final FinanceDataManager _dataManager = FinanceDataManager();
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    final income = _dataManager.getTotalIncome(startDate, endDate);
    final expenses = _dataManager.getTotalExpenses(startDate, endDate);
    final balance = income - expenses;

    final categoryBreakdown = _dataManager.getExpensesByCategory(startDate, endDate);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Card(
              child: ListTile(
                leading: Icon(Icons.dashboard, color: Colors.green[700], size: 30),
                title: Text('Cash Flow Dashboard',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[700])),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selectMonth,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Income', income, Colors.green),
                _buildStatCard('Expenses', expenses, Colors.red),
                _buildStatCard('Balance', balance, balance >= 0 ? Colors.green : Colors.red),
              ],
            ),
            const SizedBox(height: 16),

            // Breakdown
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Expenses by Category',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView(
                          children: categoryBreakdown.entries.map((entry) {
                            return ListTile(
                              title: Text(entry.key),
                              trailing: Text(
                                'KES ${entry.value.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, double value, Color color) {
    return Expanded(
      child: Card(
        color: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text('KES ${value.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  void _selectMonth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      helpText: 'Select Month',
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }
}

// Financial Diary Screen
class FinancialDiaryScreen extends StatefulWidget {
  const FinancialDiaryScreen({super.key});

  @override
  _FinancialDiaryScreenState createState() => _FinancialDiaryScreenState();
}

class _FinancialDiaryScreenState extends State<FinancialDiaryScreen> {
  final FinanceDataManager _dataManager = FinanceDataManager();
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedType = 'expense';
  String _selectedCategory = 'General';

  final List<String> _categories = ['General', 'Input', 'Labor', 'Transport', 'Sales', 'Storage'];

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortedTransactions = [..._dataManager.transactions]
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Card(
              child: ListTile(
                leading: Icon(Icons.book, color: Colors.green[700], size: 30),
                title: Text('Financial Diary',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[700])),
              ),
            ),
            const SizedBox(height: 16),

            // New Entry Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedType,
                              items: ['income', 'expense'].map((e) => DropdownMenuItem(value: e, child: Text(e.capitalize()))).toList(),
                              onChanged: (value) => setState(() => _selectedType = value ?? 'expense'),
                              decoration: const InputDecoration(labelText: 'Type'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              items: _categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (value) => setState(() => _selectedCategory = value ?? 'General'),
                              decoration: const InputDecoration(labelText: 'Category'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descController,
                        decoration: const InputDecoration(labelText: 'Description'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(labelText: 'Amount (KES)', prefixText: 'KES '),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _saveEntry,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                        child: const Text('Add Entry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Diary List
            Expanded(
              child: ListView.builder(
                itemCount: sortedTransactions.length,
                itemBuilder: (context, index) {
                  final txn = sortedTransactions[index];
                  return ListTile(
                    leading: Icon(
                      txn.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                      color: txn.type == 'income' ? Colors.green : Colors.red,
                    ),
                    title: Text(txn.description),
                    subtitle: Text('${txn.category} - ${DateFormat.yMMMd().format(txn.date)}'),
                    trailing: Text(
                      'KES ${txn.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: txn.type == 'income' ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      final txn = FinancialTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: _selectedCategory,
        description: _descController.text,
        amount: double.parse(_amountController.text),
        date: DateTime.now(),
        type: _selectedType,
      );

      _dataManager.addTransaction(txn);
      _descController.clear();
      _amountController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry added successfully!')),
      );

      setState(() {});
    }
  }
}

// Extension method for capitalizing strings
extension StringCasingExtension on String {
  String capitalize() => length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
}
