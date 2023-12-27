class UserModel {
  String? name;
  String? id;
  String? phone;
  String? childEmail;
  String? parentEmail;
  String? type;

  UserModel(
      {this.name, this.id, this.childEmail, this.parentEmail, this.phone, this.type});

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'phone': phone,
        'childEmil': childEmail,
        'parentEmail': parentEmail,
        'type': type,
      };
}
