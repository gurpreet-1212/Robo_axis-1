import 'dart:async';
import 'dart:convert'; // For JSON decoding
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:http/http.dart' as http; // Import HTTP package

class CurrentScreen extends StatefulWidget {
  const CurrentScreen({Key? key}) : super(key: key);

  @override
  State<CurrentScreen> createState() => _CurrentScreenState();
}

class _CurrentScreenState extends State<CurrentScreen> {
  // Motor current values initialized to default
  double motor1Current = 1.0;
  double motor2Current = -1.0;

  // Threshold values for each motor
  final double motor1Threshold = 3.0;
  final double motor2Threshold = 3.0;

  // Screen color control
  bool isThresholdExceeded = false;
  Color screenColor = Colors.white;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startDataUpdate();
    startBlinking();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // Function to fetch data from ESP32
  Future<void> fetchCurrentData() async {
    try {
      final response = await http.get(Uri.parse('http://<ESP32_IP>/current')); // Replace <ESP32_IP> with ESP32's IP address

      if (response.statusCode == 200) {
        // Parse JSON data received from ESP32
        final data = json.decode(response.body);

        setState(() {
          motor1Current = data['motor1Current'];
          motor2Current = data['motor2Current'];
        });
      } else {
        print('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void startDataUpdate() {
    Timer.periodic(Duration(seconds: 2), (timer) {
      fetchCurrentData(); // Update current values every 2 seconds
    });
  }

  void startBlinking() {
    timer = Timer.periodic(Duration(milliseconds: 500), (Timer t) {
      setState(() {
        // Check if either motor exceeds its respective threshold
        if (motor1Current > motor1Threshold || motor2Current > motor2Threshold) {
          isThresholdExceeded = !isThresholdExceeded;
          screenColor = isThresholdExceeded ? Colors.red : Colors.white;
        } else {
          // Reset to default color if below threshold
          isThresholdExceeded = false;
          screenColor = Colors.white;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current'),
      ),
      backgroundColor: screenColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Card(
                elevation: 4.0,
                child: Container(
                  width: 200,
                  height: 200,
                  child: SfRadialGauge(
                    animationDuration: 2500,
                    enableLoadingAnimation: true,
                    title: const GaugeTitle(text: 'MOTOR-1'),
                    axes: <RadialAxis>[
                      RadialAxis(
                        minimum: -5,
                        maximum: 5,
                        ranges: <GaugeRange>[
                          GaugeRange(
                              startValue: -5,
                              endValue: motor1Threshold,
                              color: Colors.green,
                              startWidth: 10,
                              endWidth: 10),
                          GaugeRange(
                              startValue: motor1Threshold,
                              endValue: 5,
                              color: Colors.red,
                              startWidth: 10,
                              endWidth: 10),
                        ],
                        axisLabelStyle: const GaugeTextStyle(
                          fontSize: 8,
                        ),
                        axisLineStyle: const AxisLineStyle(
                          thickness: 0.1,
                          thicknessUnit: GaugeSizeUnit.factor,
                          gradient: SweepGradient(
                            colors: <Color>[
                              Colors.blue,
                              Colors.blueAccent
                            ],
                            stops: <double>[0.25, 0.75],
                          ),
                        ),
                        pointers: <GaugePointer>[
                          NeedlePointer(
                            value: motor1Current,
                            needleStartWidth: 1,
                            needleEndWidth: 4,
                            knobStyle: KnobStyle(
                              knobRadius: 10,
                              sizeUnit: GaugeSizeUnit.logicalPixel,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                        annotations: <GaugeAnnotation>[
                          GaugeAnnotation(
                            widget: Container(
                              child: Text(
                                '${motor1Current.toStringAsFixed(1)} mA',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            angle: 90,
                            positionFactor: 0.9,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 4.0,
                child: Container(
                  width: 200,
                  height: 200,
                  child: SfRadialGauge(
                    animationDuration: 2500,
                    enableLoadingAnimation: true,
                    title: const GaugeTitle(text: 'MOTOR-2'),
                    axes: <RadialAxis>[
                      RadialAxis(
                        minimum: -5,
                        maximum: 5,
                        ranges: <GaugeRange>[
                          GaugeRange(
                              startValue: -5,
                              endValue: motor2Threshold,
                              color: Colors.green,
                              startWidth: 10,
                              endWidth: 10),
                          GaugeRange(
                              startValue: motor2Threshold,
                              endValue: 5,
                              color: Colors.red,
                              startWidth: 10,
                              endWidth: 10),
                        ],
                        axisLabelStyle: const GaugeTextStyle(
                          fontSize: 8,
                        ),
                        axisLineStyle: const AxisLineStyle(
                          thickness: 0.1,
                          thicknessUnit: GaugeSizeUnit.factor,
                          gradient: SweepGradient(
                            colors: <Color>[
                              Colors.blue,
                              Colors.blueAccent
                            ],
                            stops: <double>[0.25, 0.75],
                          ),
                        ),
                        pointers: <GaugePointer>[
                          NeedlePointer(
                            value: motor2Current,
                            needleStartWidth: 1,
                            needleEndWidth: 4,
                            knobStyle: KnobStyle(
                              knobRadius: 10,
                              sizeUnit: GaugeSizeUnit.logicalPixel,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ],
                        annotations: <GaugeAnnotation>[
                          GaugeAnnotation(
                            widget: Container(
                              child: Text(
                                '${motor2Current.toStringAsFixed(1)} mA',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            angle: 90,
                            positionFactor: 0.9,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


