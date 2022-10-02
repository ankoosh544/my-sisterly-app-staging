import 'dart:io';

import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:sisterly/models/offer.dart';
import 'package:sisterly/models/record.dart';
import 'package:sisterly/screens/signup_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:sisterly/utils/extensions.dart';
import 'package:sisterly/utils/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/constants.dart';

class NfcChooseScreen extends StatefulWidget {

  final Offer offer;

  const NfcChooseScreen({Key? key, required this.offer}) : super(key: key);

  @override
  NfcChooseScreenState createState() => NfcChooseScreenState();
}

class NfcChooseScreenState extends State<NfcChooseScreen> {

  String _errorMessage = "";

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {

    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.PRIMARY_COLOR,
      body: Container(
        decoration: const BoxDecoration(
            color: Colors.white,),
        child: Stack(
          children: [
            SvgPicture.asset("assets/images/bg-pink-ellipse.svg", width: MediaQuery.of(context).size.width,),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                          child: Container(padding: const EdgeInsets.all(12), child: SvgPicture.asset("assets/images/back_black.svg")),
                          onTap: () {
                            Navigator.of(context).pop();
                          }
                      ),
                    ),
                    const SizedBox(height: 44),
                    Text(
                      "Pronto",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Constants.PRIMARY_COLOR,
                        fontFamily: Constants.FONT,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("Avvicina il telefono al tag NFC per confermare le condizioni della borsa nel momento in cui la ricevi",
                        style: TextStyle(
                          color: Constants.TEXT_COLOR,
                          fontSize: 16,
                          fontFamily: Constants.FONT,
                        ),
                      textAlign: TextAlign.center,
                    ),
                    Text(_errorMessage),
                    const SizedBox(height: 80),
                    const Expanded(
                      child: SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NdefRecordInfo {
  const NdefRecordInfo({required this.record, required this.title, required this.subtitle});

  final Record record;

  final String title;

  final String subtitle;

  static NdefRecordInfo fromNdef(NdefRecord record) {
    final _record = Record.fromNdef(record);
    if (_record is WellknownTextRecord)
      return NdefRecordInfo(
        record: _record,
        title: 'Wellknown Text',
        subtitle: '(${_record.languageCode}) ${_record.text}',
      );
    if (_record is WellknownUriRecord)
      return NdefRecordInfo(
        record: _record,
        title: 'Wellknown Uri',
        subtitle: '${_record.uri}',
      );
    if (_record is MimeRecord)
      return NdefRecordInfo(
        record: _record,
        title: 'Mime',
        subtitle: '(${_record.type}) ${_record.dataString}',
      );
    if (_record is AbsoluteUriRecord)
      return NdefRecordInfo(
        record: _record,
        title: 'Absolute Uri',
        subtitle: '(${_record.uriType}) ${_record.payloadString}',
      );
    if (_record is ExternalRecord)
      return NdefRecordInfo(
        record: _record,
        title: 'External',
        subtitle: '(${_record.domainType}) ${_record.dataString}',
      );
    if (_record is UnsupportedRecord) {
      // more custom info from NdefRecord.
      if (record.typeNameFormat == NdefTypeNameFormat.empty)
        return NdefRecordInfo(
          record: _record,
          title: _typeNameFormatToString(_record.record.typeNameFormat),
          subtitle: '-',
        );
      return NdefRecordInfo(
        record: _record,
        title: _typeNameFormatToString(_record.record.typeNameFormat),
        subtitle: '(${_record.record.type.toHexString()}) ${_record.record.payload.toHexString()}',
      );
    }
    throw UnimplementedError();
  }
}

String _typeNameFormatToString(NdefTypeNameFormat format) {
  switch (format) {
    case NdefTypeNameFormat.empty:
      return 'Empty';
    case NdefTypeNameFormat.nfcWellknown:
      return 'NFC Wellknown';
    case NdefTypeNameFormat.media:
      return 'Media';
    case NdefTypeNameFormat.absoluteUri:
      return 'Absolute Uri';
    case NdefTypeNameFormat.nfcExternal:
      return 'NFC External';
    case NdefTypeNameFormat.unknown:
      return 'Unknown';
    case NdefTypeNameFormat.unchanged:
      return 'Unchanged';
  }
}