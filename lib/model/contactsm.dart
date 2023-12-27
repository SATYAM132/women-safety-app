class TContact {
  int? _id;
  String? _number;
  String? _name;

  TContact(this._number, this._name);
  TContact.withId(this._id, this._number, this._name);

  int get id => _id!;
  String get number => _number!;
  String get name => _name!;

  @override
  String toString() {
    return 'Contact : {id: $_id, name: $_name,number: $_number}';
  }

  set number(String newNumber) => this._number = newNumber;
  set name(String newName) => this._name = newName;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();

    map['id'] = this._id;
    map['name'] = this._name;
    map['number'] = this._number;

    return map;
  }

  TContact.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._name = map['number'];
    this._number = map['name'];
  }
}
