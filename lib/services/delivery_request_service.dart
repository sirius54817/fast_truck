import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_truck/models/delivery_request_model.dart';
import 'package:fast_truck/services/user_service.dart';

class DeliveryRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  // Collection reference
  CollectionReference get _requestsCollection => _firestore.collection('delivery_requests');

  // Create a new delivery request
  Future<String> createRequest({
    required String agentId,
    required String agentEmail,
    required String loadType,
    required double weight,
    required String pickupLocation,
    double? pickupLatitude,
    double? pickupLongitude,
    required String dropLocation,
    double? dropLatitude,
    double? dropLongitude,
    required double distance,
  }) async {
    try {
      // Check if agent is verified
      final isAgentVerified = await _userService.isAgentVerified(agentId);
      
      if (!isAgentVerified) {
        throw 'Agent verification required. Please complete agent verification before creating requests.';
      }
      
      // Fetch agent details from user service
      final agentData = await _userService.getUserData(agentId);
      
      final docRef = _requestsCollection.doc();
      final request = DeliveryRequestModel(
        id: docRef.id,
        agentId: agentId,
        agentEmail: agentEmail,
        agentName: agentData?.agentName,
        agentPhone: agentData?.agentPhone,
        agencyName: agentData?.agencyName,
        agencyContact: agentData?.agencyContact,
        loadType: loadType,
        weight: weight,
        pickupLocation: pickupLocation,
        pickupLatitude: pickupLatitude,
        pickupLongitude: pickupLongitude,
        dropLocation: dropLocation,
        dropLatitude: dropLatitude,
        dropLongitude: dropLongitude,
        distance: distance,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await docRef.set(request.toJson());
      return docRef.id;
    } catch (e) {
      throw 'Failed to create delivery request: $e';
    }
  }

  // Get all requests for an agent
  Future<List<DeliveryRequestModel>> getAgentRequests(String agentId) async {
    try {
      final querySnapshot = await _requestsCollection
          .where('agentId', isEqualTo: agentId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => DeliveryRequestModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Failed to get agent requests: $e';
    }
  }

  // Stream of agent requests
  Stream<List<DeliveryRequestModel>> getAgentRequestsStream(String agentId) {
    return _requestsCollection
        .where('agentId', isEqualTo: agentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DeliveryRequestModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get active (pending, accepted, in_progress) requests for an agent
  Stream<List<DeliveryRequestModel>> getActiveRequestsStream(String agentId) {
    return _requestsCollection
        .where('agentId', isEqualTo: agentId)
        .snapshots()
        .map((snapshot) {
          final allRequests = snapshot.docs
              .map((doc) => DeliveryRequestModel.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
          
          // Filter active requests client-side
          final activeRequests = allRequests
              .where((req) => req.status == 'pending' || 
                             req.status == 'accepted' || 
                             req.status == 'in_progress')
              .toList();
          
          // Sort by createdAt descending
          activeRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          return activeRequests;
        });
  }

  // Get completed/cancelled requests for history
  Stream<List<DeliveryRequestModel>> getHistoryRequestsStream(String agentId) {
    return _requestsCollection
        .where('agentId', isEqualTo: agentId)
        .snapshots()
        .map((snapshot) {
          final allRequests = snapshot.docs
              .map((doc) => DeliveryRequestModel.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
          
          // Filter completed/cancelled requests client-side
          final historyRequests = allRequests
              .where((req) => req.status == 'completed' || req.status == 'cancelled')
              .toList();
          
          // Sort by createdAt descending
          historyRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          return historyRequests;
        });
  }

  // Get all pending requests (for drivers to view)
  Stream<List<DeliveryRequestModel>> getPendingRequestsStream() {
    return _requestsCollection
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          final requests = snapshot.docs
              .map((doc) => DeliveryRequestModel.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
          
          // Sort by createdAt descending
          requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          return requests;
        });
  }

  // Update request status
  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      await _requestsCollection.doc(requestId).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Failed to update request status: $e';
    }
  }

  // Assign driver to request
  Future<void> assignDriver(String requestId, String driverId, String driverName) async {
    try {
      await _requestsCollection.doc(requestId).update({
        'driverId': driverId,
        'driverName': driverName,
        'status': 'accepted',
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Failed to assign driver: $e';
    }
  }

  // Delete request
  Future<void> deleteRequest(String requestId) async {
    try {
      await _requestsCollection.doc(requestId).delete();
    } catch (e) {
      throw 'Failed to delete request: $e';
    }
  }

  // Get single request
  Future<DeliveryRequestModel?> getRequest(String requestId) async {
    try {
      final doc = await _requestsCollection.doc(requestId).get();
      if (doc.exists) {
        return DeliveryRequestModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw 'Failed to get request: $e';
    }
  }
}
