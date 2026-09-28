import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../data/library_repository.dart';
import '../domain/topic.dart';

final _lessonDetailProvider =
    FutureProvider.family<({Lesson lesson, List<LessonPage> pages, List<QuizQuestion> questions}), String>(
        (ref, lessonId) async {
  final repo = ref.watch(libraryRepositoryProvider);
  final questions = await repo.getQuizQuestions(lessonId);
  // TODO: load actual lesson + pages from Supabase
  final lesson = Lesson(id: lessonId, topicId: '', title: '', bodyText: '', xpReward: 10);
  return (lesson: lesson, pages: <LessonPage>[], questions: questions);
});

/// Represents a single "page" of a lesson (shown one at a time like the Figma)
class LessonPage {
  const LessonPage({required this.title, required this.body, this.callout});
  final String title;
  final String body;
  final String? callout;
}

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

  // Sample pages — will be loaded from Supabase
  static const _samplePages = [
    LessonPage(
      title: 'What is HIV?',
      body:
          'HIV (Human Immunodeficiency Virus) is a virus that attacks the body\'s immune system, specifically the CD4 cells (T cells), which help the body fight off infections.',
      callout:
          'With proper treatment, people living with HIV can live long, healthy lives. Effective medicine reduces the viral load to "Undetectable" which means Untransmittable (U=U).',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(_lessonDetailProvider(widget.lessonId));
    final pages = _samplePages; // replace with dataAsync.value?.pages when ready

    return Scaffold(
      backgroundColor: SaabiColors.surface,
      body: SafeArea(
        child: _inQuiz
            ? dataAsync.when(
                loading: () => const SaabiLoadingIndicator(),
                error: (_, __) => const SaabiErrorBanner(message: 'Could not load quiz.'),
                data: (data) => _QuizView(
                  questions: data.questions,
                  currentIndex: _questionIndex,
                  selectedOption: _selectedOption,
                  answered: _answered,
                  topicId: widget.topicId,
                  lessonId: widget.lessonId,
                  onSelect: (i) {
                    if (_answered) return;
                    final correct = data.questions[_questionIndex].options[i].isCorrect;
                    setState(() {
                      _selectedOption = i;
                      _answered = true;
                      if (correct) _correctAnswers++;
                    });
                  },
                  onNext: () {
                    if (_questionIndex < data.questions.length - 1) {
                      setState(() {
                        _questionIndex++;
                        _selectedOption = null;
                        _answered = false;
                      });
                    } else {
                      context.go(
                          '/learn/${widget.topicId}/lesson/${widget.lessonId}/complete');
                    }
                  },
                ),
              )
            : _PageView(
                page: pages.isNotEmpty ? pages[_pageIndex] : null,
                pageIndex: _pageIndex,
                total: pages.length,
                onClose: () => context.go('/learn/${widget.topicId}'),
                onNext: () {
                  if (_pageIndex < pages.length - 1) {
                    setState(() => _pageIndex++);
                  } else {
                    setState(() => _inQuiz = true);
                  }
                },
              ),
      ),
    );
  }
}

class _PageView extends StatelessWidget {
  const _PageView({required this.page, required this.pageIndex, required this.total,
    required this.onClose, required this.onNext});
  final LessonPage? page;
  final int pageIndex;
  final int total;
  final VoidCallback onClose;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final displayTotal = total == 0 ? 5 : total; // fallback for placeholder

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
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: SaabiColors.textSecondary),
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
              Text('${pageIndex + 1}/$displayTotal',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SaabiColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      )),
            ],
          ),
          const SizedBox(height: SaabiSpacing.xl),

          // Lesson title
          if (page != null)
            Text(page!.title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: SaabiSpacing.xl),

          // Body text
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (page != null)
                    Text(page!.body,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.7)),
                  if (page?.callout != null) ...[
                    const SizedBox(height: SaabiSpacing.xl),
                    // "Good to know" card
                    Container(
                      padding: const EdgeInsets.all(SaabiSpacing.md),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(SaabiRadius.lg),
                        border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Text('💡', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: SaabiSpacing.sm),
                            Text('Good to know',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: SaabiColors.primary,
                                      fontWeight: FontWeight.w700,
                                    )),
                          ]),
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
          ElevatedButton(onPressed: onNext, child: const Text('Next')),
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
    required this.onSelect,
    required this.onNext,
  });
  final List<QuizQuestion> questions;
  final int currentIndex;
  final int? selectedOption;
  final bool answered;
  final String topicId;
  final String lessonId;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return _PageView(
        page: null,
        pageIndex: 4,
        total: 5,
        onClose: () => context.go('/learn/$topicId'),
        onNext: () => context.go('/learn/$topicId/lesson/$lessonId/complete'),
      );
    }

    final q = questions[currentIndex];
    final total = questions.length + 5; // 5 reading pages + N quiz questions

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SaabiSpacing.lg, vertical: SaabiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          Row(children: [
            GestureDetector(
              onTap: () => context.go('/learn/$topicId'),
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: SaabiColors.textSecondary),
              ),
            ),
            const SizedBox(width: SaabiSpacing.md),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(SaabiRadius.full),
                child: LinearProgressIndicator(
                  value: (5 + currentIndex + 1) / total,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: const AlwaysStoppedAnimation(SaabiColors.green),
                ),
              ),
            ),
            const SizedBox(width: SaabiSpacing.md),
            Text('${5 + currentIndex + 1}/$total',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SaabiColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    )),
          ]),
          const SizedBox(height: SaabiSpacing.lg),

          // Saabi avatar prompt (matches Figma quiz screen)
          Row(
            children: [
              Container(
                width: 44, height: 44,
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
                  child: Text("Great! Let's see what you know.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          )),
                ),
              ),
            ],
          ),
          const SizedBox(height: SaabiSpacing.xl),

          // Question
          Text(q.questionText, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: SaabiSpacing.lg),

          // Options
          ...q.options.asMap().entries.map((e) {
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
                  width: 24, height: 24,
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
                      // Radio circle
                      Container(
                        width: 20, height: 20,
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
          }),

          const Spacer(),
          if (answered)
            ElevatedButton(onPressed: onNext, child: const Text('Continue')),
          const SizedBox(height: SaabiSpacing.sm),
        ],
      ),
    );
  }
}
