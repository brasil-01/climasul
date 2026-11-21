# ClimaSul — O tempo da nossa região.

Aplicativo multiplataforma (Android · iOS · Web) de previsão do tempo para o
**Vale dos Sinos e Paranhana** e a **Grande Porto Alegre (RMPOA)**, no Rio
Grande do Sul — com dados abertos e gratuitos do
[Open-Meteo](https://open-meteo.com) e avisos oficiais do **INMET**.

> Região coberta (33 cidades): Novo Hamburgo, São Leopoldo, Campo Bom,
> Sapiranga, Estância Velha, Portão, Dois Irmãos, Ivoti, Parobé, Igrejinha,
> Três Coroas, Rolante, Nova Hartz, Araricá, Presidente Lucena,
> Santa Maria do Herval, Morro Reuter, Picada Café, Tupandi, Linha Nova,
> **Taquara** — Porto Alegre, Canoas, Esteio, Sapucaia do Sul, Gravataí,
> Cachoeirinha, Viamão, Alvorada, Guaíba, Eldorado do Sul, Nova Santa Rita,
> Triunfo.

## Marca

- **Wordmark:** Clima (#FFF/near-white sobre fundo escuro) + Sul (#FFC107 Amarelo Solar)
- **Tipografia:** Poppins ExtraBold (marca e títulos) · Inter (textos e dados)
- **Paleta oficial:**
  - Azul Profundo `#082D5B` — fundos escuros · Azul Confiança `#1976D2` — botões/links
  - Azul Céu `#4FC3F7` — detalhes/gráficos · Amarelo Solar `#FFC107` — destaques
  - Cinza Claro `#F5F7FA` — fundos claros · Verde Meteorológico `#20B486` — favorável
  - Vermelho Alerta `#E64B4B` — alertas
- **Tagline:** "O tempo da nossa região." · Arte final: "ClimaSul sempre com você!"

## Recursos

| Aba | O que faz |
|---|---|
| **Início** | Condição atual (temp, sensação, mín/máx, Umidade/Vento/Pressão), curva de temperatura e barras de chuva das próximas 24h, arco do sol, visibilidade/UV/nuvens/rajadas, qualidade do ar, previsão de 8 dias e chips de UV/AQI/chuva/atualização |
| **Radar** | Radar de precipitação RainViewer sobre mapa escuro (Esri World Dark Gray), animação dos últimos quadros, marcadores das 33 cidades, legenda de intensidade |
| **Alertas** | **Avisos oficiais do INMET** para o RS (amarelo/laranja/vermelho, cruzados por geocode IBGE com as 33 cidades) **+** alertas automáticos por regras sobre Open-Meteo (trovoada, chuva intensa, rajadas, calor, frio/geada, umidade, UV, nevoeiro) e panorama regional agregado |
| **Cidades** | Lista com busca sem acentos, favoritas persistidas, temperatura atual de todas as cidades em **uma única chamada em lote** à API |
| **Mais** | Sobre a marca, paleta oficial, fontes de dados e licenças, compartilhamento, avisos de emergência |

- UI escura "Azul Profundo" com vidro/glassmorphism, hero "Máx/Mín" e wordmark Poppins
- Cache offline (30 min; fallback de até 7 dias) com selo "dados salvos"
- Navegação inferior com badge de alertas ativos
- Ícones de app na identidade ClimaSul (Android, adaptive, iOS e Web)

## Stack

Flutter 3.50 · Dart 3.14 · Material 3 (`material_ui`) · Riverpod ·
flutter_map · fl_chart · http · shared_preferences · share_plus · intl ·
fontes empacotadas (Poppins + Inter, SIL OFL)

## Estrutura

```
lib/
├── main.dart                  # bootstrap (intl pt-BR, ProviderScope)
├── data/cities.dart           # 33 cidades (coordenadas OSM/Nominatim)
├── data/ibge_codes.dart       # geocodes IBGE dos 33 municípios (cruzamento INMET)
├── models/weather.dart        # CurrentWeather, HourPoint, DailyBrief, AirQuality…
├── services/
│   ├── open_meteo_service.dart    # Open-Meteo forecast + qualidade do ar + batch regional
│   ├── inmet_official_service.dart# avisos oficiais INMET (RS) — radarmeteorologico.com.br
│   ├── alerts_engine.dart         # motor de alertas automáticos (limiares documentados)
│   ├── rainviewer_service.dart    # quadros de radar (RainViewer)
│   └── cache_store.dart           # cache em SharedPreferences
├── state/providers.dart       # Riverpod: cidade, favoritas, bundle, região, alertas, INMET
├── screens/                   # home, radar, alertas, cidades, mais, root (navegação)
├── widgets/                   # wordmark/logo, hero, gráficos, arco do sol, AQI, sheets…
└── theme/app_theme.dart       # paleta ClimaSul, SkyBackground, GlassCard
test/                          # 26 testes
```

## Fontes de dados e licenças

- **Open-Meteo** — previsão e qualidade do ar (CC BY 4.0, exige atribuição). Uso
  comercial em alto volume requer plano próprio: <https://open-meteo.com/en/terms>
- **INMET — avisos oficiais** — Instituto Nacional de Meteorologia (inmet.gov.br).
  Neste app, consumidos em JSON via <https://radarmeteorologico.com.br/> (redistribuição
  com atribuição obrigatória). Caminho oficial futuro:
  [WIS2/CAP](https://wis2bra.inmet.gov.br). **Avisos do INMET prevalecem** sobre a
  previsão automática.
- **RainViewer** — radar global (uso pessoal gratuito com atribuição):
  <https://www.rainviewer.com>
- **Esri · Maxar · Earthstar Geographics** — mapa-base escuro (uso livre com atribuição)
- **© OpenStreetMap contributors** — referência de coordenadas das cidades
- **IBGE Serviços de Dados** — códigos dos municípios (cruzamento com geocodes INMET)
- Alertas automáticos **não são oficiais**; em emergência ligue **199** (Defesa Civil)
  ou **190**. Siga sempre INMET e Defesa Civil.

## Testes

```bash
flutter test          # 26 testes
flutter analyze       # sem issues
flutter build web --release --no-wasm-dry-run
```
