import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';

class UserEditScreen extends StatefulWidget {
  final UserProfile profile;

  const UserEditScreen({super.key, required this.profile});

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _peselController;
  late TextEditingController _streetController;
  late TextEditingController _buildingController;
  late TextEditingController _flatController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;

  final UserService _userService = UserService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.profile.firstName,
    );
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _dateOfBirthController = TextEditingController(
      text: widget.profile.dateOfBirth,
    );
    _peselController = TextEditingController(text: widget.profile.pesel);
    _streetController = TextEditingController(text: widget.profile.street);
    _buildingController = TextEditingController(text: widget.profile.building);
    _flatController = TextEditingController(text: widget.profile.flat);
    _cityController = TextEditingController(text: widget.profile.city);
    _postalCodeController = TextEditingController(
      text: widget.profile.postalCode,
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _peselController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _flatController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedData = {
        'FirstName': _firstNameController.text.trim(),
        'LastName': _lastNameController.text.trim(),
        'Email': _emailController.text.trim(),
        'Phone': _phoneController.text.trim(),
        'DateOfBirdth': _dateOfBirthController.text.trim(),
        'Pesel': _peselController.text.trim(),
        'Street': _streetController.text.trim(),
        'Building': _buildingController.text.trim(),
        'Flat': _flatController.text.trim(),
        'City': _cityController.text.trim(),
        'PostalCode': _postalCodeController.text.trim(),
      };

      final result = await _userService.updateUserProfile(
        widget.profile.guid,
        updatedData,
      );

      if (result['success']) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dane zostały zaktualizowane'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        setState(() {
          _isSaving = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Błąd zapisu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Błąd: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edycja danych'),
        centerTitle: true,
        actions: [
          if (!_isSaving)
            IconButton(icon: const Icon(Icons.check), onPressed: _saveChanges),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionHeader('Dane podstawowe'),
                    _buildTextField(
                      controller: _firstNameController,
                      label: 'Imię',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Pole wymagane'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _lastNameController,
                      label: 'Nazwisko',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Pole wymagane'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _dateOfBirthController,
                      label: 'Data urodzenia (RRRR-MM-DD)',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _peselController,
                      label: 'PESEL',
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Dane kontaktowe'),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Pole wymagane';
                        if (!value.contains('@')) return 'Błędny format email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Telefon',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Adres zamieszkania'),
                    _buildTextField(
                      controller: _streetController,
                      label: 'Ulica',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _buildingController,
                            label: 'Nr budynku',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _flatController,
                            label: 'Nr lokalu',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _cityController,
                      label: 'Miasto',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _postalCodeController,
                      label: 'Kod pocztowy',
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE20613),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'ZAPISZ ZMIANY',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
