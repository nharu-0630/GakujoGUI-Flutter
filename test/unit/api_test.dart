import 'package:gakujo_gui/api/parse.dart';
import 'package:gakujo_gui/models/contact.dart';
import 'package:html/dom.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:test/test.dart';

void main() {
  group('DateTimeParsing', () {
    test('toDetailString', () {
      initializeDateFormatting('ja');
      expect(
          DateTime(2022, 10, 13, 19, 0).toDetailString(), '2022/10/13 19:00');
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

  group('ModelParsing', () {
    test('Contact', () {
      Element element = Element.html('''
<tr>
  
  <td class="colCheck">
    
    
    
    
    
    
      <input type="checkbox" name="classContactIdCheck" value="226099" disabled="disabled">
    
    
    
    
  </td>
  
  <td>
    数理論理Ⅱ（1クラス）<br/>
    後期/月3・4(後期後半)
  </td>
  
  
  <td>
    担当　教員<br/>
  </td>
  
  
  <td>
    
    
      <span class="red">【重要】</span>
    
    <a href="javascript:void(0);" id="linkDetail" onclick="return showClassContactDetail(0);">数理論理II アンケート</a>
    
    
    
    
    
    
      
    
  </td>
  
  <td>
    教員連絡
  </td>
  
  <td></td>
  
  <td>2023/02/03 18:23</td>
  
  <td>
    
    
    
      通知済
    
  </td>
  
  <td>77453010</td>
  
  
  <td>タントウ　キョウイン</td>
  
  
  <td>5</td>
  
  <td>6</td>
</tr>
      ''');
      var actualContact = Contact.fromElement(element);
      var matcherContact = Contact(
        subject: '数理論理Ⅱ',
        teacherName: '担当　教員',
        contactType: '教員連絡',
        title: '数理論理II アンケート',
        content: '',
        fileNames: null,
        fileLinkRelease: '',
        referenceUrl: '',
        severity: '重要',
        targetDateTime: DateTime.fromMicrosecondsSinceEpoch(0),
        contactDateTime: DateTime(2023, 2, 3, 18, 23),
        webReplyRequest: '',
        isAcquired: false,
      );
      expect(actualContact, matcherContact);
      expect(actualContact.teacherName, matcherContact.teacherName);
      expect(actualContact.contactType, matcherContact.contactType);
      expect(actualContact.content, matcherContact.content);
      expect(actualContact.fileNames, matcherContact.fileNames);
      expect(actualContact.fileLinkRelease, matcherContact.fileLinkRelease);
      expect(actualContact.referenceUrl, matcherContact.referenceUrl);
      expect(actualContact.severity, matcherContact.severity);
      expect(actualContact.targetDateTime, matcherContact.targetDateTime);
      expect(actualContact.webReplyRequest, matcherContact.webReplyRequest);
      expect(actualContact.isAcquired, matcherContact.isAcquired);

      Document document = Document.html('''
<table class="ttb_entry">
							
							<tr>
								<th>連絡種別</th>
								<td>教員連絡</td>
							</tr>
							
							
							
							
							<tr>
								<th>タイトル</th>
								<td>数理論理II&nbsp;アンケート</td>
							</tr>
							
							<tr>
								<th>内容</th>
								<td><div class="rich_area"><div>&nbsp;内容開始</div>
<div>&nbsp;</div>
<div>&nbsp;</div>
<div>内容終了</div></div></td>
							</tr>
							
							<tr>
								<th>ファイル</th>
								<td>
									


  
  


































<div id="fileList_no1">

	

</div>



	
	
		
	
	<div id="fileListAllDownload_no1" style="display: none">
		<br/>
		
		<a href="javascript:void(0);" class="btn" onclick="allFileDownload('no1');"><span class="btn-side" ><span class="icon-download" >一括ダウンロード</span></span></a>
	</div>
								</td>
							</tr>
							
							
							
								<tr>
									<th>ファイルリンク公開</th>
									<td>
										
										
										
											公開しない
										
									</td>
								</tr>
							
							
							
							<tr>
								<th>参考URL</th>
								<td>
									<a href="/portal/liveapps/livecampus/classcontact/jsp/" target="_blank"></a>
								</td>
							</tr>
							
							<tr>
								<th>重要度</th>
								<td>
									
									重要
									
									
								</td>
							</tr>
							
							<tr>
								<th>連絡日時</th>
								<td>
									
									
									
										即時通知
										&nbsp;
										2023/02/03 18:23
									
									
								</td>
							</tr>
							
							
							
							
							<tr>
								<th>WEB返信要求</th>
								<td>返信を求めない</td>
							</tr>
							
						</table>
            ''');
      actualContact.toDetail(document);
      matcherContact = Contact(
        subject: '数理論理Ⅱ',
        teacherName: '担当　教員',
        contactType: '教員連絡',
        title: '数理論理II アンケート',
        content: '内容開始\n \n \n内容終了',
        fileNames: null,
        fileLinkRelease: '公開しない',
        referenceUrl: '',
        severity: '重要',
        targetDateTime: DateTime.fromMicrosecondsSinceEpoch(0),
        contactDateTime: DateTime(2023, 2, 3, 18, 23),
        webReplyRequest: '返信を求めない',
        isAcquired: true,
      );
      expect(actualContact, matcherContact);
      expect(actualContact.teacherName, matcherContact.teacherName);
      expect(actualContact.contactType, matcherContact.contactType);
      expect(actualContact.content, matcherContact.content);
      expect(actualContact.fileNames, matcherContact.fileNames);
      expect(actualContact.fileLinkRelease, matcherContact.fileLinkRelease);
      expect(actualContact.referenceUrl, matcherContact.referenceUrl);
      expect(actualContact.severity, matcherContact.severity);
      expect(actualContact.targetDateTime, matcherContact.targetDateTime);
      expect(actualContact.webReplyRequest, matcherContact.webReplyRequest);
      expect(actualContact.isAcquired, matcherContact.isAcquired);
    });
  });
}
