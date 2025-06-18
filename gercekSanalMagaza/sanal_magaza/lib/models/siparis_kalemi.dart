
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
class OrderList {
    int id;
    String status;
    String orderNumber;
    int orderDate;
    int stockCount;

    OrderList({
        required this.id,
        required this.status,
        required this.orderNumber,
        required this.orderDate,
        required this.stockCount,
    });

    factory OrderList.fromJson(Map<String, dynamic> json) => OrderList(
        id: json["id"],
        status: json["status"],
        orderNumber: json["orderNumber"],
        orderDate: json["orderDate"],
        stockCount: json["stockCount"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "orderNumber": orderNumber,
        "orderDate": orderDate,
        "stockCount": stockCount,
    };
}
