import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/design_tokens.dart';
import '../../providers/app_provider.dart';
import '../../providers/api_expense_provider.dart';
import '../../services/services.dart';
import '../../constants/categories.dart';
import '../../widgets/fintech/fintech_widgets.dart';

class NewExpenseScreen extends StatefulWidget {
  const NewExpenseScreen({super.key});

  @override
  State<NewExpenseScreen> createState() => _NewExpenseScreenState();
}

class _NewExpenseScreenState extends State<NewExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedDepartmentId;
  String? _selectedCostCenterId;
  String _selectedCurrency = 'IDR';
  String _selectedExpenseType = 'reimbursement';
  bool _submitForApproval = false;
  DateTime _selectedDate = DateTime.now();
  bool _isEditing = false;
  String? _editingApiId;
  bool _isInitialized = false;

  final List<String> _currencies = ['IDR', 'USD', 'SGD', 'MYR', 'EUR', 'JPY', 'AUD'];

  final List<Map<String, dynamic>> _expenseTypes = [
    {'value': 'reimbursement', 'label': 'Reimbursement', 'icon': CupertinoIcons.doc_text_fill},
    {'value': 'card', 'label': 'Card', 'icon': CupertinoIcons.creditcard_fill},
    {'value': 'petty_cash', 'label': 'Petty Cash', 'icon': CupertinoIcons.money_dollar_circle_fill},
    {'value': 'cash_advance', 'label': 'Advance', 'icon': CupertinoIcons.arrow_right_circle_fill},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;

    final apiProvider = context.read<ApiExpenseProvider>();
    await apiProvider.fetchReferenceData();
    _loadEditingData();

    _isInitialized = true;
  }

  void _loadEditingData() {
    final apiProvider = context.read<ApiExpenseProvider>();
    final expense = apiProvider.selectedExpense;

    if (expense != null && (expense.status == 0 || expense.status == 7)) {
      setState(() {
        _isEditing = true;
        _editingApiId = expense.id;
        _merchantController.text = expense.merchant;
        _amountController.text = expense.originalAmount.toStringAsFixed(0);
        _selectedCategoryId = expense.categoryId;
        _selectedDepartmentId = expense.departmentId;
        _selectedCostCenterId = expense.costCenterId;
        _selectedCurrency = expense.originalCurrency;
        _selectedExpenseType = expense.expenseType.isNotEmpty ? expense.expenseType : 'reimbursement';
        _notesController.text = expense.description ?? '';
        _selectedDate = expense.expenseDate;
      });
    } else {
      if (apiProvider.categories.isNotEmpty) {
        setState(() {
          _selectedCategoryId = apiProvider.categories.first.id;
        });
      }
    }
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info banner for new expense
                      if (!_isEditing) _buildInfoBanner(),

                      // Amount Section (Hero)
                      _buildAmountSection(),

                      // Form Fields
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Merchant
                            _buildSectionTitle('Merchant / Vendor', CupertinoIcons.building_2_fill),
                            const SizedBox(height: 12),
                            _buildModernTextField(
                              controller: _merchantController,
                              hint: 'Where did you spend?',
                              icon: CupertinoIcons.bag_fill,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter merchant name';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 24),

                            // Expense Type
                            _buildSectionTitle('Expense Type', CupertinoIcons.tag_fill),
                            const SizedBox(height: 12),
                            _buildExpenseTypeSelector(),

                            const SizedBox(height: 24),

                            // Category
                            _buildSectionTitle('Category', CupertinoIcons.folder_fill),
                            const SizedBox(height: 12),
                            _buildCategorySelector(),

                            const SizedBox(height: 24),

                            // Date
                            _buildSectionTitle('Date', CupertinoIcons.calendar),
                            const SizedBox(height: 12),
                            _buildDateSelector(),

                            const SizedBox(height: 24),

                            // Department & Cost Center Row
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionTitle('Department', CupertinoIcons.person_2_fill, small: true),
                                      const SizedBox(height: 8),
                                      _buildDepartmentDropdown(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionTitle('Cost Center', CupertinoIcons.chart_pie_fill, small: true),
                                      const SizedBox(height: 8),
                                      _buildCostCenterDropdown(),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Notes
                            _buildSectionTitle(
                              'Notes ${!_isEditing ? "(Required)" : "(Optional)"}',
                              CupertinoIcons.text_quote,
                            ),
                            const SizedBox(height: 12),
                            _buildModernTextField(
                              controller: _notesController,
                              hint: 'Business justification or details...',
                              icon: CupertinoIcons.pencil,
                              maxLines: 3,
                              validator: !_isEditing
                                  ? (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Notes are required for expenses without receipt';
                                      }
                                      return null;
                                    }
                                  : null,
                            ),

                            const SizedBox(height: 32),

                            // Action Buttons
                            _buildActionButtons(),

                            const SizedBox(height: 40),
                          ],
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

  Widget _buildHeader() {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.read<ApiExpenseProvider>().setSelectedExpense(null);
              context.read<AppProvider>().goBack();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                CupertinoIcons.back,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Edit Expense' : 'New Expense',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isEditing ? 'Update your expense details' : 'Create a new expense claim',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: AlertBanner(
        icon: CupertinoIcons.info_circle_fill,
        iconColor: FintechColors.categoryBlue,
        backgroundColor: FintechColors.categoryBlueBg,
        title: 'Manual Entry',
        subtitle: 'This expense will need a receipt attachment before submission.',
      ),
    );
  }

  Widget _buildAmountSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: FintechColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Enter Amount',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Currency Selector
              GestureDetector(
                onTap: _showCurrencyPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _selectedCurrency,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        CupertinoIcons.chevron_down,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Amount Input - Using Container with white background for visibility
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    cursorColor: FintechColors.primary,
                    cursorWidth: 2,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: FintechColors.primary,
                      letterSpacing: -1,
                    ),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      errorStyle: TextStyle(
                        color: FintechColors.categoryRed,
                        fontSize: 12,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Amount is required';
                      }
                      final parsed = double.tryParse(value.replaceAll(',', ''));
                      if (parsed == null) {
                        return 'Invalid amount';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCurrencyPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Currency',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: FintechColors.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 44,
                scrollController: FixedExtentScrollController(
                  initialItem: _currencies.indexOf(_selectedCurrency),
                ),
                onSelectedItemChanged: (index) {
                  setState(() => _selectedCurrency = _currencies[index]);
                },
                children: _currencies.map((c) => Center(
                  child: Text(c, style: const TextStyle(fontSize: 18)),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, {bool small = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: small ? 14 : 16,
          color: FintechColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: small ? 13 : 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 15,
            color: AppColors.textMuted,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(icon, size: 20, color: AppColors.textMuted),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide(color: FintechColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide(color: AppColors.statusRejected, width: 1),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildExpenseTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: _expenseTypes.map((type) {
          final isSelected = _selectedExpenseType == type['value'];
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedExpenseType = type['value']),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? FintechColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  children: [
                    Icon(
                      type['icon'] as IconData,
                      size: 22,
                      color: isSelected ? Colors.white : AppColors.textMuted,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      (type['label'] as String).split(' ').first,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        final categories = apiProvider.categories;

        if (categories.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CupertinoActivityIndicator(),
                ),
                const SizedBox(width: 12),
                Text('Loading categories...', style: TextStyle(color: AppColors.textMuted)),
              ],
            ),
          );
        }

        return GestureDetector(
          onTap: () => _showCategoryPicker(categories),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              children: [
                // Category icon
                Builder(
                  builder: (context) {
                    final selectedCat = categories.firstWhere(
                      (c) => c.id == _selectedCategoryId,
                      orElse: () => categories.first,
                    );
                    return CategoryIconCircle(
                      icon: selectedCat.icon ?? getCategoryIcon(selectedCat.name),
                      categoryCode: selectedCat.name.toLowerCase(),
                      size: 40,
                    );
                  },
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        categories.firstWhere(
                          (c) => c.id == _selectedCategoryId,
                          orElse: () => categories.first,
                        ).name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCategoryPicker(List<CategoryDTO> categories) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Category',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.bgSubtle,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(CupertinoIcons.xmark, size: 16, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = cat.id == _selectedCategoryId;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategoryId = cat.id);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected ? FintechColors.primary.withValues(alpha: 0.1) : AppColors.bgSubtle,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: isSelected ? Border.all(color: FintechColors.primary, width: 2) : null,
                      ),
                      child: Row(
                        children: [
                          CategoryIconCircle(
                            icon: cat.icon ?? getCategoryIcon(cat.name),
                            categoryCode: cat.name.toLowerCase(),
                            size: 44,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              CupertinoIcons.checkmark_circle_fill,
                              color: FintechColors.primary,
                              size: 22,
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

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: FintechColors.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: AppColors.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: FintechColors.categoryPurpleBg,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                CupertinoIcons.calendar,
                color: FintechColors.categoryPurple,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expense Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(_selectedDate),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildDepartmentDropdown() {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        final departments = apiProvider.departments;
        final selectedDept = departments.where((d) => d.id == _selectedDepartmentId).firstOrNull;

        return GestureDetector(
          onTap: () => _showSelectionSheet(
            title: 'Select Department',
            items: departments.map((d) => {'id': d.id, 'name': d.name}).toList(),
            selectedId: _selectedDepartmentId,
            onSelect: (id) => setState(() => _selectedDepartmentId = id),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDept?.name ?? 'Select',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: selectedDept != null ? AppColors.textPrimary : AppColors.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(CupertinoIcons.chevron_down, size: 14, color: AppColors.textMuted),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCostCenterDropdown() {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        final costCenters = apiProvider.costCenters;
        final selectedCC = costCenters.where((c) => c.id == _selectedCostCenterId).firstOrNull;

        return GestureDetector(
          onTap: () => _showSelectionSheet(
            title: 'Select Cost Center',
            items: costCenters.map((c) => {'id': c.id, 'name': c.name}).toList(),
            selectedId: _selectedCostCenterId,
            onSelect: (id) => setState(() => _selectedCostCenterId = id),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedCC?.name ?? 'Select',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: selectedCC != null ? AppColors.textPrimary : AppColors.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(CupertinoIcons.chevron_down, size: 14, color: AppColors.textMuted),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSelectionSheet({
    required String title,
    required List<Map<String, String>> items,
    String? selectedId,
    required Function(String?) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  // None option
                  _buildSelectionItem(
                    name: 'None',
                    isSelected: selectedId == null,
                    onTap: () {
                      onSelect(null);
                      Navigator.pop(ctx);
                    },
                  ),
                  ...items.map((item) => _buildSelectionItem(
                    name: item['name']!,
                    isSelected: item['id'] == selectedId,
                    onTap: () {
                      onSelect(item['id']);
                      Navigator.pop(ctx);
                    },
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionItem({
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? FintechColors.primary.withValues(alpha: 0.1) : AppColors.bgSubtle,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: isSelected ? Border.all(color: FintechColors.primary) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(CupertinoIcons.checkmark_circle_fill, color: FintechColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Consumer<ApiExpenseProvider>(
      builder: (context, apiProvider, _) {
        final isLoading = apiProvider.isLoading;

        if (_isEditing) {
          return Column(
            children: [
              _buildPrimaryButton(
                label: 'Save Changes',
                icon: CupertinoIcons.checkmark_alt,
                isLoading: isLoading,
                onTap: isLoading ? null : _submitForm,
              ),
              const SizedBox(height: 12),
              _buildSecondaryButton(
                label: 'Cancel',
                icon: CupertinoIcons.xmark,
                onTap: () {
                  context.read<ApiExpenseProvider>().setSelectedExpense(null);
                  context.read<AppProvider>().goBack();
                },
              ),
            ],
          );
        }

        return Column(
          children: [
            // Primary: Submit for Approval
            _buildPrimaryButton(
              label: isLoading && _submitForApproval ? 'Submitting...' : 'Submit for Approval',
              icon: CupertinoIcons.paperplane_fill,
              isLoading: isLoading && _submitForApproval,
              onTap: isLoading ? null : () => _submitFormWithAction(true),
            ),
            const SizedBox(height: 12),
            // Secondary: Save as Draft
            _buildSecondaryButton(
              label: isLoading && !_submitForApproval ? 'Saving...' : 'Save as Draft',
              icon: CupertinoIcons.doc_fill,
              onTap: isLoading ? null : () => _submitFormWithAction(false),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    bool isLoading = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: onTap != null
              ? LinearGradient(
                  colors: [FintechColors.primary, FintechColors.primaryLight],
                )
              : null,
          color: onTap == null ? AppColors.textMuted : null,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: FintechColors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _submitExpense();
    }
  }

  void _submitFormWithAction(bool submitForApproval) {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _submitForApproval = submitForApproval;
      });
      _submitExpense();
    }
  }

  Future<void> _submitExpense() async {
    final apiProvider = context.read<ApiExpenseProvider>();
    final appProvider = context.read<AppProvider>();

    final amount = double.parse(_amountController.text);
    final categoryId = _selectedCategoryId ?? apiProvider.categories.first.id;
    final description = _notesController.text.isNotEmpty ? _notesController.text : null;
    final merchantName = _merchantController.text.isNotEmpty ? _merchantController.text : null;

    ExpenseDTO? result;

    if (_isEditing && _editingApiId != null) {
      result = await apiProvider.updateExpense(
        _editingApiId!,
        categoryId: categoryId,
        expenseDate: _selectedDate,
        description: description,
        departmentId: _selectedDepartmentId,
        costCenterId: _selectedCostCenterId,
        merchantName: merchantName,
      );

      if (result != null) {
        apiProvider.setSelectedExpense(result);
        appProvider.goBack();
        appProvider.showNotification('Expense updated', type: 'success');
      } else {
        appProvider.showNotification(
          apiProvider.error ?? 'Failed to update expense',
          type: 'error',
        );
      }
    } else {
      result = await apiProvider.createExpense(
        amount: amount,
        categoryId: categoryId,
        expenseDate: _selectedDate,
        description: description,
        expenseType: _selectedExpenseType,
        originalCurrency: _selectedCurrency,
        departmentId: _selectedDepartmentId,
        costCenterId: _selectedCostCenterId,
        merchantName: merchantName,
        submitForApproval: _submitForApproval,
      );

      if (result != null) {
        final pendingAttachments = apiProvider.pendingAttachments;
        if (pendingAttachments.isNotEmpty) {
          for (final file in pendingAttachments) {
            final bytes = await file.readAsBytes();
            final fileName = file.path.split('/').last.split('\\').last;
            await apiProvider.uploadReceipt(result.id, bytes, fileName);
          }
          apiProvider.clearPendingAttachments();
        }

        apiProvider.setSelectedExpense(result);

        appProvider.showNotification(
          _submitForApproval
              ? 'Expense created and submitted for approval!'
              : 'Expense saved as draft!',
          type: 'success',
        );

        appProvider.navigateTo('expenseCreated');
      } else {
        appProvider.showNotification(
          apiProvider.error ?? 'Failed to create expense',
          type: 'error',
        );
      }
    }
  }
}
