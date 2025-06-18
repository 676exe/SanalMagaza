// import 'dart:convert';
// import 'dart:io';

// import 'dart:math';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:http/http.dart' as http;
// import 'package:opak_mobil_v2/Depo%20Transfer/subeDepoModel.dart';
// import 'package:opak_mobil_v2/faturaFis/FisNakliye.dart';
// import 'package:opak_mobil_v2/faturaFis/fisEkParam.dart';
// import 'package:opak_mobil_v2/interaktif_rapor/interaktifRaporGenelModel.dart';
// import 'package:opak_mobil_v2/stok_kart/daha_fazla_barkod.dart';
// import 'package:opak_mobil_v2/stok_kart/stokDepoMode.dart';
// import 'package:opak_mobil_v2/webservis/bankaModel.dart';
// import 'package:opak_mobil_v2/webservis/satisTipiModel.dart';
// import 'package:opak_mobil_v2/webservis/kullaniciYetki.dart';
// import 'package:opak_mobil_v2/webservis/kurModel.dart';
// import 'package:opak_mobil_v2/webservis/stokFiyatListesiHar.dart';
// import 'package:opak_mobil_v2/webservis/stokFiyatListesiModel.dart';
// import 'package:opak_mobil_v2/widget/cari.dart';
// import 'package:opak_mobil_v2/widget/cariAltHesap.dart';
// import 'package:opak_mobil_v2/widget/ctanim.dart';
// import 'package:opak_mobil_v2/widget/kullaniciModel.dart';
// import 'package:opak_mobil_v2/widget/modeller/cariKosulModel.dart';
// import 'package:opak_mobil_v2/widget/modeller/cariStokKosulModel.dart';
// import 'package:opak_mobil_v2/widget/modeller/gecmisSatisModel.dart';
// import 'package:opak_mobil_v2/widget/modeller/ondalikModel.dart';
// import 'package:opak_mobil_v2/widget/modeller/rafModel.dart';
// import 'package:opak_mobil_v2/widget/modeller/stokKosulModel.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:xml/xml.dart' as xml;
// import '../localDB/veritabaniIslemleri.dart';
// import '../localDB/databaseHelper.dart';
// import '../stok_kart/stok_tanim.dart';
// import '../widget/modeller/sharedPreferences.dart';
// import '../widget/veriler/listeler.dart';
// import '../widget/modeller/sHataModel.dart';
// import '../widget/modeller/olcuBirimModel.dart';
// import 'bankaSozlesmeModel.dart';

// class BaseService {
//   var _Result;
//   String mac = "";

//   get Result => _Result;

//   set Result(value) {
//     _Result = value;
//   }

//   Future<String?> _getId() async {
//     var deviceInfo = DeviceInfoPlugin();
//     if (Platform.isIOS) {
//       // import 'dart:io'
//       var iosDeviceInfo = await deviceInfo.iosInfo;
//       return iosDeviceInfo.identifierForVendor; // unique ID on iOS
//     } else if (Platform.isAndroid) {
//       var androidDeviceInfo = await deviceInfo.androidInfo;
//       return androidDeviceInfo.id; // unique ID on Android
//     }
//   }

// //webservisteki stokları getirir
//   Future<String> getirStoklar({required sirket, required kullaniciKodu}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirStok'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirStok xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <PlasiyerKod>$kullaniciKodu</PlasiyerKod>
//     </GetirStok>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
//       listeler.liststok = [];
//       return "İnternet Yok";
//     }

//     List<StokKart> tt = [];
//     try {
//       http.Response response =
//           await http.post(url, headers: headers, body: body);

//       if (response.statusCode == 200) {
//         //var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(response.body);
//         //printWrapped(response.body);
//         //Map<String, dynamic> jsonData = jsonDecode(parsedXml.innerText);
//         //SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         //  if (gelenHata.Hata == "true") {
//         //    print(gelenHata.HataMesaj);
//         //    return gelenHata.HataMesaj!;
//         //   }
//         //  else {

//         var jsonData = [];
//         try {
//           var tt = temizleKontrolKarakterleri1(parsedXml.innerText);
//           jsonData = json.decode(tt);
//         } catch (e) {
//           await ekleHata(sirket: Ctanim.sirket!, hata: parsedXml.innerText);
//           print(e);
//         }
//         List<StokKart> liststokTemp = [];

//         liststokTemp = List<StokKart>.from(
//             jsonData.map((model) => StokKart.fromJson(model)));
//         listeler.liststok.clear();
//         await VeriIslemleri().stokTabloTemizle();

//         liststokTemp.forEach((webservisStok) async {
//           await VeriIslemleri().stokEkle(webservisStok);
//         });

//         await VeriIslemleri().stokGetir();
//         return "";
//         // }
//       } else {
//         return " Stok Getirilirken İstek Oluşturulamadı. " +
//             response.statusCode.toString();
//       }
//     } on PlatformException catch (e) {
//       return "Stoklar için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   String temizleKontrolKarakterleri(String metin) {
//     final kontrolKarakterleri = RegExp(r'[\x00-\x1F\x7F]');
//     return metin.replaceAll(kontrolKarakterleri, '');
//   }

//   String temizleKontrolKarakterleri1(String metin) {
//     final kontrolKarakterleri = RegExp(r'[\x00-\x1F\x7F]');

//     final int chunkSize =
//         1024; // Metni kaç karakterlik parçalara böleceğimizi belirtiyoruz.
//     final int length = metin.length;
//     final StringBuffer result = StringBuffer();

//     for (int i = 0; i < length; i += chunkSize) {
//       int end = (i + chunkSize < length) ? i + chunkSize : length;
//       String chunk = metin.substring(i, end);
//       result.write(chunk.replaceAll(kontrolKarakterleri, ''));
//     }

//     return result.toString();
//   }

// ////webservisteki carileri getirir
//   Future<String> getirCariler({required sirket, required kullaniciKodu}) async {
//     SHataModel gelenHata = SHataModel();
//     var url = Uri.parse(Ctanim.IP);
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirCari'
//     };
//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirCari xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <PlasiyerKod>$kullaniciKodu</PlasiyerKod>
//     </GetirCari>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
//       listeler.listCari = [];
//       return "İnternet Yok";
//     }
//     List<Cari> ttcari = [];
//     try {
//       http.Response response =
//           await http.post(url, headers: headers, body: body);
//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         try {
//           Map<String, dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//           gelenHata = SHataModel.fromJson(jsonData);
//         } catch (e) {
//           await ekleHata(sirket: Ctanim.sirket!, hata: parsedXml.innerText);
//         }

//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           String modelNode = gelenHata.HataMesaj!;
//           Iterable? l;
//           try {
//             String temizJson = temizleKontrolKarakterleri(modelNode);

//             l = json.decode(temizJson);
//           } catch (e) {
//             await ekleHata(sirket: Ctanim.sirket!, hata: modelNode);
//             print(e);
//           }

//           List<Cari> listcariTemp = [];
//           listcariTemp =
//               List<Cari>.from(l!.map((model) => Cari.fromJson(model)));

//           listeler.listCari.clear();
//           await VeriIslemleri().cariTabloTemizle();

//           listcariTemp.forEach((webservisCari) async {
//             await VeriIslemleri().cariEkle(webservisCari);
//           });

//           await VeriIslemleri().cariGetir();

//           return "";
//         }
//       } else {
//         return " Cariler Getirilirken İstek Oluşturulamadı. " +
//             response.statusCode.toString();
//       }

//       // databaseden veri getirir
//     } on Exception catch (e) {
//       listeler.listCari = ttcari;
//       return "Cariler için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   Future<String> getirKur({required sirket}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirKur'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirKur xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//     </GetirKur>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response =
//           await http.post(url, headers: headers, body: body);

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           listeler.listKur.clear();
//           await VeriIslemleri().kurTemizle();

//           String modelNode = gelenHata.HataMesaj!;
//           Iterable l = json.decode(modelNode);

//           listeler.listKur =
//               List<KurModel>.from(l.map((model) => KurModel.fromJson(model)));

//           for (var element in listeler.listKur) {
//             await VeriIslemleri().kurEkle(element);
//           }
//           return "";
//         }
//       } else {
//         Exception('Kur verisi alınamadı. StatusCode: ${response.statusCode}');
//         return " Kurlar Getirilirken İstek Oluşturulamadı. " +
//             response.statusCode.toString();
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return "Kurlar için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   Future<String> getirCariAltHesap({required String sirket}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirAltHesap'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirAltHesap xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//     </GetirAltHesap>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           String modelNode = gelenHata.HataMesaj!;

//           Iterable? l;
//           String temizJson = temizleKontrolKarakterleri(modelNode);
//           try {
//             l = json.decode(temizJson);
//           } catch (e) {
//             print(e);
//           }

//           List<CariAltHesap> listcariTemp = [];
//           listcariTemp = List<CariAltHesap>.from(
//               l!.map((model) => CariAltHesap.fromJson(model)));

//           listeler.listCariAltHesap.clear();
//           await VeriIslemleri().cariAltHesapTabloTemizle();

//           listcariTemp.forEach((webservisCari) async {
//             await VeriIslemleri().cariAltHesapEkle(webservisCari);
//           });
//           await VeriIslemleri().cariAltHesapGetir();

//           return "";
//         }
//       } else {
//         Exception('Alt Hesaplar Alınamadı. StatusCode: ${response.statusCode}');
//         return " Cari Alt Hesaplar Getirilirken İstek Oluşturulamadı. " +
//             response.statusCode.toString();
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return " Cari Alt Hesaplar için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   /*

//   Future<String> getirCariAltHesap({required String sirket}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirCariAltHesap'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirCariAltHesap xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//     </GetirCariAltHesap>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));
//           listeler.listCariAltHesap.clear();
//           await VeriIslemleri().cariAltHesapTabloTemizle();

//           for (var element in jsonData) {
//             String KOD = element['KOD'];
//             String ALTHESAP = element['ALTHESAP'];
//             int DOVIZID = int.parse(element["DOVIZID"].toString());
//             String VARSAYILAN = element['VARSAYILAN'];

//             await VeriIslemleri().cariAltHesapEkle(CariAltHesap(
//                 KOD: KOD,
//                 ALTHESAP: ALTHESAP,
//                 DOVIZID: DOVIZID,
//                 VARSAYILAN: VARSAYILAN));

//             listeler.listCariAltHesap.add(CariAltHesap(
//                 KOD: KOD,
//                 ALTHESAP: ALTHESAP,
//                 DOVIZID: DOVIZID,
//                 VARSAYILAN: VARSAYILAN));
//           }

//           return "";
//         }
//       } else {
//         Exception('Alt Hesaplar Alınamadı. StatusCode: ${response.statusCode}');
//         return " Cari Alt Hesaplar Getirilirken İstek Oluşturulamadı. " +
//             response.statusCode.toString();
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return " Cari Alt Hesaplar için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }
//   */

//   Future<String> getirSubeDepo({required String sirket}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirSubeDepo'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirSubeDepo xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//     </GetirSubeDepo>
//   </soap:Body>
// </soap:Envelope>
// ''';
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));

//           List<SubeDepoModel> tempList = [];
//           jsonData.forEach((element) {
//             // int ID = int.parse(element['ID'].toString());
//             int SUBEID = int.parse(element['SUBEID'].toString());
//             int DEPOID = int.parse(element['DEPOID'].toString());
//             String SUBEADI = element['SUBEADI'];
//             String DEPOADI = element['DEPOADI'];

//             tempList.add(SubeDepoModel(
//                 SUBEID: SUBEID,
//                 DEPOID: DEPOID,
//                 SUBEADI: SUBEADI,
//                 DEPOADI: DEPOADI));
//           });
//           tempList.forEach((webservisSubeDepo) async {
//             int Index = listeler.listSubeDepoModel.indexWhere(
//                 (element) => element.SUBEID == webservisSubeDepo.SUBEID);
//             if (Index > -1) {
//               SubeDepoModel localSubeDepo =
//                   listeler.listSubeDepoModel.firstWhere(
//                 (element) => element.SUBEID == webservisSubeDepo.SUBEID,
//               );
//               webservisSubeDepo.ID = localSubeDepo.ID;
//               await VeriIslemleri().subeDepoGuncelle(webservisSubeDepo);
//             } else {
//               await VeriIslemleri().subeDepoEkle(webservisSubeDepo);
//             }
//           });
//           await VeriIslemleri().subeDepoGetir();
//           return "";
//         }
//       } else {
//         Exception(
//             'Sube-Depo verisi alınamadı. StatusCode: ${response.statusCode}');
//         return " Şube_Depo Getirilirken İstek Oluşturulamadı. " +
//             response.statusCode.toString();
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return " Şube_Depo için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   Future<String> kullaniciSayisiSorgula({
//     required String LisansNo,
//   }) async {
//     var url = Uri.parse('http://setuppro.opakyazilim.net/Service1.asmx');
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/MobilLisansSorgula'
//     };
//     String? privateID = await _getId();
//     print(privateID);

//     String body = '''<?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <MobilLisansSorgula xmlns="http://tempuri.org/">
//       <_MacAdres>$privateID</_MacAdres>
//       <_LisansNo>$LisansNo</_LisansNo>
//     </MobilLisansSorgula>
//   </soap:Body>
// </soap:Envelope>''';

//     try {
//       var response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         String jsonData = temizleKontrolKarakterleri(parsedXml.innerText);
//         if (jsonData == "OK") {
//           return jsonData;
//         } else {
//           return "";
//         }
//       } else {
//         print('SOAP isteği başarısız: ${response.statusCode}');
//         return " Kullanıcı Bilgileri Getirilirken İstek Oluşturulamadı. " +
//             response.statusCode.toString();
//       }
//     } catch (e) {
//       print('Hata: $e');
//       return " Kullanıcı bilgiler için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   Future<List<String>> makeSoapRequest(String lisansNumarasi) async {
//     var url = Uri.parse('http://setuppro.opakyazilim.net/Service1.asmx');
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirAPKServisIP'
//     };

