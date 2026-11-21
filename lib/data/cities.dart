/// Registro estático das 33 cidades monitoradas pelo ClimaSul —
/// Vale dos Sinos e Paranhana e Região Metropolitana de Porto Alegre (RMPOA).
///
/// Coordenadas obtidas via Nominatim/OpenStreetMap (cidades, não ruas),
/// suficientes para a malha ~11 km do modelo do Open-Meteo.
library;

enum Region { valeDosSinos, rmpoa }

extension RegionLabel on Region {
  String get label => switch (this) {
        Region.valeDosSinos => 'Vale dos Sinos e Paranhana',
        Region.rmpoa => 'Grande Porto Alegre',
      };
}

class City {
  const City({
    required this.id,
    required this.name,
    required this.region,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final Region region;
  final double latitude;
  final double longitude;
}

const List<City> allCities = [
  // ── Vale dos Sinos ─────────────────────────────────────────────
  City(id: 'novo_hamburgo', name: 'Novo Hamburgo', region: Region.valeDosSinos, latitude: -29.6906, longitude: -51.1429),
  City(id: 'sao_leopoldo', name: 'São Leopoldo', region: Region.valeDosSinos, latitude: -29.7544, longitude: -51.1516),
  City(id: 'campo_bom', name: 'Campo Bom', region: Region.valeDosSinos, latitude: -29.6781, longitude: -51.0580),
  City(id: 'sapiranga', name: 'Sapiranga', region: Region.valeDosSinos, latitude: -29.6392, longitude: -51.0069),
  City(id: 'estancia_velha', name: 'Estância Velha', region: Region.valeDosSinos, latitude: -29.6530, longitude: -51.1720),
  City(id: 'portao', name: 'Portão', region: Region.valeDosSinos, latitude: -29.6933, longitude: -51.2332),
  City(id: 'dois_irmaos', name: 'Dois Irmãos', region: Region.valeDosSinos, latitude: -29.5836, longitude: -51.0898),
  City(id: 'ivoti', name: 'Ivoti', region: Region.valeDosSinos, latitude: -29.5934, longitude: -51.1599),
  City(id: 'parobe', name: 'Parobé', region: Region.valeDosSinos, latitude: -29.6243, longitude: -50.8312),
  City(id: 'igrejinha', name: 'Igrejinha', region: Region.valeDosSinos, latitude: -29.5693, longitude: -50.7919),
  City(id: 'tres_coroas', name: 'Três Coroas', region: Region.valeDosSinos, latitude: -29.5155, longitude: -50.7771),
  City(id: 'rolante', name: 'Rolante', region: Region.valeDosSinos, latitude: -29.6528, longitude: -50.5769),
  City(id: 'nova_hartz', name: 'Nova Hartz', region: Region.valeDosSinos, latitude: -29.5842, longitude: -50.9043),
  City(id: 'ararica', name: 'Araricá', region: Region.valeDosSinos, latitude: -29.6169, longitude: -50.9291),
  City(id: 'presidente_lucena', name: 'Presidente Lucena', region: Region.valeDosSinos, latitude: -29.5175, longitude: -51.1798),
  City(id: 'santa_maria_do_herval', name: 'Santa Maria do Herval', region: Region.valeDosSinos, latitude: -29.4977, longitude: -50.9919),
  City(id: 'morro_reuter', name: 'Morro Reuter', region: Region.valeDosSinos, latitude: -29.5390, longitude: -51.0819),
  City(id: 'picada_cafe', name: 'Picada Café', region: Region.valeDosSinos, latitude: -29.4464, longitude: -51.1367),
  City(id: 'tupandi', name: 'Tupandi', region: Region.valeDosSinos, latitude: -29.4779, longitude: -51.4209),
  City(id: 'linha_nova', name: 'Linha Nova', region: Region.valeDosSinos, latitude: -29.4677, longitude: -51.2001),
  City(id: 'taquara', name: 'Taquara', region: Region.valeDosSinos, latitude: -29.6452, longitude: -50.7832),
  // ── Grande Porto Alegre (RMPOA) ────────────────────────────────
  City(id: 'porto_alegre', name: 'Porto Alegre', region: Region.rmpoa, latitude: -30.0325, longitude: -51.2304),
  City(id: 'canoas', name: 'Canoas', region: Region.rmpoa, latitude: -29.9216, longitude: -51.1800),
  City(id: 'esteio', name: 'Esteio', region: Region.rmpoa, latitude: -29.8512, longitude: -51.1779),
  City(id: 'sapucaia_do_sul', name: 'Sapucaia do Sul', region: Region.rmpoa, latitude: -29.8197, longitude: -51.1609),
  City(id: 'gravatai', name: 'Gravataí', region: Region.rmpoa, latitude: -29.9440, longitude: -50.9931),
  City(id: 'cachoeirinha', name: 'Cachoeirinha', region: Region.rmpoa, latitude: -29.9493, longitude: -51.0899),
  City(id: 'viamao', name: 'Viamão', region: Region.rmpoa, latitude: -30.0819, longitude: -51.0262),
  City(id: 'alvorada', name: 'Alvorada', region: Region.rmpoa, latitude: -29.9981, longitude: -51.0773),
  City(id: 'guaiba', name: 'Guaíba', region: Region.rmpoa, latitude: -30.1131, longitude: -51.3294),
  City(id: 'eldorado_do_sul', name: 'Eldorado do Sul', region: Region.rmpoa, latitude: -29.9976, longitude: -51.3064),
  City(id: 'nova_santa_rita', name: 'Nova Santa Rita', region: Region.rmpoa, latitude: -29.8570, longitude: -51.2755),
  City(id: 'triunfo', name: 'Triunfo', region: Region.rmpoa, latitude: -29.9408, longitude: -51.7192),
];

City cityById(String id) =>
    allCities.firstWhere((c) => c.id == id, orElse: () => allCities.first);

List<City> citiesOf(Region region) =>
    allCities.where((c) => c.region == region).toList(growable: false);

/// Centro aproximado da área de cobertura (para o mapa de radar).
const double regionCenterLat = -29.72;
const double regionCenterLng = -51.03;
