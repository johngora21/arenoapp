import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    // Optionally, check for existing Firebase user and set state
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      final user = credential.user;
      if (user != null) {
        // Optionally fetch userType from Firestore
        state = state.copyWith(user: DummyUser(displayName: user.displayName ?? '', email: user.email ?? email), userType: 'customer', isLoading: false);
      } else {
        state = state.copyWith(error: 'No user found', isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> signUp(String email, String password, String userType, Map<String, dynamic> userData) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Check for existing email or phone in CRM
      final crmRef = FirebaseFirestore.instance.collection('customers');
      final emailQuery = await crmRef.where('email', isEqualTo: email).limit(1).get();
      final phone = userData['phone'] ?? '';
      QuerySnapshot? phoneQuery;
      if (phone.isNotEmpty) {
        phoneQuery = await crmRef.where('phone', isEqualTo: phone).limit(1).get();
      }
      if (emailQuery.docs.isNotEmpty) {
        state = state.copyWith(error: 'An account with this email already exists.', isLoading: false);
        return;
      }
      if (phoneQuery != null && phoneQuery.docs.isNotEmpty) {
        state = state.copyWith(error: 'An account with this phone number already exists.', isLoading: false);
        return;
      }
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(userData['name'] ?? '');
        if (userType == 'customer') {
          await crmRef.doc(user.uid).set({
            'uid': user.uid,
            'name': userData['name'] ?? '',
            'email': email,
            'phone': phone,
            'userType': userType,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        state = state.copyWith(user: DummyUser(displayName: userData['name'] ?? '', email: email), userType: userType, isLoading: false);
      } else {
        state = state.copyWith(error: 'User creation failed', isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    state = state.copyWith(user: null, userType: null);
  }

  Future<void> updateUserType(String userType) async {
    state = state.copyWith(userType: userType);
  }
}
