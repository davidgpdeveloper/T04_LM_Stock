class Botiga {
  final int id;
  String nom;
  String nomComplet;
  String nif;
  String adreca;
  String poblacio;
  String codiPostal;
  String mail;
  String telefon;
  String observacions;

  Botiga({
    required this.id,
    required this.nom,
    this.nomComplet = '',
    this.nif = '',
    this.adreca = '',
    this.poblacio = '',
    this.codiPostal = '',
    this.mail = '',
    this.telefon = '',
    this.observacions = '',
  });

  factory Botiga.fromJson(Map<String, dynamic> json) {
    return Botiga(
      id: json['id'] as int,
      nom: json['nom'] as String,
      nomComplet: json['nom_complet'] as String? ?? '',
      nif: json['nif'] as String? ?? '',
      adreca: json['adreca'] as String? ?? '',
      poblacio: json['poblacio'] as String? ?? '',
      codiPostal: json['codi_postal'] as String? ?? '',
      mail: json['mail'] as String? ?? '',
      telefon: json['telefon'] as String? ?? '',
      observacions: json['observacions'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'nom_complet': nomComplet,
        'nif': nif,
        'adreca': adreca,
        'poblacio': poblacio,
        'codi_postal': codiPostal,
        'mail': mail,
        'telefon': telefon,
        'observacions': observacions,
      };

  Botiga copyWith({
    int? id,
    String? nom,
    String? nomComplet,
    String? nif,
    String? adreca,
    String? poblacio,
    String? codiPostal,
    String? mail,
    String? telefon,
    String? observacions,
  }) {
    return Botiga(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      nomComplet: nomComplet ?? this.nomComplet,
      nif: nif ?? this.nif,
      adreca: adreca ?? this.adreca,
      poblacio: poblacio ?? this.poblacio,
      codiPostal: codiPostal ?? this.codiPostal,
      mail: mail ?? this.mail,
      telefon: telefon ?? this.telefon,
      observacions: observacions ?? this.observacions,
    );
  }
}
