import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../models/sub_destination.dart';
import '../providers/trip_provider.dart';

class EditTripScreen extends StatefulWidget {
  final Trip trip;
  final bool isViewOnly;

  const EditTripScreen({
    super.key, 
    required this.trip,
    this.isViewOnly = false,
  });

  @override
  State<EditTripScreen> createState() => _EditTripScreenState();
}

class _EditTripScreenState extends State<EditTripScreen> {
  late TextEditingController _destinationController;
  late TextEditingController _noteController;
  late DateTime _startDate;
  late DateTime _endDate;
  late List<SubDestination> _subDestinations;

  @override
  void initState() {
    super.initState();
    _destinationController = TextEditingController(text: widget.trip.destination);
    _noteController = TextEditingController(text: widget.trip.note);
    _startDate = widget.trip.startDate;
    _endDate = widget.trip.endDate;
    _subDestinations = List.from(widget.trip.subDestinations);
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    if (widget.isViewOnly) return;

    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedRange != null) {
      setState(() {
        _startDate = pickedRange.start;
        _endDate = pickedRange.end;
      });
    }
  }

  Future<void> _addSubDestination() async {
    if (widget.isViewOnly) return;

    final result = await showDialog<SubDestination>(
      context: context,
      builder: (context) => SubDestinationDialog(
        tripStartDate: _startDate,
        tripEndDate: _endDate,
      ),
    );

    if (result != null) {
      setState(() {
        _subDestinations.add(result);
      });
    }
  }

  void _showDeleteConfirmation(BuildContext context, int index, SubDestination subDest) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sub Destination'),
        content: Text(
          'Are you sure you want to delete "${subDest.name}"?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _subDestinations.removeAt(index);
              });
              Navigator.pop(context);
              
              // Show confirmation snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${subDest.name} has been deleted'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      setState(() {
                        _subDestinations.insert(index, subDest);
                      });
                    },
                  ),
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isViewOnly ? 'Trip Details' : 'Edit Trip'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _destinationController,
                    decoration: const InputDecoration(
                      labelText: 'Destination',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !widget.isViewOnly,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context, true),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.date_range),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Trip Dates',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          if (!widget.isViewOnly) 
                            const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    enabled: !widget.isViewOnly,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sub Destinations',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!widget.isViewOnly)
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addSubDestination,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_subDestinations.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No sub destinations added'),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _subDestinations.length,
                      itemBuilder: (context, index) {
                        final subDest = _subDestinations[index];
                        return Card(
                          child: ListTile(
                            title: Text(subDest.name),
                            subtitle: Text(
                              '${_formatDateTime(subDest.startTime)} - ${_formatDateTime(subDest.endTime)}\n${subDest.note}',
                            ),
                            trailing: widget.isViewOnly
                                ? null
                                : IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _showDeleteConfirmation(
                                      context,
                                      index,
                                      subDest,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (!widget.isViewOnly)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _saveTrip,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Trip',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _saveTrip() {
    widget.trip.destination = _destinationController.text;
    widget.trip.note = _noteController.text;
    widget.trip.startDate = _startDate;
    widget.trip.endDate = _endDate;
    widget.trip.subDestinations = _subDestinations;

    Provider.of<TripProvider>(context, listen: false).updateTrip(widget.trip);
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class SubDestinationDialog extends StatefulWidget {
  final DateTime tripStartDate;
  final DateTime tripEndDate;

  const SubDestinationDialog({
    super.key,
    required this.tripStartDate,
    required this.tripEndDate,
  });

  @override
  State<SubDestinationDialog> createState() => _SubDestinationDialogState();
}

class _SubDestinationDialogState extends State<SubDestinationDialog> {
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, bool isStartTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.tripStartDate,
      firstDate: widget.tripStartDate,
      lastDate: widget.tripEndDate,
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          if (isStartTime) {
            _startTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
          } else {
            _endTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Sub Destination'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(_startTime == null
                  ? 'Select Start Time'
                  : 'Start: ${_formatDateTime(_startTime!)}'),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectDateTime(context, true),
            ),
            ListTile(
              title: Text(_endTime == null
                  ? 'Select End Time'
                  : 'End: ${_formatDateTime(_endTime!)}'),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectDateTime(context, false),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty &&
                _startTime != null &&
                _endTime != null) {
              final subDestination = SubDestination(
                name: _nameController.text,
                startTime: _startTime!,
                endTime: _endTime!,
                note: _noteController.text,
              );
              Navigator.pop(context, subDestination);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}  