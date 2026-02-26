import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'dio_client.dart';
import 'api_result.dart';
import '../models/expense_dto.dart';

/// Service for receipt-related API operations
class ReceiptService {
  final Dio _dio = DioClient().dio;

  /// Upload receipt for an expense
  ///
  /// Uploads a receipt image file to the expense.
  /// The file will be processed via OCR.
  ///
  /// [expenseId] - The expense UUID
  /// [file] - The file to upload (File or Uint8List for web)
  /// [fileName] - Optional custom file name
  Future<ApiResult<ReceiptDTO>> uploadReceipt({
    required String expenseId,
    required dynamic file, // File on mobile, Uint8List on web
    String? fileName,
  }) async {
    try {
      MultipartFile multipartFile;
      String finalFileName = fileName ?? 'receipt.jpg';

      // Handle different file types (mobile File vs web Uint8List)
      if (file is File) {
        // Mobile: Use File
        multipartFile = await MultipartFile.fromFile(
          file.path,
          filename: finalFileName,
          contentType: MediaType('image', 'jpeg'),
        );
      } else if (file is Uint8List) {
        // Web: Use Uint8List
        multipartFile = MultipartFile.fromBytes(
          file,
          filename: finalFileName,
          contentType: MediaType('image', 'jpeg'),
        );
      } else {
        return ApiResult.failure(ApiError(message: 'Unsupported file type'));
      }

      final formData = FormData.fromMap({
        'file': multipartFile,
      });

      print('DEBUG: Uploading receipt for expense $expenseId, fileName=$finalFileName');

      final response = await _dio.post(
        '/api/v1/expenses/$expenseId/receipts',
        data: formData,
        queryParameters: fileName != null ? {'file_name': fileName} : null,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('DEBUG: Receipt uploaded successfully: ${response.data}');
      return ApiResult.success(ReceiptDTO.fromJson(response.data));
    } on DioException catch (e) {
      print('ERROR: Failed to upload receipt: ${e.message}');
      return ApiResult.fromDioError(e);
    }
  }

  /// Download receipt file
  ///
  /// Downloads the receipt file as bytes.
  /// Returns the file content and filename.
  Future<ApiResult<ReceiptDownload>> downloadReceipt(String receiptId) async {
    try {
      print('DEBUG: Downloading receipt $receiptId');

      final response = await _dio.get(
        '/api/v1/receipts/$receiptId/download',
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      // Get filename from Content-Disposition header
      String? fileName = 'receipt.jpg';
      final contentDisposition = response.headers.value('content-disposition');
      if (contentDisposition != null) {
        final match = RegExp(r'filename="?([^"]+)"?').firstMatch(contentDisposition);
        if (match != null) {
          fileName = match.group(1);
        }
      }

      final download = ReceiptDownload(
        data: response.data as Uint8List,
        fileName: fileName ?? 'receipt.jpg',
        contentType: response.headers.value('content-type') ?? 'image/jpeg',
      );

      print('DEBUG: Receipt downloaded: fileName=$fileName, size=${download.data.length}');
      return ApiResult.success(download);
    } on DioException catch (e) {
      print('ERROR: Failed to download receipt: ${e.message}');
      return ApiResult.fromDioError(e);
    }
  }

  /// List receipts for an expense
  Future<ApiResult<List<ReceiptDTO>>> listReceipts(String expenseId) async {
    try {
      final response = await _dio.get('/api/v1/expenses/$expenseId/receipts');

      // API returns { "receipts": [ { "Body": {...} ] }
      // We need to extract the receipts array, not the response.data directly
      final responseData = response.data as Map<String, dynamic>?;
      final receiptsArray = responseData?['receipts'] as List<dynamic>?;

      print('DEBUG: listReceipts - response.data type: ${response.data.runtimeType}');
      print('DEBUG: listReceipts - receiptsArray length: ${receiptsArray?.length ?? 0}');

      final receipts = receiptsArray
              ?.map((e) => ReceiptDTO.fromJson(e))
              .toList() ??
          [];

      return ApiResult.success(receipts);
    } on DioException catch (e) {
      print('ERROR: listReceipts DioException: ${e.message}');
      return ApiResult.fromDioError(e);
    }
  }

  /// Delete receipt
  Future<ApiResult<void>> deleteReceipt(String receiptId) async {
    try {
      print('DEBUG: Deleting receipt $receiptId');
      await _dio.delete('/api/v1/receipts/$receiptId');
      return ApiResult.success(null);
    } on DioException catch (e) {
      print('ERROR: Failed to delete receipt: ${e.message}');
      return ApiResult.fromDioError(e);
    }
  }

  /// Verify receipt (for approvers/finance)
  Future<ApiResult<ReceiptDTO>> verifyReceipt(String receiptId) async {
    try {
      final response = await _dio.post('/api/v1/receipts/$receiptId/verify');
      return ApiResult.success(ReceiptDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResult.fromDioError(e);
    }
  }

  /// Process OCR for a receipt
  ///
  /// Triggers OCR processing with Gemini Vision API to extract data from receipt.
  /// Returns receipt with OCR data populated.
  ///
  /// [receiptId] - The receipt UUID
  Future<ApiResult<ReceiptDTO>> processOCR(String receiptId) async {
    try {
      print('DEBUG: Processing OCR for receipt $receiptId');

      final response = await _dio.post('/api/v1/receipts/$receiptId/ocr');

      print('DEBUG: OCR processed successfully: ${response.data}');
      return ApiResult.success(ReceiptDTO.fromJson(response.data));
    } on DioException catch (e) {
      print('ERROR: Failed to process OCR: ${e.message}');
      return ApiResult.fromDioError(e);
    }
  }

  /// Get receipt by ID
  ///
  /// Fetches a specific receipt with its OCR data.
  ///
  /// [receiptId] - The receipt UUID
  Future<ApiResult<ReceiptDTO>> getReceipt(String receiptId) async {
    try {
      print('DEBUG: Fetching receipt $receiptId');

      final response = await _dio.get('/api/v1/receipts/$receiptId');

      print('DEBUG: Receipt fetched: ${response.data}');
      return ApiResult.success(ReceiptDTO.fromJson(response.data));
    } on DioException catch (e) {
      print('ERROR: Failed to fetch receipt: ${e.message}');
      return ApiResult.fromDioError(e);
    }
  }
}

/// Receipt download result
class ReceiptDownload {
  final Uint8List data;
  final String fileName;
  final String contentType;

  ReceiptDownload({
    required this.data,
    required this.fileName,
    required this.contentType,
  });
}
