class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final bool isDriverVerified;
  final bool isDriverOnline;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Driver verification data
  final String? driverFullName;
  final String? driverPhone;
  final String? driverLicenseNumber;
  final String? vehicleType;
  final String? vehiclePlate;
  final String? licensePlateImageUrl;
  final String? vehicleImageUrl;
  
  // Agent verification data
  final bool isAgentVerified;
  final String? agentName;
  final String? agentPhone;
  final String? agentPAN;
  final String? agencyName;
  final String? agencyContact;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.isDriverVerified = false,
    this.isDriverOnline = false,
    required this.createdAt,
    this.updatedAt,
    this.driverFullName,
    this.driverPhone,
    this.driverLicenseNumber,
    this.vehicleType,
    this.vehiclePlate,
    this.licensePlateImageUrl,
    this.vehicleImageUrl,
    this.isAgentVerified = false,
    this.agentName,
    this.agentPhone,
    this.agentPAN,
    this.agencyName,
    this.agencyContact,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'isDriverVerified': isDriverVerified,
      'isDriverOnline': isDriverOnline,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'driverFullName': driverFullName,
      'driverPhone': driverPhone,
      'driverLicenseNumber': driverLicenseNumber,
      'vehicleType': vehicleType,
      'vehiclePlate': vehiclePlate,
      'licensePlateImageUrl': licensePlateImageUrl,
      'vehicleImageUrl': vehicleImageUrl,
      'isAgentVerified': isAgentVerified,
      'agentName': agentName,
      'agentPhone': agentPhone,
      'agentPAN': agentPAN,
      'agencyName': agencyName,
      'agencyContact': agencyContact,
    };
  }

  // Create from Firestore document
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      isDriverVerified: json['isDriverVerified'] as bool? ?? false,
      isDriverOnline: json['isDriverOnline'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      driverFullName: json['driverFullName'] as String?,
      driverPhone: json['driverPhone'] as String?,
      driverLicenseNumber: json['driverLicenseNumber'] as String?,
      vehicleType: json['vehicleType'] as String?,
      vehiclePlate: json['vehiclePlate'] as String?,
      licensePlateImageUrl: json['licensePlateImageUrl'] as String?,
      vehicleImageUrl: json['vehicleImageUrl'] as String?,
      isAgentVerified: json['isAgentVerified'] as bool? ?? false,
      agentName: json['agentName'] as String?,
      agentPhone: json['agentPhone'] as String?,
      agentPAN: json['agentPAN'] as String?,
      agencyName: json['agencyName'] as String?,
      agencyContact: json['agencyContact'] as String?,
    );
  }

  // Copy with method for updates
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    bool? isDriverVerified,
    bool? isDriverOnline,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? driverFullName,
    String? driverPhone,
    String? driverLicenseNumber,
    String? vehicleType,
    String? vehiclePlate,
    String? licensePlateImageUrl,
    String? vehicleImageUrl,
    bool? isAgentVerified,
    String? agentName,
    String? agentPhone,
    String? agentPAN,
    String? agencyName,
    String? agencyContact,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isDriverVerified: isDriverVerified ?? this.isDriverVerified,
      isDriverOnline: isDriverOnline ?? this.isDriverOnline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      driverFullName: driverFullName ?? this.driverFullName,
      driverPhone: driverPhone ?? this.driverPhone,
      driverLicenseNumber: driverLicenseNumber ?? this.driverLicenseNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      licensePlateImageUrl: licensePlateImageUrl ?? this.licensePlateImageUrl,
      vehicleImageUrl: vehicleImageUrl ?? this.vehicleImageUrl,
      isAgentVerified: isAgentVerified ?? this.isAgentVerified,
      agentName: agentName ?? this.agentName,
      agentPhone: agentPhone ?? this.agentPhone,
      agentPAN: agentPAN ?? this.agentPAN,
      agencyName: agencyName ?? this.agencyName,
      agencyContact: agencyContact ?? this.agencyContact,
    );
  }
}
