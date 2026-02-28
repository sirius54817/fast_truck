class DeliveryRequestModel {
  final String id;
  final String agentId;
  final String agentEmail;
  final String? agentName;
  final String? agentPhone;
  final String? agencyName;
  final String? agencyContact;
  final String loadType;
  final double weight;
  final String pickupLocation;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final String dropLocation;
  final double? dropLatitude;
  final double? dropLongitude;
  final double distance;
  final String status; // pending, accepted, in_progress, completed, cancelled
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? driverId;
  final String? driverName;

  DeliveryRequestModel({
    required this.id,
    required this.agentId,
    required this.agentEmail,
    this.agentName,
    this.agentPhone,
    this.agencyName,
    this.agencyContact,
    required this.loadType,
    required this.weight,
    required this.pickupLocation,
    this.pickupLatitude,
    this.pickupLongitude,
    required this.dropLocation,
    this.dropLatitude,
    this.dropLongitude,
    required this.distance,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
    this.driverId,
    this.driverName,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agentId': agentId,
      'agentEmail': agentEmail,
      'agentName': agentName,
      'agentPhone': agentPhone,
      'agencyName': agencyName,
      'agencyContact': agencyContact,
      'loadType': loadType,
      'weight': weight,
      'pickupLocation': pickupLocation,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'dropLocation': dropLocation,
      'dropLatitude': dropLatitude,
      'dropLongitude': dropLongitude,
      'distance': distance,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'driverId': driverId,
      'driverName': driverName,
    };
  }

  // Create from Firestore document
  factory DeliveryRequestModel.fromJson(Map<String, dynamic> json) {
    return DeliveryRequestModel(
      id: json['id'] as String,
      agentId: json['agentId'] as String,
      agentEmail: json['agentEmail'] as String,
      agentName: json['agentName'] as String?,
      agentPhone: json['agentPhone'] as String?,
      agencyName: json['agencyName'] as String?,
      agencyContact: json['agencyContact'] as String?,
      loadType: json['loadType'] as String,
      weight: (json['weight'] as num).toDouble(),
      pickupLocation: json['pickupLocation'] as String,
      pickupLatitude: json['pickupLatitude'] != null ? (json['pickupLatitude'] as num).toDouble() : null,
      pickupLongitude: json['pickupLongitude'] != null ? (json['pickupLongitude'] as num).toDouble() : null,
      dropLocation: json['dropLocation'] as String,
      dropLatitude: json['dropLatitude'] != null ? (json['dropLatitude'] as num).toDouble() : null,
      dropLongitude: json['dropLongitude'] != null ? (json['dropLongitude'] as num).toDouble() : null,
      distance: (json['distance'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      driverId: json['driverId'] as String?,
      driverName: json['driverName'] as String?,
    );
  }

  // Copy with method for updates
  DeliveryRequestModel copyWith({
    String? id,
    String? agentId,
    String? agentEmail,
    String? agentName,
    String? agentPhone,
    String? agencyName,
    String? agencyContact,
    String? loadType,
    double? weight,
    String? pickupLocation,
    double? pickupLatitude,
    double? pickupLongitude,
    String? dropLocation,
    double? dropLatitude,
    double? dropLongitude,
    double? distance,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? driverId,
    String? driverName,
  }) {
    return DeliveryRequestModel(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      agentEmail: agentEmail ?? this.agentEmail,
      agentName: agentName ?? this.agentName,
      agentPhone: agentPhone ?? this.agentPhone,
      agencyName: agencyName ?? this.agencyName,
      agencyContact: agencyContact ?? this.agencyContact,
      loadType: loadType ?? this.loadType,
      weight: weight ?? this.weight,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      dropLocation: dropLocation ?? this.dropLocation,
      dropLatitude: dropLatitude ?? this.dropLatitude,
      dropLongitude: dropLongitude ?? this.dropLongitude,
      distance: distance ?? this.distance,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
    );
  }
}
