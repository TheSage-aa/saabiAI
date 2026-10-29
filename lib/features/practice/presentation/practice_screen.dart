import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/user_progress_service.dart';

class PracticeQuizItem {
  const PracticeQuizItem({
    required this.id,
    required this.topic,
    required this.title,
    required this.questionCount,
    required this.xpReward,
    required this.difficulty,
    required this.topicColor,
    required this.questions,
  });

  final String id;
  final String topic; // HIV, Nutrition, Mental, Reproductive
  final String title;
  final int questionCount;
  final int xpReward;
  final String difficulty; // Easy, Medium, Hard
  final Color topicColor;
  final List<PracticeQuestion> questions;
}

class PracticeQuestion {
  const PracticeQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

const _allQuizzes = [
  PracticeQuizItem(
    id: 'quiz-hiv-myths',
    topic: 'HIV',
    title: 'HIV Myths vs Facts',
    questionCount: 4,
    xpReward: 20,
    difficulty: 'Easy',
    topicColor: Color(0xFFEF4444),
    questions: [
      PracticeQuestion(
        question: 'Can you contract HIV by sharing a drinking cup or eating together?',
        options: [
          'Yes, through saliva',
          'No, HIV cannot be passed through casual contact',
          'Only if the cup is cold',
        ],
        correctIndex: 1,
        explanation: 'Saliva does not transmit HIV. Casual contact like sharing cups or utensils is 100% safe.',
      ),
      PracticeQuestion(
        question: 'What does the scientific term U=U stand for?',
        options: [
          'Universal & Unconditional',
          'Undetectable = Untransmittable',
          'Understood & Unaffected',
        ],
        correctIndex: 1,
        explanation: 'Undetectable viral load means the virus cannot be transmitted to sexual partners.',
      ),
      PracticeQuestion(
        question: 'How long does a confidential rapid finger-prick test take?',
        options: [
          'About 15 to 20 minutes',
          '3 to 4 weeks',
          '24 hours without eating',
        ],
        correctIndex: 0,
        explanation: 'Rapid test kits provide accurate results within 15–20 minutes at health facilities.',
      ),
      PracticeQuestion(
        question: 'What should someone take within 72 hours of potential HIV exposure?',
        options: [
          'Antibiotics',
          'Post-Exposure Prophylaxis (PEP)',
          'Painkillers',
        ],
        correctIndex: 1,
        explanation: 'PEP must be started within 72 hours to prevent HIV from taking hold in the body.',
      ),
    ],
  ),

  PracticeQuizItem(
    id: 'quiz-nutrition',
    topic: 'Nutrition',
    title: 'Nutrition Essentials',
    questionCount: 3,
    xpReward: 20,
    difficulty: 'Medium',
    topicColor: Color(0xFF10B981),
    questions: [
      PracticeQuestion(
        question: 'Which affordable local Nigerian foods are rich sources of dietary protein?',
        options: [
          'Cassava chips only',
          'Beans, eggs, fish, and groundnuts',
          'Soft drinks and sugar',
        ],
        correctIndex: 1,
        explanation: 'Beans, eggs, fish, and legumes provide vital protein for tissue repair and stamina.',
      ),
      PracticeQuestion(
        question: 'Why is hydration essential for cardiovascular and brain health?',
        options: [
          'It regulates body temperature and cellular function',
          'It replaces the need to sleep',
          'It prevents muscle growth',
        ],
        correctIndex: 0,
        explanation: 'Water supports digestion, circulation, mental focus, and metabolic waste clearance.',
      ),
      PracticeQuestion(
        question: 'Which vegetables are packed with natural iron and folate?',
        options: [
          'Ugwu (fluted pumpkin) and waterleaf',
          'White rice',
          'Plain bread',
        ],
        correctIndex: 0,
        explanation: 'Dark leafy greens are rich in iron, promoting red blood cell vitality and oxygen delivery.',
      ),
    ],
  ),

  PracticeQuizItem(
    id: 'quiz-mental',
    topic: 'Mental',
    title: 'Mental Health Check',
    questionCount: 3,
    xpReward: 15,
    difficulty: 'Easy',
    topicColor: Color(0xFF8B5CF6),
    questions: [
      PracticeQuestion(
        question: 'What is a healthy way to manage sudden anxiety or stress spikes?',
        options: [
          'Ignoring all feelings completely',
          'Deep box breathing and taking a grounding pause',
          'Skipping meals for days',
        ],
        correctIndex: 1,
        explanation: 'Controlled breathing calms the autonomic nervous system and relieves physical tension.',
      ),
      PracticeQuestion(
        question: 'Is experiencing depression or burnout a sign of weak willpower?',
        options: [
          'No, it is a medical condition deserving care',
          'Yes, people should just ignore it',
        ],
        correctIndex: 0,
        explanation: 'Mental health challenges are medical realities. Seeking support is a sign of courage.',
      ),
      PracticeQuestion(
        question: 'How much quality sleep do young adults generally require per night?',
        options: [
          '2 to 3 hours',
          '7 to 9 hours',
          '14 hours',
        ],
        correctIndex: 1,
        explanation: '7 to 9 hours of restorative sleep allows the brain to consolidate memory and regulate mood.',
      ),
    ],
  ),

  PracticeQuizItem(
    id: 'quiz-reproductive',
    topic: 'Reproductive',
    title: 'Reproductive Health',
    questionCount: 3,
    xpReward: 25,
    difficulty: 'Medium',
    topicColor: Color(0xFFEC4899),
    questions: [
      PracticeQuestion(
        question: 'Which contraceptive method is the ONLY one that also protects against STIs?',
        options: [
          'Birth control pills',
          'Male and female condoms',
          'Copper IUD',
        ],
        correctIndex: 1,
        explanation: 'Only barrier methods like condoms prevent both unwanted pregnancy and STIs.',
      ),
      PracticeQuestion(
        question: 'What characterizes authentic, healthy consent in relationships?',
        options: [
          'Freely given, informed, and reversible anytime',
          'Given once and permanent forever',
          'Assumed if someone stays silent',
        ],
        correctIndex: 0,
        explanation: 'Consent must be continuous, clear, voluntary, and can be withdrawn at any moment.',
      ),
      PracticeQuestion(
        question: 'What is the normal variation in human menstrual cycles?',
        options: [
          'Strictly 28 days for every human',
          '21 to 35 days can be completely healthy',
          'Cycles only occur twice a year',
        ],
        correctIndex: 1,
        explanation: 'Cycle lengths vary naturally between 21 and 35 days depending on body chemistry.',
      ),
    ],
  ),
];

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    const categories = ['All', 'HIV', 'Nutrition', 'Mental', 'Reproductive'];

