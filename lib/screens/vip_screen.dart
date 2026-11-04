import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VipScreen extends StatefulWidget {
  const VipScreen({super.key});

  @override
  State<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends State<VipScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _listController = ScrollController();
  String _searchText = '';
  int _selectedYear = DateTime.now().year;
  int? _selectedMonth;

  int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _displayValue(dynamic value) {
    if (value == null) return '—';

    final text = value.toString().trim();
    return text.isEmpty ? '—' : text;
  }

  String _normalizeVietnamese(String value) {
    var result = value.trim().toLowerCase();

    const replacements = {
      'à': 'a',
      'á': 'a',
      'ạ': 'a',
      'ả': 'a',
      'ã': 'a',
      'â': 'a',
      'ầ': 'a',
      'ấ': 'a',
      'ậ': 'a',
      'ẩ': 'a',
      'ẫ': 'a',
      'ă': 'a',
      'ằ': 'a',
      'ắ': 'a',
      'ặ': 'a',
      'ẳ': 'a',
      'ẵ': 'a',
      'è': 'e',
      'é': 'e',
      'ẹ': 'e',
      'ẻ': 'e',
      'ẽ': 'e',
      'ê': 'e',
      'ề': 'e',
      'ế': 'e',
      'ệ': 'e',
      'ể': 'e',
      'ễ': 'e',
      'ì': 'i',
      'í': 'i',
      'ị': 'i',
      'ỉ': 'i',
      'ĩ': 'i',
      'ò': 'o',
      'ó': 'o',
      'ọ': 'o',
      'ỏ': 'o',
      'õ': 'o',
      'ô': 'o',
      'ồ': 'o',
      'ố': 'o',
      'ộ': 'o',
      'ổ': 'o',
      'ỗ': 'o',
      'ơ': 'o',
      'ờ': 'o',
      'ớ': 'o',
      'ợ': 'o',
      'ở': 'o',
      'ỡ': 'o',
      'ù': 'u',
      'ú': 'u',
      'ụ': 'u',
      'ủ': 'u',
      'ũ': 'u',
      'ư': 'u',
      'ừ': 'u',
      'ứ': 'u',
      'ự': 'u',
      'ử': 'u',
      'ữ': 'u',
      'ỳ': 'y',
      'ý': 'y',
      'ỵ': 'y',
      'ỷ': 'y',
      'ỹ': 'y',
      'đ': 'd',
    };

    for (final entry in replacements.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }

    return result;
  }

  String? _formatDate(dynamic value) {
    if (value == null) return null;

    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate().toLocal();
    } else if (value is DateTime) {
      date = value.toLocal();
    } else {
      date = DateTime.tryParse(value.toString())?.toLocal();
      if (date == null) return value.toString();
    }

    String twoDigits(int number) => number.toString().padLeft(2, '0');

    return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year} '
        '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }

  DateTime? _recordDate(Map<String, dynamic> data) {
    final value = data['vipAddedAt'] ?? data['datetime'] ?? data['createdAt'];

    if (value is Timestamp) return value.toDate().toLocal();
    if (value is DateTime) return value.toLocal();
    if (value == null) return null;

    return DateTime.tryParse(value.toString())?.toLocal();
  }

  void _selectMonth(int month) {
    setState(() => _selectedMonth = month);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_listController.hasClients) return;

      _listController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildMonthGrid(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> yearRecords,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (context, index) {
        final month = index + 1;

        final monthCount = yearRecords.where((record) {
          final date = _recordDate(record.data());
          return date != null && date.month == month;
        }).length;

        final isSelected = _selectedMonth == month;

        return Card(
          margin: EdgeInsets.zero,
          color: isSelected ? const Color(0xFF16856D) : Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _selectMonth(month),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tháng $month',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$monthCount khách',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.blueGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVipRecordCard(
    QueryDocumentSnapshot<Map<String, dynamic>> record,
  ) {
    final data = record.data();
    final name = _displayValue(data['name']);
    final customerId = _displayValue(
      data['id'] ?? data['sourceDocId'] ?? record.id,
    );
    final phone = _displayValue(data['sdt'] ?? data['phone']);
    final points = _toInt(data['solan'] ?? data['points']);
    final vipDate = _formatDate(
      data['vipAddedAt'] ?? data['datetime'] ?? data['createdAt'],
    );

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFF0C4),
          child: Icon(
            Icons.workspace_premium_rounded,
            color: Color(0xFFB78322),
          ),
        ),
        title: Text(
          name == '—' ? 'Khách hàng VIP' : name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: IconButton(
          tooltip: 'Xóa lượt VIP này',
          icon: const Icon(Icons.delete_outline, color: Color(0xFFB3261E)),
          onPressed: () => _confirmDeleteVipRecord(
            context,
            record,
            name == '—' ? 'Khách hàng VIP' : name,
            customerId,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _VipInfoRow(
                icon: Icons.badge_outlined,
                text: 'Mã khách: $customerId',
              ),
              const SizedBox(height: 4),
              _VipInfoRow(icon: Icons.phone_outlined, text: 'SĐT: $phone'),
              const SizedBox(height: 4),
              _VipInfoRow(
                icon: Icons.stars_outlined,
                text: 'Số lần trong lượt này: $points',
              ),
              if (vipDate != null) ...[
                const SizedBox(height: 4),
                _VipInfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: 'Lượt VIP ngày: $vipDate',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteVipRecord(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> record,
    String name,
    String customerId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa lượt VIP này?'),
        content: Text(
          'Chỉ xóa lượt VIP của $name (mã $customerId). '
          'Các lượt khác và hồ sơ khách trong vic sẽ không bị xóa.',
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
            child: const Text('Xóa lượt này'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    try {
      await record.reference.delete();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa lượt VIP.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể xóa lượt VIP: $error')));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách VIP'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchText = value);
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên hoặc số điện thoại',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchText.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Xóa tìm kiếm',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchText = '');
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('vip').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Không tải được danh sách VIP.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allRecords = snapshot.data?.docs ?? [];
                final nameQuery = _normalizeVietnamese(_searchText);
                final phoneQuery = _searchText.replaceAll(RegExp(r'\D'), '');

                final yearRecords = allRecords.where((record) {
                  final date = _recordDate(record.data());
                  return date != null && date.year == _selectedYear;
                }).toList();

                final monthRecords = yearRecords.where((record) {
                  if (_selectedMonth == null) return true;
                  final date = _recordDate(record.data());
                  return date != null && date.month == _selectedMonth;
                }).toList();

                final records = monthRecords.where((record) {
                  final data = record.data();
                  final name = _normalizeVietnamese(
                    data['name']?.toString() ?? '',
                  );
                  final phone = (data['sdt'] ?? data['phone'] ?? '')
                      .toString()
                      .replaceAll(RegExp(r'\D'), '');

                  final matchesName =
                      nameQuery.isNotEmpty && name.contains(nameQuery);
                  final matchesPhone =
                      phoneQuery.isNotEmpty && phone.contains(phoneQuery);

                  return (nameQuery.isEmpty && phoneQuery.isEmpty) ||
                      matchesName ||
                      matchesPhone;
                }).toList();

                return ListView(
                  controller: _listController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedMonth == null
                                ? 'Danh sách VIP năm $_selectedYear'
                                : 'Khách VIP tháng $_selectedMonth/$_selectedYear',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_selectedMonth != null)
                          TextButton(
                            onPressed: () {
                              setState(() => _selectedMonth = null);
                            },
                            child: const Text('Xem cả năm'),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _selectedMonth == null
                            ? 'Tổng: ${yearRecords.length} lượt VIP'
                            : 'Tổng tháng $_selectedMonth: '
                                  '${monthRecords.length} lượt VIP',
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                    if (records.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: Text(
                            allRecords.isEmpty
                                ? 'Chưa có lượt VIP nào.'
                                : 'Không có khách VIP phù hợp trong thời gian này.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    else
                      ...records.map(
                        (record) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildVipRecordCard(record),
                        ),
                      ),

                    const SizedBox(height: 12),
                    Card(
                      color: const Color(0xFFEAF5F1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.groups_rounded,
                              color: Color(0xFF16856D),
                              size: 34,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tổng khách trong 12 tháng của $_selectedYear',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${yearRecords.length} lượt VIP',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFF16856D),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          tooltip: 'Năm trước',
                          onPressed: () {
                            setState(() {
                              _selectedYear--;
                              _selectedMonth = null;
                            });
                            _listController.jumpTo(0);
                          },
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                        Text(
                          'Năm $_selectedYear',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Năm sau',
                          onPressed: () {
                            setState(() {
                              _selectedYear++;
                              _selectedMonth = null;
                            });
                            _listController.jumpTo(0);
                          },
                          icon: const Icon(Icons.chevron_right_rounded),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Tổng khách từng tháng — chạm vào tháng để xem',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildMonthGrid(yearRecords),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VipInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _VipInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blueGrey),
        const SizedBox(width: 6),
        Expanded(child: Text(text)),
      ],
    );
  }
}
