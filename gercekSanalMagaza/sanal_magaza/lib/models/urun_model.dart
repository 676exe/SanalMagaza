class Urun {
  final String id;
  final String ad;
  final String stokNumarasi;
  final int adet;
  final String? resimYolu;

  Urun({
    required this.id,
    required this.ad,
    required this.stokNumarasi,
    required this.adet,
    this.resimYolu,
  });
}  