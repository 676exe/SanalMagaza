import 'dart:convert';

import 'package:sanal_magaza/controller/Ctanim.dart';
import 'package:sanal_magaza/models/siparis_kalemi.dart';
import 'package:sanal_magaza/pages/login.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;


class Urun {
  final String id;
  final String ad;
  final String stokNumarasi;
  final int adet;
  final String? resimYolu;

  Urun({
    required this.id,
    required this.ad,
    required this.stokNumarasi,
    required this.adet,
    this.resimYolu,
  });
}

List<UrunModel> urunModelFromJson(String str) =>
    List<UrunModel>.from(json.decode(str).map((x) => UrunModel.fromJson(x)));

String urunModelToJson(List<UrunModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UrunModel {
  int lineId;
  int quantity;
  int productCode;
  double amount;
  double price;
  String barcode;
  String productName;
  int orderId;
  List<OrderList> orderList;

  UrunModel({
    required this.lineId,
    required this.quantity,
    required this.productCode,
    required this.amount,
    required this.price,
    required this.barcode,
    required this.productName,
    required this.orderId,
    required this.orderList,
  });

  factory UrunModel.fromJson(Map<String, dynamic> json) => UrunModel(
        lineId: json["lineId"],
        quantity: json["quantity"],
        productCode: json["productCode"],
        amount: json["amount"]?.toDouble(),
        price: json["price"]?.toDouble(),
        barcode: json["barcode"],
        productName: json["productName"],
        orderId: json["orderId"],
        orderList: List<OrderList>.from(
            json["orderList"].map((x) => OrderList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "lineId": lineId,
        "quantity": quantity,
        "productCode": productCode,
        "amount": amount,
        "price": price,
        "barcode": barcode,
        "productName": productName,
        "orderId": orderId,
        "orderList": List<dynamic>.from(orderList.map((x) => x.toJson())),
      };
}

Future<List<UrunModel>> UrunGetir() async {
  var url = Uri.parse(Ctanim.ip);
  var headers = {
    'Content-Type': 'text/xml; charset=utf-8',
    'SOAPAction': 'http://tempuri.org/GetirTrendYolSiparis'
  };

  var body = """<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Header>
    <AuthHeader xmlns="http://tempuri.org/">
      <ApiKey>${Ctanim.sessionKey}</ApiKey>
    </AuthHeader> 
  </soap:Header>
  <soap:Body>
    <GetirTrendYolSiparis xmlns="http://tempuri.org/">
      <Status>Created</Status>
    </GetirTrendYolSiparis>
  </soap:Body>
</soap:Envelope>""";

  try {
    var response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      var rawXmlResponse = response.body;
      xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
      final kontrolKarakterleri = RegExp(r'[\x00-\x1F\x7F]');
      String jsonData = parsedXml.innerText.replaceAll(kontrolKarakterleri, '');
      var list = urunModelFromJson(jsonData);
      return list;
    } else {
      print('SOAP isteği başarısız: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Hata: $e');
    return [];
  }
}
