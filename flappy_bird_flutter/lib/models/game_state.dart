import 'package:shared_preferences/shared_preferences.dart';

enum GameStatus { menu, playing, gameOver, paused }

class GameState {
  GameStatus _status;
  int _score;
  int _highScore;
  double _gameSpeed;

  // SharedPreferences key for high score persistence
  static const String _highScoreKey = 'flappy_bird_high_score';

  GameState({
    GameStatus status = GameStatus.menu,
    int score = 0,
    int highScore = 0,
    double gameSpeed = 1.0,
  })  : _status = status,
        _score = score,
        _highScore = highScore,
        _gameSpeed = gameSpeed;

  // Getters
  GameStatus get status => _status;
  int get score => _score;
  int get highScore => _highScore;
  double get gameSpeed => _gameSpeed;

  // Setters with validation
  set status(GameStatus newStatus) {
    _status = newStatus;
  }

  set gameSpeed(double speed) {
    if (speed > 0) {
      _gameSpeed = speed;
    }
  }

  /// Resets the game state to initial values
  void reset() {
    _status = GameStatus.menu;
    _score = 0;
    _gameSpeed = 1.0;
    // High score is preserved
  }

  /// Increments the score by 1
  void incrementScore() {
    _score++;

    // Update high score if current score exceeds it
    if (_score > _highScore) {
      _highScore = _score;
      _saveHighScore(); // Persist the new high score
    }
  }

  /// Manually updates the high score (useful for loading saved data)
  void updateHighScore(int newHighScore) {
    if (newHighScore >= 0) {
      _highScore = newHighScore;
      _saveHighScore();
    }
  }

  /// Loads the high score from persistent storage
  Future<void> loadHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _highScore = prefs.getInt(_highScoreKey) ?? 0;
    } catch (e) {
      // If loading fails, keep the current high score (default 0)
      _highScore = 0;
    }
  }

  /// Saves the high score to persistent storage
  Future<void> _saveHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_highScoreKey, _highScore);
    } catch (e) {
      // If saving fails, continue without crashing
      // The high score will be lost when the app closes
    }
  }

  /// Manually saves the current high score (useful for testing)
  Future<void> saveHighScore() async {
    await _saveHighScore();
  }

  /// Starts a new game
  void startGame() {
    _status = GameStatus.playing;
    _score = 0;
  }

  /// Ends the current game
  void endGame() {
    _status = GameStatus.gameOver;

    // Update high score if needed
    if (_score > _highScore) {
      _highScore = _score;
      _saveHighScore();
    }
  }

  /// Pauses the current game
  void pauseGame() {
    if (_status == GameStatus.playing) {
      _status = GameStatus.paused;
    }
  }

  /// Resumes the paused game
  void resumeGame() {
    if (_status == GameStatus.paused) {
      _status = GameStatus.playing;
    }
  }

  /// Returns to menu
  void returnToMenu() {
    _status = GameStatus.menu;
    _score = 0;
  }

  /// Checks if the game is currently active (playing or paused)
  bool get isGameActive =>
      _status == GameStatus.playing || _status == GameStatus.paused;

  /// Checks if the game is currently playing
  bool get isPlaying => _status == GameStatus.playing;

  /// Checks if the game is paused
  bool get isPaused => _status == GameStatus.paused;

  /// Checks if the game is over
  bool get isGameOver => _status == GameStatus.gameOver;

  /// Checks if we're in the menu
  bool get isInMenu => _status == GameStatus.menu;

  /// Checks if the current score is a new high score
  bool get isNewHighScore => _score > 0 && _score == _highScore;

  /// Gets a copy of the current state for debugging
  Map<String, dynamic> toMap() {
    return {
      'status': _status.toString(),
      'score': _score,
      'highScore': _highScore,
      'gameSpeed': _gameSpeed,
    };
  }

  /// Creates a GameState from a map (useful for testing)
  factory GameState.fromMap(Map<String, dynamic> map) {
    GameStatus status = GameStatus.menu;

    // Parse status from string
    try {
      final statusString = map['status'] as String?;
      if (statusString != null) {
        for (final gameStatus in GameStatus.values) {
          if (gameStatus.toString() == statusString) {
            status = gameStatus;
            break;
          }
        }
      }
    } catch (e) {
      status = GameStatus.menu;
    }

    // Safely parse score
    int score = 0;
    try {
      final scoreValue = map['score'];
      if (scoreValue is int) {
        score = scoreValue;
      } else if (scoreValue is String) {
        score = int.tryParse(scoreValue) ?? 0;
      }
    } catch (e) {
      score = 0;
    }

    // Safely parse highScore
    int highScore = 0;
    try {
      final highScoreValue = map['highScore'];
      if (highScoreValue is int) {
        highScore = highScoreValue;
      } else if (highScoreValue is String) {
        highScore = int.tryParse(highScoreValue) ?? 0;
      }
    } catch (e) {
      highScore = 0;
    }

    // Safely parse gameSpeed
    double gameSpeed = 1.0;
    try {
      final gameSpeedValue = map['gameSpeed'];
      if (gameSpeedValue is double) {
        gameSpeed = gameSpeedValue;
      } else if (gameSpeedValue is int) {
        gameSpeed = gameSpeedValue.toDouble();
      } else if (gameSpeedValue is String) {
        gameSpeed = double.tryParse(gameSpeedValue) ?? 1.0;
      }
    } catch (e) {
      gameSpeed = 1.0;
    }

    return GameState(
      status: status,
      score: score,
      highScore: highScore,
      gameSpeed: gameSpeed,
    );
  }
}
