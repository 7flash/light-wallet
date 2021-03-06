import 'package:flutter/material.dart' hide Action;
import 'package:seeds/providers/services/eos_service.dart';
import 'package:seeds/v2/navigation/navigation_service.dart';
import 'package:seeds/widgets/main_button.dart';
import '../../../utils/double_extension.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:seeds/i18n/wallet.i18n.dart';

class ReceiveQR extends StatefulWidget {
  final double? amount;

  const ReceiveQR({Key? key, required this.amount}) : super(key: key);

  @override
  ReceiveQRState createState() => ReceiveQRState();
}

class ReceiveQRState extends State<ReceiveQR> {
  final formKey = GlobalKey<FormState>();
  final controller = TextEditingController(text: '');
  String invoiceImage = '';

  @override
  void initState() {
    super.initState();
    generateInvoice();
  }

  void generateInvoice() async {
    double receiveAmount = widget.amount!;

    var uri = await EosService.of(context, listen: false).generateInvoice(receiveAmount);

    setState(() {
      invoiceImage = uri;
    });
  }

  @override
  Widget build(BuildContext context) {
    var acctName = EosService.of(context).accountName!;
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            acctName,
            style: const TextStyle(color: Colors.black87),
          )),
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
        child: invoiceImage.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  QrImage(data: invoiceImage, foregroundColor: Colors.black87),
                  Text(
                    "%s SEEDS to %s".i18n.fill([widget.amount.seedsFormatted, acctName]),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  MainButton(
                      title: "Done".i18n,
                      onPressed: () {
                        Navigator.of(context).popUntil(NavigationService.predicateForName("/"));
                      }),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
