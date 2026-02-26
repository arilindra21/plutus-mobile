import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/design_tokens.dart';
import '../../providers/app_provider.dart';
import '../../providers/api_expense_provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  String? _processingMessage;

  // Preview state
  XFile? _capturedImage;
  Uint8List? _capturedImageBytes;

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

            // Camera Preview or Captured Image Preview
            Expanded(
              child: _capturedImage != null
                  ? _buildImagePreview()
                  : _buildCameraPreview(),
            ),

            // Controls (different based on state)
            _capturedImage != null
                ? _buildPreviewControls(context)
                : _buildCaptureControls(context),
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
            onTap: () {
              // Clear state and go back
              _clearCapturedImage();
              context.read<AppProvider>().goBack();
            },
            child: const Icon(Icons.close, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.lg),
          Text(
            _capturedImage != null
                ? 'Review Receipt'
                : (isAttachMode ? 'Attach Receipt' : 'Scan Receipt'),
            style: AppTypography.headingSmall.copyWith(color: Colors.white),
          ),
          const Spacer(),
          if (_capturedImage == null)
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

  Widget _buildImagePreview() {
    return Stack(
      children: [
        // Image preview
        Container(
          color: Colors.black,
          child: Center(
            child: _capturedImageBytes != null
                ? Image.memory(
                    _capturedImageBytes!,
                    fit: BoxFit.contain,
                  )
                : const CircularProgressIndicator(color: AppColors.primary),
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
                    _processingMessage ?? 'Processing...',
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

  Widget _buildCaptureControls(BuildContext context) {
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
                decoration: const BoxDecoration(
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

  Widget _buildPreviewControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          // Use This Receipt button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _useThisReceipt,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Use This Receipt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Retake button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isProcessing ? null : _retakePhoto,
              icon: const Icon(Icons.refresh),
              label: const Text('Retake Photo'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearCapturedImage() {
    setState(() {
      _capturedImage = null;
      _capturedImageBytes = null;
    });
  }

  void _retakePhoto() {
    _clearCapturedImage();
  }

  Future<void> _useThisReceipt() async {
    if (_capturedImage == null) return;

    final appProvider = context.read<AppProvider>();
    final apiProvider = context.read<ApiExpenseProvider>();
    final params = appProvider.screenParams;
    final mode = params?['mode'] ?? 'scan';
    final expenseId = params?['expenseId'] as String?;

    if (mode == 'attach' && expenseId != null) {
      // Upload to existing expense
      await _uploadReceiptToExpense(_capturedImage!, expenseId);
    } else {
      // Set as pending receipt for new expense with OCR
      setState(() {
        _isProcessing = true;
        _processingMessage = 'Preparing receipt...';
      });

      // Save to provider for OCR processing
      if (kIsWeb) {
        await apiProvider.setPendingReceiptImage(_capturedImage!);
      } else {
        await apiProvider.setPendingReceiptImage(File(_capturedImage!.path));
      }

      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() => _isProcessing = false);
        appProvider.showNotification(
          'Receipt ready for processing',
          type: 'success',
        );
        // Navigate to new expense screen with OCR mode
        appProvider.navigateToWithParams('newExpense', {'fromScan': true});
      }
    }
  }

  void _captureImage() async {
    final appProvider = context.read<AppProvider>();

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      // Read bytes for preview
      final bytes = await image.readAsBytes();

      if (mounted) {
        setState(() {
          _capturedImage = image;
          _capturedImageBytes = bytes;
        });
      }
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

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      // Read bytes for preview
      final bytes = await image.readAsBytes();

      if (mounted) {
        setState(() {
          _capturedImage = image;
          _capturedImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        appProvider.showNotification(
          'Failed to pick image: $e',
          type: 'error',
        );
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

      final uploadResult = await apiProvider.uploadReceipt(
        expenseId: expenseId,
        file: bytes,
        fileName: fileName,
      );

      if (!mounted) return;

      // Also trigger OCR after upload
      if (uploadResult != null) {
        setState(() {
          _processingMessage = 'Processing receipt...';
        });

        await apiProvider.processReceiptOCR(uploadResult.id);
      }

      setState(() => _isProcessing = false);

      if (uploadResult != null) {
        appProvider.showNotification(
          'Receipt uploaded and processed',
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
