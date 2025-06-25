import 'dart:convert';
import 'package:SanalMagaza/controller/Ctanim.dart';
import 'package:SanalMagaza/models/guncelleHataModel.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;



List<UrunModel> urunModelFromJson(String str) =>
    List<UrunModel>.from(json.decode(str).map((x) => UrunModel.fromJson(x)));

String urunModelToJson(List<UrunModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UrunModel {
  int id;
  int adet;
  String productCode;
  double amount;
  double price;
  String barcode;
  String ad;
  int stokNumarasi;
  List<OrderListModel> orderList;

  UrunModel({
    required this.id,
    required this.adet,
    required this.productCode,
    required this.amount,
    required this.price,
    required this.barcode,
    required this.ad,
    required this.stokNumarasi,
    required this.orderList,
  });

  factory UrunModel.fromJson(Map<String, dynamic> json) => UrunModel(
        id: json["lineId"],
        adet: json["quantity"],
        productCode: json["productCode"],
        amount: json["amount"]?.toDouble(),
        price: json["price"]?.toDouble(),
        barcode: json["barcode"],
        ad: json["productName"],
        stokNumarasi: json["orderId"],
        orderList: List<OrderListModel>.from(
            json["orderList"].map((x) => OrderListModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "lineId": id,
        "quantity": adet,
        "productCode": productCode,
        "amount": amount,
        "price": price,
        "barcode": barcode,
        "productName": ad,
        "orderId": stokNumarasi,
        "orderList": List<dynamic>.from(orderList.map((x) => x.toJson())),
      };
}

class OrderListModel {
    int id;
    String durum;
    int talepEdilenAdet;
    int tarihSaat;
    String stokAdeti;

    OrderListModel({
        required this.id,
        required this.durum,
        required this.talepEdilenAdet,
        required this.tarihSaat,
        required this.stokAdeti,
    });

    factory OrderListModel.fromJson(Map<String, dynamic> json) => OrderListModel(
        id: json["id"],
        durum: json["status"],
        talepEdilenAdet: json["stockCount"],
        tarihSaat: json["orderDate"],
        stokAdeti: json["orderNumber"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "status": durum,
        "stockCount": talepEdilenAdet,
        "orderDate": tarihSaat,
        "orderNumber": stokAdeti,
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




Future<String> SiparisGonder(int siparisKalemiId, String  kod,int miktar,bool onayla) async {
  var url = Uri.parse(Ctanim.ip);
  var headers = {
    'Content-Type': 'text/xml; charset=utf-8',
    'SOAPAction': 'http://tempuri.org/TrendYolSiparisDurumGuncelle'
  };
  String status = onayla ? 'Picking' : 'Invoiced';
  var body = """<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Header>
    <AuthHeader xmlns="http://tempuri.org/">
      <ApiKey>${Ctanim.sessionKey}</ApiKey>
    </AuthHeader>
  </soap:Header>
  <soap:Body>
    <TrendYolSiparisDurumGuncelle xmlns="http://tempuri.org/">
      <Status>$status</Status>
      <Kod>$kod</Kod>
      <Id>$siparisKalemiId</Id>
      <Miktar>$miktar</Miktar>
    </TrendYolSiparisDurumGuncelle>
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
      var hata = guncelleHataModelFromJson(jsonData);
      print(jsonData);
      if (hata.hataMesaj == "") {
        return 'Sipariş başarıyla eşleştirildi! Stok güncellendi.';
      }
      return hata.hataMesaj;
    } else {
      print('SOAP isteği başarısız: ${response.statusCode}');
      return 'SOAP isteği başarısız: ${response.statusCode}';
    }
  } catch (e) {
    print('Hata: $e');
    return 'Hata: $e';
  }
}
