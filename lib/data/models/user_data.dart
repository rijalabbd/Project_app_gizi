class UserData {
  final double bmi;
  final String statusBmi;
  final String gender;
  final int age;
  final double weight;
  final double height;
  final String activity;
  final String goal;

  UserData({
    required this.bmi,
    required this.statusBmi,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.activity,
    required this.goal,
  });

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      bmi: (map['bmi'] as num?)?.toDouble() ?? 0.0,
      statusBmi: map['statusBmi'] as String? ?? 'Unknown',
      gender: map['gender'] as String? ?? 'Unknown',
      age: (map['age'] as num?)?.toInt() ?? 0,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      height: (map['height'] as num?)?.toDouble() ?? 0.0,
      activity: map['activity'] as String? ?? 'Unknown',
      goal: map['goal'] as String? ?? 'Unknown',
    );
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      bmi: json['bmi'] as double,
      statusBmi: json['statusBmi'] as String,
      gender: json['gender'] as String,
      age: json['age'] as int,
      weight: json['weight'] as double,
      height: json['height'] as double,
      activity: json['activity'] as String,
      goal: json['goal'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bmi': bmi,
      'statusBmi': statusBmi,
      'gender': gender,
      'age': age,
      'weight': weight,
      'height': height,
      'activity': activity,
      'goal': goal,
    };
  }
}