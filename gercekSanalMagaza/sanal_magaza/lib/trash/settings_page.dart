// import 'dart:io';

// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_connect/http/src/utils/utils.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:opak_mobil_v2/localDB/databaseHelper.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../webservis/base.dart';
// import '../stok_kart/Spinkit.dart';
// import '../widget/customAlertDialog.dart';
// import '../widget/login2.dart';
// import '../widget/kullaniciModel.dart';
// import '../widget/ctanim.dart';
// import 'package:flutter/services.dart'
//     show ByteData, PlatformException, Uint8List, rootBundle;
// import '../localDB/veritabaniIslemleri.dart';
// import '../widget/modeller/sharedPreferences.dart';

// class settings_page extends StatefulWidget {
//   const settings_page({super.key});

//   @override
//   State<settings_page> createState() => _settings_pageState();
// }

// class _settings_pageState extends State<settings_page> {
//   Future<void> clearAllPreferences() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//     print("Tüm SharedPreferences verileri silindi");
//   }

//   BaseService bs = BaseService();
//   bool resimSeciliMi = false;
//   bool islemOnayi = false;

//   int radioDeger = 0;
//   final _formKey = GlobalKey<FormState>();
//   bool yataySor = false;
//   bool disardaKullan = false;
//   List<String> donenAPIler = [];
//   TextEditingController lisans = TextEditingController();
//   TextEditingController kullaniciCont = TextEditingController();
//   TextEditingController sirket = TextEditingController();
//   TextEditingController deneme = TextEditingController();
//   bool enable = false;
//   String? sirketKullaniciDoluMu;
//   XFile? _selectedImage;

//   Future<void> _pickImage() async {
//     var pickedImage =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     setState(() {
//       _selectedImage = pickedImage;
//     });

//     if (_selectedImage != null) {
//       // Resmi veritabanına kaydet
//       final imagePath = _selectedImage!.path;
//       await VeriIslemleri().insertImage(imagePath);
//       resimSeciliMi = true;
//       setState(() {});
//     } else {
//       resimSeciliMi = false;
//       setState(() {});
//     }
//   }

//   var cihazTabletMi = false;
//   @override
//   Future<void> didChangeDependencies() async {
//     // TODO: implement didChangeDependencies
//     super.didChangeDependencies();
//     // The equivalent of the "smallestWidth" qualifier on Android.
//     var smallestDimension = MediaQuery.of(context).size.shortestSide;

