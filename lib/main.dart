import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
          seedColor: const Color(0xFF00897B), // لون التيل الأساسي
          secondary: const Color(0xFFFF8F00), // لون برتقالي للبهارات
          background: const Color(0xFFF5F5F5),
        ),
        fontFamily: 'Segoe UI', // خط نظيف (أو الافتراضي)
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
// 1. شاشة تسجيل الدخول (تصميم جديد)
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
// 2. الشاشة الرئيسية (لوحة تحكم)
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                "إدارة الخلطات",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _DashboardCard(
                      title: "الخلطات العلاجية",
                      subtitle: "الأعشاب والطب البديل",
                      icon: Icons.medical_services_outlined,
                      color: const Color(0xFF00897B), // لون الأعشاب
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
                      color: const Color(0xFFFF8F00), // لون البهارات
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
            ),
            const SizedBox(height: 20),
          ],
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
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
// 3. ميزة 1: حساب الغرامات (محسن)
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
        child: Column(
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
                color: const Color.fromARGB(255, 46, 153, 230),
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
// 4. ميزة 2: حساب سعر قائمة (محسن)
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

// ---------------------------------------------------------------------------
// 5. الخلطات (Firebase) - تصميم جديد للبطاقات
// ---------------------------------------------------------------------------

class MixturesListScreen extends StatelessWidget {
  final String type; // 'medical' or 'spice'
  const MixturesListScreen({required this.type, super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMedical = type == 'medical';
    final Color themeColor = isMedical
        ? const Color(0xFF00897B)
        : const Color(0xFFFF8F00);
    final String title = isMedical ? "الخلطات العلاجية" : "خلطات البهارات";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: Text(title)),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: themeColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("إضافة خلطة", style: TextStyle(color: Colors.white)),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddMixtureScreen(type: type)),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('mixtures')
            .where('type', isEqualTo: type)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isMedical
                        ? Icons.medical_services_outlined
                        : Icons.soup_kitchen_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "لا توجد خلطات مضافة بعد",
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              // حساب السعر الإجمالي للخلطة للعرض في القائمة
              List<dynamic> ingredients = data['ingredients'] ?? [];
              double totalPrice = 0;
              for (var item in ingredients) {
                totalPrice += (item['grams'] / 1000) * item['price_per_kg'];
              }

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
                            colors: [themeColor.withOpacity(0.8), themeColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Icon(
                                isMedical
                                    ? Icons.local_hospital
                                    : Icons.restaurant_menu,
                                color: Colors.white,
                                size: 30,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  data['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "${ingredients.length} مكونات",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "التكلفة التقريبية:",
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              "${totalPrice.toStringAsFixed(0)} دينار",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: themeColor,
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
// تفاصيل الخلطة (بتصميم الفاتورة)
// ---------------------------------------------------------------------------
class MixtureDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const MixtureDetailScreen({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> ingredients = data['ingredients'] ?? [];
    double totalPrice = 0;
    for (var item in ingredients) {
      totalPrice += (item['grams'] / 1000) * item['price_per_kg'];
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
                      "المكونات والمقادير:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...ingredients.map((item) {
                      double cost =
                          (item['grams'] / 1000) * item['price_per_kg'];
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
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            "${item['grams']} غرام  |  ${item['price_per_kg']} دينار/كغ",
                          ),
                          trailing: Text(
                            "${cost.toStringAsFixed(0)} د.ع",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
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
                    "التكلفة النهائية:",
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
// شاشة إضافة خلطة (نفس المنطق لكن تصميم أنظف)
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
      await FirebaseFirestore.instance.collection('mixtures').add({
        'name': _nameController.text,
        'type': widget.type,
        'instructions': _instructionsController.text,
        'ingredients': _tempIngredients,
        'created_at': FieldValue.serverTimestamp(),
      });
      if (mounted) Navigator.pop(context);
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
