import 'package:flappy_bird_flutter/models/game_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GameState Model Tests', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
      // Mock SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    test('should initialize with correct default values', () {
      expect(gameState.status, equals(GameStatus.menu));
      expect(gameState.score, equals(0));
      expect(gameState.highScore, equals(0));
      expect(gameState.gameSpeed, equals(1.0));
    });

    test('should initialize with custom values', () {
      final customGameState = GameState(
        status: GameStatus.playing,
        score: 10,
        highScore: 50,
        gameSpeed: 1.5,
      );

      expect(customGameState.status, equals(GameStatus.playing));
      expect(customGameState.score, equals(10));
      expect(customGameState.highScore, equals(50));
      expect(customGameState.gameSpeed, equals(1.5));
    });

    test('should reset to initial state correctly', () {
      // Modify state
      gameState.status = GameStatus.playing;
      gameState.incrementScore();
      gameState.gameSpeed = 2.0;
      final originalHighScore = gameState.highScore;

      gameState.reset();

      expect(gameState.status, equals(GameStatus.menu));
      expect(gameState.score, equals(0));
      expect(gameState.gameSpeed, equals(1.0));
      // High score should be preserved
      expect(gameState.highScore, equals(originalHighScore));
    });

    test('should increment score correctly', () {
      expect(gameState.score, equals(0));

      gameState.incrementScore();
      expect(gameState.score, equals(1));

      gameState.incrementScore();
      expect(gameState.score, equals(2));
    });

    test('should update high score when score exceeds it', () {
      expect(gameState.highScore, equals(0));

      gameState.incrementScore(); // score = 1
      expect(gameState.highScore, equals(1));

      gameState.incrementScore(); // score = 2
      expect(gameState.highScore, equals(2));
    });

    test('should not decrease high score when score is lower', () {
      gameState.updateHighScore(10);
      expect(gameState.highScore, equals(10));

      gameState.incrementScore(); // score = 1
      expect(gameState.highScore, equals(10)); // Should remain 10
    });

    test('should update high score manually', () {
      gameState.updateHighScore(25);
      expect(gameState.highScore, equals(25));
    });

    test('should not update high score with negative values', () {
      gameState.updateHighScore(10);
      gameState.updateHighScore(-5);
      expect(gameState.highScore, equals(10)); // Should remain 10
    });

    test('should start game correctly', () {
      gameState.startGame();

      expect(gameState.status, equals(GameStatus.playing));
      expect(gameState.score, equals(0));
    });

    test('should end game correctly', () {
      gameState.startGame();
      gameState.incrementScore();
      gameState.incrementScore();

      gameState.endGame();

      expect(gameState.status, equals(GameStatus.gameOver));
      expect(gameState.score, equals(2));
    });

    test('should pause and resume game correctly', () {
      gameState.startGame();
      expect(gameState.status, equals(GameStatus.playing));

      gameState.pauseGame();
      expect(gameState.status, equals(GameStatus.paused));

      gameState.resumeGame();
      expect(gameState.status, equals(GameStatus.playing));
    });

    test('should not pause when not playing', () {
      gameState.status = GameStatus.menu;
      gameState.pauseGame();
      expect(gameState.status, equals(GameStatus.menu));

      gameState.status = GameStatus.gameOver;
      gameState.pauseGame();
      expect(gameState.status, equals(GameStatus.gameOver));
    });

    test('should not resume when not paused', () {
      gameState.status = GameStatus.playing;
      gameState.resumeGame();
      expect(gameState.status, equals(GameStatus.playing));

      gameState.status = GameStatus.menu;
      gameState.resumeGame();
      expect(gameState.status, equals(GameStatus.menu));
    });

    test('should return to menu correctly', () {
      gameState.startGame();
      gameState.incrementScore();

      gameState.returnToMenu();

      expect(gameState.status, equals(GameStatus.menu));
      expect(gameState.score, equals(0));
    });

    test('should validate game speed setter', () {
      gameState.gameSpeed = 2.0;
      expect(gameState.gameSpeed, equals(2.0));

      // Should not accept negative or zero values
      gameState.gameSpeed = -1.0;
      expect(gameState.gameSpeed, equals(2.0)); // Should remain 2.0

      gameState.gameSpeed = 0.0;
      expect(gameState.gameSpeed, equals(2.0)); // Should remain 2.0
    });

    test('should report correct game state booleans', () {
      // Menu state
      gameState.status = GameStatus.menu;
      expect(gameState.isInMenu, isTrue);
      expect(gameState.isPlaying, isFalse);
      expect(gameState.isPaused, isFalse);
      expect(gameState.isGameOver, isFalse);
      expect(gameState.isGameActive, isFalse);

      // Playing state
      gameState.status = GameStatus.playing;
      expect(gameState.isInMenu, isFalse);
      expect(gameState.isPlaying, isTrue);
      expect(gameState.isPaused, isFalse);
      expect(gameState.isGameOver, isFalse);
      expect(gameState.isGameActive, isTrue);

      // Paused state
      gameState.status = GameStatus.paused;
      expect(gameState.isInMenu, isFalse);
      expect(gameState.isPlaying, isFalse);
      expect(gameState.isPaused, isTrue);
      expect(gameState.isGameOver, isFalse);
      expect(gameState.isGameActive, isTrue);

      // Game over state
      gameState.status = GameStatus.gameOver;
      expect(gameState.isInMenu, isFalse);
      expect(gameState.isPlaying, isFalse);
      expect(gameState.isPaused, isFalse);
      expect(gameState.isGameOver, isTrue);
      expect(gameState.isGameActive, isFalse);
    });

    test('should detect new high score correctly', () {
      expect(gameState.isNewHighScore, isFalse);

      gameState.incrementScore(); // score = 1, highScore = 1
      expect(gameState.isNewHighScore, isTrue);

      gameState.incrementScore(); // score = 2, highScore = 2
      expect(gameState.isNewHighScore, isTrue);

      // Reset and score less than high score
      gameState.reset(); // score = 0, highScore = 2
      gameState.incrementScore(); // score = 1, highScore = 2
      expect(gameState.isNewHighScore, isFalse);
    });

    test('should convert to and from map correctly', () {
      gameState.status = GameStatus.playing;
      gameState.incrementScore();
      gameState.incrementScore();
      gameState.gameSpeed = 1.5;

      final map = gameState.toMap();
      expect(map['status'], equals('GameStatus.playing'));
      expect(map['score'], equals(2));
      expect(map['highScore'], equals(2));
      expect(map['gameSpeed'], equals(1.5));

      final newGameState = GameState.fromMap(map);
      expect(newGameState.status, equals(GameStatus.playing));
      expect(newGameState.score, equals(2));
      expect(newGameState.highScore, equals(2));
      expect(newGameState.gameSpeed, equals(1.5));
    });

    test('should handle invalid map data gracefully', () {
      final invalidMap = <String, dynamic>{
        'status': 'InvalidStatus',
        'score': 'not_a_number',
        'highScore': null,
        'gameSpeed': 'invalid',
      };

      final gameStateFromMap = GameState.fromMap(invalidMap);
      expect(gameStateFromMap.status, equals(GameStatus.menu));
      expect(gameStateFromMap.score, equals(0));
      expect(gameStateFromMap.highScore, equals(0));
      expect(gameStateFromMap.gameSpeed, equals(1.0));
    });

    test('should load high score from SharedPreferences', () async {
      // Set up mock data
      SharedPreferences.setMockInitialValues({'flappy_bird_high_score': 42});

      await gameState.loadHighScore();
      expect(gameState.highScore, equals(42));
    });

    test('should handle missing high score in SharedPreferences', () async {
      // No mock data set, should default to 0
      SharedPreferences.setMockInitialValues({});

      await gameState.loadHighScore();
      expect(gameState.highScore, equals(0));
    });

    test('should save high score to SharedPreferences', () async {
      gameState.updateHighScore(15);
      await gameState.saveHighScore();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('flappy_bird_high_score'), equals(15));
    });

    test('should update high score when ending game with higher score',
        () async {
      gameState.startGame();
      gameState.incrementScore();
      gameState.incrementScore();
      gameState.incrementScore(); // score = 3

      gameState.endGame();

      expect(gameState.highScore, equals(3));
      expect(gameState.status, equals(GameStatus.gameOver));
    });
  });
}
