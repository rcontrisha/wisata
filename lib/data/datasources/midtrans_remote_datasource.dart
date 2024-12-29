import 'dart:convert';
import 'package:flutter_wisata_app/core/constants/variables.dart';
import 'package:flutter_wisata_app/data/models/response/qris_status_response_model.dart';
import 'package:flutter_wisata_app/data/models/response/transaction_status_model.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_wisata_app/data/models/response/qris_response_model.dart';
import 'package:intl/intl.dart';

String serverKey = 'SB-Mid-server-yaZafhRZsMqCMZyRIlOSIYim';

class MidtransRemoteDatasource {
  String generateBasicAuthHeader(String serverKey) {
    final base64Credentials = base64Encode(utf8.encode('$serverKey:'));
    final authHeader = 'Basic $base64Credentials';

    return authHeader;
  }

  Future<QrisResponseModel> generateQRCode(
      String orderId, int grossAmount) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': generateBasicAuthHeader(serverKey),
    };
    final body = jsonEncode({
      "payment_type": "gopay",
      "transaction_details": {
        "order_id": orderId,
        "gross_amount": grossAmount,
      }
    });

    final response = await http.post(
      Uri.parse('${Variables.qrisBaseUrl}/v2/charge'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      print(response.body);
      return QrisResponseModel.fromJson(response.body);
    } else {
      throw Exception('Failed to generate QR Code.');
    }
  }

  Future<QrisStatusResponseModel> checkPaymentStatus(
      String transactionId) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': generateBasicAuthHeader(serverKey),
    };

    final response = await http.get(
      Uri.parse('${Variables.qrisBaseUrl}/v2/$transactionId/status'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return QrisStatusResponseModel.fromJson(response.body);
    } else {
      throw Exception('Failed to check payment status.');
    }
  }

  Future<Map<String, dynamic>> createTransaction(
      String orderId, int grossAmount) async {
    print(getFormattedDate());
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': generateBasicAuthHeader(serverKey),
    };

    // Buat body request dengan start_time sebagai current time
    final body = jsonEncode({
      "transaction_details": {
        "order_id": orderId, // Order ID dinamis
        "gross_amount": grossAmount,
      },
      "expiry": {
        "start_time": getFormattedDate(), // Gunakan current time
        "duration": 15,
        "unit": "minutes"
      }
    });

    final response = await http.post(
      Uri.parse('https://app.sandbox.midtrans.com/snap/v1/transactions'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201) {
      // 201 Created
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to create transaction. Status Code: ${response.statusCode}');
    }
  }

  Future<TransactionDetailModel> checkTransferStatus(
      String transactionId) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': generateBasicAuthHeader(serverKey),
    };

    final uri = Uri.parse('${Variables.qrisBaseUrl}/v2/$transactionId/status');
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      // Mengurai response.body sebagai JSON
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      // Log respons mentah
      print('Raw JSON from Midtrans: $jsonResponse');
      return TransactionDetailModel.fromJson(jsonResponse);
    } else {
      // Memberikan detail pesan kesalahan
      final errorResponse = jsonDecode(response.body);
      final errorMessage = errorResponse['status_message'] ?? 'Unknown error';
      throw Exception('Failed to check payment status: $errorMessage');
    }
  }

  String getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    // Menambahkan offset zona waktu
    final timezoneOffset = now.timeZoneOffset.inHours >= 0
        ? '+${now.timeZoneOffset.inHours.toString().padLeft(2, '0')}00'
        : '${now.timeZoneOffset.inHours.toString().padLeft(3, '0')}00';

    return '${formatter.format(now)} $timezoneOffset';
  }
}
