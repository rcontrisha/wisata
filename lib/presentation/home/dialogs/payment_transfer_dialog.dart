import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wisata_app/core/core.dart';
import 'package:flutter_wisata_app/data/datasources/product_local_datasource.dart';
import 'package:flutter_wisata_app/presentation/home/bloc/checkout/models/order_model.dart';
import 'package:flutter_wisata_app/presentation/home/bloc/transfer/transfer_bloc.dart';
import 'package:flutter_wisata_app/presentation/home/bloc/transfer_status/transfer_status_bloc.dart';
import 'package:flutter_wisata_app/presentation/home/pages/payment_success_page.dart';
import 'package:url_launcher/url_launcher.dart';

class TransferDialog extends StatefulWidget {
  final int grossAmount;

  const TransferDialog({Key? key, required this.grossAmount}) : super(key: key);

  @override
  State<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog> {
  Timer? _statusCheckTimer;
  String? _currentOrderId;

  @override
  void initState() {
    super.initState();
    // Memulai transfer otomatis
    context
        .read<TransferBloc>()
        .add(TransferEvent.startTransfer(widget.grossAmount));
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel(); // Hentikan timer jika dialog ditutup
    super.dispose();
  }

  // Fungsi untuk membuka URL di browser
  Future<void> launcher(String url) async {
    final Uri _url = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (!await launchUrl(_url)) {
      throw Exception("Failed to launch URL: $_url");
    }

    // Memulai pengecekan status transaksi secara periodik
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentOrderId != null) {
        context
            .read<TransferStatusBloc>()
            .add(TransferStatusEvent.checkTransferStatus(_currentOrderId!));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: MultiBlocListener(
        listeners: [
          BlocListener<TransferBloc, TransferState>(
            listener: (context, state) {
              state.maybeWhen(
                success: (response, orderId) async {
                  // Simpan orderId untuk pengecekan status
                  _currentOrderId = orderId;

                  // Buka payment gateway
                  final url = response['redirect_url'];
                  await launcher(url);
                },
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                orElse: () {},
              );
            },
          ),
          BlocListener<TransferStatusBloc, TransferStatusState>(
            listener: (context, state) {
              state.maybeWhen(
                success: (message) {
                  if (message == "Payment completed.") {
                    // Hentikan pengecekan status
                    _statusCheckTimer?.cancel();

                    // Membuat orderModel dan mengarahkan ke PaymentSuccessPage
                    final orderModel = OrderModel(
                      paymentMethod: 'Transfer',
                      nominalPayment: widget.grossAmount,
                      orders: [], // Isi dengan data yang sesuai
                      totalQuantity: 0, // Sesuaikan
                      totalPrice: widget.grossAmount,
                      cashierId: 0,
                      cashierName: 'Cashier',
                      isSync: false,
                      transactionTime: DateTime.now().toIso8601String(),
                    );
                    ProductLocalDatasource.instance.insertOrder(orderModel);

                    // Arahkan ke halaman PaymentSuccessPage
                    context
                        .pushReplacement(PaymentSuccessPage(order: orderModel));
                  }
                },
                orElse: () {},
              );
            },
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<TransferBloc, TransferState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const Text('Initializing transaction...'),
                  loading: () => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text('Processing transaction...'),
                    ],
                  ),
                  success: (_, __) => const Text('Transaction started.'),
                  error: (message) => Text(
                    message,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            BlocBuilder<TransferStatusBloc, TransferStatusState>(
              builder: (context, state) {
                return state.maybeWhen(
                  loading: () => const CircularProgressIndicator(),
                  success: (message) => Text(
                    message,
                    style: const TextStyle(color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                  pending: (message) => Text(
                    message,
                    style: const TextStyle(color: Colors.orange),
                    textAlign: TextAlign.center,
                  ),
                  failed: (message) => Text(
                    message,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  orElse: () => const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
