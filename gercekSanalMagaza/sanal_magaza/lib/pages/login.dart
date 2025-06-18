import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:sanal_magaza/controller/Ctanim.dart';
import 'package:sanal_magaza/models/urun_model.dart';
import 'package:sanal_magaza/pages/urun_detay_sayfasi.dart';
import 'package:sanal_magaza/controller/sharedDB.dart';
import 'package:sanal_magaza/pages/urun_listesi_sayfasi.dart';
import 'package:sanal_magaza/trash/sharedPreferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import '../trash/base.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Future<void> clearAllPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final storage = FlutterSecureStorage();
    await storage.readAll();
    await prefs.clear();
    print("Tüm SharedPreferences verileri silindi");
  }

  List<String> donenAPIler = [];

  TextEditingController lisans = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: TextFormField(
        controller: lisans,
        decoration: InputDecoration(
            suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () async {
                  SharedDB shared = SharedDB();
                  String kullanici =
                      await kullaniciSayisiSorgula(LisansNo: lisans.text);
                  clearAllPreferences();
                  await lisansNumarasiKaydet(lisans.text);
                  if (kullanici == "OK") {
                    await shared.ipSil();
                    donenAPIler = await makeSoapRequest(lisans.text);
                    if (donenAPIler.length > 1) {
                      await shared.ipKaydet(donenAPIler[1]);
                      //
                      var test = await UrunGetir();
                      //
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UrunListesiSayfasi(),
                          ));
                    }
                  }
                })),
      ),
    ));
  }
}

Future<String?> _getId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor;
  } else if (Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.id;
  }
}

Future<String> kullaniciSayisiSorgula({
  required String LisansNo,
}) async {
  var url = Uri.parse('http://setuppro.opakyazilim.net/Service1.asmx');
  var headers = {
    'Content-Type': 'text/xml; charset=utf-8',
    'SOAPAction': 'http://tempuri.org/MobilLisansSorgula'
  };
  String? privateID = await _getId();
  print(privateID);

  String body = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <MobilLisansSorgula xmlns="http://tempuri.org/">
      <_MacAdres>$privateID</_MacAdres>
      <_LisansNo>$LisansNo</_LisansNo>
    </MobilLisansSorgula>
  </soap:Body>
</soap:Envelope>''';

  try {
    var response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    SharedDB shared = SharedDB();
    if (response.statusCode == 200) {
      var rawXmlResponse = response.body;
      xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
      String jsonData = temizleKontrolKarakterleri(parsedXml.innerText);
      const String successPrefix = "OK_";
      if (jsonData.startsWith(successPrefix)) {
        String sessionKey = jsonData.substring(successPrefix.length);
        await shared.sessionKeyKaydet(sessionKey);
        Ctanim.sessionKey = await shared.sessionKeyGetir();

        return "OK";
      } else {
        return "";
      }
    } else {
      print('SOAP isteği başarısız: ${response.statusCode}');
      return " Kullanıcı Bilgileri Getirilirken İstek Oluşturulamadı. " +
          response.statusCode.toString();
    }
  } catch (e) {
    print('Hata: $e');
    return " Kullanıcı bilgiler için Webservisten veri çekilemedi. Hata Mesajı : " +
        e.toString();
  }
}

Future<List<String>> makeSoapRequest(String lisansNumarasi) async {
  var url = Uri.parse('http://setuppro.opakyazilim.net/Service1.asmx');
  var headers = {
    'Content-Type': 'text/xml; charset=utf-8',
    'SOAPAction': 'http://tempuri.org/GetirAPKServisIP'
  };

  var body = "<?xml version=\"1.0\" encoding=\"utf-8\"?>  " +
      " <soap:Envelope xmlns:xsi=\"http:\/\/www.w3.org\/2001\/XMLSchema-instance\" xmlns:xsd=\"http:\/\/www.w3.org\/2001\/XMLSchema\" " +
      " xmlns:soap=\"http:\/\/schemas.xmlsoap.org\/soap\/envelope\/\">" +
      " <soap:Body>" +
      "<GetirAPKServisIP xmlns=\"http:\/\/tempuri.org\/\">" +
      "  <SipNo>$lisansNumarasi</SipNo>" +
      "</GetirAPKServisIP>" +
      " <\/soap:Body> " +
      " <\/soap:Envelope> ";

  try {
    var response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      var rawXmlResponse = response.body;
      var tt = parseSoapResponse(response.body);
      return tt;
    } else {
      print('SOAP isteği başarısız: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Hata: $e');
    return [];
  }
}

String temizleKontrolKarakterleri(String metin) {
  final kontrolKarakterleri = RegExp(r'[\x00-\x1F\x7F]');
  return metin.replaceAll(kontrolKarakterleri, '');
}

List<String> parseSoapResponse(String soapResponse) {
  var document = xml.XmlDocument.parse(soapResponse);
  var envelope = document.findAllElements('soap:Envelope').single;
  var body = envelope.findElements('soap:Body').single;
  var response = body.findElements('GetirAPKServisIPResponse').single;
  var result = response.findElements('GetirAPKServisIPResult').single;
  List<String> donecek = result.text.split("|");
  return donecek;
}

Future<void> lisansNumarasiKaydet(String lisans) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('lisansNo', lisans);
}