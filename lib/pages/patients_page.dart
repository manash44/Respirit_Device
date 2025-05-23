import 'package:flutter/material.dart';
import 'AddPatientPage.dart';
import 'EditPatientPage.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart'; // For PdfColor
import 'package:cross_file/cross_file.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  final Color blue = const Color(0xFF1565C0);
  final Color bg = Colors.white;

  // Filter controllers
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  // Selection state
  Set<String> _selectedPatientIds = {};
  List<Map<String, dynamic>> _recentlyDeletedPatients = [];

  // Sample patient data (replace with actual data source)
  final List<Map<String, dynamic>> _patients = [
    {
      'id': '001',
      'firstName': 'John',
      'lastName': 'Doe',
      'birthDate': '1990-01-01',
    },
    {
      'id': '002',
      'firstName': 'Jane',
      'lastName': 'Smith',
      'birthDate': '1985-05-15',
    },
    {
      'id': '003',
      'firstName': 'Michael',
      'lastName': 'Johnson',
      'birthDate': '1978-11-23',
    },
    {
      'id': '004',
      'firstName': 'Sarah',
      'lastName': 'Williams',
      'birthDate': '1992-03-15',
    },
    {
      'id': '005',
      'firstName': 'David',
      'lastName': 'Brown',
      'birthDate': '1987-07-30',
    },
  ];

  // Memoized filtered patients
  List<Map<String, dynamic>>? _cachedFilteredPatients;
  String? _lastFilterText;

  List<Map<String, dynamic>> get _filteredPatients {
    final currentFilter =
        '${_lastNameController.text}${_firstNameController.text}${_idController.text}';

    if (_cachedFilteredPatients != null && _lastFilterText == currentFilter) {
      return _cachedFilteredPatients!;
    }

    _lastFilterText = currentFilter;
    _cachedFilteredPatients = _patients.where((patient) {
      final lastName = patient['lastName'].toString().toLowerCase();
      final firstName = patient['firstName'].toString().toLowerCase();
      final id = patient['id'].toString().toLowerCase();

      final lastNameFilter = _lastNameController.text.toLowerCase();
      final firstNameFilter = _firstNameController.text.toLowerCase();
      final idFilter = _idController.text.toLowerCase();

      return lastName.contains(lastNameFilter) &&
          firstName.contains(firstNameFilter) &&
          id.contains(idFilter);
    }).toList();

    return _cachedFilteredPatients!;
  }

  void _clearFilters() {
    setState(() {
      _lastNameController.clear();
      _firstNameController.clear();
      _idController.clear();
      _cachedFilteredPatients = null;
      _lastFilterText = null;
    });
  }

  void _toggleSelectPatient(String id) {
    setState(() {
      if (_selectedPatientIds.contains(id)) {
        _selectedPatientIds.remove(id);
      } else {
        _selectedPatientIds.add(id);
      }
    });
  }

  void _selectOnlyPatient(String id) {
    setState(() {
      _selectedPatientIds = {id};
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedPatientIds.clear();
    });
  }

  // Generate next patient ID as a 3-digit string
  String getNextPatientId() {
    if (_patients.isEmpty) return '001';
    final ids =
        _patients.map((p) => int.tryParse(p['id'] ?? '0') ?? 0).toList();
    final maxId = ids.isEmpty ? 0 : ids.reduce((a, b) => a > b ? a : b);
    final nextId = maxId + 1;
    return nextId.toString().padLeft(3, '0');
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 1200;
    final isVerySmallScreen = size.width < 800;

    return Scaffold(
      backgroundColor: bg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isSmallScreen ? size.width - 32 : 1200,
              ),
              padding: EdgeInsets.symmetric(
                vertical: 24,
                horizontal: isVerySmallScreen ? 8 : 16,
              ),
              child: Stack(
                children: [
                  // Watermark logo
                  const Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Opacity(
                      opacity: 0.08,
                      child: Image(
                        image: AssetImage('assets/respirit.png'),
                        height: 400,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                  // Main content
                  Padding(
                    padding: const EdgeInsets.only(left: 80),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const RespiritLogo(),
                        Expanded(
                          child: isVerySmallScreen
                              ? _buildMobileLayout()
                              : _buildDesktopLayout(constraints),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const _BottomAppBar(),
    );
  }

  Widget _buildDesktopLayout(BoxConstraints constraints) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main content (table and header)
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Patients [${_filteredPatients.length}/${_patients.length}]',
                          style: const TextStyle(
                            color: Color(0xFF1565C0),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Divider(
                          thickness: 1.2,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),
                ),
                // Table header and body
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 900,
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      child: Column(
                        children: [
                          // Table header
                          Container(
                            decoration: BoxDecoration(
                              color: blue,
                              boxShadow: [
                                BoxShadow(
                                  color: blue.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: const [
                                _TableHeaderCell('ID', flex: 2),
                                _TableHeaderCell('First Name', flex: 3),
                                _TableHeaderCell('Last Name', flex: 3),
                                _TableHeaderCell('Birth Date', flex: 2),
                              ],
                            ),
                          ),
                          // Table body
                          Expanded(
                            child: Container(
                              color: Colors.white,
                              child: ListView.builder(
                                itemCount: _filteredPatients.length,
                                itemBuilder: (context, index) {
                                  final patient = _filteredPatients[index];
                                  final isSelected = _selectedPatientIds
                                      .contains(patient['id']);
                                  return _PatientRow(
                                    id: patient['id'],
                                    firstName: patient['firstName'],
                                    lastName: patient['lastName'],
                                    birthDate: patient['birthDate'],
                                    isSelected: isSelected,
                                    onTap: () =>
                                        _toggleSelectPatient(patient['id']),
                                    showCheckbox: true,
                                    onCheckboxChanged: (checked) =>
                                        _toggleSelectPatient(patient['id']),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom bar with buttons
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _PatientsBarButton(
                          icon: Icons.person_add,
                          label: 'New',
                          color: blue,
                          onTap: () async {
                            final newPatient = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddPatientPage(
                                  patientId: getNextPatientId(),
                                ),
                              ),
                            );
                            if (newPatient != null &&
                                newPatient is Map<String, dynamic>) {
                              setState(() {
                                _patients.add(newPatient);
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        _PatientsBarButton(
                          icon: Icons.edit,
                          label: 'Edit',
                          color: blue,
                          isEnabled: _selectedPatientIds.length == 1,
                          onTap: () async {
                            if (_selectedPatientIds.length == 1) {
                              final id = _selectedPatientIds.first;
                              final patient = _patients.firstWhere(
                                (p) => p['id'] == id,
                              );
                              final updatedPatient = await Navigator.of(
                                context,
                              ).push(
                                MaterialPageRoute(
                                  builder: (context) => EditPatientPage(
                                    patientId: patient['id'],
                                    initialData: patient,
                                  ),
                                ),
                              );
                              if (updatedPatient != null &&
                                  updatedPatient is Map<String, dynamic>) {
                                setState(() {
                                  final idx = _patients.indexWhere(
                                    (p) => p['id'] == id,
                                  );
                                  if (idx != -1)
                                    _patients[idx] = updatedPatient;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Patient updated successfully!',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        _PatientsBarButton(
                          icon: Icons.monitor_heart,
                          label: 'Test',
                          color: blue,
                          isEnabled: _selectedPatientIds.isNotEmpty,
                          onTap: () {
                            if (_selectedPatientIds.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Test functionality coming soon',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        _PatientsBarButton(
                          icon: Icons.history,
                          label: 'History',
                          color: blue,
                          isEnabled: _selectedPatientIds.isNotEmpty,
                          onTap: () {
                            if (_selectedPatientIds.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'History functionality coming soon',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        _PatientsBarButton(
                          icon: Icons.delete,
                          label: 'Delete',
                          color: Colors.red.shade700,
                          isEnabled: _selectedPatientIds.isNotEmpty,
                          onTap: () async {
                            if (_selectedPatientIds.isNotEmpty) {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    _selectedPatientIds.length == 1
                                        ? 'Delete Patient'
                                        : 'Delete Patients',
                                  ),
                                  content: Text(
                                    _selectedPatientIds.length == 1
                                        ? 'Are you sure you want to delete this patient?'
                                        : 'Are you sure you want to delete these ${_selectedPatientIds.length} patients?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(
                                        context,
                                      ).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(
                                        context,
                                      ).pop(true),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                final deleted = _patients
                                    .where(
                                      (p) => _selectedPatientIds.contains(
                                        p['id'],
                                      ),
                                    )
                                    .toList();
                                setState(() {
                                  _patients.removeWhere(
                                    (p) =>
                                        _selectedPatientIds.contains(p['id']),
                                  );
                                  _recentlyDeletedPatients = deleted;
                                  _selectedPatientIds.clear();
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      _recentlyDeletedPatients.length == 1
                                          ? 'Patient deleted.'
                                          : '${_recentlyDeletedPatients.length} patients deleted.',
                                    ),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () {
                                        setState(() {
                                          _patients.addAll(
                                            _recentlyDeletedPatients,
                                          );
                                          _recentlyDeletedPatients.clear();
                                        });
                                      },
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(
                            Icons.double_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            // TODO: Implement expand/collapse functionality
                          },
                          tooltip: 'Expand/Collapse',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Filter panel
        SizedBox(
          width: 280,
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.double_arrow,
                      color: Color(0xFF1565C0),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filter',
                      style: TextStyle(
                        color: blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _FilterField(
                  label: 'Last Name',
                  color: blue,
                  fontSize: 14,
                  controller: _lastNameController,
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 12),
                _FilterField(
                  label: 'First Name',
                  color: blue,
                  fontSize: 14,
                  controller: _firstNameController,
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 12),
                _FilterField(
                  label: 'ID',
                  color: blue,
                  fontSize: 14,
                  controller: _idController,
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 2,
                      shadowColor: blue.withOpacity(0.3),
                    ),
                    onPressed: _clearFilters,
                    child: const Text('Clear', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Filter panel
        Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.double_arrow,
                    color: Color(0xFF1565C0),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filter',
                    style: TextStyle(
                      color: blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _FilterField(
                label: 'Last Name',
                color: blue,
                fontSize: 14,
                controller: _lastNameController,
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 12),
              _FilterField(
                label: 'First Name',
                color: blue,
                fontSize: 14,
                controller: _firstNameController,
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 12),
              _FilterField(
                label: 'ID',
                color: blue,
                fontSize: 14,
                controller: _idController,
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 2,
                    shadowColor: blue.withOpacity(0.3),
                  ),
                  onPressed: _clearFilters,
                  child: const Text('Clear', style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Main content
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Patients [${_filteredPatients.length}/${_patients.length}]',
                          style: const TextStyle(
                            color: Color(0xFF1565C0),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Divider(
                          thickness: 1.2,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),
                ),
                // Table
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Table header
                          Container(
                            decoration: BoxDecoration(
                              color: blue,
                              boxShadow: [
                                BoxShadow(
                                  color: blue.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: const [
                                _TableHeaderCell('ID', flex: 2),
                                _TableHeaderCell('First Name', flex: 3),
                                _TableHeaderCell('Last Name', flex: 3),
                                _TableHeaderCell('Birth Date', flex: 2),
                              ],
                            ),
                          ),
                          // Table body
                          ..._filteredPatients.map((patient) {
                            final isSelected = _selectedPatientIds.contains(
                              patient['id'],
                            );
                            return _PatientRow(
                              id: patient['id'],
                              firstName: patient['firstName'],
                              lastName: patient['lastName'],
                              birthDate: patient['birthDate'],
                              isSelected: isSelected,
                              onTap: () => _toggleSelectPatient(patient['id']),
                              showCheckbox: true,
                              onCheckboxChanged: (checked) =>
                                  _toggleSelectPatient(patient['id']),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _PatientsBarButton(
                          icon: Icons.person_add,
                          label: 'New',
                          color: blue,
                          onTap: () async {
                            final newPatient = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddPatientPage(
                                  patientId: getNextPatientId(),
                                ),
                              ),
                            );
                            if (newPatient != null &&
                                newPatient is Map<String, dynamic>) {
                              setState(() {
                                _patients.add(newPatient);
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        _PatientsBarButton(
                          icon: Icons.edit,
                          label: 'Edit',
                          color: blue,
                          isEnabled: _selectedPatientIds.length == 1,
                          onTap: () async {
                            if (_selectedPatientIds.length == 1) {
                              final id = _selectedPatientIds.first;
                              final patient = _patients.firstWhere(
                                (p) => p['id'] == id,
                              );
                              final updatedPatient = await Navigator.of(
                                context,
                              ).push(
                                MaterialPageRoute(
                                  builder: (context) => EditPatientPage(
                                    patientId: patient['id'],
                                    initialData: patient,
                                  ),
                                ),
                              );
                              if (updatedPatient != null &&
                                  updatedPatient is Map<String, dynamic>) {
                                setState(() {
                                  final idx = _patients.indexWhere(
                                    (p) => p['id'] == id,
                                  );
                                  if (idx != -1)
                                    _patients[idx] = updatedPatient;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Patient updated successfully!',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        _PatientsBarButton(
                          icon: Icons.monitor_heart,
                          label: 'Test',
                          color: blue,
                          isEnabled: _selectedPatientIds.isNotEmpty,
                          onTap: () {
                            if (_selectedPatientIds.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Test functionality coming soon',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        _PatientsBarButton(
                          icon: Icons.history,
                          label: 'History',
                          color: blue,
                          isEnabled: _selectedPatientIds.isNotEmpty,
                          onTap: () {
                            if (_selectedPatientIds.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'History functionality coming soon',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        _PatientsBarButton(
                          icon: Icons.delete,
                          label: 'Delete',
                          color: Colors.red.shade700,
                          isEnabled: _selectedPatientIds.isNotEmpty,
                          onTap: () async {
                            if (_selectedPatientIds.isNotEmpty) {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    _selectedPatientIds.length == 1
                                        ? 'Delete Patient'
                                        : 'Delete Patients',
                                  ),
                                  content: Text(
                                    _selectedPatientIds.length == 1
                                        ? 'Are you sure you want to delete this patient?'
                                        : 'Are you sure you want to delete these ${_selectedPatientIds.length} patients?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(
                                        context,
                                      ).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(
                                        context,
                                      ).pop(true),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                final deleted = _patients
                                    .where(
                                      (p) => _selectedPatientIds.contains(
                                        p['id'],
                                      ),
                                    )
                                    .toList();
                                setState(() {
                                  _patients.removeWhere(
                                    (p) =>
                                        _selectedPatientIds.contains(p['id']),
                                  );
                                  _recentlyDeletedPatients = deleted;
                                  _selectedPatientIds.clear();
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      _recentlyDeletedPatients.length == 1
                                          ? 'Patient deleted.'
                                          : '${_recentlyDeletedPatients.length} patients deleted.',
                                    ),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () {
                                        setState(() {
                                          _patients.addAll(
                                            _recentlyDeletedPatients,
                                          );
                                          _recentlyDeletedPatients.clear();
                                        });
                                      },
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _exportPdf() async {
    final pdf = pw.Document();
    final headers = ['ID', 'First Name', 'Last Name', 'Birth Date'];
    final rows = _filteredPatients
        .map(
          (p) => [
            p['id'] ?? '',
            p['firstName'] ?? '',
            p['lastName'] ?? '',
            p['birthDate'] ?? '',
          ],
        )
        .toList();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Patients Export',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headers: headers,
              data: rows,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromInt(0xFFFFFFFF),
              ),
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF1565C0),
              ),
              headerHeight: 28,
              cellHeight: 24,
              cellStyle: pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
    final bytes = await pdf.save();
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/patients_export.pdf';
    final file = File(path);
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: 'Patients Export PDF');
  }

  Future<void> _printPatients() async {
    final pdf = pw.Document();
    final headers = ['ID', 'First Name', 'Last Name', 'Birth Date'];
    final rows = _filteredPatients
        .map(
          (p) => [
            p['id'] ?? '',
            p['firstName'] ?? '',
            p['lastName'] ?? '',
            p['birthDate'] ?? '',
          ],
        )
        .toList();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Patients Export',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headers: headers,
              data: rows,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromInt(0xFFFFFFFF),
              ),
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF1565C0),
              ),
              headerHeight: 28,
              cellHeight: 24,
              cellStyle: pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}

class _PatientRow extends StatelessWidget {
  final String id;
  final String firstName;
  final String lastName;
  final String birthDate;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showCheckbox;
  final ValueChanged<bool?>? onCheckboxChanged;

  const _PatientRow({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.isSelected,
    required this.onTap,
    this.showCheckbox = false,
    this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF1565C0).withOpacity(0.1)
                : Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
          ),
          child: Row(
            children: [
              if (showCheckbox)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: onCheckboxChanged,
                  ),
                ),
              Expanded(
                flex: 2,
                child: Text(
                  id,
                  style: TextStyle(
                    color:
                        isSelected ? const Color(0xFF1565C0) : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  firstName,
                  style: TextStyle(
                    color:
                        isSelected ? const Color(0xFF1565C0) : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  lastName,
                  style: TextStyle(
                    color:
                        isSelected ? const Color(0xFF1565C0) : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  birthDate,
                  style: TextStyle(
                    color:
                        isSelected ? const Color(0xFF1565C0) : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  const _TableHeaderCell(this.label, {this.flex = 1, super.key});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _PatientsBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isEnabled;

  const _PatientsBarButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.isEnabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          isEnabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? color : color.withOpacity(0.5),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 2,
          shadowColor: color.withOpacity(0.3),
        ),
        onPressed: isEnabled ? onTap : null,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  final String label;
  final Color color;
  final double fontSize;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const _FilterField({
    required this.label,
    required this.color,
    required this.fontSize,
    required this.controller,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: fontSize,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(fontSize: fontSize),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: color),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: color),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: color.withOpacity(0.5)),
            ),
          ),
        ),
      ],
    );
  }
}

class RespiritLogo extends StatelessWidget {
  const RespiritLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Image(
        image: AssetImage('assets/respirit.png'),
        height: 60,
      ),
    );
  }
}

class _BottomAppBar extends StatelessWidget {
  const _BottomAppBar();

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 8,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1565C0)),
              label: const Text(
                'Return',
                style: TextStyle(color: Color(0xFF1565C0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
