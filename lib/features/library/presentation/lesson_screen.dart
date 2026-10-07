import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../data/library_repository.dart';
import '../domain/topic.dart';

/// Represents a single "page" of a lesson (shown one at a time like the Figma)
class LessonPage {
  const LessonPage({required this.title, required this.body, this.callout});
  final String title;
  final String body;
  final String? callout;
}

final _lessonDetailProvider = FutureProvider.family<
    ({Lesson lesson, List<LessonPage> pages, List<QuizQuestion> questions}),
    ({String topicId, String lessonId})>((ref, arg) async {
  final repo = ref.watch(libraryRepositoryProvider);
  final questions = await repo.getQuizQuestions(arg.lessonId);
  final lessons = await repo.getLessons(arg.topicId);

  final matchingLesson = lessons.firstWhere(
    (l) => l.id == arg.lessonId,
    orElse: () => Lesson(
      id: arg.lessonId,
      topicId: arg.topicId,
      title: 'Health Lesson',
      bodyText: 'Learn the real facts about this health topic.',
      xpReward: 20,
    ),
  );

  // Generate multi-page content based on lessonId
  final List<LessonPage> pages;
  if (arg.lessonId == 'hiv-101') {
    pages = [
      const LessonPage(
        title: 'What is HIV?',
        body:
            'HIV (Human Immunodeficiency Virus) is a virus that attacks the body\'s immune system, specifically the CD4 cells (T cells), which help fight off infections. Without care, the immune system weakens over time.',
        callout:
            'With proper medication, people living with HIV can live long, full, and vibrant lives. Daily treatment protects your immune cells.',
      ),
      const LessonPage(
        title: 'Understanding U=U',
        body:
            'U=U stands for Undetectable = Untransmittable. When a person takes their antiretroviral therapy (ART) daily, the level of virus in their blood drops so low that medical tests cannot detect it.',
        callout:
            'An undetectable viral load means you cannot pass HIV to sexual partners. This is one of the greatest scientific advancements in health history.',
      ),
    ];
  } else if (arg.lessonId == 'hiv-transmission') {
    pages = [
      const LessonPage(
        title: 'How HIV is Transmitted',
        body:
            'HIV can only be passed through specific bodily fluids: blood, semen, vaginal fluids, and breast milk. The most common ways are unprotected sexual contact or sharing sharp instruments like needles.',
        callout:
            'Using condoms and testing together are two of the most reliable ways to stay protected.',
      ),
      const LessonPage(
        title: 'Common Myths Busted',
        body:
            'You CANNOT get HIV from hugging, shaking hands, sharing cups, toilet seats, or mosquito bites. HIV is fragile and cannot survive outside the human body or in insects.',
        callout:
            'Sharing facts with friends and family reduces stigma and builds a supportive community.',
      ),
    ];
  } else {
    pages = [
      LessonPage(
        title: matchingLesson.title,
        body: matchingLesson.bodyText,
        callout: 'Knowledge is power. Taking care of your health starts with accurate facts.',
      ),
    ];
  }

  return (lesson: matchingLesson, pages: pages, questions: questions);
});

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.topicId, required this.lessonId});
  final String topicId;
  final String lessonId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  int _pageIndex = 0;
  int _questionIndex = 0;
  int _correctAnswers = 0;
  int? _selectedOption;
  bool _answered = false;
  bool _inQuiz = false;

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(
      _lessonDetailProvider((topicId: widget.topicId, lessonId: widget.lessonId)),
    );

    return Scaffold(
      backgroundColor: SaabiColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: dataAsync.when(
              loading: () => const SaabiLoadingIndicator(),
              error: (_, __) => const SaabiErrorBanner(message: 'Could not load lesson.'),
              data: (data) {
                final pages = data.pages;
                final questions = data.questions;

                if (_inQuiz) {
                  return _QuizView(
                    questions: questions,
                    currentIndex: _questionIndex,
                    selectedOption: _selectedOption,
                    answered: _answered,
                    topicId: widget.topicId,
                    lessonId: widget.lessonId,
                    totalPages: pages.length,
                    onSelect: (i) {
                      if (_answered) return;
                      final correct = questions[_questionIndex].options[i].isCorrect;
                      setState(() {
                        _selectedOption = i;
                        _answered = true;
                        if (correct) _correctAnswers++;
                      });
                    },
                    onNext: () {
                      if (_questionIndex < questions.length - 1) {
                        setState(() {
                          _questionIndex++;
                          _selectedOption = null;
                          _answered = false;
                        });
                      } else {
                        // Mark complete
                        ref.read(libraryRepositoryProvider).completeLesson(
                              userId: 'device-user',
                              lessonId: widget.lessonId,
                              score: _correctAnswers,
                              maxScore: questions.length,
                              xpEarned: data.lesson.xpReward,
                            );
                        context.go(
                            '/learn/${widget.topicId}/lesson/${widget.lessonId}/complete');
                      }
                    },
                  );
                }

                return _PageView(
                  page: pages.isNotEmpty ? pages[_pageIndex] : null,
                  pageIndex: _pageIndex,
                  total: pages.length,
                  onClose: () => context.go('/learn/${widget.topicId}'),
                  onNext: () {
                    if (_pageIndex < pages.length - 1) {
                      setState(() => _pageIndex++);
                    } else {
                      if (questions.isNotEmpty) {
                        setState(() => _inQuiz = true);
                      } else {
                        context.go(
                            '/learn/${widget.topicId}/lesson/${widget.lessonId}/complete');
                      }
                    }
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PageView extends StatelessWidget {
  const _PageView({
    required this.page,
    required this.pageIndex,
    required this.total,
    required this.onClose,
    required this.onNext,
  });

  final LessonPage? page;
  final int pageIndex;
  final int total;
  final VoidCallback onClose;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final displayTotal = total == 0 ? 1 : total;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SaabiSpacing.lg, vertical: SaabiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar: X + progress bar + counter
          Row(
            children: [
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close,
                      size: 18, color: SaabiColors.textSecondary),
                ),
              ),
              const SizedBox(width: SaabiSpacing.md),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(SaabiRadius.full),
                  child: LinearProgressIndicator(
                    value: (pageIndex + 1) / displayTotal,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation(SaabiColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: SaabiSpacing.md),
              Text(
                '${pageIndex + 1}/$displayTotal',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SaabiColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: SaabiSpacing.xl),

          // Lesson title
          if (page != null)
            Text(page!.title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: SaabiSpacing.lg),

          // Body text
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (page != null)
                    Text(
                      page!.body,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(height: 1.7),
                    ),
                  if (page?.callout != null) ...[
                    const SizedBox(height: SaabiSpacing.xl),
                    // "Good to know" callout
                    Container(
                      padding: const EdgeInsets.all(SaabiSpacing.lg),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(SaabiRadius.lg),
                        border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('💡', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: SaabiSpacing.sm),
                              Text(
                                'Good to know',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: SaabiColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: SaabiSpacing.sm),
                          Text(page!.callout!,
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: SaabiSpacing.md),
          ElevatedButton(
            onPressed: onNext,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(pageIndex < total - 1 ? 'Next' : 'Take Quiz →'),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
          const SizedBox(height: SaabiSpacing.sm),
        ],
      ),
    );
  }
}

class _QuizView extends StatelessWidget {
  const _QuizView({
    required this.questions,
    required this.currentIndex,
    required this.selectedOption,
    required this.answered,
    required this.topicId,
    required this.lessonId,
    required this.totalPages,
    required this.onSelect,
    required this.onNext,
  });

  final List<QuizQuestion> questions;
  final int currentIndex;
  final int? selectedOption;
  final bool answered;
  final String topicId;
  final String lessonId;
  final int totalPages;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Center(
        child: ElevatedButton(
          onPressed: () => context.go('/learn/$topicId/lesson/$lessonId/complete'),
          child: const Text('Complete Lesson'),
        ),
      );
    }

    final q = questions[currentIndex];
    final progress = (currentIndex + 1) / questions.length;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SaabiSpacing.lg, vertical: SaabiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          Row(
            children: [
              GestureDetector(
                onTap: () => context.go('/learn/$topicId'),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close,
                      size: 18, color: SaabiColors.textSecondary),
                ),
              ),
              const SizedBox(width: SaabiSpacing.md),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(SaabiRadius.full),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation(SaabiColors.green),
                  ),
                ),
              ),
              const SizedBox(width: SaabiSpacing.md),
              Text(
                'Quiz ${currentIndex + 1}/${questions.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SaabiColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: SaabiSpacing.lg),

          // Saabi mascot banner
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                    color: SaabiColors.green, shape: BoxShape.circle),
                child: const Icon(Icons.sentiment_satisfied_alt,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: SaabiSpacing.md),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: SaabiSpacing.md, vertical: SaabiSpacing.sm),
                  decoration: BoxDecoration(
                    color: SaabiColors.background,
                    borderRadius: BorderRadius.circular(SaabiRadius.lg),
                  ),
                  child: Text(
                    "Great job reading! Let's check what you've learned.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SaabiSpacing.xl),

          // Question
          Text(q.questionText, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: SaabiSpacing.lg),

          // Options
          Expanded(
            child: ListView(
              children: q.options.asMap().entries.map((e) {
                final i = e.key;
                final opt = e.value;
                final selected = selectedOption == i;
                final isCorrect = opt.isCorrect;

                Color bgColor = SaabiColors.surface;
                Color borderColor = const Color(0xFFE5E7EB);
                Widget? trailing;

                if (answered) {
                  if (isCorrect) {
                    bgColor = SaabiColors.greenLight;
                    borderColor = SaabiColors.green;
                    trailing = Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                          color: SaabiColors.green, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 14),
                    );
                  } else if (selected) {
                    bgColor = const Color(0xFFFEE2E2);
                    borderColor = SaabiColors.error;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: SaabiSpacing.sm),
                  child: GestureDetector(
                    onTap: answered ? null : () => onSelect(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: SaabiSpacing.md, vertical: SaabiSpacing.md),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(SaabiRadius.xl),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: borderColor, width: 1.5),
                              color: answered && isCorrect
                                  ? SaabiColors.green
                                  : Colors.transparent,
                            ),
                          ),
                          const SizedBox(width: SaabiSpacing.md),
                          Expanded(
                            child: Text(opt.text,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ),
                          if (trailing != null) trailing,
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          if (answered) ...[
            if (q.explanation != null)
              Padding(
                padding: const EdgeInsets.only(bottom: SaabiSpacing.md),
                child: Text(
                  q.explanation!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SaabiColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            ElevatedButton(
              onPressed: onNext,
              child: Text(currentIndex < questions.length - 1
                  ? 'Next Question →'
                  : 'See Results →'),
            ),
          ],
          const SizedBox(height: SaabiSpacing.sm),
        ],
      ),
    );
  }
}
