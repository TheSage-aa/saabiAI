import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/topic.dart';

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository(Supabase.instance.client);
});

class LibraryRepository {
  LibraryRepository(this._client);
  final SupabaseClient _client;

  // ─── Verified Topics ───────────────────────────────────────────────────────

  static const List<Topic> fallbackTopics = [
    Topic(
      id: 'hiv-stis',
      slug: 'hiv-stis',
      title: 'HIV & STIs',
      description: 'Facts on HIV prevention, testing, U=U, and common infections.',
      colorHex: '#1B3A8C',
      sortOrder: 1,
    ),
    Topic(
      id: 'reproductive',
      slug: 'reproductive',
      title: 'Reproductive Health',
      description: 'Understanding menstrual health, consent, and bodily autonomy.',
      colorHex: '#C026D3',
      sortOrder: 2,
    ),
    Topic(
      id: 'mental-health',
      slug: 'mental-health',
      title: 'Mental Health',
      description: 'Dealing with stress, burnout, emotional wellness, and finding care.',
      colorHex: '#7C3AED',
      sortOrder: 3,
    ),
    Topic(
      id: 'nutrition',
      slug: 'nutrition',
      title: 'Nutrition & Wellness',
      description: 'Affordable balanced meals, hydration, and healthy daily habits.',
      colorHex: '#059669',
      sortOrder: 4,
    ),
    Topic(
      id: 'family-planning',
      slug: 'family-planning',
      title: 'Family Planning',
      description: 'Safe choices, contraception methods, and planning your future.',
      colorHex: '#D97706',
      sortOrder: 5,
    ),
    Topic(
      id: 'malaria',
      slug: 'malaria',
      title: 'Malaria & Illness',
      description: 'Prevention, symptoms, rapid diagnosis, and effective treatment.',
      colorHex: '#0D9488',
      sortOrder: 6,
    ),
  ];

  // ─── Full Lesson Curriculum ────────────────────────────────────────────────

