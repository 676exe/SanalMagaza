import 'package:SanalMagaza/models/urun_model.dart';
import 'package:SanalMagaza/pages/login.dart';
import 'package:SanalMagaza/pages/urun_yonetim_sayfasi.dart';
import 'package:SanalMagaza/services/urun_servisi.dart';
import 'package:SanalMagaza/widgets/filtreleme_alani.dart';
import 'package:SanalMagaza/widgets/urun_kart.dart';
import 'package:SanalMagaza/widgets/ust_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UrunListesiSayfasi extends StatefulWidget {
  const UrunListesiSayfasi({super.key});

  @override
  State<UrunListesiSayfasi> createState() => _UrunListesiSayfasiState();
}

class _UrunListesiSayfasiState extends State<UrunListesiSayfasi> {
  final UrunServisi _urunServisi = UrunServisi();
  List<UrunModel> _urunler = [];
  List<UrunModel> _tumUrunler = [];
  Map<int, bool> _seciliUrunler = {};
  String _aramaMetni = '';
  StokFiltreSecenekleri _seciliStokFiltre = StokFiltreSecenekleri.hepsi;
  bool _yukleniyor = false;

  Set<int> get _seciliUrunIdleri =>
      _seciliUrunler.keys.where((id) => _seciliUrunler[id] == true).toSet();
  bool get _herhangiUrunSeciliMi => _seciliUrunIdleri.isNotEmpty;


@override
void initState() {
  super.initState();
  _urunlerGetir();
}

Future<void> _urunlerGetir() async {
  setState(() {
    _yukleniyor = true;
  });
  try {
    _tumUrunler = await _urunServisi.tumUrunleriGetir();
    _filtreleVeGuncelle();
  } catch (e) {
    setState(() {
      _yukleniyor = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ürünler yüklenirken hata oluştu: $e')),
    );
  }
}

void _filtreleVeGuncelle() {
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
  final filtrelenmisUrunler = _tumUrunler.where((urun) {
    final ad = urun.ad.toLowerCase();
    final aranan = _aramaMetni.toLowerCase();
    final stok = urun.stokNumarasi;
    bool stokDurumu = true;
    if (minAdet != null && stok < minAdet) stokDurumu = false;
    if (maxAdet != null && stok > maxAdet) stokDurumu = false;
    return ad.contains(aranan) && stokDurumu;
  }).toList();

  setState(() {
    _urunler = filtrelenmisUrunler;
    Map<int, bool> yeniSeciliDurum = {};
    for (var urun in filtrelenmisUrunler) {
      yeniSeciliDurum[urun.id] = _seciliUrunler[urun.id] ?? false;
    }
    _seciliUrunler = yeniSeciliDurum;
    _yukleniyor = false;
  });
}

void _aramaMetniDegisti(String aramaMetni) {
  setState(() {
    _aramaMetni = aramaMetni;
  });
  _filtreleVeGuncelle();
}

void _stokFiltreDegisti(StokFiltreSecenekleri? yeniFiltre) {
  if (yeniFiltre != null) {
    setState(() {
      _seciliStokFiltre = yeniFiltre;
    });
    _filtreleVeGuncelle();
  }
}

  void _gitButonunaBasildi() async {
    final List<UrunModel> gonderilecekUrunler =
        _urunler.where((urun) => _seciliUrunler[urun.id] == true).toList();

    if (gonderilecekUrunler.isNotEmpty) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              UrunYonetimSayfasi(seciliUrunler: gonderilecekUrunler),
        ),
      );
      _urunlerGetir();
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
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Login(),
        ));
  }

  void _duzenle() async{
    _urunlerGetir();
  }

  TextEditingController myController = TextEditingController();
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
          Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: myController,
        onChanged: (value) {
               _aramaMetniDegisti(value);
            },
        decoration: InputDecoration(
          labelText: 'Ürün Ara',
          hintText: 'Ürün adı veya stok numarası ile ara',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
          
        ),
        )),
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
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
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
                              setState(() {
                                _seciliUrunler[urun.id] = seciliMi ?? false;
                              });
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
                backgroundColor: _herhangiUrunSeciliMi
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
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
