import 'package:flutter/material.dart';

class GeofenceControls extends StatelessWidget {
  final TextEditingController nameController;
  final double radius;
  final Function(double) onRadiusChanged;
  final VoidCallback onClear;
  final VoidCallback onSave;

  const GeofenceControls({
    Key? key,
    required this.nameController,
    required this.radius,
    required this.onRadiusChanged,
    required this.onClear,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Geofence Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text('Radius: ${radius.toStringAsFixed(0)} meters'),
          Slider(
            value: radius,
            min: 50,
            max: 1000,
            divisions: 20,
            onChanged: onRadiusChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: onClear,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Save Geofence'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
