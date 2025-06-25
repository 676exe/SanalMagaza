import 'package:SanalMagaza/controller/Ctanim.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedDB {
    FlutterSecureStorage storage =  const FlutterSecureStorage();

  Future<void> ipKaydet(String ip) async {
    Ctanim.ip = ip;
    await storage.write(key: "ip",value: ip);
  }

  Future<String> ipGetir() async {
    var ip = await storage.read(key: "ip");
    if (ip != null) {
      Ctanim.ip = ip;

      await sessionKeyGetir();

      return ip;
    } else {
      Ctanim.ip = "";
      return "";
    }
  }

  Future<void> sessionKeyKaydet(String value) async{
    await storage.write(key: "api_key", value: value);
    Ctanim.sessionKey = value;
  }
  Future<String> sessionKeyGetir() async{
    String apikey =  await storage.read(key: "api_key") ?? "";
    Ctanim.sessionKey = apikey;

    return apikey;
  }
}
