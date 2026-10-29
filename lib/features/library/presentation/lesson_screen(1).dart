import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/services/user_progress_service.dart';
import '../data/library_repository.dart';
import '../domain/topic.dart';

/// Represents a single "page" of a lesson (shown one at a time like Figma)
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
      bodyText:
          'Learn the verified facts about this topic and empower yourself to make healthy choices.',
      xpReward: 10,
    ),
  );

  // Generate rich multi-page reading content
  final List<LessonPage> pages = [];

  if (arg.lessonId == 'hiv-101') {
    pages.addAll([
      const LessonPage(
        title: 'What is HIV?',
        body:
            'HIV (Human Immunodeficiency Virus) is a virus that targets your body\'s immune system, specifically CD4 cells (T cells). Without treatment, the immune system weakens over time.',
        callout:
            'With modern antiretroviral therapy (ART), people with HIV live long, full, and vibrant lives. Daily medicine protects your cells.',
      ),
      const LessonPage(
        title: 'Understanding U=U',
        body:
            'U=U stands for Undetectable = Untransmittable. When a person takes their HIV medication consistently, the virus drops to undetectable levels in medical tests.',
        callout:
            'An undetectable viral load means you cannot pass HIV to sexual partners. This is one of modern medicine\'s greatest breakthroughs.',
      ),
    ]);
  } else if (arg.lessonId == 'hiv-transmission') {
    pages.addAll([
      const LessonPage(
        title: 'How HIV is Transmitted',
        body:
            'HIV can only be passed through specific bodily fluids: blood, semen, vaginal fluids, and breast milk. Transmission occurs primarily through unprotected sex or sharing needles.',
        callout:
            'Using condoms consistently and testing regularly are the two most effective ways to stay safe and confident.',
      ),
      const LessonPage(
        title: 'Common Myths Busted',
        body:
            'You CANNOT contract HIV from hugging, shaking hands, sharing cups, toilet seats, or mosquito bites. HIV is fragile and cannot survive outside the body or inside insects.',
        callout:
            'Sharing verified facts with friends stops fear and builds an informed, supportive community.',
      ),
    ]);
  } else if (arg.lessonId == 'srh-understanding') {
    pages.addAll([
      const LessonPage(
        title: 'Understanding Your Body',
        body:
            'Your reproductive system is regulated by endocrine hormones including estrogen, progesterone, and testosterone. These hormones guide physical changes and energy levels.',
        callout:
            'Understanding your body empowers you to notice changes, maintain personal health, and make informed decisions.',
      ),
      const LessonPage(
        title: 'Bodily Autonomy & Care',
        body:
            'Every person has the fundamental right to bodily autonomy. Regular self-checks, personal hygiene, and seeking medical advice when needed are pillars of self-care.',
        callout:
            'Never feel ashamed to ask a healthcare worker questions about reproductive wellness.',
      ),
    ]);
  } else if (arg.lessonId == 'mh-whatis') {
    pages.addAll([
      const LessonPage(
        title: 'What is Mental Health?',
        body:
            'Mental health includes emotional, psychological, and social wellbeing. It affects how you cope with life\'s stressors, relate to others, and make decisions.',
        callout:
            'Just like physical health, mental health fluctuates. Having difficult days is natural, and seeking support is a sign of strength.',
      ),
      const LessonPage(
        title: 'Nurturing Your Mind',
        body:
            'Simple daily routines like adequate sleep, talking with trusted peers, regular physical activity, and setting healthy boundaries preserve mental wellness.',
        callout:
            'If you ever feel overwhelmed, pause, breathe deeply, and reach out to someone you trust.',
      ),
    ]);
  } else {
    // Break the lesson bodyText into 2 structured pages
    final text = matchingLesson.bodyText;
    final midpoint = text.length > 200 ? text.indexOf('. ', 120) : -1;

    if (midpoint != -1) {
      pages.add(LessonPage(
        title: matchingLesson.title,
        body: text.substring(0, midpoint + 1),
        callout:
            'Taking small daily steps to learn about your health makes a lasting difference.',
      ));
      pages.add(LessonPage(
        title: 'Key Insights & Action',
        body: text.substring(midpoint + 2),
        callout:
            'Verified health knowledge gives you the power to protect yourself and your loved ones.',
      ));
    } else {
      pages.add(LessonPage(
        title: matchingLesson.title,
        body: text,
        callout:
            'Verified health knowledge gives you the power to protect yourself and your loved ones.',
      ));
    }
  }

  return (lesson: matchingLesson, pages: pages, questions: questions);
});

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({
    super.key,
    required this.topicId,
    required this.lessonId,
  });

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

  void _finishLesson(int xpEarned) {
    ref.read(userProgressProvider.notifier).completeLesson(
          lessonId: widget.lessonId,
          xpEarned: xpEarned,
        );
    context.go('/learn/${widget.topicId}/lesson/${widget.lessonId}/streak');
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(
      _lessonDetailProvider(
          (topicId: widget.topicId, lessonId: widget.lessonId)),
    );

    return Scaffold(
      backgroundColor: SaabiColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: dataAsync.when(
              loading: () => const SaabiLoadingIndicator(),
              error: (_, __) =>
                  const SaabiErrorBanner(message: 'Could not load lesson.'),
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
                      final correct =
                          questions[_questionIndex].options[i].isCorrect;
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
                        _finishLesson(data.lesson.xpReward);
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
                        _finishLesson(data.lesson.xpReward);
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
                    border: Border.all(
                        color: const Color(0xFFE5E7EB), width: 1.5),
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
                    valueColor:
                        const AlwaysStoppedAnimation(SaabiColors.primary),
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
                    Container(
                      padding: const EdgeInsets.all(SaabiSpacing.lg),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(SaabiRadius.lg),
                        border: Border.all(
                            color: const Color(0xFFBFDBFE), width: 1),
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
                Text(pageIndex < total - 1 ? 'Next' : 'Check Understanding →'),
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
          onPressed: onNext,
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
          Row(
            children: [
              GestureDetector(
                onTap: () => context.go('/learn/$topicId'),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color(0xFFE5E7EB), width: 1.5),
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
                    valueColor:
                        const AlwaysStoppedAnimation(SaabiColors.green),
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

          Text(q.questionText, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: SaabiSpacing.lg),

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
                      child:
                          const Icon(Icons.check, color: Colors.white, size: 14),
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
                              border:
                                  Border.all(color: borderColor, width: 1.5),
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
                  : 'Complete & Collect XP →'),
            ),
          ],
          const SizedBox(height: SaabiSpacing.sm),
        ],
      ),
    );
  }
}
