import 'package:flutter/material.dart';
import '../models/payment_schedule.dart';
import '../services/user_service.dart';

class PaymentScheduleScreen extends StatefulWidget {
  const PaymentScheduleScreen({super.key});

  @override
  State<PaymentScheduleScreen> createState() => _PaymentScheduleScreenState();
}

class _PaymentScheduleScreenState extends State<PaymentScheduleScreen> {
  final UserService _userService = UserService();
  PaymentScheduleResponse? _response;
  String? _selectedGroupName;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _userService.getPaymentSchedule();

      // The user requested to log the response
      print('API Response for /api/payments/schedule: $result');

      if (result['success']) {
        setState(() {
          _response = PaymentScheduleResponse.fromJson(result['data']);
          if (_response!.groups.isNotEmpty) {
            _selectedGroupName = _response!.groups.keys.first;
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Błąd: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  double get _totalAmount {
    if (_response == null) return 0;
    double total = 0;
    _response!.groups.forEach((key, items) {
      for (var item in items) {
        if (item.isSelected) {
          total += item.paymentAmount;
        }
      }
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    const brandRed = Color(0xFFC40233);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Harmonogram płatności'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : _response == null || _response!.groups.isEmpty
          ? const Center(child: Text('Brak danych harmonogramu'))
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Mamy naliczenia z różnych szkół',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                _buildGroupTabs(brandRed),
                const SizedBox(height: 16),
                Expanded(child: _buildPaymentTable(brandRed)),
                _buildBottomSummary(brandRed),
              ],
            ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Wystąpił nieoczekiwany błąd',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupTabs(Color brandRed) {
    if (_response == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: _response!.groups.keys.map((groupName) {
          bool isSelected = _selectedGroupName == groupName;

          // Fallback for numeric IDs
          debugPrint('Group name: $groupName');
          String displayTitle = 'Szkoła $groupName';

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedGroupName = groupName;
                  });
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: isSelected ? brandRed : Colors.white,
                  side: BorderSide(color: brandRed, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  displayTitle,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentTable(Color brandRed) {
    if (_selectedGroupName == null || _response == null) {
      return const SizedBox.shrink();
    }

    final items = _response!.groups[_selectedGroupName]!;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Table Header
        Container(
          color: brandRed,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: const Row(
            children: [
              Expanded(flex: 3, child: _HeaderText('Nazwa\npozycji')),
              Expanded(flex: 2, child: _HeaderText('Uczestnik')),
              Expanded(flex: 2, child: _HeaderText('Termin')),
              Expanded(flex: 2, child: _HeaderText('Kwota')),
              Expanded(flex: 1, child: _HeaderText('Wybierz')),
            ],
          ),
        ),
        // Table Rows
        ...items.asMap().entries.map((entry) {
          int index = entry.key;
          PaymentItem item = entry.value;
          bool isEven =
              index % 2 ==
              1; // Starting with index 0 (top item in image is white)

          return Container(
            color: isEven ? Colors.grey[200] : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    item.productName,
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    item.userFullName,
                    style: const TextStyle(fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    item.paymentDate,
                    style: const TextStyle(fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${item.paymentAmount.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Checkbox(
                    value: item.isSelected,
                    activeColor: brandRed,
                    onChanged: (value) {
                      setState(() {
                        item.isSelected = value ?? false;
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildBottomSummary(Color brandRed) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Do zapłaty:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
              ),
              Text(
                '${_totalAmount.toStringAsFixed(2).replaceAll('.', ',')} zł',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          SizedBox(
            height: 50,
            width: 140,
            child: ElevatedButton(
              onPressed: () {
                // Handle payment
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: brandRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'OPŁAĆ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
