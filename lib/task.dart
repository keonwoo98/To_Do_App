class Task {
  String name;
  bool isDone;
  DateTime? dueDate;

  Task({required this.name, this.isDone = false, this.dueDate});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      name: json['name'],
      isDone: json['isDone'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isDone': isDone,
      'dueDate': dueDate?.toIso8601String(),
    };
  }
}
