import 'dart:convert'; // For JSON decoding
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:http/http.dart' as http;

class VoltageScreen extends StatefulWidget {
  const VoltageScreen({Key? key}) : super(key: key);

  @override
  State<VoltageScreen> createState() => _VoltageScreenState();
}

class _VoltageScreenState extends State<VoltageScreen> {
  double motor1Voltage = 0.0;
  double motor2Voltage = 0.0;

  @override
  void initState() {
    super.initState();
    fetchVoltageData(); // Fetch voltage data on initialization
  }

  Future<void> fetchVoltageData() async {
    // Replace with your ESP32's HTTP endpoint
    final url = 'http://<your-esp32-ip>/voltage';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse JSON data received from ESP32
        final Map<String, dynamic> voltageData = json.decode(response.body);
        setState(() {
          motor1Voltage = voltageData['motor1Voltage'];
          motor2Voltage = voltageData['motor2Voltage'];
        });
      } else {
        print('Failed to load voltage data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching voltage data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voltage'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: buildVoltageGauge(motor1Voltage, 'MOTOR-1', Colors.blue),
                ),
                Expanded(
                  child: buildVoltageGauge(motor2Voltage, 'MOTOR-2', Colors.greenAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVoltageGauge(double voltage, String title, Color needleColor) {
    return Card(
      elevation: 4.0,
      child: Container(
        width: 200,
        height: 200,
        child: SfRadialGauge(
          animationDuration: 2500,
          enableLoadingAnimation: true,
          title: GaugeTitle(text: title),
          axes: <RadialAxis>[
            RadialAxis(
              minimum: -15,
              maximum: 15,
              axisLabelStyle: const GaugeTextStyle(fontSize: 8),
              axisLineStyle: const AxisLineStyle(
                thickness: 0.1,
                thicknessUnit: GaugeSizeUnit.factor,
                gradient: SweepGradient(
                  colors: <Color>[Colors.blue, Colors.blueAccent],
                  stops: <double>[0.25, 0.75],
                ),
              ),
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: voltage,
                  needleStartWidth: 1,
                  needleEndWidth: 4,
                  knobStyle: KnobStyle(
                    knobRadius: 10,
                    sizeUnit: GaugeSizeUnit.logicalPixel,
                    color: needleColor,
                  ),
                ),
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  widget: Container(
                    child: Text(
                      '${voltage.toStringAsFixed(1)}V',
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
    );
  }
}

