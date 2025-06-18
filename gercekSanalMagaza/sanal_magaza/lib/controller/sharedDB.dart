import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sanal_magaza/controller/Ctanim.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedDB {
    FlutterSecureStorage storage =  const FlutterSecureStorage();

  Future<void> ipKaydet(String ip) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Ctanim.ip = ip;
    await prefs.setString('ip', ip);
    print('$Ctanim.ip');
  }

  Future<String> ipGetir() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ip = prefs.getString('ip');
    if (ip != null) {
      Ctanim.ip = ip;
      return ip;
    } else {
      return "";
    }
  }

  Future<void> ipSil() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('ip');
  }

  Future<void> sessionKeyKaydet(String value) async{
    storage.write(key: "api_key", value: value);
  }
  Future<void> sessionKeySil(String key) async{
    storage.delete(key: "api_key");
  }
  Future<String> sessionKeyGetir() async{
    String apikey =  await storage.read(key: "api_key") ?? "";
    return apikey;
  }
}
