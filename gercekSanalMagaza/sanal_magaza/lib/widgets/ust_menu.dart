
import 'package:flutter/material.dart';

class UstMenu extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBarkodOkut;
  final VoidCallback onYazdir;
  final VoidCallback onDuzenle;

  const UstMenu({
    super.key,
    required this.onBarkodOkut,
    required this.onYazdir,
    required this.onDuzenle,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Ürün Yönetimi', 
        style: TextStyle(
          fontWeight: FontWeight.w600, 
          fontSize: 22,
        ),
      ),
      centerTitle: false, 
      actions: [
        IconButton(
          icon: const Icon(Icons.qr_code_scanner_outlined, size: 28), 
          onPressed: onBarkodOkut,
          tooltip: 'Barkod Okut',
        ),
        IconButton(
          icon: const Icon(Icons.exit_to_app, size: 28), 
          onPressed: onYazdir,
          tooltip: 'Yazdır',
        ),
        IconButton(
          icon: const Icon(Icons.refresh, size: 28), 
          onPressed: onDuzenle,
          tooltip: 'Düzenle',
        ),
        const SizedBox(width: 8), 
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}