//     var body = "<?xml version=\"1.0\" encoding=\"utf-8\"?>  " +
//         " <soap:Envelope xmlns:xsi=\"http:\/\/www.w3.org\/2001\/XMLSchema-instance\" xmlns:xsd=\"http:\/\/www.w3.org\/2001\/XMLSchema\" " +
//         " xmlns:soap=\"http:\/\/schemas.xmlsoap.org\/soap\/envelope\/\">" +
//         " <soap:Body>" +
//         "<GetirAPKServisIP xmlns=\"http:\/\/tempuri.org\/\">" +
//         "  <SipNo>$lisansNumarasi</SipNo>" +
//         "</GetirAPKServisIP>" +
//         " <\/soap:Body> " +
//         " <\/soap:Envelope> ";

//     try {
//       var response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         var tt = parseSoapResponse(response.body);
//         return tt;
//       } else {
//         print('SOAP isteği başarısız: ${response.statusCode}');
//         return [];
//       }
//     } catch (e) {
//       print('Hata: $e');
//       return [];
//     }
//   }

//   List<String> parseSoapResponse(String soapResponse) {
//     var document = xml.XmlDocument.parse(soapResponse);
//     var envelope = document.findAllElements('soap:Envelope').single;
//     var body = envelope.findElements('soap:Body').single;
//     var response = body.findElements('GetirAPKServisIPResponse').single;
//     var result = response.findElements('GetirAPKServisIPResult').single;
//     List<String> donecek = result.text.split("|");
//     return donecek;
//   }

//   Future<String> test(String IP) async {
//     // dış ve iç denecek;
//     var url = Uri.parse(IP);
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/WebServisTest'
//     };
//     String aa = "AAGENELOPAK";

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <WebServisTest xmlns="http://tempuri.org/">
//       <Sirket>$aa</Sirket>
//     </WebServisTest>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       var response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         printWrapped(parsedXml.innerText);
//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           String modelNode = gelenHata.HataMesaj!;
//           List<dynamic> parsedList = json.decode(modelNode);

//           Map<String, dynamic> kullaniciJson = parsedList[0];
//           Ctanim.kullanici = KullaniciModel.fromjson(kullaniciJson);
//           return "";
//         }
//       } else {
//         print('SOAP isteği başarısız: ${response.statusCode}');
//         return " Kullanıcı Bilgileri Getirilirken İstek Oluşturulamadı. " +
//             response.statusCode.toString();
//       }
//     } catch (e) {
//       print('Hata: $e');
//       return " Kullanıcı bilgiler için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   Future<String> getKullanicilar(
//       {required String kullaniciKodu,
//       required String sirket,
//       required String IP}) async {
//     var url = Uri.parse(IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirPlasiyerParam'
//     };

//     String body = '''<?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirPlasiyerParam xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <PlasiyerKod>$kullaniciKodu</PlasiyerKod>
//     </GetirPlasiyerParam>
//   </soap:Body>
// </soap:Envelope>''';

//     try {
//       var response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           String modelNode = gelenHata.HataMesaj!;
//           List<dynamic> parsedList =
//               json.decode(temizleKontrolKarakterleri(modelNode));

//           Map<String, dynamic> kullaniciJson = parsedList[0];
//           Ctanim.kullanici = KullaniciModel.fromjson(kullaniciJson);

//           await KullaniciModel.saveUser(Ctanim.kullanici!);

//           return "";
//         }
//       } else {
//         print('SOAP isteği başarısız: ${response.statusCode}');
//         return " Kullanıcı Bilgileri Getirilirken İstek Oluşturulamadı. " +
//             response.statusCode.toString();
//       }
//     } catch (e) {
//       print('Hata: $e');
//       return " Kullanıcı bilgiler için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   Future<String> getirCariKosul({required String sirket}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirCariKosul'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirCariKosul xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//     </GetirCariKosul>
//   </soap:Body>
// </soap:Envelope>
// ''';
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           await VeriIslemleri().CariKosulTemizle();

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));
//           List<CariKosulModel> tempList = [];
//           tempList = List<CariKosulModel>.from(
//               jsonData.map((model) => CariKosulModel.fromJson(model)));

//           tempList.forEach((webservisCariKosul) async {
//             await VeriIslemleri().cariKosulEkle(webservisCariKosul);
//           });

//           await VeriIslemleri().cariKosulGetir();
//           return "";
//         }
//       } else {
//         Exception(
//             'Cari Koşul verisi alınamadı. StatusCode: ${response.statusCode}');
//         return " Cari Koşul  Getirilirken İstek Oluşturulamadı. " +
//             response.statusCode.toString();
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return " Cari Koşul için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   Future<String> getirStokKosul({required String sirket}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirStokKosul'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirStokKosul xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//     </GetirStokKosul>
//   </soap:Body>
// </soap:Envelope>
// ''';
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           await VeriIslemleri().StokKosulTemizle();

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));
//           List<StokKosulModel> tempList = [];
//           tempList = List<StokKosulModel>.from(
//               jsonData.map((model) => StokKosulModel.fromJson(model)));

//           tempList.forEach((webservisStokKosul) async {
//             await VeriIslemleri().stokKosulEkle(webservisStokKosul);
//           });

//           await VeriIslemleri().stokKosulGetir();
//           return "";
//         }
//       } else {
//         Exception(
//             'Stok Kosul verisi alınamadı. StatusCode: ${response.statusCode}');
//         return " Stok Kosul Getirilirken İstek Oluşturulamadı. " +
//             response.statusCode.toString();
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return "Stok Kosul için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   Future<String> getirCariStokKosul({required String sirket}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirCariStokKosul'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirCariStokKosul xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//     </GetirCariStokKosul>
//   </soap:Body>
// </soap:Envelope>
// ''';
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           await VeriIslemleri().CariStokKosulTemizle();

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));

//           List<CariStokKosulModel> tempList = [];
//           tempList = List<CariStokKosulModel>.from(
//               jsonData.map((model) => CariStokKosulModel.fromJson(model)));

//           tempList.forEach((webservisCariStokKosul) async {
//             await VeriIslemleri().cariStokKosulEkle(webservisCariStokKosul);
//           });

//           await VeriIslemleri().cariStokKosulGetir();
//           return "";
//         }
//       } else {
//         Exception(
//             'Cari Stok Kosul verisi alınamadı. StatusCode: ${response.statusCode}');
//         return " Cari Stok Kosul Getirilirken İstek Oluşturulamadı. " +
//             response.statusCode.toString();
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return "Cari Stok Kosul için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   Future<String> getirFisNakliyeBilgileri({required String sirket}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirNakliyeBilgileri'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirNakliyeBilgileri xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//     </GetirNakliyeBilgileri>
//   </soap:Body>
// </soap:Envelope>
// ''';
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));

//           List<FisNakliye> tempList = [];
//           tempList = List<FisNakliye>.from(
//               jsonData.map((model) => FisNakliye.fromJson(model)));

//           await VeriIslemleri().fisNakliyeTemizle();

//           tempList.forEach((webservisCariStokKosul) async {
//             await VeriIslemleri()
//                 .fisNakliyeEkle(fisNakliye: webservisCariStokKosul);
//           });

//           await VeriIslemleri().fisNakliyeGetir();
//           return "";
//         }
//       } else {
//         Exception(
//             'Nakliye bilgileri alınamadı. StatusCode: ${response.statusCode}');
//         return " Nakliye bilgileri Getirilirken İstek Oluşturulamadı. " +
//             response.statusCode.toString();
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return "Nakliye bilgileri için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   Future<List<List<dynamic>>> getirFinansNakitDurum(
//       {required String sirket}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirFinansNakitDurum'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirFinansNakitDurum xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//     </GetirFinansNakitDurum>
//   </soap:Body>
// </soap:Envelope>
// ''';
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj],
//             [],
//             []
//           ];
//         } else {
//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));
//           List<String> keys = [];
//           List<String> values = [];
//           List<double> valuesDouble = [];
//           if (jsonData.isNotEmpty) {
//             jsonData[0].forEach((key, value) {
//               keys.add(key);
//               values.add(Ctanim.doubleToMusteriGorunumu(value));
//               valuesDouble.add(double.parse(value));
//             });
//           }
//           List<String> satirlar = [];
//           List<String> kolonlarIsimleri = [];
//           List<DataColumn> kolonlar = [DataColumn(label: Text(""))];
//           for (var element in keys) {
//             if (element.contains("Kasa")) {
//               String satir = element.substring(0, 4);
//               String kolon = element.substring(4);
//               if (!satirlar.contains(satir)) {
//                 satirlar.add(satir);
//               }
//               if (!kolonlarIsimleri.contains(kolon)) {
//                 kolonlar.add(DataColumn(label: Text(kolon)));
//                 kolonlarIsimleri.add(kolon);
//               }
//             } else if (element.contains("Banka")) {
//               String satir = element.substring(0, 5);
//               String kolon = element.substring(5);
//               if (!satirlar.contains(satir)) {
//                 satirlar.add(satir);
//               }
//               if (!kolonlarIsimleri.contains(kolon)) {
//                 kolonlar.add(DataColumn(label: Text(kolon)));
//                 kolonlarIsimleri.add(kolon);
//               }
//             } else if (element.contains("Pos")) {
//               String satir = element.substring(0, 3);
//               String kolon = element.substring(3);
//               if (!satirlar.contains(satir)) {
//                 satirlar.add(satir);
//               }
//               if (!kolonlarIsimleri.contains(kolon)) {
//                 kolonlar.add(DataColumn(label: Text(kolon)));
//                 kolonlarIsimleri.add(kolon);
//               }
//             } else if (element.contains("Çek")) {
//               String satir = element.substring(0, 3);
//               String kolon = element.substring(3);
//               if (!satirlar.contains(satir)) {
//                 satirlar.add(satir);
//               }
//               if (!kolonlarIsimleri.contains(kolon)) {
//                 kolonlar.add(DataColumn(label: Text(kolon)));
//                 kolonlarIsimleri.add(kolon);
//               }
//             } else if (element.contains("Senet")) {
//               String satir = element.substring(0, 5);
//               String kolon = element.substring(5);
//               if (!satirlar.contains(satir)) {
//                 satirlar.add(satir);
//               }
//               if (!kolonlarIsimleri.contains(kolon)) {
//                 kolonlar.add(DataColumn(label: Text(kolon)));
//                 kolonlarIsimleri.add(kolon);
//               }
//             }
//           }
//           print("Satirlar:");
//           for (var element in satirlar) {
//             print(element);
//           }
//           print("Kolonlar");
//           List<double> toplamlar = [];
//           int atlama = 0;
//           for (var element in kolonlarIsimleri) {
//             if (atlama > 0) {
//               atlama = atlama - (valuesDouble.length - 1);
//             }

//             double toplam = 0;
//             for (int i = 0; i < satirlar.length; i++) {
//               toplam +=
//                   double.parse(valuesDouble[atlama].toString()); //burda değll
//               atlama = atlama + kolonlar.length - 1;
//             }
//             toplamlar.add(toplam);
//           }
//           print("DEĞER TOPLAMLAR");
//           for (int i = 0; i < toplamlar.length; i++) {
//             Ctanim.pastaIcin.addAll({kolonlarIsimleri[i]: toplamlar[i]});
//           }

//           return [satirlar, kolonlar, values];
//         }
//       } else {
//         Exception(
//             'Nakit Durum Verisi Alınamadı. StatusCode: ${response.statusCode}');
//         return [
//           [
//             " Nakit Durum Verisi Getirilirken İstek Oluşturulamadı. " +
//                 response.statusCode.toString()
//           ],
//           [],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return [
//         [
//           "Nakit Durum için Webservisten veri çekilemedi. Hata Mesajı : " +
//               e.toString()
//         ],
//         [],
//         []
//       ];
//     }
//   }

//   Future<List<List<dynamic>>> getirFinansSatisDurum(
//       {required String sirket}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirFinansSatisDurum'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirFinansSatisDurum xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//     </GetirFinansSatisDurum>
//   </soap:Body>
// </soap:Envelope>
// ''';
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj],
//             [],
//             []
//           ];
//         } else {
//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));
//           List<String> keys = [];
//           List<String> values = [];
//           if (jsonData.isNotEmpty) {
//             jsonData[0].forEach((key, value) {
//               keys.add(key);
//               values.add(Ctanim.doubleToMusteriGorunumu(value));
//             });
//           }
//           List<String> satirlar = [];
//           List<String> kolonlarIsimleri = [];
//           List<DataColumn> kolonlar = [DataColumn(label: Text(""))];
//           for (var element in keys) {
//             satirlar.add(element);
//           }
//           kolonlar.add(DataColumn(label: Text("Toplam")));
//           print("Satirlar:");
//           for (var element in satirlar) {
//             print(element);
//           }
//           print("Kolonlar");
//           for (var element in kolonlar) {
//             print(element);
//           }

//           return [satirlar, kolonlar, values];
//         }
//       } else {
//         Exception(
//             'Satis Durum Verisi Alınamadı. StatusCode: ${response.statusCode}');
//         return [
//           [
//             " Satis Durum Verisi Getirilirken İstek Oluşturulamadı. " +
//                 response.statusCode.toString()
//           ],
//           [],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return [
//         [
//           "Satis Durum için Webservisten veri çekilemedi. Hata Mesajı : " +
//               e.toString()
//         ],
//         [],
//         []
//       ];
//     }
//   }

