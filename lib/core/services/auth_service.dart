import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:trtravel/core/services/local_storage.dart';
import 'package:trtravel/core/services/logger.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, loading }

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  User? _user;
  AuthStatus _status = AuthStatus.uninitialized;
  String? _error;

  User? get user => _user;
  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get userId => _user?.uid;
  String? get userEmail => _user?.email;
  String? get displayName => _user?.displayName;
  String? get photoUrl => _user?.photoURL;
  String? get error => _error;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    _user = user;
    _status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    if (user != null) {
      LocalStorage.setString('user_id', user.uid);
      LocalStorage.setString('user_email', user.email ?? '');
      LocalStorage.setString('user_name', user.displayName ?? '');
    } else {
      LocalStorage.remove('user_id');
    }
    _error = null;
    notifyListeners();
  }

  Future<void> signInAnonymously() async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    try {
      await _auth.signInAnonymously();
    } catch (e) {
      _error = 'Échec de la connexion anonyme';
      LogService.error('Auth', 'Anonymous sign in failed', e);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
      final auth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      _error = 'Échec de la connexion Google';
      LogService.error('Auth', 'Google sign in failed', e);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithFacebook() async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
      final accessToken = result.accessToken;
      // final credential = FacebookAuthProvider.credential(accessToken!.tokenString);
      // await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      _error = 'Échec de la connexion Facebook';
      LogService.error('Auth', 'Facebook sign in failed', e);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e.code);
      LogService.error('Auth', 'Email sign in failed: ${e.code}');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e.code);
      LogService.error('Auth', 'Sign up failed: ${e.code}');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found': return 'Aucun compte trouvé avec cet email';
      case 'wrong-password': return 'Mot de passe incorrect';
      case 'email-already-in-use': return 'Cet email est déjà utilisé';
      case 'weak-password': return 'Mot de passe trop faible (min 6 caractères)';
      case 'invalid-email': return 'Email invalide';
      case 'account-exists-with-different-credential': return 'Un compte existe déjà avec un autre mode de connexion';
      default: return 'Erreur de connexion: $code';
    }
  }
}
