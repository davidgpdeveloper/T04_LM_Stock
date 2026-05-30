class Botiga {
  final int id;
  String nom;
  String nomFiscal;
  String nif;
  String adreca;
  String poblacio;
  String codiPostal;
  String mail;
  String telefon;
  String observacions;
  String? imatgeBase64;
  bool? isFromNewApp;

  Botiga({
    required this.id,
    required this.nom,
    this.nomFiscal = '',
    this.nif = '',
    this.adreca = '',
    this.poblacio = '',
    this.codiPostal = '',
    this.mail = '',
    this.telefon = '',
    this.observacions = '',
    this.imatgeBase64,
    this.isFromNewApp,
  });

  factory Botiga.fromJson(Map<String, dynamic> json) {
    return Botiga(
      id: json['id'] as int,
      nom: json['nom'] as String,
      nomFiscal: json['nom_fiscal'] as String? ?? '',
      nif: json['nif'] as String? ?? '',
      adreca: json['adreca'] as String? ?? '',
      poblacio: json['poblacio'] as String? ?? '',
      codiPostal: json['codi_postal'] as String? ?? '',
      mail: json['mail'] as String? ?? '',
      telefon: json['telefon'] as String? ?? '',
      observacions: json['observacions'] as String? ?? '',
      imatgeBase64: json['imatge'] as String?,
      isFromNewApp: json['is_from_new_app'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'nom_fiscal': nomFiscal,
        'nif': nif,
        'adreca': adreca,
        'poblacio': poblacio,
        'codi_postal': codiPostal,
        'mail': mail,
        'telefon': telefon,
        'observacions': observacions,
        'imatge': imatgeBase64,
        'is_from_new_app': isFromNewApp,
      };

  Botiga copyWith({
    int? id,
    String? nom,
    String? nomFiscal,
    String? nif,
    String? adreca,
    String? poblacio,
    String? codiPostal,
    String? mail,
    String? telefon,
    String? observacions,
    String? imatgeBase64,
    bool? isFromNewApp,
  }) {
    return Botiga(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      nomFiscal: nomFiscal ?? this.nomFiscal,
      nif: nif ?? this.nif,
      adreca: adreca ?? this.adreca,
      poblacio: poblacio ?? this.poblacio,
      codiPostal: codiPostal ?? this.codiPostal,
      mail: mail ?? this.mail,
      telefon: telefon ?? this.telefon,
      observacions: observacions ?? this.observacions,
      imatgeBase64: imatgeBase64 ?? this.imatgeBase64,
      isFromNewApp: isFromNewApp ?? this.isFromNewApp,
    );
  }
}
