class UserModel {
  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;
  final String? phoneNumber;
  final String? providerId;

  UserModel({
    this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.emailVerified = false,
    this.phoneNumber,
    this.providerId,
  });

  // Créer un UserModel à partir d'un objet JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      emailVerified: json['emailVerified'] ?? false,
      phoneNumber: json['phoneNumber'],
      providerId: json['providerId'],
    );
  }

  // Convertir un UserModel en Map
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'emailVerified': emailVerified,
      'phoneNumber': phoneNumber,
      'providerId': providerId,
    };
  }

  // Créer une copie de l'utilisateur avec des champs mis à jour
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    bool? emailVerified,
    String? phoneNumber,
    String? providerId,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      providerId: providerId ?? this.providerId,
    );
  }
}