//   Future<List<List<dynamic>>> getirFinansSiparisTeklifDurum(
//       {required String sirket}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirFinansSiparisTeklifDurum'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirFinansSiparisTeklifDurum xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//     </GetirFinansSiparisTeklifDurum>
//   </soap:Body>
// </soap:Envelope>
// ''';
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj],
//             [],
//             []
//           ];
//         } else {
//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));
//           List<String> keys = [];
//           List<String> values = [];
//           if (jsonData.isNotEmpty) {
//             jsonData[0].forEach((key, value) {
//               keys.add(key);
//               values.add(Ctanim.doubleToMusteriGorunumu(value));
//             });
//           }
//           List<String> satirlar = [];
//           List<String> kolonlarIsimleri = [];
//           List<DataColumn> kolonlar = [DataColumn(label: Text(""))];
//           for (var element in keys) {
//             satirlar.add(element);
//           }
//           kolonlar.add(DataColumn(label: Text("Toplam")));
//           print("Satirlar:");
//           for (var element in satirlar) {
//             print(element);
//           }
//           print("Kolonlar");
//           for (var element in kolonlar) {
//             print(element);
//           }

//           return [satirlar, kolonlar, values];
//         }
//       } else {
//         Exception(
//             'Sipariş Teklif Durum Verisi Alınamadı. StatusCode: ${response.statusCode}');
//         return [
//           [
//             "Sipariş Teklif Durum Verisi Getirilirken İstek Oluşturulamadı. " +
//                 response.statusCode.toString()
//           ],
//           [],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return [
//         [
//           "Sipariş Teklif Durum için Webservisten veri çekilemedi. Hata Mesajı : " +
//               e.toString()
//         ],
//         [],
//         []
//       ];
//     }
//   }

//   Future<List<List<dynamic>>> getirFinansCekSenetDurum(
//       {required String sirket}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirFinansCekSenetDurum'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirFinansCekSenetDurum xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//     </GetirFinansCekSenetDurum>
//   </soap:Body>
// </soap:Envelope>
// ''';
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData = jsonDecode(parsedXml.innerText);
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj],
//             [],
//             []
//           ];
//         } else {
//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));
//           List<String> keys = [];
//           List<String> values = [];
//           if (jsonData.isNotEmpty) {
//             jsonData[0].forEach((key, value) {
//               keys.add(key);
//               values.add(Ctanim.doubleToMusteriGorunumu(value));
//             });
//           }
//           List<String> satirlar = [];
//           List<String> kolonlarIsimleri = [];
//           List<DataColumn> kolonlar = [DataColumn(label: Text(""))];
//           for (var element in keys) {
//             if (element.contains("Müşteri Çek")) {
//               String satir = element.substring(0, 12);
//               String kolon = element.substring(12);
//               if (!satirlar.contains(satir)) {
//                 satirlar.add(satir);
//               }
//               if (!kolonlarIsimleri.contains(kolon)) {
//                 kolonlar.add(DataColumn(label: Text(kolon)));
//                 kolonlarIsimleri.add(kolon);
//               }
//             } else if (element.contains("Müşteri Senet")) {
//               String satir = element.substring(0, 14);
//               String kolon = element.substring(14);
//               if (!satirlar.contains(satir)) {
//                 satirlar.add(satir);
//               }
//               if (!kolonlarIsimleri.contains(kolon)) {
//                 kolonlar.add(DataColumn(label: Text(kolon)));
//                 kolonlarIsimleri.add(kolon);
//               }
//             } else if (element.contains("Firma Çek")) {
//               String satir = element.substring(0, 10);
//               String kolon = element.substring(10);
//               if (!satirlar.contains(satir)) {
//                 satirlar.add(satir);
//               }
//               if (!kolonlarIsimleri.contains(kolon)) {
//                 kolonlar.add(DataColumn(label: Text(kolon)));
//                 kolonlarIsimleri.add(kolon);
//               }
//             } else if (element.contains("Firma Senet")) {
//               String satir = element.substring(0, 12);
//               String kolon = element.substring(12);
//               if (!satirlar.contains(satir)) {
//                 satirlar.add(satir);
//               }
//               if (!kolonlarIsimleri.contains(kolon)) {
//                 kolonlar.add(DataColumn(label: Text(kolon)));
//                 kolonlarIsimleri.add(kolon);
//               }
//             }
//           }
//           print("Satirlar:");
//           for (var element in satirlar) {
//             print(element);
//           }
//           print("Kolonlar");
//           for (var element in kolonlar) {
//             print(element);
//           }

//           return [satirlar, kolonlar, values];
//         }
//       } else {
//         Exception(
//             'Çek & Senet Durum Verisi Alınamadı. StatusCode: ${response.statusCode}');
//         return [
//           [
//             "Çek & Senet Durum Verisi Getirilirken İstek Oluşturulamadı. " +
//                 response.statusCode.toString()
//           ],
//           [],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return [
//         [
//           "Çek & Senet Durum için Webservisten veri çekilemedi. Hata Mesajı : " +
//               e.toString()
//         ],
//         [],
//         []
//       ];
//     }
//   }

//   Future<List<List<dynamic>>> getirFinansCariDurum(
//       {required String sirket}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirFinansCariDurum'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirFinansCariDurum xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//     </GetirFinansCariDurum>
//   </soap:Body>
// </soap:Envelope>
// ''';
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj],
//             [],
//             []
//           ];
//         } else {
//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));
//           List<String> keys = [];
//           List<String> values = [];
//           if (jsonData.isNotEmpty) {
//             jsonData[0].forEach((key, value) {
//               keys.add(key);
//               values.add(Ctanim.doubleToMusteriGorunumu(value));
//             });
//           }
//           List<String> satirlar = [];
//           List<String> kolonlarIsimleri = [];
//           List<DataColumn> kolonlar = [DataColumn(label: Text(""))];
//           for (var element in keys) {
//             if (element.contains("Bugün Vadeli Alacaklarım")) {
//               String satir = element.substring(0, 24);
//               String kolon = element.substring(24);
//               if (!satirlar.contains(satir)) {
//                 satirlar.add(satir);
//               }
//               if (!kolonlarIsimleri.contains(kolon)) {
//                 kolonlar.add(DataColumn(label: Text(kolon)));
//                 kolonlarIsimleri.add(kolon);
//               }
//             } else if (element.contains("Bugün Vadeli Borçlarım")) {
//               String satir = element.substring(0, 22);
//               String kolon = element.substring(22);
//               if (!satirlar.contains(satir)) {
//                 satirlar.add(satir);
//               }
//               if (!kolonlarIsimleri.contains(kolon)) {
//                 kolonlar.add(DataColumn(label: Text(kolon)));
//                 kolonlarIsimleri.add(kolon);
//               }
//             } else if (element.contains("Toplam Alacaklarım")) {
//               String satir = element.substring(0, 18);
//               String kolon = element.substring(18);
//               if (!satirlar.contains(satir)) {
//                 satirlar.add(satir);
//               }
//               if (!kolonlarIsimleri.contains(kolon)) {
//                 kolonlar.add(DataColumn(label: Text(kolon)));
//                 kolonlarIsimleri.add(kolon);
//               }
//             } else if (element.contains("Toplam Borçlarım")) {
//               String satir = element.substring(0, 16);
//               String kolon = element.substring(16);
//               if (!satirlar.contains(satir)) {
//                 satirlar.add(satir);
//               }
//               if (!kolonlarIsimleri.contains(kolon)) {
//                 kolonlar.add(DataColumn(label: Text(kolon)));
//                 kolonlarIsimleri.add(kolon);
//               }
//             }
//           }

//           print("Satirlar:");
//           for (var element in satirlar) {
//             print(element);
//           }
//           print("Kolonlar");
//           for (var element in kolonlar) {
//             print(element);
//           }

//           return [satirlar, kolonlar, values];
//         }
//       } else {
//         Exception(
//             'Cari Durum Verisi Alınamadı. StatusCode: ${response.statusCode}');
//         return [
//           [
//             "Cari Durum Verisi Getirilirken İstek Oluşturulamadı. " +
//                 response.statusCode.toString()
//           ],
//           [],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return [
//         [
//           "Cari Durum için Webservisten veri çekilemedi. Hata Mesajı : " +
//               e.toString()
//         ],
//         [],
//         []
//       ];
//     }
//   }

//   void printWrapped(String text) {
//     final pattern = RegExp('.{1,1000}');
//     pattern.allMatches(text).forEach((match) => print(match.group(0)));
//   }

//   Future<SHataModel> ekleFatura(
//       {required String sirket,
//       required Map<String, dynamic> jsonDataList}) async {
//     SHataModel hata = SHataModel(Hata: "true", HataMesaj: "Veri Gönderilemedi");

//     var jsonString;
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;

//     jsonString = jsonEncode(jsonDataList);

//     printWrapped(jsonString);

//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/EkleFatura',
//     };
//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <EkleFatura xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <Fis>$jsonString</Fis>
//     </EkleFatura>
//   </soap:Body>
// </soap:Envelope>
// ''';
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData = jsonDecode(parsedXml.innerText);
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         print(jsonString);
//         return gelenHata;
//       } else {
//         Exception(
//             'Fatura Verisi Gönderilemedi. StatusCode: ${response.statusCode}');
//         return hata;
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return hata;
//     }
//   }

//   Future<SHataModel> ekleDat(
//       {required String sirket,
//       required Map<String, dynamic> jsonDataList}) async {
//     SHataModel hata = SHataModel(Hata: "true", HataMesaj: "Veri Gönderilemedi");

//     var jsonString;
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;

//     jsonString = jsonEncode(jsonDataList);

//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/EkleDat',
//     };
//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <EkleDat xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <Dat>$jsonString</Dat>
//     </EkleDat>
//   </soap:Body>
// </soap:Envelope>
// ''';
//     printWrapped(jsonString);
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData = jsonDecode(parsedXml.innerText);
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         return gelenHata;
//       } else {
//         Exception(
//             'Fatura Verisi Gönderilemedi. StatusCode: ${response.statusCode}');
//         return hata;
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return hata;
//     }
//   }

//   Future<SHataModel> ekleTahsilat(
//       {required String sirket,
//       required Map<String, dynamic> jsonDataList}) async {
//     SHataModel hata = SHataModel(Hata: "true", HataMesaj: "Veri Gönderilemedi");

//     var jsonString;
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;

//     jsonString = jsonEncode(jsonDataList);

//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/EkleTahsilat',
//     };
//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <EkleTahsilat xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <Tahsilat>$jsonString</Tahsilat>
//     </EkleTahsilat>
//   </soap:Body>
// </soap:Envelope>
// ''';
//     print("Tahsilat Ekleme");
//     printWrapped(jsonString);
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData = jsonDecode(parsedXml.innerText);
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         return gelenHata;
//       } else {
//         Exception(
//             'Tahsilat Verisi Gönderilemedi. StatusCode: ${response.statusCode}');
//         return hata;
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return hata;
//     }
//   }

//   Future<String> getirOlcuBirim({required String sirket}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirOlcuBirim'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirOlcuBirim xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//     </GetirOlcuBirim>
//   </soap:Body>
// </soap:Envelope>
// ''';
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           await VeriIslemleri().olcuBirimTemizle();
//           listeler.listOlcuBirim.clear();

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));

//           listeler.listOlcuBirim = List<OlcuBirimModel>.from(
//               jsonData.map((model) => OlcuBirimModel.fromJson(model)));

//           listeler.listOlcuBirim.forEach((webservisCariStokKosul) async {
//             await VeriIslemleri().olcuBirimEkle(webservisCariStokKosul);
//           });
//           return "";
//         }
//       } else {
//         Exception(
//             'Ölçü Birim verisi alınamadı. StatusCode: ${response.statusCode}');
//         return 'Ölçü Birim Verisi Alınamadı. StatusCode: ${response.statusCode}';
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return "Ölçü Birim için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   Future<SHataModel> ekleSayim(
//       {required String sirket,
//       required Map<String, dynamic> jsonDataList}) async {
//     SHataModel hata = SHataModel(Hata: "true", HataMesaj: "Veri Gönderilemedi");

//     var jsonString;
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;

//     jsonString = jsonEncode(jsonDataList);

//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/EkleSayim',
//     };
//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <EkleSayim xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <Dat>$jsonString</Dat>
//     </EkleSayim>
//   </soap:Body>
// </soap:Envelope>
// ''';
//     printWrapped(jsonString);
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData = jsonDecode(parsedXml.innerText);
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         return gelenHata;
//       } else {
//         Exception(
//             'Sayım Verisi Gönderilemedi. StatusCode: ${response.statusCode}');
//         return hata;
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return hata;
//     }
//   }

//   Future<String?> getirRaf({required String sirket}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirRaf'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirRaf xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//     </GetirRaf>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj;
//         } else {
//           await VeriIslemleri().rafTemizle();
//           listeler.listRaf.clear();

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));

//           jsonData.forEach((element) async {
//             String RAF = element['RAF'];

//             listeler.listRaf.add(RafModel(RAF: RAF));
//             await VeriIslemleri().rafEkle(RafModel(RAF: RAF));
//           });

//           return "";
//         }
//       } else {
//         Exception('Raf Bilgisi Alınamadı. StatusCode: ${response.statusCode}');
//         return 'Raf Bilgisi Alınamadı. StatusCode: ${response.statusCode}';
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return "Raf Bilgisi için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   Future<List<List<dynamic>>> getirGenelRapor(
//       {required String sirket,
//       required String kullaniciKodu,
//       required String fonksiyonAdi}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/$fonksiyonAdi'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <$fonksiyonAdi xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <PlasiyerKod>$kullaniciKodu</PlasiyerKod>
      