// // Determine if we should use mobile layout or not. The
// // number 600 here is a common breakpoint for a typical
// // 7-inch tablet.
//     final useMobileLayout = smallestDimension < 600;
//     cihazTabletMi = !useMobileLayout;
//     yataySor = await SharedPrefsHelper.yatayDikeyGetir();
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     SharedPrefsHelper.lisansNumarasiGetir().then((value) {
//       if (value != "") {
//         lisans.text = value;
//         setState(() {});
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     var ekranBilgisi = MediaQuery.of(context);
//     double ekranYuksekligi = ekranBilgisi.size.height;
//     double ekranGenisligi = ekranBilgisi.size.width;
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Container(
//           constraints: BoxConstraints.expand(),
//           decoration: BoxDecoration(
//               image: DecorationImage(
//                   image: AssetImage("images/sj1.jpg"), fit: BoxFit.cover)),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Expanded(
//                 child: Form(
//                   key: _formKey,
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                             width: ekranGenisligi / 1.5,
//                             height: ekranYuksekligi / 5,
//                             child: Padding(
//                               padding:
//                                   EdgeInsets.only(left: ekranGenisligi / 3),
//                               child: Image.asset('images/opaklogo2.png'),
//                             )),
//                         Container(
//                           height: enable == true
//                               ? ekranYuksekligi / 1.6
//                               : ekranYuksekligi / 6.5,
//                           decoration: BoxDecoration(
//                             color: Colors.white
//                                 .withOpacity(0.5), // Şeffaf arka plan rengi
//                             borderRadius:
//                                 BorderRadius.circular(10.0), // Kenar yuvarlatma
//                           ),
//                           child: Column(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Container(
//                                   padding: EdgeInsets.all(8.0),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withOpacity(0.9),
//                                     borderRadius: BorderRadius.circular(5),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Icon(Icons.confirmation_num_outlined),
//                                       SizedBox(width: 10),
//                                       Expanded(
//                                         child: TextFormField(
//                                           cursorColor:
//                                               Color.fromARGB(255, 60, 59, 59),
//                                           controller: lisans,
//                                           onChanged: (value) {
//                                             lisans.value =
//                                                 lisans.value.copyWith(
//                                               text: value,
//                                               selection:
//                                                   TextSelection.collapsed(
//                                                       offset: value.length),
//                                             );
//                                           },
//                                           validator: (value) {
//                                             if (value == "") {
//                                               return "Bu Alan Boş Bırakılamaz";
//                                             }
//                                           },
//                                           decoration: InputDecoration(
//                                             labelText:
//                                                 "Lisans Numarası Giriniz",
//                                             labelStyle: TextStyle(
//                                               color: Color.fromARGB(
//                                                   255, 60, 59, 59),
//                                               fontSize: 15,
//                                             ),
//                                             border: InputBorder.none,
//                                           ),
//                                         ),
//                                       ),
//                                       IconButton(
//                                         onPressed: () async {
//                                           showDialog(
//                                               context: context,
//                                               builder: (context) {
//                                                 return CustomAlertDialog(
//                                                   pdfSimgesi: false,
//                                                   align: TextAlign.left,
//                                                   title: 'İşlem Onayı',
//                                                   message:
//                                                       'Bu işleme devam edildiği taktirde veri tabanı silinecektir. Onaylıyor musunuz?',
//                                                   onPres: () async {
//                                                     if (await Connectivity()
//                                                             .checkConnectivity() ==
//                                                         ConnectivityResult
//                                                             .none) {
//                                                       Future.delayed(
//                                                           Duration.zero,
//                                                           () =>
//                                                               showAlertDialogSettings1(
//                                                                 context,
//                                                                 "İnternet bağlantısı bulunamadı.",
//                                                               ));
//                                                     } else {
//                                                       //DB Yİ DROPLA
//                                                       showDialog(
//                                                         context: context,
//                                                         barrierDismissible:
//                                                             false,
//                                                         builder: (BuildContext
//                                                             context) {
//                                                           return LoadingSpinner(
//                                                             color: Colors.blue,
//                                                             message:
//                                                                 'Lisans Sorgulanıyor...',
//                                                           );
//                                                         },
//                                                       );

//                                                       String kullanici = await bs
//                                                           .kullaniciSayisiSorgula(
//                                                               LisansNo:
//                                                                   lisans.text);
//                                                       if (kullanici == "OK") {
//                                                         await SharedPrefsHelper
//                                                             .IpSil();
//                                                         donenAPIler = await bs
//                                                             .makeSoapRequest(
//                                                                 lisans.text);

//                                                         Navigator.pop(context);

//                                                         if (donenAPIler.length >
//                                                             1) {
//                                                           /*
//                                                 if (kayitliLisansNo != "") {
//                                                   if (kayitliLisansNo !=
//                                                       lisans.text) {
                                                        
//                                                     DatabaseHelper dt =
//                                                         DatabaseHelper("opak" +
//                                                             lisans.text +
//                                                             ".db");

//                                                     Ctanim.db =
//                                                         await dt.database();
//                                                     //  showAlertDialogForLisans(context, lisans.text);
                                                    
//                                                   } else {
//                                                     /*
//                                                     DatabaseHelper dt =
//                                                         DatabaseHelper("opak" +
//                                                             lisans.text +
//                                                             ".db");
//                                                     Ctanim.db =
//                                                         await dt.database();
//                                                         */
//                                                     String tempKulKod =
//                                                         await SharedPrefsHelper
//                                                             .kullaniciKoduGetir();
//                                                     String tempSirket =
//                                                         await SharedPrefsHelper
//                                                             .sirketGetir();
//                                                     if (tempKulKod != "" &&
//                                                         tempSirket != "") {
//                                                       kullaniciCont.text =
//                                                           tempKulKod;
//                                                       sirket.text = tempSirket;
//                                                     }
//                                                   }
//                                                 } 
//                                                 */
//                                                           clearAllPreferences();
//                                                           await DatabaseHelper
//                                                               .deleteDatabase();

//                                                           DatabaseHelper dt =
//                                                               DatabaseHelper(
//                                                                   "opak" +
//                                                                       lisans
//                                                                           .text +
//                                                                       ".db");
//                                                           Ctanim.db = await dt
//                                                               .database();

//                                                           enable = true;
//                                                           await SharedPrefsHelper
//                                                               .lisansNumarasiKaydet(
//                                                                   lisans.text);
//                                                           // ŞİRKETLE KULLANICI KODU KAYDET
//                                                           setState(() {});
//                                                         } else {
//                                                           Future.delayed(
//                                                               Duration.zero,
//                                                               () =>
//                                                                   showAlertDialogSettings1(
//                                                                     context,
//                                                                     "İp Bilgisi Alınamadı.",
//                                                                   ));
//                                                         }
//                                                       } else {
//                                                         print("KULAŞ");
//                                                         Future.delayed(
//                                                             Duration.zero,
//                                                             () =>
//                                                                 showAlertDialogSettings1(
//                                                                   context,
//                                                                   ikinciGeri:
//                                                                       true,
//                                                                   "Kullanıcı sayısı aşılmış. Mesaj: $kullanici",
//                                                                 ));
//                                                       }
//                                                     }
//                                                     Navigator.pop(context);
//                                                   },
//                                                   secondButtonText: "İptal",
//                                                   onSecondPress: () {
//                                                     Navigator.pop(context);
//                                                   },
//                                                   buttonText: 'Onay',
//                                                 );
//                                               });

//                                           /*
//                                           if (await Connectivity()
//                                                   .checkConnectivity() ==
//                                               ConnectivityResult.none) {
//                                             showAlertDialog(
//                                               context,
//                                               "İnternet bağlantısı bulunamadı.",
//                                             );
//                                           } else {
                                         
//                                             //DB Yİ DROPLA
//                                             showDialog(
//                                               context: context,
//                                               barrierDismissible: false,
//                                               builder: (BuildContext context) {
//                                                 return LoadingSpinner(
//                                                   color: Colors.blue,
//                                                   message:
//                                                       'Lisans Sorgulanıyor...',
//                                                 );
//                                               },
//                                             );

//                                             String kullanici =
//                                                 await bs.kullaniciSayisiSorgula(
//                                                     LisansNo: lisans.text);
//                                             if (kullanici == "OK") {
//                                               await SharedPrefsHelper.IpSil();
//                                               donenAPIler = await bs
//                                                   .makeSoapRequest(lisans.text);

//                                               Navigator.pop(context);

//                                               if (donenAPIler.length > 1) {
//                                             /*
//                                                 if (kayitliLisansNo != "") {
//                                                   if (kayitliLisansNo !=
//                                                       lisans.text) {
                                                        
//                                                     DatabaseHelper dt =
//                                                         DatabaseHelper("opak" +
//                                                             lisans.text +
//                                                             ".db");

//                                                     Ctanim.db =
//                                                         await dt.database();
//                                                     //  showAlertDialogForLisans(context, lisans.text);
                                                    
//                                                   } else {
//                                                     /*
//                                                     DatabaseHelper dt =
//                                                         DatabaseHelper("opak" +
//                                                             lisans.text +
//                                                             ".db");
//                                                     Ctanim.db =
//                                                         await dt.database();
//                                                         */
//                                                     String tempKulKod =
//                                                         await SharedPrefsHelper
//                                                             .kullaniciKoduGetir();
//                                                     String tempSirket =
//                                                         await SharedPrefsHelper
//                                                             .sirketGetir();
//                                                     if (tempKulKod != "" &&
//                                                         tempSirket != "") {
//                                                       kullaniciCont.text =
//                                                           tempKulKod;
//                                                       sirket.text = tempSirket;
//                                                     }
//                                                   }
//                                                 } 
//                                                 */
//                                             await DatabaseHelper.deleteDatabase();
                                                
//                                                   DatabaseHelper dt =
//                                                       DatabaseHelper("opak" +
//                                                           lisans.text +
//                                                           ".db");
//                                                   Ctanim.db =
//                                                       await dt.database();
                                              
//                                                 enable = true;
//                                                 await SharedPrefsHelper
//                                                     .lisansNumarasiKaydet(
//                                                         lisans.text);
//                                                         // ŞİRKETLE KULLANICI KODU KAYDET
//                                                 setState(() {});
//                                               } else {
//                                                 showAlertDialog(
//                                                   context,
//                                                   "İp Bilgisi Alınamadı.",
//                                                 );
//                                               }
//                                             } else {
//                                               showAlertDialog(
//                                                 context,
//                                                 ikinciGeri: true,
//                                                 "Kullanıcı sayısı aşılmış. Mesaj: $kullanici",
//                                               );
//                                             }
//                                           }
//                                           */
//                                         },
//                                         icon: Icon(Icons.search),
//                                         color: Color.fromARGB(255, 60, 59, 59),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               enable == true
//                                   ? Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Container(
//                                         padding: EdgeInsets.all(8.0),
//                                         decoration: BoxDecoration(
//                                           color: Colors.white.withOpacity(0.9),
//                                           borderRadius:
//                                               BorderRadius.circular(5),
//                                         ),
//                                         child: Row(
//                                           children: [
//                                             Icon(
//                                               Icons.assignment_ind,
//                                               color: enable == true
//                                                   ? Colors.black
//                                                   : Colors.grey,
//                                             ),
//                                             SizedBox(width: 10),
//                                             Expanded(
//                                               child: TextFormField(
//                                                 enabled: enable,
//                                                 cursorColor: Color.fromARGB(
//                                                     255, 60, 59, 59),
//                                                 controller: kullaniciCont,
//                                                 onChanged: (value) {
//                                                   kullaniciCont.value =
//                                                       kullaniciCont.value
//                                                           .copyWith(
//                                                     text: value,
//                                                     selection:
//                                                         TextSelection.collapsed(
//                                                             offset:
//                                                                 value.length),
//                                                   );
//                                                 },
//                                                 validator: (value) {
//                                                   if (value == "") {
//                                                     return "Bu Alan Boş Bırakılamaz";
//                                                   }
//                                                 },
//                                                 decoration: InputDecoration(
//                                                   labelText:
//                                                       "Kullanıcı Kodu Giriniz",
//                                                   labelStyle: TextStyle(
//                                                     color: Color.fromARGB(
//                                                         255, 60, 59, 59),
//                                                     fontSize: 15,
//                                                   ),
//                                                   border: InputBorder.none,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     )
//                                   : Container(),
//                               enable == true
//                                   ? Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Container(
//                                         padding: EdgeInsets.all(8.0),
//                                         decoration: BoxDecoration(
//                                           color: Colors.white.withOpacity(0.9),
//                                           borderRadius:
//                                               BorderRadius.circular(5),
//                                         ),
//                                         child: Row(
//                                           children: [
//                                             Icon(
//                                               Icons.business,
//                                               color: enable == true
//                                                   ? Colors.black
//                                                   : Colors.grey,
//                                             ),
//                                             SizedBox(width: 10),
//                                             Expanded(
//                                               child: TextFormField(
//                                                 enabled: enable,
//                                                 cursorColor: Color.fromARGB(
//                                                     255, 60, 59, 59),
//                                                 controller: sirket,
//                                                 onChanged: (value) {
//                                                   sirket.value =
//                                                       sirket.value.copyWith(
//                                                     text: value,
//                                                     selection:
//                                                         TextSelection.collapsed(
//                                                             offset:
//                                                                 value.length),
//                                                   );
//                                                 },
//                                                 validator: (value) {
//                                                   if (value == "") {
//                                                     return "Bu Alan Boş Bırakılamaz";
//                                                   }
//                                                 },
//                                                 decoration: InputDecoration(
//                                                   labelText:
//                                                       "Şirket İsmi Giriniz",
//                                                   labelStyle: TextStyle(
//                                                     color: Color.fromARGB(
//                                                         255, 60, 59, 59),
//                                                     fontSize: 15,
//                                                   ),
//                                                   border: InputBorder.none,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     )
//                                   : Container(),

//                               /*
//                           SizedBox(
//                             width: ekranGenisligi / 1.5,
//                             height: ekranYuksekligi / 15,
//                             child: RadioListTile(
//                               activeColor: Colors.white,
//                               title: Text(
//                                 "Yazıcı",
//                                 style: TextStyle(fontSize: 18, color: Colors.white),
//                               ),
//                               value: 1,
//                               groupValue: radioDeger,
//                               onChanged: (int? veri) {
//                                 setState(() {
//                                   radioDeger = veri!;
//                                 });
//                               },
//                             ),
//                           ),
//                           SizedBox(
//                             width: ekranGenisligi / 1.5,
//                             height: ekranYuksekligi / 15,
//                             child: RadioListTile(
//                               activeColor: Colors.white,
//                               title: Text(
//                                 "Termal Yazıcı, Post vb",
//                                 style: TextStyle(fontSize: 18, color: Colors.white),
//                               ),
//                               value: 2,
//                               groupValue: radioDeger,
//                               onChanged: (int? veri) {
//                                 setState(() {
//                                   radioDeger = veri!;
//                                 });
//                               },
//                             ),
//                           ),
//                           */

//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   cihazTabletMi == true
//                                       ? SizedBox(
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: Container(
//                                               child: Row(
//                                                 children: [
//                                                   Checkbox(
//                                                     activeColor: Color.fromRGBO(
//                                                         81, 82, 83, 1),
//                                                     side: BorderSide(
//                                                         color: Colors.black),
//                                                     //child: Text(,

//                                                     value: yataySor,

//                                                     onChanged:
//                                                         (bool? value) async {
//                                                       setState(() {
//                                                         yataySor = value!;
//                                                       });
//                                                       await SharedPrefsHelper
//                                                           .yatayDikeyKaydet(
//                                                               yataySor);
//                                                     },
//                                                   ),
//                                                   Expanded(
//                                                       child: Text(
//                                                     "Uygulamayı Yatay Kullan (Tabletler için önerilir. Değişiklikleri görmek için uygulamayı yeniden başlatın.)",
//                                                     maxLines: 3,
//                                                   )),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         )
//                                       : Container(),
//                                   enable == true
//                                       ? SizedBox(
//                                           width: ekranGenisligi * .4,
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: Container(
//                                               child: Row(
//                                                 children: [
//                                                   Checkbox(
//                                                     activeColor: Color.fromRGBO(
//                                                         81, 82, 83, 1),
//                                                     side: BorderSide(
//                                                         color: Colors.black),
//                                                     value: disardaKullan,
//                                                     onChanged:
//                                                         (bool? value) async {
//                                                       setState(() {
//                                                         disardaKullan = value!;
//                                                       });
//                                                     },
//                                                   ),
//                                                   Expanded(
//                                                       child: Text(
//                                                     "Dışarda Kullan",
//                                                     maxLines: 3,
//                                                   )),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         )
//                                       : Container()
//                                 ],
//                               ),
//                               Spacer(),
//                               enable == true
//                                   ? Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       // crossAxisAlignment: CrossAxisAlignment.center,
//                                       children: [
//                                         Padding(
//                                           padding: const EdgeInsets.only(
//                                               bottom: 20.0),
//                                           child: SizedBox(
//                                             width: ekranGenisligi / 1.2,
//                                             height: ekranYuksekligi / 12,
//                                             child: ElevatedButton(
//                                               child: Text(
//                                                 "Kaydet",
//                                                 style: TextStyle(fontSize: 20),
//                                               ),
//                                               style: ElevatedButton.styleFrom(
//                                                   foregroundColor: Colors.white,
//                                                   backgroundColor:
//                                                       Color.fromRGBO(
//                                                           192, 192, 192, 1),
//                                                   shadowColor: Colors.black,
//                                                   elevation: 10,
//                                                   shape: RoundedRectangleBorder(
//                                                     borderRadius:
//                                                         BorderRadius.all(
//                                                             Radius.circular(
//                                                                 10.0)),
//                                                   )),
//                                               onPressed: () async {
//                                                 if (_formKey.currentState!
//                                                     .validate()) {
//                                                   _formKey.currentState!.save();
//                                                   showDialog(
//                                                     context: context,
//                                                     barrierDismissible: false,
//                                                     builder:
//                                                         (BuildContext context) {
//                                                       return LoadingSpinner(
//                                                         color: Colors.black,
//                                                         message: disardaKullan ==
//                                                                 false
//                                                             ? "Program İçerde Kullanılacak.\nKullanıcı ve Şirket Bilgileri Sorgulanıyor..."
//                                                             : "Program Dışarda Kullanılacak.\nKullanıcı ve Şirket Bilgileri Sorgulanıyor...",
//                                                       );
//                                                     },
//                                                   );
//                                                   KullaniciModel.clearUser();  
//                                                   Ctanim.kullanici = null;
//                                                   if (disardaKullan == false) {
//                                                     if (donenAPIler[0] != "") {
//                                                       sirketKullaniciDoluMu =
//                                                           await bs.getKullanicilar(
//                                                               IP: donenAPIler[
//                                                                   0],
//                                                               kullaniciKodu:
//                                                                   kullaniciCont
//                                                                       .text,
//                                                               sirket:
//                                                                   sirket.text);

//                                                       if (sirketKullaniciDoluMu ==
//                                                           "") {
//                                                         print("o dan aldım");
//                                                         await bs
//                                                             .getirPlasiyerYetki(
//                                                                 sirket:
//                                                                     sirket.text,
//                                                                 kullaniciKodu:
//                                                                     kullaniciCont
//                                                                         .text,
//                                                                 IP: donenAPIler[
//                                                                     0]);
//                                                         await SharedPrefsHelper
//                                                             .saveList([]);

//                                                         await SharedPrefsHelper
//                                                             .IpKaydet(
//                                                                 donenAPIler[0]);
//                                                         print(Ctanim.IP
//                                                             .toString());
//                                                         await KullaniciModel
//                                                             .saveUser(Ctanim
//                                                                 .kullanici!);
//                                                         await SharedPrefsHelper
//                                                             .sirketSil();
//                                                         SharedPrefsHelper
//                                                             .sirketKaydet(
//                                                                 sirket.text);
//                                                         await SharedPrefsHelper
//                                                             .kullaniciKoduKaydet(
//                                                                 kullaniciCont
//                                                                     .text);
//                                                         showDialog(
//                                                             context: context,
//                                                             builder: (context) {
//                                                               return CustomAlertDialog(
//                                                                 textColor:
//                                                                     Colors
//                                                                         .green,
//                                                                 align: TextAlign
//                                                                     .left,
//                                                                 title:
//                                                                     'Kayıt Başarılı',
//                                                                 message:
//                                                                     'Şirket ve Kullanıcı Bilgileri Başarıyla Alındı. Giriş Sayfasına Yönlendiriliyorsunuz.',
//                                                                 onPres: () {
//                                                                   Navigator
//                                                                       .push(
//                                                                     context,
//                                                                     MaterialPageRoute(
//                                                                         builder: (context) =>
//                                                                             LoginPage(
//                                                                               title: '',
//                                                                             )),
//                                                                   );
//                                                                   setState(
//                                                                       () {});
//                                                                 },
//                                                                 buttonText:
//                                                                     'Tamam',
//                                                               );
//                                                             });
//                                                       } else {
//                                                         Future.delayed(
//                                                             Duration.zero,
//                                                             () =>
//                                                                 showAlertDialogSettings1(
//                                                                   ikinciGeri:
//                                                                       true,
//                                                                   context,
//                                                                   sirketKullaniciDoluMu!,
//                                                                 ));
//                                                       }
//                                                     } else {
//                                                       Future.delayed(
//                                                           Duration.zero,
//                                                           () =>
//                                                               showAlertDialogSettings1(
//                                                                 ikinciGeri:
//                                                                     true,
//                                                                 context,
//                                                                 "İç IP tanımlanmamış. Lütfen yetkli bayiniz ile iletişime geçiniz",
//                                                               ));
//                                                     }
//                                                   } else {
//                                                     if (donenAPIler[1] != "") {
//                                                       sirketKullaniciDoluMu =
//                                                           await bs.getKullanicilar(
//                                                               IP: donenAPIler[
//                                                                   1],
//                                                               kullaniciKodu:
//                                                                   kullaniciCont
//                                                                       .text,
//                                                               sirket:
//                                                                   sirket.text);

//                                                       if (sirketKullaniciDoluMu ==
//                                                           "") {
//                                                         print("1 dan aldım");
//                                                         await bs
//                                                             .getirPlasiyerYetki(
//                                                                 sirket:
//                                                                     sirket.text,
//                                                                 kullaniciKodu:
//                                                                     kullaniciCont
//                                                                         .text,
//                                                                 IP: donenAPIler[
//                                                                     1]);
//                                                         await SharedPrefsHelper
//                                                             .saveList([]);

//                                                         await SharedPrefsHelper
//                                                             .IpKaydet(
//                                                                 donenAPIler[1]);
//                                                         print(Ctanim.IP
//                                                             .toString());
//                                                         await KullaniciModel
//                                                             .saveUser(Ctanim
//                                                                 .kullanici!);
//                                                         await SharedPrefsHelper
//                                                             .sirketSil();
//                                                         SharedPrefsHelper
//                                                             .sirketKaydet(
//                                                                 sirket.text);
//                                                         await SharedPrefsHelper
//                                                             .kullaniciKoduKaydet(
//                                                                 kullaniciCont
//                                                                     .text);
//                                                         showDialog(
//                                                             context: context,
//                                                             builder: (context) {
//                                                               return CustomAlertDialog(
//                                                                 textColor:
//                                                                     Colors
//                                                                         .green,
//                                                                 align: TextAlign
//                                                                     .left,
//                                                                 title:
//                                                                     'Kayıt Başarılı',
//                                                                 message:
//                                                                     'Şirket ve Kullanıcı Bilgileri Başarıyla Alındı. Giriş Sayfasına Yönlendiriliyorsunuz.',
//                                                                 onPres: () {
//                                                                   Navigator
//                                                                       .push(
//                                                                     context,
//                                                                     MaterialPageRoute(
//                                                                         builder: (context) =>
//                                                                             LoginPage(
//                                                                               title: '',
//                                                                             )),
//                                                                   );
//                                                                   setState(
//                                                                       () {});
//                                                                 },
//                                                                 buttonText:
//                                                                     'Tamam',
//                                                               );
//                                                             });
//                                                       } else {
//                                                         Future.delayed(
//                                                             Duration.zero,
//                                                             showAlertDialogSettings1(
//                                                               ikinciGeri: true,
//                                                               context,
//                                                               sirketKullaniciDoluMu!,
//                                                             ));
//                                                       }
//                                                     } else {
//                                                       Future.delayed(
//                                                           Duration.zero,
//                                                           () =>
//                                                               showAlertDialogSettings1(
//                                                                 ikinciGeri:
//                                                                     true,
//                                                                 context,
//                                                                 "Dış IP tanımlanmamış. Lütfen yetkli bayiniz ile iletişime geçiniz",
//                                                               ));
//                                                     }

//                                                     /*
                                                  
//                                                     */
//                                                   }
//                                                 }
//                                               },
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     )
//                                   : Container(),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(top: 8.0),
//         child: FloatingActionButton(
//           onPressed: () => Navigator.pop(context),
//           child: Icon(
//             Icons.arrow_back,
//             size: 28,
//           ),
//           backgroundColor: Color.fromRGBO(181, 182, 184, 1),
//           mini: true,
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
//     );
//   }
// }

// showAlertDialogSettings1(BuildContext context, String mesaj,
//     {bool ikinciGeri = false}) {
//   // set up the button
//   Widget okButton = TextButton(
//     child: Text("OK"),
//     onPressed: () {
//       if (ikinciGeri == true) {
//         Get.back();
//       }
//       Get.back();
//     },
//   );

//   // set up the AlertDialog
//   AlertDialog alert = AlertDialog(
//     title: Text(
//       "Hatalı İşlem!",
//       style: TextStyle(color: Colors.red),
//     ),
//     content: Text(mesaj),
//     actions: [
//       okButton,
//     ],
//   );

//   // show the dialog
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return alert;
//     },
//   );
// }

// showAlertDialogForLisans(BuildContext context, String lisansText) {
//   // set up the buttons
//   Widget cancelButton = TextButton(
//     child: Text("İptal"),
//     onPressed: () {
//       Navigator.pop(context);
//     },
//   );
//   Widget continueButton = TextButton(
//     child: Text("Devam"),
//     onPressed: () async {
//       try {} on PlatformException catch (e) {
//         print(e);
//       }
//       Navigator.pop(context);
//     },
//   );

//   // set up the AlertDialog
//   AlertDialog alert = AlertDialog(
//     title: Text("Bilgilendirme"),
//     content: Text(
//         "Programda lisans değişimi algılandı. Veri tabanı değiştirilecek. Devam etmek istiyor musunuz?"),
//     actions: [
//       cancelButton,
//       continueButton,
//     ],
//   );

//   // show the dialog
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return alert;
//     },
//   );
// }
