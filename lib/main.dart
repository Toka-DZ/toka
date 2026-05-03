import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const TaqwaApp());
}

class TC {
  static const bg = Color(0xFF060F0A);
  static const bg2 = Color(0xFF0D1F13);
  static const card = Color(0xFF0C2314);
  static const card2 = Color(0xFF12301C);
  static const gold = Color(0xFFC9A84C);
  static const gold2 = Color(0xFFE8C97A);
  static const gold3 = Color(0xFF8B6914);
  static const green = Color(0xFF1A6B4A);
  static const green2 = Color(0xFF25A36E);
  static const text = Color(0xFFF5EDD6);
  static const text2 = Color(0xFFB8A882);
  static const text3 = Color(0xFF7D6C4E);
  static const border = Color(0x2DC9A84C);
  static const border2 = Color(0x73C9A84C);
  static const night1 = Color(0xFF0D1B2A);
  static const night2 = Color(0xFF1A2744);
  static const night3 = Color(0xFF2D3A5C);
  static const themes = {
    'blue': [
      Color(0xFF0D1B2A),
      Color(0xFF1A2744),
      Color(0xFF2D3A5C),
      Color(0xFF3D4F7C)
    ],
    'green': [
      Color(0xFF0A1F12),
      Color(0xFF0D2B18),
      Color(0xFF1A4A2E),
      Color(0xFF256040)
    ],
    'brown': [
      Color(0xFF1A0F08),
      Color(0xFF2D1A0E),
      Color(0xFF3D2510),
      Color(0xFF5C3A1A)
    ],
  };
  static List<Color> getTheme(String t) => themes[t] ?? themes['blue']!;
  static Color cardColor(String t) {
    if (t == 'green') return const Color(0xFF0D2B18);
    if (t == 'brown') return const Color(0xFF2D1A0E);
    return const Color(0xFF0C1E2E);
  }

  static Color card2Color(String t) {
    if (t == 'green') return const Color(0xFF12351E);
    if (t == 'brown') return const Color(0xFF3D2510);
    return const Color(0xFF122440);
  }
}

class AppState extends ChangeNotifier {
  static final AppState _i = AppState._();
  factory AppState() => _i;
  AppState._();
  String _lang = 'ar';
  String _theme = 'blue';
  String _userName = '';
  String _userGender = 'female';
  bool _loaded = false;
  String get lang => _lang;
  String get theme => _theme;
  String get userName => _userName;
  String get userGender => _userGender;
  bool get loaded => _loaded;
  bool get isFirstTime => _userName.isEmpty;
  String get appName => _lang == 'ar' ? 'تقى' : 'Toka';
  String get appSlogan => _lang == 'ar'
      ? 'نور الإيمان'
      : _lang == 'fr'
          ? 'La lumière de la foi'
          : 'The Light of Faith';
  String get palestineDua => _lang == 'ar'
      ? '🇵🇸 اللهم انصر إخواننا في فلسطين 🇵🇸'
      : _lang == 'fr'
          ? '🇵🇸 Ô Allah, aide nos frères en Palestine 🇵🇸'
          : '🇵🇸 O Allah, support our brothers in Palestine 🇵🇸';
  void setLang(String v) {
    _lang = v;
    notifyListeners();
    _save();
  }

  void setTheme(String v) {
    _theme = v;
    notifyListeners();
    _save();
  }

  void setUser(String name, String gender) {
    _userName = name;
    _userGender = gender;
    notifyListeners();
    _save();
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _lang = p.getString('lang') ?? 'ar';
    _theme = p.getString('theme') ?? 'blue';
    _userName = p.getString('userName') ?? '';
    _userGender = p.getString('userGender') ?? 'female';
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('lang', _lang);
    await p.setString('theme', _theme);
    await p.setString('userName', _userName);
    await p.setString('userGender', _userGender);
  }
}

class TaqwaApp extends StatefulWidget {
  const TaqwaApp({super.key});
  @override
  State<TaqwaApp> createState() => _TaqwaAppState();
}

class _TaqwaAppState extends State<TaqwaApp> {
  @override
  void initState() {
    super.initState();
    AppState().addListener(() => setState(() {}));
    AppState().load();
  }

  @override
  Widget build(BuildContext context) {
    if (!AppState().loaded)
      return const MaterialApp(
          home: Scaffold(
              backgroundColor: TC.night1,
              body: Center(child: CircularProgressIndicator(color: TC.gold))));
    return MaterialApp(
      title: 'تقى',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.transparent,
          colorScheme:
              const ColorScheme.dark(primary: TC.gold, secondary: TC.green2),
          useMaterial3: true),
      home: AppState().isFirstTime
          ? const OnboardingScreen()
          : const SplashScreen(),
    );
  }
}

class AnimatedBg extends StatefulWidget {
  final Widget child;
  const AnimatedBg({super.key, required this.child});
  @override
  State<AnimatedBg> createState() => _AnimatedBgState();
}

class _AnimatedBgState extends State<AnimatedBg> with TickerProviderStateMixin {
  late AnimationController _moonCtrl, _glowCtrl;
  late Animation<double> _moonAnim, _glowAnim;
  final _rand = Random();
  late List<_StarData> _stars;
  @override
  void initState() {
    super.initState();
    _moonCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..repeat(reverse: true);
    _glowCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _moonAnim = CurvedAnimation(parent: _moonCtrl, curve: Curves.easeInOut);
    _glowAnim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
    _stars = List.generate(
        65,
        (_) => _StarData(
            x: _rand.nextDouble(),
            y: _rand.nextDouble() * 0.65,
            size: _rand.nextDouble() * 2.5 + 0.5,
            speed: _rand.nextDouble() * 2000 + 1000,
            delay: _rand.nextDouble() * 3000));
    AppState().addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _moonCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final tc = TC.getTheme(AppState().theme);
    return Stack(children: [
      Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: tc,
                  stops: const [0.0, 0.3, 0.7, 1.0]))),
      AnimatedBuilder(
          animation: _glowAnim,
          builder: (_, __) => Container(
                  decoration: BoxDecoration(
                      gradient: RadialGradient(
                          center: const Alignment(0, -0.6),
                          radius: 0.7,
                          colors: [
                    TC.gold.withOpacity(0.05 + 0.03 * _glowAnim.value),
                    Colors.transparent
                  ])))),
      ...(_stars.map((s) => Positioned(
          left: s.x * size.width,
          top: s.y * size.height,
          child: _TwinkleStar(
              size: s.size,
              durationMs: s.speed.toInt(),
              delayMs: s.delay.toInt())))),
      Positioned(
          top: 35,
          right: 25,
          child: AnimatedBuilder(
              animation: _moonAnim,
              builder: (_, __) => Transform.translate(
                  offset: Offset(0, -7 * _moonAnim.value),
                  child: Opacity(
                      opacity: 0.75 + 0.25 * _moonAnim.value,
                      child: const _CrescentWidget(size: 42))))),
      Positioned(
          top: 32,
          right: 78,
          child: AnimatedBuilder(
              animation: _glowAnim,
              builder: (_, __) => Opacity(
                  opacity: 0.3 + 0.6 * _glowAnim.value,
                  child: const Text('✦',
                      style: TextStyle(color: TC.gold, fontSize: 10))))),
      widget.child,
    ]);
  }
}

class _StarData {
  final double x, y, size, speed, delay;
  _StarData(
      {required this.x,
      required this.y,
      required this.size,
      required this.speed,
      required this.delay});
}

class _TwinkleStar extends StatefulWidget {
  final double size;
  final int durationMs, delayMs;
  const _TwinkleStar(
      {required this.size, required this.durationMs, required this.delayMs});
  @override
  State<_TwinkleStar> createState() => _TwinkleStarState();
}

class _TwinkleStarState extends State<_TwinkleStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.durationMs))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Opacity(
          opacity: 0.15 + 0.85 * _c.value,
          child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.white.withOpacity(0.5 * _c.value),
                        blurRadius: 3)
                  ]))));
}

class _CrescentWidget extends StatelessWidget {
  final double size;
  const _CrescentWidget({required this.size});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _CrescentPainter());
}

class _CrescentPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = const Color(0xFFD4AF37);
    final path = Path()
      ..addOval(Rect.fromCenter(
          center: Offset(s.width * .45, s.height * .5),
          width: s.width * .75,
          height: s.height * .75));
    final cut = Path()
      ..addOval(Rect.fromCenter(
          center: Offset(s.width * .65, s.height * .42),
          width: s.width * .65,
          height: s.height * .65));
    c.drawPath(Path.combine(PathOperation.difference, path, cut), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

class DomeWidget extends StatelessWidget {
  final double height;
  const DomeWidget({super.key, this.height = 180});
  @override
  Widget build(BuildContext context) => SizedBox(
      height: height,
      child: CustomPaint(
          size: Size(MediaQuery.of(context).size.width, height),
          painter: _DomePainter()));
}

class _DomePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final g = Paint()
      ..shader = LinearGradient(colors: const [
        Color(0xFFF5D76E),
        Color(0xFFD4AF37),
        Color(0xFF8B6914)
      ]).createShader(Rect.fromLTWH(cx - 80, 0, 160, s.height));
    final blue = Paint()..color = const Color(0xFF3B6FC9);
    final blue2 = Paint()..color = const Color(0xFF4E85D8);
    final line = Paint()
      ..color = TC.gold.withOpacity(0.4)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 145, s.height * .56, 290, s.height * .38),
            const Radius.circular(6)),
        blue);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 145, s.height * .56, 290, s.height * .38),
            const Radius.circular(6)),
        line);
    for (final x in [cx - 125.0, cx - 83.0, cx - 8.0, cx + 38.0, cx + 85.0])
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x, s.height * .6, 28, s.height * .26),
              const Radius.circular(14)),
          blue2);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 115, s.height * .45, 230, s.height * .13),
            const Radius.circular(3)),
        blue2);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 115, s.height * .45, 230, s.height * .13),
            const Radius.circular(3)),
        line);
    final base = Path()
      ..moveTo(cx - 78, s.height * .45)
      ..lineTo(cx + 78, s.height * .45)
      ..lineTo(cx + 94, s.height * .37)
      ..lineTo(cx - 94, s.height * .37)
      ..close();
    canvas.drawPath(base, blue);
    canvas.drawPath(base, line);
    final dome = Path()
      ..moveTo(cx - 94, s.height * .37)
      ..quadraticBezierTo(cx - 78, s.height * .04, cx, s.height * -.03)
      ..quadraticBezierTo(cx + 78, s.height * .04, cx + 94, s.height * .37)
      ..close();
    canvas.drawPath(dome, g);
    canvas.drawPath(dome, line..strokeWidth = 1.5);
    canvas.drawPath(
        Path()
          ..moveTo(cx - 18, s.height * .28)
          ..quadraticBezierTo(cx - 38, s.height * .1, cx, s.height * -.02)
          ..quadraticBezierTo(cx - 28, s.height * .12, cx - 8, s.height * .3)
          ..close(),
        Paint()..color = Colors.white.withOpacity(0.15));
    canvas.drawLine(
        Offset(cx, s.height * -.03),
        Offset(cx, s.height * -.12),
        g
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
    canvas.drawCircle(
        Offset(cx, s.height * -.14), 4, g..style = PaintingStyle.fill);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx, s.height * .37), width: 185, height: 10),
        Paint()
          ..color = TC.gold.withOpacity(0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ═══════════════════════════════════════════════════════════
// ONBOARDING
// ═══════════════════════════════════════════════════════════
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  final _nameCtrl = TextEditingController();
  String _gender = 'female';
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;
  @override
  void initState() {
    super.initState();
    AppState().addListener(() => setState(() {}));
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 2) {
      setState(() {
        _step++;
      });
      _fadeCtrl.forward(from: 0);
    } else {
      if (_nameCtrl.text.trim().isEmpty) return;
      AppState().setUser(_nameCtrl.text.trim(), _gender);
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SplashScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppState().lang;
    return Scaffold(
      body: AnimatedBg(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: Column(children: [
              const SizedBox(height: 20),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      3,
                      (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _step == i ? 30 : 10,
                            height: 8,
                            decoration: BoxDecoration(
                                color: _step >= i ? TC.gold : TC.border2,
                                borderRadius: BorderRadius.circular(4)),
                          ))),
              const SizedBox(height: 16),
              Expanded(
                  child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _step == 0
                    ? _buildLangStep()
                    : _step == 1
                        ? _buildThemeStep()
                        : _buildUserStep(),
              )),
              Padding(
                padding: const EdgeInsets.all(20),
                child: TaqwaBtn(
                  label: _step == 2
                      ? (l == 'ar'
                          ? 'لنبدأ! 🌙'
                          : l == 'fr'
                              ? 'Commençons! 🌙'
                              : 'Let\'s start! 🌙')
                      : (l == 'ar'
                          ? 'التالي ←'
                          : l == 'fr'
                              ? 'Suivant →'
                              : 'Next →'),
                  onTap: _next,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildLangStep() {
    final l = AppState().lang;
    return Column(children: [
      DomeWidget(height: 130),
      const SizedBox(height: 16),
      Text('تقى',
          style: const TextStyle(
              color: TC.gold, fontSize: 56, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(
          l == 'ar'
              ? 'اختر لغتك'
              : l == 'fr'
                  ? 'Choisissez votre langue'
                  : 'Choose your language',
          style: const TextStyle(color: TC.text2, fontSize: 16)),
      const SizedBox(height: 30),
      ...[
        ('ar', '🇸🇦', 'العربية', 'Arabic'),
        ('fr', '🇫🇷', 'Français', 'French'),
        ('en', '🇬🇧', 'English', 'English')
      ].map((item) => GestureDetector(
            onTap: () => AppState().setLang(item.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppState().lang == item.$1
                    ? TC.gold.withOpacity(0.15)
                    : TC.cardColor(AppState().theme).withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppState().lang == item.$1 ? TC.gold : TC.border2,
                    width: AppState().lang == item.$1 ? 2 : 1),
              ),
              child: Row(children: [
                Text(item.$2, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.$3,
                      style: TextStyle(
                          color: AppState().lang == item.$1 ? TC.gold : TC.text,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text(item.$4,
                      style: const TextStyle(color: TC.text3, fontSize: 12)),
                ]),
                const Spacer(),
                if (AppState().lang == item.$1)
                  const Icon(Icons.check_circle, color: TC.gold),
              ]),
            ),
          )),
    ]);
  }

  // ══ FIX 1: Theme step — French translation fixed ══
  Widget _buildThemeStep() {
    final l = AppState().lang;
    final themes = [
      (
        'blue',
        '🌊',
        l == 'ar'
            ? 'الماء'
            : l == 'fr'
                ? 'Eau'
                : 'Water',
        l == 'ar'
            ? 'نيلي داكن'
            : l == 'fr'
                ? 'Bleu Nuit'
                : 'Night Blue',
        l == 'ar'
            ? '﴿ وَجَعَلْنَا مِنَ الْمَاءِ كُلَّ شَيْءٍ حَيٍّ ﴾'
            : l == 'fr'
                ? '﴿ Nous avons fait de l\'eau toute chose vivante ﴾'
                : '﴿ We made from water every living thing ﴾',
        TC.night2,
        [TC.night1, TC.night2, TC.night3, const Color(0xFF3D4F7C)]
      ),
      (
        'green',
        '🌿',
        l == 'ar'
            ? 'النبات'
            : l == 'fr'
                ? 'Nature'
                : 'Plant',
        l == 'ar'
            ? 'أخضر زمردي'
            : l == 'fr'
                ? 'Vert Émeraude'
                : 'Emerald Green',
        l == 'ar'
            ? '﴿ وَهُوَ الَّذِي أَنشَأَ جَنَّاتٍ مَّعْرُوشَاتٍ ﴾'
            : l == 'fr'
                ? '﴿ C\'est Lui qui a créé les jardins en treilles ﴾'
                : '﴿ He who created gardens with trellises ﴾',
        TC.green,
        [
          const Color(0xFF0A1F12),
          const Color(0xFF0D2B18),
          const Color(0xFF1A4A2E),
          const Color(0xFF256040)
        ]
      ),
      (
        'brown',
        '🏔️',
        l == 'ar'
            ? 'التراب'
            : l == 'fr'
                ? 'Terre'
                : 'Earth',
        l == 'ar'
            ? 'بني ذهبي'
            : l == 'fr'
                ? 'Brun Doré'
                : 'Golden Brown',
        l == 'ar'
            ? '﴿ مِنْهَا خَلَقْنَاكُمْ وَفِيهَا نُعِيدُكُمْ ﴾'
            : l == 'fr'
                ? '﴿ De la terre Nous vous avons créés ﴾'
                : '﴿ From it We created you and into it We return you ﴾',
        const Color(0xFF3D2510),
        [
          const Color(0xFF1A0F08),
          const Color(0xFF2D1A0E),
          const Color(0xFF3D2510),
          const Color(0xFF5C3A1A)
        ]
      ),
    ];
    return Column(children: [
      Text(
          l == 'ar'
              ? '🎨 اختر ثيمك'
              : l == 'fr'
                  ? '🎨 Choisissez votre thème'
                  : '🎨 Choose your theme',
          style: const TextStyle(
              color: TC.gold, fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center),
      const SizedBox(height: 6),
      Text(
          l == 'ar'
              ? 'كل ثيم مستوحى من آية قرآنية'
              : l == 'fr'
                  ? 'Chaque thème est inspiré d\'un verset coranique'
                  : 'Each theme is inspired by a Quranic verse',
          style: const TextStyle(color: TC.text3, fontSize: 12),
          textAlign: TextAlign.center),
      const SizedBox(height: 24),
      ...themes.map((t) => GestureDetector(
            onTap: () => AppState().setTheme(t.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppState().theme == t.$1
                    ? t.$6.withOpacity(0.3)
                    : TC.cardColor(AppState().theme).withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppState().theme == t.$1 ? TC.gold : TC.border2,
                    width: AppState().theme == t.$1 ? 2 : 1),
              ),
              child: Column(children: [
                Row(children: [
                  Text(t.$2, style: const TextStyle(fontSize: 30)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('${t.$3} · ${t.$4}',
                            style: TextStyle(
                                color: AppState().theme == t.$1
                                    ? TC.gold
                                    : TC.text,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                            children: t.$7
                                .map((c) => Container(
                                    margin: const EdgeInsets.only(left: 4),
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle, color: c)))
                                .toList()),
                      ])),
                  if (AppState().theme == t.$1)
                    const Icon(Icons.check_circle, color: TC.gold),
                ]),
                const SizedBox(height: 10),
                Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(t.$5,
                        style: const TextStyle(
                            color: TC.gold2,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl)),
              ]),
            ),
          )),
    ]);
  }

  Widget _buildUserStep() {
    final l = AppState().lang;
    return Column(children: [
      const SizedBox(height: 20),
      Text(
          l == 'ar'
              ? 'أهلاً! أخبرنا عنك'
              : l == 'fr'
                  ? 'Bonjour! Parlez-nous de vous'
                  : 'Hello! Tell us about you',
          style: const TextStyle(
              color: TC.gold, fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center),
      const SizedBox(height: 8),
      Text(
          l == 'ar'
              ? 'لنخصص تجربتك'
              : l == 'fr'
                  ? 'Pour personnaliser votre expérience'
                  : 'To personalize your experience',
          style: const TextStyle(color: TC.text3, fontSize: 13),
          textAlign: TextAlign.center),
      const SizedBox(height: 30),
      Directionality(
          textDirection: l == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: TC.text),
              decoration: InputDecoration(
                hintText: l == 'ar'
                    ? 'اكتب اسمك...'
                    : l == 'fr'
                        ? 'Ton prénom...'
                        : 'Your name...',
                hintStyle: const TextStyle(color: TC.text3),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: TC.border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: TC.gold)),
                prefixIcon: const Icon(Icons.person_outline, color: TC.gold3),
              ))),
      const SizedBox(height: 24),
      Text(
          l == 'ar'
              ? 'الجنس'
              : l == 'fr'
                  ? 'Genre'
                  : 'Gender',
          style: const TextStyle(color: TC.text2, fontSize: 14)),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _GenderBtn(
            label: l == 'ar'
                ? 'أنثى'
                : l == 'fr'
                    ? 'Femme'
                    : 'Female',
            value: 'female',
            selected: _gender,
            icon: '👩',
            onTap: () => setState(() => _gender = 'female')),
        const SizedBox(width: 12),
        _GenderBtn(
            label: l == 'ar'
                ? 'ذكر'
                : l == 'fr'
                    ? 'Homme'
                    : 'Male',
            value: 'male',
            selected: _gender,
            icon: '👨',
            onTap: () => setState(() => _gender = 'male')),
      ]),
    ]);
  }
}

