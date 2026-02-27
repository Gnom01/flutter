import 'package:flutter/material.dart';
import '../models/payment_schedule.dart';
import '../models/payment_history.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';

class PaymentScheduleScreen extends StatefulWidget {
  const PaymentScheduleScreen({super.key});

  @override
  State<PaymentScheduleScreen> createState() => _PaymentScheduleScreenState();
}

class _PaymentScheduleScreenState extends State<PaymentScheduleScreen>
    with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  PaymentScheduleResponse? _scheduleResponse;
  PaymentHistoryResponse? _historyResponse;
  String? _selectedGroupName;
  bool _isScheduleLoading = true;
  bool _isHistoryLoading = true;
  String? _scheduleErrorMessage;
  String? _historyErrorMessage;

  @override
  void initState() {
    super.initState();
    _loadScheduleData();
    _loadHistoryData();
  }

  Future<void> _loadScheduleData() async {
    setState(() {
      _isScheduleLoading = true;
      _scheduleErrorMessage = null;
    });

    try {
      final result = await _userService.getPaymentSchedule();
      if (result['success']) {
        setState(() {
          _scheduleResponse = PaymentScheduleResponse.fromJson(result['data']);
          if (_scheduleResponse!.groups.isNotEmpty &&
              _selectedGroupName == null) {
            _selectedGroupName = _scheduleResponse!.groups.keys.first;
          }
          _isScheduleLoading = false;
        });
      } else {
        setState(() {
          _scheduleErrorMessage = result['message'];
          _isScheduleLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _scheduleErrorMessage = 'Błąd: ${e.toString()}';
        _isScheduleLoading = false;
      });
    }
  }

  Future<void> _loadHistoryData() async {
    setState(() {
      _isHistoryLoading = true;
      _historyErrorMessage = null;
    });

    try {
      final authService = AuthService();
      final user = await authService.getCurrentUser();

      if (user == null) {
        setState(() {
          _historyErrorMessage = 'Nie znaleziono danych użytkownika';
          _isHistoryLoading = false;
        });
        return;
      }

      final result = await _userService.getPaymentHistory(user.guid);
      if (result['success']) {
        setState(() {
          _historyResponse = PaymentHistoryResponse.fromJson(result['data']);
          _isHistoryLoading = false;
        });
      } else {
        setState(() {
          _historyErrorMessage = result['message'];
          _isHistoryLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _historyErrorMessage = 'Błąd: ${e.toString()}';
        _isHistoryLoading = false;
      });
    }
  }

  double get _totalScheduleAmount {
    if (_scheduleResponse == null) return 0;
    double total = 0;
    _scheduleResponse!.groups.forEach((key, items) {
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Płatności'),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: brandRed,
            labelColor: brandRed,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Płatności'),
              Tab(text: 'Historia'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildScheduleTab(brandRed), _buildHistoryTab(brandRed)],
        ),
      ),
    );
  }

  Widget _buildScheduleTab(Color brandRed) {
    if (_isScheduleLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_scheduleErrorMessage != null) {
      return _buildErrorView(_scheduleErrorMessage!, _loadScheduleData);
    }
    if (_scheduleResponse == null || _scheduleResponse!.groups.isEmpty) {
      return const Center(child: Text('Brak zaplanowanych płatności'));
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Mamy naliczenia z różnych szkół',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          ),
        ),
        _buildGroupTabs(brandRed),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildPaymentTable(brandRed),
          ),
        ),
        _buildBottomSummary(brandRed),
      ],
    );
  }

  Widget _buildHistoryTab(Color brandRed) {
    if (_isHistoryLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_historyErrorMessage != null) {
      return _buildErrorView(_historyErrorMessage!, _loadHistoryData);
    }
    if (_historyResponse == null || _historyResponse!.items.isEmpty) {
      return const Center(child: Text('Brak historii płatności'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HISTORIA PŁATNOŚCI',
            style: TextStyle(
              color: brandRed,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(child: _buildHistoryTable(brandRed)),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupTabs(Color brandRed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: _scheduleResponse!.groups.keys.map((groupName) {
          bool isSelected = _selectedGroupName == groupName;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton(
                onPressed: () => setState(() => _selectedGroupName = groupName),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isSelected ? brandRed : Colors.white,
                  side: BorderSide(color: brandRed, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Szkoła $groupName',
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
    final items = _scheduleResponse!.groups[_selectedGroupName]!;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
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
        ...items.asMap().entries.map((entry) {
          final item = entry.value;
          final isEven = entry.key % 2 == 1;
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
                    item.paymentAmount.toStringAsFixed(2).replaceAll('.', ','),
                    style: const TextStyle(fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Checkbox(
                    value: item.isSelected,
                    activeColor: brandRed,
                    onChanged: (val) =>
                        setState(() => item.isSelected = val ?? false),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildHistoryTable(Color brandRed) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          decoration: BoxDecoration(
            color: brandRed,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: const Row(
            children: [
              Expanded(flex: 3, child: _HeaderText('Nazwa pozycji')),
              Expanded(flex: 3, child: _HeaderText('Data płatności')),
              Expanded(flex: 2, child: _HeaderText('Kwota')),
              Expanded(flex: 2, child: _HeaderText('Status')),
              Expanded(flex: 1, child: SizedBox.shrink()),
            ],
          ),
        ),
        ..._historyResponse!.items
            .map((item) => _buildHistoryRow(item, brandRed))
            .toList(),
      ],
    );
  }

  Widget _buildHistoryRow(PaymentHistoryItem item, Color brandRed) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(item.name, style: const TextStyle(fontSize: 11)),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  item.date,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  item.amount.toStringAsFixed(2).replaceAll('.', ','),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  item.status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () =>
                      setState(() => item.isExpanded = !item.isExpanded),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFC40233),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.isExpanded ? Icons.remove : Icons.add,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (item.isExpanded)
          ...item.positions.map(
            (pos) => Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      pos.name,
                      style: const TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      pos.date,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      pos.amount.toStringAsFixed(2).replaceAll('.', ','),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      pos.status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  const Expanded(flex: 1, child: SizedBox.shrink()),
                ],
              ),
            ),
          ),
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
              const Text('Do zapłaty:', style: TextStyle(fontSize: 18)),
              Text(
                '${_totalScheduleAmount.toStringAsFixed(2).replaceAll('.', ',')} zł',
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
              onPressed: () {},
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
