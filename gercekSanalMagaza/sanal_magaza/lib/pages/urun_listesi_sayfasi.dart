import 'package:flutter/material.dart';
import 'package:sanal_magaza/models/urun_model.dart';
import 'package:sanal_magaza/services/urun_servisi.dart';
import 'package:sanal_magaza/widgets/arama_cubugu.dart';
import 'package:sanal_magaza/widgets/filtreleme_alani.dart';
import 'package:sanal_magaza/widgets/urun_kart.dart';
import 'package:sanal_magaza/widgets/ust_menu.dart';
import 'package:sanal_magaza/pages/urun_yonetim_sayfasi.dart';

class UrunListesiSayfasi extends StatefulWidget {
  const UrunListesiSayfasi({super.key});

  @override
  State<UrunListesiSayfasi> createState() => _UrunListesiSayfasiState();
}

class _UrunListesiSayfasiState extends State<UrunListesiSayfasi> {
  final UrunServisi _urunServisi = UrunServisi();
  List<Urun> _urunler = [];
  Map<String, bool> _seciliUrunler = {};
  String _aramaMetni = '';
  StokFiltreSecenekleri _seciliStokFiltre = StokFiltreSecenekleri.hepsi;
  bool _yukleniyor = false;

  Set<String> get _seciliUrunIdleri => _seciliUrunler.keys.where((id) => _seciliUrunler[id] == true).toSet();
  bool get _herhangiUrunSeciliMi => _seciliUrunIdleri.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _urunleriGetirVeFiltrele();
  }

  Future<void> _urunleriGetirVeFiltrele() async {
    setState(() {
      _yukleniyor = true;
      _urunler = [];
    });

    try {
      int? minAdet;
      int? maxAdet;

      switch (_seciliStokFiltre) {
        case StokFiltreSecenekleri.azStoklu:
          maxAdet = 9;
          break;
        case StokFiltreSecenekleri.yeterliStoklu:
          minAdet = 10;
          break;
        case StokFiltreSecenekleri.hepsi:
          break;
      }

      final filtrelenmisUrunler = await _urunServisi.urunAraVeFiltrele(
        _aramaMetni,
        minAdet: minAdet,
        maxAdet: maxAdet,
      );

      setState(() {
        _urunler = filtrelenmisUrunler;
        
        Map<String, bool> yeniSeciliDurum = {};
        for (var urun in filtrelenmisUrunler) {
          yeniSeciliDurum[urun.id] = _seciliUrunler[urun.id] ?? false;
        }
        _seciliUrunler = yeniSeciliDurum;
        _yukleniyor = false;
      });
    } catch (e) {
      print('HATA: Ürünler getirilirken veya filtrelenirken bir hata oluştu: $e');
      setState(() {
        _yukleniyor = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürünler yüklenirken hata oluştu: $e')),
      );
    }
  }

  void _aramaMetniDegisti(String aramaMetni) {
    setState(() {
      _aramaMetni = aramaMetni;
    });
    _urunleriGetirVeFiltrele();
  }

  void _stokFiltreDegisti(StokFiltreSecenekleri? yeniFiltre) {
    if (yeniFiltre != null) {
      setState(() {
        _seciliStokFiltre = yeniFiltre;
      });
      _urunleriGetirVeFiltrele();
    }
  }

  void _urunSecimiDegisti(String urunId, bool? seciliMi) {
    setState(() {
      _seciliUrunler[urunId] = seciliMi ?? false;
    });
  }

  void _gitButonunaBasildi() async { 
    final List<Urun> gonderilecekUrunler = _urunler
        .where((urun) => _seciliUrunler[urun.id] == true)
        .toList();

    if (gonderilecekUrunler.isNotEmpty) {
      
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UrunYonetimSayfasi(seciliUrunler: gonderilecekUrunler),
        ),
      );

      
      
      if (result == true) {
        _urunleriGetirVeFiltrele();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen önce ürün seçin!')),
      );
    }
  }

  void _barkodOkut() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Barkod okuma özelliği entegre edilecek.')),
    );
  }

  void _yazdir() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yazdırma özelliği entegre edilecek.')),
    );
  }

  void _duzenle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Düzenleme özelliği entegre edilecek.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UstMenu(
        onBarkodOkut: _barkodOkut,
        onYazdir: _yazdir,
        onDuzenle: _duzenle,
      ),
      body: Column(
        children: [
          AramaCubugu(onAramaYapildi: _aramaMetniDegisti),
          FiltrelemeAlani(
            seciliFiltre: _seciliStokFiltre,
            onFiltreDegisti: _stokFiltreDegisti,
          ),
          Expanded(
            child: _yukleniyor
                ? const Center(child: CircularProgressIndicator())
                : _urunler.isEmpty
                    ? Center(
                        child: Text(
                          '${_aramaMetni.isNotEmpty || _seciliStokFiltre != StokFiltreSecenekleri.hepsi ? "Aradığınız kriterlere uygun ürün bulunamadı." : "Henüz ürün bulunmamaktadır."}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _urunler.length,
                        itemBuilder: (context, index) {
                          final urun = _urunler[index];
                          return UrunKart(
                            urun: urun,
                            seciliMi: _seciliUrunler[urun.id] ?? false,
                            onTiklandi: (bool? seciliMi) {
                              _urunSecimiDegisti(urun.id, seciliMi);
                            },
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              onPressed: _herhangiUrunSeciliMi ? _gitButonunaBasildi : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _herhangiUrunSeciliMi ? Theme.of(context).primaryColor : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Seçili Ürünleri Yönet (Git)',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}