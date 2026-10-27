import 'dart:collection';

class HangmanGame {
  HangmanGame({required String secretWord, this.maxErrors = 6})
    : assert(maxErrors > 0),
      secretWord = secretWord.trim() {
    if (this.secretWord.isEmpty ||
        !_normalizedCharacters(this.secretWord).any(_isLetter)) {
      throw ArgumentError.value(secretWord, 'secretWord', 'Palavra inválida');
    }
  }

  final String secretWord;
  final int maxErrors;
  final Set<String> _guessedLetters = {};
  final Set<String> _wrongLetters = {};

  int get errors => _wrongLetters.length;
  bool get isLost => errors >= maxErrors;
  bool get isWon => _normalizedCharacters(
    secretWord,
  ).where(_isLetter).every(_guessedLetters.contains);
  bool get isFinished => isWon || isLost;
  UnmodifiableSetView<String> get guessedLetters =>
      UnmodifiableSetView(_guessedLetters);
  UnmodifiableSetView<String> get wrongLetters =>
      UnmodifiableSetView(_wrongLetters);

  String get maskedWord {
    final original = _characters(secretWord).toList();
    final normalized = _normalizedCharacters(secretWord).toList();
    return List.generate(original.length, (index) {
      final character = normalized[index];
      if (!_isLetter(character)) return original[index];
      return _guessedLetters.contains(character)
          ? original[index].toUpperCase()
          : '_';
    }).join(' ');
  }

  bool guess(String letter) {
    if (isFinished) return false;
    final normalized = _normalize(letter.trim());
    if (normalized.length != 1 || !_isLetter(normalized)) {
      return false;
    }
    if (_guessedLetters.contains(normalized) ||
        _wrongLetters.contains(normalized)) {
      return false;
    }

    final word = _normalize(secretWord);
    if (word.contains(normalized)) {
      _guessedLetters.add(normalized);
    } else {
      _wrongLetters.add(normalized);
    }
    return true;
  }

  static Iterable<String> _normalizedCharacters(String value) {
    return _characters(_normalize(value));
  }

  static bool _isLetter(String value) {
    return RegExp(r'^[A-Z]$').hasMatch(value);
  }

  static String _normalize(String value) {
    const accents = {
      'Á': 'A',
      'À': 'A',
      'Â': 'A',
      'Ã': 'A',
      'Ä': 'A',
      'É': 'E',
      'È': 'E',
      'Ê': 'E',
      'Ë': 'E',
      'Í': 'I',
      'Ì': 'I',
      'Î': 'I',
      'Ï': 'I',
      'Ó': 'O',
      'Ò': 'O',
      'Ô': 'O',
      'Õ': 'O',
      'Ö': 'O',
      'Ú': 'U',
      'Ù': 'U',
      'Û': 'U',
      'Ü': 'U',
      'Ç': 'C',
    };
    return _characters(
      value.toUpperCase(),
    ).map((char) => accents[char] ?? char).join();
  }

  static Iterable<String> _characters(String value) {
    return value.runes.map(String.fromCharCode);
  }
}
