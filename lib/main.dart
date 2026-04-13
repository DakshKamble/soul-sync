import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SoulSyncApp());
}

class SoulSyncApp extends StatelessWidget {
  const SoulSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoulSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF0F5),
        primaryColor: const Color(0xFFE91E63),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF48FB1)),
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const HistoryTab(),
    const NFCTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _tabs[_currentIndex]),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFCE4EC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1)
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            backgroundColor: const Color(0xFFFCE4EC),
            elevation: 0,
            currentIndex: _currentIndex,
            selectedItemColor: const Color(0xFFD81B60),
            unselectedItemColor: const Color(0xFFF48FB1),
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
              BottomNavigationBarItem(icon: Icon(Icons.nfc), label: 'NFC'),
            ],
          ),
        ),
      ),
    );
  }
}

// --- HOME TAB WITH WARPING FEATURE ---
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('moods');
  final TextEditingController _messageController = TextEditingController();
  
  // Track which mood is currently expanded into a text box
  String? _editingMood;

  void _sendMood(String mood, {String? message}) async {
    try {
      await _database.push().set({
        'mood': mood,
        'message': message ?? "", // Added detailed message field
        'sender': 'Gargi',
        'timestamp': ServerValue.timestamp,
      });

      if (!mounted) return;
      
      setState(() {
        _editingMood = null;
        _messageController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message != null ? 'Message sent! 💌' : 'Synced $mood! 💕'),
          backgroundColor: const Color(0xFFD81B60),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      debugPrint("Error sending mood: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _editingMood = null), // Collapse if tapping outside
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('SoulSync', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFD81B60))),
            const SizedBox(height: 20),
            const Text('How are we feeling\ntoday?', textAlign: TextAlign.center, 
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF4A148C))),
            const SizedBox(height: 10),
            const Text('Hold a button to add a message', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 30),

            // Using Wrap instead of GridView to allow height expansion
            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: [
                _buildWarpingMoodCard('Happy', Icons.sentiment_very_satisfied, Colors.pinkAccent),
                _buildWarpingMoodCard('Sad', Icons.sentiment_dissatisfied, Colors.blueAccent),
                _buildWarpingMoodCard('Needy', Icons.favorite, Colors.redAccent, isFullWidth: true),
                _buildWarpingMoodCard('Sleepy', Icons.bedtime, Colors.deepPurple[300]!),
                _buildWarpingMoodCard('Angry', Icons.mood_bad, Colors.deepOrange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarpingMoodCard(String mood, IconData icon, Color color, {bool isFullWidth = false}) {
    bool isEditing = _editingMood == mood;
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = isFullWidth || isEditing ? screenWidth - 40 : (screenWidth - 55) / 2;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: cardWidth,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: isEditing ? color.withOpacity(0.3) : Colors.pink.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!isEditing) _sendMood(mood);
          },
          onLongPress: () {
            setState(() {
              _editingMood = mood;
              _messageController.clear();
            });
          },
          borderRadius: BorderRadius.circular(30),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: isEditing 
              ? _buildTextBoxUI(mood, color) 
              : _buildStandardCardUI(mood, icon, color, isFullWidth),
          ),
        ),
      ),
    );
  }

  // The UI when the button "Warps" into a text box
  Widget _buildTextBoxUI(String mood, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.edit_note, color: color, size: 20),
            const SizedBox(width: 8),
            Text('Message with $mood', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => setState(() => _editingMood = null),
            )
          ],
        ),
        TextField(
          controller: _messageController,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Type something special...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            filled: true,
            fillColor: color.withOpacity(0.05),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _sendMood(mood, message: _messageController.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('Send Detailed Mood'), SizedBox(width: 8), Icon(Icons.send, size: 16)],
          ),
        )
      ],
    );
  }

  // The original Icon/Text UI
  Widget _buildStandardCardUI(String mood, IconData icon, Color color, bool isFullWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isFullWidth ? 20 : 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.15)),
            child: Icon(icon, color: color, size: isFullWidth ? 40 : 28),
          ),
          const SizedBox(height: 10),
          Text(mood, style: TextStyle(fontSize: isFullWidth ? 20 : 16, fontWeight: FontWeight.bold)),
          if (isFullWidth) const Text('NEEDS ATTENTION NOW', style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1.2)),
        ],
      ),
    );
  }
}

// --- UPDATED HISTORY TAB TO SHOW MESSAGES ---
class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  Map<String, dynamic> _getMoodDetails(String mood) {
    switch (mood) {
      case 'Happy': return {'icon': Icons.sentiment_very_satisfied, 'color': Colors.pinkAccent};
      case 'Sad': return {'icon': Icons.sentiment_dissatisfied, 'color': Colors.blueAccent};
      case 'Needy': return {'icon': Icons.favorite, 'color': Colors.redAccent};
      case 'Sleepy': return {'icon': Icons.bedtime, 'color': Colors.deepPurple[300]};
      case 'Angry': return {'icon': Icons.mood_bad, 'color': Colors.deepOrange};
      default: return {'icon': Icons.help_outline, 'color': Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    final databaseRef = FirebaseDatabase.instance.ref().child('moods');

    return Column(
      children: [
        const SizedBox(height: 20),
        const Center(child: Text('SoulSync', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD81B60)))),
        const SizedBox(height: 10),
        const Text('RECENT HISTORY', style: TextStyle(letterSpacing: 2, color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 10),
        Expanded(
          child: StreamBuilder(
            stream: databaseRef.onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                Map<dynamic, dynamic> values = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                List<dynamic> list = [];
                values.forEach((key, values) => list.add(values));
                list.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    var item = list[index];
                    var details = _getMoodDetails(item['mood']);
                    DateTime date = DateTime.fromMillisecondsSinceEpoch(item['timestamp']);
                    String formattedTime = DateFormat('jm').format(date);

                    return _buildHistoryCard(
                      'Feeling ${item['mood']}',
                      formattedTime,
                      item['message'] ?? "", // Pass the message
                      details['icon'],
                      details['color'],
                    );
                  },
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return const Center(child: Text('No moods shared yet! 💕', style: TextStyle(color: Colors.grey)));
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(String title, String time, String message, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.1)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF2F5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(message, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.black87)),
                  ),
                ],
                const SizedBox(height: 4),
                const Text('Synced to partner', style: TextStyle(fontSize: 10, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NFCTab extends StatelessWidget {
  const NFCTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.nfc, size: 100, color: Color(0xFFF48FB1)),
          SizedBox(height: 40),
          Text('Ready to Sync', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF4A148C))),
          SizedBox(height: 20),
          Text('Hold your phone near the heart on your gift to unlock a surprise.', 
            textAlign: TextAlign.center, 
            style: TextStyle(fontSize: 18, color: Colors.grey)
          ),
        ],
      ),
    );
  }
}