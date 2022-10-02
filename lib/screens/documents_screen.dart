import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:sisterly/models/document.dart';
import 'package:sisterly/models/product.dart';
import 'package:sisterly/models/var.dart';
import 'package:sisterly/screens/add_document_screen.dart';
import 'package:sisterly/utils/api_manager.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sisterly/utils/utils.dart';
import 'package:sisterly/widgets/header_widget.dart';

import '../utils/constants.dart';
import '../widgets/alert/custom_alert.dart';

class DocumentsScreen extends StatefulWidget {

  final Product? editProduct;

  const DocumentsScreen({Key? key, this.editProduct}) : super(key: key);

  @override
  DocumentsScreenState createState() => DocumentsScreenState();
}

class DocumentsScreenState extends State<DocumentsScreen>  {

  List<Document> _documents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      getDocuments();
    });
  }

  getDocuments() {
    setState(() {
      _isLoading = true;
    });
    ApiManager(context).makeGetRequest('/client/document', {}, (res) {
      _documents = [];

      var data = res["data"];
      if (data != null) {
        for (var doc in data) {
          _documents.add(Document.fromJson(doc));
        }
      }

      setState(() {
        _isLoading = false;
      });
    }, (res) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  documentCell(Document document) {
    return Stack(
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getGenericName(document.documentType.id, documentTypes),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Constants.TEXT_COLOR,
                        fontFamily: Constants.FONT,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                    ),

                  ],
                ),
                SizedBox(height: 8,),
                if(document.expirationDate != null) Text(
                  DateFormat("dd/MM/yyyy").format(document.expirationDate!),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Constants.TEXT_COLOR,
                      fontFamily: Constants.FONT,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 8,),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            primary: Constants.PRIMARY_COLOR,
                            textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),
                            side: const BorderSide(color: Constants.PRIMARY_COLOR, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            )
                        ),
                        child: Text('Visualizza'),
                        onPressed: () async {
                          Utils.launchURL(document.front);
                        },
                      ),
                    ),
                    if(document.back != null && document.back!.isNotEmpty) SizedBox(width: 12),
                    if(document.back != null && document.back!.isNotEmpty) Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            primary: Constants.PRIMARY_COLOR,
                            textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),
                            side: const BorderSide(color: Constants.PRIMARY_COLOR, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            )
                        ),
                        child: Text('Vedi retro'),
                        onPressed: () async {
                          Utils.launchURL(document.back!);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 0,
            top: 0,
            child: InkWell(
                onTap: () {
                  CustomAlert.show(context,
                      //title: AppLocalizations.of(context).translate("generic_success"),
                      confirmButtonColor: Constants.SECONDARY_COLOR,
                      subtitle: "Vuoi procedere con l'eliminazione?",
                      showCancelButton: true,
                      cancelButtonText: "Annulla",
                      cancelButtonColor: Colors.white,
                      //style: CustomAlertStyle.success,
                      onPress: (bool isConfirm) {
                        Navigator.of(context, rootNavigator: true).pop();

                       if(isConfirm) {
                         delete(document);
                       }

                        return false;
                      });
                },
                child: SvgPicture.asset("assets/images/cancel.svg", width: 40, height: 40,)
            )
        )
      ],
    );
  }

  delete(Document document) {
    setState(() {
      _isLoading = true;
    });

    ApiManager(context).makeDeleteRequest("/client/document/" + document.id.toString(), (res) {
      // print(res);
      setState(() {
        _isLoading = false;
      });

      ApiManager.showFreeSuccessMessage(context, "Documento eliminato!");

      getDocuments();
    }, (res) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.PRIMARY_COLOR,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          backgroundColor: Constants.SECONDARY_COLOR,
          child: SvgPicture.asset("assets/images/plus.svg"),
          onPressed: () async {
            await Navigator.of(context).push(
                MaterialPageRoute(builder: (BuildContext context) => AddDocumentScreen()));

            getDocuments();
          },
        ),
      ),
      body: Column(
        children: [
          HeaderWidget(title: "Documenti"),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 6),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: _documents.isEmpty ? Center(child: Text("Nessun documento caricato")) : ListView.builder(
                        padding: const EdgeInsets.all(0),
                          itemCount: _documents.length,
                          itemBuilder: (BuildContext context, int index) {
                            return documentCell(_documents[index]);
                          }
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