  static const Map<String, List<Lesson>> fallbackLessonsByTopic = {
    'hiv-stis': [
      Lesson(
        id: 'hiv-101',
        topicId: 'hiv-stis',
        title: 'What is HIV?',
        bodyText:
            'HIV (Human Immunodeficiency Virus) is a virus that targets your body\'s immune system, specifically CD4 cells (T cells). Without treatment, it becomes harder for your body to fight off everyday infections. With modern antiretroviral treatment (ART), people with HIV live long, full, and active lives.',
        sortOrder: 1,
        xpReward: 10,
      ),
      Lesson(
        id: 'hiv-transmission',
        topicId: 'hiv-stis',
        title: 'How HIV is Transmitted',
        bodyText:
            'HIV can only be transmitted through specific body fluids: blood, semen, vaginal fluids, and breast milk. You CANNOT contract HIV from hugging, shaking hands, sharing cups, toilet seats, or mosquito bites. Transmission primarily occurs through unprotected sex or sharing needles.',
        sortOrder: 2,
        xpReward: 10,
      ),
      Lesson(
        id: 'hiv-prevention',
        topicId: 'hiv-stis',
        title: 'Prevention Methods & PrEP',
        bodyText:
            'Consistent condom use provides strong barrier protection against HIV and other STIs. Pre-Exposure Prophylaxis (PrEP) is a daily pill taken by HIV-negative individuals to prevent infection. Post-Exposure Prophylaxis (PEP) must be started within 72 hours of possible exposure.',
        sortOrder: 3,
        xpReward: 10,
      ),
      Lesson(
        id: 'hiv-testing',
        topicId: 'hiv-stis',
        title: 'Testing and Treatment (U=U)',
        bodyText:
            'HIV testing is quick, free, and completely confidential at public clinics across Nigeria. Rapid tests take under 20 minutes. Undetectable = Untransmittable (U=U) means taking daily treatment reduces viral levels so much that it cannot be passed to sexual partners.',
        sortOrder: 4,
        xpReward: 10,
      ),
      Lesson(
        id: 'hiv-living',
        topicId: 'hiv-stis',
        title: 'Living Well with HIV',
        bodyText:
            'People living with HIV study, work, marry, and have healthy HIV-free children. Taking prescribed daily antiretroviral drugs and eating balanced food preserves vitality. Overcoming stigma starts with knowing and sharing the medical facts.',
        sortOrder: 5,
        xpReward: 10,
      ),
    ],

    'reproductive': [
      Lesson(
        id: 'srh-understanding',
        topicId: 'reproductive',
        title: 'Understanding Your Body',
        bodyText:
            'Your reproductive anatomy and endocrine system are unique to you. Hormones like estrogen, progesterone, and testosterone regulate growth, moods, physical changes, and reproductive cycles throughout your life.',
        sortOrder: 1,
        xpReward: 10,
      ),
      Lesson(
        id: 'srh-menstrual',
        topicId: 'reproductive',
        title: 'Menstrual Health & Hygiene',
        bodyText:
            'A typical menstrual cycle lasts 21 to 35 days. Tracking your cycle helps predict ovulation and understand natural body rhythms. Using clean, breathable sanitary materials and changing them regularly prevents infections.',
        sortOrder: 2,
        xpReward: 10,
      ),
      Lesson(
        id: 'srh-contraception',
        topicId: 'reproductive',
        title: 'Contraception Options',
        bodyText:
            'Contraception gives you autonomy over if and when to have children. Methods include barrier methods (male and female condoms), hormonal methods (pills, injections, implants), and emergency contraception. Condoms are the only method that also protects against STIs.',
        sortOrder: 3,
        xpReward: 10,
      ),
      Lesson(
        id: 'srh-relationships',
        topicId: 'reproductive',
        title: 'Healthy Relationships & Consent',
        bodyText:
            'Consent must always be freely given, reversible, informed, and enthusiastic. Healthy relationships are built on mutual respect, active communication, and clear boundaries without manipulation or pressure.',
        sortOrder: 4,
        xpReward: 10,
      ),
      Lesson(
        id: 'srh-prenatal',
        topicId: 'reproductive',
        title: 'Pregnancy & Prenatal Care',
        bodyText:
            'Prenatal care ensures health for both mother and child. Early visits to a certified healthcare facility, folic acid supplements, and routine blood tests prevent complications and promote safe development.',
        sortOrder: 5,
        xpReward: 10,
      ),
    ],

    'mental-health': [
      Lesson(
        id: 'mh-whatis',
        topicId: 'mental-health',
        title: 'What is Mental Health?',
        bodyText:
            'Mental health encompasses your emotional, psychological, and social wellbeing. It affects how you think, feel, and make choices. Having mental health challenges is common and not a sign of personal weakness.',
        sortOrder: 1,
        xpReward: 10,
      ),
      Lesson(
        id: 'mh-stress',
        topicId: 'mental-health',
        title: 'Managing Stress & Anxiety',
        bodyText:
            'Stress is the natural response to high demands. When stress becomes persistent, it leads to burnout. Box breathing, journaling, light physical exercise, and setting boundaries help regulate your nervous system.',
        sortOrder: 2,
        xpReward: 10,
      ),
      Lesson(
        id: 'mh-resilience',
        topicId: 'mental-health',
        title: 'Building Emotional Resilience',
        bodyText:
            'Resilience is the ability to adapt to adversity and bounce back. Building supportive social connections, practicing positive self-talk, and learning problem-solving skills cultivate long-term mental resilience.',
        sortOrder: 3,
        xpReward: 10,
      ),
      Lesson(
        id: 'mh-sleep',
        topicId: 'mental-health',
        title: 'Sleep & Mental Wellness',
        bodyText:
            'Sleep is crucial for brain memory consolidation and emotional regulation. Aim for 7 to 9 hours of quality rest. Limiting screen time before bed and keeping a consistent schedule improve mental clarity.',
        sortOrder: 4,
        xpReward: 10,
      ),
      Lesson(
        id: 'mh-seekhelp',
        topicId: 'mental-health',
        title: 'When to Seek Help',
        bodyText:
            'If sadness, anxiety, or feelings of hopelessness interfere with daily functioning for more than two weeks, seek support from a professional counselor or helpline. Confidential mental healthcare is available in Nigeria.',
        sortOrder: 5,
        xpReward: 10,
      ),
    ],

    'nutrition': [
      Lesson(
        id: 'nutr-basics',
        topicId: 'nutrition',
        title: 'Everyday Balanced Nutrition',
        bodyText:
            'A balanced diet balances carbohydrates, proteins, healthy fats, vitamins, and minerals. Fresh local fruits and vegetables provide natural antioxidants that strengthen your immune system.',
        sortOrder: 1,
        xpReward: 10,
      ),
      Lesson(
        id: 'nutr-budget',
        topicId: 'nutrition',
        title: 'Eating Well on a Nigerian Budget',
        bodyText:
            'Local foods like beans, eggs, groundnuts, ugwu, waterleaf, and local fish offer superior nutrition at reasonable costs compared to processed foods. Variety is key to meeting daily nutritional needs.',
        sortOrder: 2,
        xpReward: 10,
      ),
      Lesson(
        id: 'nutr-hydration',
        topicId: 'nutrition',
        title: 'Hydration and Vitality',
        bodyText:
            'Water regulates body temperature, supports digestion, and prevents fatigue. Drink plenty of clean, safe water throughout the day, especially in tropical climates.',
        sortOrder: 3,
        xpReward: 10,
      ),
      Lesson(
        id: 'nutr-habits',
        topicId: 'nutrition',
        title: 'Building Lifelong Healthy Habits',
        bodyText:
            'Mindful eating, reducing excessive salt and refined sugars, and maintaining moderate daily movement protect against chronic illnesses like hypertension and type 2 diabetes.',
        sortOrder: 4,
        xpReward: 10,
      ),
    ],

    'family-planning': [
      Lesson(
        id: 'fp-basics',
        topicId: 'family-planning',
        title: 'Introduction to Family Planning',
        bodyText:
            'Family planning enables couples and individuals to anticipate and attain their desired number of children and spacing between births. It improves maternal and child health outcomes.',
        sortOrder: 1,
        xpReward: 10,
      ),
      Lesson(
        id: 'fp-methods',
        topicId: 'family-planning',
        title: 'Short & Long Acting Methods',
        bodyText:
            'Methods include daily oral pills, injectable contraceptives (Depo-Provera), and long-acting reversible options like intrauterine devices (IUDs) and sub-dermal implants.',
        sortOrder: 2,
        xpReward: 10,
      ),
      Lesson(
        id: 'fp-myths',
        topicId: 'family-planning',
        title: 'Common Misconceptions Busted',
        bodyText:
            'Contraceptives do NOT cause permanent infertility. Once hormonal methods are stopped, fertility returns naturally. Consulting a trained nurse helps address side effects.',
        sortOrder: 3,
        xpReward: 10,
      ),
      Lesson(
        id: 'fp-consultation',
        topicId: 'family-planning',
        title: 'Choosing What is Right For You',
        bodyText:
            'Every person\'s medical profile and life stage is different. Discuss your medical history, goals, and lifestyle with a healthcare provider to choose an ideal method.',
        sortOrder: 4,
        xpReward: 10,
      ),
    ],

    'malaria': [
      Lesson(
        id: 'mal-basics',
        topicId: 'malaria',
        title: 'Understanding Malaria & Mosquitoes',
        bodyText:
            'Malaria is caused by the Plasmodium parasite and transmitted by the bite of an infected female Anopheles mosquito. Mosquitoes typically bite between dusk and dawn.',
        sortOrder: 1,
        xpReward: 10,
      ),
      Lesson(
        id: 'mal-prevention',
        topicId: 'malaria',
        title: 'Insecticide Nets & Vector Control',
        bodyText:
            'Sleeping under Long-Lasting Insecticidal Nets (LLINs) is the most effective defense against malaria. Eliminating stagnant water around compounds prevents mosquito breeding.',
        sortOrder: 2,
        xpReward: 10,
      ),
      Lesson(
        id: 'mal-symptoms',
        topicId: 'malaria',
        title: 'Recognising Symptoms Early',
        bodyText:
            'Symptoms include high fever, chills, profuse sweating, headaches, and joint pains. In young children and pregnant women, malaria can progress rapidly if untreated.',
        sortOrder: 3,
        xpReward: 10,
      ),
      Lesson(
        id: 'mal-treatment',
        topicId: 'malaria',
        title: 'Rapid Testing (RDT) & ACT Drugs',
        bodyText:
            'Always test before treating! A Rapid Diagnostic Test (RDT) provides results in 15 minutes. Artemisinin-based Combination Therapy (ACT) is the recommended first-line cure.',
        sortOrder: 4,
        xpReward: 10,
      ),
    ],
  };

