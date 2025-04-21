import 'package:hive/hive.dart';
import 'sub_destination.dart';

part 'trip.g.dart';

@HiveType(typeId: 0)
class Trip extends HiveObject {
  @HiveField(0)
  String destination;

  @HiveField(1)
  DateTime startDate;

  @HiveField(2)
  DateTime endDate;

  @HiveField(3)
  String note;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  List<SubDestination> subDestinations;

  Trip({
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.note,
    this.isCompleted = false,
    List<SubDestination>? subDestinations,
  }) : subDestinations = subDestinations ?? [];
} 