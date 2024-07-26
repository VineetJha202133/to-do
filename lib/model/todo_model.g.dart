part of 'todo_model.dart';

Todo _$TodoFromJson(Map<String, dynamic> json) {
  try {
    return Todo(
      json['name'] as String? ?? '',
      DateTime.parse(json['dateTime'] as String? ?? ''),
      json['priority'] == null
          ? Priority.Low
          : Priority.values.firstWhere(
              (e) => e.toString().split('.').last == json['priority']),
      parent: json['parent'] as String? ?? '',
      isCompleted: json['completed'] as int? ?? 0,
      id: json['id'] as String? ?? '',
    );
  } catch (e) {
    print('Error parsing date time: $e');
    // Handle the error gracefully, e.g., provide default date time or return null
    return Todo(
      '',
      DateTime.now(),
      Priority.Low,
      parent: '',
    );
  }
}

Map<String, dynamic> _$TodoToJson(Todo instance) => <String, dynamic>{
      'id': instance.id,
      'parent': instance.parent,
      'name': instance.name,
      'dateTime': instance.dateTime.toIso8601String(),
      'priority': instance.priority.toString().split('.').last,
      'completed': instance.isCompleted,
    };