class _GenderBtn extends StatelessWidget {
  final String label, value, selected, icon;
  final VoidCallback onTap;
  const _GenderBtn(
      {required this.label,
      required this.value,
      required this.selected,
      required this.icon,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    final sel = selected == value;
    return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
                color: sel ? TC.gold.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: sel ? TC.gold : TC.border2, width: sel ? 2 : 1)),
            child: Column(children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      color: sel ? TC.gold : TC.text2,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal))
            ])));
  }
}

// ═══════════════════════════════════════════════════════════
// SPLASH
// ═══════════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl, _scaleCtrl, _glowCtrl;
  late Animation<double> _fade, _scale, _glow;
  @override
  void initState() {
    super.initState();
    AppState().addListener(() {
      if (mounted) setState(() {});
    });
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..forward();
    _scaleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
    _glowCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _scale = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
    _glow = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scaleCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  void _enter() => Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, __, ___) => const HomeScreen(),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 800)));
  @override
  Widget build(BuildContext context) {
    final s = AppState();
    return Scaffold(
        body: AnimatedBg(
            child: SafeArea(
                child: FadeTransition(
                    opacity: _fade,
                    child: Column(children: [
                      const SizedBox(height: 16),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: _LangSelector())
                      ]),
                      const Spacer(),
                      DomeWidget(height: 200),
                      const SizedBox(height: 16),
                      ScaleTransition(
                          scale: _scale,
                          child: AnimatedBuilder(
                              animation: _glow,
                              builder: (_, __) => Text(s.appName,
                                  style: TextStyle(
                                      fontSize: 88,
                                      color: TC.gold,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                            color: TC.gold.withOpacity(
                                                0.3 + 0.4 * _glow.value),
                                            blurRadius: 30),
                                        Shadow(
                                            color: TC.gold.withOpacity(
                                                0.2 + 0.2 * _glow.value),
                                            blurRadius: 60)
                                      ])))),
                      Text(s.appSlogan,
                          style: TextStyle(
                              color: TC.gold.withOpacity(0.6),
                              fontSize: 13,
                              letterSpacing: 4)),
                      const SizedBox(height: 12),
                      _OrnamentDivider(),
                      const SizedBox(height: 20),
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 30),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(30),
                              border:
                                  Border.all(color: TC.gold.withOpacity(0.2))),
                          child: Text(s.palestineDua,
                              style: const TextStyle(
                                  color: Color(0xFFE8D5A3),
                                  fontSize: 14,
                                  height: 1.6),
                              textAlign: TextAlign.center)),
                      const SizedBox(height: 30),
                      TaqwaBtn(
                          label: s.lang == 'ar'
                              ? 'ادخل للتطبيق ✨'
                              : s.lang == 'fr'
                                  ? 'Entrer ✨'
                                  : 'Enter ✨',
                          onTap: _enter),
                      const Spacer(),
                    ])))));
  }
}

// ═══════════════════════════════════════════════════════════
// HOME
// ═══════════════════════════════════════════════════════════
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;
  @override
  void initState() {
    super.initState();
    AppState().addListener(() {
      if (mounted) setState(() {});
    });
  }

  final _icons = [
    '🏠',
    '📿',
    '🕌',
    '📖',
    '📅',
    '❓',
    '✅',
    '🤲',
    '💬',
    '🎉',
    '🤖',
    '⚙️'
  ];
  List<String> get _labels {
    final l = AppState().lang;
    return l == 'ar'
        ? [
            'الرئيسية',
            'المسبحة',
            'الصلاة',
            'الأذكار',
            'التقويم',
            'مسابقة',
            'خيرية',
            'الدعاء',
            'تشجيع',
            'تكبيرات',
            'مساعد',
            'إعدادات'
          ]
        : l == 'fr'
            ? [
                'Accueil',
                'Misbaha',
                'Prière',
                'Adhkars',
                'Calendrier',
                'Quiz',
                'Actions',
                'Doua',
                'Boost',
                'Takbirs',
                'Assistant',
                'Paramètres'
              ]
            : [
                'Home',
                'Misbaha',
                'Prayer',
                'Dhikr',
                'Calendar',
                'Quiz',
                'Deeds',
                'Dua',
                'Boost',
                'Takbirs',
                'Assistant',
                'Settings'
              ];
  }

  // FIX 5: replaced IslamQAPage with IslamChatPage
  List<Widget> get _pages => [
        const HomePage(),
        const MisbahaPage(),
        const PrayerTimesPage(),
        const AdkarPage(),
        const HijriCalendarPage(),
        const QuizPage(),
        const GoodDeedsPage(),
        const DuaPage(),
        const EncouragePage(),
        const TakbirPage(),
        const IslamChatPage(),
        const SettingsPage()
      ];
  @override
  Widget build(BuildContext context) {
    final l = AppState().lang;
    return Directionality(
        textDirection: l == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: AnimatedBg(
                child: SafeArea(
                    child: Column(children: [
              _buildAppBar(),
              Expanded(child: _pages[_idx])
            ]))),
            bottomNavigationBar: _buildNav()));
  }

  Widget _buildAppBar() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          color: TC.getTheme(AppState().theme)[0].withOpacity(0.85),
          border: const Border(bottom: BorderSide(color: TC.border2))),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppState().appName,
              style: const TextStyle(
                  color: TC.gold, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(AppState().appSlogan,
              style: const TextStyle(
                  color: TC.text3, fontSize: 9, letterSpacing: 2))
        ]),
        const Spacer(),
        _LangSelector()
      ]));
  Widget _buildNav() => Container(
      decoration: BoxDecoration(
          color: TC.getTheme(AppState().theme)[0].withOpacity(0.95),
          border: const Border(top: BorderSide(color: TC.border))),
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
              children: List.generate(_pages.length, (i) {
            final sel = _idx == i;
            return GestureDetector(
                onTap: () => setState(() => _idx = i),
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 11, vertical: 10),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: sel ? TC.gold : Colors.transparent,
                                width: 2))),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(_icons[i], style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(_labels[i],
                          style: TextStyle(
                              color: sel ? TC.gold : TC.text3, fontSize: 9))
                    ])));
          }))));
}

// ═══════════════════════════════════════════════════════════
// HOME PAGE
// ═══════════════════════════════════════════════════════════
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppState();
    final l = s.lang;
    String welcome = s.userName.isEmpty
        ? (l == 'ar'
            ? 'أهلاً بك 🌙'
            : l == 'fr'
                ? 'Bienvenue 🌙'
                : 'Welcome 🌙')
        : (s.userGender == 'male'
            ? (l == 'ar'
                ? 'أهلاً بك ${s.userName} 🌙'
                : 'Welcome ${s.userName} 🌙')
            : (l == 'ar'
                ? 'أهلاً بكِ ${s.userName} 🌙'
                : 'Welcome ${s.userName} 🌙'));
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const SizedBox(height: 8),
          DomeWidget(height: 150),
          const SizedBox(height: 12),
          Text(s.appName,
              style: const TextStyle(
                  color: TC.gold, fontSize: 48, fontWeight: FontWeight.bold)),
          Text(s.appSlogan,
              style: const TextStyle(
                  color: TC.text3, fontSize: 11, letterSpacing: 3)),
          const SizedBox(height: 8),
          Text(welcome, style: const TextStyle(color: TC.gold2, fontSize: 16)),
          const SizedBox(height: 12),
          _OrnamentDivider(),
          const SizedBox(height: 14),
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: TC.gold.withOpacity(0.2))),
              child: Text(s.palestineDua,
                  style: const TextStyle(
                      color: Color(0xFFE8D5A3), fontSize: 14, height: 1.8),
                  textAlign: TextAlign.center)),
          const SizedBox(height: 18),
          GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.7,
              children: [
                _QCard(
                    icon: '📿',
                    label: l == 'ar'
                        ? 'المسبحة'
                        : l == 'fr'
                            ? 'Misbaha'
                            : 'Misbaha'),
                _QCard(
                    icon: '🕌',
                    label: l == 'ar'
                        ? 'الصلاة'
                        : l == 'fr'
                            ? 'Prière'
                            : 'Prayer'),
                _QCard(
                    icon: '📖',
                    label: l == 'ar'
                        ? 'الأذكار'
                        : l == 'fr'
                            ? 'Adhkars'
                            : 'Dhikr'),
                _QCard(
                    icon: '🤲',
                    label: l == 'ar'
                        ? 'الدعاء'
                        : l == 'fr'
                            ? 'Doua'
                            : 'Dua'),
              ]),
        ]));
  }
}

class _QCard extends StatelessWidget {
  final String icon, label;
  const _QCard({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => TaqwaCard(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: TC.text2, fontSize: 13))
      ]));
}

// ═══════════════════════════════════════════════════════════
// MISBAHA
// ═══════════════════════════════════════════════════════════
class MisbahaPage extends StatefulWidget {
  const MisbahaPage({super.key});
  @override
  State<MisbahaPage> createState() => _MisbahaPageState();
}

class _MisbahaPageState extends State<MisbahaPage>
    with TickerProviderStateMixin {
  final List<int> _counts = [0, 0, 0];
  int _cur = 0, _sets = 0;
  late AnimationController _ripple;
  late Animation<double> _rippleAnim;
  List<String> get _dhikr => AppState().lang == 'ar'
      ? ['سُبحانَ الله', 'الحمدُ لله', 'اللهُ أكبر']
      : ['Subhan Allah', 'Alhamdulillah', 'Allahu Akbar'];
  @override
  void initState() {
    super.initState();
    _ripple = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _rippleAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ripple, curve: Curves.easeOut));
    AppState().addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ripple.dispose();
    super.dispose();
  }

  void _tap() {
    if (_counts[_cur] >= 33) return;
    HapticFeedback.lightImpact();
    _ripple.forward(from: 0);
    setState(() {
      _counts[_cur]++;
    });
    if (_counts[_cur] == 33) {
      if (_cur < 2)
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) setState(() => _cur++);
        });
      else
        setState(() => _sets++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppState().lang;
    final c = _counts[_cur];
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TaqwaTitle(
              text: l == 'ar'
                  ? 'المسبحة الرقمية'
                  : l == 'fr'
                      ? 'Misbaha Numérique'
                      : 'Digital Misbaha'),
          const SizedBox(height: 16),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final sel = _cur == i;
                return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                        onTap: () => setState(() => _cur = i),
                        child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                                color: sel ? TC.gold : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: sel ? TC.gold : TC.border2)),
                            child: Text(_dhikr[i],
                                style: TextStyle(
                                    color: sel ? TC.bg : TC.text2,
                                    fontSize: 13)))));
              })),
          const SizedBox(height: 16),
          Text(_dhikr[_cur],
              style: const TextStyle(color: TC.text, fontSize: 22)),
          const SizedBox(height: 16),
          GestureDetector(
              onTap: _tap,
              child: AnimatedBuilder(
                  animation: _rippleAnim,
                  builder: (_, __) =>
                      Stack(alignment: Alignment.center, children: [
                        if (_ripple.isAnimating)
                          Opacity(
                              opacity: 1 - _rippleAnim.value,
                              child: Container(
                                  width: 200 + 60 * _rippleAnim.value,
                                  height: 200 + 60 * _rippleAnim.value,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: TC.gold.withOpacity(0.4),
                                          width: 2)))),
                        Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(colors: [
                                  TC.gold.withOpacity(0.15),
                                  TC.cardColor(AppState().theme)
                                ]),
                                border: Border.all(color: TC.border2, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                      color: TC.gold.withOpacity(0.12),
                                      blurRadius: 30,
                                      spreadRadius: 5)
                                ]),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('$c',
                                      style: const TextStyle(
                                          color: TC.gold,
                                          fontSize: 58,
                                          fontWeight: FontWeight.bold)),
                                  const Text('/ 33',
                                      style: TextStyle(
                                          color: TC.text3, fontSize: 14))
                                ])),
                      ]))),
          const SizedBox(height: 16),
          ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                  value: c / 33.0,
                  minHeight: 6,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(TC.gold))),
          const SizedBox(height: 12),
          Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: List.generate(
                  33,
                  (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < c ? TC.gold : Colors.transparent,
                          border:
                              Border.all(color: i < c ? TC.gold : TC.border),
                          boxShadow: i < c
                              ? [
                                  BoxShadow(
                                      color: TC.gold.withOpacity(0.4),
                                      blurRadius: 4)
                                ]
                              : null)))),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            TaqwaOutlineBtn(
                label: l == 'ar' ? 'إعادة' : 'Reset',
                onTap: () => setState(() => _counts[_cur] = 0)),
            const SizedBox(width: 12),
            TaqwaBtn(
                label: l == 'ar' ? 'التالي ›' : 'Next ›',
                onTap: () {
                  if (_cur < 2) setState(() => _cur++);
                })
          ]),
          const SizedBox(height: 20),
          GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                StatCard(
                    icon: '📿', label: 'Tasbih', value: '${_counts[0]}/33'),
                StatCard(icon: '🌿', label: 'Hamd', value: '${_counts[1]}/33'),
                StatCard(icon: '✨', label: 'Takbir', value: '${_counts[2]}/33'),
                StatCard(
                    icon: '🏆',
                    label: l == 'ar' ? 'دورات' : 'Sets',
                    value: '$_sets')
              ]),
          const SizedBox(height: 12),
          TaqwaOutlineBtn(
              label: l == 'ar'
                  ? 'إعادة الكل'
                  : l == 'fr'
                      ? 'Tout réinitialiser'
                      : 'Reset All',
              onTap: () => setState(() {
                    _counts.fillRange(0, 3, 0);
                    _cur = 0;
                    _sets = 0;
                  })),
        ]));
  }
}

