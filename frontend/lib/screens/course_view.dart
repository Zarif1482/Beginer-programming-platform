import 'package:flutter/material.dart';

class CourseView extends StatefulWidget {
  final String courseTitle;
  final String courseIcon;

  const CourseView({super.key, required this.courseTitle, required this.courseIcon});

  @override
  State<CourseView> createState() => _CourseViewState();
}

class _CourseViewState extends State<CourseView> {
  int currentLessonIndex = 0;
  
  // Simulated modules for UI presentation
  final List<String> modules = [
    'Variables & types',
    'Control flow',
    'Functions',
    'Lists & dicts',
    'Object Oriented Programming',
  ];

  void _nextLesson() {
    if (currentLessonIndex < modules.length - 1) {
      setState(() {
        currentLessonIndex++;
      });
    } else {
      // Course completed
      Navigator.pop(context);
    }
  }

  void _previousLesson() {
    if (currentLessonIndex > 0) {
      setState(() {
        currentLessonIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // calculate overall progress % based strictly on indexing for milestone
    int completePercent = (currentLessonIndex / modules.length * 100).round();
    if (currentLessonIndex == modules.length - 1 && currentLessonIndex > 0) completePercent = 100; // max

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.courseIcon} ${widget.courseTitle}',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              '$completePercent% complete',
              style: const TextStyle(
                color: Color(0xFF4338CA),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar
          Container(
            width: 180,
            color: const Color(0xFFF7F9FC),
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                const Text(
                  'MODULES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(modules.length, (index) {
                  return _buildSidebarItem(
                    '${index + 1}. ${modules[index]}',
                    isActive: currentLessonIndex == index,
                    isCompleted: index < currentLessonIndex,
                    isLocked: index > currentLessonIndex,
                  );
                }),
                const Divider(),
                _buildSidebarItem('💬 Q&A forum', isLocked: true),
                _buildSidebarItem('📝 Assignments', isLocked: true),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lesson ${currentLessonIndex + 1} — ${modules[currentLessonIndex]}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This is interactive module content. Finish examining the content below before marking it completely done to proceed.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF475569),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '# Example Content for ${modules[currentLessonIndex]}\n\nprint("Welcome to ${modules[currentLessonIndex]}")',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Color(0xFFF8FAFC),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'LESSON PROGRESS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  ...List.generate(modules.length, (index) {
                     return _buildProgressRow(
                      index < currentLessonIndex ? '✓' : '${index + 1}',
                      'Lesson ${index + 1} — ${modules[index]}' + (currentLessonIndex == index ? ' (current)' : ''),
                      index < currentLessonIndex,
                      index == currentLessonIndex,
                    );
                  }),

                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: currentLessonIndex > 0 ? _previousLesson : null,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: currentLessonIndex > 0 ? const Color(0xFFE2E8F0) : Colors.transparent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('← Previous'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _nextLesson,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4338CA),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            currentLessonIndex == modules.length - 1 ? 'Finish course' : 'Mark complete & next →',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    String title, {
    bool isActive = false,
    bool isCompleted = false,
    bool isLocked = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: isActive ? Border.all(color: const Color(0xFFE2E8F0)) : null,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isLocked
              ? const Color(0xFF94A3B8)
              : (isActive ? const Color(0xFF0F172A) : const Color(0xFF475569)),
        ),
      ),
    );
  }

  Widget _buildProgressRow(
    String number,
    String title,
    bool isDone,
    bool isCurrent,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFFEEF2FF) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrent ? const Color(0xFFC7D2FE) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isDone
                  ? const Color(0xFF10B981)
                  : (isCurrent
                        ? const Color(0xFF4338CA)
                        : const Color(0xFFF1F5F9)),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: TextStyle(
                color: (isDone || isCurrent)
                    ? Colors.white
                    : const Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent
                  ? const Color(0xFF4338CA)
                  : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}
