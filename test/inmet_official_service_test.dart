import 'package:flutter_test/flutter_test.dart';
import 'package:clima_sul/data/cities.dart';
import 'package:clima_sul/data/ibge_codes.dart';
import 'package:clima_sul/services/inmet_official_service.dart';
import 'package:clima_sul/utils/text.dart';

void main() {
  group('stripAccents', () {
    test('remove acentos e cedilha', () {
      expect(stripAccents('São Leopoldo'), 'Sao Leopoldo');
      expect(stripAccents('Estância Velha'), 'Estancia Velha');
      expect(stripAccents('Guaíba'), 'Guaiba');
      expect(stripAccents('Três Coroas'), 'Tres Coroas');
    });

    test('preserva caracteres comuns', () {
      expect(stripAccents('Novo Hamburgo'), 'Novo Hamburgo');
      expect(stripAccents('Canoas'), 'Canoas');
    });
  });

  group('cities registry', () {
    test('contém 33 cidades e Taquara está presente', () {
      expect(allCities.length, 33);
      expect(allCities.any((c) => c.id == 'taquara'), isTrue);
    });

    test('toda cidade tem geocode IBGE mapeado', () {
      for (final city in allCities) {
        expect(ibgeCodeByCityId.containsKey(city.id), isTrue,
            reason: '${city.id} sem geocode IBGE');
      }
      expect(ibgeCodeByCityId.length, 33);
    });

    test('geocodes são únicos e têm 7 dígitos', () {
      final codes = ibgeCodeByCityId.values.toList();
      expect(codes.toSet().length, codes.length);
      for (final code in codes) {
        expect(code, greaterThanOrEqualTo(1000000));
        expect(code, lessThanOrEqualTo(9999999));
      }
    });
  });

  group('InmetOfficialService.parseFeed', () {
    Map<String, dynamic> sampleFeed({List<Map<String, dynamic>> alerts = const []}) =>
        {
          'fonte': 'INMET',
          'atualizado_em': '2026-11-21 09:28',
          'alertas': alerts,
        };

    test('extrai alerta ativo e cruza geocodes com cidades da cobertura', () {
      final feed = InmetOfficialService.parseFeed(
        sampleFeed(alerts: [
          {
            'id': 56475,
            'evento': 'Tempestade',
            'severidade': 'Perigo Potencial',
            'nivel': 1,
            'inicio': '2026-11-21 09:28',
            'fim': '2026-11-22 23:59',
            'estados': ['RS', 'SC', 'PR'],
            'municipios_afetados': 3717,
            'geocodes': [ibgeCodeByCityId['novo_hamburgo']!, 4313409 + 1],
          },
        ]),
        DateTime(2026, 11, 21, 12),
      );
      expect(feed.alerts, hasLength(1));
      expect(feed.alerts.first.evento, 'Tempestade');
      expect(feed.alerts.first.nivelLabel, 'PERIGO POTENCIAL');
      expect(feed.alerts.first.matchedCityIds, contains('novo_hamburgo'));
      expect(feed.atualizadoEm, isNotNull);
    });

    test('aviso estadual sem geocodes casa com todas as cidades', () {
      final feed = InmetOfficialService.parseFeed(
        sampleFeed(alerts: [
          {
            'id': 1,
            'evento': 'Tempestade',
            'severidade': 'Perigo',
            'nivel': 2,
            'estados': ['RS'],
            'municipios_afetados': 497,
          },
        ]),
        DateTime(2026, 11, 21, 12),
      );
      expect(feed.alerts.single.matchedCityIds.length, allCities.length);
      expect(feed.alerts.single.nivelLabel, 'PERIGO');
    });

    test('aviso de outro estado sem geocodes não casa cidades', () {
      final feed = InmetOfficialService.parseFeed(
        sampleFeed(alerts: [
          {
            'id': 2,
            'evento': 'Calor',
            'severidade': 'Perigo',
            'nivel': 2,
            'estados': ['MT'],
            'municipios_afetados': 100,
          },
        ]),
        DateTime(2026, 11, 21, 12),
      );
      expect(feed.alerts.single.matchedCityIds, isEmpty);
    });

    test('ordena por severidade (maior nível primeiro)', () {
      final feed = InmetOfficialService.parseFeed(
        sampleFeed(alerts: [
          {'id': 1, 'evento': 'Vendaval', 'severidade': 'Perigo Potencial', 'nivel': 1, 'estados': ['RS']},
          {'id': 2, 'evento': 'Tempestade', 'severidade': 'Grande Perigo', 'nivel': 3, 'estados': ['RS']},
          {'id': 3, 'evento': 'Chuva Intensa', 'severidade': 'Perigo', 'nivel': 2, 'estados': ['RS']},
        ]),
        DateTime(2026, 11, 21, 12),
      );
      expect(feed.alerts.map((a) => a.nivel), [3, 2, 1]);
      expect(feed.alerts.first.nivelLabel, 'GRANDE PERIGO');
    });

    test('feed vazio retorna total zero', () {
      final feed = InmetOfficialService.parseFeed(
        sampleFeed(),
        DateTime(2026, 11, 21, 12),
      );
      expect(feed.total, 0);
    });
  });
}
