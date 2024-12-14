import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressEnterPage extends StatefulWidget {
  const AddressEnterPage({super.key});

  @override
  State<AddressEnterPage> createState() => _AddressEnterPageState();
}

class _AddressEnterPageState extends State<AddressEnterPage> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController additionalNotesController =
      TextEditingController();
  String addressType = 'Home';
  final List<String> wasteCategories = ['Plastic', 'Organic', 'Electronic'];
  final List<String> selectedCategories = [];
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _saveData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final data = {
      'address': addressController.text,
      'addressType': addressType,
      'categories': selectedCategories,
      'date': selectedDate?.toIso8601String(),
      'time': selectedTime?.format(context),
      'additionalNotes': additionalNotesController.text,
    };
    await prefs.setString('pickupData', jsonEncode(data));
  }

  Future<void> _loadSavedData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('pickupData');
    if (savedData != null) {
      final data = jsonDecode(savedData);
      setState(() {
        addressController.text = data['address'];
        addressType = data['addressType'];
        selectedCategories.addAll(List<String>.from(data['categories']));
        selectedDate =
            data['date'] != null ? DateTime.parse(data['date']) : null;
        selectedTime = data['time'] != null
            ? TimeOfDay(
                hour: int.parse(data['time'].split(':')[0]),
                minute: int.parse(data['time'].split(':')[1]),
              )
            : null;
        additionalNotesController.text = data['additionalNotes'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Waste Pickup Scheduler'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                hintText: 'Enter your address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: addressType,
              items: const [
                DropdownMenuItem(value: 'Home', child: Text('Home')),
                DropdownMenuItem(value: 'Office', child: Text('Office')),
              ],
              onChanged: (value) {
                setState(() {
                  addressType = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Address Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Waste Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 10,
              children: wasteCategories.map((category) {
                final isSelected = selectedCategories.contains(category);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.orange[100] : Colors.grey[200],
                    border: Border.all(
                      color: isSelected ? Colors.green : Colors.grey[400]!,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedCategories.remove(category);
                        } else {
                          selectedCategories.add(category);
                        }
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isSelected ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          category,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.green : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Pickup Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: Text(
                selectedDate == null
                    ? 'Pick a Date'
                    : 'Selected Date: ${selectedDate!.toString().split(' ')[0]}',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Pickup Time',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    selectedTime = time;
                  });
                }
              },
              child: Text(selectedTime == null
                  ? 'Pick a Time'
                  : 'Selected Time: ${selectedTime!.format(context)}'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Additional Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: additionalNotesController,
              decoration: const InputDecoration(
                hintText: 'Enter additional instructions for the pickup team',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (addressController.text.isEmpty ||
                      selectedCategories.isEmpty ||
                      selectedDate == null ||
                      selectedTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please complete all fields!'),
                      ),
                    );
                    return;
                  }

                  await _saveData();

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Pickup Scheduled'),
                        content: Text(
                          'Address: ${addressController.text}\n'
                          'Type: $addressType\n'
                          'Categories: ${selectedCategories.join(', ')}\n'
                          'Date: ${selectedDate.toString().split(' ')[0]}\n'
                          'Time: ${selectedTime!.format(context)}\n'
                          'Notes: ${additionalNotesController.text}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Confirm Pickup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
