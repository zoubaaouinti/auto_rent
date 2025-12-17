class UserModel {
  final String? id;
  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;
  final String? phoneNumber;
  final String? role;
  final String? address;
  final String? bio;
  final String? password;
  final String? otp;
  final String? otpExpiration;
  final String? token;

  UserModel({
    this.id,
    this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.emailVerified = false,
    this.phoneNumber,
    this.role,
    this.address,
    this.bio,
    this.password,
    this.otp,
    this.otpExpiration,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      uid: json['uid'],
      email: json['email'],
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      emailVerified: json['emailVerified'] ?? false,
      phoneNumber: json['phoneNumber'],
      role: json['role'],
      address: json['address'],
      bio: json['bio'],
      password: json['password'],
      otp: json['otp'],
      otpExpiration: json['otpExpiration'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (uid != null) 'uid': uid,
      if (email != null) 'email': email,
      if (displayName != null) 'displayName': displayName,
      if (photoURL != null) 'photoURL': photoURL,
      'emailVerified': emailVerified,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (role != null) 'role': role,
      if (address != null) 'address': address,
      if (bio != null) 'bio': bio,
      if (password != null) 'password': password,
      if (otp != null) 'otp': otp,
      if (otpExpiration != null) 'otpExpiration': otpExpiration,
      if (token != null) 'token': token,
    };
  }

  UserModel copyWith({
    String? id,
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    bool? emailVerified,
    String? phoneNumber,
    String? role,
    String? address,
    String? bio,
    String? password,
    String? otp,
    String? otpExpiration,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      password: password ?? this.password,
      otp: otp ?? this.otp,
      otpExpiration: otpExpiration ?? this.otpExpiration,
      token: token ?? this.token,
    );
  }
}