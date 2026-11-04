import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();

  List<QueryDocumentSnapshot<Map<String, dynamic>>> customers = [];
  bool loading = false;
  String? searchError;
  int _requestNumber = 0;

  String _normalizeVietnamese(String text) {
    var result = text.trim().toLowerCase();

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

  Future<void> searchCustomer(String keyword) async {
    final term = _normalizeVietnamese(keyword);
    final phoneTerm = keyword.replaceAll(RegExp(r'\D'), '');
    final currentRequest = ++_requestNumber;

    if (term.isEmpty) {
      setState(() {
        customers = [];
        loading = false;
        searchError = null;
      });
      return;
    }

    setState(() {
      loading = true;
      searchError = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance.collection('vic').get();

      final results = snapshot.docs.where((doc) {
        final data = doc.data();

        final name = _normalizeVietnamese(data['name']?.toString() ?? '');

        // Hỗ trợ sdt lưu dưới dạng số hoặc chuỗi.
        final phone = (data['sdt']?.toString() ?? '').replaceAll(
          RegExp(r'\D'),
          '',
        );

        final matchesName = name.contains(term);
        final matchesPhone = phoneTerm.isNotEmpty && phone.contains(phoneTerm);

        return matchesName || matchesPhone;
      }).toList();

      if (!mounted || currentRequest != _requestNumber) return;

      setState(() {
        customers = results;
        loading = false;
      });
    } catch (error) {
      if (!mounted || currentRequest != _requestNumber) return;

      setState(() {
        customers = [];
        loading = false;
        searchError = 'Không tải được dữ liệu: $error';
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: searchController,
              onChanged: searchCustomer,
              decoration: InputDecoration(
                hintText: 'Nhập tên hoặc số điện thoại...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : searchError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(searchError!),
                    ),
                  )
                : searchController.text.trim().isEmpty
                ? const Center(
                    child: Text('Nhập tên hoặc số điện thoại để tìm'),
                  )
                : customers.isEmpty
                ? const Center(
                    child: Text(
                      'Không tìm thấy kết quả',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final doc = customers[index];
                      final data = doc.data();

                      final name = (data['name']?.toString() ?? '').trim();
                      final phone = (data['sdt']?.toString() ?? '').trim();

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(name.isEmpty ? '—' : name),
                          subtitle: Text(phone.isEmpty ? '—' : 'SĐT: $phone'),
                          onTap: () {
                            Navigator.pop<Map<String, dynamic>>(context, {
                              'docId': doc.id,
                              'id': data['id']?.toString() ?? doc.id,
                              'name': name,
                              'sdt': phone,
                              'solan': data['solan'] ?? 0,
                            });
                          },
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
