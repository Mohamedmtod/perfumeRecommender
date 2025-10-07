import 'package:aichat/switch.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

void main() {
  runApp(const PerfumeRecommendPage());
}

class PerfumeRecommendPage extends StatefulWidget {
  const PerfumeRecommendPage({super.key});

  @override
  State<PerfumeRecommendPage> createState() => _PerfumeRecommendPageState();
}

class _PerfumeRecommendPageState extends State<PerfumeRecommendPage> {
  final TextEditingController mainQ = TextEditingController();
  late String gender;
  late String q1;
  late String q2;
  late String q3;
  late TextEditingController userInput= TextEditingController();

  bool loading = false;
  List recommendations = [];

  final Dio api = Dio(
    BaseOptions(
      baseUrl:
          "https://web-production-bb6d7.up.railway.app/", // ✅ غيّر الـ IP لو السيرفر على جهاز تاني
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {"Content-Type": "application/json"},
    ),
  );

  Future<void> getRecommendations() async {
    setState(() => loading = true);

    final body = {
      "mainQ": mainQ.text,
      "gender": gender,
      "questions": [q1, q2, q3],
      "userInput": userInput.text,
    };

    try {
      final response = await api.post("/recommend", data: jsonEncode(body));

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          recommendations = data["recommendations"] ?? [];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } on DioException catch (e) {
      String message = "حدث خطأ أثناء الاتصال";
      if (e.type == DioExceptionType.connectionTimeout) {
        message = "انتهت مهلة الاتصال بالسيرفر";
      } else if (e.type == DioExceptionType.connectionError) {
        message = "تعذر الوصول للسيرفر، تحقق من الشبكة";
      } else if (e.response != null) {
        message = "خطأ من السيرفر: ${e.response?.statusCode}";
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => loading = false);
    }
  }

  Gender? selectedGender ;
  Strength? selectedStrength;
  Season? selectedSeason;
  Time? selectedTime;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text("Perfume Recommender")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              buttony(recommendations: recommendations),
              Text("النوع (رجالي / حريمي)"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyBtn(
                    clicked: selectedGender == Gender.female,

                    onTap: () {
                      selectedGender = Gender.female;

                      gender = "حريمي";
                      setState(() {});
                    },
                    text: "حريمي",
                  ),
                  MyBtn(
                    clicked: selectedGender == Gender.male,

                    onTap: () {
                      selectedGender = Gender.male;

                      gender = "رجالي";
                      setState(() {});
                    },
                    text: "رجالي",
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text("قوي ولا هادي؟"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyBtn(
                    clicked: selectedStrength == Strength.strong,
                    onTap: () {
                      selectedStrength = Strength.strong;
                      q1= "قوي";
                      setState(() {});
                    },
                    text: "قوي",
                  ),
                  MyBtn(
                    clicked: selectedStrength == Strength.weak,
                    onTap: () {
                      selectedStrength = Strength.weak;
                      q1= "هادي";
                      setState(() {});
                    },
                    text: "هادي",
                  ),
                
                ],
              ),
              const SizedBox(height: 10),
              Text("صيفي ولا شتوي؟"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   MyBtn(
                    clicked: selectedSeason == Season.summer,
                    onTap: () {
                      selectedSeason = Season.summer;
                      q2= "صيفي"; 
                      setState(() {});
                    },
                    text: "صيفي",
                    
                  ),
                  MyBtn(
                    clicked: selectedSeason == Season.winter,
                    onTap: () {
                      selectedSeason = Season.winter;
                      q2= "شتوي";
                      setState(() {});
                    },
                    text: "شتوي",
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text("صباحي ولا مسائي؟"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyBtn(
                    clicked: selectedTime == Time.morning,
                    onTap: () {
                      selectedTime = Time.morning;
                      q3= "صباحي";
                      setState(() {});
                    },
                    text: "صباحي",
                  ),
                  MyBtn(
                    clicked: selectedTime == Time.night,
                    onTap: () {
                      selectedTime = Time.night;
                      q3= "مسائي";
                      setState(() {});
                    },
                    text: "مسائي",
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  myTxtField(
                    mainQ,
                    "التركيز الأساسي (توابل / فانيليا / ورود...)",
                  ),

                  myTxtField(userInput, "مواصفات إضافية (اختياري)"),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: loading ? null : getRecommendations,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("عرض الترشيحات"),
                  ),

                  const SizedBox(height: 24),

                  if (recommendations.isNotEmpty)
                    const Text(
                      "الترشيحات:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  const SizedBox(height: 12),

                  for (var rec in recommendations)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.local_florist),
                        title: Text(rec["name"]),
                        subtitle: Text("نسبة التطابق: ${rec["score"]}%"),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget myTxtField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class buttony extends StatelessWidget {
  const buttony({super.key, required this.recommendations});

  final List recommendations;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("logg: ${recommendations},   ${recommendations.length}");
      },
      child: Container(width: 200, height: 50, color: Colors.black),
    );
  }
}

class MyBtn extends StatelessWidget {
  final bool clicked;

  final VoidCallback onTap;
  final String text;

  const MyBtn({
    super.key,
    required this.clicked,

    required this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        height: 50,
        width: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: clicked ? Colors.red : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text(text)),
      ),
    );
  }
}
