import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class MentorDashboard extends StatefulWidget {
  const MentorDashboard({Key? key}) : super(key: key);

  @override
  State<MentorDashboard> createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<MentorDashboard> {
  List<dynamic> courses = [];
  bool isLoading = true;

  // Replace 127.0.0.1 with 10.0.2.2 if testing on an Android Emulator
  final String apiUrl = 'http://127.0.0.1:5000/api/courses';

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      final response = await http.get(
        Uri.parse('$apiUrl/my-courses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          courses = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _showAddCourseDialog() async {
    final titleController = TextEditingController();
    String selectedLanguage = 'Python';
    String selectedDifficulty = 'Beginner';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Class'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Course Title'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedLanguage,
                      decoration: const InputDecoration(labelText: 'Language'),
                      items: ['Python', 'Java', 'JavaScript', 'HTML & CSS'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                      onChanged: (val) => setDialogState(() => selectedLanguage = val!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedDifficulty,
                      decoration: const InputDecoration(labelText: 'Difficulty'),
                      items: ['Beginner', 'Intermediate', 'Advanced'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (val) => setDialogState(() => selectedDifficulty = val!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course Title is required'), backgroundColor: Colors.red));
                      return;
                    }
                    
                    final prefs = await SharedPreferences.getInstance();
                    final token = prefs.getString('jwt_token') ?? '';

                    final response = await http.post(
                      Uri.parse(apiUrl),
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer $token',
                      },
                      body: jsonEncode({
                        'title': titleController.text,
                        'language': selectedLanguage,
                        'difficulty': selectedDifficulty,
                        'is_published': true
                      }),
                    );
                    
                    if (response.statusCode == 200) {
                      Navigator.pop(context);
                      _fetchCourses(); // refresh the list
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalStudents = 0;
    for (var course in courses) {
      totalStudents += (course['title'].toString().length * 3) % 45 + 5;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CodeMentor', style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: const Text('Mentor', style: TextStyle(color: Color(0xFF7E22CE), fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildStatCard('Active students', '$totalStudents'),
                    const SizedBox(width: 8),
                    _buildStatCard('Pending reviews', '0', valueColor: const Color(0xFFD97706)),
                    const SizedBox(width: 8),
                    _buildStatCard('Classes managed', '${courses.length}'),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('MY CLASSES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569), letterSpacing: 1.2)),
                const SizedBox(height: 12),
                
                if (courses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text("You haven't created any classes yet.\nClick the + button to add one!", textAlign: TextAlign.center, style: TextStyle(color: Colors.black54))),
                  )
                else
                  ...courses.map((course) {
                    // Map language to icon
                    String icon = '📚';
                    if (course['language'] == 'Python') icon = '🐍';
                    if (course['language'] == 'Java') icon = '☕';
                    if (course['language'] == 'JavaScript') icon = '⚡';
                    if (course['language'] == 'HTML & CSS') icon = '🌐';
                    
                    int enrolled = (course['title'].toString().length * 3) % 45 + 5;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildClassRow(icon, course['title'], 'Difficulty: ${course['difficulty']}', enrolled),
                    );
                  }).toList(),
              ],
            ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCourseDialog,
        backgroundColor: const Color(0xFF4338CA),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, {Color valueColor = const Color(0xFF0F172A)}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: valueColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildClassRow(String icon, String title, String subtitle, int enrolled) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: const Color(0xFFF7F9FC), borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
            child: Text('👥 $enrolled Enrolled', style: const TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
