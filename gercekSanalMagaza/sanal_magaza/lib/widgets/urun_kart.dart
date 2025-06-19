import 'package:flutter/material.dart';
import 'package:sanal_magaza/models/urun_model.dart';
import 'package:sanal_magaza/controller/Ctanim.dart';

class UrunKart extends StatefulWidget {
  final UrunModel urun;
  final ValueChanged<bool?> onTiklandi;
  final bool seciliMi;

  const UrunKart({
    super.key,
    required this.urun,
    required this.onTiklandi,
    required this.seciliMi,
  });

  @override
  State<UrunKart> createState() => _UrunKartState();
}

class _UrunKartState extends State<UrunKart> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => widget.onTiklandi(!widget.seciliMi),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: widget.seciliMi,
                onChanged: widget.onTiklandi,
                activeColor: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.urun.ad,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Stok No: ${widget.urun.barcode}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      'Adet: ${widget.urun.amount}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
