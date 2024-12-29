// transfer_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:flutter_wisata_app/data/datasources/midtrans_remote_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transfer_event.dart';
part 'transfer_state.dart';
part 'transfer_bloc.freezed.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final MidtransRemoteDatasource datasource;
  String? orderId; // Tambahkan property untuk menyimpan orderId

  TransferBloc(this.datasource) : super(const TransferState.initial()) {
    on<TransferEvent>((event, emit) async {
      await event.when(
        started: () async {
          emit(const TransferState.initial());
        },
        startTransfer: (grossAmount) async {
          emit(const TransferState.loading());
          orderId =
              'ORDER-${DateTime.now().millisecondsSinceEpoch}'; // Set orderId di sini
          try {
            final response =
                await datasource.createTransaction(orderId!, grossAmount);
            emit(TransferState.success(response, orderId!));
          } catch (e) {
            emit(TransferState.error(e.toString()));
          }
        },
      );
    });
  }
}