  // ─── Quizzes per Lesson ───────────────────────────────────────────────────

  static const Map<String, List<QuizQuestion>> fallbackQuizzesByLesson = {
    'hiv-101': [
      QuizQuestion(
        id: 'q-hiv-1',
        lessonId: 'hiv-101',
        questionText: 'What does HIV stand for?',
        options: [
          QuizOption(text: 'Human Immune Variance', isCorrect: false),
          QuizOption(text: 'Human Immunodeficiency Virus', isCorrect: true),
          QuizOption(text: 'Health Immunity Vaccine', isCorrect: false),
        ],
        explanation: 'HIV stands for Human Immunodeficiency Virus, which targets CD4 immune cells.',
      ),
      QuizQuestion(
        id: 'q-hiv-2',
        lessonId: 'hiv-101',
        questionText: 'Can people living with HIV on medication live full, healthy lives?',
        options: [
          QuizOption(text: 'Yes, with daily modern treatment', isCorrect: true),
          QuizOption(text: 'No, medication cannot help', isCorrect: false),
        ],
        explanation: 'Daily antiretroviral therapy (ART) keeps the immune system strong and healthy.',
      ),
    ],
    'hiv-transmission': [
      QuizQuestion(
        id: 'q-hiv-3',
        lessonId: 'hiv-transmission',
        questionText: 'Can mosquito bites transmit HIV?',
        options: [
          QuizOption(text: 'Yes, if the mosquito bites two people', isCorrect: false),
          QuizOption(text: 'No, mosquitoes cannot transmit HIV', isCorrect: true),
        ],
        explanation: 'HIV cannot survive or reproduce inside mosquitoes. Insects do not transmit HIV.',
      ),
    ],
    'srh-understanding': [
      QuizQuestion(
        id: 'q-srh-1',
        lessonId: 'srh-understanding',
        questionText: 'Which system produces hormones that regulate development and cycles?',
        options: [
          QuizOption(text: 'Endocrine system', isCorrect: true),
          QuizOption(text: 'Digestive system', isCorrect: false),
          QuizOption(text: 'Respiratory system', isCorrect: false),
        ],
        explanation: 'The endocrine system releases vital hormones like estrogen, progesterone, and testosterone.',
      ),
    ],
    'srh-menstrual': [
      QuizQuestion(
        id: 'q-srh-2',
        lessonId: 'srh-menstrual',
        questionText: 'What is the typical length of a healthy menstrual cycle?',
        options: [
          QuizOption(text: '7 to 10 days', isCorrect: false),
          QuizOption(text: '21 to 35 days', isCorrect: true),
          QuizOption(text: '60 to 90 days', isCorrect: false),
        ],
        explanation: 'A normal menstrual cycle typically ranges between 21 and 35 days.',
      ),
    ],
    'mh-whatis': [
      QuizQuestion(
        id: 'q-mh-1',
        lessonId: 'mh-whatis',
        questionText: 'Is experiencing mental health challenges a sign of personal weakness?',
        options: [
          QuizOption(text: 'No, it is a health condition that can be managed', isCorrect: true),
          QuizOption(text: 'Yes, it only happens to weak people', isCorrect: false),
        ],
        explanation: 'Mental health is part of overall health, and seeking help is a courageous sign of strength.',
      ),
    ],
    'nutr-basics': [
      QuizQuestion(
        id: 'q-nutr-1',
        lessonId: 'nutr-basics',
        questionText: 'Why are leafy green vegetables like ugwu valuable in daily meals?',
        options: [
          QuizOption(text: 'They provide vitamins, iron, and fiber', isCorrect: true),
          QuizOption(text: 'They replace the need to drink water', isCorrect: false),
        ],
        explanation: 'Local leafy greens are rich in iron, micronutrients, and antioxidants.',
      ),
    ],
    'mal-basics': [
      QuizQuestion(
        id: 'q-mal-1',
        lessonId: 'mal-basics',
        questionText: 'Which mosquito transmits malaria?',
        options: [
          QuizOption(text: 'Female Anopheles mosquito', isCorrect: true),
          QuizOption(text: 'Housefly', isCorrect: false),
          QuizOption(text: 'Male Culex mosquito', isCorrect: false),
        ],
        explanation: 'The female Anopheles mosquito carries and transmits the Plasmodium parasite.',
      ),
    ],
  };

