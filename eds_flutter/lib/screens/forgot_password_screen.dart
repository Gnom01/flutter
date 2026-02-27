import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authService = AuthService();

  int _step = 0;
  bool _isLoading = false;

  // Step 1 – phone
  final _phoneController = TextEditingController();
  String _phone = '';

  // Step 2 – OTP
  final _otpController = TextEditingController();
  String _otpToken = '';

  // Step 3 – new password
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── Step handlers ────────────────────────────────────────────────────────

  Future<void> _sendOtp() async {
    if (!_formKeys[0].currentState!.validate()) return;
    setState(() => _isLoading = true);
    _phone = _phoneController.text.trim();
    final result = await _authService.resetPasswordRequest(_phone);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() => _step = 1);
    } else {
      _showError(result['message'] ?? 'Nie znaleziono konta');
    }
  }

  Future<void> _verifyOtp() async {
    if (!_formKeys[1].currentState!.validate()) return;
    setState(() => _isLoading = true);
    final result = await _authService.verifySmsOtp(
      _phone,
      _otpController.text.trim(),
    );
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (result['success'] == true) {
      _otpToken = result['otp_token'] ?? '';
      setState(() => _step = 2);
    } else {
      _showError(result['message'] ?? 'Nieprawidłowy kod SMS');
    }
  }

  Future<void> _confirmReset() async {
    if (!_formKeys[2].currentState!.validate()) return;
    setState(() => _isLoading = true);
    final result = await _authService.resetPasswordConfirm(
      phone: _phone,
      otpToken: _otpToken,
      newPassword: _passwordController.text,
    );
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Hasło zostało zmienione. Możesz się zalogować.'),
          backgroundColor: Colors.green.shade600,
        ),
      );
      Navigator.of(context).pop();
    } else {
      _showError(result['message'] ?? 'Błąd zmiany hasła');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade400),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.fromARGB(255, 228, 228, 228), Color(0xFF111827)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildStepIndicator(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildStepCard(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () {
              if (_step > 0) {
                setState(() => _step--);
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          Expanded(
            child: Text(
              'Odzyskaj hasło',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    const labels = ['Telefon', 'Kod SMS', 'Hasło'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final active = i <= _step;
          return Row(
            children: [
              if (i > 0)
                Container(
                  width: 40,
                  height: 2,
                  color: active ? const Color(0xFFE20613) : Colors.white30,
                ),
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _step
                          ? const Color(0xFFE20613)
                          : i == _step
                          ? Colors.white
                          : Colors.white24,
                    ),
                    child: Center(
                      child: i < _step
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: i == _step
                                    ? const Color(0xFF1F2937)
                                    : Colors.white54,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[i],
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      color: active ? Colors.white : Colors.white54,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStepCard() {
    return Container(
      key: ValueKey(_step),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: switch (_step) {
        0 => _buildPhoneStep(),
        1 => _buildOtpStep(),
        _ => _buildNewPasswordStep(),
      },
    );
  }

  // ─── Step 1 – Phone ────────────────────────────────────────────────────────

  Widget _buildPhoneStep() {
    return Form(
      key: _formKeys[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stepTitle('Podaj numer telefonu'),
          const SizedBox(height: 8),
          Text(
            'Wyślemy Ci kod SMS, aby zweryfikować Twoje konto.',
            style: GoogleFonts.lato(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _inputDecoration(
              label: 'Numer telefonu',
              icon: Icons.phone_outlined,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Wprowadź numer telefonu';
              if (v.length < 9) return 'Numer musi mieć co najmniej 9 cyfr';
              return null;
            },
          ),
          const SizedBox(height: 28),
          _primaryButton(
            label: 'Wyślij kod SMS',
            onPressed: _sendOtp,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  // ─── Step 2 – OTP ──────────────────────────────────────────────────────────

  Widget _buildOtpStep() {
    return Form(
      key: _formKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stepTitle('Wpisz kod SMS'),
          const SizedBox(height: 8),
          Text(
            'Kod został wysłany na numer $_phone.',
            style: GoogleFonts.lato(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 6,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 12,
            ),
            decoration: _inputDecoration(
              label: 'Kod SMS',
              icon: Icons.sms_outlined,
            ).copyWith(counterText: ''),
            validator: (v) {
              if (v == null || v.length < 4) return 'Wprowadź kod SMS';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isLoading ? null : _sendOtp,
            child: Text(
              'Wyślij ponownie',
              style: GoogleFonts.lato(color: const Color(0xFFE20613)),
            ),
          ),
          const SizedBox(height: 16),
          _primaryButton(
            label: 'Potwierdź',
            onPressed: _verifyOtp,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  // ─── Step 3 – New password ─────────────────────────────────────────────────

  Widget _buildNewPasswordStep() {
    return Form(
      key: _formKeys[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stepTitle('Ustaw nowe hasło'),
          const SizedBox(height: 24),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration:
                _inputDecoration(
                  label: 'Nowe hasło',
                  icon: Icons.lock_outline,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Wprowadź hasło';
              if (v.length < 8) return 'Hasło musi mieć co najmniej 8 znaków';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            decoration:
                _inputDecoration(
                  label: 'Powtórz hasło',
                  icon: Icons.lock_outline,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
            validator: (v) {
              if (v != _passwordController.text) return 'Hasła nie są zgodne';
              return null;
            },
          ),
          const SizedBox(height: 28),
          _primaryButton(
            label: 'Zmień hasło',
            onPressed: _confirmReset,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _stepTitle(String title) => Text(
    title,
    style: GoogleFonts.lato(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: const Color(0xFF1F2937),
    ),
  );

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE20613), width: 2),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE20613),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
