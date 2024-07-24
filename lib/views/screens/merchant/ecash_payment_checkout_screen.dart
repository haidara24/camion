import 'package:camion/business_logic/bloc/instructions/payment_create_bloc.dart';
import 'package:camion/data/models/instruction_model.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ECashPaymentCheckoutScreen extends StatefulWidget {
  final String url;
  final SubShipment shipment;

  ECashPaymentCheckoutScreen({
    Key? key,
    required this.url,
    required this.shipment,
  }) : super(key: key);

  @override
  State<ECashPaymentCheckoutScreen> createState() =>
      _ECashPaymentCheckoutScreenState();
}

class _ECashPaymentCheckoutScreenState
    extends State<ECashPaymentCheckoutScreen> {
  double _progress = 0;
  late InAppWebViewController inAppController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri.uri(
                  Uri.parse(widget.url),
                ),
              ),
              onWebViewCreated: (controller) {
                inAppController = controller;
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100;
                });
              },
              onLoadStart: (controller, url) {
                if (url != null &&
                    url.toString().contains("https://your-redirect-url.com")) {
                  ShipmentPayment payment = ShipmentPayment();

                  payment.shipment = widget.shipment.id!;
                  payment.amount = widget.shipment.truck!.fees;
                  payment.paymentMethod = "E";
                  payment.fees = widget.shipment.truck!.fees;
                  payment.extraFees = widget.shipment.truck!.extra_fees;

                  BlocProvider.of<PaymentCreateBloc>(context)
                      .add(PaymentCreateButtonPressed(payment, null));
                  Navigator.pop(context);
                }
              },
            ),
            _progress < 1
                ? SizedBox(
                    child: LinearProgressIndicator(
                      value: _progress,
                    ),
                  )
                : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}
