class Item {
  int? id;
  String name;
  DateTime date;
  int value;
  bool isActive;

  Item({this.id, required this.name, required this.date, required this.value, required this.isActive});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'name': name,
      'date': date.toIso8601String(),
      'value': value,
      'isActive': isActive ? 1 : 0,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      value: map['value'],
      isActive: map['isActive'] == 1,
    );
  }
}
