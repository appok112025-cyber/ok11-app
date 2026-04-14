import 'package:flutter/foundation.dart';
import 'package:ok11/app/data/models/quiz_question.dart';

class QuizRepository {
  Future<List<QuizQuestion>> getQuestions() async {
    debugPrint('📥 QuizRepository.getQuestions()');
    await Future.delayed(const Duration(milliseconds: 100));
    final result = [
      QuizQuestion(
        question: 'Who will win today\'s match?',
        options: ['Ind', 'Eng'],
      ),
      QuizQuestion(question: 'Top run scorer?', options: ['Kohli', 'Root']),
      QuizQuestion(
        question: 'Top wicket taker?',
        options: ['Bumrah', 'Woakes'],
      ),
      QuizQuestion(question: 'Most catches?', options: ['Rahul', 'Stokes']),
      QuizQuestion(question: 'Most sixes?', options: ['Kohli', 'Stokes']),
    ];
    debugPrint('✅ QuizRepository.getQuestions: ${result.length} questions');
    return result;
  }

  Future<bool> saveAnswers(List<QuizQuestion> answers) async {
    debugPrint('💾 QuizRepository.saveAnswers: ${answers.length} answers');
    await Future.delayed(const Duration(milliseconds: 100));
    debugPrint('✅ QuizRepository.saveAnswers: Success');
    return true;
  }
}
