import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sanal_magaza/models/urun_model.dart';
import 'package:sanal_magaza/models/siparis_kalemi.dart';
import 'package:sanal_magaza/services/urun_servisi.dart';

class UrunYonetimSayfasi extends StatefulWidget {
  final List<Urun> seciliUrunler;

  const UrunYonetimSayfasi({
    super.key,
    required this.seciliUrunler,
  });

  @override
  State<UrunYonetimSayfasi> createState() => _UrunYonetimSayfasiState();
}

class _UrunYonetimSayfasiState extends State<UrunYonetimSayfasi> {
  final UrunServisi _urunServisi = UrunServisi();
  
  Map<String, List<SiparisKalemi>> _urunTrendyolSiparisleri = {};
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
        final siparisler = await _urunServisi.urunTrendyolSiparisleriniGetir(urun.id);
        setState(() {
          _urunTrendyolSiparisleri[urun.id] = siparisler;
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

  
  Future<void> _eslestirSiparisKalemi(String urunId, String siparisKalemiId) async {
    final success = await _urunServisi.eslestirSiparisKalemi(urunId, siparisKalemiId);
    if (success) {
      await _trendyolSiparisleriniYukle(); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sipariş başarıyla eşleştirildi! Stok güncellendi.')),
      );
    } else {
      
      await _trendyolSiparisleriniYukle(); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Eşleştirme Başarısız: Stok yetersiz veya sipariş zaten işlenmiş.')),
      );
    }
  }

  
  Future<void> _iptalEtSiparisKalemi(String urunId, String siparisKalemiId) async {
    await _urunServisi.iptalEtSiparisKalemi(urunId, siparisKalemiId);
    await _trendyolSiparisleriniYukle(); 
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sipariş iptal edildi.')),
    );
  }

  
  Future<void> _tumunuEsle(String urunId) async {
    final siparisler = _urunTrendyolSiparisleri[urunId];
    if (siparisler != null) {
      for (var siparisKalemi in siparisler) {
        if (siparisKalemi.durum == 'Bekliyor') { 
          await _eslestirSiparisKalemi(urunId, siparisKalemi.id);
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${urunId} için tüm bekleyen siparişler eşleştirilmeye çalışıldı.')),
      );
      await _trendyolSiparisleriniYukle(); 
    }
  }

  
  bool _hasPendingSiparisKalemleri(String urunId) {
    final siparisler = _urunTrendyolSiparisleri[urunId];
    if (siparisler == null || siparisler.isEmpty) {
      return false;
    }
    return siparisler.any((siparisKalemi) => siparisKalemi.durum == 'Bekliyor');
  }

  
  Color _getDurumRengi(String durum) {
    switch (durum) {
      case 'Bekliyor':
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
      case 'Bekliyor':
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
                    final siparisKalemleri = _urunTrendyolSiparisleri[urun.id] ?? [];

                    
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
                              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                            ),
                            Text(
                              'Depodaki Ürün Adeti: ${urun.adet}', 
                              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: _hasPendingSiparisKalemleri(urun.id) 
                                    ? () => _tumunuEsle(urun.id)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _hasPendingSiparisKalemleri(urun.id)
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey, 
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                                
                                final bool isActive = siparisKalemi.durum == 'Bekliyor';

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _getDurumRengi(siparisKalemi.durum), 
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(color: Colors.grey.shade300, width: 0.8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                                    child: Row(
                                      children: [
                                        
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getDurumYaziRengi(siparisKalemi.durum).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          child: Text(
                                            siparisKalemi.durum,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: _getDurumYaziRengi(siparisKalemi.durum),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                siparisKalemi.platform, 
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                '${siparisKalemi.talepEdilenAdet} adet', 
                                                style: const TextStyle(fontSize: 14, color: Colors.black54),
                                              ),
                                              Text(
                                                DateFormat('d/M/yyyy HH:mm').format(siparisKalemi.tarihSaat),
                                                style: const TextStyle(fontSize: 12, color: Colors.black45),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        
                                        IconButton(
                                          icon: Icon(
                                            siparisKalemi.durum == 'Eşleştirildi'
                                                ? Icons.check_circle 
                                                : Icons.check_circle_outline, 
                                            color: isActive ? Colors.green[700] : Colors.grey, 
                                            size: 28,
                                          ),
                                          onPressed: isActive
                                              ? () => _eslestirSiparisKalemi(urun.id, siparisKalemi.id)
                                              : null, 
                                          tooltip: 'Eşleştir',
                                        ),
                                        
                                        IconButton(
                                          icon: Icon(
                                            siparisKalemi.durum == 'İptal Edildi'
                                                ? Icons.cancel 
                                                : Icons.cancel_outlined, 
                                            color: isActive ? Colors.red[700] : Colors.grey, 
                                            size: 28,
                                          ),
                                          onPressed: isActive
                                              ? () => _iptalEtSiparisKalemi(urun.id, siparisKalemi.id)
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
              const SnackBar(content: Text('Sayfa kapatılıyor. Tüm işlemler kayıt edildi.')),
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