    final filtered = _selectedCategory == 'All'
        ? _allQuizzes
        : _allQuizzes.where((q) => q.topic == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: SaabiColors.background,
      appBar: AppBar(
        backgroundColor: SaabiColors.background,
        elevation: 0,
        title: Text(
          'Health Quizzes',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: SaabiColors.textPrimary,
              ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.symmetric(
                horizontal: SaabiSpacing.lg, vertical: SaabiSpacing.sm),
            children: [
              // ── Ask Saabi AI Banner (Orange Figma banner) ──
              InkWell(
                onTap: () => context.go('/chat'),
                borderRadius: BorderRadius.circular(SaabiRadius.xl),
                child: Container(
                  padding: const EdgeInsets.all(SaabiSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(SaabiRadius.xl),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('🤖', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: SaabiSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ask Saabi AI',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Have a personal question? Get confidential answers.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SaabiSpacing.xl),

              Text(
                "Test what you've learned",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: SaabiColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: SaabiSpacing.md),

              // ── Filter Pills (All, HIV, Nutrition, Mental, Reproductive) ──
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: SaabiSpacing.sm),
                  itemBuilder: (_, i) {
                    final cat = categories[i];
                    final active = cat == _selectedCategory;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: SaabiSpacing.lg,
                            vertical: SaabiSpacing.sm),
                        decoration: BoxDecoration(
                          color: active ? SaabiColors.primary : SaabiColors.surface,
                          borderRadius:
                              BorderRadius.circular(SaabiRadius.full),
                          border: Border.all(
                            color: active
                                ? SaabiColors.primary
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: active
                                  ? Colors.white
                                  : SaabiColors.textPrimary,
                              fontWeight:
                                  active ? FontWeight.w700 : FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: SaabiSpacing.lg),

              // ── Quiz Cards List ──
              ...filtered.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: SaabiSpacing.md),
                    child: _QuizCard(item: item),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({required this.item});
  final PracticeQuizItem item;

  void _startQuiz(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InteractiveQuizModal(quiz: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _startQuiz(context),
      borderRadius: BorderRadius.circular(SaabiRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(SaabiSpacing.lg),
        decoration: BoxDecoration(
          color: SaabiColors.surface,
          borderRadius: BorderRadius.circular(SaabiRadius.xl),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Question badge icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.topicColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(SaabiRadius.lg),
              ),
              child: Center(
                child: Icon(
                  Icons.help_outline_rounded,
                  color: item.topicColor,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: SaabiSpacing.md),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: item.topicColor.withOpacity(0.12),
                          borderRadius:
                              BorderRadius.circular(SaabiRadius.sm),
                        ),
                        child: Text(
                          item.topic.toUpperCase(),
                          style: TextStyle(
                            color: item.topicColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.questionCount} Qs • ${item.xpReward} XP',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: SaabiColors.textHint,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: SaabiColors.textPrimary,
                        ),
                  ),
                ],
              ),
            ),

            // Difficulty Pill
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: item.difficulty == 'Easy'
                    ? const Color(0xFFECFDF5)
                    : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(SaabiRadius.full),
              ),
              child: Text(
                item.difficulty,
                style: TextStyle(
                  color: item.difficulty == 'Easy'
                      ? const Color(0xFF059669)
                      : const Color(0xFFD97706),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Interactive Practice Quiz Sheet ──────────────────────────────────────────

class _InteractiveQuizModal extends ConsumerStatefulWidget {
  const _InteractiveQuizModal({required this.quiz});
  final PracticeQuizItem quiz;

  @override
  ConsumerState<_InteractiveQuizModal> createState() =>
      _InteractiveQuizModalState();
}

class _InteractiveQuizModalState extends ConsumerState<_InteractiveQuizModal> {
  int _currentIndex = 0;
  int? _selected;
  bool _answered = false;
  int _score = 0;
  bool _completed = false;

  void _select(int i) {
    if (_answered) return;
    final isCorrect = i == widget.quiz.questions[_currentIndex].correctIndex;
    setState(() {
      _selected = i;
      _answered = true;
      if (isCorrect) _score++;
    });
  }

  void _next() {
    if (_currentIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selected = null;
        _answered = false;
      });
    } else {
      // Award XP
      ref.read(userProgressProvider.notifier).addXp(widget.quiz.xpReward);
      setState(() => _completed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.quiz.questions[_currentIndex];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: SaabiColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(SaabiSpacing.xl),
      child: _completed
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 60)),
                const SizedBox(height: SaabiSpacing.md),
                Text(
                  'Quiz Finished!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: SaabiSpacing.sm),
                Text(
                  'You scored $_score / ${widget.quiz.questions.length} correct',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: SaabiColors.textSecondary,
                      ),
                ),
                const SizedBox(height: SaabiSpacing.lg),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: SaabiColors.goldLight,
                    borderRadius: BorderRadius.circular(SaabiRadius.full),
                  ),
                  child: Text(
                    '+${widget.quiz.xpReward} XP Earned!',
                    style: const TextStyle(
                      color: Color(0xFFB45309),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: SaabiSpacing.xxl),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Continue'),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.quiz.title} (${_currentIndex + 1}/${widget.quiz.questions.length})',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: SaabiColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(SaabiRadius.full),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) /
                        widget.quiz.questions.length,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor:
                        AlwaysStoppedAnimation(widget.quiz.topicColor),
                  ),
                ),
                const SizedBox(height: SaabiSpacing.xl),

                Text(
                  q.question,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: SaabiSpacing.lg),

                Expanded(
                  child: ListView.separated(
                    itemCount: q.options.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: SaabiSpacing.sm),
                    itemBuilder: (_, i) {
                      final opt = q.options[i];
                      final isSelected = _selected == i;
                      final isCorrect = i == q.correctIndex;

                      Color bg = SaabiColors.background;
                      Color border = Colors.transparent;

                      if (_answered) {
                        if (isCorrect) {
                          bg = SaabiColors.greenLight;
                          border = SaabiColors.green;
                        } else if (isSelected) {
                          bg = const Color(0xFFFEE2E2);
                          border = SaabiColors.error;
                        }
                      }

                      return GestureDetector(
                        onTap: () => _select(i),
                        child: Container(
                          padding: const EdgeInsets.all(SaabiSpacing.lg),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius:
                                BorderRadius.circular(SaabiRadius.xl),
                            border: Border.all(color: border, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  opt,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                ),
                              ),
                              if (_answered && isCorrect)
                                const Icon(Icons.check_circle_rounded,
                                    color: SaabiColors.green),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                if (_answered) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: SaabiSpacing.md),
                    child: Text(
                      q.explanation,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: SaabiColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _next,
                    child: Text(_currentIndex <
                            widget.quiz.questions.length - 1
                        ? 'Next Question →'
                        : 'Finish Quiz'),
                  ),
                ],
              ],
            ),
    );
  }
}
