import 'package:flutter_test/flutter_test.dart';
import 'package:geonsaehelper/features/conversation/domain/models.dart';
import 'package:geonsaehelper/features/conversation/domain/rules_engine.dart';

void main() {
  group('rules_engine.evaluateProgramMatches', () {
    test('Standard: 수도권 보증금 3억 초과 → 결격', () {
      final answers = <String, String>{
        'A1': 'household_head',
        'A2': 'yes',
        'A3': 'y35p',
        'A6': 'inc_le50m',
        'A7': 'asset_le337',
        'P2': 'metro',
        'P3': 'apartment',
        'P4': 'fa_le60',
        'P5': 'dep_gt3',
      };
      final matches = evaluateProgramMatches(answers);
      final standard =
          matches.firstWhere((m) => m.programId == ProgramId.RENT_STANDARD);
      expect(standard.status, RulingStatus.notPossibleDisq);
    });

    test('Youth: 1.5~2.0억 경계 → 정보부족', () {
      final answers = <String, String>{
        'A1': 'household_head',
        'A2': 'yes',
        'A3': 'y19_34',
        'A6': 'inc_le50m',
        'A7': 'asset_le337',
        'P2': 'metro',
        'P3': 'apartment',
        'P4': 'fa_le60',
        'P5': 'dep_le2', // 경계 처리(정보부족)
      };
      final matches = evaluateProgramMatches(answers);
      final youth = matches.firstWhere((m) => m.programId == ProgramId.RENT_YOUTH);
      expect(youth.status, RulingStatus.notPossibleInfo);
    });

    test('Newborn: 단일소득 1.3~2.0억 구간 + 맞벌이=아니오 → 결격', () {
      final answers = <String, String>{
        'A1': 'household_head',
        'A2': 'yes',
        'A3': 'y35p',
        'A5': 'yes',
        'A6': 'inc_le200m',
        'A8': 'no',
        'A7': 'asset_le337',
        'P2': 'metro',
        'P3': 'apartment',
        'P4': 'fa_le60',
        'P5': 'dep_le2',
      };
      final matches = evaluateProgramMatches(answers);
      final newborn =
          matches.firstWhere((m) => m.programId == ProgramId.RENT_NEWBORN);
      expect(newborn.status, RulingStatus.notPossibleDisq);
    });

    test('Newlywed: 수도권 3~4억 경계 → 정보부족', () {
      final answers = <String, String>{
        'A1': 'household_head',
        'A2': 'yes',
        'A3': 'y35p',
        'A4': 'newly7y',
        'A6': 'inc_le75m',
        'A7': 'asset_le337',
        'P2': 'metro',
        'P3': 'apartment',
        'P4': 'fa_le60',
        'P5': 'dep_gt3', // 수도권 3~4억 경계 → 정보부족
      };
      final matches = evaluateProgramMatches(answers);
      final newly =
          matches.firstWhere((m) => m.programId == ProgramId.RENT_NEWLYWED);
      expect(newly.status, RulingStatus.notPossibleInfo);
    });
  });
}

