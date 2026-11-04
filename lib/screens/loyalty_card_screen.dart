import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vic/screens/admin.dart';
import 'package:vic/timkiem/search_page.dart';
import 'package:vic/widgets/vip.dart';

import '../models/customer_model.dart';
import '../widgets/loyalty_card_front.dart';

class LoyaltyCardScreen extends StatefulWidget {
  const LoyaltyCardScreen({super.key});

  @override
  State<LoyaltyCardScreen> createState() => _LoyaltyCardScreenState();
}

class _LoyaltyCardScreenState extends State<LoyaltyCardScreen> {
  // Thay bằng thông tin demo của bạn tại máy.
  static const String _demoUsername = 'a';
  static const String _demoPassword = 'a';

  bool _isSavingPoint = false;
  bool _isLoggedIn = false;

  CustomerModel customer = const CustomerModel(
    id: 'Tan2412',
    name: 'Lê Thanh Tân',
    phone: '0364273884',
    points: 25,
  );

  Future<void> _addPoint() async {
    if (_isSavingPoint) return;

    String? _customerDocId;

    final docId = _customerDocId;
    if (docId == null || docId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn khách hàng trước.')),
      );
      return;
    }

    if (customer.points >= 35) return;

    setState(() => _isSavingPoint = true);

    try {
      await FirebaseFirestore.instance.collection('vic').doc(docId).update({
        'solan': FieldValue.increment(1),
      });

      if (!mounted) return;

      setState(() {
        customer = CustomerModel(
          id: customer.id,
          name: customer.name,
          phone: customer.phone,
          points: customer.points + 1,
        );
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể cập nhật điểm: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingPoint = false);
      }
    }
  }

  int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> _showLoginDialog() async {
    final enteredCredentials = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _LoginDialog(),
    );

    if (!mounted || enteredCredentials == null) return;

    final username = enteredCredentials['username'];
    final password = enteredCredentials['password'];

    if (username == _demoUsername && password == _demoPassword) {
      setState(() {
        _isLoggedIn = true;
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoyaltyCardScreen1()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tài khoản hoặc mật khẩu không đúng')),
      );
    }
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã đăng xuất')));
  }

  Future<void> _openSearchPage() async {
    final selectedCustomer = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const SearchPage()),
    );

    if (!mounted || selectedCustomer == null) return;

    setState(() {
      customer = CustomerModel(
        id: selectedCustomer['id']?.toString() ?? '',
        name: selectedCustomer['name']?.toString() ?? '',
        phone: selectedCustomer['sdt']?.toString() ?? '',
        points: _toInt(selectedCustomer['solan']),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Nền thiên nhiên xanh dương
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE4F4FF),
                    Color(0xFFD1E9F3),
                    Color(0xFFEAF5E9),
                    Color(0xFFDCEBFA),
                  ],
                ),
              ),
            ),
          ),

          // Ánh sáng trang trí phía trên
          const Positioned(
            top: -65,
            right: -55,
            child: _BackgroundCircle(size: 230, color: Color(0x453DABAE)),
          ),

          // Ánh sáng phía dưới
          const Positioned(
            bottom: 80,
            left: -85,
            child: _BackgroundCircle(size: 250, color: Color(0x354A9BBD)),
          ),

          // Cây trang trí
          const Positioned(
            top: 150,
            left: 8,
            child: Icon(Icons.park_rounded, size: 85, color: Color(0x303B927D)),
          ),

          const Positioned(
            bottom: 20,
            right: 5,
            child: Icon(
              Icons.forest_rounded,
              size: 110,
              color: Color(0x303B927D),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 750;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 40 : 20,
                    vertical: 25,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        children: [
                          // Logo VIC
                          const Icon(
                            Icons.eco_rounded,
                            color: Color(0xFF16856D),
                            size: 38,
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'VIC',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 7,
                              color: Color(0xFF12477F),
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            'KHÁCH HÀNG THÂN THIẾT',
                            style: TextStyle(
                              color: Color(0xFF527A9F),
                              fontSize: 11,
                              letterSpacing: 3,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Nút tìm kiếm khách hàng
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _openSearchPage,
                              icon: const Icon(Icons.search_rounded),
                              label: const Text('Tìm kiếm khách hàng'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16856D),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Hai mặt thẻ
                          if (isWide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: LoyaltyCardFront(customer: customer),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: LoyaltyCardBack(
                                    points: customer.points,
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            LoyaltyCardFront(customer: customer),
                            const SizedBox(height: 22),
                            LoyaltyCardBack(points: customer.points),
                          ],

                          const SizedBox(height: 28),

                          // Lời tri ân
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 17,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF315F80,
                                  ).withValues(alpha: 0.07),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Column(
                              children: [
                                Text(
                                  '💙 CẢM ƠN BẠN ĐÃ ĐỒNG HÀNH',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF174B7C),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 7),
                                Text(
                                  'Mỗi điểm thưởng là một lời tri ân từ VIC.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF65809B),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'VIC • LOYALTY PROGRAM',
                            style: TextStyle(
                              color: Color(0xFF65809B),
                              fontSize: 10,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Nút đăng nhập / đăng xuất ở cuối trang
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isLoggedIn
                                  ? _logout
                                  : _showLoginDialog,
                              icon: Icon(
                                _isLoggedIn
                                    ? Icons.logout_rounded
                                    : Icons.login_rounded,
                              ),
                              label: Text(
                                _isLoggedIn
                                    ? 'Đăng xuất'
                                    : 'Đăng nhập tài khoản',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF12477F),
                                side: const BorderSide(
                                  color: Color(0xFF16856D),
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Hộp thoại tự sở hữu và dispose controller
class _LoginDialog extends StatefulWidget {
  const _LoginDialog();

  @override
  State<_LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<_LoginDialog> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submit() {
    Navigator.of(context).pop<Map<String, String>>({
      'username': _usernameController.text.trim(),
      'password': _passwordController.text,
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Đăng nhập'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Tài khoản',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            onSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Mật khẩu',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Đăng nhập')),
      ],
    );
  }
}

// Trang trí nền
class _BackgroundCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BackgroundCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
