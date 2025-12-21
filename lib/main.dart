// ==================== 1. منطقة الاستدعاءات (Imports Area) ====================
// هذه المنطقة يجب أن تكون في أول الملف فقط. ممنوع وضع import في الأسفل.
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'dart:convert'; // ✅ يحل مشكلة jsonEncode
import 'package:http/http.dart' as http; // ✅ يحل مشكلة http
import 'package:flutter/services.dart';

// ===========================================================================

String currentUser = "";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 👇👇 أضف هذا السطر هنا بالضبط لإخفاء شريط الحالة والأزرار السفلية 👇👇
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  final savedUser = prefs.getString('saved_user');
  Widget startScreen = const LoginPage();

  if (savedUser != null && savedUser.isNotEmpty) {
    currentUser = savedUser;
    if (savedUser == "مؤمل") {
      startScreen = const AdminDashboard();
    } else {
      startScreen = const HomeScreen();
    }
  }

  runApp(MyApp(startScreen: startScreen));
}

class MyApp extends StatelessWidget {
  final Widget startScreen;
  const MyApp({required this.startScreen, super.key});

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
      home: startScreen,
    );
  }
}

// ---------------------------------------------------------------------------
// شاشة تسجيل الدخول
// ---------------------------------------------------------------------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showMessage("يرجى ملء كافة الحقول", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    if (username == "مؤمل" && password == "2002") {
      await _saveUserSession("مؤمل");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
      }
      return;
    }

    try {
      final ref = FirebaseDatabase.instance.ref('accounts/$username');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        if (userData['password'].toString() == password) {
          await _saveUserSession(username);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        } else {
          _showMessage("كلمة المرور غير صحيحة", isError: true);
          setState(() => _isLoading = false);
        }
      } else {
        _showMessage("اسم المستخدم غير موجود", isError: true);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showMessage("حدث خطأ في الاتصال: $e", isError: true);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserSession(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_user', username);
    currentUser = username;
  }

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _launchWhatsApp() async {
    const phoneNumber = "9647726860085";
    final appUrl = Uri.parse("whatsapp://send?phone=$phoneNumber");
    final webUrl = Uri.parse("https://wa.me/$phoneNumber");

    try {
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl);
      } else {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      _showMessage("تعذر فتح الواتساب", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF004D40), Color(0xFF00897B)],
          ),
        ),
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Expanded(
                  child: Center(
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
                            const Icon(
                              Icons.spa,
                              size: 60,
                              color: Color(0xFF00897B),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "بيت العطار",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF004D40),
                              ),
                            ),
                            const SizedBox(height: 32),
                            TextField(
                              controller: _usernameController,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                hintText: 'اسم المستخدم',
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                hintText: 'كلمة المرور',
                                prefixIcon: Icon(Icons.lock),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00897B),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "جميع الحقوق محفوظة لعطارة بيت العطار\nلطلب حساب المراسلة واتساب",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _launchWhatsApp,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chat,
                            color: Colors.green,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
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

