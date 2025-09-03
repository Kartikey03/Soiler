// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/data_provider.dart';
import '../models/soil_reading.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _showChart = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History & Reports'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showChart ? Icons.list : Icons.show_chart),
            onPressed: () {
              setState(() {
                _showChart = !_showChart;
              });
            },
          ),
        ],
      ),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          return StreamBuilder<List<SoilReading>>(
            stream: dataProvider.getReadingsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final readings = snapshot.data ?? [];

              if (readings.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No readings available'),
                      Text('Take a test to see data here'),
                    ],
                  ),
                );
              }

              return _showChart
                  ? _buildSimpleChart(readings)
                  : _buildList(readings);
            },
          );
        },
      ),
    );
  }

  Widget _buildList(List<SoilReading> readings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: readings.length,
      itemBuilder: (context, index) {
        final reading = readings[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text('${index + 1}'),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.thermostat, color: Colors.orange, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${reading.temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.water_drop, color: Colors.blue, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${reading.moisture.toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            subtitle: Text(
              DateFormat('MMM dd, yyyy - HH:mm').format(reading.timestamp),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimpleChart(List<SoilReading> readings) {
    if (readings.isEmpty) return Container();

    // Calculate stats
    double avgTemp = readings.map((r) => r.temperature).reduce((a, b) => a + b) / readings.length;
    double avgMoisture = readings.map((r) => r.moisture).reduce((a, b) => a + b) / readings.length;
    double minTemp = readings.map((r) => r.temperature).reduce((a, b) => a < b ? a : b);
    double maxTemp = readings.map((r) => r.temperature).reduce((a, b) => a > b ? a : b);
    double minMoisture = readings.map((r) => r.moisture).reduce((a, b) => a < b ? a : b);
    double maxMoisture = readings.map((r) => r.moisture).reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Temperature Stats',
                  Icons.thermostat,
                  Colors.orange,
                  [
                    'Average: ${avgTemp.toStringAsFixed(1)}°C',
                    'Min: ${minTemp.toStringAsFixed(1)}°C',
                    'Max: ${maxTemp.toStringAsFixed(1)}°C',
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Moisture Stats',
                  Icons.water_drop,
                  Colors.blue,
                  [
                    'Average: ${avgMoisture.toStringAsFixed(1)}%',
                    'Min: ${minMoisture.toStringAsFixed(1)}%',
                    'Max: ${maxMoisture.toStringAsFixed(1)}%',
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Simple Bar Chart for Temperature
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.thermostat, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text(
                        'Temperature Trend',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildSimpleBarChart(
                      readings.take(10).toList(),
                          (reading) => reading.temperature,
                      Colors.orange,
                      minTemp,
                      maxTemp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Simple Bar Chart for Moisture
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.water_drop, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Moisture Trend',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildSimpleBarChart(
                      readings.take(10).toList(),
                          (reading) => reading.moisture,
                      Colors.blue,
                      minMoisture,
                      maxMoisture,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, IconData icon, Color color, List<String> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...stats.map((stat) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                stat,
                style: const TextStyle(fontSize: 12),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleBarChart(
      List<SoilReading> readings,
      double Function(SoilReading) getValue,
      Color color,
      double minValue,
      double maxValue,
      ) {
    if (readings.isEmpty) return Container();

    final range = maxValue - minValue;
    if (range <= 0) return Container();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            width: readings.length * 50.0, // Minimum width per bar
            height: availableHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: readings.reversed.take(10).toList().asMap().entries.map((entry) {
                final reading = entry.value;
                final value = getValue(reading);
                // Constrain height to available space minus space for labels
                final maxBarHeight = availableHeight - 60; // Reserve space for labels
                final height = ((value - minValue) / range) * maxBarHeight + 20; // Min height 20
                final clampedHeight = height.clamp(20.0, maxBarHeight);

                return Container(
                  width: 50.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: clampedHeight,
                          width: 30,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: color, width: 1),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Flexible(
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}