import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'بيت العطار',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00897B),
          secondary: const Color(0xFFFF8F00),
          background: const Color(0xFFF5F5F5),
        ),
        fontFamily: 'Segoe UI',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00897B), width: 2),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. شاشة تسجيل الدخول
// ---------------------------------------------------------------------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _passwordController = TextEditingController();

  void _login() {
    if (_passwordController.text == '1234') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('كلمة المرور غير صحيحة'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF004D40), Color(0xFF00897B)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 10,
              margin: const EdgeInsets.all(24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.spa, size: 60, color: Color(0xFF00897B)),
                    const SizedBox(height: 16),
                    const Text(
                      "بيت العطار",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004D40),
                      ),
                    ),
                    const Text(
                      "بوابة الموظفين",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: 'رمز الدخول',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00897B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          "تسجيل الدخول",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. الشاشة الرئيسية (معدلة)
// ---------------------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "لوحة التحكم",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00897B),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- القسم الجديد: الإدارة الشاملة ---
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "الإدارة العامة",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              _DashboardCard(
                title: "إدارة كافة المنتجات",
                subtitle: "عرض، تعديل، وحذف (بهارات وعلاجات)",
                icon: Icons.settings_applications, // أيقونة تعبر عن الإدارة
                color: Colors.red.shade700, // لون مميز
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    // نرسل النوع 'all' ليجلب كل شيء
                    builder: (context) => const MixturesListScreen(type: 'all'),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- أدوات الحساب ---
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "أدوات الحساب",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _DashboardCard(
                      title: "حاسبة الغرامات",
                      icon: Icons.scale,
                      color: Colors.blue.shade600,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GramCalculatorPage(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DashboardCard(
                      title: "حاسبة الأسعار",
                      icon: Icons.calculate,
                      color: Colors.indigo.shade600,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuickOrderCalculator(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- التصنيفات المنفصلة (كما هي) ---
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "إضافة وعرض حسب القسم",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _DashboardCard(
                      title: "الخلطات العلاجية",
                      subtitle: "طب بديل",
                      icon: Icons.medical_services_outlined,
                      color: const Color(0xFF00897B),
                      isVertical: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const MixturesListScreen(type: 'medical'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DashboardCard(
                      title: "خلطات البهارات",
                      subtitle: "توابل ونكهات",
                      icon: Icons.soup_kitchen_outlined,
                      color: const Color(0xFFFF8F00),
                      isVertical: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const MixturesListScreen(type: 'spice'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isVertical;

  const _DashboardCard({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1), width: 1),
        ),
        child: isVertical
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 32, color: color),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 28, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. حاسبة الغرامات
// ---------------------------------------------------------------------------
class GramCalculatorPage extends StatefulWidget {
  const GramCalculatorPage({super.key});

  @override
  State<GramCalculatorPage> createState() => _GramCalculatorPageState();
}

class _GramCalculatorPageState extends State<GramCalculatorPage> {
  final _pricePerKgController = TextEditingController();
  final _targetPriceController = TextEditingController();
  String _result = "0";

  void _calculate() {
    double pricePerKg = double.tryParse(_pricePerKgController.text) ?? 0;
    double targetPrice = double.tryParse(_targetPriceController.text) ?? 0;
    if (pricePerKg > 0) {
      double grams = (targetPrice / pricePerKg) * 1000;
      setState(() {
        _result = grams.toStringAsFixed(0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("حاسبة الغرامات")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            TextField(
              controller: _pricePerKgController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "سعر الكيلو (دينار)",
                prefixIcon: Icon(Icons.price_change),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "السعر الذي يريده الزبون",
                prefixIcon: Icon(Icons.monetization_on),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text("احسب الكمية"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                children: [
                  const Text(
                    "الكمية المطلوبة",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$_result غرام",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. حاسبة الأسعار السريعة
// ---------------------------------------------------------------------------
class QuickOrderCalculator extends StatefulWidget {
  const QuickOrderCalculator({super.key});

  @override
  State<QuickOrderCalculator> createState() => _QuickOrderCalculatorState();
}

class _QuickOrderCalculatorState extends State<QuickOrderCalculator> {
  List<Map<String, dynamic>> items = [];
  final _nameController = TextEditingController();
  final _kgPriceController = TextEditingController();
  final _gramsController = TextEditingController();
  double _totalPrice = 0;

  void _addItem() {
    String name = _nameController.text;
    double priceKg = double.tryParse(_kgPriceController.text) ?? 0;
    double grams = double.tryParse(_gramsController.text) ?? 0;

    if (name.isNotEmpty && priceKg > 0 && grams > 0) {
      double itemCost = (grams / 1000) * priceKg;
      setState(() {
        items.add({
          'name': name,
          'priceKg': priceKg,
          'grams': grams,
          'cost': itemCost,
        });
        _totalPrice += itemCost;
        _nameController.clear();
        _kgPriceController.clear();
        _gramsController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("قائمة حساب سريع")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "المادة (مثلاً: كمون)",
                        prefixIcon: Icon(Icons.edit),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _kgPriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "سعر الكيلو",
                              prefixIcon: Icon(Icons.tag),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _gramsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "الوزن (غرام)",
                              prefixIcon: Icon(Icons.scale),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add_circle),
                        label: const Text("إضافة للقائمة"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade50,
                      child: Text(
                        "${index + 1}",
                        style: TextStyle(color: Colors.indigo.shade800),
                      ),
                    ),
                    title: Text(
                      items[index]['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${items[index]['grams']} غرام × ${items[index]['priceKg']} د.ع",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${items[index]['cost'].toStringAsFixed(0)} د.ع",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              _totalPrice -= items[index]['cost'];
                              items.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "المجموع الكلي:",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  "${_totalPrice.toStringAsFixed(0)} دينار",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// // ---------------------------------------------------------------------------
// 5. الخلطات (معدلة: تدعم عرض الكل + الحذف + التعديل + البحث 🔍)
// ---------------------------------------------------------------------------
class MixturesListScreen extends StatefulWidget {
  final String type; // يمكن أن تكون 'medical', 'spice', أو 'all'
  const MixturesListScreen({required this.type, super.key});

  @override
  State<MixturesListScreen> createState() => _MixturesListScreenState();
}

class _MixturesListScreenState extends State<MixturesListScreen> {
  // متغيرات البحث
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  // دالة الحذف
  void _deleteMixture(BuildContext context, String key) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل أنت متأكد من حذف هذه الخلطة نهائياً؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              FirebaseDatabase.instance.ref('mixtures').child(key).remove();
              Navigator.of(ctx).pop();
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAll = widget.type == 'all';
    final bool isMedical = widget.type == 'medical';

    // تحديد الألوان والعناوين بناءً على النوع
    Color themeColor;
    String title;

    if (isAll) {
      themeColor = Colors.red.shade700;
      title = "كافة المنتجات";
    } else if (isMedical) {
      themeColor = const Color(0xFF00897B);
      title = "الخلطات العلاجية";
    } else {
      themeColor = const Color(0xFFFF8F00);
      title = "خلطات البهارات";
    }

    // بناء الاستعلام (Query)
    Query dbQuery = FirebaseDatabase.instance.ref('mixtures');
    if (!isAll) {
      dbQuery = dbQuery.orderByChild('type').equalTo(widget.type);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        // المنطق الخاص بتبديل العنوان إلى حقل بحث
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "اكتب اسم الخلطة...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  prefixIcon: Icon(Icons.search, color: Colors.white70),
                ),
                onChanged: (val) {
                  setState(() {});
                },
              )
            : Text(title),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      floatingActionButton: (isAll)
          ? null
          : FloatingActionButton.extended(
              backgroundColor: themeColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "إضافة خلطة",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMixtureScreen(type: widget.type),
                ),
              ),
            ),
      body: StreamBuilder<DatabaseEvent>(
        stream: dbQuery.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Map<String, dynamic>> mixturesList = [];

          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final dataMap =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

            dataMap.forEach((key, value) {
              final mixture = Map<String, dynamic>.from(value);
              mixture['key'] = key;
              mixturesList.add(mixture);
            });

            mixturesList.sort((a, b) {
              int timeA = a['created_at'] ?? 0;
              int timeB = b['created_at'] ?? 0;
              return timeB.compareTo(timeA);
            });

            if (_searchController.text.isNotEmpty) {
              mixturesList = mixturesList.where((item) {
                final name = item['name'].toString().toLowerCase();
                final search = _searchController.text.toLowerCase();
                return name.contains(search);
              }).toList();
            }
          }

          if (mixturesList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isSearching
                        ? Icons.search_off
                        : Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isSearching ? "لا توجد نتائج مطابقة" : "لا توجد بيانات",
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: mixturesList.length,
            // تم التصحيح هنا: إزالة التكرار ووضع padding واحد يشمل الهوامش والمساحة السفلية
            padding: const EdgeInsets.only(
              bottom: 80, // مساحة للزر العائم
              top: 16,
              left: 16,
              right: 16,
            ),
            itemBuilder: (context, index) {
              var data = mixturesList[index];
              List<dynamic> ingredients = data['ingredients'] ?? [];
              double totalPrice = 0;
              for (var item in ingredients) {
                num g = item['grams'] ?? 0;
                num p = item['price_per_kg'] ?? 0;
                totalPrice += (g / 1000) * p;
              }

              bool itemIsMedical = data['type'] == 'medical';
              Color itemColor = itemIsMedical
                  ? const Color(0xFF00897B)
                  : const Color(0xFFFF8F00);

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MixtureDetailScreen(data: data),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [itemColor.withOpacity(0.8), itemColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(
                                itemIsMedical
                                    ? Icons.local_hospital
                                    : Icons.restaurant_menu,
                                color: Colors.white,
                                size: 30,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  data['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditMixtureScreen(
                                                mixtureKey: data['key'],
                                                currentData: data,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                    onPressed: () =>
                                        _deleteMixture(context, data['key']),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${ingredients.length} مكونات",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            Text(
                              "${totalPrice.toStringAsFixed(0)} دينار",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: itemColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// تفاصيل الخلطة (مع زر الحاسبة الجديد)
// ---------------------------------------------------------------------------
class MixtureDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const MixtureDetailScreen({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> ingredients = data['ingredients'] ?? [];
    double totalPrice = 0;
    for (var item in ingredients) {
      num g = item['grams'] ?? 0;
      num p = item['price_per_kg'] ?? 0;
      totalPrice += (g / 1000) * p;
    }

    final bool isMedical = data['type'] == 'medical';
    final Color themeColor = isMedical
        ? const Color(0xFF00897B)
        : const Color(0xFFFF8F00);

    return Scaffold(
      backgroundColor: themeColor,
      appBar: AppBar(
        title: const Text(
          "تفاصيل الخلطة",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // --- زر الحاسبة الذكية ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => MixtureCalculatorModal(
              ingredients: ingredients,
              themeColor: themeColor,
              mixtureName: data['name'],
            ),
          );
        },
        backgroundColor: Colors.white,
        foregroundColor: themeColor,
        icon: const Icon(Icons.calculate),
        label: const Text("حاسبة الكميات"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                // أضفنا مساحة في الأسفل عشان الزر العائم ما يغطي المحتوى
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 80.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: themeColor.withOpacity(0.1),
                              child: Icon(
                                isMedical ? Icons.healing : Icons.soup_kitchen,
                                size: 35,
                                color: themeColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              data['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "طريقة الاستخدام:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          data['instructions'] ?? "لا توجد تعليمات",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "المكونات والمقادير (الأساسية):",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...ingredients.map((item) {
                        num g = item['grams'] ?? 0;
                        num p = item['price_per_kg'] ?? 0;
                        double cost = (g / 1000) * p;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              item['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text("$g غرام  |  $p دينار/كغ"),
                            trailing: Text(
                              "${cost.toStringAsFixed(0)} د.ع",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "التكلفة الأساسية:",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    "${totalPrice.toStringAsFixed(0)} دينار",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widget جديد: النافذة المنبثقة لحاسبة الخلطة (Feature المطلوبة)
// ---------------------------------------------------------------------------
class MixtureCalculatorModal extends StatefulWidget {
  final List<dynamic> ingredients;
  final Color themeColor;
  final String mixtureName;

  const MixtureCalculatorModal({
    required this.ingredients,
    required this.themeColor,
    required this.mixtureName,
    super.key,
  });

  @override
  State<MixtureCalculatorModal> createState() => _MixtureCalculatorModalState();
}

class _MixtureCalculatorModalState extends State<MixtureCalculatorModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _amountController = TextEditingController();

  // Variables for calculation
  double _baseTotalWeight = 0;
  double _baseTotalPrice = 0;
  List<Map<String, dynamic>> _calculatedIngredients = [];
  double _calculatedTotalPrice = 0;
  double _calculatedTotalWeight = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _calculateBaseValues();

    // Listen to changes
    _amountController.addListener(_recalculate);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _amountController.clear();
      setState(() {
        _calculatedIngredients = [];
        _calculatedTotalPrice = 0;
        _calculatedTotalWeight = 0;
      });
    });
  }

  void _calculateBaseValues() {
    _baseTotalWeight = 0;
    _baseTotalPrice = 0;
    for (var item in widget.ingredients) {
      double g = double.tryParse(item['grams'].toString()) ?? 0;
      double p = double.tryParse(item['price_per_kg'].toString()) ?? 0;
      _baseTotalWeight += g;
      _baseTotalPrice += (g / 1000) * p;
    }
  }

  void _recalculate() {
    double inputVal = double.tryParse(_amountController.text) ?? 0;
    if (inputVal <= 0) {
      setState(() {
        _calculatedIngredients = [];
        _calculatedTotalPrice = 0;
        _calculatedTotalWeight = 0;
      });
      return;
    }

    List<Map<String, dynamic>> tempList = [];
    double newTotalPrice = 0;
    double newTotalWeight = 0;

    // Mode 0: Input Weight -> Get Price
    // Mode 1: Input Price -> Get Weight
    bool isWeightMode = _tabController.index == 0;

    // إذا كانت الخلطة فارغة لتجنب القسمة على صفر
    if (_baseTotalWeight == 0) return;

    double ratio = 0; // النسبة المستخدمة للضرب

    if (isWeightMode) {
      // المستخدم أدخل وزن، نريد حساب السعر
      // Ratio = الوزن المطلوب / الوزن الأساسي
      newTotalWeight = inputVal;
      ratio = newTotalWeight / _baseTotalWeight;
    } else {
      // المستخدم أدخل سعر، نريد حساب الوزن
      // Price per gram of mixture = _baseTotalPrice / _baseTotalWeight
      // Target Weight = Target Price / PricePerGram
      double pricePerGram = _baseTotalPrice / _baseTotalWeight;
      if (pricePerGram > 0) {
        newTotalWeight = inputVal / pricePerGram;
        ratio = newTotalWeight / _baseTotalWeight;
      }
    }

    // بناء القائمة الجديدة
    for (var item in widget.ingredients) {
      double originalGrams = double.tryParse(item['grams'].toString()) ?? 0;
      double pricePerKg = double.tryParse(item['price_per_kg'].toString()) ?? 0;

      double newGrams = originalGrams * ratio;
      double newCost = (newGrams / 1000) * pricePerKg;

      tempList.add({'name': item['name'], 'grams': newGrams, 'cost': newCost});

      newTotalPrice += newCost;
    }

    setState(() {
      _calculatedIngredients = tempList;
      _calculatedTotalPrice = newTotalPrice;
      _calculatedTotalWeight = newTotalWeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 12),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Title
          Text(
            "حاسبة: ${widget.mixtureName}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.themeColor,
            ),
          ),
          const SizedBox(height: 10),
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: widget.themeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: "أريد وزناً محدداً"),
                  Tab(text: "أريد سعراً محدداً"),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _tabController.index == 0
                    ? "الوزن المطلوب (غرام)"
                    : "السعر المطلوب (دينار)",
                hintText: _tabController.index == 0
                    ? "مثلاً: 250" // ربع كيلو
                    : "مثلاً: 5000",
                suffixIcon: Icon(
                  _tabController.index == 0
                      ? Icons.scale
                      : Icons.monetization_on,
                  color: widget.themeColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Summary Header
          if (_calculatedIngredients.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: widget.themeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.themeColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "الوزن الصافي",
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        "${_calculatedTotalWeight.toStringAsFixed(0)} غرام",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: widget.themeColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 30,
                    width: 1,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "السعر النهائي",
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        "${_calculatedTotalPrice.toStringAsFixed(0)} د.ع",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: widget.themeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // List
          Expanded(
            child: _calculatedIngredients.isEmpty
                ? Center(
                    child: Text(
                      "أدخل قيمة لعرض المقادير",
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _calculatedIngredients.length,
                    itemBuilder: (context, index) {
                      final item = _calculatedIngredients[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade100),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(
                            item['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${(item['grams'] as double).toStringAsFixed(1)} غرام",
                            style: TextStyle(color: widget.themeColor),
                          ),
                          trailing: Text(
                            "${(item['cost'] as double).toStringAsFixed(0)} د.ع",
                            style: const TextStyle(fontWeight: FontWeight.bold),
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

// ---------------------------------------------------------------------------
// شاشة إضافة خلطة
// ---------------------------------------------------------------------------
class AddMixtureScreen extends StatefulWidget {
  final String type;
  const AddMixtureScreen({required this.type, super.key});

  @override
  State<AddMixtureScreen> createState() => _AddMixtureScreenState();
}

class _AddMixtureScreenState extends State<AddMixtureScreen> {
  final _nameController = TextEditingController();
  final _instructionsController = TextEditingController();
  List<Map<String, dynamic>> _tempIngredients = [];
  final _ingNameController = TextEditingController();
  final _ingGramsController = TextEditingController();
  final _ingPriceController = TextEditingController();

  void _addIngredient() {
    if (_ingNameController.text.isNotEmpty &&
        _ingGramsController.text.isNotEmpty) {
      setState(() {
        _tempIngredients.add({
          'name': _ingNameController.text,
          'grams': double.tryParse(_ingGramsController.text) ?? 0,
          'price_per_kg': double.tryParse(_ingPriceController.text) ?? 0,
        });
        _ingNameController.clear();
        _ingGramsController.clear();
        _ingPriceController.clear();
      });
    }
  }

  Future<void> _saveToFirebase() async {
    if (_nameController.text.isNotEmpty && _tempIngredients.isNotEmpty) {
      try {
        DatabaseReference newRef = FirebaseDatabase.instance
            .ref('mixtures')
            .push();

        await newRef.set({
          'name': _nameController.text,
          'type': widget.type,
          'instructions': _instructionsController.text,
          'ingredients': _tempIngredients,
          'created_at': ServerValue.timestamp,
        });

        if (mounted) Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("حدث خطأ أثناء الحفظ: $e")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى ملء الاسم وإضافة مكونات")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMedical = widget.type == 'medical';
    Color color = isMedical ? const Color(0xFF00897B) : const Color(0xFFFF8F00);

    return Scaffold(
      appBar: AppBar(
        title: Text("إضافة ${isMedical ? 'خلطة علاجية' : 'بهارات'}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "بيانات الخلطة الأساسية",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "اسم الخلطة"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _instructionsController,
              decoration: const InputDecoration(labelText: "طريقة الاستخدام"),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            const Text(
              "المكونات",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _ingNameController,
                    decoration: const InputDecoration(
                      labelText: "اسم المكون",
                      prefixIcon: Icon(Icons.grass),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ingGramsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "الوزن (غ)",
                            prefixIcon: Icon(Icons.scale),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _ingPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "سعر/كغ",
                            prefixIcon: Icon(Icons.price_check),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _addIngredient,
                      icon: const Icon(Icons.add),
                      label: const Text("أضف المكون للقائمة"),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ..._tempIngredients
                .map(
                  (item) => Card(
                    child: ListTile(
                      title: Text(item['name']),
                      subtitle: Text(
                        "${item['grams']}غ - ${item['price_per_kg']}د.ع/كغ",
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() => _tempIngredients.remove(item));
                        },
                      ),
                    ),
                  ),
                )
                .toList(),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveToFirebase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "حفظ الخلطة في قاعدة البيانات",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// شاشة تعديل خلطة موجودة (جديدة)
// ---------------------------------------------------------------------------
class EditMixtureScreen extends StatefulWidget {
  final String mixtureKey;
  final Map<String, dynamic> currentData;

  const EditMixtureScreen({
    required this.mixtureKey,
    required this.currentData,
    super.key,
  });

  @override
  State<EditMixtureScreen> createState() => _EditMixtureScreenState();
}

class _EditMixtureScreenState extends State<EditMixtureScreen> {
  final _nameController = TextEditingController();
  final _instructionsController = TextEditingController();
  List<Map<String, dynamic>> _tempIngredients = [];

  // controllers for new ingredient
  final _ingNameController = TextEditingController();
  final _ingGramsController = TextEditingController();
  final _ingPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // تعبئة البيانات الحالية
    _nameController.text = widget.currentData['name'] ?? '';
    _instructionsController.text = widget.currentData['instructions'] ?? '';

    if (widget.currentData['ingredients'] != null) {
      // نسخ المكونات لقائمة جديدة قابلة للتعديل
      List<dynamic> existing = widget.currentData['ingredients'];
      for (var item in existing) {
        _tempIngredients.add(Map<String, dynamic>.from(item));
      }
    }
  }

  void _addIngredient() {
    if (_ingNameController.text.isNotEmpty &&
        _ingGramsController.text.isNotEmpty) {
      setState(() {
        _tempIngredients.add({
          'name': _ingNameController.text,
          'grams': double.tryParse(_ingGramsController.text) ?? 0,
          'price_per_kg': double.tryParse(_ingPriceController.text) ?? 0,
        });
        _ingNameController.clear();
        _ingGramsController.clear();
        _ingPriceController.clear();
      });
    }
  }

  Future<void> _updateMixture() async {
    if (_nameController.text.isNotEmpty && _tempIngredients.isNotEmpty) {
      try {
        await FirebaseDatabase.instance
            .ref('mixtures')
            .child(widget.mixtureKey)
            .update({
              'name': _nameController.text,
              'instructions': _instructionsController.text,
              'ingredients': _tempIngredients,
              // لا نحدث النوع type ولا تاريخ الإنشاء created_at إلا إذا أردت ذلك
            });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تم تحديث البيانات بنجاح")),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("حدث خطأ أثناء التحديث: $e")));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("يرجى التأكد من البيانات")));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMedical = widget.currentData['type'] == 'medical';
    Color color = isMedical ? const Color(0xFF00897B) : const Color(0xFFFF8F00);

    return Scaffold(
      appBar: AppBar(
        title: const Text("تعديل الخلطة"),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "البيانات الأساسية",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "اسم الخلطة"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _instructionsController,
              decoration: const InputDecoration(labelText: "طريقة الاستخدام"),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            const Text(
              "المكونات (يمكنك الحذف والإضافة)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            // --- قسم إضافة مكون جديد ---
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _ingNameController,
                    decoration: const InputDecoration(
                      labelText: "اسم المكون الجديد",
                      prefixIcon: Icon(Icons.grass),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ingGramsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "الوزن (غ)",
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _ingPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "سعر الكيلو",
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addIngredient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text(
                      "أضف للقائمة",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            // --- قائمة المكونات الحالية ---
            ..._tempIngredients.map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(item['name']),
                  subtitle: Text(
                    "${item['grams']}غ - ${item['price_per_kg']}د.ع/كغ",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      setState(() => _tempIngredients.remove(item));
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _updateMixture,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "حفظ التعديلات",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