//     </$fonksiyonAdi>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj],
//             []
//           ];
//         } else {
//           List<DataColumn> kolonlar = [];
//           List<String> satirlar = [];
//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));
//           try {
//             if (jsonData.isNotEmpty) {
//               jsonData[0].forEach((key, value) {
//                 kolonlar.add(DataColumn(label: Text(key)));
//               });
//               for (int i = 0; i < jsonData.length; i++) {
//                 jsonData[i].forEach((key, value) {
//                   satirlar.add(value.toString());
//                 });
//               }
//             }
//           } catch (e) {
//             print(e);
//           }

//           print(kolonlar.length);
//           print(satirlar.length);

//           return [satirlar, kolonlar];
//         }
//       } else {
//         Exception(fonksiyonAdi.toString() +
//             'için Genel Rapor Bilgisi Alınamadı. StatusCode: ${response.statusCode}');

//         return [
//           [
//             fonksiyonAdi.toString() +
//                 'için Genel Rapor Bilgisi Alınamadı. StatusCode: ${response.statusCode}'
//           ],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return [
//         [
//           fonksiyonAdi.toString() +
//               " için  Webservisten veri çekilemedi. Hata Mesajı : " +
//               e.toString()
//         ],
//         []
//       ];
//     }
//   }

//   Future<List<List<String>>> getirCariBakiyeRapor({
//     required String sirket,
//     required String kullaniciKodu,
//   }) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/RaporCariBakiye'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <RaporCariBakiye xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <PlasiyerKod>$kullaniciKodu</PlasiyerKod>
      
//     </RaporCariBakiye>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj!],
//             []
//           ];
//         } else {
//           List<String> kolonlar = [];
//           List<String> satirlar = [];
//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));
//           try {
//             if (jsonData.isNotEmpty) {
//               jsonData[0].forEach((key, value) {
//                 kolonlar.add(key);
//               });
//               for (int i = 0; i < jsonData.length; i++) {
//                 jsonData[i].forEach((key, value) {
//                   satirlar.add(value.toString());
//                 });
//               }
//             }
//           } catch (e) {
//             print(e);
//           }

//           print(kolonlar.length);
//           print(satirlar.length);

//           return [satirlar, kolonlar];
//         }
//       } else {
//         Exception(
//             "RaporCariBakiye için Genel Rapor Bilgisi Alınamadı. StatusCode: ${response.statusCode}");

//         return [
//           [
//             "RaporCariBakiye için Genel Rapor Bilgisi Alınamadı. StatusCode: ${response.statusCode}"
//           ],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return [
//         [
//           "RaporCariBakiye için  Webservisten veri çekilemedi. Hata Mesajı : $e"
//         ],
//         []
//       ];
//     }
//   }

//   Future<List<List<dynamic>>> getirKapatilmamisFaturalarRapor({
//     required String sirket,
//     required String cariKodu,
//   }) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/RaporKapatilmamisFaturalar'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <RaporKapatilmamisFaturalar xmlns="http://tempuri.org/">
//       <CariKodu>$cariKodu</CariKodu>
//       <Sirket>$sirket</Sirket>
//     </RaporKapatilmamisFaturalar>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj],
//             []
//           ];
//         } else {
//           List<DataColumn> kolonlar = [];
//           List<String> satirlar = [];

//           if (gelenHata.Hata == "false" && gelenHata.HataMesaj == "") {
//             return [
//               ["Veri Bulunamadı"],
//               []
//             ];
//           }

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));

//           try {
//             if (jsonData.isNotEmpty) {
//               jsonData[0].forEach((key, value) {
//                 kolonlar.add(DataColumn(label: Text(key)));
//               });
//               for (int i = 0; i < jsonData.length; i++) {
//                 jsonData[i].forEach((key, value) {
//                   satirlar.add(value.toString());
//                 });
//               }
//             }
//           } catch (e) {
//             print(e);
//           }

//           print(kolonlar.length);
//           print(satirlar.length);

//           return [satirlar, kolonlar];
//         }
//       } else {
//         Exception(
//             'Kapatılmamış Faturalar Alınamadı. StatusCode: ${response.statusCode}');

//         return [
//           [
//             'Kapatılmamış Faturalar Alınamadı. StatusCode: ${response.statusCode}'
//           ],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return [
//         [
//           "Kapatılmamış Faturalar için Webservisten veri çekilemedi. Hata Mesajı : " +
//               e.toString()
//         ],
//         []
//       ];
//     }
//   }

//   Future<List<List<dynamic>>> getirValorRapor({
//     required String sirket,
//     required String cariKodu,
//   }) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/RaporValor'
//     };

//     String body = '''
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <RaporValor xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <Cari_Kodu>$cariKodu</Cari_Kodu>
//     </RaporValor>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj],
//             []
//           ];
//         } else {
//           List<DataColumn> kolonlar = [];
//           List<String> satirlar = [];

//           if (gelenHata.Hata == "false" && gelenHata.HataMesaj == "") {
//             return [
//               ["Veri Bulunamadı"],
//               []
//             ];
//           }

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));

//           try {
//             if (jsonData.isNotEmpty) {
//               jsonData[0].forEach((key, value) {
//                 kolonlar.add(DataColumn(label: Text(key)));
//               });
//               for (int i = 0; i < jsonData.length; i++) {
//                 jsonData[i].forEach((key, value) {
//                   satirlar.add(value.toString());
//                 });
//               }
//             }
//           } catch (e) {
//             print(e);
//           }

//           print(kolonlar.length);
//           print(satirlar.length);

//           return [satirlar, kolonlar];
//         }
//       } else {
//         Exception('Valor Rapor Alınamadı. StatusCode: ${response.statusCode}');

//         return [
//           ['Valor Rapor  Alınamadı. StatusCode: ${response.statusCode}'],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return [
//         [
//           "Valor Rapor  için Webservisten veri çekilemedi. Hata Mesajı : " +
//               e.toString()
//         ],
//         []
//       ];
//     }
//   }

//   Future<List<List<String>>> getirBekleyenSiparisRapor(
//       {required String sirket,
//       required String cariKodu,
//       required String basTar,
//       required String bitTar,
//       required String kullaniciKodu}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/RaporBekleyenSiparis'
//     };
//     String gecBasTar = '2023-01-01';
//     String gecBitTar = '2023-12-12';

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <RaporBekleyenSiparis xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <Cari_Kodu>$cariKodu</Cari_Kodu>
//       <Bastar>$basTar</Bastar>
//       <Bittar>$bitTar</Bittar>
//       <kulkodu>$kullaniciKodu</kulkodu>
//     </RaporBekleyenSiparis>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj!],
//             []
//           ];
//         } else {
//           List<String> kolonlar = [];
//           List<String> satirlar = [];

//           if (gelenHata.Hata == "false" && gelenHata.HataMesaj == "") {
//             return [
//               ["Veri Bulunamadı"],
//               []
//             ];
//           }

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));

//           try {
//             if (jsonData.isNotEmpty) {
//               jsonData[0].forEach((key, value) {
//                 kolonlar.add(key);
//               });
//               for (int i = 0; i < jsonData.length; i++) {
//                 jsonData[i].forEach((key, value) {
//                   satirlar.add(value.toString());
//                 });
//               }
//             }
//           } catch (e) {
//             print(e);
//           }

//           print(kolonlar.length);
//           print(satirlar.length);

//           return [satirlar, kolonlar];
//         }
//       } else {
//         Exception(
//             'Bekleyen Sipariş Raporları Alınamadı. StatusCode: ${response.statusCode}');

//         return [
//           [
//             'Bekleyen Sipariş Raporları  Alınamadı. StatusCode: ${response.statusCode}'
//           ],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return [
//         [
//           "Bekleyen Sipariş Raporları  için Webservisten veri çekilemedi. Hata Mesajı : " +
//               e.toString()
//         ],
//         []
//       ];
//     }
//   }

//   Future<List<List<String>>> getirMusteriSiparisRapor(
//       {required String sirket,
//       required String cariKodu,
//       required String basTar,
//       required String bitTar}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/RaporMusteriSiparisListesi'
//     };
//     String tempBasTar = "2023-01-01", tempBitTar = "2023-07-04";
//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <RaporMusteriSiparisListesi xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <Cari_Kodu>$cariKodu</Cari_Kodu>
//       <Bastar>$basTar</Bastar>
//       <Bittar>$bitTar</Bittar>
//     </RaporMusteriSiparisListesi>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj!],
//             []
//           ];
//         } else {
//           List<String> kolonlar = [];
//           List<String> satirlar = [];

//           if (gelenHata.Hata == "false" && gelenHata.HataMesaj == "") {
//             return [
//               ["Veri Bulunamadı"],
//               []
//             ];
//           }

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));

//           try {
//             if (jsonData.isNotEmpty) {
//               jsonData[0].forEach((key, value) {
//                 kolonlar.add(key);
//               });
//               for (int i = 0; i < jsonData.length; i++) {
//                 jsonData[i].forEach((key, value) {
//                   satirlar.add(value.toString());
//                 });
//               }
//             }
//           } catch (e) {
//             print(e);
//           }

//           print(kolonlar.length);
//           print(satirlar.length);

//           return [satirlar, kolonlar];
//         }
//       } else {
//         Exception(
//             'Müşteri Sipariş Rapor Alınamadı. StatusCode: ${response.statusCode}');

//         return [
//           [
//             'Müşteri Sipariş Rapor Alınamadı. StatusCode: ${response.statusCode}'
//           ],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return [
//         [
//           "Müşteri Sipariş Rapor için Webservisten veri çekilemedi. Hata Mesajı : " +
//               e.toString()
//         ],
//         []
//       ];
//     }
//   }

//   Future<List<List<dynamic>>> getirMusteriSiparisDetayRapor({
//     required String sirket,
//     required String faturaID,
//   }) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/RaporMusteriSiparisListesiDetay'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <RaporMusteriSiparisListesiDetay xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <Fatura>$faturaID</Fatura>
//     </RaporMusteriSiparisListesiDetay>
//   </soap:Body>
// </soap:Envelope>
// ''';
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj],
//             []
//           ];
//         } else {
//           List<DataColumn> kolonlar = [];
//           List<String> satirlar = [];

//           if (gelenHata.Hata == "false" && gelenHata.HataMesaj == "") {
//             return [
//               ["Veri Bulunamadı"],
//               []
//             ];
//           }

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));

//           try {
//             if (jsonData.isNotEmpty) {
//               jsonData[0].forEach((key, value) {
//                 kolonlar.add(DataColumn(label: Text(key)));
//               });
//               for (int i = 0; i < jsonData.length; i++) {
//                 jsonData[i].forEach((key, value) {
//                   satirlar.add(value.toString());
//                 });
//               }
//             }
//           } catch (e) {
//             print(e);
//           }

//           print(kolonlar.length);
//           print(satirlar.length);

//           return [satirlar, kolonlar];
//         }
//       } else {
//         Exception(
//             'Musteri Siparis Detay Rapor Alınamadı. StatusCode: ${response.statusCode}');

//         return [
//           [
//             'Musteri Siparis Detay Rapor Alınamadı. StatusCode: ${response.statusCode}'
//           ],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return [
//         [
//           "Musteri Siparis Detay Rapor için Webservisten veri çekilemedi. Hata Mesajı : " +
//               e.toString()
//         ],
//         []
//       ];
//     }
//   }

//   Future<List<List<String>>> getirAlisFaturaRapor({
//     required String sirket,
//     required String cariKodu,
//     required String basTar,
//     required String bitTar,
//   }) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/RaporAlisFaturaListesi'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <RaporAlisFaturaListesi xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <Cari_Kodu>$cariKodu</Cari_Kodu>
//       <Bastar>$basTar</Bastar>
//       <Bittar>$bitTar</Bittar>
//     </RaporAlisFaturaListesi>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj!],
//             []
//           ];
//         } else {
//           List<String> kolonlar = [];
//           List<String> satirlar = [];

//           if (gelenHata.Hata == "false" && gelenHata.HataMesaj == "") {
//             return [
//               ["Veri Bulunamadı"],
//               []
//             ];
//           }

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));

//           try {
//             if (jsonData.isNotEmpty) {
//               jsonData[0].forEach((key, value) {
//                 kolonlar.add(key);
//               });
//               for (int i = 0; i < jsonData.length; i++) {
//                 jsonData[i].forEach((key, value) {
//                   satirlar.add(value.toString());
//                 });
//               }
//             }
//           } catch (e) {
//             print(e);
//           }

//           print(kolonlar.length);
//           print(satirlar.length);

//           return [satirlar, kolonlar];
//         }
//       } else {
//         Exception(
//             'Alis Fatura Rapor Alınamadı. StatusCode: ${response.statusCode}');

//         return [
//           ['Alis Fatura Rapor  Alınamadı. StatusCode: ${response.statusCode}'],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return [
//         [
//           "Alis Fatura Rapor  için Webservisten veri çekilemedi. Hata Mesajı : " +
//               e.toString()
//         ],
//         []
//       ];
//     }
//   }

//   Future<List<List<String>>> getirSatisFaturaRapor(
//       {required String sirket,
//       required String cariKodu,
//       required String basTar,
//       required String bitTar}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/RaporSatisFaturaListesi'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <RaporSatisFaturaListesi xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <Cari_Kodu>$cariKodu</Cari_Kodu>
//       <Bastar>$basTar</Bastar>
//       <Bittar>$bitTar</Bittar>
//     </RaporSatisFaturaListesi>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj!],
//             []
//           ];
//         } else {
//           List<String> kolonlar = [];
//           List<String> satirlar = [];

