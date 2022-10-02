import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sisterly/models/address.dart';
import 'package:sisterly/models/credit_card.dart';
import 'package:sisterly/models/document.dart';
import 'package:sisterly/models/offer.dart';
import 'package:sisterly/screens/payment_status_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';

import '../utils/card_number_formatter.dart';
import '../utils/utils.dart';
import 'documents_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final Function successCallback;
  final Function failureCallback;
  final String? paymentIntentId;
  final String paymentIntentSecret;
  final Offer? offer;

  const PaymentMethodScreen({Key? key, required this.successCallback, required this.failureCallback, required this.paymentIntentId, required this.paymentIntentSecret, this.offer}) : super(key: key);

  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  CardDetails _card = CardDetails();
  bool? _saveCard = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.PRIMARY_COLOR,
      body: Column(
        children: [
          Stack(
            children: [
              Align(
                child: SvgPicture.asset("assets/images/wave_blue.svg"),
                alignment: Alignment.topRight,
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                          child: InkWell(
                              child: SizedBox(
                                  child: SvgPicture.asset(
                                      "assets/images/back.svg")),
                              onTap: () {
                                Navigator.of(context).pop();
                              })),
                      const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Text(
                          "Pagamento",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: Constants.FONT),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 17)
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 4),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 25),
                      Row(children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Numero carta",
                                  style: TextStyle(
                                    color: Constants.TEXT_COLOR,
                                    fontSize: 16,
                                    fontFamily: Constants.FONT,
                                  )),
                              const SizedBox(height: 7),
                              Container(
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x4ca3c4d4),
                                      spreadRadius: 8,
                                      blurRadius: 12,
                                      offset: Offset(
                                          0, 0), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  cursorColor: Constants.PRIMARY_COLOR,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Constants.FORM_TEXT,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: "",
                                    hintText: "XXXX XXXX XXXX XXXX",
                                    hintStyle: const TextStyle(
                                        color: Constants.PLACEHOLDER_COLOR),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.all(16),
                                    filled: true,
                                    fillColor: Constants.WHITE,
                                  ),
                                  onChanged: (number) {
                                    setState(() {
                                      _card = _card.copyWith(number: number);
                                    });
                                  },
                                  maxLength: 19,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    CardNumberFormatter(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                      SizedBox(height: 24,),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Mese scad.",
                                    style: TextStyle(
                                      color: Constants.TEXT_COLOR,
                                      fontSize: 16,
                                      fontFamily: Constants.FONT,
                                    )),
                                const SizedBox(height: 7),
                                Container(
                                  decoration: const BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x4ca3c4d4),
                                        spreadRadius: 8,
                                        blurRadius: 12,
                                        offset:
                                        Offset(0, 0), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    cursorColor: Constants.PRIMARY_COLOR,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Constants.FORM_TEXT,
                                    ),
                                    maxLength: 2,
                                    decoration: InputDecoration(
                                      hintText: "MM",
                                      counterText: "",
                                      hintStyle: const TextStyle(
                                          color: Constants.PLACEHOLDER_COLOR),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          width: 0,
                                          style: BorderStyle.none,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.all(16),
                                      filled: true,
                                      fillColor: Constants.WHITE,
                                    ),
                                    onChanged: (number) {
                                      setState(() {
                                        _card = _card.copyWith(
                                            expirationMonth: int.tryParse(number));
                                      });
                                    },
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Anno scad.",
                                    style: TextStyle(
                                      color: Constants.TEXT_COLOR,
                                      fontSize: 16,
                                      fontFamily: Constants.FONT,
                                    )),
                                const SizedBox(height: 7),
                                Container(
                                  decoration: const BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x4ca3c4d4),
                                        spreadRadius: 8,
                                        blurRadius: 12,
                                        offset:
                                        Offset(0, 0), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    cursorColor: Constants.PRIMARY_COLOR,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Constants.FORM_TEXT,
                                    ),
                                    maxLength: 2,
                                    decoration: InputDecoration(
                                      counterText: "",
                                      hintText: "AA",
                                      hintStyle: const TextStyle(
                                          color: Constants.PLACEHOLDER_COLOR),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          width: 0,
                                          style: BorderStyle.none,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.all(16),
                                      filled: true,
                                      fillColor: Constants.WHITE,
                                    ),
                                    onChanged: (number) {
                                      setState(() {
                                        _card = _card.copyWith(
                                            expirationYear: int.tryParse(number));
                                      });
                                    },
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12,),
                          Column(
                            children: [
                              const Text("CVC",
                                  style: TextStyle(
                                    color: Constants.TEXT_COLOR,
                                    fontSize: 16,
                                    fontFamily: Constants.FONT,
                                  )),
                              const SizedBox(height: 7),
                              Container(
                                width: 100,
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x4ca3c4d4),
                                      spreadRadius: 8,
                                      blurRadius: 12,
                                      offset:
                                      Offset(0, 0), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  cursorColor: Constants.PRIMARY_COLOR,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Constants.FORM_TEXT,
                                  ),
                                  maxLength: 4,
                                  decoration: InputDecoration(
                                    hintText: "CVC",
                                    counterText: "",
                                    hintStyle: const TextStyle(
                                        color: Constants.PLACEHOLDER_COLOR),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.all(16),
                                    filled: true,
                                    fillColor: Constants.WHITE,
                                  ),
                                  onChanged: (number) {
                                    setState(() {
                                      _card = _card.copyWith(cvc: number);
                                    });
                                  },
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                      if(widget.offer != null) Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Totale da pagare",
                            style: TextStyle(
                                color: Constants.DARK_TEXT_COLOR,
                                fontSize: 18,
                                fontFamily: Constants.FONT,
                                fontWeight: FontWeight.bold
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            Utils.formatCurrency(widget.offer!.total),
                            style: TextStyle(
                                color: Constants.DARK_TEXT_COLOR,
                                fontSize: 18,
                                fontFamily: Constants.FONT,
                                fontWeight: FontWeight.bold
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                      Text("L'importo verrà addebitato solo quando la Lender accetterà la tua richiesta di noleggio"),
                      SizedBox(height: 40),
                      Center(
                        child: isLoading ? CircularProgressIndicator() : Opacity(
                          opacity: 1,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Constants.SECONDARY_COLOR,
                                textStyle: const TextStyle(fontSize: 16),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 46, vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50))),
                            child: Text('Paga'),
                            onPressed: () async {
                              next();
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 35)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  next() async {
    setState(() {
      isLoading = true;
    });

    try {
      //final paymentMethod = await Stripe.instance.createPaymentMethod(PaymentMethodParams.card());
      await Stripe.instance.dangerouslyUpdateCardDetails(_card);

      final paymentMethod = await Stripe.instance.createPaymentMethod(
          PaymentMethodParams.card(paymentMethodData: PaymentMethodData()));
      debugPrint("paymentMethod " + paymentMethod.id.toString());

      PaymentMethodParams params = PaymentMethodParams.cardFromMethodId(
          paymentMethodData: PaymentMethodDataCardFromMethod(
              paymentMethodId: paymentMethod.id));
      final confirmIntent = await Stripe.instance.confirmPayment(
          widget.paymentIntentSecret, params);

      debugPrint("confirmIntent " + confirmIntent.id.toString());

      setState(() {
        isLoading = false;
      });

      widget.successCallback();
    } catch(e) {
      setState(() {
        isLoading = false;
      });
      ApiManager.showFreeErrorMessage(context, "Pagamento fallito. Riprova");

      ApiManager.showFreeErrorToast(context, e.toString());
    }


  }
}
