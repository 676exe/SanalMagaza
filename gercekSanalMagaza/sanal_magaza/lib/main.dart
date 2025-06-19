
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanal_magaza/controller/Ctanim.dart';
import 'package:sanal_magaza/pages/login.dart';
import 'package:sanal_magaza/pages/urun_listesi_sayfasi.dart';
import 'package:sanal_magaza/controller/sharedDB.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    
    return MaterialApp(
      title: 'Ürün Yönetim Sistemi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey, 
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey, 
          foregroundColor: Colors.white, 
          elevation: 4.0, 
        ),
        cardTheme: CardTheme(
          elevation: 2.0, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), 
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0), 
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0), 
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade400), 
          ),
        ),
        
        
      ),
      home: FutureBuilder<String>(
          future: SharedDB().ipGetir(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty ) {
          return const UrunListesiSayfasi();
            } else {
          return const Login();
            }
          },
        ),
    );
  }
}
