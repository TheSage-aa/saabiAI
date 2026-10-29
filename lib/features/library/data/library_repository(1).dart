import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/topic.dart';

/// Static in-app lesson content. See the NOTE in `domain/topic.dart` --
/// this exists so the referenced routes/ids (hiv-stis, reproductive,
/// mental-health, nutrition, and the specific lesson ids home_screen.dart
/// and practice_screen.dart already pointed at) resolve to something real.
class LibraryRepository {
  static const List<Topic> topics = [
    Topic(
      id: 'hiv-stis',
      title: 'HIV & STIs',
      emoji: '🎗️',
      color: SaabiColors.topicHiv,
      description: 'The facts on HIV, STIs, testing, and staying status neutral.',
      lessons: [
        Lesson(
          id: 'hiv-101',
          title: 'What is HIV?',
          estMinutes: 3,
          paragraphs: [
            'HIV (Human Immunodeficiency Virus) affects the body\'s immune defenses over time. '
                'It is not the same as AIDS -- AIDS is a late stage that only happens if HIV goes untreated for years.',
            'With daily antiretroviral treatment (ART), people living with HIV stay healthy and live full, '
                'normal lives. There is no reason to treat someone differently because of their status.',
            'Testing is fast, free, and confidential at public health centers and youth clinics across Nigeria.',
          ],
        ),
        Lesson(
          id: 'hiv-transmission',
          title: 'How HIV is Transmitted',
          estMinutes: 3,
          paragraphs: [
            'HIV only passes through specific body fluids: blood, semen, vaginal fluids, and breast milk, '
                'and only when those fluids reach the bloodstream.',
            'You cannot get HIV from hugging, kissing, sharing food or cups, toilet seats, or mosquito bites -- '
                'casual, everyday contact is completely safe.',
          ],
        ),
        Lesson(
          id: 'hiv-prevention',
          title: 'Prevention Methods & PrEP',
          estMinutes: 4,
          paragraphs: [
            'Condoms (male or female) are the only method that protects against both pregnancy and HIV/STIs.',
            'PrEP (Pre-Exposure Prophylaxis) is a daily pill that prevents HIV before exposure. '
                'PEP (Post-Exposure Prophylaxis) is emergency medication that must be started within 72 hours after a possible exposure.',
            'U=U (Undetectable = Untransmittable): when someone on treatment reaches an undetectable viral '
                'load, they cannot pass HIV on through sex.',
          ],
        ),
      ],
    ),
    Topic(
      id: 'reproductive',
      title: 'Reproductive Health',
      emoji: '🌸',
      color: SaabiColors.topicReproductive,
      description: 'Your body, your choices, and the facts behind both.',
      lessons: [
        Lesson(
          id: 'srh-understanding',
          title: 'Understanding Your Body',
          estMinutes: 3,
          paragraphs: [
            'Menstrual cycles normally range from 21 to 35 days -- there is no single "correct" length, '
                'and some variation month to month is completely normal.',
            'Consent must be freely given, informed, and can be withdrawn at any time -- it is never assumed '
                'from silence, past agreement, or a relationship status.',
          ],
        ),
        Lesson(
          id: 'srh-contraception',
          title: 'Contraception Options',
          estMinutes: 4,
          paragraphs: [
            'There are many contraception options -- pills, injectables, implants, IUDs, and condoms -- with '
                'different effectiveness, side effects, and routines. A trained health worker can help you '
                'find the right fit; this isn\'t one-size-fits-all.',
            'Condoms remain the only option that also protects against STIs, so many people use them '
                'alongside another method.',
          ],
        ),
      ],
    ),
    Topic(
      id: 'mental-health',
      title: 'Mental Health',
      emoji: '🧠',
      color: SaabiColors.topicMentalHealth,
      description: 'Everyday tools for stress, mood, and knowing when to reach out.',
      lessons: [
        Lesson(
          id: 'mh-whatis',
          title: 'What is Mental Health?',
          estMinutes: 3,
          paragraphs: [
            'Mental health is part of overall health, not separate from it. Everyone has ups and downs -- '
                'what matters is noticing patterns and knowing support is available.',
            'Struggling with low mood, stress, or burnout is not a sign of weak willpower. These are real, '
                'common experiences, and reaching out for support is a sign of strength, not failure.',
          ],
        ),
        Lesson(
          id: 'mh-everyday-tools',
          title: 'Everyday Coping Tools',
          estMinutes: 3,
          paragraphs: [
            'Simple, low-cost tools that help in the moment: slow breathing, a short walk, naming the feeling '
                'out loud, or talking to someone you trust.',
            'If stress, sadness, or anxiety are affecting your daily life for more than a couple of weeks, '
                'it is worth talking to a counselor or health worker -- Saabi can help you find one nearby.',
          ],
        ),
      ],
    ),
    Topic(
      id: 'nutrition',
      title: 'Nutrition',
      emoji: '🥗',
      color: SaabiColors.topicNutrition,
      description: 'Affordable, practical nutrition for everyday energy and health.',
      lessons: [
        Lesson(
          id: 'nutrition-basics',
          title: 'Everyday Nutrition Basics',
          estMinutes: 3,
          paragraphs: [
            'Local, affordable foods like beans, eggs, fish, and groundnuts are excellent sources of protein '
                'for growth, repair, and energy.',
            'Dark leafy greens like ugwu and waterleaf are rich in iron and folate, supporting healthy blood '
                'and energy levels.',
            'Water supports digestion, circulation, and focus -- aim to drink regularly through the day, '
                'not just when thirsty.',
          ],
        ),
      ],
    ),
  ];

  static Topic? topicById(String id) {
    for (final t in topics) {
      if (t.id == id) return t;
    }
    return null;
  }

  static Lesson? lessonById(String topicId, String lessonId) {
    final topic = topicById(topicId);
    if (topic == null) return null;
    for (final l in topic.lessons) {
      if (l.id == lessonId) return l;
    }
    return null;
  }
}
