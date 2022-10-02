class DocumentType {

  final int id;
  final String documentType;

  DocumentType(this.id, this.documentType);

  factory DocumentType.fromJson(Map<String, dynamic> json) {
    DocumentType document = DocumentType(json["id"], json["document_type"]);
    return document;
  }
}