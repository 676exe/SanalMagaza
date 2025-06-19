import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sanal_magaza/controller/Ctanim.dart';
import 'package:sanal_magaza/models/urun_model.dart';
import 'package:sanal_magaza/models/siparis_kalemi.dart';
import 'package:sanal_magaza/services/urun_servisi.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;


class UrunYonetimSayfasi extends StatefulWidget {
  final List<UrunModel> seciliUrunler;

  const UrunYonetimSayfasi({
    super.key,
    required this.seciliUrunler,
  });

  @override
  State<UrunYonetimSayfasi> createState() => _UrunYonetimSayfasiState();
}

class _UrunYonetimSayfasiState extends State<UrunYonetimSayfasi> {
  final UrunServisi _urunServisi = UrunServisi();

  Map<int, List<OrderListModel>> _urunTrendyolSiparisleri = {};
    Map<int, String> _urunResimleri = {};

  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _trendyolSiparisleriniYukle();
  }

  Future<void> _trendyolSiparisleriniYukle() async {
    setState(() {
      _yukleniyor = true;
      
    });
    try {
      for (var urun in widget.seciliUrunler) {
        final resim = await getirTrendYolStokResim(urun.barcode, Ctanim.sessionKey);

        final siparisler = urun.orderList;
        setState(() {
          _urunTrendyolSiparisleri[urun.id] = siparisler;
          _urunResimleri[urun.id] = resim ?? '';

        });
      }
    } catch (e) {
      print('HATA: Trendyol siparişleri yüklenirken hata oluştu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Siparişler yüklenirken hata oluştu: $e')),
      );
    } finally {
      setState(() {
        _yukleniyor = false;
        
      });
    }
  }

  Future<bool> _eslestirSiparisKalemi(
      int urunId, int siparisKalemiId, int miktar, bool onayla) async {
    final success =
        await SiparisGonder(urunId, siparisKalemiId, miktar, onayla);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Sipariş başarıyla eşleştirildi! Stok güncellendi.'),
            duration: Duration(milliseconds: 1000)),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Eşleştirme Başarısız: Stok yetersiz veya sipariş zaten işlenmiş.'),
            duration: Duration(milliseconds: 100)),
      );
      return false;
    }
  }

  Future<void> _iptalEtSiparisKalemi(int urunId, int siparisKalemiId) async {
    final success =
        await _urunServisi.iptalEtSiparisKalemi(urunId, siparisKalemiId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Sipariş iptal edildi.'),
          duration: Duration(milliseconds: 100)),
    );
    setState(() {});
  }

  Future<void> _tumunuEsle(int urunId) async {
    final siparisler = _urunTrendyolSiparisleri[urunId];
    if (siparisler != null) {
      for (var siparisKalemi in siparisler) {
        if (siparisKalemi.durum == 'Bekliyor') {}
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${urunId} için tüm bekleyen siparişler eşleştirilmeye çalışıldı.')),
      );
      setState(() {});
    }
  }

  bool _hasPendingSiparisKalemleri(int urunId) {
    final siparisler = _urunTrendyolSiparisleri[urunId];
    if (siparisler == null || siparisler.isEmpty) {
      return false;
    }
    return siparisler.any((siparisKalemi) => siparisKalemi.durum == 'Bekliyor');
  }

  Color _getDurumRengi(String durum) {
    switch (durum) {
      case 'ReadyToShip':
        return Colors.blue.shade50;
      case 'Eşleştirildi':
        return Colors.green.shade50;
      case 'İptal Edildi':
        return Colors.red.shade50;
      case 'Stok Yetersiz':
        return Colors.orange.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  Color _getDurumYaziRengi(String durum) {
    switch (durum) {
      case 'ReadyToShip':
        return Colors.blue.shade800;
      case 'Eşleştirildi':
        return Colors.green.shade800;
      case 'İptal Edildi':
        return Colors.red.shade800;
      case 'Stok Yetersiz':
        return Colors.orange.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  
  Future<String?> getirTrendYolStokResim(String barcode, String sessionKey) async {
  final url = Uri.parse(Ctanim.ip);
  final headers = {
    'Content-Type': 'text/xml; charset=utf-8',
    'SOAPAction': 'http://tempuri.org/GetirTrendYolStokResim',
  };

  final body = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xmlns:xsd="http://www.w3.org/2001/XMLSchema"
               xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Header>
    <AuthHeader xmlns="http://tempuri.org/">
      <ApiKey>${Ctanim.sessionKey}</ApiKey>
    </AuthHeader>
  </soap:Header>
  <soap:Body>
    <GetirTrendYolStokResim xmlns="http://tempuri.org/">
      <Barcode>$barcode</Barcode>
    </GetirTrendYolStokResim>
  </soap:Body>
</soap:Envelope>''';

  try {
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      final document = xml.XmlDocument.parse(response.body);
      final jsonStr = document.findAllElements('GetirTrendYolStokResimResult').first.text;

      final List<dynamic> jsonList = json.decode(jsonStr);
      final imageUrl = jsonList.first["Images"][0]["Url"];
      return imageUrl;
    }
  } catch (e) {
    print("Resim getirme hatası: $e");
  }

  return null;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trendyol Sipariş Yönetimi'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : widget.seciliUrunler.isEmpty
              ? const Center(child: Text('Henüz seçili ürün bulunmamaktadır.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: widget.seciliUrunler.length,
                  itemBuilder: (context, index) {
                    final urun = widget.seciliUrunler[index];
                    final siparisKalemleri =
                        _urunTrendyolSiparisleri[urun.id] ?? [];
                                            final resim = _urunResimleri[urun.id];


                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             if (resim != null && resim.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: resim.startsWith('http')
                                    ? Image.network(resim, height: 160, fit: BoxFit.contain)
                                    : Image.memory(base64Decode(resim), height: 160, fit: BoxFit.contain),
                              ),
                            Text(
                              urun.ad,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Barkod: ${urun.stokNumarasi}',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey[700]),
                            ),
                            Text(
                              'Depodaki Ürün Adeti: ${urun.adet}',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: _hasPendingSiparisKalemleri(urun.id)
                                    ? () => _tumunuEsle(urun.id)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _hasPendingSiparisKalemleri(urun.id)
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  elevation: 2.0,
                                ),
                                child: const Text(
                                  'Tümünü Eşleştir',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (siparisKalemleri.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Bu ürün için bekleyen Trendyol siparişi bulunmamaktadır.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            else
                              ...siparisKalemleri.map((siparisKalemi) {
                                final bool isActive =
                                    siparisKalemi.durum == 'ReadyToShip';

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          _getDurumRengi(siparisKalemi.durum),
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                          color: Colors.grey.shade300,
                                          width: 0.8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 10.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getDurumYaziRengi(
                                                    siparisKalemi.durum)
                                                .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          child: Text(
                                            siparisKalemi.durum,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: _getDurumYaziRengi(
                                                  siparisKalemi.durum),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                '${siparisKalemi.talepEdilenAdet} adet',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54),
                                              ),
                                              Text(
                                                siparisKalemi.tarihSaat
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black45),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        IconButton(
                                          icon: Icon(
                                            siparisKalemi.durum ==
                                                    'Eşleştirildi'
                                                ? Icons.check_circle
                                                : Icons.check_circle_outline,
                                            color: isActive
                                                ? Colors.green[700]
                                                : Colors.grey,
                                            size: 28,
                                          ),
                                          onPressed: isActive
                                              ? () async {
                                                  var succes =
                                                      await _eslestirSiparisKalemi(
                                                          urun.id,
                                                          siparisKalemi.id,
                                                          int.parse(siparisKalemi
                                                              .talepEdilenAdet
                                                              .toString()),
                                                          true);
                                                  if(succes){
                                                    siparisKalemi.durum = "Eşleştirildi";
                                                    setState(() {
                                                      
                                                    });
                                                  }
                                                }
                                              : null,
                                          tooltip: 'Eşleştir',
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            siparisKalemi.durum ==
                                                    'İptal Edildi'
                                                ? Icons.cancel
                                                : Icons.cancel_outlined,
                                            color: isActive
                                                ? Colors.red[700]
                                                : Colors.grey,
                                            size: 28,
                                          ),
                                          onPressed: isActive
                                              ? () => _iptalEtSiparisKalemi(
                                                  urun.id, siparisKalemi.id)
                                              : null,
                                          tooltip: 'İptal Et',
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Sayfa kapatılıyor. Tüm işlemler kayıt edildi.')),
            );
            Navigator.pop(context, true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: const Text(
            'İşlemleri Kaydet ve Geri Dön',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
