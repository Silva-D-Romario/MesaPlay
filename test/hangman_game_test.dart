import 'package:asobiplay/features/hangman/domain/hangman_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HangmanGame', () {
    test('revela acertos e contabiliza erros', () {
      final game = HangmanGame(secretWord: 'CASA');

      expect(game.maxErrors, 7);
      expect(game.guess('A'), isTrue);
      expect(game.maskedWord, '_ A _ A');
      expect(game.guess('X'), isTrue);
      expect(game.errors, 1);
      expect(game.wrongLetters, contains('X'));
    });

    test('não contabiliza uma letra repetida novamente', () {
      final game = HangmanGame(secretWord: 'DADO');

      expect(game.guess('X'), isTrue);
      expect(game.guess('x'), isFalse);
      expect(game.errors, 1);
    });

    test('trata letras acentuadas como equivalentes', () {
      final game = HangmanGame(secretWord: 'CORAÇÃO');

      for (final letter in ['c', 'o', 'r', 'a']) {
        game.guess(letter);
      }

      expect(game.maskedWord, 'C O R A Ç Ã O');
    });

    test('vence ao descobrir todas as letras', () {
      final game = HangmanGame(secretWord: 'SOL');

      for (final letter in ['S', 'O', 'L']) {
        game.guess(letter);
      }

      expect(game.isWon, isTrue);
      expect(game.isFinished, isTrue);
    });

    test('perde ao atingir o limite de erros', () {
      final game = HangmanGame(secretWord: 'SOL', maxErrors: 3);

      for (final letter in ['A', 'B', 'C']) {
        game.guess(letter);
      }

      expect(game.isLost, isTrue);
      expect(game.isFinished, isTrue);
      expect(game.guess('S'), isFalse);
    });

    test('oferece uma última tentativa depois do boneco completo', () {
      final game = HangmanGame(secretWord: 'SOL');

      for (final letter in ['A', 'B', 'C', 'D', 'E', 'F']) {
        game.guess(letter);
      }

      expect(game.errors, 6);
      expect(game.isFinished, isFalse);
      expect(game.guess('G'), isTrue);
      expect(game.isLost, isTrue);
    });

    test('rejeita palavra sem letras', () {
      expect(() => HangmanGame(secretWord: '---'), throwsArgumentError);
    });
  });
}
