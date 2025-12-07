import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:bcrypt/bcrypt.dart';
import '../models/user_model.dart';
import 'user_database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserDatabaseService _db = UserDatabaseService();

  Future<UserModel?> currentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await _db.getUser(user.uid);
  }

  // ------------------------------
  // SIGN UP (EMAIL/PASSWORD)
  // ------------------------------
  Future<UserModel?> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = result.user!.uid;
      final hash = BCrypt.hashpw(password, BCrypt.gensalt());

      UserModel user = UserModel(
        userId: uid,
        fullName: fullName,
        email: email,
        passwordHash: hash,
        avatarUrl: "",
        role: null,
        status: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _db.saveUser(user);

      return user;
    } catch (e) {
      print("❌ SignUp error: $e");
      return null;
    }
  }

  // ------------------------------
  // SIGN IN WITH EMAIL
  // ------------------------------
  Future<UserModel?> loginWithEmail({
      required String email,
      required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel? user =
      await _db.getUser(result.user!.uid);

      if (user == null) return null;

      // Check password hash manually
      bool isValid = BCrypt.checkpw(password, user.passwordHash);

      if (!isValid) return null;

      return user;
    } catch (e) {
      print("❌ Login error: $e");
      return null;
    }
  }



  // SIGN IN WITH GOOGLE
  // ------------------------------
  Future<UserModel?> loginWithGoogle() async {
    try {
      User? firebaseUser;

      if (kIsWeb) {
        // --- Web ---
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final UserCredential result = await _auth.signInWithPopup(
            googleProvider);
        firebaseUser = result.user;
      } else {
        // --- Mobile (Android/iOS) ---
        final googleUser = await GoogleSignIn.instance.authenticate();
        if (googleUser == null) return null;

        final googleAuth = googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
            idToken: googleAuth.idToken);

        final result = await _auth.signInWithCredential(credential);
        firebaseUser = result.user;
      }
      if (firebaseUser == null) return null;
      final uid = firebaseUser.uid;

      UserModel? user = await _db.getUser(uid);
      if (user == null) {
        user = UserModel(
          userId: uid,
          fullName: firebaseUser.displayName ?? "",
          email: firebaseUser.email ?? "",
          passwordHash: "",
          avatarUrl: firebaseUser.photoURL ?? "",
          role: null,
          status: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _db.saveUser(user);
      }

      return user;
    } catch(e){
      print("Google Login error: $e");
      return null;
    }
  }

  // ------------------------------
  // SIGN OUT
  // ------------------------------
  Future<void> signOut() async {
    await _auth.signOut();

    try {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.signOut();
    } catch (_) {
      // Ignore if GoogleSignIn fails
    }
  }

  // ------------------------------
  // UPDATE NAME
  // ------------------------------
  Future<void> updateFullName(String fullName) async {
    final user = _auth.currentUser;
    if (user == null) throw "No user logged in";

    // Update Firebase displayName
    await user.updateDisplayName(fullName);
    await user.reload();

    // Update Realtime DB
    final userModel = await _db.getUser(user.uid);
    if (userModel == null) throw "User not found";

    userModel.fullName = fullName;
    userModel.updatedAt = DateTime.now();
    await _db.updateUser(user.uid, userModel.toMap());
  }

  // ------------------------------
  // UPDATE MAIL
  // ------------------------------
  Future<void> updateEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user == null) throw "No user logged in";

    // Firebase update email
    await user.verifyBeforeUpdateEmail(newEmail);
    await user.reload();

    // Update Realtime DB
    final userModel = await _db.getUser(user.uid);
    if (userModel == null) throw "User not found";

    userModel.email = newEmail;
    userModel.updatedAt = DateTime.now();
    await _db.updateUser(user.uid, userModel.toMap());
  }

  // ------------------------------
  // UPDATE PASS
  // ------------------------------
  Future<void> updatePassword(
      String oldPass, String newPass) async {
    final user = _auth.currentUser;
    if (user == null) throw "No user logged in";

    final userModel = await _db.getUser(user.uid);
    if (userModel == null) throw "User not found";

    bool isValid = BCrypt.checkpw(oldPass, userModel.passwordHash);
    if (!isValid) throw "Old password is incorrect";

    // Firebase update password
    await user.updatePassword(newPass);
    await user.reload();

    // Update hash DB
    userModel.passwordHash = BCrypt.hashpw(newPass, BCrypt.gensalt());
    userModel.updatedAt = DateTime.now();
    await _db.updateUser(user.uid, userModel.toMap());
  }

  // ------------------------------
  // UPDATE AVATAR URL
  // ------------------------------
  Future<void> updateAvatar(String avatarUrl) async {
    final user = _auth.currentUser;
    if (user == null) throw "No user logged in";

    // Firebase update
    await user.updatePhotoURL(avatarUrl);
    await user.reload();

    // Update DB
    final userModel = await _db.getUser(user.uid);
    if (userModel == null) throw "User not found";

    userModel.avatarUrl = avatarUrl;
    userModel.updatedAt = DateTime.now();
    await _db.updateUser(user.uid, userModel.toMap());
  }

}

// ------------------------------
void initGoogleSignIn() {
  if (!kIsWeb) {
    // Chỉ Android/iOS mới cần serverClientId
    GoogleSignIn.instance.initialize(
      clientId: null,
      serverClientId: "639479435926-23qn77ll1nb0o2jpsbbiiudsjilgubbs.apps.googleusercontent.com",
    );
  } else {
    // Web không cần serverClientId
    GoogleSignIn.instance.initialize();
  }
}