//           if (gelenHata.Hata == "false" && gelenHata.HataMesaj == "") {
//             return [
//               ["Veri Bulunamadı"],
//               []
//             ];
//           }

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));

//           try {
//             if (jsonData.isNotEmpty) {
//               jsonData[0].forEach((key, value) {
//                 kolonlar.add(key);
//               });
//               for (int i = 0; i < jsonData.length; i++) {
//                 jsonData[i].forEach((key, value) {
//                   satirlar.add(value.toString());
//                 });
//               }
//             }
//           } catch (e) {
//             print(e);
//           }

//           print(kolonlar.length);
//           print(satirlar.length);

//           return [satirlar, kolonlar];
//         }
//       } else {
//         Exception(
//             'Satis Fatura Rapor Alınamadı. StatusCode: ${response.statusCode}');

//         return [
//           ['Satis Fatura Rapor Alınamadı. StatusCode: ${response.statusCode}'],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return [
//         [
//           "Satis Fatura Rapor için Webservisten veri çekilemedi. Hata Mesajı : " +
//               e.toString()
//         ],
//         []
//       ];
//     }
//   }

//   Future<List<List<dynamic>>> getirFaturaDetayRapor({
//     required String sirket,
//     required String faturaID,
//   }) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/RaporFaturaListesiDetay'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <RaporFaturaListesiDetay xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <Fatura>$faturaID</Fatura>
//     </RaporFaturaListesiDetay>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj],
//             []
//           ];
//         } else {
//           List<DataColumn> kolonlar = [];
//           List<String> satirlar = [];

//           if (gelenHata.Hata == "false" && gelenHata.HataMesaj == "") {
//             return [
//               ["Veri Bulunamadı"],
//               []
//             ];
//           }

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));

//           try {
//             if (jsonData.isNotEmpty) {
//               jsonData[0].forEach((key, value) {
//                 kolonlar.add(DataColumn(label: Text(key)));
//               });
//               for (int i = 0; i < jsonData.length; i++) {
//                 jsonData[i].forEach((key, value) {
//                   satirlar.add(value.toString());
//                 });
//               }
//             }
//           } catch (e) {
//             print(e);
//           }

//           print(kolonlar.length);
//           print(satirlar.length);

//           return [satirlar, kolonlar];
//         }
//       } else {
//         Exception(
//             'Fatura Detay Rapor Alınamadı. StatusCode: ${response.statusCode}');

//         return [
//           ['Fatura Detay Rapor  Alınamadı. StatusCode: ${response.statusCode}'],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return [
//         [
//           "Fatura Detay Rapor  için Webservisten veri çekilemedi. Hata Mesajı : " +
//               e.toString()
//         ],
//         []
//       ];
//     }
//   }

//   Future<List<List<String>>> getirBekleyenSiparisIrsaliyeRapor({
//     required String sirket,
//     required String cariKodu,
//     required String basTar,
//     required String bitTar,
//   }) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/RaporBekleyenSiparisIrsaliyeleri'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <RaporBekleyenSiparisIrsaliyeleri xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <Cari_Kod>$cariKodu</Cari_Kod>
//       <Bastar>$basTar</Bastar>
//       <Bittar>$bitTar</Bittar>
//     </RaporBekleyenSiparisIrsaliyeleri>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj!],
//             []
//           ];
//         } else {
//           List<String> kolonlar = [];
//           List<String> satirlar = [];

//           if (gelenHata.Hata == "false" && gelenHata.HataMesaj == "") {
//             return [
//               ["Veri Bulunamadı"],
//               []
//             ];
//           }

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));

//           try {
//             if (jsonData.isNotEmpty) {
//               jsonData[0].forEach((key, value) {
//                 kolonlar.add(key);
//               });
//               for (int i = 0; i < jsonData.length; i++) {
//                 jsonData[i].forEach((key, value) {
//                   satirlar.add(value.toString());
//                 });
//               }
//             }
//           } catch (e) {
//             print(e);
//           }

//           print(kolonlar.length);
//           print(satirlar.length);

//           return [satirlar, kolonlar];
//         }
//       } else {
//         Exception(
//             'Bekleyen Siparis Irsaliye Rapor Alınamadı. StatusCode: ${response.statusCode}');

//         return [
//           [
//             'Bekleyen Siparis Irsaliye Rapor Alınamadı. StatusCode: ${response.statusCode}'
//           ],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return [
//         [
//           "Bekleyen Siparis Irsaliye Rapor için Webservisten veri çekilemedi. Hata Mesajı : " +
//               e.toString()
//         ],
//         []
//       ];
//     }
//   }

//   Future<List<List<dynamic>>> getirIrsaliyeDetayRapor({
//     required String sirket,
//     required String faturaID,
//   }) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/RaporIrsaliyeListesiDetay'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <RaporIrsaliyeListesiDetay xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <Fatura>$faturaID</Fatura>
//     </RaporIrsaliyeListesiDetay>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj],
//             []
//           ];
//         } else {
//           List<DataColumn> kolonlar = [];
//           List<String> satirlar = [];

//           if (gelenHata.Hata == "false" && gelenHata.HataMesaj == "") {
//             return [
//               ["Veri Bulunamadı"],
//               []
//             ];
//           }

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));

//           try {
//             if (jsonData.isNotEmpty) {
//               jsonData[0].forEach((key, value) {
//                 kolonlar.add(DataColumn(label: Text(key)));
//               });
//               for (int i = 0; i < jsonData.length; i++) {
//                 jsonData[i].forEach((key, value) {
//                   satirlar.add(value.toString());
//                 });
//               }
//             }
//           } catch (e) {
//             print(e);
//           }

//           print(kolonlar.length);
//           print(satirlar.length);

//           return [satirlar, kolonlar];
//         }
//       } else {
//         Exception(
//             'Irsaliye Detay Rapor Alınamadı. StatusCode: ${response.statusCode}');

//         return [
//           [
//             'Irsaliye Detay Rapor Alınamadı. StatusCode: ${response.statusCode}'
//           ],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return [
//         [
//           "Irsaliye Detay Rapor için Webservisten veri çekilemedi. Hata Mesajı : " +
//               e.toString()
//         ],
//         []
//       ];
//     }
//   }

//   Future<List<List<String>>> getirSatisIrsaliyeRapor({
//     required String sirket,
//     required String cariKodu,
//     required String basTar,
//     required String bitTar,
//   }) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/RaporSatisIrsaliyeListesi'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <RaporSatisIrsaliyeListesi xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <Cari_Kodu>$cariKodu</Cari_Kodu>
//       <Bastar>$basTar</Bastar>
//       <Bittar>$bitTar</Bittar>
//     </RaporSatisIrsaliyeListesi>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj!],
//             []
//           ];
//         } else {
//           List<String> kolonlar = [];
//           List<String> satirlar = [];

//           if (gelenHata.Hata == "false" && gelenHata.HataMesaj == "") {
//             return [
//               ["Veri Bulunamadı"],
//               []
//             ];
//           }

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));

//           try {
//             if (jsonData.isNotEmpty) {
//               jsonData[0].forEach((key, value) {
//                 kolonlar.add(key);
//               });
//               for (int i = 0; i < jsonData.length; i++) {
//                 jsonData[i].forEach((key, value) {
//                   satirlar.add(value.toString());
//                 });
//               }
//             }
//           } catch (e) {
//             print(e);
//           }

//           print(kolonlar.length);
//           print(satirlar.length);

//           return [satirlar, kolonlar];
//         }
//       } else {
//         Exception(
//             'Satis Irsaliye Rapor Alınamadı. StatusCode: ${response.statusCode}');

//         return [
//           [
//             'Satis Irsaliye Rapor Alınamadı. StatusCode: ${response.statusCode}'
//           ],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return [
//         [
//           "Satis Irsaliye Rapor için Webservisten veri çekilemedi. Hata Mesajı : " +
//               e.toString()
//         ],
//         []
//       ];
//     }
//   }
//   // jkldahfkljsdşlfjkşlodskfksd

//   Future<String> getirPlasiyerYetki({
//     required String sirket,
//     required String kullaniciKodu,
//     required String IP,
//   }) async {
//     var url = Uri.parse(IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirPlasiyeYetki'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirPlasiyeYetki xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <PlasiyerKod>$kullaniciKodu</PlasiyerKod>
//     </GetirPlasiyeYetki>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData = jsonDecode(parsedXml.innerText);
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           if (gelenHata.Hata == "false" && gelenHata.HataMesaj == "") {
//             return "Veri Bulunamadı";
//           }
//           String modelNode = gelenHata.HataMesaj!;
//           Iterable l = json.decode(modelNode);
//           listeler.yetki.clear();

//           listeler.yetki = List<KullaniciYetki>.from(
//               l.map((model) => KullaniciYetki.fromJson(model)));

//           for (var element in listeler.yetki) {
//             print(element);
//             bool sonBool;
//             if (element.deger == "False") {
//               sonBool = false;
//             } else {
//               sonBool = true;
//             }
//             listeler.plasiyerYetkileri.removeAt(element.sira!);
//             listeler.plasiyerYetkileri.insert(element.sira!, sonBool);
//           }
//           await SharedPrefsHelper.yetkiKaydet(
//               listeler.plasiyerYetkileri, "yetkiler");

//           return "";
//         }
//       } else {
//         Exception(
//             'Plasiyer Yetki Alınamadı. StatusCode: ${response.statusCode}');

//         return 'Plasiyer Yetki Alınamadı. StatusCode: ${response.statusCode}';
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return "Plasiyer Yetki için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   Future<String> getirDahaFazlaBarkod(
//       {required String sirket, required String kullaniciKodu}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirStokBarkod'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirStokBarkod xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <PlasiyerKod>$kullaniciKodu</PlasiyerKod>
//     </GetirStokBarkod>
//   </soap:Body>
// </soap:Envelope>
// ''';
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           List<dynamic> jsonData = jsonDecode(gelenHata.HataMesaj!);

//           List<DahaFazlaBarkod> tempList = List<DahaFazlaBarkod>.from(
//               jsonData.map((model) => DahaFazlaBarkod.fromJson(model)));

//           print(e);

//           tempList.forEach((barkodlar) async {
//             int Index = listeler.listDahaFazlaBarkod
//                 .indexWhere((element) => element.BARKOD == barkodlar.BARKOD);
//             if (Index > -1) {
//               DahaFazlaBarkod localstok =
//                   listeler.listDahaFazlaBarkod.firstWhere(
//                 (element) => element.BARKOD == barkodlar.BARKOD,
//               );
//               barkodlar.BARKOD = localstok.BARKOD;
//               await VeriIslemleri().dahaFazlaBarkodGuncelle(barkodlar);
//             } else {
//               await VeriIslemleri().dahaFazlaBarkodEkle(barkodlar);
//             }
//           });
//           await VeriIslemleri().dahaFazlaBarkodGetir();
//           return "";
//         }
//       } else {
//         Exception(
//             'Daha Fazla Barkod verisi alınamadı. StatusCode: ${response.statusCode}');
//         return 'Daha Fazla Barkod Alınamadı. StatusCode: ${response.statusCode}';
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return "Daha Fazla Barkod için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   Future<String> getirPlasiyerBanka(
//       {required String sirket, required String kullaniciKodu}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirPlasiyerBanka'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirPlasiyerBanka xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <PlasiyerKod>$kullaniciKodu</PlasiyerKod>
//     </GetirPlasiyerBanka>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response =
//           await http.post(url, headers: headers, body: body);

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           listeler.listBankaModel.clear();
//           await VeriIslemleri().plasiyerBankaTemizle();

//           String modelNode = gelenHata.HataMesaj!;
//           Iterable l = json.decode(modelNode);

//           listeler.listBankaModel = List<BankaModel>.from(
//               l.map((model) => BankaModel.fromJson(model)));

//           for (var element in listeler.listBankaModel) {
//             await VeriIslemleri().plasiyerBankaEkle(element);
//           }
//           return "";
//         }
//       } else {
//         Exception('Banka verisi alınamadı. StatusCode: ${response.statusCode}');
//         return " Bankalar Getirilirken İstek Oluşturulamadı. " +
//             response.statusCode.toString();
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return "Bankalar için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   Future<String> getirPlasiyerBankaSozlesme(
//       {required String sirket, required String kullaniciKodu}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirPlasiyerBankaSozlesme'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirPlasiyerBankaSozlesme xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <PlasiyerKod>$kullaniciKodu</PlasiyerKod>
//     </GetirPlasiyerBankaSozlesme>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response =
//           await http.post(url, headers: headers, body: body);

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           listeler.listBankaSozlesmeModel.clear();
//           await VeriIslemleri().plasiyerBankaSozlesmeTemizle();

//           String modelNode = gelenHata.HataMesaj!;
//           Iterable l = json.decode(modelNode);

//           listeler.listBankaSozlesmeModel = List<BankaSozlesmeModel>.from(
//               l.map((model) => BankaSozlesmeModel.fromJson(model)));

//           for (var element in listeler.listBankaSozlesmeModel) {
//             await VeriIslemleri().plasiyerBankaSozlesmeEkle(element);
//           }
//           return "";
//         }
//       } else {
//         Exception(
//             'Banka Sozlesme verisi alınamadı. StatusCode: ${response.statusCode}');
//         return " Bankaların Sozlesmeleri Getirilirken İstek Oluşturulamadı. " +
//             response.statusCode.toString();
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return "Bankalarleriın Sozlesme için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   Future<List<List<String>>> getirCariEkstre({
//     required List<String> altHesaplar,
//     required List<String> islemTipler,
//     required String sirket,
//     required String cariKodu,
//     required String basTarih,
//     required String bitTarih,
//   }) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/RaporCariEkstre'
//     };

//     String altHesapS = '';
//     if (altHesaplar.isNotEmpty) {
//       for (var e in altHesaplar) {
//         altHesapS = altHesapS + "'" + e + "'" + ',';
//       }
//       altHesapS = altHesapS.substring(0, altHesapS.length - 1);
//     }
//     print(altHesapS);
//     Map<String, String> islemTipMap = {
//       'NORMAL': '0',
//       'AÇIK': '1',
//       'FİKTİF': '2',
//     };
//     String islemTipS = '';
//     if (islemTipler.isNotEmpty) {
//       for (var e in islemTipler) {
//         islemTipS = '$islemTipS${islemTipMap[e]},';
//       }
//       islemTipS = islemTipS.substring(0, islemTipS.length - 1);
//     }
//     print(islemTipS);

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <RaporCariEkstre xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <Cari_Kod>$cariKodu</Cari_Kod>
//       <basTarih>$basTarih</basTarih>
//       <bitTarih>$bitTarih</bitTarih>
//       <AlthesapKisit>$altHesapS</AlthesapKisit>
//       <islemTip>$islemTipS</islemTip>
//     </RaporCariEkstre>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj!],
//             []
//           ];
//         } else {
//           List<String> kolonlar = [];
//           List<String> satirlar = [];

//           if (gelenHata.Hata == "false" && gelenHata.HataMesaj == "") {
//             return [
//               ["Veri Bulunamadı"],
//               []
//             ];
//           }

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));

