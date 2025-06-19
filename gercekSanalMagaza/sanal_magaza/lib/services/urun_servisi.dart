
import 'package:sanal_magaza/models/urun_model.dart';
import 'package:sanal_magaza/models/siparis_kalemi.dart';

class UrunServisi {
  static List<UrunModel> _urunler = [
  ];

   
  static final Map<String, List<OrderListModel>> _mockSiparisKalemleri = {
    
  };

  Future<List<UrunModel>> tumUrunleriGetir() async {
    _urunler = await UrunGetir();
    return List.from(_urunler); 
  }

  Future<List<UrunModel>> urunAraVeFiltrele(
      String aramaMetni, {
      int? minAdet,
      int? maxAdet,
      }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    List<UrunModel> filtrelenmisListe = _urunler.where((urun) =>
        urun.ad.toLowerCase().contains(aramaMetni.toLowerCase()) ||
        urun.barcode.toLowerCase().contains(aramaMetni.toLowerCase())
    ).toList();

    if (minAdet != null) {
      filtrelenmisListe = filtrelenmisListe.where((urun) => urun.amount >= minAdet).toList();
    }
    if (maxAdet != null) {
      filtrelenmisListe = filtrelenmisListe.where((urun) => urun.amount <= maxAdet).toList();
    }

    return List.from(filtrelenmisListe);
  }

  
  Future<List<OrderListModel>> urunTrendyolSiparisleriniGetir(int urunId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_mockSiparisKalemleri[urunId] ?? []);
  }

  
  
  Future<bool> eslestirSiparisKalemi(int urunId, int siparisKalemiId) async {
    await Future.delayed(const Duration(milliseconds: 100)); 

    
    final siparisler = _mockSiparisKalemleri[urunId];
    OrderListModel? siparisKalemi;
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

    
    final urunIndex = _urunler.indexWhere((urun) => urun.barcode == urunId);
    if (urunIndex == -1) {
      print('HATA: Ürün ID: $urunId bulunamadı.');
      return false; 
    }

    final urun = _urunler[urunIndex];

    
    if (urun.amount >= siparisKalemi.talepEdilenAdet) {
      
      _urunler[urunIndex] = UrunModel(
        barcode: urun.barcode,
        ad: urun.ad,
        productCode: urun.productCode,
        amount: urun.amount - siparisKalemi.talepEdilenAdet,
        price: urun.price,
        id: urun.id,
        stokNumarasi: urun.stokNumarasi,
        orderList: urun.orderList,
        adet: urun.adet
      );
      
      siparisKalemi.durum = 'Eşleştirildi';
      print('DEBUG: Sipariş Kalemi ID: $siparisKalemiId başarıyla eşleştirildi. Yeni stok: ${_urunler[urunIndex].amount}');
      return true; 
    } else {
      
      siparisKalemi.durum = 'Stok Yetersiz'; 
      print('UYARI: Stok yetersiz! Ürün ID: $urunId, Gerekli: ${siparisKalemi.talepEdilenAdet}, Mevcut: ${urun.amount}');
      return false; 
    }
  }

  
  Future<void> iptalEtSiparisKalemi(int urunId, int siparisKalemiId) async {
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