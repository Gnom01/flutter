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

  String get fullName {
    if (firstName.isEmpty && lastName.isEmpty && address.isNotEmpty) {
      return address;
    }
    return '$firstName $lastName'.trim();
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      guid:
          json['guid'] ??
          json['UsersID']?.toString() ??
          json['id']?.toString() ??
          '',
      firstName: json['FirstName'] ?? json['first_name'] ?? '',
      lastName: json['LastName'] ?? json['last_name'] ?? '',
      email: json['Email'] ?? json['email'] ?? '',
      phone: json['Phone'] ?? json['phone'] ?? '',
      dateOfBirth: json['DateOfBirdth'] ?? json['date_of_birth'] ?? '',
      street: json['Street'] ?? json['street'] ?? '',
      building: json['Building'] ?? json['building'] ?? '',
      flat: json['Flat'] ?? json['flat'] ?? '',
      city: json['City'] ?? json['city'] ?? '',
      postalCode: json['PostalCode'] ?? json['postal_code'] ?? '',
      pesel: json['Pesel'] ?? json['pesel'] ?? '',
      genderDvid: json['GenderDVID'] ?? json['gender_dvid'] ?? 0,
      memberCardNumber:
          json['MemberCardNumber'] ?? json['member_card_number'] ?? '',
      address: json['address'] ?? json['fullName'] ?? '',
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
