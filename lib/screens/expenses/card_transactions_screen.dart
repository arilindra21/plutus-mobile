import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/api_transaction_provider.dart';
import '../../services/services.dart';
import '../../utils/formatters.dart';
import '../../widgets/layout/bottom_navigation.dart';

/// Screen to display card transactions with pending receipt indicators
/// V1 Feature: Check all transaction and pending receipt upload
class CardTransactionsScreen extends StatefulWidget {
  const CardTransactionsScreen({super.key});

  @override
  State<CardTransactionsScreen> createState() => _CardTransactionsScreenState();
}

class _CardTransactionsScreenState extends State<CardTransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final transactionProvider = context.read<ApiTransactionProvider>();
      if (!transactionProvider.isLoadingMore && transactionProvider.hasMore) {
        transactionProvider.loadMore();
      }
    }
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;

    final appProvider = context.read<AppProvider>();
    if (appProvider.isApiMode) {
      final transactionProvider = context.read<ApiTransactionProvider>();
      await transactionProvider.loadTransactions(refresh: true);
      await transactionProvider.loadPendingReceiptTransactions();
    }
    _isInitialized = true;
  }

  Future<void> _refreshData() async {
    final transactionProvider = context.read<ApiTransactionProvider>();
    await transactionProvider.loadTransactions(refresh: true);
    await transactionProvider.loadPendingReceiptTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(child: _buildTabBarView()),
            const AppBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<ApiTransactionProvider>(
      builder: (context, provider, _) {
        final pendingCount = provider.pendingReceiptCount;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.read<AppProvider>().goBack(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.back,
                    size: 20,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Card Transactions',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    if (pendingCount > 0)
                      Text(
                        '$pendingCount pending receipts',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFFF9500),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              // Refresh button
              GestureDetector(
                onTap: _refreshData,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.refresh,
                    size: 20,
                    color: Color(0xFF007AFF),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5EA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(3),
        dividerColor: Colors.transparent,
        labelColor: const Color(0xFF1C1C1E),
        unselectedLabelColor: const Color(0xFF8E8E93),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(
            child: Consumer<ApiTransactionProvider>(
              builder: (context, provider, _) {
                final count = provider.pendingReceiptTransactions.length;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Pending'),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9500),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          const Tab(text: 'All'),
          const Tab(text: 'Completed'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildPendingReceiptTab(),
        _buildAllTransactionsTab(),
        _buildCompletedTab(),
      ],
    );
  }

  Widget _buildPendingReceiptTab() {
    return Consumer<ApiTransactionProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.pendingReceiptTransactions.isEmpty) {
          return const Center(
            child: CupertinoActivityIndicator(radius: 14),
          );
        }

        final transactions = provider.pendingReceiptTransactions;

        if (transactions.isEmpty) {
          return _buildEmptyState(
            icon: CupertinoIcons.checkmark_circle,
            title: 'All receipts uploaded!',
            subtitle: 'No pending receipts to upload',
            iconColor: const Color(0xFF30D158),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              return _TransactionCard(
                transaction: transactions[index],
                showPendingIndicator: true,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAllTransactionsTab() {
    return Consumer<ApiTransactionProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.transactions.isEmpty) {
          return const Center(
            child: CupertinoActivityIndicator(radius: 14),
          );
        }

        final transactions = provider.transactions;

        if (transactions.isEmpty) {
          return _buildEmptyState(
            icon: CupertinoIcons.creditcard,
            title: 'No transactions yet',
            subtitle: 'Your card transactions will appear here',
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: transactions.length + (provider.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == transactions.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CupertinoActivityIndicator(radius: 12),
                  ),
                );
              }
              return _TransactionCard(
                transaction: transactions[index],
                showPendingIndicator: transactions[index].needsReceipt,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCompletedTab() {
    return Consumer<ApiTransactionProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.transactions.isEmpty) {
          return const Center(
            child: CupertinoActivityIndicator(radius: 14),
          );
        }

        // Filter for transactions with receipts uploaded
        final completedTransactions = provider.transactions
            .where((t) => t.receiptStatus >= 2 || !t.receiptRequired)
            .toList();

        if (completedTransactions.isEmpty) {
          return _buildEmptyState(
            icon: CupertinoIcons.doc_checkmark,
            title: 'No completed transactions',
            subtitle: 'Transactions with receipts will appear here',
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: completedTransactions.length,
            itemBuilder: (context, index) {
              return _TransactionCard(
                transaction: completedTransactions[index],
                showPendingIndicator: false,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: (iconColor ?? const Color(0xFF007AFF)).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 36,
              color: iconColor ?? const Color(0xFF007AFF),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

/// Transaction Card Widget
class _TransactionCard extends StatelessWidget {
  final TransactionDTO transaction;
  final bool showPendingIndicator;

  const _TransactionCard({
    required this.transaction,
    this.showPendingIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = transaction.isReceiptOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: showPendingIndicator
            ? Border.all(
                color: isOverdue
                    ? const Color(0xFFFF3B30).withOpacity(0.3)
                    : const Color(0xFFFF9500).withOpacity(0.3),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to transaction detail or show upload receipt sheet
            if (showPendingIndicator) {
              _showUploadReceiptSheet(context);
            } else {
              _showTransactionDetail(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Card icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          CupertinoIcons.creditcard_fill,
                          size: 24,
                          color: Color(0xFF5856D6),
                        ),
                      ),
                      if (showPendingIndicator)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: isOverdue
                                  ? const Color(0xFFFF3B30)
                                  : const Color(0xFFFF9500),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                CupertinoIcons.exclamationmark,
                                size: 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.merchant,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            transaction.formattedDate,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                          if (transaction.cardDisplay.isNotEmpty) ...[
                            const Text(
                              ' • ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                            Text(
                              transaction.cardDisplay,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Amount & Status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatRupiahCompact(transaction.amount),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (showPendingIndicator)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isOverdue
                              ? const Color(0xFFFF3B30).withOpacity(0.12)
                              : const Color(0xFFFF9500).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.camera_fill,
                              size: 10,
                              color: isOverdue
                                  ? const Color(0xFFFF3B30)
                                  : const Color(0xFFFF9500),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isOverdue ? 'Overdue' : 'Upload',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isOverdue
                                    ? const Color(0xFFFF3B30)
                                    : const Color(0xFFFF9500),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF30D158).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.checkmark,
                              size: 10,
                              color: Color(0xFF30D158),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Complete',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF30D158),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUploadReceiptSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _UploadReceiptSheet(transaction: transaction),
    );
  }

  void _showTransactionDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _TransactionDetailSheet(transaction: transaction),
    );
  }
}

/// Upload Receipt Bottom Sheet
class _UploadReceiptSheet extends StatefulWidget {
  final TransactionDTO transaction;

  const _UploadReceiptSheet({required this.transaction});

  @override
  State<_UploadReceiptSheet> createState() => _UploadReceiptSheetState();
}

class _UploadReceiptSheetState extends State<_UploadReceiptSheet> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        await _uploadReceipt(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        await _uploadReceipt(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to take photo: $e')),
        );
      }
    }
  }

  Future<void> _uploadReceipt(File file) async {
    setState(() => _isUploading = true);

    try {
      final transactionProvider = context.read<ApiTransactionProvider>();
      final success = await transactionProvider.uploadReceipt(
        widget.transaction.id,
        file,
      );

      if (mounted) {
        Navigator.pop(context);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Receipt uploaded successfully'),
              backgroundColor: Color(0xFF30D158),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(transactionProvider.error ?? 'Failed to upload receipt'),
              backgroundColor: const Color(0xFFFF3B30),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9500).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        CupertinoIcons.camera_fill,
                        size: 24,
                        color: Color(0xFFFF9500),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Upload Receipt',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          Text(
                            transaction.merchant,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Transaction details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'Amount',
                        value: formatRupiahCompact(transaction.amount),
                        valueStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      const Divider(height: 16),
                      _DetailRow(
                        label: 'Date',
                        value: transaction.formattedDate,
                      ),
                      const Divider(height: 16),
                      _DetailRow(
                        label: 'Card',
                        value: transaction.cardDisplay.isNotEmpty
                            ? transaction.cardDisplay
                            : 'N/A',
                      ),
                      if (transaction.category.isNotEmpty) ...[
                        const Divider(height: 16),
                        _DetailRow(
                          label: 'Category',
                          value: transaction.category,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Loading indicator
                if (_isUploading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CupertinoActivityIndicator(radius: 14),
                          SizedBox(height: 12),
                          Text(
                            'Uploading receipt...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _takePhoto,
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFF007AFF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.camera_fill,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Take Photo',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickFromGallery,
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F2F7),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.photo,
                                  color: Color(0xFF1C1C1E),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Gallery',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1C1C1E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Transaction Detail Bottom Sheet
class _TransactionDetailSheet extends StatelessWidget {
  final TransactionDTO transaction;

  const _TransactionDetailSheet({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5856D6).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        CupertinoIcons.creditcard_fill,
                        size: 28,
                        color: Color(0xFF5856D6),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.merchant,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatRupiahCompact(transaction.amount),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF007AFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'Date',
                        value: transaction.formattedDate,
                      ),
                      const Divider(height: 16),
                      _DetailRow(
                        label: 'Card',
                        value: transaction.cardDisplay.isNotEmpty
                            ? transaction.cardDisplay
                            : 'N/A',
                      ),
                      const Divider(height: 16),
                      _DetailRow(
                        label: 'Category',
                        value: transaction.category,
                      ),
                      const Divider(height: 16),
                      _DetailRow(
                        label: 'Receipt Status',
                        value: transaction.receiptStatusLabel,
                        valueColor: transaction.receiptStatus >= 2
                            ? const Color(0xFF30D158)
                            : const Color(0xFF8E8E93),
                      ),
                      if (transaction.referenceNumber != null) ...[
                        const Divider(height: 16),
                        _DetailRow(
                          label: 'Reference',
                          value: transaction.referenceNumber!,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Close button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueStyle,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF8E8E93),
          ),
        ),
        Text(
          value,
          style: valueStyle ??
              TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor ?? const Color(0xFF1C1C1E),
              ),
        ),
      ],
    );
  }
}
