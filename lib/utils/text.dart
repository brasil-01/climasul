/// Normaliza texto para busca sem acentos e sem maiúsculas.
String stripAccents(String input) {
  const map = {
    'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
    'é': 'e', 'ê': 'e', 'è': 'e', 'ë': 'e',
    'í': 'i', 'î': 'i', 'ì': 'i', 'ï': 'i',
    'ó': 'o', 'ô': 'o', 'õ': 'o', 'ò': 'o', 'ö': 'o',
    'ú': 'u', 'û': 'u', 'ù': 'u', 'ü': 'u',
    'ç': 'c', 'ñ': 'n',
  };
  final buffer = StringBuffer();
  for (final ch in input.split('')) {
    buffer.write(map[ch] ?? ch);
  }
  return buffer.toString();
}
