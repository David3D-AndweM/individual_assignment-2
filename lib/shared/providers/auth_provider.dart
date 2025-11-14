import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider()
      : _authRepository = AuthRepositoryImpl(
          firebaseAuth: FirebaseAuth.instance,
          firestore: FirebaseFirestore.instance,
        ) {
    _initializeAuthState();
  }

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null && _currentUser!.isEmailVerified;

  void _initializeAuthState() {
    _authRepository.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => _setError(failure.message),
      (user) => _currentUser = user,
    );

    _setLoading(false);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authRepository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );

    result.fold(
      (failure) => _setError(failure.message),
      (user) => _currentUser = user,
    );

    _setLoading(false);
  }

  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    final result = await _authRepository.signOut();

    result.fold(
      (failure) => _setError(failure.message),
      (_) => _currentUser = null,
    );

    _setLoading(false);
  }

  Future<void> sendEmailVerification() async {
    _setLoading(true);
    _clearError();

    final result = await _authRepository.sendEmailVerification();

    result.fold(
      (failure) => _setError(failure.message),
      (_) => {},
    );

    _setLoading(false);
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    final result = await _authRepository.resetPassword(email);

    result.fold(
      (failure) => _setError(failure.message),
      (_) => {},
    );

    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
