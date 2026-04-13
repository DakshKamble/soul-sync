import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SoulSyncApp());
}

// ─── THEME CONSTANTS ───────────────────────────────────────────────────────────

class SS {
  static const Color rose = Color(0xFFFF6B9D);
  static const Color roseLight = Color(0xFFFFB3CC);
  static const Color roseDark = Color(0xFFE91E63);
  static const Color lavender = Color(0xFFB57BEE);
  static const Color lavLight = Color(0xFFE8D5FF);
  static const Color peach = Color(0xFFFFAA85);
  static const Color sky = Color(0xFF85C8FF);
  static const Color mint = Color(0xFF85EEC8);
  static const Color bg = Color(0xFFFFF5F8);
  static const Color card = Colors.white;
  static const Color textDark = Color(0xFF2D1B2E);
  static const Color textMid = Color(0xFF8B6B8E);
  static const Color textLight = Color(0xFFBCA0BE);

  static const LinearGradient heroGrad = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFB57BEE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient bgGrad = LinearGradient(
    colors: [Color(0xFFFFF0F7), Color(0xFFF8EAFF), Color(0xFFEEF4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxShadow get softShadow => BoxShadow(
        color: SS.rose.withOpacity(0.18),
        blurRadius: 24,
        offset: const Offset(0, 8),
        spreadRadius: 0,
      );
  static BoxShadow get thinShadow => BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      );
}

// ─── APP ───────────────────────────────────────────────────────────────────────

class SoulSyncApp extends StatelessWidget {
  const SoulSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoulSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: SS.bg,
        primaryColor: SS.rose,
        colorScheme: ColorScheme.fromSeed(seedColor: SS.rose),
        fontFamily: 'Quicksand',
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const MainScreen(),
    );
  }
}

// ─── MAIN SCREEN ──────────────────────────────────────────────────────────────

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _navController;

  final List<Widget> _tabs = const [HomeTab(), HistoryTab(), NFCTab()];

  @override
  void initState() {
    super.initState();
    _navController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _navController.forward();
  }

  @override
  void dispose() {
    _navController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
    _navController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(gradient: SS.bgGrad),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                      begin: const Offset(0, 0.03), end: Offset.zero)
                  .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(_currentIndex),
            child: _tabs[_currentIndex],
          ),
        ),
      ),
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