// ═══════════════════════════════════════════════════════════
// PRAYER TIMES
// ═══════════════════════════════════════════════════════════
class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});
  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  Map<String, String> _times = {};
  String _cd = '00:00:00', _next = '', _loc = '';
  Timer? _timer;
  bool _loading = true;
  bool _adhanPlaying = false;
  String _adhanType = 'makki';
  AudioPlayer _audioPlayer = AudioPlayer();
  final _keys = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  final _icons = ['🌙', '🌄', '☀️', '⛅', '🌇', '🌃'];
  final _nameKeys = ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha'];
  List<String> get _names {
    final l = AppState().lang;
    if (l == 'fr') return ['Fajr', 'Lever', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    if (l == 'en')
      return ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    return ['الفجر', 'الشروق', 'الظهر', 'العصر', 'المغرب', 'العشاء'];
  }

  @override
  void initState() {
    super.initState();
    AppState().addListener(() {
      if (mounted) setState(() {});
    });
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioEl?.pause();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    double lat = 36.7, lng = 3.05;
    String loc = 'الجزائر العاصمة';
    try {
      final r = await http
          .get(Uri.parse('https://ipapi.co/json/'))
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) {
        final d = jsonDecode(r.body);
        lat = double.tryParse(d['latitude'].toString()) ?? 36.7;
        lng = double.tryParse(d['longitude'].toString()) ?? 3.05;
        loc = '${d['city'] ?? ''}, ${d['country_name'] ?? ''}';
      }
    } catch (_) {}
    try {
      final r = await http.get(Uri.parse(
          'https://api.aladhan.com/v1/timings?latitude=$lat&longitude=$lng&method=3&school=0'));
      final d = jsonDecode(r.body);
      if (d['code'] == 200) {
        setState(() {
          _times = (d['data']['timings'] as Map)
              .map((k, v) => MapEntry(k.toString(), v.toString()));
          _loc = loc;
          _loading = false;
        });
        _startTimer();
      }
    } catch (_) {
      setState(() {
        _times = {
          'Fajr': '05:12',
          'Sunrise': '06:42',
          'Dhuhr': '12:30',
          'Asr': '16:00',
          'Maghrib': '18:45',
          'Isha': '20:15'
        };
        _loc = 'الجزائر العاصمة';
        _loading = false;
      });
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
    _update();
  }

  void _update() {
    final now = DateTime.now();
    final ns = now.hour * 3600 + now.minute * 60 + now.second;
    for (int i = 0; i < _keys.length; i++) {
      final t = _times[_keys[i]] ?? '';
      if (t.isEmpty) continue;
      final p = t.substring(0, 5).split(':');
      if (p.length < 2) continue;
      final ps = int.parse(p[0]) * 3600 + int.parse(p[1]) * 60;
      if (ps > ns) {
        final diff = ps - ns;
        if (mounted)
          setState(() {
            _cd =
                '${(diff ~/ 3600).toString().padLeft(2, '0')}:${((diff % 3600) ~/ 60).toString().padLeft(2, '0')}:${(diff % 60).toString().padLeft(2, '0')}';
            _next = _names[i];
          });
        return;
      }
    }
    final ft = _times['Fajr'] ?? '';
    if (ft.isNotEmpty) {
      final p = ft.substring(0, 5).split(':');
      if (p.length >= 2) {
        final fs = int.parse(p[0]) * 3600 + int.parse(p[1]) * 60;
        final diff = 86400 - ns + fs;
        if (mounted)
          setState(() {
            _cd =
                '${(diff ~/ 3600).toString().padLeft(2, '0')}:${((diff % 3600) ~/ 60).toString().padLeft(2, '0')}:${(diff % 60).toString().padLeft(2, '0')}';
            _next = _names[0];
          });
      }
    }
  }

  int _nextIdx() {
    final nm = DateTime.now().hour * 60 + DateTime.now().minute;
    for (int i = 0; i < _keys.length; i++) {
      final t = _times[_keys[i]] ?? '';
      if (t.isEmpty) continue;
      final p = t.substring(0, 5).split(':');
      if (p.length < 2) continue;
      if (int.parse(p[0]) * 60 + int.parse(p[1]) > nm) return i;
    }
    return 0;
  }

  void _playAdhan() {
    _audioEl?.pause();
    final url = _adhanType == 'makki'
        ? 'https://www.islamcan.com/audio/adhan/azan1.mp3'
        : 'https://www.islamcan.com/audio/adhan/azan2.mp3';
    await _audioPlayer.play(UrlSource(url));
    setState(() => _adhanPlaying = true);
    _audioEl!.onEnded.listen((_) {
      if (mounted) setState(() => _adhanPlaying = false);
    });
  }

  void _stopAdhan() {
    _audioEl?.pause();
    _audioEl = null;
    setState(() => _adhanPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppState().lang;
    final ni = _nextIdx();
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TaqwaTitle(
              text: l == 'ar'
                  ? 'أوقات الصلاة'
                  : l == 'fr'
                      ? 'Heures de Prière'
                      : 'Prayer Times'),
          const SizedBox(height: 16),
          TaqwaCard(
              child: Column(children: [
            Text(
                '${l == 'ar' ? 'الصلاة القادمة' : l == 'fr' ? 'Prochaine' : 'Next'}: $_next',
                style: const TextStyle(color: TC.text2, fontSize: 13)),
            const SizedBox(height: 8),
            Text(_cd,
                style: const TextStyle(
                    color: TC.gold2, fontSize: 40, letterSpacing: 3))
          ])),
          const SizedBox(height: 14),
          if (_loading)
            const CircularProgressIndicator(color: TC.gold)
          else
            GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                itemCount: _keys.length,
                itemBuilder: (_, i) {
                  final isNext = i == ni;
                  final t = (_times[_keys[i]] ?? '--:--').substring(0, 5);
                  return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                          color: isNext
                              ? TC.gold.withOpacity(0.1)
                              : TC.cardColor(AppState().theme).withOpacity(0.8),
                          border:
                              Border.all(color: isNext ? TC.gold : TC.border),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: isNext
                              ? [
                                  BoxShadow(
                                      color: TC.gold.withOpacity(0.15),
                                      blurRadius: 12)
                                ]
                              : null),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_icons[i],
                                style: const TextStyle(fontSize: 18)),
                            if (isNext)
                              Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                      color: TC.gold,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Text(l == 'ar' ? 'التالية' : 'Next',
                                      style: const TextStyle(
                                          fontSize: 8,
                                          color: TC.bg,
                                          fontWeight: FontWeight.bold))),
                            Text(_names[i],
                                style: const TextStyle(
                                    color: TC.text, fontSize: 12)),
                            Text(t,
                                style: const TextStyle(
                                    color: TC.gold,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold))
                          ]));
                }),
          const SizedBox(height: 14),
          TaqwaCard(
              child: Column(children: [
            Text(
                l == 'ar'
                    ? 'اختر الأذان'
                    : l == 'fr'
                        ? 'Choisir l\'Adhan'
                        : 'Choose Adhan',
                style: const TextStyle(
                    color: TC.gold, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _AdhanTypeBtn(
                  label: l == 'ar'
                      ? 'الأذان المكي'
                      : l == 'fr'
                          ? 'Adhan Mecque'
                          : 'Makkah',
                  value: 'makki',
                  selected: _adhanType,
                  onTap: () => setState(() => _adhanType = 'makki')),
              const SizedBox(width: 12),
              _AdhanTypeBtn(
                  label: l == 'ar'
                      ? 'الأذان المدني'
                      : l == 'fr'
                          ? 'Adhan Médine'
                          : 'Madinah',
                  value: 'madani',
                  selected: _adhanType,
                  onTap: () => setState(() => _adhanType = 'madani')),
            ]),
            const SizedBox(height: 12),
            if (_adhanPlaying) ...[
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: TC.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔊', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                            l == 'ar'
                                ? 'الأذان يُقام...'
                                : l == 'fr'
                                    ? 'Adhan en cours...'
                                    : 'Adhan playing...',
                            style:
                                const TextStyle(color: TC.green2, fontSize: 13))
                      ])),
              const SizedBox(height: 8),
              TaqwaOutlineBtn(
                  label: l == 'ar' ? 'إيقاف' : 'Stop', onTap: _stopAdhan)
            ] else
              TaqwaBtn(
                  label:
                      '🔊 ${l == 'ar' ? 'الأذان' : l == 'fr' ? 'Adhan' : 'Adhan'}',
                  onTap: _playAdhan),
          ])),
          const SizedBox(height: 8),
          if (_loc.isNotEmpty)
            Text('📍 $_loc',
                style: const TextStyle(color: TC.text3, fontSize: 12)),
          TaqwaOutlineBtn(
              label:
                  '🔄 ${l == 'ar' ? 'تحديث' : l == 'fr' ? 'Actualiser' : 'Refresh'}',
              onTap: _load),
        ]));
  }
}

class _AdhanTypeBtn extends StatelessWidget {
  final String label, value, selected;
  final VoidCallback onTap;
  const _AdhanTypeBtn(
      {required this.label,
      required this.value,
      required this.selected,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    final sel = selected == value;
    return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                color: sel ? TC.gold.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: sel ? TC.gold : TC.border2, width: sel ? 2 : 1)),
            child: Column(children: [
              Text(sel ? '🕌' : '🕍', style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      color: sel ? TC.gold : TC.text2,
                      fontSize: 11,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal),
                  textAlign: TextAlign.center)
            ])));
  }
}

// ═══════════════════════════════════════════════════════════
// ADKAR
// ═══════════════════════════════════════════════════════════
class AdkarPage extends StatefulWidget {
  const AdkarPage({super.key});
  @override
  State<AdkarPage> createState() => _AdkarPageState();
}

class _AdkarPageState extends State<AdkarPage> {
  int _cat = 0, _idx = 0;
  bool _done = false;
  final _catKeys = ['morning', 'evening', 'night'];
  final _data = [
    [
      {
        'ar':
            'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
        'fr': 'Nous atteignons le matin et le royaume appartient à Allah.',
        'en': 'We have entered the morning and the kingdom belongs to Allah.',
        'count': 1
      },
      {
        'ar':
            'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ',
        'fr': 'Ô Allah, c\'est grâce à Toi que nous atteignons le matin.',
        'en': 'O Allah, with You we enter the morning.',
        'count': 1
      },
      {
        'ar': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
        'fr': 'Gloire à Allah et louange à Lui.',
        'en': 'Glory be to Allah and praise Him.',
        'count': 100
      },
      {
        'ar':
            'اللَّهُمَّ عَافِنِي فِي بَدَنِي اللَّهُمَّ عَافِنِي فِي سَمْعِي اللَّهُمَّ عَافِنِي فِي بَصَرِي',
        'fr': 'Ô Allah, préserve ma santé corporelle, mon ouïe et ma vue.',
        'en': 'O Allah, grant me health in my body, hearing and sight.',
        'count': 3
      },
      {
        'ar': 'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ',
        'fr': 'Allah me suffit. Je me confie à Lui.',
        'en': 'Allah is sufficient for me. I place my trust in Him.',
        'count': 7
      }
    ],
    [
      {
        'ar': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ',
        'fr': 'Nous atteignons le soir et le royaume appartient à Allah.',
        'en': 'We have entered the evening and the kingdom belongs to Allah.',
        'count': 1
      },
      {
        'ar': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
        'fr': 'Je cherche refuge dans les paroles parfaites d\'Allah.',
        'en': 'I seek refuge in the perfect words of Allah.',
        'count': 3
      },
      {
        'ar': 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ',
        'fr': 'Au nom d\'Allah, avec Lequel rien ne peut causer de mal.',
        'en': 'In the name of Allah, with Whose name nothing can cause harm.',
        'count': 3
      },
      {
        'ar': 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ',
        'fr': 'Ô Allah, Tu es mon Seigneur.',
        'en': 'O Allah, You are my Lord.',
        'count': 1
      }
    ],
    [
      {
        'ar': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
        'fr': 'En Ton nom, Ô Allah, je meurs et je vis.',
        'en': 'In Your name, O Allah, I die and I live.',
        'count': 1
      },
      {
        'ar': 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
        'fr': 'Ô Allah, protège-moi de Ton châtiment.',
        'en': 'O Allah, protect me from Your punishment.',
        'count': 3
      },
      {
        'ar': 'سُبْحَانَ اللَّهِ ٣٣ — الحَمدُ لِلَّهِ ٣٣ — اللَّهُ أَكْبَر ٣٤',
        'fr': 'Subhan Allah 33 — Alhamdulillah 33 — Allahu Akbar 34',
        'en': 'Subhan Allah 33 — Alhamdulillah 33 — Allahu Akbar 34',
        'count': 1
      },
      {
        'ar': 'اللَّهُمَّ أَسْلَمْتُ نَفْسِي إِلَيْكَ',
        'fr': 'Ô Allah, je me soumets à Toi.',
        'en': 'O Allah, I submit myself to You.',
        'count': 1
      }
    ],
  ];
  List<String> get _cats {
    final l = AppState().lang;
    if (l == 'fr') return ['🌅 Matin', '🌆 Soir', '🌙 Nuit'];
    if (l == 'en') return ['🌅 Morning', '🌆 Evening', '🌙 Night'];
    return ['🌅 الصباح', '🌆 المساء', '🌙 النوم'];
  }

  @override
  void initState() {
    super.initState();
    AppState().addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppState().lang;
    final list = _data[_cat];
    final item = list[_idx];
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TaqwaTitle(
              text: l == 'ar'
                  ? 'الأذكار اليومية'
                  : l == 'fr'
                      ? 'Adhkars Quotidiens'
                      : 'Daily Dhikr'),
          const SizedBox(height: 16),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: List.generate(3, (i) {
                final sel = _cat == i;
                return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
                        onTap: () => setState(() {
                              _cat = i;
                              _idx = 0;
                              _done = false;
                            }),
                        child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 9),
                            decoration: BoxDecoration(
                                color: sel ? TC.green : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: sel ? TC.green2 : TC.border)),
                            child: Text(_cats[i],
                                style: TextStyle(
                                    color: sel ? TC.text : TC.text2,
                                    fontSize: 13)))));
              }))),
          const SizedBox(height: 20),
          TaqwaCard(
              child: Column(children: [
            Text(item['ar'].toString(),
                style: const TextStyle(color: TC.text, fontSize: 20, height: 2),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl),
            if (l != 'ar') ...[
              const SizedBox(height: 8),
              Container(width: double.infinity, height: 1, color: TC.border),
              const SizedBox(height: 8),
              Text(item[l]?.toString() ?? '',
                  style: const TextStyle(
                      color: TC.text2, fontSize: 14, height: 1.7),
                  textAlign: TextAlign.center)
            ],
            const SizedBox(height: 8),
            Text('× ${item['count']}',
                style: const TextStyle(color: TC.gold, fontSize: 15)),
            const SizedBox(height: 12),
            ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                    value: _idx / (list.length - 1).toDouble().clamp(1, 100),
                    minHeight: 5,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(TC.gold))),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              IconButton(
                  onPressed: _idx > 0
                      ? () => setState(() {
                            _idx--;
                            _done = false;
                          })
                      : null,
                  icon: const Icon(Icons.chevron_left, color: TC.gold)),
              Text('${_idx + 1}/${list.length}',
                  style: const TextStyle(color: TC.text3, fontSize: 13)),
              IconButton(
                  onPressed: () {
                    if (_idx < list.length - 1)
                      setState(() {
                        _idx++;
                        _done = false;
                      });
                    else
                      setState(() => _done = true);
                  },
                  icon: const Icon(Icons.chevron_right, color: TC.gold))
            ]),
            if (_done)
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: TC.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                      l == 'ar'
                          ? '✨ أحسنتَ! أكملتَ الأذكار ✨'
                          : l == 'fr'
                              ? '✨ Bravo! Adhkars complétés ✨'
                              : '✨ Well done! Dhikr completed ✨',
                      style: const TextStyle(color: TC.green2, fontSize: 15),
                      textAlign: TextAlign.center)),
          ])),
        ]));
  }
}

