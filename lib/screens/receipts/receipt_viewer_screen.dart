import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';
import '../../core/design_tokens.dart';
import '../../providers/app_provider.dart';
import '../../providers/api_expense_provider.dart';
import '../../widgets/buttons/buttons.dart' as app_widgets;

/// Receipt viewer screen
///
/// Allows users to view uploaded receipts at full size with zoom support.
class ReceiptViewerScreen extends StatefulWidget {
  const ReceiptViewerScreen({super.key});

  @override
  State<ReceiptViewerScreen> createState() => _ReceiptViewerScreenState();
}

class _ReceiptViewerScreenState extends State<ReceiptViewerScreen> {
  final TransformationController _transformationController = TransformationController();
  double _currentScale = 1.0;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPaper,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            final appProvider = Provider.of<AppProvider>(context, listen: false);
            appProvider.clearNavigationParams();
            appProvider.goBack(fallback: 'home');
          },
        ),
        title: const Text(
          'Receipt Viewer',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareReceipt,
          ),
        ],
      ),
      body: FutureBuilder<ReceiptViewerData>(
        future: _loadReceiptData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.description_outlined,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Receipt not found',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  app_widgets.AppButton(
                    label: 'Go Back',
                    onPressed: () {
                      final appProvider = Provider.of<AppProvider>(context, listen: false);
                      appProvider.clearNavigationParams();
                      appProvider.goBack(fallback: 'home');
                    },
                    style: app_widgets.ButtonStyle.ghost,
                  ),
                ],
              ),
            );
          }

          final receipt = snapshot.data!;
          return Column(
            children: [
              // Receipt info header
              if (receipt.fileName != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16).copyWith(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppShadows.card,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              receipt.fileName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (receipt.uploadedAt != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Uploaded on ${_formatDate(receipt.uploadedAt)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Receipt image viewer with zoom and pan
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Stack(
                    children: [
                      // Image viewer
                      Center(
                        child: PhotoView(
                          imageProvider: MemoryImage(receipt.imageData),
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.covered * 3.0,
                          initialScale: PhotoViewComputedScale.contained,
                          backgroundDecoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                          loadingBuilder: (context, event) => const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: AppColors.statusRejected,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Failed to load image',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // Zoom controls
                      Positioned(
                        bottom: 24,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildZoomButton(
                                  icon: Icons.remove,
                                  onTap: () => _zoomOut(),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '${(_currentScale * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                _buildZoomButton(
                                  icon: Icons.add,
                                  onTap: () => _zoomIn(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }

  void _zoomIn() {
    setState(() {
      _currentScale = (_currentScale + 0.25).clamp(1.0, 3.0);
      _transformationController.value = Matrix4.identity()
        ..scale(_currentScale, _currentScale, _currentScale);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentScale = (_currentScale - 0.25).clamp(1.0, 3.0);
      _transformationController.value = Matrix4.identity()
        ..scale(_currentScale, _currentScale, _currentScale);
    });
  }

  void _shareReceipt() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon'),
      ),
    );
  }

  Future<ReceiptViewerData> _loadReceiptData() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final params = appProvider.screenParams;

    if (params == null || !params.containsKey('receiptId')) {
      throw Exception('Receipt ID is required');
    }

    final receiptId = params['receiptId'] as String?;

    if (receiptId == null || receiptId.isEmpty) {
      throw Exception('Receipt ID is required');
    }

    final expenseProvider = Provider.of<ApiExpenseProvider>(context, listen: false);

    // Get receipt metadata
    final receipt = await expenseProvider.getReceipt(receiptId);
    if (receipt == null) {
      throw Exception('Receipt not found');
    }

    // Download receipt image bytes
    final download = await expenseProvider.downloadReceipt(receiptId);
    if (download == null) {
      throw Exception('Failed to download receipt image');
    }

    return ReceiptViewerData(
      imageData: download.data,
      fileName: receipt.fileName ?? download.fileName,
      uploadedAt: receipt.createdAt,
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date.toLocal());
  }
}

/// Receipt viewer data containing image bytes and metadata
class ReceiptViewerData {
  final Uint8List imageData;
  final String fileName;
  final DateTime? uploadedAt;

  ReceiptViewerData({
    required this.imageData,
    required this.fileName,
    this.uploadedAt,
  });
}
