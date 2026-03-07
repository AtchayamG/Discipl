import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/api_service.dart';
import '../core/constants/app_constants.dart';

class AppProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  // Navigation history — enables back-to-previous-tab behaviour
  final List<int> _navHistory = [];

  Map<String, dynamic> _data = {};
  Map<String, dynamic> get data => _data;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // \u2500\u2500 Auth State \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get currentUser => _currentUser;

  // \u2500\u2500 Mock auth users (loaded from JSON) \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  List<Map<String, dynamic>> _mockUsers = [];

  AppProvider() {
    _init();
  }

  Future<void> _init() async {
    // Run data loading and minimum 3-second splash timer in parallel.
    // isLoading stays true until BOTH complete — guarantees splash shows for 3s.
    await Future.wait([
      _loadMockData().then((_) => _checkSavedSession()),
      Future.delayed(const Duration(milliseconds: 3000)),
    ]);
  }

  // \u2500\u2500\u2500 Load mock JSON \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  Future<void> _loadMockData() async {
    try {
      final raw = await rootBundle.loadString('assets/data/mock_data.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _data = json;
      // Extract mock users for auth
      final authData = json['auth'] as Map<String, dynamic>?;
      if (authData != null) {
        _mockUsers = (authData['validUsers'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } catch (e) {
      debugPrint('loadMockData error: $e');
      _data = _fallbackData();
      // Also populate _mockUsers from fallback
      final authData = _data['auth'] as Map<String, dynamic>?;
      if (authData != null) {
        _mockUsers = (authData['validUsers'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    }
  }

  // \u2500\u2500\u2500 Check if user was previously signed in \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  Future<void> _checkSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getString('signed_in_user_id');
      if (savedUserId != null) {
        // Find user in mock users
        final user = _mockUsers.firstWhere(
          (u) => u['id'] == savedUserId,
          orElse: () => <String, dynamic>{},
        );
        if (user.isNotEmpty) {
          _currentUser = user;
          _isSignedIn = true;
          // Update data['user'] with current user
          _data['user'] = _buildUserData(user);
        }
      }
    } catch (e) {
      debugPrint('checkSavedSession error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // \u2500\u2500\u2500 Sign In \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  /// Returns null on success, error message string on failure.
  Future<String?> signIn(String email, String password) async {
    try {
      if (ApiConstants.baseUrl == 'MOCK') {
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 800));

        // Find matching user
        final user = _mockUsers.firstWhere(
          (u) =>
              (u['email'] as String).toLowerCase() == email.toLowerCase() &&
              u['password'] == password,
          orElse: () => <String, dynamic>{},
        );

        if (user.isEmpty) {
          return 'Invalid email or password. Try demo@discipl.ai / demo123';
        }

        _currentUser = user;
        _isSignedIn = true;
        _data['user'] = _buildUserData(user);

        // Save session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('signed_in_user_id', user['id'] as String);

        notifyListeners();
        return null; // success
      } else {
        // Real API
        final result = await ApiService.instance.post(ApiConstants.signIn, {
          'email': email,
          'password': password,
        });
        if (result['success'] == true) {
          _currentUser = result['user'] as Map<String, dynamic>?;
          _isSignedIn = true;
          _data['user'] = _currentUser ?? {};
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', result['token'] ?? '');
          notifyListeners();
          return null;
        }
        return result['message'] as String? ?? 'Sign in failed';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // \u2500\u2500\u2500 Sign Up \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      if (ApiConstants.baseUrl == 'MOCK') {
        // Check if email already exists
        final exists = _mockUsers.any(
            (u) => (u['email'] as String).toLowerCase() == email.toLowerCase());
        if (exists) return 'An account with this email already exists';

        // Create new mock user
        final newUser = {
          'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
          'email': email,
          'password': password,
          'name': name,
          'username': email.split('@').first,
          'bio': '',
          'goal': '',
          'avatarInitials': name.split(' ').map((w) => w[0]).take(2).join().toUpperCase(),
          'isPremium': false,
        };
        _mockUsers.add(newUser);
        _currentUser = newUser;
        _isSignedIn = true;
        _data['user'] = _buildUserData(newUser);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('signed_in_user_id', newUser['id'] as String);

        notifyListeners();
        return null;
      } else {
        final result = await ApiService.instance.post(ApiConstants.signUp, {
          'name': name, 'email': email, 'password': password,
        });
        if (result['success'] == true) {
          return await signIn(email, password);
        }
        return result['message'] as String? ?? 'Sign up failed';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // \u2500\u2500\u2500 Sign Out \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('signed_in_user_id');
      await prefs.remove('auth_token');
    } catch (e) {
      debugPrint('signOut prefs error: $e');
    }
    _isSignedIn = false;
    _currentUser = null;
    _selectedIndex = 0;
    notifyListeners();
  }

  // \u2500\u2500\u2500 Helper: build user data map \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  Map<String, dynamic> _buildUserData(Map<String, dynamic> u) {
    final existing = _data['user'] as Map<String, dynamic>? ?? {};
    return {
      ...existing,
      'id': u['id'],
      'name': u['name'],
      'username': u['username'],
      'email': u['email'],
      'bio': u['bio'] ?? '',
      'goal': u['goal'] ?? '',
      'avatarInitials': u['avatarInitials'] ?? 'U',
      'isPremium': u['isPremium'] ?? false,
      'memberSince': existing['memberSince'] ?? '2026-01-01',
      'disciplineScore': existing['disciplineScore'] ?? 76,
      'currentStreak': existing['currentStreak'] ?? 14,
      'totalPoints': existing['totalPoints'] ?? 0,
      'globalRank': existing['globalRank'] ?? 999,
    };
  }

  // \u2500\u2500\u2500 Theme \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  // \u2500\u2500\u2500 Navigation \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  void navigate(int index) {
    // Only push to history when changing between main tabs (0-9)
    // Ignore history for index 10/11 (now pushed via Navigator.push)
    if (_selectedIndex != index && index < 10) {
      _navHistory.add(_selectedIndex);
    }
    _selectedIndex = index;
    notifyListeners();
  }

  /// Pop to the previous tab. Returns true if there was history to go back to.
  bool navigateBack() {
    if (_navHistory.isEmpty) return false;
    _selectedIndex = _navHistory.removeLast();
    notifyListeners();
    return true;
  }

  Future<void> refresh() async {
    await _loadMockData();
    notifyListeners();
  }

  // \u2500\u2500\u2500 Habits \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  Future<void> toggleHabit(String habitId) async {
    try {
      final habits = List<Map<String, dynamic>>.from(
          (_data['habits'] as List? ?? [])
              .map((e) => Map<String, dynamic>.from(e as Map)));
      final idx = habits.indexWhere((h) => h['id'] == habitId);
      if (idx == -1) return;
      final habit = Map<String, dynamic>.from(habits[idx]);
      // Support both field names used across mock data sources
      final wasCompleted = (habit['completedToday'] as bool?) ?? (habit['completed'] as bool?) ?? false;
      habit['completedToday'] = !wasCompleted;
      habit['completed'] = !wasCompleted;
      if (!wasCompleted) {
        habit['streak'] = ((habit['streak'] as int?) ?? 0) + 1;
      }
      habits[idx] = habit;
      _data = Map<String, dynamic>.from(_data);
      _data['habits'] = habits;
      notifyListeners();
      if (ApiConstants.baseUrl != 'MOCK') {
        await ApiService.instance.post(ApiConstants.habits, {
          'habitId': habitId, 'completed': habit['completed'],
        });
      }
    } catch (e) {
      debugPrint('toggleHabit error: $e');
    }
  }

  // \u2500\u2500\u2500 Update Profile \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      final user = Map<String, dynamic>.from(
          _data['user'] as Map<String, dynamic>? ?? {});
      user.addAll(updates);
      _data = Map<String, dynamic>.from(_data);
      _data['user'] = user;
      // Also update currentUser
      if (_currentUser != null) {
        _currentUser = Map<String, dynamic>.from(_currentUser!);
        _currentUser!.addAll(updates);
      }
      notifyListeners();
      if (ApiConstants.baseUrl != 'MOCK') {
        await ApiService.instance.put(ApiConstants.user, updates);
      }
    } catch (e) {
      debugPrint('updateProfile error: $e');
    }
  }


  // ─── Methods needed by redesigned screens ─────────────────────────────────

  Future<void> addProgressPhoto(Map<String, dynamic> photo) async {
    try {
      final photos = ((_data['progressPhotos'] as List?) ?? []).cast<Map<String, dynamic>>();
      photos.insert(0, photo);
      _data = {..._data, 'progressPhotos': photos};
      notifyListeners();
    } catch (e) { debugPrint('addProgressPhoto error: $e'); }
  }

  Future<void> addWorkout(Map<String, dynamic> workout) async {
    try {
      final workouts = ((_data['workouts'] as List?) ?? []).cast<Map<String, dynamic>>();
      workouts.insert(0, workout);
      _data = {..._data, 'workouts': workouts};
      notifyListeners();
    } catch (e) { debugPrint('addWorkout error: $e'); }
  }

  void updateWorkout(int index, Map<String, dynamic> updated) {
    try {
      final workouts = List<Map<String, dynamic>>.from(
          (_data['workouts'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)));
      if (index >= 0 && index < workouts.length) {
        workouts[index] = updated;
        _data = {..._data, 'workouts': workouts};
        notifyListeners();
      }
    } catch (e) { debugPrint('updateWorkout error: $e'); }
  }

  void deleteWorkout(int index) {
    try {
      final workouts = List<Map<String, dynamic>>.from(
          (_data['workouts'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)));
      if (index >= 0 && index < workouts.length) {
        workouts.removeAt(index);
        _data = {..._data, 'workouts': workouts};
        notifyListeners();
      }
    } catch (e) { debugPrint('deleteWorkout error: $e'); }
  }

  Future<void> addHabit(Map<String, dynamic> habit) async {
    try {
      final habits = ((_data['habits'] as List?) ?? []).cast<Map<String, dynamic>>();
      habits.add(habit);
      _data = {..._data, 'habits': habits};
      notifyListeners();
    } catch (e) { debugPrint('addHabit error: $e'); }
  }

  // ─── Profile helpers ──────────────────────────────────────────────────────
  String? get avatarImagePath {
    final user = _data['user'] as Map<String, dynamic>?;
    final path = user?['avatarImagePath'];
    return (path != null && path.toString().isNotEmpty) ? path.toString() : null;
  }

  String get userBio {
    final user = _data['user'] as Map<String, dynamic>?;
    return user?['bio'] as String? ?? '';
  }

  // ─── Notifications ────────────────────────────────────────────────────────
  List<Map<String, dynamic>> get notifications =>
      ((_data['notifications'] as List?) ?? [])
          .cast<Map<String, dynamic>>();

  int get unreadCount =>
      notifications.where((n) => n['read'] == false).length;

  void markNotificationRead(String id) {
    final list = notifications.map((n) {
      if (n['id'] == id) return {...n, 'read': true};
      return n;
    }).toList();
    _data = {..._data, 'notifications': list};
    notifyListeners();
  }

  void markAllNotificationsRead() {
    final list = notifications.map((n) => {...n, 'read': true}).toList();
    _data = {..._data, 'notifications': list};
    notifyListeners();
  }

  void deleteNotification(String id) {
    final list = notifications.where((n) => n['id'] != id).toList();
    _data = {..._data, 'notifications': list};
    notifyListeners();
  }

  Future<void> joinChallenge(String challengeId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      final challenges = (_data['challenges'] as Map<String, dynamic>?) ?? {};
      final list = ((challenges['list'] as List?) ?? []).cast<Map<String, dynamic>>();
      final updated = list.map((c) => c['id'] == challengeId ? {...c, 'joined': true} : c).toList();
      _data = {..._data, 'challenges': {...challenges, 'list': updated}};
      notifyListeners();
    } catch (e) { debugPrint('joinChallenge error: $e'); }
  }

  // \u2500\u2500\u2500 Fallback data \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  Map<String, dynamic> _fallbackData() => {
    'auth': {
      'validUsers': [
        {'id': 'user_demo', 'name': 'Demo User', 'username': 'demouser',
          'email': 'demo@discipl.ai', 'password': 'demo123',
          'avatarInitials': 'DU', 'memberSince': 'Jan 2024',
          'disciplineScore': 76, 'currentStreak': 14, 'totalPoints': 12450},
      ]
    },
    'user': {'name': 'Demo User', 'username': 'demouser', 'email': 'demo@discipl.ai', 'avatarInitials': 'DU',
      'memberSince': '2024-01-01', 'disciplineScore': 76, 'currentStreak': 14, 'totalPoints': 12450},
    'dashboard': {'stats': {'currentStreak': 0, 'habitsThisWeek': 0, 'workoutsLogged': 0,
        'workoutsTarget': 7, 'pointsEarned': 0, 'pointsThisWeek': 0},
      'disciplineScore': {'score': 0, 'breakdown': {'workouts': 0, 'habits': 0, 'streak': 0, 'community': 0}},
      'weeklyActivity': [], 'aiPrediction': '', 'habitProgress': [], 'leaderboardPreview': []},
    'habits': [], 'weeklyOverview': [], 'workouts': [], 'progressPhotos': [],
    'notifications': [
      {'id': 'n1', 'type': 'streak', 'title': '🔥 Streak Milestone!', 'body': "You've hit a 21-day streak. Keep the fire burning!", 'time': '2 min ago', 'read': false, 'icon': 'streak'},
      {'id': 'n2', 'type': 'habit', 'title': '⏰ Habit Reminder', 'body': 'Meditate 10 min is scheduled for this morning.', 'time': '1 hour ago', 'read': false, 'icon': 'habit'},
      {'id': 'n3', 'type': 'achievement', 'title': '🏆 Achievement Unlocked', 'body': "You earned the 'Iron Will' badge for 7 days in a row.", 'time': '3 hours ago', 'read': false, 'icon': 'achievement'},
    ],
    'weightTrend': [], 'communityFeed': [],
    'challenges': {'active': {}, 'list': [], 'leaderboard': []},
    'leaderboard': {'global': [], 'friends': [], 'badges': []},
    'aiInsights': {'weeklyReport': '', 'metrics': [], 'prediction': {}, 'patterns': []},
    'analytics': {'scoreTrend': [], 'habitCategories': [], 'workoutTypes': []},
  };
}