import 'package:bloc/bloc.dart';
import 'package:flutter_wisata_app/data/datasources/midtrans_remote_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transfer_status_event.dart';
part 'transfer_status_state.dart';
part 'transfer_status_bloc.freezed.dart';

class TransferStatusBloc
    extends Bloc<TransferStatusEvent, TransferStatusState> {
  final MidtransRemoteDatasource datasource;

  TransferStatusBloc(this.datasource) : super(const TransferStatusState.initial()) {
    on<TransferStatusEvent>((event, emit) async {
      await event.map(
        started: (_) async {
          emit(const TransferStatusState.initial());
        },
        checkTransferStatus: (e) async {
          emit(const TransferStatusState.loading());
          try {
            final status = await datasource.checkTransferStatus(e.transactionId);
            if (status.transactionStatus == 'settlement') {
              emit(const TransferStatusState.success('Payment completed.'));
            } else if (status.transactionStatus == 'pending') {
              emit(const TransferStatusState.pending('Waiting for payment.'));
            } else {
              emit(const TransferStatusState.failed('Payment failed.'));
            }
          } catch (e) {
            emit(TransferStatusState.error(e.toString()));
          }
        },
      );
    });
  }
}