// ─── FLOATING NAV BAR ─────────────────────────────────────────────────────────

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _FloatingNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
              color: SS.rose.withOpacity(0.25),
              blurRadius: 32,
              offset: const Offset(0, 8)),
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(icon: Icons.favorite_rounded, label: 'Home', index: 0, currentIndex: currentIndex, onTap: onTap),
          _NavItem(icon: Icons.history_rounded, label: 'History', index: 1, currentIndex: currentIndex, onTap: onTap),
          _NavItem(icon: Icons.nfc_rounded, label: 'NFC', index: 2, currentIndex: currentIndex, onTap: onTap),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _NavItem({
    required this.icon, required this.label, required this.index,
    required this.currentIndex, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
            horizontal: active ? 20 : 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: active ? SS.heroGrad : null,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: active ? Colors.white : SS.textLight, size: 22),
            if (active) ...[
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── HOME TAB ─────────────────────────────────────────────────────────────────

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  final DatabaseReference _db = FirebaseDatabase.instance.ref().child('moods');
  late AnimationController _heartbeatController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _sendMood(String mood, {String message = ''}) async {
    HapticFeedback.mediumImpact();
    try {
      await _db.push().set({
        'mood': mood,
        'message': message,
        'sender': 'Gargi',
        'timestamp': ServerValue.timestamp,
      });
      if (!mounted) return;
      _showToast(
          message.isNotEmpty ? '💌 Deep message synced!' : '💕 $mood synced!');
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: SS.rose,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      duration: const Duration(seconds: 2),
    ));
  }

  void _openMoodDialog(MoodData mood) {
    HapticFeedback.selectionClick();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 450),
      transitionBuilder: (ctx, anim, _, child) {
        final curved =
            CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curved),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      pageBuilder: (ctx, _, __) => _MoodDialog(mood: mood, onSend: _sendMood),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 28),
            _buildPartnerCard(),
            const SizedBox(height: 32),
            Text('How are you\nfeeling today?',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: SS.textDark,
                    height: 1.2)),
            const SizedBox(height: 6),
            Text('Tap to sync • Hold for a message',
                style: TextStyle(fontSize: 13, color: SS.textLight)),
            const SizedBox(height: 24),
            _buildMoodGrid(),
            const SizedBox(height: 20),
            _buildNeedyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SOULSYNC',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: SS.rose,
                  letterSpacing: 3)),
          Text('Good morning, Gargi ✨',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: SS.textDark)),
        ]),
        AnimatedBuilder(
          animation: _heartbeatController,
          builder: (_, __) => Transform.scale(
            scale: 1.0 + 0.12 * _heartbeatController.value,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: SS.heroGrad,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: SS.rose.withOpacity(0.4),
                      blurRadius: 16,
                      spreadRadius: 2)
                ],
              ),
              child: const Icon(Icons.favorite_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPartnerCard() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, -3 * _floatController.value),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: SS.heroGrad,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [SS.softShadow],
          ),
          child: Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: const Center(
                  child: Text('💑', style: TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Connected to Ansh',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('Last synced 2 min ago',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 12)),
                  ]),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Online',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildMoodGrid() {
    final moods = [
      MoodData('Happy', '😊', const Color(0xFFFF6B9D),
          [const Color(0xFFFF6B9D), const Color(0xFFFF9AC5)]),
      MoodData('Sad', '🥺', const Color(0xFF6B9DFF),
          [const Color(0xFF6B9DFF), const Color(0xFF9AC5FF)]),
      MoodData('Sleepy', '😴', const Color(0xFF9D6BFF),
          [const Color(0xFF9D6BFF), const Color(0xFFC09AFF)]),
      MoodData('Angry', '😤', const Color(0xFFFF8C6B),
          [const Color(0xFFFF8C6B), const Color(0xFFFFAA8C)]),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.0,
      children: moods
          .asMap()
          .entries
          .map((e) => _AnimatedMoodCard(
                mood: e.value,
                delay: Duration(milliseconds: e.key * 80),
                onTap: () => _sendMood(e.value.name),
                onLongPress: () => _openMoodDialog(e.value),
              ))
          .toList(),
    );
  }

  Widget _buildNeedyButton() {
    final mood = MoodData('Needy', '🥰', const Color(0xFFE91E63),
        [const Color(0xFFFF6B9D), const Color(0xFFB57BEE)]);
    return _AnimatedMoodCard(
      mood: mood,
      delay: Duration.zero,
      onTap: () => _sendMood('Needy'),
      onLongPress: () => _openMoodDialog(mood),
      isFeatured: true,
    );
  }
}

// ─── MOOD DATA ────────────────────────────────────────────────────────────────

class MoodData {
  final String name;
  final String emoji;
  final Color color;
  final List<Color> gradient;
  const MoodData(this.name, this.emoji, this.color, this.gradient);
}

// ─── ANIMATED MOOD CARD ───────────────────────────────────────────────────────

class _AnimatedMoodCard extends StatefulWidget {
  final MoodData mood;
  final Duration delay;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isFeatured;

  const _AnimatedMoodCard({
    required this.mood,
    required this.delay,
    required this.onTap,
    required this.onLongPress,
    this.isFeatured = false,
  });

  @override
  State<_AnimatedMoodCard> createState() => _AnimatedMoodCardState();
}

