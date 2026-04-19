import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class IbanAIService {
  Future<String> explainMistake(String userEntry, String correctEntry) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_secret_key_here') {
      return "[MOCK AI]: You typed '$userEntry' but it should be '$correctEntry'. The grammar is slightly different in Iban! (Please add OpenAI Key to .env to see real feedback)";
    }

    // Actual implementation can remain uncommented if they put a real key
    final prompt = "The user entered: '$userEntry'. The correct answer is: '$correctEntry'. Explain the mistake briefly.";

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey', // Replace OPENAI_API_KEY with GROQ_API_KEY
        },
        body: jsonEncode({
          'model': 'llama3-8b-8192', // Powerful, blazingly fast, and completely free mode
          'messages': [
            {'role': 'system', 'content': "You are an Iban language tutor. Explain things clearly and concisely."},
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        return "Failed to get explanation. Server returned ${response.statusCode}.";
      }
    } catch (e) {
      return "An error occurred while connecting to the BudiLingua AI tutor.";
    }
  }

  Future<String> chatWithBot(String message) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_secret_key_here') {
      return "[MOCK AI]: $message (Please add Groq Key to .env to see real feedback)";
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {'role': 'system', 'content': """You are LinguaBuddy, a friendly expert tutor for the Iban language (an indigenous language in Sarawak). 
IMPORTANT RULES:
- Do NOT confuse Iban with standard Malay. If a user asks for Iban, use strict Iban vocabulary.
- Keep responses concise, supportive, and playful. Make formatting readable.
- If you do not know a word with 100% certainty, admit you are still learning Iban!

Here is your core Iban-English memory bank:
# GREETINGS
- Brita / Nama berita? = How are you? / News
- Manah = Good / Fine
- Selamat Pagi = Good morning
- Selamat Siang = Good afternoon
- Selamat Lemai = Good night
- Selamat datai = Welcome
- Selamat jalai = Goodbye

# CORE QUESTIONS & PRONOUNS
- Sapa = Who (Sapa nama nuan? = What is your name?)
- Nama = What (Nama hal? = Why? / Nama pengawa dik? = What are you doing?)
- Dini / Ni = Where (Dini nuan diau? = Where do you live?)
- Bakani = How (Bakani ngaga tu? = How to do this?)
- Berapa = How much / How many
- Lapa = Why (Lapa nuan ketawa? = Why are you laughing?)
- Aku = I / Me
- Nuan / Dik = You

# PHRASES
- Aku diau ba... = I live in...
- Aku gawa ba... = I work at...
- Minta ampun = I am sorry
- Manah tok = This is good / cool
- Ka kini nuan? = Where are you going?
- Aram bekalala = Let's get to know each other
- Tama meh = Please come in

# FAMILY
- Apai = Father
- Indai = Mother
- Aki' = Grandfather
- Ini / Inik = Grandmother
- Anak = Child (Anak indu = daughter, Anak laki = son)
- Madi indu = Younger sister
- Madi laki = Younger brother
- Abang = Elder brother/sister
- Bini = Wife
- Kaban / Pangan = Friend
- Petunggal = Cousin
- Ayak = Uncle
- Ibuk = Aunt
"""},
            {'role': 'user', 'content': message}
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        final data = jsonDecode(response.body);
        final errorMessage = data['error']?['message'] ?? 'Unknown error';
        return "Failed to get response. Server returned ${response.statusCode}: $errorMessage";
      }
    } catch (e) {
      return "An error occurred while connecting to LinguaBuddy. $e";
    }
  }
}
