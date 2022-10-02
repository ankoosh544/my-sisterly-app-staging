import 'document_type.dart';

class Document {
  final int id;
  final String front;
  final String? back;
  final DocumentType documentType;
  final DateTime? expirationDate;

  Document(
      this.id, this.front, this.back, this.documentType, this.expirationDate);

  factory Document.fromJson(Map<String, dynamic> json) {
    Document document = Document(
        json["id"],
        json["front"],
        json["back"],
        DocumentType.fromJson(json["document_type"]),
        json["expiration_date"] != null ? DateTime.tryParse(json["expiration_date"]) : null);
    return document;
  }
}