// ═══════════════════════════════════════════════════════════
// FIX 2: HIJRI CALENDAR — correct algorithm + correct date
// ═══════════════════════════════════════════════════════════
class HijriCalendarPage extends StatefulWidget {
  const HijriCalendarPage({super.key});
  @override
  State<HijriCalendarPage> createState() => _HijriCalendarPageState();
}

class _HijriCalendarPageState extends State<HijriCalendarPage> {
  // Default: 15 Dhu Al-Qi'dah 1447 — الأحد (month index 10 = 0-based)
  int _year = 1447, _month = 10, _day = 15;
  bool _loading = true;
  final _months = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الثاني',
    'جمادى الأولى',
    'جمادى الثانية',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة'
  ];
  final _monthsFr = [
    'Mouharram',
    'Safar',
    'Rabi al-Awwal',
    'Rabi ath-Thani',
    'Joumada I',
    'Joumada II',
    'Rajab',
    'Chaban',
    'Ramadan',
    'Chawwal',
    'Dhou al-Qi\'da',
    'Dhou al-Hijja'
  ];
  final _monthsEn = [
    'Muharram',
    'Safar',
    'Rabi al-Awwal',
    'Rabi al-Thani',
    'Jumada I',
    'Jumada II',
    'Rajab',
    'Shaban',
    'Ramadan',
    'Shawwal',
    'Dhul Qadah',
    'Dhul Hijjah'
  ];
  final _events = [
    {'m': 0, 'd': 10, 'ar': 'عاشوراء', 'fr': 'Achoura', 'en': 'Ashura'},
    {'m': 2, 'd': 12, 'ar': 'المولد النبوي', 'fr': 'Mawlid', 'en': 'Mawlid'},
    {
      'm': 6,
      'd': 27,
      'ar': 'ليلة المعراج',
      'fr': 'Mi\'raj',
      'en': 'Isra Mi\'raj'
    },
    {'m': 8, 'd': 1, 'ar': 'أول رمضان', 'fr': 'Ramadan', 'en': 'Ramadan'},
    {
      'm': 8,
      'd': 27,
      'ar': 'ليلة القدر',
      'fr': 'Laylat al-Qadr',
      'en': 'Laylat al-Qadr'
    },
    {
      'm': 9,
      'd': 1,
      'ar': 'عيد الفطر',
      'fr': 'Aïd al-Fitr',
      'en': 'Eid al-Fitr'
    },
    {'m': 11, 'd': 9, 'ar': 'يوم عرفة', 'fr': 'Arafat', 'en': 'Day of Arafah'},
    {
      'm': 11,
      'd': 10,
      'ar': 'عيد الأضحى',
      'fr': 'Aïd al-Adha',
      'en': 'Eid al-Adha'
    }
  ];
  @override
  void initState() {
    super.initState();
    AppState().addListener(() {
      if (mounted) setState(() {});
    });
    _fetch();
  }

  String get _mName {
    final l = AppState().lang;
    if (l == 'fr') return _monthsFr[_month];
    if (l == 'en') return _monthsEn[_month];
    return _months[_month];
  }

  // Local Gregorian → Hijri algorithm (Umm Al-Qura based)
  Map<String, int> _gToH(DateTime d) {
    int y = d.year, m = d.month, day = d.day;
    double jd;
    if (m <= 2) {
      jd = (365.25 * (y - 1 + 4716)).floorToDouble() +
          (30.6001 * (m + 12 + 1)).floorToDouble() +
          day -
          1524.5;
    } else {
      jd = (365.25 * (y + 4716)).floorToDouble() +
          (30.6001 * (m + 1)).floorToDouble() +
          day -
          1524.5;
    }
    int jdi = jd.floor();
    int l2 = jdi - 1948440 + 10632;
    int n = ((l2 - 1) / 10631).floor();
    int l3 = l2 - 10631 * n + 354;
    int j = ((10985 - l3) / 5316).floor() * ((50 * l3) / 17719).floor() +
        (l3 / 5670).floor() * ((43 * l3) / 15238).floor();
    int l4 = l3 -
        ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() +
        29;
    int hm = ((24 * l4) / 709).floor();
    int hd = l4 - ((709 * hm) / 24).floor();
    int hy = 30 * n + j - 30;
    return {'y': hy, 'm': hm - 1, 'd': hd}; // month 0-indexed
  }

  // Calculate day-of-week for 1st of Hijri month (0=Sun)
  int _firstDayOfMonth(int hy, int hm1) {
    int jd = (11 * hy + 3) ~/ 30 +
        354 * hy +
        30 * hm1 -
        (hm1 - 1) ~/ 2 +
        1948440 -
        385;
    return (jd + 1) % 7;
  }

  Future<void> _fetch() async {
    // التاريخ مثبت يدوياً بناء على تأكيد المستخدم
    // اليوم الأحد 15 ذو القعدة 1447 = 2026-05-03
    setState(() {
      _year = 1447;
      _month = 10;
      _day = 15;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppState().lang;
    final me = _events.where((e) => e['m'] == _month).toList();
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TaqwaTitle(
              text: l == 'ar'
                  ? 'التقويم الهجري'
                  : l == 'fr'
                      ? 'Calendrier Hégirien'
                      : 'Hijri Calendar'),
          const SizedBox(height: 16),
          TaqwaCard(
              child: _loading
                  ? const CircularProgressIndicator(color: TC.gold)
                  : Column(children: [
                      Text('$_day $_mName $_year هـ',
                          style: const TextStyle(
                              color: TC.gold,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(DateTime.now().toString().substring(0, 10),
                          style: const TextStyle(color: TC.text3, fontSize: 12))
                    ])),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
                onPressed: () => setState(() {
                      _month--;
                      if (_month < 0) {
                        _month = 11;
                        _year--;
                      }
                    }),
                icon: const Icon(Icons.chevron_left, color: TC.gold)),
            Text('$_mName $_year',
                style: const TextStyle(color: TC.gold, fontSize: 16)),
            IconButton(
                onPressed: () => setState(() {
                      _month++;
                      if (_month > 11) {
                        _month = 0;
                        _year++;
                      }
                    }),
                icon: const Icon(Icons.chevron_right, color: TC.gold))
          ]),
          TaqwaCard(child: _buildGrid()),
          if (me.isNotEmpty) ...[
            const SizedBox(height: 12),
            TaqwaCard(
                child: Column(
                    children: me
                        .map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(children: [
                              Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle, color: TC.gold)),
                              const SizedBox(width: 10),
                              Text('${e['d']} — ${e[l] ?? e['ar']}',
                                  style: const TextStyle(
                                      color: TC.text2, fontSize: 13))
                            ])))
                        .toList()))
          ],
        ]));
  }

  Widget _buildGrid() {
    final l = AppState().lang;
    final days = l == 'ar'
        ? ['أح', 'إث', 'ثل', 'أر', 'خم', 'جم', 'سب']
        : ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    final ed = _events
        .where((e) => e['m'] == _month)
        .map((e) => e['d'] as int)
        .toSet();
    // FIX: dynamic offset using algorithm
    final offset = _firstDayOfMonth(_year, _month + 1);
    return Column(children: [
      Row(
          children: days
              .map((d) => Expanded(
                  child: Center(
                      child: Text(d,
                          style:
                              const TextStyle(color: TC.text3, fontSize: 11)))))
              .toList()),
      const SizedBox(height: 8),
      GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 3,
              mainAxisSpacing: 3),
          itemCount: 30 + offset,
          itemBuilder: (_, idx) {
            if (idx < offset) return const SizedBox();
            final day = idx - offset + 1;
            if (day > 30) return const SizedBox();
            final isToday = day == _day;
            final hasEvent = ed.contains(day);
            return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                    color: isToday ? TC.gold : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: hasEvent && !isToday
                        ? Border.all(color: TC.gold3)
                        : null),
                child: Center(
                    child: Text('$day',
                        style: TextStyle(
                            color: isToday ? TC.bg : TC.text,
                            fontSize: 12,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.normal))));
          }),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════
// FIX 3: QUIZ — 20 questions, 10 per cycle, new cycle button
// ═══════════════════════════════════════════════════════════
class QuizPage extends StatefulWidget {
  const QuizPage({super.key});
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  // 20 questions per language — first 10 = cycle A, last 10 = cycle B
  static const _allQ = {
    'ar': [
      // Cycle A
      {
        'q': 'كم عدد آيات سورة الفاتحة؟',
        'opts': ['٥', '٧', '٩', '٦'],
        'a': 1
      },
      {
        'q': 'ما اسم الصحابي الملقب بـ"سيف الإسلام"؟',
        'opts': ['عمر', 'خالد بن الوليد', 'علي', 'أبو بكر'],
        'a': 1
      },
      {
        'q': 'في أي شهر أُنزل القرآن الكريم؟',
        'opts': ['محرم', 'شعبان', 'رمضان', 'ذو الحجة'],
        'a': 2
      },
      {
        'q': 'ما عدد ركعات صلاة الفجر؟',
        'opts': ['٢', '٣', '٤', '١'],
        'a': 0
      },
      {
        'q': 'من هو أول الخلفاء الراشدين؟',
        'opts': ['عمر', 'علي', 'عثمان', 'أبو بكر'],
        'a': 3
      },
      {
        'q': 'كم عدد أركان الإسلام؟',
        'opts': ['٤', '٦', '٥', '٣'],
        'a': 2
      },
      {
        'q': 'ما اسم جبل نزول الوحي؟',
        'opts': ['عرفات', 'أُحد', 'حراء', 'ثور'],
        'a': 2
      },
      {
        'q': 'كم عدد سور القرآن؟',
        'opts': ['١٢٠', '١١٤', '١١٦', '١١٠'],
        'a': 1
      },
      {
        'q': 'ما هي القبلة الأولى للمسلمين؟',
        'opts': ['مكة', 'بيت المقدس', 'المدينة', 'الكوفة'],
        'a': 1
      },
      {
        'q': 'في أي مدينة وُلد النبي ﷺ؟',
        'opts': ['المدينة', 'الطائف', 'مكة', 'القدس'],
        'a': 2
      },
      // Cycle B
      {
        'q': 'ما اسم والدة النبي ﷺ؟',
        'opts': ['خديجة', 'فاطمة', 'آمنة', 'هالة'],
        'a': 2
      },
      {
        'q': 'كم سنة عاش النبي ﷺ؟',
        'opts': ['٦٠', '٦٣', '٦٥', '٧٠'],
        'a': 1
      },
      {
        'q': 'ما أول سورة نزلت من القرآن؟',
        'opts': ['الفاتحة', 'البقرة', 'العلق', 'المدثر'],
        'a': 2
      },
      {
        'q': 'كم عدد أنبياء الإسلام المذكورين في القرآن؟',
        'opts': ['٢٠', '٢٥', '٣٠', '١٨'],
        'a': 1
      },
      {
        'q': 'ما اسم زوجة النبي ﷺ الأولى؟',
        'opts': ['عائشة', 'حفصة', 'خديجة', 'فاطمة'],
        'a': 2
      },
      {
        'q': 'كم عدد ركعات صلاة الظهر؟',
        'opts': ['٢', '٣', '٤', '٥'],
        'a': 2
      },
      {
        'q': 'ما معنى كلمة "الإسلام"؟',
        'opts': ['السلام', 'الاستسلام لله', 'الرحمة', 'الإيمان'],
        'a': 1
      },
      {
        'q': 'أين تقع الكعبة المشرفة؟',
        'opts': ['المدينة المنورة', 'مكة المكرمة', 'القدس', 'الطائف'],
        'a': 1
      },
      {
        'q': 'ما اسم الملك الموكل بالوحي؟',
        'opts': ['إسرافيل', 'ميكائيل', 'جبريل', 'عزرائيل'],
        'a': 2
      },
      {
        'q': 'كم مرة يُصلي المسلم في اليوم؟',
        'opts': ['٣', '٤', '٥', '٦'],
        'a': 2
      },
    ],
    'fr': [
      // Cycle A
      {
        'q': 'Combien de fois les musulmans prient-ils par jour?',
        'opts': ['3', '4', '5', '6'],
        'a': 2
      },
      {
        'q': 'Quelle est la première sourate du Coran?',
        'opts': ['Al-Baqara', 'Al-Fatiha', 'Al-Ikhlas', 'An-Nas'],
        'a': 1
      },
      {
        'q': 'Quel est le mois du jeûne islamique?',
        'opts': ['Rajab', 'Chaban', 'Ramadan', 'Mouharram'],
        'a': 2
      },
      {
        'q': 'Quelle ville est la plus sacrée en Islam?',
        'opts': ['Médine', 'Jérusalem', 'La Mecque', 'Baghdad'],
        'a': 2
      },
      {
        'q': 'Combien de piliers a l\'Islam?',
        'opts': ['4', '5', '6', '3'],
        'a': 1
      },
      {
        'q': 'Quel ange a apporté la révélation?',
        'opts': ['Israfil', 'Mikail', 'Jibril', 'Izra\'il'],
        'a': 2
      },
      {
        'q': 'Combien de sourates contient le Coran?',
        'opts': ['110', '120', '114', '100'],
        'a': 2
      },
      {
        'q': 'Dans quelle ville le Prophète ﷺ est-il né?',
        'opts': ['Médine', 'Taïf', 'La Mecque', 'Jérusalem'],
        'a': 2
      },
      {
        'q': 'Quel est le nom de la femme du Prophète ﷺ?',
        'opts': ['Aïcha', 'Hafsa', 'Khadija', 'Fatima'],
        'a': 2
      },
      {
        'q': 'Combien d\'années a vécu le Prophète ﷺ?',
        'opts': ['60', '63', '65', '70'],
        'a': 1
      },
      // Cycle B
      {
        'q': 'Qu\'est-ce que la Zakat?',
        'opts': ['Le jeûne', 'La prière', 'L\'aumône', 'Le pèlerinage'],
        'a': 2
      },
      {
        'q': 'Quel est le livre sacré de l\'Islam?',
        'opts': ['La Bible', 'La Torah', 'Le Coran', 'Le Psaume'],
        'a': 2
      },
      {
        'q': 'Quelle sourate est le cœur du Coran?',
        'opts': ['Al-Fatiha', 'Al-Ikhlas', 'Ya-Sin', 'Al-Baqara'],
        'a': 2
      },
      {
        'q': 'Où se trouve la Kaaba?',
        'opts': ['Médine', 'Jérusalem', 'La Mecque', 'Taïf'],
        'a': 2
      },
      {
        'q': 'Combien de rakats pour Fajr?',
        'opts': ['1', '2', '3', '4'],
        'a': 1
      },
      {
        'q': 'Quel est le premier pilier de l\'Islam?',
        'opts': ['La prière', 'Le jeûne', 'La Shahada', 'La zakat'],
        'a': 2
      },
      {
        'q': 'Qui est le premier calife en Islam?',
        'opts': ['Omar', 'Ali', 'Othman', 'Abu Bakr'],
        'a': 3
      },
      {
        'q': 'Quel est le nom du père du Prophète ﷺ?',
        'opts': ['Abdullah', 'Abu Talib', 'Hamza', 'Abbas'],
        'a': 0
      },
      {
        'q': 'Dans quel mois le Coran a-t-il été révélé?',
        'opts': ['Rajab', 'Chaban', 'Ramadan', 'Mouharram'],
        'a': 2
      },
      {
        'q': 'Combien de versets dans Al-Fatiha?',
        'opts': ['5', '6', '7', '8'],
        'a': 2
      },
    ],
    'en': [
      // Cycle A
      {
        'q': 'How many times do Muslims pray per day?',
        'opts': ['3', '4', '5', '6'],
        'a': 2
      },
      {
        'q': 'What is the first chapter of the Quran?',
        'opts': ['Al-Baqara', 'Al-Fatiha', 'Al-Ikhlas', 'An-Nas'],
        'a': 1
      },
      {
        'q': 'Which month is the month of fasting?',
        'opts': ['Rajab', 'Shaban', 'Ramadan', 'Muharram'],
        'a': 2
      },
      {
        'q': 'What is the holiest city in Islam?',
        'opts': ['Medina', 'Jerusalem', 'Mecca', 'Baghdad'],
        'a': 2
      },
      {
        'q': 'How many pillars does Islam have?',
        'opts': ['4', '5', '6', '3'],
        'a': 1
      },
      {
        'q': 'Which angel brought revelation?',
        'opts': ['Israfil', 'Mikail', 'Jibril', 'Izrail'],
        'a': 2
      },
      {
        'q': 'How many surahs in the Quran?',
        'opts': ['110', '120', '114', '100'],
        'a': 2
      },
      {
        'q': 'Where was the Prophet ﷺ born?',
        'opts': ['Medina', 'Taif', 'Mecca', 'Jerusalem'],
        'a': 2
      },
      {
        'q': 'What is the name of the Prophet\'s first wife?',
        'opts': ['Aisha', 'Hafsa', 'Khadijah', 'Fatima'],
        'a': 2
      },
      {
        'q': 'How old was the Prophet ﷺ when he died?',
        'opts': ['60', '63', '65', '70'],
        'a': 1
      },
      // Cycle B
      {
        'q': 'What is Zakat?',
        'opts': ['Fasting', 'Prayer', 'Charity', 'Pilgrimage'],
        'a': 2
      },
      {
        'q': 'What is the holy book of Islam?',
        'opts': ['Bible', 'Torah', 'Quran', 'Psalms'],
        'a': 2
      },
      {
        'q': 'Which surah is the heart of the Quran?',
        'opts': ['Al-Fatiha', 'Al-Ikhlas', 'Ya-Sin', 'Al-Baqarah'],
        'a': 2
      },
      {
        'q': 'Where is the Kaaba located?',
        'opts': ['Medina', 'Jerusalem', 'Mecca', 'Taif'],
        'a': 2
      },
      {
        'q': 'How many rakats does Fajr have?',
        'opts': ['1', '2', '3', '4'],
        'a': 1
      },
      {
        'q': 'What is the first pillar of Islam?',
        'opts': ['Prayer', 'Fasting', 'Shahada', 'Zakat'],
        'a': 2
      },
      {
        'q': 'Who was the first caliph of Islam?',
        'opts': ['Omar', 'Ali', 'Uthman', 'Abu Bakr'],
        'a': 3
      },
      {
        'q': 'What is the name of the Prophet\'s father?',
        'opts': ['Abdullah', 'Abu Talib', 'Hamza', 'Abbas'],
        'a': 0
      },
      {
        'q': 'In which month was the Quran revealed?',
        'opts': ['Rajab', 'Shaban', 'Ramadan', 'Muharram'],
        'a': 2
      },
      {
        'q': 'How many verses does Al-Fatiha have?',
        'opts': ['5', '6', '7', '8'],
        'a': 2
      },
    ],
  };

