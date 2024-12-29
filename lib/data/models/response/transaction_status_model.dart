class TransactionDetailModel {
  String? statusCode;
  String? transactionId;
  String? grossAmount;
  String? currency;
  String? orderId;
  String? paymentType;
  String? signatureKey;
  String? transactionStatus;
  String? fraudStatus;
  String? statusMessage;
  String? merchantId;
  List<VaNumbers>? vaNumbers;
  List<PaymentAmounts>? paymentAmounts;
  String? transactionTime;
  String? expiryTime;

  TransactionDetailModel({
    this.statusCode,
    this.transactionId,
    this.grossAmount,
    this.currency,
    this.orderId,
    this.paymentType,
    this.signatureKey,
    this.transactionStatus,
    this.fraudStatus,
    this.statusMessage,
    this.merchantId,
    this.vaNumbers,
    this.paymentAmounts,
    this.transactionTime,
    this.expiryTime,
  });

  TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'] as String?;
    transactionId = json['transaction_id'] as String?;
    grossAmount = json['gross_amount'] as String?;
    currency = json['currency'] as String?;
    orderId = json['order_id'] as String?;
    paymentType = json['payment_type'] as String?;
    signatureKey = json['signature_key'] as String?;
    transactionStatus = json['transaction_status'] as String?;
    fraudStatus = json['fraud_status'] as String?;
    statusMessage = json['status_message'] as String?;
    merchantId = json['merchant_id'] as String?;
    vaNumbers = (json['va_numbers'] as List?)?.map((dynamic e) => VaNumbers.fromJson(e as Map<String,dynamic>)).toList();
    paymentAmounts = (json['payment_amounts'] as List?)?.map((dynamic e) => PaymentAmounts.fromJson(e as Map<String,dynamic>)).toList();
    transactionTime = json['transaction_time'] as String?;
    expiryTime = json['expiry_time'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['status_code'] = statusCode;
    json['transaction_id'] = transactionId;
    json['gross_amount'] = grossAmount;
    json['currency'] = currency;
    json['order_id'] = orderId;
    json['payment_type'] = paymentType;
    json['signature_key'] = signatureKey;
    json['transaction_status'] = transactionStatus;
    json['fraud_status'] = fraudStatus;
    json['status_message'] = statusMessage;
    json['merchant_id'] = merchantId;
    json['va_numbers'] = vaNumbers?.map((e) => e.toJson()).toList();
    json['payment_amounts'] = paymentAmounts?.map((e) => e.toJson()).toList();
    json['transaction_time'] = transactionTime;
    json['expiry_time'] = expiryTime;
    return json;
  }
}

class VaNumbers {
  String? bank;
  String? vaNumber;

  VaNumbers({
    this.bank,
    this.vaNumber,
  });

  VaNumbers.fromJson(Map<String, dynamic> json) {
    bank = json['bank'] as String?;
    vaNumber = json['va_number'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['bank'] = bank;
    json['va_number'] = vaNumber;
    return json;
  }
}

class PaymentAmounts {
  String? amount;
  String? paidAt;

  PaymentAmounts({
    this.amount,
    this.paidAt,
  });

  PaymentAmounts.fromJson(Map<String, dynamic> json) {
    amount = json['amount'] as String?;
    paidAt = json['paid_at'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['amount'] = amount;
    json['paid_at'] = paidAt;
    return json;
  }
}