import 'package:flutter/material.dart';
import 'package:sanal_magaza/models/urun_model.dart';

class UrunDetaySayfasi extends StatelessWidget {
  final UrunModel urun;

  const UrunDetaySayfasi({super.key, required this.urun});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(urun.ad),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
                width: 200,
                height: 200,
                child: Center(
                  child: Text('Resim Yolu Yok', textAlign: TextAlign.center),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Ürün Adı: ${urun.ad}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Stok Numarası: ${urun.stokNumarasi}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Adet: ${urun.adet}', style: const TextStyle(fontSize: 16)),
            
          ],
        ),
      ),
    );
  }
}