import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart'; // Ensure you have intl: ^0.19.0 in pubspec.yaml
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

// --- HOME TAB ---
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('moods');
  
  void _sendMood(String mood) async {
    try {
      await _database.push().set({
        'mood': mood,
        'sender': 'Gargi', 
        'timestamp': ServerValue.timestamp,
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Synced $mood! 💕'),
          backgroundColor: const Color(0xFFD81B60),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Error sending mood: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text('SoulSync', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFD81B60))),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8BBD0).withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Mood Check-in', style: TextStyle(color: Color(0xFFAD1457))),
          ),
          const SizedBox(height: 20),
          const Text('How are we feeling\ntoday?', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF4A148C))),
          const SizedBox(height: 30),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _buildMoodCard('Happy', Icons.sentiment_very_satisfied, Colors.pinkAccent),
              _buildMoodCard('Sad', Icons.sentiment_dissatisfied, Colors.blueAccent),
            ],
          ),
          const SizedBox(height: 15),
          
          _buildBigNeedyButton(),
          
          const SizedBox(height: 15),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _buildMoodCard('Sleepy', Icons.bedtime, Colors.deepPurple[300]!),
              _buildMoodCard('Angry', Icons.mood_bad, Colors.deepOrange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBigNeedyButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: () => _sendMood('Needy'),
          borderRadius: BorderRadius.circular(30),
          splashColor: Colors.redAccent.withOpacity(0.2),
          child: const Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              children: [
                Icon(Icons.favorite, color: Colors.redAccent, size: 50),
                SizedBox(height: 10),
                Text('Needy', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text('NEEDS ATTENTION NOW', style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodCard(String mood, IconData icon, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: () => _sendMood(mood),
          borderRadius: BorderRadius.circular(30),
          splashColor: iconColor.withOpacity(0.2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(shape: BoxShape.circle, color: iconColor.withOpacity(0.2)),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(height: 10),
              Text(mood, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

// --- UPDATED HISTORY TAB (FUNCTIONAL) ---
class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  // Helper to get the right color/icon for each mood card in history
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
                // Converting Firebase data to a list we can work with
                Map<dynamic, dynamic> values = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                List<dynamic> list = [];
                values.forEach((key, values) => list.add(values));

                // Sort by timestamp (Newest first)
                list.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    var item = list[index];
                    var details = _getMoodDetails(item['mood']);
                    
                    // Format the timestamp
                    DateTime date = DateTime.fromMillisecondsSinceEpoch(item['timestamp']);
                    String formattedTime = DateFormat('jm').format(date); // e.g., 5:30 PM

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: _buildHistoryCard(
                        'Feeling ${item['mood']}',
                        formattedTime,
                        details['icon'],
                        details['color'],
                      ),
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

  Widget _buildHistoryCard(String title, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.2)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Synced to partner', style: TextStyle(fontSize: 12, color: Colors.black54)),
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
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.nfc, size: 100, color: Color(0xFFF48FB1)),
          const SizedBox(height: 40),
          const Text('Ready to Sync', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF4A148C))),
          const SizedBox(height: 20),
          const Text('Hold your phone near the heart on your gift to unlock a surprise.', 
            textAlign: TextAlign.center, 
            style: TextStyle(fontSize: 18, color: Colors.grey)
          ),
        ],
      ),
    );
  }
}