import 'package:flutter/foundation.dart';
import '../models/ranking_models.dart';
import '../services/ranking_repository.dart';

class RankingsProvider extends ChangeNotifier {
  final RankingService _rankingService = RankingService();

  RankingType _selectedType = RankingType.xp;
  RankingPeriod _selectedPeriod = RankingPeriod.allTime;

  List<RankingPlayer> _players = [];
  RankingPlayer? _currentUserRank;
  bool _isLoading = false;
  String? _errorMessage;

  RankingType get selectedType => _selectedType;
  RankingPeriod get selectedPeriod => _selectedPeriod;
  List<RankingPlayer> get players => _players;
  RankingPlayer? get currentUserRank => _currentUserRank;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOnline => _rankingService.isOnlineMode;

  RankingPlayer? get podiumFirst => _players.isNotEmpty ? _players[0] : null;
  RankingPlayer? get podiumSecond => _players.length > 1 ? _players[1] : null;
  RankingPlayer? get podiumThird => _players.length > 2 ? _players[2] : null;
  List<RankingPlayer> get remainingPlayers => _players.length > 3 ? _players.sublist(3) : [];

  Future<void> loadRankings({String? currentUsername}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _rankingService.getRankings(
        type: _selectedType,
        period: _selectedPeriod,
        currentUsername: currentUsername,
      );

      _players = list;

      // Extract or find current user rank
      try {
        _currentUserRank = _players.firstWhere((p) => p.isCurrentUser);
      } catch (_) {
        _currentUserRank = _players.isNotEmpty ? _players.first : null;
      }
    } catch (e) {
      _errorMessage = 'Unable to load rankings. Please try again.';
      debugPrint('Error loading rankings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectType(RankingType type, {String? currentUsername}) {
    if (_selectedType == type) return;
    _selectedType = type;
    loadRankings(currentUsername: currentUsername);
  }

  void selectPeriod(RankingPeriod period, {String? currentUsername}) {
    if (_selectedPeriod == period) return;
    _selectedPeriod = period;
    loadRankings(currentUsername: currentUsername);
  }

  Future<void> refreshRankings({String? currentUsername}) async {
    await loadRankings(currentUsername: currentUsername);
  }

  Future<PlayerPublicProfile?> fetchPublicProfile(dynamic userId) async {
    return await _rankingService.getPublicProfile(userId);
  }
}
