import 'package:flutter/material.dart';
import 'learning_mode_screen.dart';

class LanguagePreferenceScreen extends StatefulWidget {
  const LanguagePreferenceScreen({Key? key}) : super(key: key);

  @override
  State<LanguagePreferenceScreen> createState() => _LanguagePreferenceScreenState();
}

class _LanguagePreferenceScreenState extends State<LanguagePreferenceScreen> {
  String? _selectedLanguage = 'English';

  final List<Map<String, String>> _languages = [
    {'name': 'English', 'native': 'English'},
    {'name': 'Malay', 'native': 'Bahasa Melayu'},
    {'name': 'Indonesian', 'native': 'Bahasa Indonesia'},
    {'name': 'Iban', 'native': 'Jaku Iban'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Progress (Orange, empty, empty)
              Row(
                children: [
                  Expanded(child: Container(height: 4, color: const Color(0xFFFFC857))),
                  const SizedBox(width: 8),
                  Expanded(child: Container(height: 4, color: const Color(0xFFCBD5E1))),
                  const SizedBox(width: 8),
                  Expanded(child: Container(height: 4, color: const Color(0xFFCBD5E1))),
                ],
              ),
              const SizedBox(height: 40),
              
              const Text(
                'Choose your app language',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B365D),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select the language you want to use for the app interface',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 32),

              Expanded(
                child: ListView.separated(
                  itemCount: _languages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    final isSelected = _selectedLanguage == lang['name'];

                    return GestureDetector(
                      onTap: () => setState(() => _selectedLanguage = lang['name']),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF1B365D) : const Color(0xFFCBD5E1),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang['name']!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? const Color(0xFF1B365D) : const Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lang['native']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected ? const Color(0xFF1e40af) : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: Color(0xFF1B365D)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              ElevatedButton(
                onPressed: _selectedLanguage != null
                    ? () {
                        // Normally you would save this preference to Provider/LocalStorage here
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LearningModeScreen()),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B365D),
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Continue', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
