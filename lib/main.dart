import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // تأكد من أنك وضعت ملف google-services.json في مجلد android/app
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تطبيق المحل - أونلاين',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        fontFamily: 'Arial',
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('كلمة المرور غير صحيحة')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_sync, size: 80, color: Colors.teal),
              const SizedBox(height: 20),
              const Text(
                "دخول الموظفين (متصل)",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text("دخول"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. الشاشة الرئيسية
// ---------------------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة التحكم السحابية"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildMenuCard(
              context,
              "حساب الغرامات",
              Icons.scale,
              const GramCalculatorPage(),
            ),
            _buildMenuCard(
              context,
              "حساب سعر قائمة",
              Icons.calculate,
              const QuickOrderCalculator(),
            ),
            _buildMenuCard(
              context,
              "الخلطات العلاجية",
              Icons.medical_services,
              const MixturesListScreen(type: 'medical'),
            ),
            _buildMenuCard(
              context,
              "خلطات البهارات",
              Icons.soup_kitchen,
              const MixturesListScreen(type: 'spice'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget page,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.teal),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. ميزة 1: حساب الغرامات
// ---------------------------------------------------------------------------
class GramCalculatorPage extends StatefulWidget {
  const GramCalculatorPage({super.key});

  @override
  State<GramCalculatorPage> createState() => _GramCalculatorPageState();
}

class _GramCalculatorPageState extends State<GramCalculatorPage> {
  final _pricePerKgController = TextEditingController();
  final _targetPriceController = TextEditingController();
  String _result = "";

  void _calculate() {
    double pricePerKg = double.tryParse(_pricePerKgController.text) ?? 0;
    double targetPrice = double.tryParse(_targetPriceController.text) ?? 0;
    if (pricePerKg > 0) {
      double grams = (targetPrice / pricePerKg) * 1000;
      setState(() {
        _result = "الكمية المطلوبة:\n ${grams.toStringAsFixed(1)} غرام";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("حاسبة الغرامات")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _pricePerKgController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "سعر الكيلو (دينار)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _targetPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "السعر الذي يريده الزبون",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculate,
              child: const Text("احسب الغرامات"),
            ),
            const SizedBox(height: 30),
            Text(
              _result,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. ميزة 2: حساب سعر قائمة
// ---------------------------------------------------------------------------
class QuickOrderCalculator extends StatefulWidget {
  const QuickOrderCalculator({super.key});

  @override
  State<QuickOrderCalculator> createState() => _QuickOrderCalculatorState();
}

class _QuickOrderCalculatorState extends State<QuickOrderCalculator> {
  List<Map<String, dynamic>> items = [];
  final _kgPriceController = TextEditingController();
  final _gramsController = TextEditingController();
  double _totalPrice = 0;

  void _addItem() {
    double priceKg = double.tryParse(_kgPriceController.text) ?? 0;
    double grams = double.tryParse(_gramsController.text) ?? 0;

    if (priceKg > 0 && grams > 0) {
      double itemCost = (grams / 1000) * priceKg;
      setState(() {
        items.add({'priceKg': priceKg, 'grams': grams, 'cost': itemCost});
        _totalPrice += itemCost;
        _kgPriceController.clear();
        _gramsController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("حساب سعر خلطة يدوية")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _kgPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "سعر الكيلو"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _gramsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "الوزن (غرام)",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: const Text("أضف للقائمة"),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("مادة ${index + 1}"),
                    subtitle: Text(
                      "${items[index]['grams']} غرام @ ${items[index]['priceKg']} للكيلو",
                    ),
                    trailing: Text(
                      "${items[index]['cost'].toStringAsFixed(0)} د.ع",
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.teal[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "المجموع الكلي:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${_totalPrice.toStringAsFixed(0)} دينار",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
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
// 5. ميزة 3 & 4: (FIREBASE) الخلطات السحابية
// ---------------------------------------------------------------------------

class MixturesListScreen extends StatelessWidget {
  final String type; // 'medical' or 'spice'
  const MixturesListScreen({required this.type, super.key});

  @override
  Widget build(BuildContext context) {
    String title = type == 'medical' ? "الخلطات العلاجية" : "خلطات البهارات";

    // الاتصال بـ Firestore
    final Stream<QuerySnapshot> mixturesStream = FirebaseFirestore.instance
        .collection('mixtures')
        .where('type', isEqualTo: type)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMixtureScreen(type: type),
            ),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: mixturesStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ في الاتصال'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("لا توجد بيانات، أضف جديد"));
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    data['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("اضغط لعرض التفاصيل"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MixtureDetailScreen(data: data),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

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
        await FirebaseFirestore.instance.collection('mixtures').add({
          'name': _nameController.text,
          'type': widget.type,
          'instructions': _instructionsController.text,
          'ingredients': _tempIngredients,
          'created_at': FieldValue.serverTimestamp(),
        });
        if (mounted) Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("خطأ: $e")));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("يرجى ملء البيانات")));
    }
  }

  @override
  Widget build(BuildContext context) {
    String labelName = widget.type == 'medical'
        ? "اسم المرض/الخلطة"
        : "نوع البهار";
    return Scaffold(
      appBar: AppBar(title: Text("إضافة $labelName")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: labelName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: "طريقة الاستخدام",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const Divider(height: 30, thickness: 2),
            const Text(
              "المكونات",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _ingNameController,
                    decoration: const InputDecoration(labelText: "المكون"),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    controller: _ingGramsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "غرام"),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    controller: _ingPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "سعر/كغ"),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _addIngredient,
              child: const Text("أضف المكون"),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tempIngredients.length,
              itemBuilder: (context, index) {
                var item = _tempIngredients[index];
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text(
                    "${item['grams']} غرام - ${item['price_per_kg']} دينار/كغ",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        setState(() => _tempIngredients.removeAt(index)),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveToFirebase,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text("حفظ في قاعدة البيانات السحابية"),
            ),
          ],
        ),
      ),
    );
  }
}

class MixtureDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const MixtureDetailScreen({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> ingredients = data['ingredients'] ?? [];
    double totalPrice = 0;

    for (var item in ingredients) {
      double cost = (item['grams'] / 1000) * item['price_per_kg'];
      totalPrice += cost;
    }

    return Scaffold(
      appBar: AppBar(title: Text(data['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "طريقة الاستخدام:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              data['instructions'] ?? "لا توجد تعليمات",
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(),
            const Text(
              "المكونات:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  var item = ingredients[index];
                  double cost = (item['grams'] / 1000) * item['price_per_kg'];
                  return Card(
                    color: Colors.grey[100],
                    child: ListTile(
                      title: Text(
                        item['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "${item['grams']} غرام  |  ${item['price_per_kg']} دينار/كغ",
                      ),
                      trailing: Text("${cost.toStringAsFixed(0)} دينار"),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "سعر الخلطة الكلي:",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    "${totalPrice.toStringAsFixed(0)} دينار",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
