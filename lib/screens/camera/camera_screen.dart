import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/design_tokens.dart';
import '../../providers/app_provider.dart';
import '../../providers/api_expense_provider.dart';
import '../../widgets/common/app_button.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  String? _processingMessage;

  @override
  Widget build(BuildContext context) {
    final params = context.read<AppProvider>().screenParams;
    final mode = params?['mode'] ?? 'scan';
    final isAttachMode = mode == 'attach';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, isAttachMode),

            // Camera Preview (Mock)
            Expanded(
              child: _buildCameraPreview(),
            ),

            // Controls
            _buildControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isAttachMode) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.read<AppProvider>().goBack(),
            child: const Icon(Icons.close, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.lg),
          Text(
            isAttachMode ? 'Attach Receipt' : 'Scan Receipt',
            style: AppTypography.headingSmall.copyWith(color: Colors.white),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              // Toggle flash (mock)
            },
            child: const Icon(Icons.flash_off, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Stack(
      children: [
        // Mock camera preview
        Container(
          color: Colors.black87,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 64,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Camera Preview',
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Position the receipt within the frame',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Scan frame overlay
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 1.2,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primary.withOpacity(0.8),
                width: 2,
              ),
              borderRadius: AppRadius.borderRadiusLg,
            ),
            child: Stack(
              children: [
                // Corner accents
                Positioned(
                  top: -2,
                  left: -2,
                  child: _cornerAccent(),
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Transform.rotate(
                    angle: 1.5708,
                    child: _cornerAccent(),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  left: -2,
                  child: Transform.rotate(
                    angle: -1.5708,
                    child: _cornerAccent(),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Transform.rotate(
                    angle: 3.1416,
                    child: _cornerAccent(),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Processing overlay
        if (_isProcessing)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    _processingMessage ?? 'Processing receipt...',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _cornerAccent() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.primary, width: 4),
          left: BorderSide(color: AppColors.primary, width: 4),
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          // Capture button
          GestureDetector(
            onTap: _captureImage,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Gallery option
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickFromGallery,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: AppRadius.borderRadiusFull,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.photo_library_outlined,
                          color: Colors.white, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Choose from Gallery',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _captureImage() async {
    final appProvider = context.read<AppProvider>();
    final params = appProvider.screenParams;
    final mode = params?['mode'] ?? 'scan';
    final expenseId = params?['expenseId'] as String?;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      await _processImage(image, mode, expenseId);
    } catch (e) {
      if (mounted) {
        appProvider.showNotification(
          'Failed to capture image: $e',
          type: 'error',
        );
      }
    }
  }

  void _pickFromGallery() async {
    final appProvider = context.read<AppProvider>();
    final params = appProvider.screenParams;
    final mode = params?['mode'] ?? 'scan';
    final expenseId = params?['expenseId'] as String?;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      await _processImage(image, mode, expenseId);
    } catch (e) {
      if (mounted) {
        appProvider.showNotification(
          'Failed to pick image: $e',
          type: 'error',
        );
      }
    }
  }

  Future<void> _processImage(XFile imageFile, String mode, String? expenseId) async {
    if (!mounted) return;

    final appProvider = context.read<AppProvider>();

    if (appProvider.isApiMode) {
      // API mode
      if (mode == 'attach' && expenseId != null) {
        // Upload receipt to existing expense
        await _uploadReceiptToExpense(imageFile, expenseId);
      } else {
        // Store image for new expense creation
        final apiProvider = context.read<ApiExpenseProvider>();
        // For non-web, we can still use File for pending attachments
        if (!kIsWeb) {
          apiProvider.addPendingAttachment(File(imageFile.path));
        }

        setState(() {
          _isProcessing = true;
          _processingMessage = 'Image captured successfully';
        });

        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          setState(() => _isProcessing = false);
          appProvider.showNotification(
            'Receipt captured. Creating expense...',
            type: 'success',
          );
          appProvider.navigateTo('newExpense');
        }
      }
    } else {
      // Demo mode - simulate processing
      setState(() {
        _isProcessing = true;
        _processingMessage = 'Processing receipt...';
      });

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() => _isProcessing = false);
        appProvider.navigateTo('newExpense');
      }
    }
  }

  Future<void> _uploadReceiptToExpense(XFile imageFile, String expenseId) async {
    if (!mounted) return;

    final appProvider = context.read<AppProvider>();
    final apiProvider = context.read<ApiExpenseProvider>();

    setState(() {
      _isProcessing = true;
      _processingMessage = 'Uploading receipt...';
    });

    try {
      // Read bytes from XFile (works on both web and mobile)
      final bytes = await imageFile.readAsBytes();
      final fileName = imageFile.name;

      final success = await apiProvider.uploadReceipt(expenseId, bytes, fileName);

      if (!mounted) return;

      setState(() => _isProcessing = false);

      if (success) {
        appProvider.showNotification(
          'Receipt uploaded successfully',
          type: 'success',
        );
        appProvider.goBack();
      } else {
        appProvider.showNotification(
          apiProvider.error ?? 'Failed to upload receipt',
          type: 'error',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      appProvider.showNotification(
        'Failed to upload receipt: $e',
        type: 'error',
      );
    }
  }
}