//           try {
//             if (jsonData.isNotEmpty) {
//               jsonData[0].forEach((key, value) {
//                 kolonlar.add(key);
//               });
//               for (int i = 0; i < jsonData.length; i++) {
//                 jsonData[i].forEach((key, value) {
//                   satirlar.add(value.toString());
//                 });
//               }
//             }
//           } catch (e) {
//             print(e);
//           }

//           print(kolonlar.length);
//           print(satirlar.length);

//           return [satirlar, kolonlar];
//         }
//       } else {
//         Exception(
//             'CARİ EXTRE Rapor Alınamadı. StatusCode: ${response.statusCode}');

//         return [
//           ['CARİ EXTRE Rapor Alınamadı. StatusCode: ${response.statusCode}'],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return [
//         [
//           "CARİ EXTRE Rapor için Webservisten veri çekilemedi. Hata Mesajı : " +
//               e.toString()
//         ],
//         []
//       ];
//     }
//   }

//   Future<List<List<dynamic>>> getirCariEkstreAltHesap(
//       {required String sirket, required String cariKodu}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/RaporCariEkstreAltHesap'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
//  <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
//  xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
//  xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body> 
//   <RaporCariEkstreAltHesap xmlns="http://tempuri.org/">
//    <Sirket>$sirket</Sirket> 
//    <Cari_Kod>$cariKodu</Cari_Kod>
//     </RaporCariEkstreAltHesap> 
//     </soap:Body>
//      </soap:Envelope>
// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj],
//             []
//           ];
//         } else {
//           List<DataColumn> kolonlar = [];
//           List<String> satirlar = [];

//           if (gelenHata.Hata == "false" && gelenHata.HataMesaj == "") {
//             return [
//               ["Veri Bulunamadı"],
//               []
//             ];
//           }

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));

//           try {
//             if (jsonData.isNotEmpty) {
//               jsonData[0].forEach((key, value) {
//                 kolonlar.add(DataColumn(label: Text(key)));
//               });
//               for (int i = 0; i < jsonData.length; i++) {
//                 jsonData[i].forEach((key, value) {
//                   satirlar.add(value.toString());
//                 });
//               }
//             }
//           } catch (e) {
//             print(e);
//           }

//           print(kolonlar.length);
//           print(satirlar.length);

//           return [satirlar, kolonlar];
//         }
//       } else {
//         Exception(
//             'CARİ EXTRE alt hesap Rapor Alınamadı. StatusCode: ${response.statusCode}');

//         return [
//           [
//             'CARİ EXTRE  alt hesap Rapor Alınamadı. StatusCode: ${response.statusCode}'
//           ],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return [
//         [
//           "CARİ EXTRE Rapor için Webservisten veri çekilemedi. Hata Mesajı : " +
//               e.toString()
//         ],
//         []
//       ];
//     }
//   }

//   Future<List<List<dynamic>>> getirCariEkstreDetay({
//     required String sirket,
//     required String faturaID,
//   }) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/RaporCariEkstreDetay'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <RaporCariEkstreDetay xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <FaturaId>$faturaID</FaturaId>
//     </RaporCariEkstreDetay>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj],
//             []
//           ];
//         } else {
//           List<DataColumn> kolonlar = [];
//           List<String> satirlar = [];

//           if (gelenHata.Hata == "false" && gelenHata.HataMesaj == "") {
//             return [
//               ["Veri Bulunamadı"],
//               []
//             ];
//           }

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));

//           try {
//             if (jsonData.isNotEmpty) {
//               jsonData[0].forEach((key, value) {
//                 kolonlar.add(DataColumn(label: Text(key)));
//               });
//               for (int i = 0; i < jsonData.length; i++) {
//                 jsonData[i].forEach((key, value) {
//                   satirlar.add(value.toString());
//                 });
//               }
//             }
//           } catch (e) {
//             print(e);
//           }

//           print(kolonlar.length);
//           print(satirlar.length);

//           return [satirlar, kolonlar];
//         }
//       } else {
//         Exception(
//             'CariEkstreDetay Rapor Alınamadı. StatusCode: ${response.statusCode}');

//         return [
//           [
//             'CariEkstreDetay Rapor Alınamadı. StatusCode: ${response.statusCode}'
//           ],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return [
//         [
//           "CariEkstreDetay Rapor için Webservisten veri çekilemedi. Hata Mesajı : " +
//               e.toString()
//         ],
//         []
//       ];
//     }
//   }

//   Future<List<List<String>>> getirAltHesapBakiye({
//     required String sirket,
//     required String cariKodu,
//   }) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/RaporAltHesapBakiye'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <RaporAltHesapBakiye xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <Cari_Kodu>$cariKodu</Cari_Kodu>
//     </RaporAltHesapBakiye>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj!],
//             []
//           ];
//         } else {
//           List<String> kolonlar = [];
//           List<String> satirlar = [];

//           if (gelenHata.Hata == "false" && gelenHata.HataMesaj == "") {
//             return [
//               ["Veri Bulunamadı"],
//               []
//             ];
//           }

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));

//           try {
//             if (jsonData.isNotEmpty) {
//               jsonData[0].forEach((key, value) {
//                 kolonlar.add(key);
//               });
//               for (int i = 0; i < jsonData.length; i++) {
//                 jsonData[i].forEach((key, value) {
//                   satirlar.add(value.toString());
//                 });
//               }
//             }
//           } catch (e) {
//             print(e);
//           }

//           print(kolonlar.length);
//           print(satirlar.length);

//           return [satirlar, kolonlar];
//         }
//       } else {
//         Exception(
//             'Alt Hesap Bakiye Rapor Alınamadı. StatusCode: ${response.statusCode}');

//         return [
//           ['Alt Hesap Rapor Alınamadı. StatusCode: ${response.statusCode}'],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return [
//         [
//           "Alt Hesap Rapor için Webservisten veri çekilemedi. Hata Mesajı : " +
//               e.toString()
//         ],
//         []
//       ];
//     }
//   }

//   Future<List<List<dynamic>>> getirCariCekSenet(
//       {required String sirket,
//       required String cariKodu,
//       required String basTar,
//       required String bitTar}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/RaporCariCekSenet'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <RaporCariCekSenet xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <Cari_Kodu>$cariKodu</Cari_Kodu>
//       <Bastar>$basTar</Bastar>
//       <Bittar>$bitTar</Bittar>
//     </RaporCariCekSenet>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj],
//             []
//           ];
//         } else {
//           List<DataColumn> kolonlar = [];
//           List<String> satirlar = [];

//           if (gelenHata.Hata == "false" && gelenHata.HataMesaj == "") {
//             return [
//               ["Veri Bulunamadı"],
//               []
//             ];
//           }

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));

//           try {
//             if (jsonData.isNotEmpty) {
//               jsonData[0].forEach((key, value) {
//                 kolonlar.add(DataColumn(label: Text(key)));
//               });
//               for (int i = 0; i < jsonData.length; i++) {
//                 jsonData[i].forEach((key, value) {
//                   satirlar.add(value.toString());
//                 });
//               }
//             }
//           } catch (e) {
//             print(e);
//           }

//           print(kolonlar.length);
//           print(satirlar.length);

//           return [satirlar, kolonlar];
//         }
//       } else {
//         Exception(
//             'Bekleyen Sipariş Raporları Alınamadı. StatusCode: ${response.statusCode}');

//         return [
//           [
//             'Bekleyen Sipariş Raporları  Alınamadı. StatusCode: ${response.statusCode}'
//           ],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return [
//         [
//           "Bekleyen Sipariş Raporları  için Webservisten veri çekilemedi. Hata Mesajı : " +
//               e.toString()
//         ],
//         []
//       ];
//     }
//   }

//   Future<String> getirIslemTip(
//       {required String sirket, required String kullaniciKodu}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirSatisTip'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirSatisTip xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <PlasiyerKod>$kullaniciKodu</PlasiyerKod>
//     </GetirSatisTip>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response =
//           await http.post(url, headers: headers, body: body);

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           listeler.listSatisTipiModel.clear();
//           await VeriIslemleri().islemTipiTemizle();

//           String modelNode = gelenHata.HataMesaj!;
//           Iterable l = json.decode(modelNode);

//           listeler.listSatisTipiModel = List<SatisTipiModel>.from(
//               l.map((model) => SatisTipiModel.fromJson(model)));
//           listeler.listSatisTipiModel.insert(
//               0,
//               SatisTipiModel(
//                   ID: -1, TIP: "Yok", FIYATTIP: "", ISK1: "", ISK2: ""));

//           for (var element in listeler.listSatisTipiModel) {
//             await VeriIslemleri().islemTipiEkle(element);
//           }
//           return "";
//         }
//       } else {
//         Exception(
//             'Satış Tipi verisi alınamadı. StatusCode: ${response.statusCode}');
//         return " Satış Tipi Getirilirken İstek Oluşturulamadı. " +
//             response.statusCode.toString();
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return "Satış Tipi için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   Future<SHataModel> ekleStok(
//       {required String sirket,
//       required Map<String, dynamic> jsonDataList}) async {
//     SHataModel hata = SHataModel(Hata: "true", HataMesaj: "Veri Gönderilemedi");

//     var jsonString;
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;

//     jsonString = jsonEncode(jsonDataList);

//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/EkleStok',
//     };
//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <EkleStok xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <Stok>$jsonString</Stok>
//     </EkleStok>
//   </soap:Body>
// </soap:Envelope>
// ''';
//     printWrapped(jsonString);
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData = jsonDecode(parsedXml.innerText);
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         return gelenHata;
//       } else {
//         Exception(
//             'Yeni Stok Verisi Gönderilemedi. StatusCode: ${response.statusCode}');
//         return hata;
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return hata;
//     }
//   }

//   Future<String> getirInteraktifRaporBilgi({
//     required String sirket,
//     required String kullaniciKodu,
//   }) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirInteraktifRapor'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirInteraktifRapor xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <PlasiyerKod>$kullaniciKodu</PlasiyerKod>
//     </GetirInteraktifRapor>
//   </soap:Body>
// </soap:Envelope>

// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           listeler.listInteraktifRapor.clear();

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));
//           final List<Map<String, dynamic>> data =
//               List<Map<String, dynamic>>.from(
//                   json.decode(gelenHata.HataMesaj!));
//           print(data);

//           for (var element in jsonData) {
//             GenelInteraktifRapor a = GenelInteraktifRapor.fromJson(element);
//             listeler.listInteraktifRapor.add(a);
//           }
//           listeler.listInteraktifRapor;

//           return "";
//         }
//       } else {
//         Exception(
//             'İnteraktif Raporlar için Genel Rapor Bilgisi Alınamadı. StatusCode: ${response.statusCode}');

//         return "İnteraktif Raporlar Alınamadı";
//       }
//     } catch (e) {
//       print("aa" + e.toString());
//       Exception('Hata: $e');

//       return "İnteraktif Raporlar Alınamadı";
//     }
//   }

//   Future<List<List<dynamic>>> getirSonucInteraktifRapor(
//       {required String sirket, required String rapor}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirSonucInteraktifRapor'
//     };
//     var jsonString = jsonEncode(rapor);

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirSonucInteraktifRapor xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <_Rapor>$rapor</_Rapor>
//     </GetirSonucInteraktifRapor>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [
//             [gelenHata.HataMesaj],
//             []
//           ];
//         } else {
//           List<DataColumn> kolonlar = [];
//           List<String> satirlar = [];

//           if (gelenHata.Hata == "false" && gelenHata.HataMesaj == "") {
//             return [
//               ["Veri Bulunamadı"],
//               []
//             ];
//           }

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));

//           try {
//             if (jsonData.isNotEmpty) {
//               jsonData[0].forEach((key, value) {
//                 kolonlar.add(DataColumn(label: Text(key)));
//               });
//               for (int i = 0; i < jsonData.length; i++) {
//                 jsonData[i].forEach((key, value) {
//                   satirlar.add(value.toString());
//                 });
//               }
//             }
//           } catch (e) {
//             print(e);
//           }

//           print(kolonlar.length);
//           print(satirlar.length);

