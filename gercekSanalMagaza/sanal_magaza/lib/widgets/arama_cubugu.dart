
import 'package:flutter/material.dart';

class AramaCubugu extends StatelessWidget {
  final Function(String) onAramaYapildi;
  final TextEditingController _controller = TextEditingController(); 

  AramaCubugu({
    super.key,
    required this.onAramaYapildi,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0), 
      child: TextField(
        controller: _controller, 
        decoration: InputDecoration(
          labelText: 'Ürün Ara',
          hintText: 'Ürün adı veya stok numarası ile ara',
          prefixIcon: const Icon(Icons.search, color: Colors.grey), 
          suffixIcon: _controller.text.isNotEmpty 
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _controller.clear(); 
                    onAramaYapildi(''); 
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0), 
            borderSide: BorderSide.none, 
          ),
          filled: true, 
          fillColor: Colors.grey[100], 
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0), 
        ),
        onChanged: (text) {
          onAramaYapildi(text);
          
          
          
          
          
        },
      ),
    );
  }
}