import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class DummyUser {
  final String displayName;
  final String email;
  DummyUser({required this.displayName, required this.email});
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final DummyUser? user;
  final String? userType;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.userType,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    DummyUser? user,
    String? userType,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      userType: userType ?? this.userType,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _init();
  }

  void _init() {
    // Do not simulate a logged in user by default
    // state = state.copyWith(user: DummyUser(displayName: 'Demo User', email: 'demo@areno.com'), userType: 'customer', isLoading: false);
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(Duration(seconds: 1));
    state = state.copyWith(user: DummyUser(displayName: 'Demo User', email: email), userType: 'customer', isLoading: false);
  }

  Future<void> signUp(String email, String password, String userType, Map<String, dynamic> userData) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(Duration(seconds: 1));
    state = state.copyWith(user: DummyUser(displayName: userData['displayName'] ?? 'Demo User', email: email), userType: userType, isLoading: false);
  }

  Future<void> signOut() async {
    state = state.copyWith(user: null, userType: null);
  }

  Future<void> updateUserType(String userType) async {
    state = state.copyWith(userType: userType);
  }
}
