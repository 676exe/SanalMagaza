// import 'dart:ffi';

// import 'package:shared_preferences/shared_preferences.dart';
// import '../veriler/listeler.dart';
// import '../../widget/ctanim.dart';

// class SharedPrefsHelper {
//   static const String kListKey = 'my_list_key';

//   static Future<void> yatayDikeyKaydet(bool yatayDikey) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('yatayDikey', yatayDikey);
//   }

//   static Future<List<bool>> getList() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String>? stringList = prefs.getStringList(kListKey);
//     List<bool> boolList =
//         stringList?.map((str) => str == 'true').toList() ?? [];
//     return boolList;
//   }

//   static Future<bool> yatayDikeyGetir() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool? storedNumber = prefs.getBool('yatayDikey');
//     if (storedNumber != null) {
//       return storedNumber;
//     } else {
//       return false;
//     }
//   }

//   static Future<void> saveList(List<bool> list) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String> stringList = list.map((item) => item.toString()).toList();
//     await prefs.setStringList(kListKey, stringList);
//   }

//   static Future<void> tahsilatbelgeNumarasiKaydet() async {
//     int tempbelgeno = Ctanim.tahsilatBelgeNo + 1;
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('tahsilatbelgeNo', tempbelgeno);
//   }

//   static Future<int> tahsilatbelgeNumarasiGetir() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     int? storedNumber = prefs.getInt('tahsilatbelgeNo');
//     DateTime now = DateTime.now();
//     String currentDate =
//         "${now.year.toString().padLeft(4, '0')}${(now.month).toString().padLeft(2, '0')}${(now.day).toString().padLeft(2, '0')}";
//     if (storedNumber != null) {
//       String tempbelgeno = storedNumber.toString().substring(
//           (Ctanim.kullanici!.KOD!.length), storedNumber.toString().length - 4);
//       if (tempbelgeno != currentDate) {
//         String newNumber = Ctanim.kullanici!.KOD! + "$currentDate" + "0000";
//         storedNumber = int.parse(newNumber);
//       }

//       Ctanim.tahsilatBelgeNo = storedNumber;
//       return storedNumber;
//     } else {
//       String newNumber = Ctanim.kullanici!.KOD! +
//           "$currentDate" +
//           "0000"; // Sabit "0001" ekleniyor
//       Ctanim.tahsilatBelgeNo = int.parse(newNumber);
//       return int.parse(newNumber);
//     }
//   }

//   static Future<void> faturaNumarasiKaydet(int number) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('faturaNo', number.toString());
//   }

//   static Future<int> faturaNumarasiGetir() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? storedNumber = prefs.getString('faturaNo');
//     if (storedNumber != null) {
//       return int.parse(storedNumber);
//     } else {
//       return -1;
//     }
//   }

//   static Future<void> ciktiBoyutuKaydet(bool cikti8cmMi) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('cikti8cmMi', cikti8cmMi);
//   }

//   static Future<bool> ciktiBoyutuGetir() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool? cikti8cmMi = prefs.getBool('cikti8cmMi');
//     if (cikti8cmMi != null) {
//       return cikti8cmMi;
//     } else {
//       return false;
//     }
//   }

//   static Future<void> faturaNumarasiSil() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('faturaNo');
//   }

//   static Future<void> siparisNumarasiKaydet(int number) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('siparisNo', number.toString());
//   }

//   static Future<int> siparisNumarasiGetir() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? storedNumber = prefs.getString('siparisNo');
//     if (storedNumber != null) {
//       return int.parse(storedNumber);
//     } else {
//       return -1;
//     }
//   }

//   static Future<void> siparisNumarasiSil() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('siparisNo');
//   }

//   static Future<void> irsaliyeNumarasiKaydet(int number) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('irsaliyeNo', number.toString());
//   }

//   static Future<int> irsaliyeNumarasiGetir() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? storedNumber = prefs.getString('irsaliyeNo');
//     if (storedNumber != null) {
//       return int.parse(storedNumber);
//     } else {
//       return -1;
//     }
//   }

//   static Future<void> irsaliyeNumarasiSil() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('irsaliyeNo');
//   }

//   static Future<void> efaturaNumarasiKaydet(int number) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('efaturaNo', number.toString());
//   }

//   static Future<int> efaturaNumarasiGetir() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? storedNumber = prefs.getString('efaturaNo');
//     if (storedNumber != null) {
//       return int.parse(storedNumber);
//     } else {
//       return -1;
//     }
//   }

//   static Future<void> efaturaNumarasiSil() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('efaturaNo');
//   }

//   static Future<void> eArsivNumarasiKaydet(int number) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('eArsivNo', number.toString());
//   }

//   static Future<int> eArsivNumarasiGetir() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? storedNumber = prefs.getString('eArsivNo');
//     if (storedNumber != null) {
//       return int.parse(storedNumber);
//     } else {
//       return -1;
//     }
//   }

//   static Future<void> eArsivNumarasiSil() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('eArsivNo');
//   }

//   static Future<void> eirsaliyeNumarasiKaydet(int number) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('eirsaliyeNo', number.toString());
//   }

//   static Future<int> eirsaliyeNumarasiGetir() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? storedNumber = prefs.getString('eirsaliyeNo');
//     if (storedNumber != null) {
//       return int.parse(storedNumber);
//     } else {
//       return -1;
//     }
//   }

