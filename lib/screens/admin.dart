import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vic/timkiem/search_page.dart';
import 'package:vic/screens/vip_screen.dart';

import '../models/customer_model.dart';
import '../widgets/loyalty_card_front.dart';
import '../widgets/loyalty_card_back.dart';

class LoyaltyCardScreen1 extends StatefulWidget {
  const LoyaltyCardScreen1({super.key});

  @override
  State<LoyaltyCardScreen1> createState() => _LoyaltyCardScreenState();
}

class _LoyaltyCardScreenState extends State<LoyaltyCardScreen1> {
  String? _customerDocId;
  bool _isSavingPoint = false;

  CustomerModel customer = const CustomerModel(
    id: 'tan2412',
    name: 'Lê Thanh Tân',
    phone: '0364273884',
    points: 25,
  );

  int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> _openSearchPage() async {
    if (_isSavingPoint) return;

    final selectedCustomer = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const SearchPage()),
    );

    if (!mounted || selectedCustomer == null) return;

    setState(() {
      _customerDocId = selectedCustomer['docId']?.toString();
      customer = CustomerModel(
        id: selectedCustomer['id']?.toString() ?? '',
        name: selectedCustomer['name']?.toString() ?? '',
        phone: selectedCustomer['sdt']?.toString() ?? '',
        points: _toInt(selectedCustomer['solan']),
      );
    });
  }

  Future<void> _openAddCustomerPage() async {
    if (_isSavingPoint) return;

    final newCustomer = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AddVicCustomerPage()),
    );

    if (!mounted || newCustomer == null) return;

    setState(() {
      _customerDocId = newCustomer['docId']?.toString();
      customer = CustomerModel(
        id: newCustomer['id']?.toString() ?? '',
        name: newCustomer['name']?.toString() ?? '',
        phone: newCustomer['sdt']?.toString() ?? '',
        points: _toInt(newCustomer['solan']),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã thêm khách hàng vào danh sách VIC.')),
    );
  }

  Future<void> _openVipScreen() async {
    if (_isSavingPoint) return;

    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const VipScreen()),
    );
  }

  Future<void> _addPoint() async {
    if (_isSavingPoint) return;

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

  // Nút Đổi quà cũ: đặt số lần của khách hiện tại về 0.
  Future<void> _redeemReward() async {
    if (_isSavingPoint) return;

    final docId = _customerDocId;
    if (docId == null || docId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn khách hàng trước.')),
      );
      return;
    }

    setState(() => _isSavingPoint = true);

    try {
      await FirebaseFirestore.instance.collection('vic').doc(docId).update({
        'solan': 0,
      });

      if (!mounted) return;
      setState(() {
        customer = CustomerModel(
          id: customer.id,
          name: customer.name,
          phone: customer.phone,
          points: 0,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đổi quà thành công. Điểm đã về 0.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể đổi quà: $error')));
    } finally {
      if (mounted) {
        setState(() => _isSavingPoint = false);
      }
    }
  }

  // Trừ số lần bằng transaction để kiểm tra số điểm mới nhất trên Firestore.
  // Nếu không đủ điểm thì không cập nhật dữ liệu.
  Future<void> _spendPoints(int amount, {required String rewardName}) async {
    if (_isSavingPoint) return;

    final docId = _customerDocId;
    if (docId == null || docId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn khách hàng trước.')),
      );
      return;
    }

    setState(() => _isSavingPoint = true);

    try {
      final db = FirebaseFirestore.instance;
      final customerRef = db.collection('vic').doc(docId);

      final result = await db.runTransaction<_SpendPointsResult>((
        transaction,
      ) async {
        final snapshot = await transaction.get(customerRef);
        if (!snapshot.exists) {
          throw StateError('Không tìm thấy khách hàng trong vic.');
        }

        final currentPoints = _toInt(snapshot.data()?['solan']);
        if (currentPoints < amount) {
          return _SpendPointsResult(
            success: false,
            currentPoints: currentPoints,
          );
        }

        final remainingPoints = currentPoints - amount;
        transaction.update(customerRef, {'solan': remainingPoints});

        return _SpendPointsResult(
          success: true,
          currentPoints: remainingPoints,
        );
      });

      if (!mounted) return;

      setState(() {
        customer = CustomerModel(
          id: customer.id,
          name: customer.name,
          phone: customer.phone,
          points: result.currentPoints,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.success
                ? '$rewardName thành công. Còn ${result.currentPoints} lần.'
                : 'Không đủ lần để $rewardName. '
                      'Hiện có ${result.currentPoints} lần, cần $amount lần.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể cập nhật số lần: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingPoint = false);
      }
    }
  }

  Future<void> _reduceOnePoint() async {
    await _spendPoints(1, rewardName: 'Giảm 1 lần');
  }

  Future<void> _redeemSevenPoints() async {
    await _spendPoints(7, rewardName: 'Đổi quà 7');
  }

  Future<void> _redeemFifteenPoints() async {
    await _spendPoints(15, rewardName: 'Đổi quà 15');
  }

  Future<void> _promoteVipCustomers() async {
    if (_isSavingPoint) return;

    final db = FirebaseFirestore.instance;
    final vicCollection = db.collection('vic');
    final vipCollection = db.collection('vip');

    setState(() => _isSavingPoint = true);

    try {
      final previewSnapshot = await vicCollection.get();
      final eligibleCount = previewSnapshot.docs
          .where((doc) => _toInt(doc.data()['solan']) >= 7)
          .length;

      if (!mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Chuyển khách lên VIP?'),
          content: Text(
            'Hiện có $eligibleCount khách đạt từ 7 lần trở lên trong vic. '
            'Nếu tiếp tục, mỗi khách đủ điều kiện sẽ được thêm thành một '
            'bản ghi mới trong vip (không ghi đè lịch sử cũ). solan sẽ được '
            'đặt về 0 cho tất cả ${previewSnapshot.docs.length} hồ sơ trong '
            'vic; hồ sơ trong vic vẫn được giữ lại.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB3261E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Tiếp tục'),
            ),
          ],
        ),
      );

      if (!mounted || confirmed != true) return;

      final latestSnapshot = await vicCollection.get();
      final docs = latestSnapshot.docs;
      var promotedCount = 0;

      for (var start = 0; start < docs.length; start += 200) {
        final batch = db.batch();
        final end = (start + 200 < docs.length) ? start + 200 : docs.length;

        for (var index = start; index < end; index++) {
          final doc = docs[index];
          final data = doc.data();

          if (_toInt(data['solan']) >= 7) {
            // Mỗi lần đủ điều kiện tạo một document VIP mới để lưu lịch sử.
            final vipRecord = <String, dynamic>{
              ...data,
              'sourceDocId': doc.id,
              // Thời điểm nhấn Đặc quyền, ghi đè datetime cũ từ vic.
              'datetime': FieldValue.serverTimestamp(),
              'vipAddedAt': FieldValue.serverTimestamp(),
            };
            batch.set(vipCollection.doc(), vipRecord);
            promotedCount++;
          }

          // Đặt solan về 0, không xóa hồ sơ trong vic.
          batch.update(doc.reference, {'solan': 0});
        }

        await batch.commit();
      }

      if (!mounted) return;

      setState(() {
        customer = CustomerModel(
          id: customer.id,
          name: customer.name,
          phone: customer.phone,
          points: 0,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã thêm $promotedCount lượt VIP mới và đặt solan về 0 cho '
            '${docs.length} hồ sơ trong vic.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể hoàn tất thao tác VIP. Có thể một số nhóm đã được '
            'cập nhật; hãy kiểm tra dữ liệu Firestore trước khi chạy lại. '
            'Chi tiết: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingPoint = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          const Positioned(
            top: -65,
            right: -55,
            child: _BackgroundCircle(size: 230, color: Color(0x453DABAE)),
          ),
          const Positioned(
            bottom: 80,
            left: -85,
            child: _BackgroundCircle(size: 250, color: Color(0x354A9BBD)),
          ),
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

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _openAddCustomerPage,
                              icon: const Icon(Icons.person_add_alt_1_rounded),
                              label: const Text('Thêm khách hàng'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF16856D),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFF16856D),
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

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _openVipScreen,
                              icon: const Icon(Icons.workspace_premium_rounded),
                              label: const Text('Danh sách VIP'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF12477F),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFF16856D),
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

                          const SizedBox(height: 28),

                          if (isWide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: LoyaltyCardFront(customer: customer),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: LoyaltyCardBack1(
                                    points: customer.points,
                                    onStampTap: _addPoint,
                                    onRedeemTap: _redeemReward,
                                    onRedeem7Tap: _redeemSevenPoints,
                                    onRedeem15Tap: _redeemFifteenPoints,
                                    onPrivilegesTap: _promoteVipCustomers,
                                    onMinusOneTap: _reduceOnePoint,
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            LoyaltyCardFront(customer: customer),
                            const SizedBox(height: 22),
                            LoyaltyCardBack1(
                              points: customer.points,
                              onStampTap: _addPoint,
                              onRedeemTap: _redeemReward,
                              onRedeem7Tap: _redeemSevenPoints,
                              onRedeem15Tap: _redeemFifteenPoints,
                              onPrivilegesTap: _promoteVipCustomers,
                              onMinusOneTap: _reduceOnePoint,
                            ),
                          ],

                          const SizedBox(height: 28),

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

class _SpendPointsResult {
  final bool success;
  final int currentPoints;

  const _SpendPointsResult({
    required this.success,
    required this.currentPoints,
  });
}

class AddVicCustomerPage extends StatefulWidget {
  const AddVicCustomerPage({super.key});

  @override
  State<AddVicCustomerPage> createState() => _AddVicCustomerPageState();
}

class _AddVicCustomerPageState extends State<AddVicCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');

    setState(() => _isSaving = true);

    try {
      final vicCollection = FirebaseFirestore.instance.collection('vic');
      final existingCustomers = await vicCollection.get();
      final normalizedName = name.toLowerCase();

      final hasDuplicatePair = existingCustomers.docs.any((doc) {
        final data = doc.data();
        final existingName = (data['name']?.toString() ?? '')
            .trim()
            .toLowerCase();
        final existingPhone = (data['sdt']?.toString() ?? '').replaceAll(
          RegExp(r'\D'),
          '',
        );

        // Chỉ chặn khi tên và số điện thoại đều trùng.
        return existingName == normalizedName && existingPhone == phone;
      });

      if (hasDuplicatePair) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Khách hàng có cùng tên và số điện thoại đã tồn tại.',
            ),
          ),
        );
        return;
      }

      final customerRef = vicCollection.doc();

      await customerRef.set({
        'id': customerRef.id,
        'name': name,
        'sdt': phone,
        'solan': 0,
        'datetime': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pop<Map<String, dynamic>>(context, {
        'docId': customerRef.id,
        'id': customerRef.id,
        'name': name,
        'sdt': phone,
        'solan': 0,
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể lưu khách hàng: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm khách hàng'),
        backgroundColor: const Color(0xFF16856D),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 56,
                  color: Color(0xFF16856D),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Tên khách hàng',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên khách hàng.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
                    if (digits.isEmpty) {
                      return 'Vui lòng nhập số điện thoại.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _saveCustomer,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(_isSaving ? 'Đang lưu...' : 'Lưu khách hàng'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF16856D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