// ---------------------------------------------------------------------------
// شاشة عرض الإشعارات (جديدة - للمستخدمين)
// ---------------------------------------------------------------------------
class UserNotificationsScreen extends StatelessWidget {
  const UserNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تنبيهات الإدارة"),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        // جلب آخر 20 إشعار
        stream: FirebaseDatabase.instance
            .ref('notifications')
            .limitToLast(20)
            .onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("لا توجد إشعارات جديدة"),
                ],
              ),
            );
          }

          final rawData = snapshot.data!.snapshot.value as Map;
          List<Map<String, dynamic>> messages = [];

          rawData.forEach((key, value) {
            messages.add(Map<String, dynamic>.from(value));
          });

          // ترتيب من الأحدث للأقدم
          messages.sort(
            (a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0),
          );

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    child: Icon(Icons.priority_high, color: Colors.white),
                  ),
                  title: Text(
                    msg['body'] ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    "بواسطة: ${msg['sender'] ?? 'الإدارة'}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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

// أضف هذا الاستدعاء في أعلى الملف مع باقي الـ imports

// ... باقي الكود ...

// تأكد من إضافة هذا السطر في أعلى ملف main.dart مع باقي الـ imports:

// ---------------------------------------------------------------------------
// شاشة إرسال الإشعارات (محدثة لتعمل مع FCM API V1 باستخدام حساب الخدمة)
// ---------------------------------------------------------------------------
class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _messageController = TextEditingController();
  bool _isSending = false;

  // ✅ بيانات الحساب الخدمي (Service Account) المحدثة
  final String _projectId = "attaraapp";
  final String _clientEmail =
      "firebase-adminsdk-fbsvc@attaraapp.iam.gserviceaccount.com";
  // تم استخدام ''' للنصوص متعددة الأسطر لضمان التنسيق الصحيح للمفتاح
  final String _privateKey = '''
-----BEGIN PRIVATE KEY-----
MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQCf/ni8IeiBc0AY
EKITOt7q36z6NVQ+VefqP8DHi8md2i4vFu1UekIkVxEcn3I73PkukdaNvDOhfhcN
DyuptCsQcYLZgoQXQfnN5/kFJkizkUgknccBLYFx7+WzzVYi57UYwCqgr76muE2V
dx9LUxYz5+qGfp/GVcfXA60Y4WFhbQGiXei8iKjE9MVZQi3ee/UeZd4y6vWGhm2y
wn4CmvzJLI3P7iKa9f1aZO8U9GyuMWIjRSbVL0//aGGYKukzbAvi+bgqLiaJkvec
R5Tw7+77g5KsgjbMlee8Ma4lDCswf/DkB2PYthy17+kegEZf8wSAcL/gTWc8AI9N
as2+Y0vxAgMBAAECggEAAoTwpytkWdEkDxpIR7kndwdqNenmpNEi5NvCYroAekYh
WvU3gTsoGmJNwbeVMPIKBpn+CNm6mTuZrBIDNV8XMav3PCAmSZH3bPmO604heq9f
gBEaco9XgJZpwD7WsS0YxfYfrbZQEEK/w6ozpv1c0K4sEZhXQSRLEGdiykJL74tl
bfbJ86YLHjf7i+d8k4Zzd+F/iD98CcaUHcwPxHNWlwDbFDXzsYp4w+x7oQ/BWnMB
jFVf+YhrgYjYtx/8Md6qvnOZdhb2ByJw1k/59HRJELYVUtmqJnzp9ArXozpuUohm
oqIAMXgCHEiMhTjKom1JoKZmDsCEaC7W/TY3eflqwQKBgQDdFqT9uLB4EwH8cPGN
lFxdexPcWr+1i33ZD7aXQEJlg+GzIyTOdSyvlow9mZViwa+MSrvXMnTHcOCIowZM
OhDVqVHl1XWJuv5BCmlLvNmjnXhxg6/ZqS9HZXrbz38DnpR6OiUF05C5kMaJ9kIB
133K6txSoQ/5vbcFRnNf9EICEQKBgQC5QiAIlQT+fRA6r9mD2fJctfxZ1Ae++GOz
lW5EQjYZT1+cHQAX+0ifhTVtl5jxgAKy9YyC4ASqkxg0a6lQfXqF+2MQtIRSpqt1
yowePgCFcA3JozTznj4ctL4oONHuKSBVYfDMcL0YPN1YTzTImQ6FG1CsGI2byrG6
Y3JCsPzL4QKBgQCKZ3mkSDFZCfUtVnsxOZZVAw6c3Ma03P1MnFSe/SBTsqrhXPfW
s23lAicLDRGCwGOoPMS45CJNFHHLt9rib1tIlnXpnqa1MTWn+9+NBU1t6s+SqHC2
nv41AOdXod8OogCrP6kbq6UnNeXESkBqLL/X/w0sQR3iJwzjJYZmpF+KMQKBgQCz
DPsC8GxUPrGp1v3m1oXNH0LX2vrlkxJhpkJdjJTW34Ur0Eef5gkpzEh4NHXoq21w
Y6y7bSJ1bheNyqRpG+2IgxAbPC1L6LR88xd7vzcnwMZCpQ/viXjEq9fB7jDP+0W5
4CAop6nLPEA+Msd0PaHv+hd9TXnIIh6mY6kyVfbuYQKBgQC6SMjN2fZMGhqzoMfS
dTyyvq8ji73u0mK+oyyCVUgIFQqHAQg58+XZh/HyG9M8wbB4tQ3ceYHd27C93/ox
+NDLSE+sOzZBtEIjMacoJ+SDGXDiKxRl7ogGt1YWk+MjaAR2MDPHQLNu4azZqfJN
BAGwlAmfqqPxZX6+gIhCXtLRdQ==
-----END PRIVATE KEY-----
''';

  // دالة للحصول على Access Token
  Future<String?> _getAccessToken() async {
    try {
      final accountCredentials = auth.ServiceAccountCredentials.fromJson({
        "private_key": _privateKey,
        "client_email": _clientEmail,
        "project_id": _projectId,
        "type": "service_account",
      });

      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final client = await auth.clientViaServiceAccount(
        accountCredentials,
        scopes,
      );
      return client.credentials.accessToken.data;
    } catch (e) {
      debugPrint("خطأ في توليد التوكن: $e");
      return null;
    }
  }

  Future<void> _sendNotification() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() => _isSending = true);

    try {
      // 1. حفظ في قاعدة البيانات (للعرض الداخلي في التطبيق)
      await FirebaseDatabase.instance.ref('notifications').push().set({
        'body': _messageController.text.trim(),
        'sender': 'الإدارة (مؤمل)',
        'timestamp': ServerValue.timestamp,
      });

      // 2. الحصول على توكن المصادقة الجديد (V1)
      final String? accessToken = await _getAccessToken();

      if (accessToken == null) {
        throw "فشل في المصادقة مع Google API - تأكد من صلاحيات ملف الخدمة";
      }

      // 3. إرسال الإشعار باستخدام FCM V1 API
      final response = await http.post(
        Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send',
        ),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'topic': 'all', // يرسل لجميع المشتركين في topic 'all'
            'notification': {
              'title': 'تنبيه من بيت العطار',
              'body': _messageController.text.trim(),
            },
            'android': {
              'notification': {
                'sound': 'default',
                'priority': 'high', // لضمان الظهور
                'channel_id':
                    'high_importance_channel', // نفس ID القناة في main
              },
            },
            'data': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'id': '1',
              'body': _messageController.text.trim(),
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تم الإرسال بنجاح (V1)")),
          );
        }
      } else {
        throw "خطأ من السيرفر (${response.statusCode}): ${response.body}";
      }

      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("خطأ: $e")));
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إرسال إشعار (V1)"),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.notifications_active, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              "نظام الإشعارات المطور (V1)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "اكتب رسالة لتصل لجميع الهواتف فوراً",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "مثال: عرض خاص على الزعفران...",
                labelText: "نص الإشعار",
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _sendNotification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.send),
                label: _isSending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("إرسال الآن"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// شاشة المدير (مؤمل) - محدثة
// ---------------------------------------------------------------------------
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_user');
    currentUser = "";
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة المدير (مؤمل)"),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // زر الدخول للتطبيق كـ مستخدم عادي
              _DashboardCard(
                title: "الدخول لتطبيقي الخاص",
                subtitle: "إدارة منتجاتي وبياناتي",
                icon: Icons.store_mall_directory,
                color: const Color(0xFF00897B),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              // زر إدارة الحسابات (حذف/تعديل)
              _DashboardCard(
                title: "إدارة الحسابات",
                subtitle: "حذف الحسابات وتعديل الصلاحيات",
                icon: Icons.manage_accounts,
                color: Colors.orange.shade800,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageUsersScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // زر إرسال الإشعارات (جديد)
              _DashboardCard(
                title: "إرسال إشعارات",
                subtitle: "إرسال تنبيهات لكل المستخدمين",
                icon: Icons.notifications_active,
                color: Colors.red.shade700,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SendNotificationScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// شاشة إدارة المستخدمين (حذف وإضافة) - محدثة
// ---------------------------------------------------------------------------
class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  // دالة الحذف
  void _deleteUser(BuildContext context, String key) {
    if (key == "مؤمل") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لا يمكن حذف حساب المدير الرئيسي!")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: Text(
          "هل أنت متأكد من حذف حساب ($key)؟\nسيتم حذف بيانات الدخول والبيانات الخاصة.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              // 1. حذف من accounts (بيانات الدخول)
              FirebaseDatabase.instance.ref('accounts/$key').remove();
              // 2. حذف من users_data (بيانات المستخدم الخاصة كالخلطات)
              FirebaseDatabase.instance.ref('users_data/$key').remove();

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("تم حذف الحساب والبيانات بنجاح")),
              );
            },
            child: const Text("حذف نهائي", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة الحسابات"),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange.shade800,
        child: const Icon(Icons.person_add, color: Colors.white),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateUserScreen()),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref('accounts').onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("حدث خطأ"));
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("لا يوجد حسابات حالياً"));
          }

          final rawData = snapshot.data!.snapshot.value;
          List<Map<String, dynamic>> users = [];

          if (rawData is Map) {
            rawData.forEach((key, value) {
              final userData = Map<String, dynamic>.from(value as Map);
              users.add({'key': key, 'password': userData['password']});
            });
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user['key'] == "مؤمل"
                        ? Colors.purple
                        : Colors.teal,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    user['key'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("الرمز: ${user['password']}"),
                  trailing: user['key'] == "مؤمل"
                      ? null // إخفاء الحذف للمدير
                      : IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteUser(context, user['key']),
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
// شاشة إنشاء مستخدم جديد
// ---------------------------------------------------------------------------
class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _newUsernameController = TextEditingController();
  final _newPasswordController = TextEditingController();

  void _createNewUser() async {
    String username = _newUsernameController.text.trim();
    String password = _newPasswordController.text.trim();

    if (username.isEmpty || password.isEmpty) return;

    if (username == "مؤمل") {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("لا يمكن تكرار اسم المدير")));
      return;
    }

    await FirebaseDatabase.instance.ref('accounts/$username').set({
      'password': password,
      'created_at': ServerValue.timestamp,
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("تم إنشاء الحساب بنجاح")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إنشاء حساب جديد")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _newUsernameController,
              decoration: const InputDecoration(
                labelText: "اسم المستخدم الجديد",
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(labelText: "كلمة المرور"),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _createNewUser,
                icon: const Icon(Icons.save),
                label: const Text("حفظ الحساب"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade700,
                  foregroundColor: Colors.white,
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
// الشاشة الرئيسية (HomeScreen) - متجاوبة مع إضافة زر الدعم (واتساب)
// ---------------------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_user');
    currentUser = "";
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  // ✅ دالة لفتح واتساب للدعم الفني
  Future<void> _launchSupportWhatsApp(BuildContext context) async {
    const phoneNumber = "9647726860085"; // رقم الدعم
    final appUrl = Uri.parse("whatsapp://send?phone=$phoneNumber");
    final webUrl = Uri.parse("https://wa.me/$phoneNumber");

    try {
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl);
      } else {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("تعذر فتح الواتساب")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ التحقق من حجم الشاشة
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 380;

    return StreamBuilder(
      stream: (currentUser == "مؤمل")
          ? null
          : FirebaseDatabase.instance.ref('accounts/$currentUser').onValue,
      builder: (context, snapshot) {
        if (currentUser != "مؤمل" &&
            snapshot.hasData &&
            snapshot.data!.snapshot.value == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _logout(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("تم حذف حسابك من قبل الإدارة"),
                backgroundColor: Colors.red,
              ),
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: Text(
              "لوحة التحكم ($currentUser)",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            backgroundColor: const Color(0xFF00897B),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserNotificationsScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () => _logout(context),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          icon: Icons.settings_applications,
                          color: Colors.red.shade700,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MixturesListScreen(type: 'all'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
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
                        _DashboardCard(
                          title: "حاسبة الغرامات",
                          icon: Icons.scale,
                          color: Colors.blue.shade600,
                          isVertical: false,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GramCalculatorPage(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _DashboardCard(
                          title: "حاسبة الأسعار",
                          icon: Icons.calculate,
                          color: Colors.indigo.shade600,
                          isVertical: false,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const QuickOrderCalculator(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
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

                        // القسم المتجاوب (الخلطات)
                        if (isSmallScreen) ...[
                          _DashboardCard(
                            title: "الخلطات العلاجية",
                            subtitle: "طب بديل",
                            icon: Icons.medical_services_outlined,
                            color: const Color(0xFF00897B),
                            isVertical: false,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MixturesListScreen(type: 'medical'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _DashboardCard(
                            title: "خلطات البهارات",
                            subtitle: "توابل ونكهات",
                            icon: Icons.soup_kitchen_outlined,
                            color: const Color(0xFFFF8F00),
                            isVertical: false,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MixturesListScreen(type: 'spice'),
                              ),
                            ),
                          ),
                        ] else ...[
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
                                          const MixturesListScreen(
                                            type: 'medical',
                                          ),
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
                                          const MixturesListScreen(
                                            type: 'spice',
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 24),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            "ذكاء اصطناعي",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        _DashboardCard(
                          title: "الموسوعة الذكية ",
                          subtitle: "معلومات فورية عن أي عشبة",
                          icon: Icons.psychology,
                          color: Colors.purple.shade600,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SmartHerbAssistant(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        // ✅ زر الدعم الفني الجديد
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            "الدعم والمساعدة",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        _DashboardCard(
                          title: "تواصل مع الدعم الفني",
                          subtitle: "راسلنا على واتساب لأي مشكلة",
                          icon: Icons.support_agent,
                          color: Colors.green.shade600,
                          isVertical: false, // جعلته أفقياً ليأخذ مساحة
                          onTap: () => _launchSupportWhatsApp(context),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  width: double.infinity,
                  child: Column(
                    children: const [
                      Text(
                        "جميع الحقوق محفوظة لعطارة بيت العطار",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "تم برمجة التطبيق بواسطة kratossysttems",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
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
  }
}

// ---------------------------------------------------------------------------
// Widget البطاقات (DashboardCard)
// ---------------------------------------------------------------------------
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
// حاسبة الغرامات (Tabs)
// ---------------------------------------------------------------------------
class GramCalculatorPage extends StatefulWidget {
  const GramCalculatorPage({super.key});

  @override
  State<GramCalculatorPage> createState() => _GramCalculatorPageState();
}

class _GramCalculatorPageState extends State<GramCalculatorPage> {
  final _pricePerKgController1 = TextEditingController();
  final _targetPriceController = TextEditingController();
  String _resultWeight = "0";

  final _pricePerKgController2 = TextEditingController();
  final _targetGramsController = TextEditingController();
  String _resultPrice = "0";

  void _calculateWeight() {
    double pricePerKg = double.tryParse(_pricePerKgController1.text) ?? 0;
    double targetPrice = double.tryParse(_targetPriceController.text) ?? 0;
    if (pricePerKg > 0) {
      double grams = (targetPrice / pricePerKg) * 1000;
      setState(() {
        _resultWeight = grams.toStringAsFixed(0);
      });
    }
  }

  void _calculatePrice() {
    double pricePerKg = double.tryParse(_pricePerKgController2.text) ?? 0;
    double targetGrams = double.tryParse(_targetGramsController.text) ?? 0;
    if (pricePerKg > 0) {
      double price = (targetGrams / 1000) * pricePerKg;
      setState(() {
        _resultPrice = price.toStringAsFixed(0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("حاسبة الغرامات والأسعار"),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "عندي مبلغ (أريد الوزن)"),
              Tab(text: "عندي وزن (أريد السعر)"),
            ],
          ),
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                children: [
                  const Text(
                    "أدخل المبلغ الذي يملكه الزبون لتعرف كم غراماً يستحق:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _pricePerKgController1,
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
                      labelText: "المبلغ المراد الشراء به",
                      prefixIcon: Icon(Icons.monetization_on),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _calculateWeight,
                      icon: const Icon(Icons.scale),
                      label: const Text("احسب الوزن المستحق"),
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
                          "الوزن المطلوب",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "$_resultWeight غرام",
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                children: [
                  const Text(
                    "أدخل الوزن المطلوب لتعرف كم يكلف:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _pricePerKgController2,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "سعر الكيلو (دينار)",
                      prefixIcon: Icon(Icons.price_change),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _targetGramsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "الوزن المطلوب (غرام)",
                      prefixIcon: Icon(Icons.scale),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _calculatePrice,
                      icon: const Icon(Icons.calculate),
                      label: const Text("احسب السعر"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.indigo.shade100),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "السعر المطلوب",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "$_resultPrice دينار",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade800,
                          ),
                        ),
                      ],
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
// حاسبة الأسعار السريعة
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
// شاشات الخلطات (Mixtures)
// ---------------------------------------------------------------------------
class MixturesListScreen extends StatefulWidget {
  final String type;
  const MixturesListScreen({required this.type, super.key});

  @override
  State<MixturesListScreen> createState() => _MixturesListScreenState();
}

class _MixturesListScreenState extends State<MixturesListScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

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
              FirebaseDatabase.instance
                  .ref('users_data/$currentUser/mixtures')
                  .child(key)
                  .remove();
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

    Query dbQuery = FirebaseDatabase.instance.ref(
      'users_data/$currentUser/mixtures',
    );

    if (!isAll) {
      dbQuery = dbQuery.orderByChild('type').equalTo(widget.type);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                decoration: const InputDecoration(
                  hintText: "اكتب اسم الخلطة...",
                  hintStyle: TextStyle(color: Color.fromARGB(179, 0, 0, 0)),
                  border: InputBorder.none,
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
                    _isSearching
                        ? "لا توجد نتائج مطابقة"
                        : "لا توجد بيانات لهذا الحساب",
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: mixturesList.length,
            padding: const EdgeInsets.only(
              bottom: 80,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // ضروري للسماح بالارتفاع الكامل
            useSafeArea:
                true, // ✅ الإضافة الجديدة: تحمي المحتوى من الاختفاء تحت شريط الحالة
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
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: RichText(
                                textDirection: TextDirection
                                    .rtl, // اتجاه النص من اليمين لليسار
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                    fontFamily: 'Roboto',
                                  ),
                                  children: [
                                    // 1. الوزن أولاً (باللون الأزرق)
                                    TextSpan(
                                      text: "$p ",
                                      style: TextStyle(
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const TextSpan(text: "غرام"),

                                    // 2. الفاصل
                                    const TextSpan(
                                      text: "   |   ",
                                      style: TextStyle(color: Colors.grey),
                                    ),

                                    // 3. السعر ثانياً (باللون الأخضر)
                                    TextSpan(
                                      text: "$g ",
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const TextSpan(text: "دينار/كغ"),
                                  ],
                                ),
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
// نافذة حاسبة الكميات (Modal) - ملء الشاشة (Full Screen)
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
    bool isWeightMode = _tabController.index == 0;

    if (_baseTotalWeight == 0) return;
    double ratio = 0;

    if (isWeightMode) {
      newTotalWeight = inputVal;
      ratio = newTotalWeight / _baseTotalWeight;
    } else {
      double pricePerGram = _baseTotalPrice / _baseTotalWeight;
      if (pricePerGram > 0) {
        newTotalWeight = inputVal / pricePerGram;
        ratio = newTotalWeight / _baseTotalWeight;
      }
    }

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
    // ✅ التعديل هنا: جعل الحاوية تأخذ ارتفاع الشاشة بالكامل
    return Container(
      height: MediaQuery.of(context).size.height, // ارتفاع كامل
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // مقبض السحب
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 12),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // زر الإغلاق + العنوان
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  "حاسبة: ${widget.mixtureName}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.themeColor,
                  ),
                ),
                const SizedBox(width: 48), // مسافة لموازنة زر الإغلاق
              ],
            ),
          ),

          const SizedBox(height: 2),

          // التبويبات
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
                  borderRadius: BorderRadius.circular(9),
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

          const SizedBox(height: 10),

          // حقل الإدخال
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: _tabController.index == 0
                    ? "الوزن المطلوب (غرام)"
                    : "السعر المطلوب (دينار)",
                hintText: _tabController.index == 0
                    ? "مثلاً: 250"
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

          // --- ملخص النتائج (تم تصغير الحجم) ---
          if (_calculatedIngredients.isNotEmpty)
            Container(
              // تقليل الهوامش الداخلية (كان 16)
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 6),
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
                        style: TextStyle(
                          fontSize: 10,
                        ), // تصغير خط العنوان (كان 14)
                      ),
                      Text(
                        "${_calculatedTotalWeight.toStringAsFixed(0)} غرام",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15, // تصغير الرقم (كان 28)
                          color: widget.themeColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 30, // تصغير ارتفاع الخط الفاصل (كان 40)
                    width: 0.1,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "السعر النهائي",
                        style: TextStyle(fontSize: 12), // تصغير خط العنوان
                      ),
                      Text(
                        "${_calculatedTotalPrice.toStringAsFixed(0)} د.ع",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22, // تصغير الرقم (كان 28)
                          color: widget.themeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // قائمة المواد
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
                        margin: const EdgeInsets.only(bottom: 0),
                        padding: const EdgeInsets.symmetric(vertical: 0.2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${(item['grams'] as double).toStringAsFixed(1)} غرام",
                                  style: TextStyle(
                                    color: widget.themeColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${(item['cost'] as double).toStringAsFixed(0)} د.ع",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
            .ref('users_data/$currentUser/mixtures')
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

  final _ingNameController = TextEditingController();
  final _ingGramsController = TextEditingController();
  final _ingPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentData['name'] ?? '';
    _instructionsController.text = widget.currentData['instructions'] ?? '';

    if (widget.currentData['ingredients'] != null) {
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
            .ref('users_data/$currentUser/mixtures')
            .child(widget.mixtureKey)
            .update({
              'name': _nameController.text,
              'instructions': _instructionsController.text,
              'ingredients': _tempIngredients,
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

// ---------------------------------------------------------------------------
// شاشة المساعد الذكي (نسخة: تتوفر الخدمة قريباً)
// ---------------------------------------------------------------------------
class SmartHerbAssistant extends StatelessWidget {
  const SmartHerbAssistant({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الموسوعة الذكية"),
        backgroundColor: Colors.purple.shade600, // نفس لون البطاقة في القائمة
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.engineering, // أيقونة تدل على العمل
              size: 100,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            Text(
              "تتوفر الخدمة قريباً",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "نعمل حالياً على تطوير هذه الميزة",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
