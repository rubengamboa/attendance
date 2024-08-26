
class Course{
  final String id;
  String name;
 
  Course({
    this.id = "", 
    this.name = ""
  });
  
  @override
  bool operator ==(Object other) {
    if(other is! Course) return false;
    if(id != other.id) return false;
    return true;
  }
  
  @override
  int get hashCode => 37 * 17 + id.hashCode;
  
  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      id: id,
      name: name
    };
    return map;
  }

  factory Course.fromMap(Map<String, Object?> map) {
    return Course(
      id: map["id"] as String,
      name: map["name"] as String
    );
  }
}