class _AnimatedMoodCardState extends State<_AnimatedMoodCard>
    with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late AnimationController _pressCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _entry;
  late Animation<double> _press;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _pressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);

    _entry = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutBack);
    _press =
        Tween<double>(begin: 1.0, end: 0.93).animate(_pressCtrl);

    Future.delayed(widget.delay, () {
      if (mounted) _entryCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pressCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entry, _press, _pulseCtrl]),
      builder: (_, __) => Transform.scale(
        scale: _entry.value * _press.value,
        child: GestureDetector(
          onTap: () {
            _pressCtrl.forward().then((_) => _pressCtrl.reverse());
            widget.onTap();
          },
          onLongPress: widget.onLongPress,
          onTapDown: (_) => _pressCtrl.forward(),
          onTapCancel: () => _pressCtrl.reverse(),
          child: Container(
            height: widget.isFeatured ? 110 : null,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.mood.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: widget.mood.color.withOpacity(
                      0.35 + 0.15 * _pulseCtrl.value),
                  blurRadius: 20 + 8 * _pulseCtrl.value,
                  offset: const Offset(0, 6),
                  spreadRadius: widget.isFeatured ? 2 : 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative circle
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: -10,
                  bottom: -15,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: widget.isFeatured
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(widget.mood.emoji,
                                style: const TextStyle(fontSize: 36)),
                            const SizedBox(width: 16),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.mood.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800)),
                                Text('needs attention ♡',
                                    style: TextStyle(
                                        color:
                                            Colors.white.withOpacity(0.8),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(widget.mood.emoji,
                                style: const TextStyle(fontSize: 38)),
                            const SizedBox(height: 10),
                            Text(widget.mood.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800)),
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

// ─── MOOD DIALOG ──────────────────────────────────────────────────────────────

class _MoodDialog extends StatefulWidget {
  final MoodData mood;
  final Function(String, {String message}) onSend;
  const _MoodDialog({required this.mood, required this.onSend});

  @override
  State<_MoodDialog> createState() => _MoodDialogState();
}

class _MoodDialogState extends State<_MoodDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _ctrl = TextEditingController();
  late AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.88,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                  color: widget.mood.color.withOpacity(0.3),
                  blurRadius: 48,
                  spreadRadius: 4)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.mood.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Column(children: [
                  Text(widget.mood.emoji,
                      style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text('Feeling ${widget.mood.name}?',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Send a little note to your person',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13)),
                ]),
              ),
              // Body
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  Container(
                    decoration: BoxDecoration(
                      color: widget.mood.color.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: widget.mood.color.withOpacity(0.15)),
                    ),
                    child: TextField(
                      controller: _ctrl,
                      maxLines: 4,
                      autofocus: true,
                      style: TextStyle(
                          color: SS.textDark,
                          fontSize: 15,
                          fontFamily: 'Quicksand'),
                      decoration: InputDecoration(
                        hintText: "What's on your heart... 💭",
                        hintStyle: TextStyle(
                            color: SS.textLight, fontFamily: 'Quicksand'),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      widget.onSend(widget.mood.name,
                          message: _ctrl.text);
                      Navigator.pop(context);
                    },
                    child: AnimatedBuilder(
                      animation: _shimmer,
                      builder: (_, __) => Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: widget.mood.gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                                color: widget.mood.color.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6))
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Send to Partner',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel',
                        style:
                            TextStyle(color: SS.textLight, fontSize: 14)),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── HISTORY TAB ──────────────────────────────────────────────────────────────

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  MoodData _getMoodData(String mood) {
    switch (mood) {
      case 'Happy':
        return MoodData('Happy', '😊', const Color(0xFFFF6B9D),
            [const Color(0xFFFF6B9D), const Color(0xFFFF9AC5)]);
      case 'Sad':
        return MoodData('Sad', '🥺', const Color(0xFF6B9DFF),
            [const Color(0xFF6B9DFF), const Color(0xFF9AC5FF)]);
      case 'Needy':
        return MoodData('Needy', '🥰', const Color(0xFFE91E63),
            [const Color(0xFFFF6B9D), const Color(0xFFB57BEE)]);
      case 'Sleepy':
        return MoodData('Sleepy', '😴', const Color(0xFF9D6BFF),
            [const Color(0xFF9D6BFF), const Color(0xFFC09AFF)]);
      case 'Angry':
        return MoodData('Angry', '😤', const Color(0xFFFF8C6B),
            [const Color(0xFFFF8C6B), const Color(0xFFFFAA8C)]);
      default:
        return MoodData('Unknown', '💭', SS.textLight, [SS.textLight, SS.lavLight]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref().child('moods');
    return SafeArea(
      bottom: false,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('SOULSYNC',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: SS.rose,
                        letterSpacing: 3)),
                Text('Mood Journey',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: SS.textDark)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: SS.rose.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('All time',
                    style: TextStyle(
                        color: SS.rose,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<DatabaseEvent>(
            stream: ref.onValue,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                        color: SS.rose, strokeWidth: 2));
              }
              if (!snap.hasData || snap.data!.snapshot.value == null) {
                return _buildEmpty();
              }
              final map = snap.data!.snapshot.value as Map<dynamic, dynamic>;
              final list = map.values.toList()
                ..sort((a, b) =>
                    (b['timestamp'] as int).compareTo(a['timestamp'] as int));

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final item = list[i];
                  final moodData = _getMoodData(item['mood'] ?? '');
                  final dt = DateTime.fromMillisecondsSinceEpoch(
                      item['timestamp'] as int);
                  return _HistoryCard(
                    mood: moodData,
                    message: item['message'] ?? '',
                    time: DateFormat('h:mm a').format(dt),
                    date: _formatDate(dt),
                    delay: Duration(milliseconds: i * 60),
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.day == now.day) return 'Today';
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.day == yesterday.day) return 'Yesterday';
    return DateFormat('MMM d').format(dt);
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('💝', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        Text('No moods yet',
            style: TextStyle(
                color: SS.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Start syncing your heart with your partner!',
            style: TextStyle(color: SS.textLight, fontSize: 13)),
      ]),
    );
  }
}

