class Comanda {
  final int id;
  String albara;
  DateTime data;
  int botigaId;
  int producteId;
  int quantitat;
  String estat;
  String observacions;
  bool? isFromNewApp;

  Comanda({
    required this.id,
    required this.albara,
    required this.data,
    required this.botigaId,
    required this.producteId,
    required this.quantitat,
    required this.estat,
    this.observacions = '',
    this.isFromNewApp,
  });

  factory Comanda.fromJson(Map<String, dynamic> json) {
    return Comanda(
      id: json['id'] as int,
      albara: json['albara'] as String,
      data: DateTime.parse(json['data'] as String),
      botigaId: json['botiga_id'] as int,
      producteId: json['producte_id'] as int,
      quantitat: json['quantitat'] as int,
      estat: json['estat'] as String,
      observacions: json['observacions'] as String? ?? '',
      isFromNewApp: json['is_from_new_app'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'albara': albara,
        'data': '${data.year.toString().padLeft(4, '0')}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}',
        'botiga_id': botigaId,
        'producte_id': producteId,
        'quantitat': quantitat,
        'estat': estat,
        'observacions': observacions,
        'is_from_new_app': isFromNewApp,
      };

  Comanda copyWith({
    int? id,
    String? albara,
    DateTime? data,
    int? botigaId,
    int? producteId,
    int? quantitat,
    String? estat,
    String? observacions,
    bool? isFromNewApp,
  }) {
    return Comanda(
      id: id ?? this.id,
      albara: albara ?? this.albara,
      data: data ?? this.data,
      botigaId: botigaId ?? this.botigaId,
      producteId: producteId ?? this.producteId,
      quantitat: quantitat ?? this.quantitat,
      estat: estat ?? this.estat,
      observacions: observacions ?? this.observacions,
      isFromNewApp: isFromNewApp ?? this.isFromNewApp,
    );
  }

  static const List<String> estatsDisponibles = [
    'ENTREGAT',
    'RECOLLIT',
    'VENUT',
    'MAGATZEM IN',
    'DEFECTUOS',
  ];
}
