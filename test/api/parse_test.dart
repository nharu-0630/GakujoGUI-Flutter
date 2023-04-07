import 'package:gakujo_gui/api/parse.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:test/test.dart';

void main() {
  group('DateTimeParsing', () {
    test('toDateTimeString', () {
      initializeDateFormatting('ja');
      expect(
          DateTime(2022, 10, 13, 19, 0).toDateTimeString(), '2022/10/13 19:00');
    });

    test('toDateString', () {
      initializeDateFormatting('ja');
      expect(DateTime(2022, 10, 13, 0, 0).toDateString(), '2022/10/13');
    });
  });

  group('StringParsing', () {
    test('trimWhiteSpace', () {
      expect(
          '\n\t\t\t\t\t\t\t\t\t\t\t\t数理論理Ⅱ（1クラス）\n\t\t\t\t\t\t\t\t\t\t\t\t後期/月3・4(後期後半)\n\t\t\t\t\t\t\t\t\t\t\t'
              .trimWhiteSpace(),
          '数理論理Ⅱ（1クラス）後期/月3・4(後期後半)');
    });

    test('trimSubject', () {
      expect('数理論理Ⅱ（1クラス）後期/月3・4(後期後半)'.trimSubject(), '数理論理Ⅱ');
    });

    test('trimJsArgs', () {
      expect(
          'formSubmit(\'forwardSubmitRef\', \'63660\',\'\',\'2022\',\'77453060\',\'61\');'
              .trimJsArgs(1),
          '63660');
    });

    test('trimNewLines', () {
      expect(
          '''
																
																
                                共通講義棟５１ 
                                
                                
															'''
              .trimNewLines(),
          '共通講義棟５１');
    });

    test('toSpanDateTime', () {
      initializeDateFormatting('ja');
      expect('2022/10/13 19:00 ～ 2022/10/20 15:55'.toSpanDateTime(0),
          DateTime(2022, 10, 13, 19, 0));
      expect('2022/10/13 19:00 ～ 2022/10/20 15:55'.toSpanDateTime(1),
          DateTime(2022, 10, 20, 15, 55));
    });

    test('toDateTime', () {
      initializeDateFormatting('ja');
      expect('2022/10/13'.toDateTime(), DateTime(2022, 10, 13));
      expect('2022/10/13 19:00'.toDateTime(), DateTime(2022, 10, 13, 19, 0));
      expect('2022年 10月 13日'.toDateTime(), DateTime(2022, 10, 13));
      expect('Not a date'.toDateTime(), DateTime.fromMicrosecondsSinceEpoch(0));
    });
  });
}
