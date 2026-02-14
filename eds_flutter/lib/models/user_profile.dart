class UserProfile {
  final String guid;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String street;
  final String building;
  final String flat;
  final String city;
  final String postalCode;
  final String pesel;
  final int genderDvid;
  final String memberCardNumber;
  final String address;

  UserProfile({
    required this.guid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.street,
    required this.building,
    required this.flat,
    required this.city,
    required this.postalCode,
    required this.pesel,
    required this.genderDvid,
    required this.memberCardNumber,
    required this.address,
  });

  String get fullName => '$firstName $lastName';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      guid: json['guid'] ?? json['UsersID']?.toString() ?? '',
      firstName: json['FirstName'] ?? '',
      lastName: json['LastName'] ?? '',
      email: json['Email'] ?? '',
      phone: json['Phone'] ?? '',
      dateOfBirth: json['DateOfBirdth'] ?? '',
      street: json['Street'] ?? '',
      building: json['Building'] ?? '',
      flat: json['Flat'] ?? '',
      city: json['City'] ?? '',
      postalCode: json['PostalCode'] ?? '',
      pesel: json['Pesel'] ?? '',
      genderDvid: json['GenderDVID'] ?? 0,
      memberCardNumber: json['MemberCardNumber'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guid': guid,
      'FirstName': firstName,
      'LastName': lastName,
      'Email': email,
      'Phone': phone,
      'DateOfBirdth': dateOfBirth,
      'Street': street,
      'Building': building,
      'Flat': flat,
      'City': city,
      'PostalCode': postalCode,
      'Pesel': pesel,
      'GenderDVID': genderDvid,
      'MemberCardNumber': memberCardNumber,
      'address': address,
    };
  }
}
