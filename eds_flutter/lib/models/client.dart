class Client {
  final int id;
  final int? parentId;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? city;
  final String? zipCode;
  final String? nip;
  final String? regon;
  final String? logo;
  final String? url;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Client({
    required this.id,
    this.parentId,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.city,
    this.zipCode,
    this.nip,
    this.regon,
    this.logo,
    this.url,
    this.createdAt,
    this.updatedAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['ClientsID'] ?? json['id'] ?? 0,
      parentId: json['Parent_ClientsID'],
      name: json['ClientName'] ?? json['name'] ?? '',
      email: json['EMAIL'] ?? json['email'] ?? '',
      phone: json['Phone'] ?? json['phone'],
      address: json['Address'] ?? json['address'],
      city: json['City'] ?? json['city'],
      zipCode: json['ZipCode'] ?? json['zipCode'],
      nip: json['NIP'] ?? json['nip'],
      regon: json['Regon'] ?? json['regon'],
      logo: json['Logo'] ?? json['logo'],
      url: json['URL'] ?? json['url'],
      createdAt: json['WhenInserted'] != null
          ? DateTime.parse(json['WhenInserted'])
          : (json['created_at'] != null
                ? DateTime.parse(json['created_at'])
                : null),
      updatedAt: json['WhenUpdated'] != null
          ? DateTime.parse(json['WhenUpdated'])
          : (json['updated_at'] != null
                ? DateTime.parse(json['updated_at'])
                : null),
    );
  }

  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (zipCode != null && zipCode!.isNotEmpty) parts.add(zipCode!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    return parts.join(', ');
  }

  Map<String, dynamic> toJson() {
    return {
      'ClientsID': id,
      'Parent_ClientsID': parentId,
      'ClientName': name,
      'EMAIL': email,
      'Phone': phone,
      'Address': address,
      'City': city,
      'ZipCode': zipCode,
      'NIP': nip,
      'Regon': regon,
      'Logo': logo,
      'URL': url,
      'WhenInserted': createdAt?.toIso8601String(),
      'WhenUpdated': updatedAt?.toIso8601String(),
    };
  }
}
