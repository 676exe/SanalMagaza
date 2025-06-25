
import 'dart:convert';
import 'dart:ffi';

GuncelleHataModel guncelleHataModelFromJson(String str) => GuncelleHataModel.fromJson(json.decode(str));

String guncelleHataModelToJson(GuncelleHataModel data) => json.encode(data.toJson());

class GuncelleHataModel {
    int hataType;
    int hataNo;
    dynamic hataBaslik;
    String hataMesaj;
    bool hata;
    dynamic valueTable;
    double valueDecimal;
    int valueInt;
    DateTime valueDateTime;
    dynamic valueString;
    dynamic valueJSonString;
    dynamic valueObject;

    GuncelleHataModel({
        required this.hataType,
        required this.hataNo,
        required this.hataBaslik,
        required this.hataMesaj,
        required this.hata,
        required this.valueTable,
        required this.valueDecimal,
        required this.valueInt,
        required this.valueDateTime,
        required this.valueString,
        required this.valueJSonString,
        required this.valueObject,
    });

    factory GuncelleHataModel.fromJson(Map<String, dynamic> json) => GuncelleHataModel(
        hataType: json["HataType"],
        hataNo: json["HataNo"],
        hataBaslik: json["HataBaslik"],
        hataMesaj: json["HataMesaj"],
        hata: json["Hata"],
        valueTable: json["ValueTable"],
        valueDecimal: json["ValueDecimal"],
        valueInt: json["ValueInt"],
        valueDateTime: DateTime.parse(json["ValueDateTime"]),
        valueString: json["ValueString"],
        valueJSonString: json["ValueJSonString"],
        valueObject: json["ValueObject"],
    );

    Map<String, dynamic> toJson() => {
        "HataType": hataType,
        "HataNo": hataNo,
        "HataBaslik": hataBaslik,
        "HataMesaj": hataMesaj,
        "Hata": hata,
        "ValueTable": valueTable,
        "ValueDecimal": valueDecimal,
        "ValueInt": valueInt,
        "ValueDateTime": valueDateTime.toIso8601String(),
        "ValueString": valueString,
        "ValueJSonString": valueJSonString,
        "ValueObject": valueObject,
    };
}
