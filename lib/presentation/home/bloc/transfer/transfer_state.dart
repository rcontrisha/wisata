part of 'transfer_bloc.dart';

@freezed
class TransferState with _$TransferState {
  const factory TransferState.initial() = _Initial;
  const factory TransferState.loading() = _Loading;
  const factory TransferState.success(Map<String, dynamic> response, String orderId) = _Success;
  const factory TransferState.error(String message) = _Error;
}