import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/cities.dart';
import '../data/ibge_codes.dart';

/// Alertas meteorológicos **oficiais** do INMET (Instituto Nacional de
/// Meteorologia), obtidos em JSON já processado via radarmeteorologico.com.br
/// (que redistribui o feed oficial com atribuição obrigatória).
///
/// Fonte primária oficial (CAP/WIS2): https://wis2bra.inmet.gov.br — caminho
/// futuro quando o parsing de CAP/XML e o broker trocar de estágio.
///
/// Os avisos do INMET PREVALECEM sobre a previsão automática do ClimaSul;
/// a UI os exibe em seção própria, com fonte e validade explícitas.
class InmetOfficialService {
  InmetOfficialService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _endpoint =
      'https://radarmeteorologico.com.br/api/v1/alertas?uf=RS';

  Future<InmetOfficialFeed> fetchRsAlerts() async {
    final resp = await _client
        .get(Uri.parse(_endpoint))
        .timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) {
      throw InmetException('HTTP ${resp.statusCode}');
    }
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    return parseFeed(json, DateTime.now());
  }

  /// Parse puro (testável): extrai alertas e casa geocodes com as cidades do app.
  static InmetOfficialFeed parseFeed(
    Map<String, dynamic> json,
    DateTime fetchedAt,
  ) {
    final rawAlerts = (json['alertas'] as List?) ?? const [];
    final cityIdByCode = {
      for (final entry in ibgeCodeByCityId.entries) entry.value: entry.key,
    };

    final alerts = <OfficialInmetAlert>[];
    for (final item in rawAlerts) {
      if (item is! Map) continue;
      final geocodes = ((item['geocodes'] as List?) ?? const [])
          .map((g) => (g as num).toInt())
          .toSet();
      final matchedCityIds = <String>{
        for (final code in geocodes)
          if (cityIdByCode[code] != null) cityIdByCode[code]!,
      };
      // Cobertura: se o aviso atinge RS e não casa com cidades específicas
      // (ex.: aviso nacional), considera todas as cidades do app.
      final states = ((item['estados'] as List?) ?? const [])
          .map((s) => s.toString().toUpperCase())
          .toList();
      final coversRs = states.contains('RS');
      final effectiveMatches = matchedCityIds.isNotEmpty
          ? matchedCityIds
          : (coversRs ? allCities.map((c) => c.id).toSet() : <String>{});

      alerts.add(OfficialInmetAlert(
        id: (item['id'] as num?)?.toInt() ?? 0,
        evento: item['evento']?.toString() ?? 'Aviso meteorológico',
        severidade: item['severidade']?.toString() ?? 'Perigo Potencial',
        nivel: (item['nivel'] as num?)?.toInt() ?? 1,
        inicio: _parseDate(item['inicio']?.toString()),
        fim: _parseDate(item['fim']?.toString()),
        futuro: item['futuro'] == true,
        municipiosAfetados:
            (item['municipios_afetados'] as num?)?.toInt() ?? geocodes.length,
        matchedCityIds: effectiveMatches.toList()..sort(),
      ));
    }

    // Mais severos primeiro; depois, mais cidades afetadas primeiro.
    alerts.sort((a, b) {
      final r = b.nivel.compareTo(a.nivel);
      if (r != 0) return r;
      return b.matchedCityIds.length.compareTo(a.matchedCityIds.length);
    });

    return InmetOfficialFeed(
      alerts: alerts,
      atualizadoEm: _parseDate(json['atualizado_em']?.toString()),
      fetchedAt: fetchedAt,
      atribuicao: json['atribuicao']?.toString() ??
          'Dados via https://radarmeteorologico.com.br',
    );
  }

  static DateTime? _parseDate(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      // '2026-11-21 09:28' ou ISO-8601 com timezone.
      return DateTime.parse(s.replaceFirst(' ', 'T'));
    } catch (_) {
      return null;
    }
  }
}

class InmetOfficialFeed {
  const InmetOfficialFeed({
    required this.alerts,
    required this.fetchedAt,
    this.atualizadoEm,
    this.atribuicao = 'Dados via radarmeteorologico.com.br',
  });

  final List<OfficialInmetAlert> alerts;
  final DateTime? atualizadoEm;
  final DateTime fetchedAt;
  final String atribuicao;

  int get total => alerts.length;
}

class OfficialInmetAlert {
  const OfficialInmetAlert({
    required this.id,
    required this.evento,
    required this.severidade,
    required this.nivel,
    required this.matchedCityIds,
    required this.municipiosAfetados,
    this.inicio,
    this.fim,
    this.futuro = false,
  });

  final int id;
  final String evento;
  final String severidade;

  /// 1 = Perigo Potencial (amarelo) · 2 = Perigo (laranja) · 3 = Grande Perigo (vermelho)
  final int nivel;
  final DateTime? inicio;
  final DateTime? fim;
  final bool futuro;
  final int municipiosAfetados;

  /// IDs das cidades do ClimaSul atingidas pelo aviso.
  final List<String> matchedCityIds;

  String get nivelLabel => switch (nivel) {
        1 => 'PERIGO POTENCIAL',
        2 => 'PERIGO',
        _ => 'GRANDE PERIGO',
      };
}

class InmetException implements Exception {
  const InmetException(this.message);
  final String message;
  @override
  String toString() => message;
}