// ─── HISTORY CARD ─────────────────────────────────────────────────────────────

class _HistoryCard extends StatefulWidget {
  final MoodData mood;
  final String message;
  final String time;
  final String date;
  final Duration delay;

  const _HistoryCard({
    required this.mood,
    required this.message,
    required this.time,
    required this.date,
    required this.delay,
  });

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
            begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: SS.card,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [SS.thinShadow],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Color accent bar
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: widget.mood.gradient,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Emoji avatar
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: widget.mood.gradient),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(widget.mood.emoji,
                                style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Feeling ${widget.mood.name}',
                                    style: TextStyle(
                                        color: SS.textDark,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(widget.time,
                                          style: TextStyle(
                                              color: SS.textLight,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600)),
                                      Text(widget.date,
                                          style: TextStyle(
                                              color: widget.mood.color,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ],
                              ),
                              if (widget.message.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: widget.mood.color.withOpacity(0.07),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '"${widget.message}"',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                        color: SS.textMid,
                                        height: 1.4),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4CAF50),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text('Synced successfully',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: SS.textLight,
                                        fontWeight: FontWeight.w600)),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
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

// ─── NFC TAB ──────────────────────────────────────────────────────────────────

class NFCTab extends StatefulWidget {
  const NFCTab({super.key});
  @override
  State<NFCTab> createState() => _NFCTabState();
}

class _NFCTabState extends State<NFCTab> with TickerProviderStateMixin {
  late AnimationController _ring1;
  late AnimationController _ring2;
  late AnimationController _ring3;
  late AnimationController _iconCtrl;

  @override
  void initState() {
    super.initState();
    _ring1 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
    _ring2 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
    _ring3 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
    _iconCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _ring2.forward(from: 0.33);
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _ring3.forward(from: 0.66);
    });
  }

  @override
  void dispose() {
    _ring1.dispose();
    _ring2.dispose();
    _ring3.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SOULSYNC',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: SS.rose,
                    letterSpacing: 3)),
            Text('NFC Sync',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: SS.textDark)),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ripple animation
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildRing(_ring3, 220, 0.0),
                          _buildRing(_ring2, 170, 0.0),
                          _buildRing(_ring1, 120, 0.0),
                          AnimatedBuilder(
                            animation: _iconCtrl,
                            builder: (_, __) => Transform.scale(
                              scale: 1.0 + 0.08 * _iconCtrl.value,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: SS.heroGrad,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: SS.rose.withOpacity(0.5),
                                        blurRadius: 24,
                                        spreadRadius: 4)
                                  ],
                                ),
                                child: const Icon(Icons.nfc_rounded,
                                    color: Colors.white, size: 36),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text('NFC Sync Ready',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: SS.textDark)),
                    const SizedBox(height: 10),
                    Text(
                      'Bring your devices together\nto sync instantly 💕',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15,
                          color: SS.textMid,
                          height: 1.6),
                    ),
                    const SizedBox(height: 36),
                    _buildNFCButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRing(AnimationController ctrl, double size, double startFrom) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final progress = ctrl.value;
        return Opacity(
          opacity: (1.0 - progress).clamp(0.0, 1.0) * 0.4,
          child: Container(
            width: size * (0.5 + 0.5 * progress),
            height: size * (0.5 + 0.5 * progress),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: SS.rose,
                width: 1.5,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNFCButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          gradient: SS.heroGrad,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [SS.softShadow],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.nfc_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Start NFC Scan',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}