  late List<Map<String, dynamic>> _q;
  int _idx = 0, _correct = 0, _wrong = 0, _cycle = 0;
  int? _sel;
  bool _answered = false, _finished = false;
  String _lastLang = '';

  @override
  void initState() {
    super.initState();
    AppState().addListener(() {
      if (mounted) setState(() {});
    });
    _shuffle();
  }

  void _shuffle() {
    _lastLang = AppState().lang;
    final all = (_allQ[_lastLang] ?? _allQ['ar']!)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    // Pick 10 questions based on current cycle
    final start = (_cycle % 2) * 10;
    _q = [...all.sublist(start, start + 10)]..shuffle(Random());
    _idx = 0;
    _correct = 0;
    _wrong = 0;
    _sel = null;
    _answered = false;
    _finished = false;
  }

  void _answer(int i) {
    if (_answered) return;
    setState(() {
      _sel = i;
      _answered = true;
      if (_q[_idx]['a'] == i)
        _correct++;
      else
        _wrong++;
    });
  }

  void _next() {
    if (_idx < _q.length - 1)
      setState(() {
        _idx++;
        _sel = null;
        _answered = false;
      });
    else
      setState(() => _finished = true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppState().lang;
    if (l != _lastLang) Future.microtask(() => setState(_shuffle));
    final q = _q[_idx];
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TaqwaTitle(
              text: l == 'ar'
                  ? 'مسابقة إسلامية'
                  : l == 'fr'
                      ? 'Quiz Islamique'
                      : 'Islamic Quiz'),
          const SizedBox(height: 8),
          // Cycle indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                color: TC.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: TC.border2)),
            child: Text(
                l == 'ar'
                    ? 'الدورة ${_cycle + 1}'
                    : l == 'fr'
                        ? 'Cycle ${_cycle + 1}'
                        : 'Cycle ${_cycle + 1}',
                style: const TextStyle(color: TC.gold2, fontSize: 12)),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${l == 'ar' ? 'سؤال' : 'Q'} ${_idx + 1}/${_q.length}',
                style: const TextStyle(color: TC.text3)),
            Row(children: [
              _Badge('✅', '$_correct'),
              const SizedBox(width: 8),
              _Badge('❌', '$_wrong')
            ])
          ]),
          const SizedBox(height: 16),
          if (_finished)
            TaqwaCard(
                child: Column(children: [
              const Text('🏆', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                  l == 'ar'
                      ? 'انتهت المسابقة!'
                      : l == 'fr'
                          ? 'Quiz terminé!'
                          : 'Quiz finished!',
                  style: const TextStyle(color: TC.gold, fontSize: 22)),
              const SizedBox(height: 8),
              Text('$_correct/${_q.length}',
                  style: const TextStyle(color: TC.text2, fontSize: 16)),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TaqwaBtn(
                    label: l == 'ar'
                        ? '🔄 إعادة'
                        : l == 'fr'
                            ? '🔄 Recommencer'
                            : '🔄 Restart',
                    onTap: () => setState(_shuffle)),
                const SizedBox(width: 10),
                // New cycle button
                TaqwaOutlineBtn(
                    label: l == 'ar'
                        ? 'دورة جديدة ›'
                        : l == 'fr'
                            ? 'Cycle suivant ›'
                            : 'Next cycle ›',
                    onTap: () {
                      setState(() {
                        _cycle = (_cycle + 1) % 2;
                        _shuffle();
                      });
                    }),
              ]),
            ]))
          else
            TaqwaCard(
                child: Column(children: [
              Text(q['q'].toString(),
                  style: const TextStyle(
                      color: TC.text, fontSize: 18, height: 1.7),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl),
              const SizedBox(height: 20),
              ...List.generate((q['opts'] as List).length, (i) {
                Color bg = TC.card2Color(AppState().theme);
                Color border = TC.border;
                Color tc2 = TC.text;
                if (_answered) {
                  if (i == q['a']) {
                    bg = const Color(0x1A2DB87A);
                    border = const Color(0xFF2DB87A);
                    tc2 = const Color(0xFF2DB87A);
                  } else if (i == _sel) {
                    bg = const Color(0x0DE05C5C);
                    border = const Color(0xFFE05C5C);
                    tc2 = const Color(0xFFE05C5C);
                  }
                }
                return GestureDetector(
                    onTap: () => _answer(i),
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: border)),
                        child: Text(q['opts'][i].toString(),
                            style: TextStyle(color: tc2, fontSize: 16),
                            textDirection: TextDirection.rtl)));
              }),
              if (_answered) ...[
                const SizedBox(height: 12),
                TaqwaBtn(
                    label: l == 'ar'
                        ? 'التالي ›'
                        : l == 'fr'
                            ? 'Suivant ›'
                            : 'Next ›',
                    onTap: _next)
              ],
            ])),
        ]));
  }
}

class _Badge extends StatelessWidget {
  final String icon, val;
  const _Badge(this.icon, this.val);
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
          color: TC.card2Color(AppState().theme),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: TC.border)),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(val,
            style: const TextStyle(color: TC.gold, fontWeight: FontWeight.bold))
      ]));
}

// ═══════════════════════════════════════════════════════════
// GOOD DEEDS
// ═══════════════════════════════════════════════════════════
class GoodDeedsPage extends StatefulWidget {
  const GoodDeedsPage({super.key});
  @override
  State<GoodDeedsPage> createState() => _GoodDeedsPageState();
}

class _GoodDeedsPageState extends State<GoodDeedsPage> {
  final _def = [
    {
      'i': '🌅',
      'ar': 'صلاة الفجر في وقتها',
      'fr': 'Prière Fajr à l\'heure',
      'en': 'Pray Fajr on time'
    },
    {
      'i': '📖',
      'ar': 'قراءة القرآن',
      'fr': 'Lire le Coran',
      'en': 'Read the Quran'
    },
    {
      'i': '🌞',
      'ar': 'أذكار الصباح',
      'fr': 'Adhkars du matin',
      'en': 'Morning adhkar'
    },
    {
      'i': '🌆',
      'ar': 'أذكار المساء',
      'fr': 'Adhkars du soir',
      'en': 'Evening adhkar'
    },
    {
      'i': '🤝',
      'ar': 'مساعدة شخص محتاج',
      'fr': 'Aider quelqu\'un',
      'en': 'Help someone'
    },
    {'i': '💛', 'ar': 'التصدق', 'fr': 'Donner l\'aumône', 'en': 'Give charity'},
    {
      'i': '😊',
      'ar': 'إدخال السرور على مسلم',
      'fr': 'Réjouir un musulman',
      'en': 'Make someone happy'
    },
    {
      'i': '📞',
      'ar': 'صلة الرحم',
      'fr': 'Liens familiaux',
      'en': 'Family ties'
    },
    {
      'i': '🛡️',
      'ar': 'تجنب الغيبة',
      'fr': 'Éviter la médisance',
      'en': 'Avoid backbiting'
    },
    {
      'i': '🌙',
      'ar': 'صلاة الليل',
      'fr': 'Prière de nuit',
      'en': 'Night prayer'
    },
    {
      'i': '🌿',
      'ar': 'الاستغفار ١٠٠ مرة',
      'fr': '100 fois Istighfar',
      'en': '100x Istighfar'
    },
    {
      'i': '🍽️',
      'ar': 'إطعام مسكين',
      'fr': 'Nourrir un pauvre',
      'en': 'Feed the poor'
    }
  ];
  List<Map<String, String>> _custom = [];
  late List<bool> _done;
  final _ctrl = TextEditingController();
  String _emoji = '⭐';
  final _emojis = [
    '⭐',
    '🌸',
    '💎',
    '🌺',
    '🎯',
    '📝',
    '🏃',
    '💪',
    '🎁',
    '🌍',
    '❤️',
    '🙏'
  ];
  List<Map<String, String>> get _all => [..._def, ..._custom];
  @override
  void initState() {
    super.initState();
    AppState().addListener(() {
      if (mounted) setState(() {});
    });
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final cr = p.getStringList('custom_deeds') ?? [];
    _custom = cr.map((e) {
      final pts = e.split('||');
      return {'i': pts[0], 'ar': pts[1], 'fr': pts[1], 'en': pts[1]};
    }).toList();
    _done = List.filled(_all.length, false);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (p.getString('deeds_date') == today) {
      final s = p.getStringList('deeds_state') ?? [];
      if (s.length == _all.length) _done = s.map((e) => e == '1').toList();
    }
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
        'deeds_date', DateTime.now().toIso8601String().substring(0, 10));
    await p.setStringList(
        'deeds_state', _done.map((e) => e ? '1' : '0').toList());
  }

  Future<void> _saveCustom() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(
        'custom_deeds', _custom.map((d) => '${d['i']}||${d['ar']}').toList());
  }

  void _toggle(int i) {
    HapticFeedback.selectionClick();
    setState(() => _done[i] = !_done[i]);
    _save();
  }

  void _showAdd() {
    showDialog(
        context: context,
        builder: (_) => StatefulBuilder(
            builder: (ctx, setS) => Directionality(
                textDirection: AppState().lang == 'ar'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: AlertDialog(
                    backgroundColor: TC.card2Color(AppState().theme),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: TC.border2)),
                    title: Text(
                        AppState().lang == 'ar' ? 'إضافة عمل خير' : 'Add deed',
                        style: const TextStyle(color: TC.gold)),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _emojis
                              .map((e) => GestureDetector(
                                  onTap: () => setS(() => _emoji = e),
                                  child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: _emoji == e
                                              ? TC.gold.withOpacity(0.2)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: _emoji == e
                                                  ? TC.gold
                                                  : TC.border)),
                                      child: Center(
                                          child: Text(e,
                                              style: const TextStyle(
                                                  fontSize: 20))))))
                              .toList()),
                      const SizedBox(height: 16),
                      TextField(
                          controller: _ctrl,
                          style: const TextStyle(color: TC.text),
                          textDirection: TextDirection.rtl,
                          decoration: InputDecoration(
                              hintText: AppState().lang == 'ar'
                                  ? 'اكتبي العمل هنا...'
                                  : 'Write the deed...',
                              hintStyle: const TextStyle(color: TC.text3),
                              filled: true,
                              fillColor: Colors.black26,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: TC.border)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: TC.gold))))
                    ]),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                              AppState().lang == 'ar' ? 'إلغاء' : 'Cancel',
                              style: const TextStyle(color: TC.text3))),
                      ElevatedButton(
                          onPressed: () {
                            if (_ctrl.text.trim().isEmpty) return;
                            setState(() {
                              _custom.add({
                                'i': _emoji,
                                'ar': _ctrl.text.trim(),
                                'fr': _ctrl.text.trim(),
                                'en': _ctrl.text.trim()
                              });
                              _done = List.filled(_all.length, false);
                              _ctrl.clear();
                            });
                            _saveCustom();
                            _save();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: TC.gold,
                              foregroundColor: TC.bg,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20))),
                          child:
                              Text(AppState().lang == 'ar' ? 'إضافة' : 'Add'))
                    ]))));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppState().lang;
    final count = _done.where((e) => e).length;
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TaqwaTitle(
              text: l == 'ar'
                  ? 'أعمال خيرية يومية'
                  : l == 'fr'
                      ? 'Bonnes Actions'
                      : 'Good Deeds'),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                        value: _all.isEmpty ? 0 : count / _all.length,
                        minHeight: 8,
                        backgroundColor: Colors.white12,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(TC.green2)))),
            const SizedBox(width: 12),
            Text('$count/${_all.length}',
                style: const TextStyle(color: TC.text2))
          ]),
          const SizedBox(height: 16),
          ..._all.asMap().entries.map((e) {
            final i = e.key;
            final d = e.value;
            return GestureDetector(
                onTap: () => _toggle(i),
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: _done[i]
                            ? TC.green.withOpacity(0.15)
                            : TC.cardColor(AppState().theme).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _done[i] ? TC.green2 : TC.border)),
                    child: Row(children: [
                      AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _done[i] ? TC.green2 : Colors.transparent,
                              border: Border.all(
                                  color: _done[i] ? TC.green2 : TC.text3)),
                          child: _done[i]
                              ? const Icon(Icons.check,
                                  size: 16, color: Colors.white)
                              : null),
                      const SizedBox(width: 12),
                      Text(d['i']!, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(d[l] ?? d['ar']!,
                              style: const TextStyle(
                                  color: TC.text, fontSize: 14))),
                      if (i >= _def.length)
                        GestureDetector(
                            onTap: () {
                              setState(() {
                                _custom.removeAt(i - _def.length);
                                _done = List.filled(_all.length, false);
                              });
                              _saveCustom();
                              _save();
                            },
                            child: const Icon(Icons.close,
                                color: TC.text3, size: 18))
                    ])));
          }),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            TaqwaBtn(
                label: l == 'ar'
                    ? '+ إضافة عمل'
                    : l == 'fr'
                        ? '+ Ajouter'
                        : '+ Add',
                onTap: _showAdd),
            const SizedBox(width: 12),
            TaqwaOutlineBtn(
                label: l == 'ar' ? 'إعادة' : 'Reset',
                onTap: () {
                  setState(() => _done = List.filled(_all.length, false));
                  _save();
                })
          ]),
        ]));
  }
}

// ═══════════════════════════════════════════════════════════
// DUA
// ═══════════════════════════════════════════════════════════
class DuaPage extends StatefulWidget {
  const DuaPage({super.key});
  @override
  State<DuaPage> createState() => _DuaPageState();
}

