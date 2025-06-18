
class SiparisKalemi {
  final String id; 
  final String platform; 
  final int talepEdilenAdet; 
  final DateTime tarihSaat;
  String durum; 

  SiparisKalemi({
    required this.id,
    required this.platform,
    required this.talepEdilenAdet,
    required this.tarihSaat,
    this.durum = 'Bekliyor', 
  });
}