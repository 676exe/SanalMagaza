
import 'package:sanal_magaza/models/urun_model.dart';
import 'package:sanal_magaza/models/siparis_kalemi.dart';

class UrunServisi {
  static List<Urun> _urunler = [
    Urun(id: '1', ad: 'OPAK', stokNumarasi: 'STK001', adet: 15, resimYolu: 'assets/beraat.PNG'),
    Urun(id: '2', ad: 'OPAK', stokNumarasi: 'STK002', adet: 5, resimYolu: 'assets/beraat.PNG'),
    Urun(id: '3', ad: 'OPAK', stokNumarasi: 'STK003', adet: 8, resimYolu: 'assets/beraat.PNG'),
    Urun(id: '4', ad: 'OPAK', stokNumarasi: 'STK004', adet: 120, resimYolu: null),
    Urun(id: '5', ad: 'OPAK', stokNumarasi: 'STK005', adet: 3, resimYolu: 'assets/beraat.PNG'),
    Urun(id: '6', ad: 'OPAK', stokNumarasi: 'STK006', adet: 25, resimYolu: 'assets/beraat.PNG'),
  ];

   
  static final Map<String, List<SiparisKalemi>> _mockSiparisKalemleri = {
    '1': [ 
      SiparisKalemi(id: '1-1', platform: 'Trendyol', talepEdilenAdet: 1, tarihSaat: DateTime(2025, 5, 1, 14, 50), durum: 'Bekliyor'),
      SiparisKalemi(id: '1-2', platform: 'Trendyol', talepEdilenAdet: 1, tarihSaat: DateTime(2025, 5, 1, 20, 20), durum: 'Bekliyor'),
      SiparisKalemi(id: '1-3', platform: 'Trendyol', talepEdilenAdet: 1, tarihSaat: DateTime(2025, 5, 1, 21, 24), durum: 'Bekliyor'),
      SiparisKalemi(id: '1-4', platform: 'Trendyol', talepEdilenAdet: 2, tarihSaat: DateTime(2025, 5, 2, 10, 0), durum: 'Eşleştirildi'), 
    ],
    '2': [ 
      SiparisKalemi(id: '2-1', platform: 'Trendyol', talepEdilenAdet: 1, tarihSaat: DateTime(2025, 5, 3, 11, 0), durum: 'Bekliyor'),
      SiparisKalemi(id: '2-2', platform: 'Trendyol', talepEdilenAdet: 1, tarihSaat: DateTime(2025, 5, 3, 15, 30), durum: 'Bekliyor'),
    ],
    '3': [ 
      SiparisKalemi(id: '3-1', platform: 'Trendyol', talepEdilenAdet: 1, tarihSaat: DateTime(2025, 5, 4, 9, 0), durum: 'Bekliyor'),
    ],
    
  };

  Future<List<Urun>> tumUrunleriGetir() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_urunler); 
  }

  Future<List<Urun>> urunAraVeFiltrele(
      String aramaMetni, {
      int? minAdet,
      int? maxAdet,
      }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    List<Urun> filtrelenmisListe = _urunler.where((urun) =>
        urun.ad.toLowerCase().contains(aramaMetni.toLowerCase()) ||
        urun.stokNumarasi.toLowerCase().contains(aramaMetni.toLowerCase())
    ).toList();

    if (minAdet != null) {
      filtrelenmisListe = filtrelenmisListe.where((urun) => urun.adet >= minAdet).toList();
    }
    if (maxAdet != null) {
      filtrelenmisListe = filtrelenmisListe.where((urun) => urun.adet <= maxAdet).toList();
    }

    return List.from(filtrelenmisListe);
  }

  
  Future<List<SiparisKalemi>> urunTrendyolSiparisleriniGetir(String urunId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_mockSiparisKalemleri[urunId] ?? []);
  }

  
  
  Future<bool> eslestirSiparisKalemi(String urunId, String siparisKalemiId) async {
    await Future.delayed(const Duration(milliseconds: 100)); 

    
    final siparisler = _mockSiparisKalemleri[urunId];
    SiparisKalemi? siparisKalemi;
    if (siparisler != null) {
      try {
        siparisKalemi = siparisler.firstWhere((sk) => sk.id == siparisKalemiId);
      } catch (e) {
        print('HATA: Sipariş kalemi bulunamadı: $siparisKalemiId');
        return false;
      }
    }

    if (siparisKalemi == null || siparisKalemi.durum != 'Bekliyor') {
      print('DEBUG: Sipariş kalemi bulunamadı veya zaten işlenmiş (durum: ${siparisKalemi?.durum}).');
      return false; 
    }

    
    final urunIndex = _urunler.indexWhere((urun) => urun.id == urunId);
    if (urunIndex == -1) {
      print('HATA: Ürün ID: $urunId bulunamadı.');
      return false; 
    }

    final urun = _urunler[urunIndex];

    
    if (urun.adet >= siparisKalemi.talepEdilenAdet) {
      
      _urunler[urunIndex] = Urun(
        id: urun.id,
        ad: urun.ad,
        stokNumarasi: urun.stokNumarasi,
        adet: urun.adet - siparisKalemi.talepEdilenAdet, 
        resimYolu: urun.resimYolu,
      );
      
      siparisKalemi.durum = 'Eşleştirildi';
      print('DEBUG: Sipariş Kalemi ID: $siparisKalemiId başarıyla eşleştirildi. Yeni stok: ${_urunler[urunIndex].adet}');
      return true; 
    } else {
      
      siparisKalemi.durum = 'Stok Yetersiz'; 
      print('UYARI: Stok yetersiz! Ürün ID: $urunId, Gerekli: ${siparisKalemi.talepEdilenAdet}, Mevcut: ${urun.adet}');
      return false; 
    }
  }

  
  Future<void> iptalEtSiparisKalemi(String urunId, String siparisKalemiId) async {
    await Future.delayed(const Duration(milliseconds: 100)); 
    final siparisler = _mockSiparisKalemleri[urunId];
    if (siparisler != null) {
      try {
        final siparisKalemi = siparisler.firstWhere((sk) => sk.id == siparisKalemiId);
        if (siparisKalemi.durum == 'Bekliyor') {
          siparisKalemi.durum = 'İptal Edildi';
          print('DEBUG: Sipariş Kalemi ID: $siparisKalemiId iptal edildi.');
        } else {
          print('UYARI: Sipariş kalemi zaten işlenmiş veya iptal edilmiş (durum: ${siparisKalemi.durum}).');
        }
      } catch (e) {
        print('HATA: İptal edilecek sipariş kalemi bulunamadı: $siparisKalemiId');
      }
    }
  }
}