class _DuaPageState extends State<DuaPage> {
  int? _sel;
  final _duas = [
    {
      'cat': {'ar': 'استفتاح', 'fr': 'Ouverture', 'en': 'Opening'},
      'ar':
          'اللَّهُمَّ بَاعِدْ بَيْنِي وَبَيْنَ خَطَايَايَ كَمَا بَاعَدْتَ بَيْنَ الْمَشْرِقِ وَالْمَغْرِبِ',
      'fr':
          'Ô Allah, éloigne-moi de mes fautes comme Tu as éloigné l\'Est de l\'Ouest.',
      'en':
          'O Allah, put distance between me and my sins as You put distance between East and West.'
    },
    {
      'cat': {'ar': 'رزق', 'fr': 'Subsistance', 'en': 'Rizq'},
      'ar':
          'اللَّهُمَّ اكْفِنِي بِحَلاَلِكَ عَنْ حَرَامِكَ وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
      'fr': 'Ô Allah, préserve-moi par le licite de l\'illicite.',
      'en': 'O Allah, suffice me with what You have made lawful.'
    },
    {
      'cat': {'ar': 'هداية', 'fr': 'Guidée', 'en': 'Guidance'},
      'ar': 'اللَّهُمَّ اهْدِنِي لِأَحْسَنِ الْأَعْمَالِ وَالْأَخْلاقِ',
      'fr': 'Ô Allah, guide-moi vers les meilleures actions.',
      'en': 'O Allah, guide me to the best of deeds and character.'
    },
    {
      'cat': {'ar': 'حماية', 'fr': 'Protection', 'en': 'Protection'},
      'ar':
          'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ وَالْعَجْزِ وَالْكَسَلِ',
      'fr':
          'Ô Allah, je cherche refuge en Toi contre l\'anxiété et la tristesse.',
      'en': 'O Allah, I seek refuge in You from worry, grief and incapacity.'
    },
    {
      'cat': {'ar': 'والدين', 'fr': 'Parents', 'en': 'Parents'},
      'ar':
          'رَبِّ اغْفِرْ لِي وَلِوَالِدَيَّ وَارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
      'fr': 'Seigneur, pardonne-moi ainsi qu\'à mes parents.',
      'en': 'My Lord, forgive me and my parents and have mercy upon them.'
    },
    {
      'cat': {'ar': 'علم', 'fr': 'Savoir', 'en': 'Knowledge'},
      'ar': 'رَبِّ زِدْنِي عِلْمًا',
      'fr': 'Seigneur, accrois mon savoir.',
      'en': 'My Lord, increase me in knowledge.'
    },
    {
      'cat': {'ar': 'قلب', 'fr': 'Cœur', 'en': 'Heart'},
      'ar': 'يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ',
      'fr': 'Ô Celui qui fait chavirer les cœurs, affermis mon cœur.',
      'en': 'O Turner of hearts, keep my heart firm upon Your religion.'
    },
    {
      'cat': {'ar': 'جنة', 'fr': 'Paradis', 'en': 'Paradise'},
      'ar':
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْجَنَّةَ وَمَا قَرَّبَ إِلَيْهَا مِنْ قَوْلٍ أَوْ عَمَلٍ',
      'fr': 'Ô Allah, je Te demande le Paradis et tout ce qui m\'en rapproche.',
      'en':
          'O Allah, I ask You for Paradise and whatever brings me closer to it.'
    }
  ];
  @override
  void initState() {
    super.initState();
    AppState().addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppState().lang;
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TaqwaTitle(
              text: l == 'ar'
                  ? 'الأدعية المأثورة'
                  : l == 'fr'
                      ? 'Douas'
                      : 'Duas'),
          const SizedBox(height: 16),
          if (_sel != null) ...[
            TaqwaCard(
                child: Column(children: [
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                      color: TC.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: TC.gold3)),
                  child: Text(
                      (_duas[_sel!]['cat'] as Map)[l] ??
                          (_duas[_sel!]['cat'] as Map)['ar'],
                      style: const TextStyle(color: TC.gold3, fontSize: 12))),
              const SizedBox(height: 16),
              Text(_duas[_sel!]['ar'] as String,
                  style:
                      const TextStyle(color: TC.text, fontSize: 20, height: 2),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl),
              if (l != 'ar') ...[
                const SizedBox(height: 8),
                Container(width: double.infinity, height: 1, color: TC.border),
                const SizedBox(height: 8),
                Text(_duas[_sel!][l] as String? ?? '',
                    style: const TextStyle(
                        color: TC.text2, fontSize: 14, height: 1.7),
                    textAlign: TextAlign.center)
              ],
              const SizedBox(height: 12),
              TextButton(
                  onPressed: () => setState(() => _sel = null),
                  child: Text(l == 'ar' ? '← العودة' : '← Back',
                      style: const TextStyle(color: TC.gold)))
            ])),
            const SizedBox(height: 16)
          ],
          ..._duas.asMap().entries.map((e) {
            final i = e.key;
            final d = e.value;
            final sel = _sel == i;
            return GestureDetector(
                onTap: () => setState(() => _sel = i),
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: sel
                            ? TC.gold.withOpacity(0.07)
                            : TC.cardColor(AppState().theme).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: sel ? TC.gold3 : TC.border)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text((d['cat'] as Map)[l] ?? '',
                              style: const TextStyle(
                                  color: TC.gold3, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(
                              (d['ar'] as String).length > 80
                                  ? '${(d['ar'] as String).substring(0, 80)}…'
                                  : d['ar'] as String,
                              style: const TextStyle(
                                  color: TC.text, fontSize: 14, height: 1.7),
                              textDirection: TextDirection.rtl)
                        ])));
          })
        ]));
  }
}

// ═══════════════════════════════════════════════════════════
// ENCOURAGE
// ═══════════════════════════════════════════════════════════
class EncouragePage extends StatefulWidget {
  const EncouragePage({super.key});
  @override
  State<EncouragePage> createState() => _EncouragePageState();
}

class _EncouragePageState extends State<EncouragePage>
    with SingleTickerProviderStateMixin {
  static const _msgsF = {
    'ar': [
      '🌟 أنتِ قادرة! كل يوم تبدئين فيه هو انتصار جديد!',
      '💪 تذكري أن الله مع الصابرين. خطوة تلو الأخرى!',
      '🌸 أنتِ أقوى مما تظنين! الفجر يأتي بعد أحلك ليلة.',
      '✨ أنتِ مميزة وفريدة! مسيرتكِ الخاصة هي الأجمل.',
      '🤲 اللهم اشرح صدرها ويسر أمرها وبارك في حياتها.',
      '🌙 أنتِ نجمة تضيء حياة من حولكِ!',
      '💎 صعوباتكِ اليوم تصنع قوتكِ غداً!',
      '🌺 ابتسامتكِ صدقة ونيتكِ الطيبة عبادة!',
      '🎯 الله يعوض أكثر مما تتخيلين!',
      '🌈 صبركِ سيُكلَّل بأجمل النتائج إن شاء الله!'
    ],
    'fr': [
      '🌟 Tu es capable! Chaque jour est une nouvelle victoire!',
      '💪 Allah est avec les patients!',
      '🌸 Tu es plus forte que tu ne le penses!',
      '✨ Tu es spéciale et unique!',
      '🤲 Que Allah te bénisse.',
      '🌙 Tu es une étoile!',
      '💎 Tes difficultés construisent ta force!',
      '🌺 Ton sourire est une aumône!',
      '🎯 Allah récompense généreusement!',
      '🌈 Ta patience sera récompensée!'
    ],
    'en': [
      '🌟 You can do it!',
      '💪 Allah is with the patient!',
      '🌸 You\'re stronger than you think!',
      '✨ You are special and unique!',
      '🤲 May Allah bless you.',
      '🌙 You are a shining star!',
      '💎 Difficulties build your strength!',
      '🌺 Your smile is charity!',
      '🎯 Allah rewards generously!',
      '🌈 Your patience will be rewarded!'
    ]
  };
  static const _msgsM = {
    'ar': [
      '🌟 أنتَ قادر! كل يوم تبدأ فيه هو انتصار جديد!',
      '💪 تذكر أن الله مع الصابرين. خطوة تلو الأخرى!',
      '🌸 أنتَ أقوى مما تظن! الفجر يأتي بعد أحلك ليلة.',
      '✨ أنتَ مميز وفريد! مسيرتكَ الخاصة هي الأجمل.',
      '🤲 اللهم اشرح صدره ويسر أمره وبارك في حياته.',
      '🌙 أنتَ نجم يضيء حياة من حولكَ!',
      '💎 صعوباتكَ اليوم تصنع قوتكَ غداً!',
      '🌺 ابتسامتكَ صدقة ونيتكَ الطيبة عبادة!',
      '🎯 الله يعوض أكثر مما تتخيل!',
      '🌈 صبركَ سيُكلَّل بأجمل النتائج إن شاء الله!'
    ],
    'fr': [
      '🌟 Tu es capable!',
      '💪 Allah est avec les patients!',
      '🌸 Tu es plus fort que tu ne le penses!',
      '✨ Tu es spécial et unique!',
      '🤲 Que Allah te bénisse.',
      '🌙 Tu es une étoile!',
      '💎 Tes difficultés construisent ta force!',
      '🌺 Ton sourire est une aumône!',
      '🎯 Allah récompense généreusement!',
      '🌈 Ta patience sera récompensée!'
    ],
    'en': [
      '🌟 You can do it!',
      '💪 Allah is with the patient!',
      '🌸 You\'re stronger than you think!',
      '✨ You are special and unique!',
      '🤲 May Allah bless you.',
      '🌙 You are a shining star!',
      '💎 Difficulties build your strength!',
      '🌺 Your smile is charity!',
      '🎯 Allah rewards generously!',
      '🌈 Your patience will be rewarded!'
    ]
  };
  String _cur = '';
  bool _show = false;
  int _lastIdx = -1;
  late AnimationController _bounce;
  late Animation<double> _ba;
  @override
  void initState() {
    super.initState();
    AppState().addListener(() {
      if (mounted) setState(() {});
    });
    _bounce = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _ba = CurvedAnimation(parent: _bounce, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  void _getMsg() {
    HapticFeedback.mediumImpact();
    final s = AppState();
    final l = s.lang;
    final msgs = s.userGender == 'male'
        ? (_msgsM[l] ?? _msgsM['ar']!)
        : (_msgsF[l] ?? _msgsF['ar']!);
    int idx;
    do {
      idx = Random().nextInt(msgs.length);
    } while (idx == _lastIdx && msgs.length > 1);
    _lastIdx = idx;
    setState(() {
      _cur = msgs[idx];
      _show = true;
    });
    _bounce.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppState().lang;
    final s = AppState();
    String welcome = s.userName.isEmpty
        ? (l == 'ar'
            ? 'مرحباً 🌸'
            : l == 'fr'
                ? 'Bienvenue 🌸'
                : 'Welcome 🌸')
        : (s.userGender == 'male'
            ? (l == 'ar'
                ? 'مرحباً ${s.userName} 🌸'
                : 'Welcome ${s.userName} 🌸')
            : (l == 'ar'
                ? 'مرحباً ${s.userName} 🌸'
                : 'Welcome ${s.userName} 🌸'));
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TaqwaTitle(
              text: l == 'ar'
                  ? 'التشجيع والدعم'
                  : l == 'fr'
                      ? 'Encouragement'
                      : 'Encouragement'),
          const SizedBox(height: 16),
          TaqwaCard(
              child: Text(
                  '$welcome\n${l == 'ar' ? 'اضغط على الزر لرسالة تشجيعية!' : l == 'fr' ? 'Appuie pour un message!' : 'Tap for an encouraging message!'}',
                  style: const TextStyle(
                      color: TC.text2, fontSize: 14, height: 1.8),
                  textAlign: TextAlign.center)),
          const SizedBox(height: 30),
          GestureDetector(
              onTap: _getMsg,
              child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient:
                          const RadialGradient(colors: [TC.gold2, TC.gold3]),
                      boxShadow: [
                        BoxShadow(
                            color: TC.gold.withOpacity(0.4),
                            blurRadius: 25,
                            spreadRadius: 5)
                      ]),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('💬', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 8),
                        Text(
                            l == 'ar'
                                ? 'شجعني!'
                                : l == 'fr'
                                    ? 'Encourage-moi!'
                                    : 'Encourage me!',
                            style: const TextStyle(
                                color: TC.bg,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center)
                      ]))),
          const SizedBox(height: 30),
          if (_show)
            ScaleTransition(
                scale: _ba,
                child: TaqwaCard(
                    child: Column(children: [
                  Text(_cur,
                      style: const TextStyle(
                          color: TC.text,
                          fontSize: 17,
                          height: 1.9,
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl),
                  const SizedBox(height: 16),
                  TaqwaOutlineBtn(
                      label: l == 'ar'
                          ? '🔄 رسالة أخرى'
                          : l == 'fr'
                              ? '🔄 Autre'
                              : '🔄 Another',
                      onTap: _getMsg)
                ]))),
          const SizedBox(height: 20),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: TC.gold.withOpacity(0.2))),
              child: Text(AppState().palestineDua,
                  style: const TextStyle(color: TC.text2, fontSize: 13),
                  textAlign: TextAlign.center)),
        ]));
  }
}

// ═══════════════════════════════════════════════════════════
// FIX 4: TAKBIR — Eid takbir audio URLs (not adhan)
// ═══════════════════════════════════════════════════════════
class TakbirPage extends StatefulWidget {
  const TakbirPage({super.key});
  @override
  State<TakbirPage> createState() => _TakbirPageState();
}

class _TakbirPageState extends State<TakbirPage> with TickerProviderStateMixin {
  int _eid = 0;
  late AnimationController _pulse;
  late Animation<double> _pa;
  final _takbirat = [
    {
      'ar':
          'اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ\nلَا إِلَهَ إِلَّا اللَّهُ\nاللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ\nوَلِلَّهِ الْحَمْدُ',
      'fr':
          'Allah est le Plus Grand (×3)\nIl n\'y a de dieu qu\'Allah\nAllah est le Plus Grand (×2)\nEt toute louange appartient à Allah',
      'en':
          'Allah is the Greatest (×3)\nThere is no god but Allah\nAllah is the Greatest (×2)\nAnd all praise belongs to Allah'
    },
    {
      'ar':
          'اللَّهُ أَكْبَرُ كَبِيرًا وَالْحَمْدُ لِلَّهِ كَثِيرًا\nوَسُبْحَانَ اللَّهِ بُكْرَةً وَأَصِيلًا\nلَا إِلَهَ إِلَّا اللَّهُ وَلَا نَعْبُدُ إِلَّا إِيَّاهُ',
      'fr':
          'Allah est vraiment le Plus Grand et abondante louange à Allah\nGloire à Allah matin et soir\nIl n\'y a de dieu qu\'Allah et nous n\'adorons que Lui',
      'en':
          'Allah is truly the Greatest and abundant praise to Allah\nGlory to Allah morning and evening\nThere is no god but Allah and we worship none but Him'
    },
  ];
  @override
  void initState() {
    super.initState();
    AppState().addListener(() {
      if (mounted) setState(() {});
    });
    _pulse =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _pa = CurvedAnimation(parent: _pulse, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppState().lang;
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TaqwaTitle(
              text: l == 'ar'
                  ? 'تكبيرات العيد'
                  : l == 'fr'
                      ? 'Takbirs de l\'Aïd'
                      : 'Eid Takbirs'),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _EidBtn(
                label: l == 'ar'
                    ? 'عيد الفطر'
                    : l == 'fr'
                        ? 'Aïd al-Fitr'
                        : 'Eid al-Fitr',
                icon: '🌙',
                sel: _eid == 0,
                onTap: () => setState(() => _eid = 0)),
            const SizedBox(width: 12),
            _EidBtn(
                label: l == 'ar'
                    ? 'عيد الأضحى'
                    : l == 'fr'
                        ? 'Aïd al-Adha'
                        : 'Eid al-Adha',
                icon: '🐑',
                sel: _eid == 1,
                onTap: () => setState(() => _eid = 1))
          ]),
          const SizedBox(height: 20),
          // زينة العيد بدلاً من زر الصوت
          AnimatedBuilder(
              animation: _pa,
              builder: (_, __) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🌙',
                            style: TextStyle(fontSize: 28 + 6 * _pa.value)),
                        const SizedBox(width: 12),
                        Text(
                            l == 'ar'
                                ? 'تكبيرات العيد المباركة'
                                : l == 'fr'
                                    ? 'Takbirs de l\'Aïd Moubarak'
                                    : 'Eid Mubarak Takbirs',
                            style: const TextStyle(
                                color: TC.gold,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        Text('⭐',
                            style: TextStyle(fontSize: 28 + 6 * _pa.value)),
                      ]))),
          const SizedBox(height: 8),
          ..._takbirat.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TaqwaCard(
                  child: Column(children: [
                Text(t['ar']!,
                    style: const TextStyle(
                        color: TC.gold,
                        fontSize: 18,
                        height: 2,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl),
                if (l != 'ar') ...[
                  const SizedBox(height: 10),
                  Container(
                      width: double.infinity, height: 1, color: TC.border),
                  const SizedBox(height: 10),
                  Text(t[l]!,
                      style: const TextStyle(
                          color: TC.text2, fontSize: 13, height: 1.8),
                      textAlign: TextAlign.center)
                ]
              ])))),
          TaqwaCard(
              child: Column(children: [
            const Text('🌟', style: TextStyle(fontSize: 30)),
            const SizedBox(height: 8),
            Text(
                l == 'ar'
                    ? 'تقبَّل الله منا ومنكم'
                    : l == 'fr'
                        ? 'Que Allah accepte de nous'
                        : 'May Allah accept from us',
                style: const TextStyle(
                    color: TC.gold, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
                l == 'ar'
                    ? 'عيد مبارك سعيد 🎉'
                    : l == 'fr'
                        ? 'Aïd Moubarak 🎉'
                        : 'Eid Mubarak 🎉',
                style: const TextStyle(color: TC.text2, fontSize: 15))
          ])),
        ]));
  }
}