//           return [satirlar, kolonlar];
//         }
//       } else {
//         Exception(
//             'İnteraktif Rapor Sonuç Alınamadı. StatusCode: ${response.statusCode}');

//         return [
//           [
//             'İnteraktif Rapor Sonuç Alınamadı. StatusCode: ${response.statusCode}'
//           ],
//           []
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return [
//         [
//           "İnteraktif Rapor Sonuç için Webservisten veri çekilemedi. Hata Mesajı : " +
//               e.toString()
//         ],
//         []
//       ];
//     }
//   }

//   Future<String> getirStokFiyatListesi({
//     required String sirket,
//   }) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirStokFiyatListesi'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirStokFiyatListesi xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//     </GetirStokFiyatListesi>
//   </soap:Body>
// </soap:Envelope>

// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           listeler.listStokFiyatListesi.clear();

//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));
//           final List<Map<String, dynamic>> data =
//               List<Map<String, dynamic>>.from(
//                   json.decode(gelenHata.HataMesaj!));

//           print("LİSSSSSTT");
//           print(data);
//           for (var element in jsonData) {
//             StokFiyatListesiModel a = StokFiyatListesiModel.fromJson(element);
//             listeler.listStokFiyatListesi.add(a);
//           }
//           listeler.listStokFiyatListesi.insert(
//               0, StokFiyatListesiModel(ID: -1, ADI: "Kullanmadan Devam Et"));
//           await VeriIslemleri().stokFiyatListesiTemizle();

//           for (var element in listeler.listStokFiyatListesi) {
//             await VeriIslemleri().stokFiyatListesiEkle(element);
//           }

//           return "";
//         }
//       } else {
//         Exception(
//             'Stok Fiyat Listesi (Koşul) Bilgisi Alınamadı. StatusCode: ${response.statusCode}');

//         return "Stok Fiyat Listesi (Koşul) Alınamadı";
//       }
//     } catch (e) {
//       print("aa" + e.toString());
//       Exception('Hata: $e');

//       return "Tanımlı Stok Fiyat Listesi (Koşul)  Bulunamadı";
//     }
//   }

//   Future<String> getirStokFiyatHarListesi({
//     required String sirket,
//   }) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirStokFiyatListesiHar'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirStokFiyatListesiHar xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//     </GetirStokFiyatListesiHar>
//   </soap:Body>
// </soap:Envelope>

// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           listeler.listStokFiyatListesiHar.clear();
//           List<dynamic> jsonData = jsonDecode(temizleKontrolKarakterleri(gelenHata
//               .HataMesaj!)); // burayı kaldır aga gereksiz bi daha bekletiyo decodelere
//           /*
//           final List<Map<String, dynamic>> data =
//               List<Map<String, dynamic>>.from(
//                   json.decode(gelenHata.HataMesaj!)); //bak
//           await VeriIslemleri().stokFiyatListesiHarTemizle();
//           */

//           for (var element in jsonData) {
//             StokFiyatListesiHarModel a =
//                 StokFiyatListesiHarModel.fromJson(element);
//             listeler.listStokFiyatListesiHar.add(a);
//           }

//           for (var element in listeler.listStokFiyatListesiHar) {
//             await VeriIslemleri().stokFiyatListesiHarEkle(element);
//           }

//           return "";
//         }
//       } else {
//         Exception(
//             'Stok Fiyat Listesi Hareketleri (Koşul) Bilgisi Alınamadı. StatusCode: ${response.statusCode}');

//         return "Stok Fiyat Listesi Hareketleri (Koşul) Alınamadı";
//       }
//     } catch (e) {
//       print("aa" + e.toString());
//       Exception('Hata: $e');

//       return "Tanımlı Stok Fiyat Listesi Hareketleri (Koşul)  Bulunamadı";
//     }
//   }

//   Future<List> getirStokResimEski(
//       {required String sirket, required String stokKod}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirStokResim'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirStokResim xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <StokKodu>$stokKod</StokKodu>
//        <resimHepsiMi>boolean</resimHepsiMi>
//     </GetirStokResim>
//   </soap:Body>
// </soap:Envelope>
// ''';
//     try {
//       //BURDAKAKLDIM
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;

//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [true, gelenHata.HataMesaj!];
//         } else {
//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));
//           List<String> donecekByteList = [];
//           for (var el in jsonData) {
//             donecekByteList.add(el["RESIM"]);
//           }

//           return [false, donecekByteList];
//         }
//       } else {
//         Exception(
//             'Stok resim verisi alınamadı. StatusCode: ${response.statusCode}');
//         return [
//           true,
//           " Stok resim Getirilirken İstek Oluşturulamadı. " +
//               response.statusCode.toString()
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return [
//         true,
//         "Stok resim için Webservisten veri çekilemedi. Hata Mesajı : " +
//             e.toString()
//       ];
//     }
//   }

//   Future<String> getirCevrimdisiResim() async {
//     String hata = "";
//     List<String> stringList =
//         listeler.liststok.map((e) => e.KOD ?? "").toList();

//     for (var index in stringList) {
//       List<dynamic> donen = await bs.getirStokResim(
//           sirket: Ctanim.sirket.toString(),
//           stokKod: index,
//           resimHepsiMi: false);
//       if (donen[0] == true) {
//         hata += "Stok Kodu : $index için Resim Getirilemedi. Hata Mesajı  \n";
//       }
//     }

//     return hata;
//   }

//   Future<SHataModel> ekleStokResim({
//     required String sirket,
//     required String stokKod,
//     required String resim,
//   }) async {
//     SHataModel hata = SHataModel(Hata: "true", HataMesaj: "Veri Gönderilemedi");
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/EkleStokResim'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?> 
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
// xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
// xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"> 
// <soap:Body> <EkleStokResim xmlns="http://tempuri.org/">
//  <Sirket>$sirket</Sirket> 
//  <Resim>$resim</Resim> 
//  <StokKod>$stokKod</StokKod> 
//  </EkleStokResim> 
//  </soap:Body> 
//  </soap:Envelope>


// ''';
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData = jsonDecode(parsedXml.innerText);
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);

//         if (Ctanim.kullanici!.MOBILRESIMAKTIF == "E") {
//           //await resimKucukKaydet(resim, stokKod, gelenHata.HataMesaj!);
//         }

//         return gelenHata;
//       } else {
//         Exception(
//             'Resim Verisi Gönderilemedi. StatusCode: ${response.statusCode}');
//         return hata;
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return hata;
//     }
//   }

//   Future<List> getirStokResim({
//     required String sirket,
//     required String stokKod,
//     bool resimHepsiMi = true,
//     bool idListDonsunMu = false,
//   }) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirStokResim'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirStokResim xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <StokKodu>$stokKod</StokKodu>
//        <resimHepsiMi>$resimHepsiMi</resimHepsiMi>
//     </GetirStokResim>
//   </soap:Body>
// </soap:Envelope>
// ''';
//     try {
//       //BURDAKAKLDIM
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;

//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));

//         SHataModel gelenHata = SHataModel.fromJson(jsonData);

//         if (gelenHata.Hata == "true") {
//           return [true, gelenHata.HataMesaj!];
//         } else {
//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));
//           List<int> resimIDList = [];
//           List<String> donecekByteList = [];
//           for (var i = 0; i < jsonData.length; i++) {
//             var el = jsonData[i];
//             resimIDList.add(int.parse(el["ID"]));

//             if (i < 3 && Ctanim.kullanici!.MOBILRESIMAKTIF == "E")
//               await resimKucukKaydet(el["RESIM"], stokKod, i.toString());

//             donecekByteList.add(el["RESIM"]);
//           }
//           if (idListDonsunMu == false) {
//             return [false, donecekByteList];
//           } else {
//             return [false, donecekByteList, resimIDList];
//           }
//         }
//       } else {
//         Exception(
//             'Stok resim verisi alınamadı. StatusCode: ${response.statusCode}');
//         return [
//           true,
//           " Stok resim Getirilirken İstek Oluşturulamadı. " +
//               response.statusCode.toString()
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return [
//         true,
//         "Stok resim için Webservisten veri çekilemedi. Hata Mesajı : " +
//             e.toString()
//       ];
//     }
//   }

//   Future<SHataModel> silStokResim(
//       {required String sirket, required int id}) async {
//     SHataModel hata = SHataModel(Hata: "true", HataMesaj: "Veri Gönderilemedi");

//     var jsonString;
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;

//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/SilStokResim',
//     };
//     String body = '''
// <?xml version="1.0" encoding="utf-8"?> 
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
// xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
// xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"> 
// <soap:Body> <SilStokResim xmlns="http://tempuri.org/"> 
// <Sirket>$sirket</Sirket> 
// <ID>$id</ID> 
// </SilStokResim> 
// </soap:Body>
//  </soap:Envelope>

// ''';
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData = jsonDecode(parsedXml.innerText);
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         return gelenHata;
//       } else {
//         Exception(
//             'Resim silmek için istek gönderilemedi. StatusCode: ${response.statusCode}');
//         return hata;
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return hata;
//     }
//   }

//   Future<List<int>> testComporessList(Uint8List list) async {
//     var result = await FlutterImageCompress.compressWithList(list,
//         minHeight: 200,
//         minWidth: 200,
//         quality: 96,
//         rotate: 0,
//         format: CompressFormat.jpeg);
//     return result;
//   }

//   Future<void> deleteFilesStartingWithStokKodu(String stokKodu) async {
//     // Belgeler dizinini alın
//     final directory = await getApplicationDocumentsDirectory();

//     // Dizindeki tüm dosyaları alın
//     final List<FileSystemEntity> files = directory.listSync();

//     // "x" ile başlayan dosyaları silin
//     for (FileSystemEntity file in files) {
//       if (file is File && file.path.split('/').last.startsWith(stokKodu)) {
//         try {
//           await file.delete();
//           print('Deleted file: ${file.path}');
//         } catch (e) {
//           print('Failed to delete file: ${file.path}');
//         }
//       }
//     }
//   }

//   Future<void> resimKucukKaydet(
//       String image, String stokKod, String imageIndex) async {
//     String fileName = "$stokKod-$imageIndex.jpeg";
//     var file =
//         File('${(await getApplicationDocumentsDirectory()).path}/$fileName');

//     await deleteFilesStartingWithStokKodu("${stokKod}-${imageIndex}");
//     String uint8temp =
//         base64.encode(await testComporessList(base64Decode(image)));
//     saveBase64ToFile(uint8temp, fileName);
//   }

//   Future<void> saveBase64ToFile(String base64String, String fileName) async {
//     final decodedBytes = base64Decode(base64String);
//     final directory = await getApplicationDocumentsDirectory();
//     final filePath = '${directory.path}/$fileName';
//     await File(filePath).writeAsBytes(decodedBytes);
//     print('File saved to: $filePath');
//   }

//   Future<String> ekleHata(
//       {required String sirket, required String hata}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/EkleHata'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <EkleHata xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <Hata>$hata</Hata>
//     </EkleHata>
//   </soap:Body>
// </soap:Envelope>
// ''';
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           return "";
//         }
//       } else {
//         Exception('Log Kaydı Yapılamadı. StatusCode: ${response.statusCode}');
//         return 'Log Kaydı Yapılamadı. StatusCode: ${response.statusCode}';
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return "Log için Webserviste Bağlantı Kurulamadı. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   Future<String> getirOndalikParam({
//     required int subeId,
//     required String sirket,
//   }) async {
//     var url = Uri.parse(Ctanim.IP);

//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirOndalikParam'
//     };

//     String body = '''<?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirOndalikParam xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <SubeId>$subeId</SubeId>
//     </GetirOndalikParam>
//   </soap:Body>
// </soap:Envelope>''';

//     try {
//       var response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           await VeriIslemleri().ondalikTemizle();
//           String modelNode = gelenHata.HataMesaj!;
//           List<dynamic> parsedList = json.decode(modelNode);

//           Map<String, dynamic> ondalikJson = parsedList[0];
//           Ctanim.ondalikModel = OndalikModel.fromJson(ondalikJson);
//           VeriIslemleri().ondalikEkle(Ctanim.ondalikModel!);
//           return "";
//         }
//       } else {
//         print('SOAP isteği başarısız: ${response.statusCode}');
//         return " Ondalık Bilgileri Getirilirken İstek Oluşturulamadı. " +
//             response.statusCode.toString();
//       }
//     } catch (e) {
//       print('Hata: $e');
//       return " Ondalık bilgiler için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   Future<List<String>> getirEtiketDizayn({
//     required int subeId,
//     required String sirket,
//   }) async {
//     var url = Uri.parse(Ctanim.IP);

//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirStokEtiketDizayn'
//     };

//     String body = '''<?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirStokEtiketDizayn xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <SubeId>$subeId</SubeId>
//     </GetirStokEtiketDizayn>
//   </soap:Body>
// </soap:Envelope>''';

//     try {
//       var response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         List<String> donecek = [];
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return ["false", gelenHata.HataMesaj!];
//         } else {
//           List<dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(gelenHata.HataMesaj!));
//           /*
//           final List<Map<String, dynamic>> data =
//               List<Map<String, dynamic>>.from( ////BURAYA BAK
//                   json.decode(gelenHata.HataMesaj!));
//                   */

//           for (var element in jsonData) {
//             String adi = element["ADI"];
//             donecek.add(adi);
//           }
//           return donecek;
//         }
//       } else {
//         print('SOAP isteği başarısız: ${response.statusCode}');
//         return [
//           "false",
//           " Dizayn İsimleri Getirilirken İstek Oluşturulamadı. " +
//               response.statusCode.toString()
//         ];
//       }
//     } catch (e) {
//       print('Hata: $e');
//       return [
//         "false",
//         " Dizayn İsimleri için Webservisten veri çekilemedi. Hata Mesajı : " +
//             e.toString()
//       ];
//     }
//   }

//   Future<List> getirEtiketPdf(
//       {required String kodlar,
//       required String dizaynAdi,
//       required String sirket,
//       required int sira}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/YazdirEtiketDizayn'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <YazdirEtiketDizayn xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <Kodlar>$kodlar</Kodlar>
//       <DizaynAdi>$dizaynAdi</DizaynAdi>
//       <BarkodSira>$sira</BarkodSira>
//     </YazdirEtiketDizayn>
//   </soap:Body>
// </soap:Envelope>
// ''';
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;

//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [true, gelenHata.HataMesaj!];
//         } else {
//           printWrapped(gelenHata.HataMesaj!);

//           return [false, gelenHata.HataMesaj];
//         }
//       } else {
//         Exception(
//             'Stok resim verisi alınamadı. StatusCode: ${response.statusCode}');
//         return [
//           true,
//           " Stok resim Getirilirken İstek Oluşturulamadı. " +
//               response.statusCode.toString()
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return [
//         true,
//         "Stok resim için Webservisten veri çekilemedi. Hata Mesajı : " +
//             e.toString()
//       ];
//     }
//   }

//   Future<List> getirEtiketJpg(
//       {required String kodlar,
//       required String dizaynAdi,
//       required String sirket,
//       required int sira}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/YazdirEtiketDizaynJpg'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <YazdirEtiketDizaynJpg xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <Kodlar>$kodlar</Kodlar>
//       <DizaynAdi>$dizaynAdi</DizaynAdi>
//       <BarkodSira>$sira</BarkodSira>
//     </YazdirEtiketDizaynJpg>
//   </soap:Body>
// </soap:Envelope>

// ''';
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;

//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return [true, gelenHata.HataMesaj!];
//         } else {
//           printWrapped(gelenHata.HataMesaj!);

//           return [false, gelenHata.HataMesaj];
//         }
//       } else {
//         Exception(
//             'Stok resim verisi alınamadı. StatusCode: ${response.statusCode}');
//         return [
//           true,
//           " Stok resim Getirilirken İstek Oluşturulamadı. " +
//               response.statusCode.toString()
//         ];
//       }
//     } catch (e) {
//       Exception('Hata: $e');

//       return [
//         true,
//         "Stok resim için Webservisten veri çekilemedi. Hata Mesajı : " +
//             e.toString()
//       ];
//     }
//   }

//   Future<String> getirStokDepo({required sirket, required plasiyerKod}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirStokDepoBakiye'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirStokDepoBakiye xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <PlasiyerKod>$plasiyerKod</PlasiyerKod>
//     </GetirStokDepoBakiye>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response =
//           await http.post(url, headers: headers, body: body);

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           listeler.listStokDepo.clear();
//           await VeriIslemleri().stokDepoTemizle();

//           String modelNode = gelenHata.HataMesaj!;
//           Iterable l = json.decode(modelNode);

//           listeler.listStokDepo = List<StokDepoModel>.from(
//               l.map((model) => StokDepoModel.fromJson(model)));

//           for (var element in listeler.listStokDepo) {
//             await VeriIslemleri().stokDepoEkle(element);
//           }
//           return "";
//         }
//       } else {
//         Exception(
//             'Stok Depo verisi alınamadı. StatusCode: ${response.statusCode}');
//         return " Stokların Depo Bakiyeleri Getirilirken İstek Oluşturulamadı. " +
//             response.statusCode.toString();
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return "Stoklar için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   Future<String> getirFisEkParam({required sirket}) async {
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/GetirFaturaEkParam'
//     };

//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <GetirFaturaEkParam xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//     </GetirFaturaEkParam>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response =
//           await http.post(url, headers: headers, body: body);

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData =
//             jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           if (gelenHata.HataMesaj == "") {
//             listeler.listFisEkParam.clear();
//             await VeriIslemleri().fisEkParamTemizle();
//             return "";
//           } else {
//             listeler.listFisEkParam.clear();
//             await VeriIslemleri().fisEkParamTemizle();

//             String modelNode = gelenHata.HataMesaj!;
//             Iterable l = json.decode(modelNode);

//             listeler.listFisEkParam = List<FisEkParam>.from(
//                 l.map((model) => FisEkParam.fromJson(model)));
//             listeler.listFisEkParamZorunluID.clear();
//             for (var element in listeler.listFisEkParam) {
//               if (element.ZORUNLU == "True") {
//                 listeler.listFisEkParamZorunluID.add(element.ID!);
//               }

//               await VeriIslemleri().fisEkParamEkle(element);
//             }
//             return "";
//           }
//         }
//       } else {
//         Exception(
//             'Fis Ek Parametre verisi alınamadı. StatusCode: ${response.statusCode}');
//         return " Fis Ek Parametre Getirilirken İstek Oluşturulamadı. " +
//             response.statusCode.toString();
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return "Fis Ek Parametre için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   Future<SHataModel> ekleDekont(
//       {required String sirket,
//       required Map<String, dynamic> jsonDataList}) async {
//     SHataModel hata = SHataModel(Hata: "true", HataMesaj: "Veri Gönderilemedi");
//     var jsonString;
//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;

//     jsonString = jsonEncode(jsonDataList);

//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/EkleDekont',
//     };
//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <EkleDekont xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <Fis>$jsonString</Fis>
//     </EkleDekont>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     printWrapped(jsonString);
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);
//         Map<String, dynamic> jsonData = jsonDecode(parsedXml.innerText);
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         return gelenHata;
//       } else {
//         Exception(
//             'Dekont Verisi Gönderilemedi. StatusCode: ${response.statusCode}');
//         return hata;
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return hata;
//     }
//   }

//   Future<SHataModel> VersiyonGuncelle({
//     required String Versiyon,
//   }) async {
//     SHataModel hata =
//         SHataModel(Hata: "true", HataMesaj: "İstek Gönderilemedi");

//     var url = Uri.parse(Ctanim.IP);
//     // dış ve iç denecek;

//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/VersiyonGuncelleMobil',
//     };
//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <VersiyonGuncelleMobil xmlns="http://tempuri.org/">
//       <Version>$Versiyon</Version>
//     </VersiyonGuncelleMobil>
//   </soap:Body>
// </soap:Envelope>


// ''';
//     //printWrapped(base64EncodedString);
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData = jsonDecode(parsedXml.innerText);
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);

//         return gelenHata;
//       } else {
//         Exception(
//             'Güncelleme İsteği gönderilemedi. StatusCode: ${response.statusCode}');
//         return hata;
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return hata;
//     }
//   }

//   Future<SHataModel> raporPdfOlustur(
//       {required String sirket,
//       required int id,
//       required String tip,
//       String? cariKod = ""}) async {
//     SHataModel hata =
//         SHataModel(Hata: "true", HataMesaj: "İstek Gönderilemedi");

//     var url = Uri.parse(Ctanim.IP);
//     // dış ve iç denecek;

//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/PdfGoster',
//     };
//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
//  <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
//  xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"> 
//  <soap:Body> <PdfGoster xmlns="http://tempuri.org/">
//   <Sirket>$sirket</Sirket> 
//   <Id>$id</Id>
//    <_Tip>$tip</_Tip> 
//     <CariKod>$cariKod</CariKod>
//    </PdfGoster> 
//    </soap:Body> 
//    </soap:Envelope>

// ''';
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         if (parsedXml.innerText.contains("Dizayn bulunamadı")) {
//           hata.Hata = "true";
//           hata.HataMesaj =
//               "Seçilen belge tipi için seçili varsayılan dizayn bulunamadı.";
//           return hata;
//         }
//         hata.Hata = "false";
//         hata.HataMesaj = "";
//         return hata;
//       } else {
//         Exception(
//             'PDF oluşturma isteği gönderilemedi. StatusCode: ${response.statusCode}');
//         hata.HataMesaj =
//             "PDF oluşturma isteği gönderilemedi. StatusCode: ${response.statusCode}";
//         return hata;
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       hata.HataMesaj =
//           "PDF oluşturma isteği gönderilemedi. Hata Mesajı : " + e.toString();
//       return hata;
//     }
//   }

//   Future<SHataModel> raporPdfOlustuCariEkstre(
//       {required String sirket,
//       required String TIP,
//       required int ID,
//       String? cariKod = ""}) async {
//     SHataModel hata =
//         SHataModel(Hata: "true", HataMesaj: "İstek Gönderilemedi");

//     var url = Uri.parse(Ctanim.IP);
//     // dış ve iç denecek;

//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/PdfGosterCariEkstre',
//     };
//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
// xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
// xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"> 
// <soap:Body> <PdfGosterCariEkstre xmlns="http://tempuri.org/">
//  <Sirket>$sirket</Sirket> 
//  <_Tip>$TIP</_Tip>
//   <Id>$ID</Id> 
//   </PdfGosterCariEkstre> 
//   </soap:Body> 
//   </soap:Envelope>
// ''';
//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         if (parsedXml.innerText.contains("Dizayn bulunamadı")) {
//           hata.Hata = "true";
//           hata.HataMesaj = "Seçilen belge tipi için dizayn bulunamadı.";
//           return hata;
//         }
//         hata.Hata = "false";
//         hata.HataMesaj = "";
//         return hata;
//       } else {
//         Exception(
//             'PDF oluşturma isteği gönderilemedi. StatusCode: ${response.statusCode}');
//         hata.HataMesaj =
//             "PDF oluşturma isteği gönderilemedi. StatusCode: ${response.statusCode}";
//         return hata;
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       hata.HataMesaj =
//           "PDF oluşturma isteği gönderilemedi. Hata Mesajı : " + e.toString();
//       return hata;
//     }
//   }

//   Future<String> getirGecmisSatis({required sirket, required stokKodu}) async {
//     listeler.listGecmisSatisModel.clear();
//     SHataModel gelenHata = SHataModel();
//     var url = Uri.parse(Ctanim.IP);
//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/RaporStokGecmisSatisDetay'
//     };
//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
//  <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
//  xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"> 
//  <soap:Body> <RaporStokGecmisSatisDetay 
//  xmlns="http://tempuri.org/">
//   <Sirket>$sirket</Sirket>
//    <StokKodu>$stokKodu</StokKodu> 
//    </RaporStokGecmisSatisDetay> 
//    </soap:Body> 
//    </soap:Envelope>

// ''';

//     if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
//       //listeler.listCari = [];
//       return "İnternet Yok";
//     }

//     try {
//       http.Response response =
//           await http.post(url, headers: headers, body: body);
//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         try {
//           Map<String, dynamic> jsonData =
//               jsonDecode(temizleKontrolKarakterleri(parsedXml.innerText));
//           gelenHata = SHataModel.fromJson(jsonData);
//         } catch (e) {
//           print(e);
//           return "Geçmiş Satışlar Getirilirken Hata Oluştu. (Json decode error.)";
//         }

//         if (gelenHata.Hata == "true") {
//           return gelenHata.HataMesaj!;
//         } else {
//           String modelNode = gelenHata.HataMesaj!;
//           Iterable? l;
//           try {
//             String temizJson = temizleKontrolKarakterleri(modelNode);

//             l = json.decode(temizJson);
//           } catch (e) {
//             print(e);
//             return "Geçmiş Satışlar Getirilirken Hata Oluştu. (Json decode error.)";
//           }

//           listeler.listGecmisSatisModel.clear();
//           listeler.listGecmisSatisModel = List<GecmisSatisModel>.from(
//               l!.map((model) => GecmisSatisModel.fromJson(model)));

//           return "";
//         }
//       } else {
//         return " Geçmiş Satışlar için istek oluşturulamadı. " +
//             response.statusCode.toString();
//       }

//       // databaseden veri getirir
//     } on Exception catch (e) {
//       return "Geçmiş Satışlar için Webservisten veri çekilemedi. Hata Mesajı : " +
//           e.toString();
//     }
//   }

//   Future<SHataModel> stokFiyatGuncelle(
//       {required String sirket,
//       required String plasiyerKod,
//       required String stokKod,
//       required int FiyatSira,
//       required double yeniDeger,
//       required double eskiDeger}) async {
//     SHataModel hata = SHataModel(Hata: "true", HataMesaj: "Veri Gönderilemedi");

//     var url = Uri.parse(Ctanim.IP); // dış ve iç denecek;

//     var headers = {
//       'Content-Type': 'text/xml; charset=utf-8',
//       'SOAPAction': 'http://tempuri.org/StokFiyatGuncelle',
//     };
//     String body = '''
// <?xml version="1.0" encoding="utf-8"?>
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <StokFiyatGuncelle xmlns="http://tempuri.org/">
//       <Sirket>$sirket</Sirket>
//       <plasiyerKod>$plasiyerKod</plasiyerKod>
//       <stokKod>$stokKod</stokKod>
//       <FiyatSira>$FiyatSira</FiyatSira>
//       <yeniDeger>$yeniDeger</yeniDeger>
//       <eskiDeger>$eskiDeger</eskiDeger>
//     </StokFiyatGuncelle>
//   </soap:Body>
// </soap:Envelope>
// ''';

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         var rawXmlResponse = response.body;
//         xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawXmlResponse);

//         Map<String, dynamic> jsonData = jsonDecode(parsedXml.innerText);
//         SHataModel gelenHata = SHataModel.fromJson(jsonData);
//         printWrapped(gelenHata.HataMesaj!);
//         return gelenHata;
//       } else {
//         Exception(
//             'Fatura Verisi Gönderilemedi. StatusCode: ${response.statusCode}');
//         return hata;
//       }
//     } catch (e) {
//       Exception('Hata: $e');
//       return hata;
//     }
//   }
// }
