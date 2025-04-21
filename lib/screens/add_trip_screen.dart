import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../models/sub_destination.dart';

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  final List<SubDestination> _subDestinations = [];

  @override
  void dispose() {
    _destinationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _addSubDestination() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select trip dates first'),
        ),
      );
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Trip'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    controller: _destinationController,
                    decoration: const InputDecoration(
                      labelText: 'Destination',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a destination';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(_startDate == null
                        ? 'Select Start Date'
                        : 'Start Date: ${_formatDate(_startDate!)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, true),
                  ),
                  ListTile(
                    title: Text(_endDate == null
                        ? 'Select End Date'
                        : 'End Date: ${_formatDate(_endDate!)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, false),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Sub Destinations',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: _addSubDestination,
                              ),
                            ],
                          ),
                        ),
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
                              return ListTile(
                                title: Text(subDest.name),
                                subtitle: Text(
                                  '${_formatDateTime(subDest.startTime)} - ${_formatDateTime(subDest.endTime)}\n${subDest.note}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      _subDestinations.removeAt(index);
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _startDate != null &&
                      _endDate != null) {
                    final newTrip = Trip(
                      destination: _destinationController.text,
                      startDate: _startDate!,
                      endDate: _endDate!,
                      note: _noteController.text,
                      subDestinations: _subDestinations,
                    );
                    Navigator.pop(context, newTrip);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'Save Trip',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class SubDestinationDialog extends StatefulWidget {
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;

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
      initialDate: widget.tripStartDate!,
      firstDate: widget.tripStartDate!,
      lastDate: widget.tripEndDate!,
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