class _EidBtn extends StatelessWidget {
  final String label, icon;
  final bool sel;
  final VoidCallback onTap;
  const _EidBtn(
      {required this.label,
      required this.icon,
      required this.sel,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
              color: sel ? TC.gold.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: sel ? TC.gold : TC.border2, width: sel ? 2 : 1)),
          child: Column(children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: sel ? TC.gold : TC.text2,
                    fontSize: 11,
                    fontWeight: sel ? FontWeight.bold : FontWeight.normal),
                textAlign: TextAlign.center)
          ])));
}

// ═══════════════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════
// FIX 5: ISLAM CHAT PAGE
// نفس أسئلة وأجوبة IslamQAPage الأصلية لكن على شكل محادثة
// ═══════════════════════════════════════════════════════════
class IslamChatPage extends StatefulWidget {
  const IslamChatPage({super.key});
  @override
  State<IslamChatPage> createState() => _IslamChatPageState();
}

class _IslamChatPageState extends State<IslamChatPage> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<Map<String, String>> _messages = [];

  // نفس البيانات الأصلية من IslamQAPage
  static const _qa = [
    {
      'q': {
        'ar': 'لماذا الإسلام دين السلام؟',
        'fr': 'Pourquoi l\'Islam est-il une religion de paix?',
        'en': 'Why is Islam a religion of peace?'
      },
      'a': {
        'ar':
            'الإسلام في لغته يعني الخضوع والانقياد والاستسلام لأوامر الله تعالى وحده. فالمسلم هو من يسلّم إرادته لله ويخضع لشرعه بمحبة وطوع. وهذا الخضوع لله هو ما يُفضي إلى السلام الحقيقي في النفس والمجتمع، قال النبي ﷺ: "لا يؤمن أحدكم حتى يحب لأخيه ما يحب لنفسه".',
        'fr':
            'L\'Islam signifie soumission, obéissance et abandon total à la volonté d\'Allah seul. Le musulman est celui qui soumet sa volonté à Allah par amour et obéissance. C\'est cette soumission à Dieu qui engendre la vraie paix intérieure et sociale. Le Prophète ﷺ a dit: "Nul ne croit vraiment s\'il n\'aime pour son frère ce qu\'il aime pour lui-même".',
        'en':
            'Islam means submission, obedience and complete surrender to the commands of Allah alone. A Muslim is one who submits their will to Allah out of love and willingness. This submission to God is what leads to true peace within oneself and in society. The Prophet ﷺ said: "None truly believes until he loves for his brother what he loves for himself."'
      }
    },
    {
      'q': {
        'ar': 'ما سر الطمأنينة في الصلاة؟',
        'fr': 'Quel est le secret de la sérénité dans la prière?',
        'en': 'What is the secret of tranquility in prayer?'
      },
      'a': {
        'ar':
            'الصلاة اتصال مباشر بالخالق خمس مرات يومياً. في الصلاة يترك المسلم كل هموم الدنيا ويتوجه بقلبه وجسده لله. يقول القرآن: ﴿أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ﴾ — الرعد 28',
        'fr':
            'La prière est une connexion directe avec le Créateur cinq fois par jour. Le Coran dit: "C\'est par le rappel d\'Allah que les cœurs se tranquillisent" — Ar-Ra\'d 28',
        'en':
            'Prayer is a direct connection with the Creator five times daily. The Quran says: "Verily, in the remembrance of Allah do hearts find rest" — Ar-Ra\'d 28'
      }
    },
    {
      'q': {
        'ar': 'هل القرآن معجزة علمية؟',
        'fr': 'Le Coran est-il un miracle scientifique?',
        'en': 'Is the Quran a scientific miracle?'
      },
      'a': {
        'ar':
            'نعم! القرآن ذكر حقائق علمية قبل اكتشافها بـ 1400 سنة: مثل مراحل تكوين الجنين، وتمدد الكون، والطبقات الجوية. قال تعالى: ﴿وَالسَّمَاءَ بَنَيْنَاهَا بِأَيْدٍ وَإِنَّا لَمُوسِعُونَ﴾ — الذاريات 47.',
        'fr':
            'Oui! Le Coran a mentionné des vérités scientifiques 1400 ans avant leur découverte. Allah dit: "Et le ciel, Nous l\'avons construit avec force, et c\'est Nous qui l\'étendons" — Adh-Dhariyat 47',
        'en':
            'Yes! The Quran mentioned scientific facts 1400 years before discovery. Allah says: "And the heaven We constructed with strength, and indeed, We are its expander" — Adh-Dhariyat 47'
      }
    },
    {
      'q': {
        'ar': 'كيف يعامل الإسلام المرأة؟',
        'fr': 'Comment l\'Islam traite-t-il la femme?',
        'en': 'How does Islam treat women?'
      },
      'a': {
        'ar':
            'الإسلام أعطى المرأة حقوقاً كاملة قبل 1400 سنة: حق التعليم، والميراث، والعمل، واختيار الزوج. قال النبي ﷺ: "النساء شقائق الرجال". المرأة في الإسلام محترمة كأم وزوجة وابنة وعاملة.',
        'fr':
            'L\'Islam a accordé à la femme des droits complets il y a 1400 ans. Le Prophète ﷺ a dit: "Les femmes sont les égales des hommes".',
        'en':
            'Islam gave women full rights 1400 years ago: education, inheritance, work, and choosing a spouse. The Prophet ﷺ said: "Women are the counterparts of men."'
      }
    },
    {
      'q': {
        'ar': 'ما الفرق بين الإسلام والإرهاب؟',
        'fr': 'Quelle est la différence entre l\'Islam et le terrorisme?',
        'en': 'What is the difference between Islam and terrorism?'
      },
      'a': {
        'ar':
            'الإسلام يُحرّم قتل الأبرياء تحريماً قاطعاً. قال تعالى: ﴿مَن قَتَلَ نَفْسًا بِغَيْرِ نَفْسٍ أَوْ فَسَادٍ فِي الْأَرْضِ فَكَأَنَّمَا قَتَلَ النَّاسَ جَمِيعًا﴾. الإرهاب يتعارض كلياً مع تعاليم الإسلام.',
        'fr':
            'L\'Islam interdit absolument de tuer des innocents. Allah dit: "Quiconque tue une personne sans raison légitime, c\'est comme s\'il avait tué toute l\'humanité."',
        'en':
            'Islam absolutely forbids killing innocent people. Allah says: "Whoever kills a person without justification, it is as if he has killed all of mankind."'
      }
    },
    {
      'q': {
        'ar': 'لماذا يصوم المسلمون في رمضان؟',
        'fr': 'Pourquoi les musulmans jeûnent-ils pendant le Ramadan?',
        'en': 'Why do Muslims fast during Ramadan?'
      },
      'a': {
        'ar':
            'الصوم يُعلّم الصبر والتعاطف مع الفقراء، ويُصفّي الروح والجسد. في رمضان نزل القرآن الكريم. والصوم ليس فقط عن الطعام — بل عن تهذيب النفس والتقرب من الله.',
        'fr':
            'Le jeûne enseigne la patience et l\'empathie envers les pauvres. C\'est en Ramadan que le Coran a été révélé. Le jeûne est une purification de l\'âme.',
        'en':
            'Fasting teaches patience and empathy with the poor. The Quran was revealed during Ramadan. Fasting is about self-purification and drawing closer to God.'
      }
    },
    {
      'q': {
        'ar': 'ما هو الجهاد الحقيقي في الإسلام؟',
        'fr': 'Qu\'est-ce que le vrai Jihad en Islam?',
        'en': 'What is the true meaning of Jihad in Islam?'
      },
      'a': {
        'ar':
            'كلمة "جهاد" تعني "البذل والمجاهدة". أعلى درجاته هو "جهاد النفس" — مقاومة الأهواء وتحسين الأخلاق. قال النبي ﷺ عند عودته من معركة: "رجعنا من الجهاد الأصغر إلى الجهاد الأكبر — جهاد النفس".',
        'fr':
            'Le mot "Jihad" signifie "effort et lutte". Sa plus haute forme est le "Jihad de l\'âme" — résister aux désirs et améliorer son caractère.',
        'en':
            'The word "Jihad" means "striving and effort". Its highest form is the "Jihad of the soul" — resisting desires and improving character.'
      }
    },
    {
      'q': {
        'ar': 'كيف يؤمن الإسلام بالعلم والعقل؟',
        'fr': 'Comment l\'Islam croit-il en la science et la raison?',
        'en': 'How does Islam embrace science and reason?'
      },
      'a': {
        'ar':
            'أول كلمة نزلت في القرآن كانت "اقرأ"! الإسلام يأمر بالتفكر في الكون. في العصور الذهبية أسهم المسلمون في تأسيس الرياضيات والطب والفلك والكيمياء. العلم في الإسلام عبادة.',
        'fr':
            'Le premier mot révélé dans le Coran était "Lis"! Durant l\'âge d\'or islamique, les musulmans ont fondé les mathématiques, la médecine, l\'astronomie et la chimie.',
        'en':
            'The first word revealed in the Quran was "Read"! During the Islamic Golden Age, Muslims founded mathematics, medicine, astronomy and chemistry. Science in Islam is worship.'
      }
    },
    {
      'q': {
        'ar': 'ما معنى الزكاة وكيف تساهم في العدالة؟',
        'fr': 'Que signifie la Zakat et comment contribue-t-elle à la justice?',
        'en': 'What is Zakat and how does it contribute to social justice?'
      },
      'a': {
        'ar':
            'الزكاة هي إعطاء 2.5% من المدخرات للفقراء سنوياً. هي ركن من أركان الإسلام وتُطهّر المال وتُزكّي النفس. لو طُبّقت الزكاة عالمياً لأمكن القضاء على الفقر المدقع!',
        'fr':
            'La Zakat est de donner 2,5% de ses économies aux pauvres annuellement. C\'est un pilier de l\'Islam qui purifie la richesse et l\'âme.',
        'en':
            'Zakat is giving 2.5% of savings to the poor annually. It is a pillar of Islam that purifies wealth and the soul.'
      }
    },
    {
      'q': {
        'ar': 'هل يؤمن الإسلام بالمسيح عيسى عليه السلام؟',
        'fr': 'L\'Islam croit-il en Jésus-Christ?',
        'en': 'Does Islam believe in Jesus Christ?'
      },
      'a': {
        'ar':
            'نعم! عيسى عليه السلام نبي معظَّم في الإسلام. له سورة كاملة في القرآن (مريم). يؤمن المسلمون بمعجزاته وبأنه وُلد من العذراء مريم. الإسلام يعتبره نبياً عظيماً ويؤمن بعودته قرب نهاية الزمان.',
        'fr':
            'Oui! Jésus est un prophète vénéré en Islam. Il a une sourate entière dans le Coran (Marie). Les musulmans croient en ses miracles et en sa naissance de la Vierge Marie.',
        'en':
            'Yes! Jesus (peace be upon him) is a revered prophet in Islam. He has an entire chapter in the Quran (Mary). Muslims believe in his miracles and birth from the Virgin Mary.'
      }
    },
    {
      'q': {
        'ar': 'كيف يتعامل الإسلام مع البيئة والطبيعة؟',
        'fr': 'Comment l\'Islam traite-t-il l\'environnement?',
        'en': 'How does Islam treat the environment?'
      },
      'a': {
        'ar':
            'الإسلام أول دين يُشرّع حماية البيئة! النبي ﷺ قال: "إن قامت الساعة وبيد أحدكم فسيلة فليغرسها". أسّس النبي ﷺ محميات طبيعية. المسلم خليفة الله في الأرض مسؤول عن حفظها.',
        'fr':
            'L\'Islam est la première religion à légiférer la protection de l\'environnement! Le Prophète ﷺ a dit: "Si l\'Heure arrive et qu\'il y a dans la main de l\'un de vous un plant, qu\'il le plante."',
        'en':
            'Islam is the first religion to legislate environmental protection! The Prophet ﷺ said: "If the Hour comes and one of you has a seedling, let him plant it."'
      }
    },
    {
      'q': {
        'ar': 'ما هو الفردوس في الإسلام؟',
        'fr': 'Qu\'est-ce que le Paradis en Islam?',
        'en': 'What is Paradise in Islam?'
      },
      'a': {
        'ar':
            'الجنة في الإسلام دار الخلد والنعيم الأبدي. يقول القرآن: ﴿فِيهَا مَا تَشْتَهِيهِ الْأَنفُسُ وَتَلَذُّ الْأَعْيُنُ﴾. لكن أعظم نعيمها هو رؤية الله تعالى.',
        'fr':
            'Le Paradis en Islam est la demeure éternelle de bonheur. Le Coran dit: "Il y aura là ce que les âmes désirent." Mais le plus grand bonheur est de voir Allah.',
        'en':
            'Paradise in Islam is the eternal abode of bliss. The Quran says: "In it is what souls desire and what delights the eyes." The greatest joy is seeing Allah.'
      }
    },
    {
      'q': {
        'ar': 'كيف يُعزز الإسلام الأخلاق الحسنة؟',
        'fr': 'Comment l\'Islam promeut-il les bonnes mœurs?',
        'en': 'How does Islam promote good character?'
      },
      'a': {
        'ar':
            'قال النبي ﷺ: "إنما بُعثت لأتمم مكارم الأخلاق". الإسلام يأمر بالصدق والأمانة والكرم والعدل والرحمة. "خيركم خيركم لأهله"، "الدين المعاملة".',
        'fr':
            'Le Prophète ﷺ a dit: "Je n\'ai été envoyé que pour parfaire les bonnes mœurs." L\'Islam ordonne l\'honnêteté, la fidélité, la générosité, la justice et la miséricorde.',
        'en':
            'The Prophet ﷺ said: "I was sent only to perfect good character." Islam commands honesty, trustworthiness, generosity, justice and mercy.'
      }
    },
    {
      'q': {
        'ar': 'لماذا يدعو الإسلام إلى التعايش مع غير المسلمين؟',
        'fr': 'Pourquoi l\'Islam appelle-t-il à la coexistence?',
        'en': 'Why does Islam call for coexistence with non-Muslims?'
      },
      'a': {
        'ar':
            'الإسلام يأمر بالعدل مع الجميع. قال تعالى: ﴿لَا يَنْهَاكُمُ اللَّهُ عَنِ الَّذِينَ لَمْ يُقَاتِلُوكُمْ فِي الدِّينِ أَن تَبَرُّوهُمْ وَتُقْسِطُوا إِلَيْهِمْ﴾. عاش في ظل الحضارة الإسلامية يهود ومسيحيون بسلام لقرون.',
        'fr':
            'L\'Islam ordonne la justice envers tous. Allah dit: "Allah ne vous interdit pas d\'être bons et équitables envers ceux qui ne vous ont pas combattus."',
        'en':
            'Islam commands justice towards everyone. Allah says: "Allah does not forbid you from being kind and just to those who have not fought you."'
      }
    },
    {
      'q': {
        'ar': 'لماذا يرتدي المسلمون ملابس محتشمة؟',
        'fr': 'Pourquoi les musulmans portent-ils des vêtements modestes?',
        'en': 'Why do Muslims wear modest clothing?'
      },
      'a': {
        'ar':
            'الحشمة في الإسلام ليست فقط للمرأة — بل للرجل أيضاً. هي تعبير عن الكرامة والاحترام الذاتي. الحجاب للمرأة المسلمة هو اختيار إيماني يُعبّر عن هويتها وتقواها.',
        'fr':
            'La modestie en Islam n\'est pas seulement pour la femme — mais aussi pour l\'homme. Le hijab est un choix de foi.',
        'en':
            'Modesty in Islam is not only for women — but for men too. The hijab for Muslim women is a faith choice expressing identity and piety.'
      }
    },
  ];

  // يبحث عن إجابة في قاعدة البيانات
  String? _findAnswer(String question, String lang) {
    final q = question.trim().toLowerCase();
    for (final item in _qa) {
      final stored = ((item['q'] as Map)[lang] ?? '').toLowerCase();
      // مطابقة مرنة: إذا كان السؤال يحتوي على كلمات رئيسية
      final words = stored.split(' ').where((w) => w.length > 3).toList();
      int matches = 0;
      for (final w in words) {
        if (q.contains(w)) matches++;
      }
      if (matches >= 2 ||
          (stored.isNotEmpty &&
              q.contains(stored.substring(
                  0, stored.length < 15 ? stored.length : 15)))) {
        return (item['a'] as Map)[lang] ?? '';
      }
    }
    return null;
  }

  String _defaultReply(String lang) {
    if (lang == 'fr')
      return 'Je n\'ai pas trouvé de réponse précise. Voici les sujets disponibles 👆 Appuyez sur un sujet pour en savoir plus!';
    if (lang == 'en')
      return 'I didn\'t find a precise answer. See the topics above 👆 Tap any topic to learn more!';
    return 'لم أجد إجابة محددة لسؤالك. اضغط على أحد الموضوعات أعلاه 👆 للحصول على معلومات مفصّلة!';
  }

  @override
  void initState() {
    super.initState();
    AppState().addListener(() {
      if (mounted) setState(() {});
    });
    _addBot(_welcome());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _welcome() {
    final l = AppState().lang;
    if (l == 'fr')
      return 'Assalamu Alaikum! 🌙 Je suis Taqwa, votre assistant islamique.\nChoisissez un sujet ci-dessus ou posez votre question directement!';
    if (l == 'en')
      return 'Assalamu Alaikum! 🌙 I am Taqwa, your Islamic assistant.\nChoose a topic above or ask your question directly!';
    return 'السلام عليكم ورحمة الله! 🌙\nأنا تقى، مساعدك الإسلامي.\nاختر موضوعاً من الأعلى أو اكتب سؤالك مباشرةً!';
  }

  void _addBot(String t) {
    setState(() => _messages.add({'role': 'assistant', 'content': t}));
    _toBottom();
  }

  void _toBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scroll.hasClients)
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  // الضغط على سؤال مباشرة — يضيف السؤال كرسالة مستخدم ويجيب فوراً
  void _sendTopic(String question) {
    final l = AppState().lang;
    // إيجاد الإجابة المباشرة من قاعدة البيانات بالمطابقة الكاملة
    String? answer;
    for (final item in _qa) {
      if ((item['q'] as Map)[l] == question) {
        answer = (item['a'] as Map)[l] ?? '';
        break;
      }
    }
    setState(() => _messages.add({'role': 'user', 'content': question}));
    _toBottom();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _addBot(answer ?? _defaultReply(l));
    });
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    final l = AppState().lang;
    setState(() => _messages.add({'role': 'user', 'content': text}));
    _ctrl.clear();
    _toBottom();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      // بحث مرن
      String? answer;
      final q = text.toLowerCase();
      for (final item in _qa) {
        final stored = ((item['q'] as Map)[l] ?? '').toLowerCase();
        final words = stored.split(' ').where((w) => w.length > 2).toList();
        int matches = 0;
        for (final w in words) {
          if (q.contains(w)) matches++;
        }
        if (matches >= 2) {
          answer = (item['a'] as Map)[l] ?? '';
          break;
        }
      }
      _addBot(answer ?? _defaultReply(l));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppState().lang;
    final topics = _qa.map((item) => (item['q'] as Map)[l] ?? '').toList();
    return Column(children: [
      // Header
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
              color: TC.cardColor(AppState().theme).withOpacity(0.8),
              border: const Border(bottom: BorderSide(color: TC.border))),
          child: Row(children: [
            const Text('🤖', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                      l == 'ar'
                          ? 'تعرف على الإسلام'
                          : l == 'fr'
                              ? 'Découvrir l\'Islam'
                              : 'Discover Islam',
                      style: const TextStyle(
                          color: TC.gold,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text(
                      l == 'ar'
                          ? 'اضغط على سؤال أو اكتب سؤالك'
                          : l == 'fr'
                              ? 'Appuyez ou tapez'
                              : 'Tap a topic or type',
                      style: const TextStyle(color: TC.text3, fontSize: 10)),
                ])),
          ])),
      // الأسئلة ثابتة دائماً في الأعلى
      Container(
          color: TC.cardColor(AppState().theme).withOpacity(0.5),
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Wrap(
              spacing: 7,
              runSpacing: 7,
              children: List.generate(
                  topics.length,
                  (i) => GestureDetector(
                      onTap: () => _sendTopic(topics[i]),
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 11, vertical: 6),
                          decoration: BoxDecoration(
                              color: TC.gold.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: TC.border2)),
                          child: Text(topics[i],
                              style: const TextStyle(
                                  color: TC.gold2, fontSize: 11),
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right)))))),
      // المحادثة
      Expanded(
          child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                final isMe = msg['role'] == 'user';
                return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.85),
                        decoration: BoxDecoration(
                            color: isMe
                                ? TC.gold.withOpacity(0.18)
                                : TC
                                    .cardColor(AppState().theme)
                                    .withOpacity(0.9),
                            borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(14),
                                topRight: const Radius.circular(14),
                                bottomLeft: Radius.circular(isMe ? 14 : 4),
                                bottomRight: Radius.circular(isMe ? 4 : 14)),
                            border: Border.all(
                                color: isMe ? TC.border2 : TC.border)),
                        child: Text(msg['content'] ?? '',
                            style: const TextStyle(
                                color: TC.text, fontSize: 13, height: 1.75),
                            textDirection: TextDirection.rtl)));
              })),
      // Input
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
              color: TC.cardColor(AppState().theme).withOpacity(0.9),
              border: const Border(top: BorderSide(color: TC.border))),
          child: Row(children: [
            Expanded(
                child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(color: TC.text, fontSize: 14),
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    minLines: 1,
                    decoration: InputDecoration(
                        hintText: l == 'ar'
                            ? 'اكتب سؤالك...'
                            : l == 'fr'
                                ? 'Écrivez votre question...'
                                : 'Type your question...',
                        hintStyle:
                            const TextStyle(color: TC.text3, fontSize: 13),
                        filled: true,
                        fillColor: Colors.black26,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: TC.border)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: TC.gold))),
                    onSubmitted: (_) => _send())),
            const SizedBox(width: 8),
            GestureDetector(
                onTap: _send,
                child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [TC.gold, TC.gold3]),
                        shape: BoxShape.circle),
                    child: const Center(
                        child:
                            Icon(Icons.send_rounded, color: TC.bg, size: 20)))),
          ])),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════
