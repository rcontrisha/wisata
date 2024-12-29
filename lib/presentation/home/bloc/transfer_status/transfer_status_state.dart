part of 'transfer_status_bloc.dart';

@freezed
class TransferStatusState with _$TransferStatusState {
  const factory TransferStatusState.initial() = _Initial;
  const factory TransferStatusState.loading() = _Loading;
  const factory TransferStatusState.success(String message) = _Success;
  const factory TransferStatusState.pending(String message) = _Pending;
  const factory TransferStatusState.failed(String message) = _Failed;
  const factory TransferStatusState.error(String error) = _Error;
}
