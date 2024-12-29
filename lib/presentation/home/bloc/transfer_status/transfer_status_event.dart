part of 'transfer_status_bloc.dart';

@freezed
class TransferStatusEvent with _$TransferStatusEvent {
  const factory TransferStatusEvent.started() = _Started;
  const factory TransferStatusEvent.checkTransferStatus(String transactionId) = _CheckTransferStatus;
}