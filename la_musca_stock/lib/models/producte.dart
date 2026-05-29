class Producte {
  final int id;
  String nom;
  int quantitat;
  String descripcio;
  String? imatgeBase64;

  Producte({
    required this.id,
    required this.nom,
    this.quantitat = 0,
    this.descripcio = '',
    this.imatgeBase64,
  });

  factory Producte.fromJson(Map<String, dynamic> json) {
    return Producte(
      id: json['id'] as int,
      nom: json['nom'] as String,
      quantitat: json['quantitat'] as int? ?? 0,
      descripcio: json['descripcio'] as String? ?? '',
      imatgeBase64: json['imatge'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'quantitat': quantitat,
        'descripcio': descripcio,
        'imatge': imatgeBase64,
      };

  Producte copyWith({
    int? id,
    String? nom,
    int? quantitat,
    String? descripcio,
    String? imatgeBase64,
  }) {
    return Producte(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      quantitat: quantitat ?? this.quantitat,
      descripcio: descripcio ?? this.descripcio,
      imatgeBase64: imatgeBase64 ?? this.imatgeBase64,
    );
  }
}
