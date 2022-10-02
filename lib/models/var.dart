import 'package:sisterly/models/delivery_mode.dart';

import 'generic.dart';

List<DeliveryMode> deliveryTypes = [
  DeliveryMode(1, 'Di persona'),
  DeliveryMode(3, 'Corriere'),
  DeliveryMode(13, 'Di persona o corriere'),
];

List<Generic> productConditions = [
  Generic(1, 'Eccellenti'),
  Generic(2, 'Buone'),
  Generic(3, 'Scarse')
];

List<Generic> bagYears = [
  Generic(1, '1-2'),
  Generic(2, '2+')
];

List<Generic> bagSizes = [
  Generic(1, 'Piccola'),
  Generic(2, 'Media'),
  Generic(3, 'Grande')
];

List<Generic> lenderKits = [
  Generic(1, 'Solo tag NFC (obbligatorio) - 4€'),
  Generic(2, 'Lender Kit completo (Tag + Bag) - 15€'),
  Generic(3, 'Ritiro NFC in ufficio Sisterly - 0€')
];

List<Generic> documentTypes = [
  Generic(1, "Carta d'identità"),
  Generic(2, "Passaporto"),
  Generic(3, 'Patente di guida'),
  Generic(4, 'Bolletta')
];

/*
# Order statuses
# When an user makes an offer, it first has to pay (2) (see 2-step payment).
# After the user has paid, the money is on-hold (3 -> 31) until the product's owner accepts it (4).
# At this point, the money gets captured.
ORDER_STATUS = [
    # DEPRECATED: there will be no need to use status == 1, as every offer will begin on 2.
    (1, 'WAITING FOR ACCEPTANCE'),
    # The borrower just created the offer, and has to pay
    (2, 'WAITING FOR PAYMENT'),
    # The order is being paid
    (3, 'PAYMENT IN PROGRESS'),
     # The offer has been accepted and the money has left the borrower's account
    (4, 'PAID'),
    # The borrower has received the item
    (5, 'BORROWED'),
    # The lender has received the item back from the borrower
    (6, 'CLOSED'),
    # The offer has been rejected
    (7, 'REJECTED'),
    # The offer has been paid, but the offer has not been accepted
    (31, 'PAYMENT_WAITING_FOR_ACCEPTANCE'),
]
 */

getGenericName(id, array) {
  var cond = array.where((element) => element.id == id);

  if(cond.isNotEmpty) {
    return cond.first.name;
  } else {
    return id.toString();
  }
}

getDeliveryTypeName(id) {
  var cond = deliveryTypes.where((element) => element.id == id);

  if(cond.isNotEmpty) {
    return cond.first.description;
  } else {
    return id.toString();
  }
}