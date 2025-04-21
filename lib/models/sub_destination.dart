import 'package:hive/hive.dart';

part 'sub_destination.g.dart';

@HiveType(typeId: 1)
class SubDestination {
  @HiveField(0)
  String name;

  @HiveField(1)
  DateTime startTime;

  @HiveField(2)
  DateTime endTime;

  @HiveField(3)
  String note;

  SubDestination({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.note,
  });
} 