import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fast_truck/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _usersCollection => _firestore.collection('users');

  // Create or update user document
  Future<void> createUserDocument(User firebaseUser) async {
    try {
      final userDoc = await _usersCollection.doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        // Create new user document
        final newUser = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
          isDriverVerified: false, // Default to false
          createdAt: DateTime.now(),
        );

        await _usersCollection.doc(firebaseUser.uid).set(newUser.toJson());
      }
    } catch (e) {
      throw 'Failed to create user document: $e';
    }
  }

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw 'Failed to get user data: $e';
    }
  }

  // Get user data stream
  Stream<UserModel?> getUserDataStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Check if driver is verified
  Future<bool> isDriverVerified(String uid) async {
    try {
      final userData = await getUserData(uid);
      return userData?.isDriverVerified ?? false;
    } catch (e) {
      return false;
    }
  }

  // Update driver verification status
  Future<void> updateDriverVerification(String uid, bool isVerified) async {
    try {
      await _usersCollection.doc(uid).update({
        'isDriverVerified': isVerified,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Failed to update driver verification: $e';
    }
  }

  // Submit driver verification data
  Future<void> submitDriverVerification({
    required String uid,
    required String fullName,
    required String phone,
    required String licenseNumber,
    required String vehicleType,
    required String vehiclePlate,
    String? licensePlateImageUrl,
    String? vehicleImageUrl,
  }) async {
    try {
      await _usersCollection.doc(uid).update({
        'driverFullName': fullName,
        'driverPhone': phone,
        'driverLicenseNumber': licenseNumber,
        'vehicleType': vehicleType,
        'vehiclePlate': vehiclePlate,
        'licensePlateImageUrl': licensePlateImageUrl,
        'vehicleImageUrl': vehicleImageUrl,
        'isDriverVerified': true, // Auto-verify for demo, in production this should be false
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Failed to submit driver verification: $e';
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    bool? isDriverVerified,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (displayName != null) {
        updates['displayName'] = displayName;
      }
      if (isDriverVerified != null) {
        updates['isDriverVerified'] = isDriverVerified;
      }

      await _usersCollection.doc(uid).update(updates);
    } catch (e) {
      throw 'Failed to update user profile: $e';
    }
  }

  // ========== Agent Verification Methods ==========

  // Check if agent is verified
  Future<bool> isAgentVerified(String uid) async {
    try {
      final userData = await getUserData(uid);
      return userData?.isAgentVerified ?? false;
    } catch (e) {
      return false;
    }
  }

  // Update agent verification status
  Future<void> updateAgentVerification(String uid, bool isVerified) async {
    try {
      await _usersCollection.doc(uid).update({
        'isAgentVerified': isVerified,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Failed to update agent verification: $e';
    }
  }

  // Submit agent verification data
  Future<void> submitAgentVerification({
    required String uid,
    required String name,
    required String phone,
    required String pan,
    required String agencyName,
    required String agencyContact,
  }) async {
    try {
      await _usersCollection.doc(uid).update({
        'agentName': name,
        'agentPhone': phone,
        'agentPAN': pan,
        'agencyName': agencyName,
        'agencyContact': agencyContact,
        'isAgentVerified': false, // Default to false, admin will verify
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Failed to submit agent verification: $e';
    }
  }

  // Get current user model
  Future<UserModel?> getCurrentUserModel() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;
    return await getUserData(currentUser.uid);
  }

  // Stream of current user model
  Stream<UserModel?> getCurrentUserModelStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value(null);
    return getUserDataStream(currentUser.uid);
  }

  // Update driver online status
  Future<void> updateDriverOnlineStatus(String uid, bool isOnline) async {
    try {
      await _usersCollection.doc(uid).update({
        'isDriverOnline': isOnline,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Failed to update driver online status: $e';
    }
  }

  // Get driver online status
  Future<bool> getDriverOnlineStatus(String uid) async {
    try {
      final userData = await getUserData(uid);
      return userData?.isDriverOnline ?? false;
    } catch (e) {
      return false;
    }
  }

  // Get all online drivers
  Future<List<UserModel>> getOnlineDrivers() async {
    try {
      final querySnapshot = await _usersCollection
          .where('isDriverVerified', isEqualTo: true)
          .where('isDriverOnline', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Failed to get online drivers: $e';
    }
  }

  // Stream of online drivers
  Stream<List<UserModel>> getOnlineDriversStream() {
    return _usersCollection
        .where('isDriverVerified', isEqualTo: true)
        .where('isDriverOnline', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }
}
