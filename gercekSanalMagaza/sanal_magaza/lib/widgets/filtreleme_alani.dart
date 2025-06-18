
import 'package:flutter/material.dart';

enum StokFiltreSecenekleri {
  hepsi,
  azStoklu, 
  yeterliStoklu, 
}

class FiltrelemeAlani extends StatelessWidget {
  final StokFiltreSecenekleri seciliFiltre;
  final ValueChanged<StokFiltreSecenekleri?> onFiltreDegisti;

  const FiltrelemeAlani({
    super.key,
    required this.seciliFiltre,
    required this.onFiltreDegisti,
  });

  String _filtreMetniGetir(StokFiltreSecenekleri filtre) {
    switch (filtre) {
      case StokFiltreSecenekleri.hepsi:
        return 'Tüm Ürünler';
      case StokFiltreSecenekleri.azStoklu:
        return 'Az Stoklu (<10 Adet)'; 
      case StokFiltreSecenekleri.yeterliStoklu:
        return 'Yeterli Stoklu (>=10 Adet)'; 
      default:
        return 'Tüm Ürünler';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), 
      child: Row(
        children: [
          const Text(
            'Filtrele:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0), 
                border: Border.all(color: Colors.grey.shade300), 
                color: Colors.white, 
              ),
              child: DropdownButtonHideUnderline( 
                child: DropdownButton<StokFiltreSecenekleri>(
                  isExpanded: true,
                  value: seciliFiltre,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey), 
                  elevation: 2, 
                  style: const TextStyle(color: Colors.black87, fontSize: 15), 
                  onChanged: onFiltreDegisti,
                  items: StokFiltreSecenekleri.values.map((StokFiltreSecenekleri filtre) {
                    return DropdownMenuItem<StokFiltreSecenekleri>(
                      value: filtre,
                      child: Text(_filtreMetniGetir(filtre)),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}