part of 'transfer_bloc.dart';

@freezed
class TransferEvent with _$TransferEvent {
  const factory TransferEvent.started() = _Started;
  const factory TransferEvent.startTransfer(int grossAmount) = _StartTransfer;
}