// FIX 6: SETTINGS — theme buttons now show text labels
// ═══════════════════════════════════════════════════════════
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _nameCtrl = TextEditingController();
  String _gender = 'female';
  @override
  void initState() {
    super.initState();
    AppState().addListener(() {
      if (mounted) setState(() {});
    });
    _nameCtrl.text = AppState().userName;
    _gender = AppState().userGender;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppState();
    final l = s.lang;
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TaqwaTitle(
              text: l == 'ar'
                  ? 'الإعدادات'
                  : l == 'fr'
                      ? 'Paramètres'
                      : 'Settings'),
          const SizedBox(height: 20),
          // Language
          TaqwaCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                    l == 'ar'
                        ? '🌍 اللغة'
                        : l == 'fr'
                            ? '🌍 Langue'
                            : '🌍 Language',
                    style: const TextStyle(
                        color: TC.gold,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _LangChip('ar', '🇸🇦'),
                  const SizedBox(width: 8),
                  _LangChip('fr', '🇫🇷'),
                  const SizedBox(width: 8),
                  _LangChip('en', '🇬🇧')
                ]),
              ])),
          const SizedBox(height: 14),
          // Theme — FIX: full text + color dots on each button
          TaqwaCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                    l == 'ar'
                        ? '🎨 لون الخلفية'
                        : l == 'fr'
                            ? '🎨 Couleur du thème'
                            : '🎨 Theme Color',
                    style: const TextStyle(
                        color: TC.gold,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...[
                  (
                    'blue',
                    '🌊',
                    l == 'ar'
                        ? 'أزرق ليلي'
                        : l == 'fr'
                            ? 'Bleu Nuit'
                            : 'Night Blue',
                    [
                      const Color(0xFF0D1B2A),
                      const Color(0xFF1A2744),
                      const Color(0xFF3D4F7C)
                    ]
                  ),
                  (
                    'green',
                    '🌿',
                    l == 'ar'
                        ? 'أخضر إسلامي'
                        : l == 'fr'
                            ? 'Vert Émeraude'
                            : 'Emerald Green',
                    [
                      const Color(0xFF0A1F12),
                      const Color(0xFF1A4A2E),
                      const Color(0xFF256040)
                    ]
                  ),
                  (
                    'brown',
                    '🏔️',
                    l == 'ar'
                        ? 'بني ذهبي'
                        : l == 'fr'
                            ? 'Brun Doré'
                            : 'Golden Brown',
                    [
                      const Color(0xFF1A0F08),
                      const Color(0xFF3D2510),
                      const Color(0xFF5C3A1A)
                    ]
                  ),
                ].map((item) => GestureDetector(
                      onTap: () => s.setTheme(item.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                            color: s.theme == item.$1
                                ? TC.gold.withOpacity(0.12)
                                : Colors.black12,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    s.theme == item.$1 ? TC.gold : TC.border2,
                                width: s.theme == item.$1 ? 2 : 1)),
                        child: Row(children: [
                          Text(item.$2, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(item.$3,
                                    style: TextStyle(
                                        color: s.theme == item.$1
                                            ? TC.gold
                                            : TC.text,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Row(
                                    children: (item.$4 as List<Color>)
                                        .map((c) => Container(
                                            margin:
                                                const EdgeInsets.only(right: 5),
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: c)))
                                        .toList()),
                              ])),
                          if (s.theme == item.$1)
                            const Icon(Icons.check_circle,
                                color: TC.gold, size: 20),
                        ]),
                      ),
                    )),
              ])),
          const SizedBox(height: 14),
          // User info
          TaqwaCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                    l == 'ar'
                        ? '👤 معلوماتي'
                        : l == 'fr'
                            ? '👤 Mes infos'
                            : '👤 My Info',
                    style: const TextStyle(
                        color: TC.gold,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Directionality(
                    textDirection:
                        l == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                    child: TextField(
                        controller: _nameCtrl,
                        style: const TextStyle(color: TC.text),
                        decoration: InputDecoration(
                            hintText: l == 'ar'
                                ? 'اسمك...'
                                : l == 'fr'
                                    ? 'Ton prénom...'
                                    : 'Your name...',
                            hintStyle: const TextStyle(color: TC.text3),
                            filled: true,
                            fillColor: Colors.black26,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: TC.border)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: TC.gold)),
                            prefixIcon: const Icon(Icons.person_outline,
                                color: TC.gold3)))),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _GenderBtn(
                      label: l == 'ar'
                          ? 'أنثى'
                          : l == 'fr'
                              ? 'Femme'
                              : 'Female',
                      value: 'female',
                      selected: _gender,
                      icon: '👩',
                      onTap: () => setState(() => _gender = 'female')),
                  const SizedBox(width: 12),
                  _GenderBtn(
                      label: l == 'ar'
                          ? 'ذكر'
                          : l == 'fr'
                              ? 'Homme'
                              : 'Male',
                      value: 'male',
                      selected: _gender,
                      icon: '👨',
                      onTap: () => setState(() => _gender = 'male'))
                ]),
                const SizedBox(height: 16),
                Center(
                    child: TaqwaBtn(
                        label: l == 'ar'
                            ? '💾 حفظ'
                            : l == 'fr'
                                ? '💾 Enregistrer'
                                : '💾 Save',
                        onTap: () {
                          if (_nameCtrl.text.trim().isNotEmpty) {
                            s.setUser(_nameCtrl.text.trim(), _gender);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    l == 'ar' ? 'تم الحفظ ✅' : 'Saved ✅',
                                    textAlign: TextAlign.center),
                                backgroundColor: TC.green,
                                duration: const Duration(seconds: 2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                behavior: SnackBarBehavior.floating));
                          }
                        })),
              ])),
        ]));
  }
}

// ═══════════════════════════════════════════════════════════
// SHARED WIDGETS — unchanged from original
// ═══════════════════════════════════════════════════════════
class _LangChip extends StatelessWidget {
  final String lang, flag;
  const _LangChip(this.lang, this.flag);
  @override
  Widget build(BuildContext context) {
    final sel = AppState().lang == lang;
    return GestureDetector(
        onTap: () => AppState().setLang(lang),
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
                color: sel ? TC.gold.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? TC.gold : TC.border)),
            child: Text('$flag ${lang.toUpperCase()}',
                style:
                    TextStyle(color: sel ? TC.gold : TC.text3, fontSize: 13))));
  }
}

class TaqwaTitle extends StatelessWidget {
  final String text;
  const TaqwaTitle({super.key, required this.text});
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Expanded(
            child: Container(
                height: 1,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.transparent, TC.gold3])))),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(text,
                style: const TextStyle(
                    color: TC.gold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold))),
        Expanded(
            child: Container(
                height: 1,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [TC.gold3, Colors.transparent]))))
      ]);
}

class TaqwaCard extends StatelessWidget {
  final Widget child;
  const TaqwaCard({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: TC.cardColor(AppState().theme).withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: TC.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 4))
          ]),
      child: child);
}

class TaqwaBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const TaqwaBtn({super.key, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [TC.gold, TC.gold3]),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                    color: TC.gold.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ]),
          child: Text(label,
              style: const TextStyle(
                  color: TC.bg, fontWeight: FontWeight.bold, fontSize: 14))));
}

class TaqwaOutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const TaqwaOutlineBtn({super.key, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: TC.gold3)),
          child: Text(label,
              style: const TextStyle(color: TC.gold2, fontSize: 13))));
}

class StatCard extends StatelessWidget {
  final String icon, label, value;
  const StatCard(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: TC.card2Color(AppState().theme).withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TC.border)),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: TC.text3, fontSize: 10)),
          Text(value,
              style: const TextStyle(
                  color: TC.gold, fontSize: 16, fontWeight: FontWeight.bold))
        ])
      ]));
}

class _LangSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppState().lang;
    return PopupMenuButton<String>(
        color: TC.card2Color(AppState().theme),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: TC.border2)),
        onSelected: (v) => AppState().setLang(v),
        itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'ar',
                  child: Text('🇸🇦 العربية',
                      style: TextStyle(color: l == 'ar' ? TC.gold : TC.text2))),
              PopupMenuItem(
                  value: 'fr',
                  child: Text('🇫🇷 Français',
                      style: TextStyle(color: l == 'fr' ? TC.gold : TC.text2))),
              PopupMenuItem(
                  value: 'en',
                  child: Text('🇬🇧 English',
                      style: TextStyle(color: l == 'en' ? TC.gold : TC.text2)))
            ],
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                border: Border.all(color: TC.border2),
                borderRadius: BorderRadius.circular(20)),
            child: Text(
                l == 'ar'
                    ? '🇸🇦 ع'
                    : l == 'fr'
                        ? '🇫🇷 Fr'
                        : '🇬🇧 En',
                style: const TextStyle(color: TC.gold, fontSize: 12))));
  }
}

class _OrnamentDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
            width: 80,
            height: 1,
            decoration: const BoxDecoration(
                gradient:
                    LinearGradient(colors: [Colors.transparent, TC.gold3]))),
        const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('✦', style: TextStyle(color: TC.gold3, fontSize: 12))),
        Container(
            width: 80,
            height: 1,
            decoration: const BoxDecoration(
                gradient:
                    LinearGradient(colors: [TC.gold3, Colors.transparent])))
      ]);
}
