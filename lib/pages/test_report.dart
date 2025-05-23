import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// import '../backend/models/device_data.dart';
// import '../backend/models/data_point.dart';
// import '../backend/models/spirometry_results.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data'; // Required for Uint8List
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../spirometry_backend/spirometry_parameters.dart';
import '../spirometry_backend/vitals_widget.dart';

class TestReportPage extends StatefulWidget {
  final List<FlSpot> flowVolumePoints;
  final List<FlSpot> volumeTimePoints;
  final SpirometryParameters parameters;
  final Map<String, dynamic>? vitalsData;
  final List<Map<String, dynamic>>? trialTableData;
  final String? sessionQuality;
  final String? interpretation;
  final Map<String, dynamic> patientInfo;

  const TestReportPage({
    super.key,
    required this.flowVolumePoints,
    required this.volumeTimePoints,
    required this.parameters,
    this.vitalsData,
    this.trialTableData,
    this.sessionQuality,
    this.interpretation,
    required this.patientInfo,
  });

  @override
  State<TestReportPage> createState() => _TestReportPageState();
}

class _TestReportPageState extends State<TestReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String _selectedGender = 'Male';
  String _selectedEthnicity = 'Asian';

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _showPatientInfoDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Patient Information'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter age' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _heightController,
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter height' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spirometry Report'),
        backgroundColor: const Color(0xFF6B4FA1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _generatePdfReport,
            tooltip: 'Export as PDF',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6E3F3), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Information
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Patient Information',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B4FA1),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPatientInfoForm(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Graphs Section
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Spirometry Graphs',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B4FA1),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 400,
                        child: Row(
                          children: [
                            // Flow vs Volume graph
                            Expanded(
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Flow vs Volume',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF6B4FA1),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: LineChart(
                                          LineChartData(
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: widget.flowVolumePoints,
                                                isCurved: false,
                                                color: const Color(0xFF6B4FA1),
                                                barWidth: 2,
                                                dotData: FlDotData(show: false),
                                              ),
                                            ],
                                            titlesData: FlTitlesData(
                                              leftTitles: AxisTitles(
                                                axisNameWidget:
                                                    const Text('Flow (L/s)'),
                                                sideTitles: SideTitles(
                                                    showTitles: true),
                                              ),
                                              bottomTitles: AxisTitles(
                                                axisNameWidget:
                                                    const Text('Volume (L)'),
                                                sideTitles: SideTitles(
                                                    showTitles: true),
                                              ),
                                              rightTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                      showTitles: false)),
                                              topTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                      showTitles: false)),
                                            ),
                                            borderData:
                                                FlBorderData(show: true),
                                            gridData: FlGridData(show: true),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Volume vs Time graph
                            Expanded(
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Volume vs Time',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF6B4FA1),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: LineChart(
                                          LineChartData(
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: widget.volumeTimePoints,
                                                isCurved: false,
                                                color: const Color(0xFF6B4FA1),
                                                barWidth: 2,
                                                dotData: FlDotData(show: false),
                                              ),
                                            ],
                                            titlesData: FlTitlesData(
                                              leftTitles: AxisTitles(
                                                axisNameWidget:
                                                    const Text('Volume (L)'),
                                                sideTitles: SideTitles(
                                                    showTitles: true),
                                              ),
                                              bottomTitles: AxisTitles(
                                                axisNameWidget:
                                                    const Text('Time (s)'),
                                                sideTitles: SideTitles(
                                                    showTitles: true),
                                              ),
                                              rightTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                      showTitles: false)),
                                              topTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                      showTitles: false)),
                                            ),
                                            borderData:
                                                FlBorderData(show: true),
                                            gridData: FlGridData(show: true),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Parameters and Vitals Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Spirometry Parameters
                  Expanded(
                    flex: 2,
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Spirometry Parameters',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B4FA1),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildParameterGrid(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Vitals
                  Expanded(
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Vitals',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B4FA1),
                              ),
                            ),
                            const SizedBox(height: 16),
                            VitalsWidget(
                              sensorData: widget.vitalsData ??
                                  {
                                    'Airflow': 0.0,
                                    'Volume': 0.0,
                                    'Temperature': 0.0,
                                    'HeartRate': 0,
                                    'Oxygen': 0,
                                    'Confidence': 0,
                                    'DifferentialVoltage': 0.0,
                                  },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfoForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ageController,
            decoration: const InputDecoration(
              labelText: 'Age',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter age' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _heightController,
            decoration: const InputDecoration(
              labelText: 'Height (cm)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter height' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildParameterGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildParameterCard(
            'FVC', '${widget.parameters.fvc.toStringAsFixed(2)} L'),
        _buildParameterCard(
            'FEV1', '${widget.parameters.fev1.toStringAsFixed(2)} L'),
        _buildParameterCard(
            'FEV1/FVC', '${widget.parameters.fev1FvcRatio.toStringAsFixed(2)}'),
        _buildParameterCard(
            'PEF', '${widget.parameters.pef.toStringAsFixed(2)} L/s'),
        _buildParameterCard(
            'FEF25-75', '${widget.parameters.fef2575.toStringAsFixed(2)} L/s'),
      ],
    );
  }

  Widget _buildParameterCard(String title, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B4FA1),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generatePdfReport() async {
    await _showPatientInfoDialog();
    final pdf = await _generateReportDocument();
    Printing.sharePdf(bytes: pdf, filename: 'spirometry_report.pdf');
  }

  Future<Uint8List> _generateReportDocument() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildPDFHeader(),
          _buildPDFContent(),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPDFHeader() {
    return pw.Header(
      level: 0,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Spirometry Test Report',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Name: ${_nameController.text}'),
                  pw.Text('Age: ${_ageController.text} years'),
                  pw.Text('Height: ${_heightController.text} cm'),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}'),
                  pw.Text(
                      'Time: ${DateTime.now().toString().split(' ')[1].substring(0, 8)}'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFContent() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 20),
        pw.Text(
          'Spirometry Parameters',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: [
                _buildPDFTableCell('Parameter'),
                _buildPDFTableCell('Value'),
                _buildPDFTableCell('Unit'),
              ],
            ),
            _buildPDFTableRow(
                'FVC', widget.parameters.fvc.toStringAsFixed(2), 'L'),
            _buildPDFTableRow(
                'FEV1', widget.parameters.fev1.toStringAsFixed(2), 'L'),
            _buildPDFTableRow('FEV1/FVC',
                widget.parameters.fev1FvcRatio.toStringAsFixed(2), ''),
            _buildPDFTableRow(
                'PEF', widget.parameters.pef.toStringAsFixed(2), 'L/s'),
            _buildPDFTableRow('FEF25-75',
                widget.parameters.fef2575.toStringAsFixed(2), 'L/s'),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          'Vitals',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: [
                _buildPDFTableCell('Parameter'),
                _buildPDFTableCell('Value'),
                _buildPDFTableCell('Unit'),
              ],
            ),
            _buildPDFTableRow('Heart Rate',
                widget.vitalsData?['HeartRate']?.toString() ?? '--', 'BPM'),
            _buildPDFTableRow(
                'SpO2', widget.vitalsData?['Oxygen']?.toString() ?? '--', '%'),
            _buildPDFTableRow('Temperature',
                widget.vitalsData?['Temperature']?.toString() ?? '--', '°C'),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPDFTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.TableRow _buildPDFTableRow(String parameter, String value, String unit) {
    return pw.TableRow(
      children: [
        _buildPDFTableCell(parameter),
        _buildPDFTableCell(value),
        _buildPDFTableCell(unit),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _showPatientInfoDialog();
  }
}