//   static Future<void> eirsaliyeNumarasiSil() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('eirsaliyeNo');
//   }

//   static Future<void> perakendeSatisNumKaydet(int number) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('perSatNo', number.toString());
//   }

//   static Future<int> perakendeSatisNumGetir() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? storedNumber = prefs.getString('perSatNo');
//     if (storedNumber != null) {
//       return int.parse(storedNumber);
//     } else {
//       return -1;
//     }
//   }

//   static Future<void> perakendeSatisNumSil() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('perSatNo');
//   }

//   static Future<void> depoTransferNumKaydet(int number) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('depTrNo', number.toString());
//   }

//   static Future<int> depoTransferNumGetir() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? storedNumber = prefs.getString('depTrNo');
//     if (storedNumber != null) {
//       return int.parse(storedNumber);
//     } else {
//       return -1;
//     }
//   }

//   static Future<void> depoTransferNumSil() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('depTrNo');
//   }

//   static Future<void> acikFaturaNumarasiKaydet(int number) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('acikFatNo', number.toString());
//   }

//   static Future<int> acikFaturaNumarasiGetir() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? storedNumber = prefs.getString('acikFatNo');
//     if (storedNumber != null) {
//       return int.parse(storedNumber);
//     } else {
//       return -1;
//     }
//   }

//   static Future<void> acikFaturaNumarasiSil() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('acikFatNo');
//   }

//   static Future<void> lisansNumarasiKaydet(String lisans) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('lisansNo', lisans);
//   }

//   static Future<String> lisansNumarasiGetir() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? storedNumber = prefs.getString('lisansNo');
//     if (storedNumber != null) {
//       return storedNumber;
//     } else {
//       return "";
//     }
//   }

//   static Future<void> kullaniciKoduKaydet(String kod) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('setKulKod', kod);
//   }

//   static Future<String> kullaniciKoduGetir() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? storedNumber = prefs.getString('setKulKod');
//     if (storedNumber != null) {
//       return storedNumber;
//     } else {
//       return "";
//     }
//   }

//   static Future<bool> kaydedilmisMi(String _key) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     if (prefs.containsKey(_key)) {
//       return true;
//     } else {
//       return false;
//     }
//   }

//   static Future<void> filtreKaydet(List<bool> boolList, String _key) async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       // boolList'in her bir elemanını String'e çevirip tek bir String olarak kaydediyoruz.
//       String boolListString =
//           boolList.map((boolVal) => boolVal.toString()).join(',');
//       prefs.setString(_key, boolListString);
//     } catch (e) {
//       print("Kaydetme Hatası: $e");
//     }
//   }

//   static Future<List<bool>> filtreCek(String _key) async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();

//       String? boolListString = prefs.getString(_key);
//       if (boolListString == null || boolListString.isEmpty) {
//         return [];
//       }

//       List<String> boolStringList = boolListString.split(',');

//       List<bool> boolList = boolStringList.map((str) => str == 'true').toList();
//       return boolList;
//     } catch (e) {
//       print("Çekme Hatası: $e");
//       return [];
//     }
//   }

//   static Future<void> yetkiKaydet(List<bool> boolList, String _key) async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();

//       String boolListString =
//           boolList.map((boolVal) => boolVal.toString()).join(',');
//       prefs.setString(_key, boolListString);
//     } catch (e) {
//       print("Kaydetme Hatası: $e");
//     }
//   }

//   static Future<List<bool>> yetkiCek(String _key) async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();

//       String? boolListString = prefs.getString(_key);
//       if (boolListString == null || boolListString.isEmpty) {
//         return [];
//       }

//       List<String> boolStringList = boolListString.split(',');

//       List<bool> boolList = boolStringList.map((str) => str == 'true').toList();
//       listeler.plasiyerYetkileri.clear();
//       listeler.plasiyerYetkileri.addAll(boolList);
//       return boolList;
//     } catch (e) {
//       print("Çekme Hatası: $e");
//       return [];
//     }
//   }

//   static Future<void> sirketKaydet(String sirket) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     Ctanim.sirket = sirket;
//     await prefs.setString('sirket', sirket);
//   }

//   static Future<String> sirketGetir() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? sirket = prefs.getString('sirket');
//     if (sirket != null) {
//       Ctanim.sirket = sirket;
//       return sirket;
//     } else {
//       return "";
//     }
//   }

//   static Future<void> sirketSil() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('sirket');
//   }

//   static Future<void> IpKaydet(String ip) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     Ctanim.IP = ip;
//     await prefs.setString('ip', ip);
//   }

//   static Future<String> IpGetir() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? ip = prefs.getString('ip');
//     if (ip != null) {
//       Ctanim.IP = ip;
//       return ip;
//     } else {
//       return "";
//     }
//   }

//   static Future<void> IpSil() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('ip');
//   }

//   static Future<void> stokAraFiltreKaydet(int number) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('stokAraFiltre', number);
//   }

//   static Future<int> stokAraFiltreGetir() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     int? storedNumber = prefs.getInt('stokAraFiltre');
//     if (storedNumber != null) {
//       return storedNumber;
//     } else {
//       return -1;
//     }
//   }
// }