  // ─── API Methods ───────────────────────────────────────────────────────────

  Future<List<Topic>> getTopics() async {
    try {
      final data = await _client
          .from('topics')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      final list = (data as List)
          .map((e) => Topic.fromJson(e as Map<String, dynamic>))
          .toList();
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return fallbackTopics;
  }

  Future<List<Lesson>> getLessons(String topicId) async {
    try {
      final data = await _client
          .from('lessons')
          .select()
          .eq('topic_id', topicId)
          .eq('is_active', true)
          .order('sort_order');
      final list = (data as List)
          .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
          .toList();
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return fallbackLessonsByTopic[topicId] ??
        fallbackLessonsByTopic['hiv-stis']!;
  }

  Future<List<QuizQuestion>> getQuizQuestions(String lessonId) async {
    try {
      final data = await _client
          .from('quiz_questions')
          .select()
          .eq('lesson_id', lessonId)
          .order('sort_order');
      final list = (data as List)
          .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
          .toList();
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return fallbackQuizzesByLesson[lessonId] ??
        fallbackQuizzesByLesson['hiv-101']!;
  }

  Future<UserProgress> getUserStats(String userId) async {
    try {
      final data = await _client
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data != null) {
        return UserProgress.fromJson(data);
      }
    } catch (_) {}

    return const UserProgress(
      totalXp: 0,
      lessonsCompleted: 0,
      currentStreak: 1,
      longestStreak: 1,
    );
  }
}
