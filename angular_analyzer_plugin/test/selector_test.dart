import 'package:analyzer/src/generated/source.dart';
import 'package:angular_analyzer_plugin/src/model.dart';
import 'package:angular_analyzer_plugin/src/selector.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

// 'typed' is deprecated and shouldn't be used.
// ignore_for_file: deprecated_member_use

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AndSelectorTest);
    defineReflectiveTests(AttributeSelectorTest);
    defineReflectiveTests(AttributeContainsSelectorTest);
    defineReflectiveTests(ClassSelectorTest);
    defineReflectiveTests(ElementNameSelectorTest);
    defineReflectiveTests(OrSelectorTest);
    defineReflectiveTests(NotSelectorTest);
    defineReflectiveTests(AttributeValueRegexSelectorTest);
    defineReflectiveTests(AttributeStartsWithSelectorTest);
    defineReflectiveTests(SelectorParserTest);
    defineReflectiveTests(SuggestTagsTest);
    defineReflectiveTests(HtmlTagForSelectorTest);
  });
}

@reflectiveTest
class AndSelectorTest extends _SelectorTest {
  final selector1 = new _SelectorMock('aaa');
  final selector2 = new _SelectorMock('bbb');
  final selector3 = new _SelectorMock('ccc');

  AndSelector selector;

  @override
  void setUp() {
    super.setUp();
    selector = new AndSelector(<Selector>[selector1, selector2, selector3]);
    when(selector1.match(typed(any), typed(any)))
        .thenReturn(SelectorMatch.NonTagMatch);
    when(selector2.match(typed(any), typed(any)))
        .thenReturn(SelectorMatch.NonTagMatch);
    when(selector3.match(typed(any), typed(any)))
        .thenReturn(SelectorMatch.NonTagMatch);

    when(selector1.availableTo(typed(any))).thenReturn(true);
    when(selector2.availableTo(typed(any))).thenReturn(true);
    when(selector3.availableTo(typed(any))).thenReturn(true);
  }

  // ignore: non_constant_identifier_names
  void test_match() {
    expect(
        selector.match(element, template), equals(SelectorMatch.NonTagMatch));
    verify(selector1.match(typed(any), typed(any))).called(2);
    verify(selector2.match(typed(any), typed(any))).called(2);
    verify(selector3.match(typed(any), typed(any))).called(2);
  }

  // ignore: non_constant_identifier_names
  void test_match_availableTo_allMatch() {
    expect(selector.availableTo(element), true);
    verify(selector1.availableTo(typed(any))).called(1);
    verify(selector2.availableTo(typed(any))).called(1);
    verify(selector3.availableTo(typed(any))).called(1);
  }

  // ignore: non_constant_identifier_names
  void test_match_availableTo_singleUnmatch() {
    when(selector2.availableTo(typed(any))).thenReturn(false);
    expect(selector.availableTo(element), equals(false));
    verify(selector1.availableTo(typed(any))).called(1);
    verify(selector2.availableTo(typed(any))).called(1);
    verifyNever(selector3.availableTo(typed(any)));
  }

  // ignore: non_constant_identifier_names
  void test_match_false1() {
    when(selector1.match(typed(any), typed(any)))
        .thenReturn(SelectorMatch.NoMatch);
    expect(selector.match(element, template), equals(SelectorMatch.NoMatch));
    verify(selector1.match(typed(any), typed(any))).called(1);
    verifyNever(selector2.match(typed(any), typed(any)));
    verifyNever(selector3.match(typed(any), typed(any)));
  }

  // ignore: non_constant_identifier_names
  void test_match_false2() {
    when(selector2.match(typed(any), typed(any)))
        .thenReturn(SelectorMatch.NoMatch);
    expect(selector.match(element, template), equals(SelectorMatch.NoMatch));
    verify(selector1.match(typed(any), typed(any))).called(1);
    verify(selector2.match(typed(any), typed(any))).called(1);
    verifyNever(selector3.match(typed(any), typed(any)));
  }

  // ignore: non_constant_identifier_names
  void test_match_falseTagMatch() {
    when(selector1.match(typed(any), typed(any)))
        .thenReturn(SelectorMatch.TagMatch);
    when(selector2.match(typed(any), typed(any)))
        .thenReturn(SelectorMatch.NoMatch);
    expect(selector.match(element, template), equals(SelectorMatch.NoMatch));
    verify(selector1.match(typed(any), typed(any))).called(1);
    verify(selector2.match(typed(any), typed(any))).called(1);
    verifyNever(selector3.match(typed(any), typed(any)));
  }

  // ignore: non_constant_identifier_names
  void test_match_TagMatch1() {
    when(selector1.match(typed(any), typed(any)))
        .thenReturn(SelectorMatch.TagMatch);
    expect(selector.match(element, template), equals(SelectorMatch.TagMatch));
    verify(selector1.match(typed(any), typed(any))).called(2);
    verify(selector2.match(typed(any), typed(any))).called(2);
    verify(selector3.match(typed(any), typed(any))).called(2);
  }

  // ignore: non_constant_identifier_names
  void test_match_TagMatch2() {
    when(selector2.match(typed(any), typed(any)))
        .thenReturn(SelectorMatch.TagMatch);
    expect(selector.match(element, template), equals(SelectorMatch.TagMatch));
    verify(selector1.match(typed(any), typed(any))).called(2);
    verify(selector2.match(typed(any), typed(any))).called(2);
    verify(selector3.match(typed(any), typed(any))).called(2);
  }

  // ignore: non_constant_identifier_names
  void test_toString() {
    expect(selector.toString(), 'aaa && bbb && ccc');
  }
}

@reflectiveTest
class AttributeContainsSelectorTest extends _SelectorTest {
  final AngularElement nameElement =
      new AngularElementImpl('kind', 10, 5, null);
  // ignore: non_constant_identifier_names
  void test_match() {
    final selector = new AttributeContainsSelector(nameElement, 'search');
    when(element.attributes).thenReturn({'kind': 'include the search here'});
    when(element.attributeNameSpans)
        .thenReturn({'kind': _newStringSpan(100, 'kind')});
    // verify
    expect(
        selector.match(element, template), equals(SelectorMatch.NonTagMatch));
    _assertRange(resolvedRanges[0], 100, 4, selector.nameElement);
    expect(selector.availableTo(element), true);
  }

  // ignore: non_constant_identifier_names
  void test_match_begins() {
    final selector = new AttributeContainsSelector(nameElement, 'start');
    when(element.attributes).thenReturn({'kind': 'start is matched'});
    when(element.attributeNameSpans)
        .thenReturn({'kind': _newStringSpan(100, 'kind')});
    // verify
    expect(
        selector.match(element, template), equals(SelectorMatch.NonTagMatch));
    _assertRange(resolvedRanges[0], 100, 4, selector.nameElement);
    expect(selector.availableTo(element), true);
  }

  // ignore: non_constant_identifier_names
  void test_match_ends() {
    final selector = new AttributeContainsSelector(nameElement, 'end');
    when(element.attributes).thenReturn({'kind': 'matches at the end'});
    when(element.attributeNameSpans)
        .thenReturn({'kind': _newStringSpan(100, 'kind')});
    // verify
    expect(
        selector.match(element, template), equals(SelectorMatch.NonTagMatch));
    _assertRange(resolvedRanges[0], 100, 4, selector.nameElement);
    expect(selector.availableTo(element), true);
  }

  // ignore: non_constant_identifier_names
  void test_noMatch_attributeName() {
    final selector = new AttributeContainsSelector(nameElement, 'match');
    when(element.attributes).thenReturn({'unmatched': 'this is matched'});
    when(element.attributeNameSpans)
        .thenReturn({'unmatched': _newStringSpan(100, 'unmatched')});
    // verify
    expect(selector.match(element, template), equals(SelectorMatch.NoMatch));
    expect(selector.availableTo(element), true);
  }

  // ignore: non_constant_identifier_names
  void test_noMatch_value() {
    final selector =
        new AttributeContainsSelector(nameElement, 'not appearing');
    when(element.attributes).thenReturn({'kind': 'not related'});
    when(element.attributeNameSpans)
        .thenReturn({'kind': _newStringSpan(100, 'kind')});
    // verify
    expect(selector.match(element, template), equals(SelectorMatch.NoMatch));
    expect(selector.availableTo(element), false);
  }
}

@reflectiveTest
class AttributeSelectorTest extends _SelectorTest {
  final AngularElement nameElement =
      new AngularElementImpl('kind', 10, 5, null);

  // ignore: non_constant_identifier_names
  void test_match_name_value() {
    final selector = new AttributeSelector(nameElement, 'silly');
    when(element.attributes).thenReturn({'kind': 'silly'});
    when(element.attributeNameSpans)
        .thenReturn({'kind': _newStringSpan(100, 'kind')});
    expect(
        selector.match(element, template), equals(SelectorMatch.NonTagMatch));
    _assertRange(resolvedRanges[0], 100, 4, selector.nameElement);
    expect(selector.availableTo(element), true);
  }

  // ignore: non_constant_identifier_names
  void test_match_notName() {
    final selector = new AttributeSelector(nameElement, null);
    when(element.attributes).thenReturn({'not-kind': 'no-matter'});
    when(element.attributeNameSpans).thenReturn({'not-kind': null});
    expect(selector.match(element, template), equals(SelectorMatch.NoMatch));
    expect(selector.availableTo(element), true);
  }

  // ignore: non_constant_identifier_names
  void test_match_notValue() {
    final selector = new AttributeSelector(nameElement, 'silly');
    when(element.attributes).thenReturn({'kind': 'strange'});
    when(element.attributeNameSpans)
        .thenReturn({'kind': _newStringSpan(100, "kind")});
    expect(selector.match(element, template), equals(SelectorMatch.NoMatch));
    expect(selector.availableTo(element), equals(false));
  }

  // ignore: non_constant_identifier_names
  void test_match_noValue() {
    final selector = new AttributeSelector(nameElement, null);
    when(element.attributes).thenReturn({'kind': 'no-matter'});
    when(element.attributeNameSpans)
        .thenReturn({'kind': _newStringSpan(100, "kind")});
    // verify
    expect(
        selector.match(element, template), equals(SelectorMatch.NonTagMatch));
    _assertRange(resolvedRanges[0], 100, 4, selector.nameElement);
    expect(selector.availableTo(element), true);
  }

  // ignore: non_constant_identifier_names
  void test_toString_hasValue() {
    final selector = new AttributeSelector(nameElement, 'daffy');
    expect(selector.toString(), '[kind=daffy]');
  }

  // ignore: non_constant_identifier_names
  void test_toString_noValue() {
    final selector = new AttributeSelector(nameElement, null);
    expect(selector.toString(), '[kind]');
  }
}

@reflectiveTest
class AttributeStartsWithSelectorTest extends _SelectorTest {
  final selector = new AttributeStartsWithSelector(
      new AngularElementImpl('abc', 10, 5, null), 'xyz');

  // ignore: non_constant_identifier_names
  void test_exactMatch() {
    when(element.attributes).thenReturn({'abc': 'xyz'});
    when(element.attributeNameSpans)
        .thenReturn({'abc': _newStringSpan(100, 'abc')});
    expect(
        selector.match(element, template), equals(SelectorMatch.NonTagMatch));
    expect(selector.availableTo(element), true);
  }

  // ignore: non_constant_identifier_names
  void test_match_justOne() {
    when(element.attributes)
        .thenReturn({'abc': 'xyz and stuff', 'plop': 'zabcz', 'klark': 'efg'});
    when(element.attributeNameSpans).thenReturn({
      'abc': _newStringSpan(100, 'abc'),
      'plop': _newStringSpan(110, 'plop'),
      'klark': _newStringSpan(120, 'klark')
    });
    expect(
        selector.match(element, template), equals(SelectorMatch.NonTagMatch));
    expect(selector.availableTo(element), true);
  }

  // ignore: non_constant_identifier_names
  void test_noMatch_any() {
    when(element.attributes).thenReturn(
        {'abc': 'wrong value', 'wrong-attr': 'xyz', 'klark': 'efg'});
    when(element.attributeNameSpans).thenReturn({
      'abc': _newStringSpan(100, 'abc'),
      'xyz': _newStringSpan(110, 'xyz'),
      'klark': _newStringSpan(120, 'klark')
    });
    expect(selector.match(element, template), equals(SelectorMatch.NoMatch));
    expect(selector.availableTo(element), equals(false));
  }

  // ignore: non_constant_identifier_names
  void test_noMatch_valueNotStartWith() {
    when(element.attributes).thenReturn({'abc': 'axyz'});
    when(element.attributeNameSpans)
        .thenReturn({'abc': _newStringSpan(100, 'abc')});
    expect(selector.match(element, template), equals(SelectorMatch.NoMatch));
    // available to is false, because the attribute already exists and so
    // suggesting it would lead to duplication.
    expect(selector.availableTo(element), equals(false));
  }

  // ignore: non_constant_identifier_names
  void test_noMatch_wrongAttrName() {
    when(element.attributes).thenReturn({'abcd': 'xyz'});
    when(element.attributeNameSpans)
        .thenReturn({'abcd': _newStringSpan(100, 'abcd')});
    expect(selector.match(element, template), equals(SelectorMatch.NoMatch));
    expect(selector.availableTo(element), equals(true));
  }

  // ignore: non_constant_identifier_names
  void test_withExtraCharsMatch() {
    when(element.attributes).thenReturn({'abc': 'xyz and stuff'});
    when(element.attributeNameSpans)
        .thenReturn({'abc': _newStringSpan(100, 'abc')});
    expect(
        selector.match(element, template), equals(SelectorMatch.NonTagMatch));
    expect(selector.availableTo(element), true);
  }
}

@reflectiveTest
class AttributeValueRegexSelectorTest extends _SelectorTest {
  final selector = new AttributeValueRegexSelector("abc");

  // ignore: non_constant_identifier_names
  void test_match() {
    when(element.attributes).thenReturn({'kind': '0abcd'});
    expect(
        selector.match(element, template), equals(SelectorMatch.NonTagMatch));
    expect(selector.availableTo(element), true);
  }

  // ignore: non_constant_identifier_names
  void test_match_justOne() {
    when(element.attributes)
        .thenReturn({'kind': 'bcd', 'plop': 'zabcz', 'klark': 'efg'});
    expect(
        selector.match(element, template), equals(SelectorMatch.NonTagMatch));
    expect(selector.availableTo(element), true);
  }

  // ignore: non_constant_identifier_names
  void test_noMatch() {
    when(element.attributes).thenReturn({'kind': 'bcd'});
    expect(selector.match(element, template), equals(SelectorMatch.NoMatch));
    expect(selector.availableTo(element), equals(false));
  }

  // ignore: non_constant_identifier_names
  void test_noMatch_any() {
    when(element.attributes)
        .thenReturn({'kind': 'bcd', 'plop': 'cde', 'klark': 'efg'});
    expect(selector.match(element, template), equals(SelectorMatch.NoMatch));
    expect(selector.availableTo(element), equals(false));
  }
}

@reflectiveTest
class ClassSelectorTest extends _SelectorTest {
  final nameElement = new AngularElementImpl('nice', 10, 5, null);
  ClassSelector selector;

  @override
  void setUp() {
    super.setUp();
    selector = new ClassSelector(nameElement);
  }

  // ignore: non_constant_identifier_names
  void test_match_false_noClass() {
    when(element.attributes).thenReturn({'not-class': 'no-matter'});
    expect(selector.match(element, template), equals(SelectorMatch.NoMatch));
    expect(selector.availableTo(element), true);
  }

  // ignore: non_constant_identifier_names
  void test_match_false_noSuchClass() {
    when(element.attributes).thenReturn({'class': 'not-nice'});
    expect(selector.match(element, template), equals(SelectorMatch.NoMatch));
    expect(selector.availableTo(element), true);
  }

  // ignore: non_constant_identifier_names
  void test_match_true_first() {
    final classValue = 'nice some other';
    when(element.attributes).thenReturn({'class': classValue});
    when(element.attributeValueSpans)
        .thenReturn({'class': _newStringSpan(100, classValue)});
    expect(
        selector.match(element, template), equals(SelectorMatch.NonTagMatch));
    expect(selector.availableTo(element), true);
    expect(resolvedRanges, hasLength(1));
    _assertRange(resolvedRanges[0], 100, 4, selector.nameElement);
  }

  // ignore: non_constant_identifier_names
  void test_match_true_last() {
    final classValue = 'some other nice';
    when(element.attributes).thenReturn({'class': classValue});
    when(element.attributeValueSpans)
        .thenReturn({'class': _newStringSpan(100, classValue)});
    expect(
        selector.match(element, template), equals(SelectorMatch.NonTagMatch));
    expect(selector.availableTo(element), true);
    expect(resolvedRanges, hasLength(1));
    _assertRange(resolvedRanges[0], 111, 4, selector.nameElement);
  }

  // ignore: non_constant_identifier_names
  void test_match_true_middle() {
    final classValue = 'some nice other';
    when(element.attributes).thenReturn({'class': classValue});
    when(element.attributeValueSpans)
        .thenReturn({'class': _newStringSpan(100, classValue)});
    expect(
        selector.match(element, template), equals(SelectorMatch.NonTagMatch));
    expect(selector.availableTo(element), true);
    expect(resolvedRanges, hasLength(1));
    _assertRange(resolvedRanges[0], 105, 4, selector.nameElement);
  }

  // ignore: non_constant_identifier_names
  void test_toString() {
    expect(selector.toString(), '.nice');
  }
}

@reflectiveTest
class ElementNameSelectorTest extends _SelectorTest {
  ElementNameSelector selector;

  @override
  void setUp() {
    super.setUp();
    selector =
        new ElementNameSelector(new AngularElementImpl('panel', 10, 5, null));
  }

  // ignore: non_constant_identifier_names
  void test_match() {
    when(element.localName).thenReturn('panel');
    when(element.openingNameSpan).thenReturn(_newStringSpan(100, 'panel'));
    when(element.closingNameSpan).thenReturn(_newStringSpan(200, 'panel'));
    expect(selector.match(element, template), equals(SelectorMatch.TagMatch));
    expect(selector.availableTo(element), true);
    _assertRange(resolvedRanges[0], 100, 5, selector.nameElement);
    _assertRange(resolvedRanges[1], 200, 5, selector.nameElement);
  }

  // ignore: non_constant_identifier_names
  void test_match_not() {
    when(element.localName).thenReturn('not-panel');
    expect(selector.match(element, template), equals(SelectorMatch.NoMatch));
    expect(selector.availableTo(element), equals(false));
  }

  // ignore: non_constant_identifier_names
  void test_toString() {
    expect(selector.toString(), 'panel');
  }
}

@reflectiveTest
class HtmlTagForSelectorTest {
  // ignore: non_constant_identifier_names
  void test_addClassMultipleTimesOKDoesntRepeat() {
    final tag = new HtmlTagForSelector()
      ..name = "tagname"
      ..addClass("myclass");
    // ignore: cascade_invocations
    tag.addClass("myclass");
    // ignore: cascade_invocations
    tag.addClass("myclass");
    expect(tag.isValid, isTrue);
    expect(tag.toString(), equals('<tagname class="myclass"'));
  }

  // ignore: non_constant_identifier_names
  void test_addClassOneClass() {
    final tag = new HtmlTagForSelector()
      ..name = "tagname"
      ..addClass("myclass");
    expect(tag.isValid, isTrue);
    expect(tag.toString(), equals('<tagname class="myclass"'));
  }

  // ignore: non_constant_identifier_names
  void test_addClassTwoClasses() {
    final tag = new HtmlTagForSelector()
      ..name = "tagname"
      ..addClass("myclass");
    // ignore: cascade_invocations
    tag.addClass("myotherclass");
    expect(tag.isValid, isTrue);
    expect(tag.toString(), equals('<tagname class="myclass myotherclass"'));
  }

  // ignore: non_constant_identifier_names
  void test_classesAndClassAttrBindingInvalid() {
    final tag = new HtmlTagForSelector()
      ..name = "tagname"
      ..addClass("myclass")
      ..setAttribute("class", value: "blah");
    expect(tag.isValid, isFalse);
  }

  // ignore: non_constant_identifier_names
  void test_classesAndEmptyClassAttrBindingValid() {
    final tag = new HtmlTagForSelector()
      ..name = "tagname"
      ..addClass("myclass")
      ..setAttribute("class");
    expect(tag.isValid, isTrue);
    expect(tag.toString(), equals('<tagname class="myclass"'));
  }

  // ignore: non_constant_identifier_names
  void test_classesAndMatchingClassAttrBindingValid() {
    final tag = new HtmlTagForSelector()
      ..name = "tagname"
      ..addClass("myclass")
      ..setAttribute("class", value: 'myclass');
    expect(tag.isValid, isTrue);
    expect(tag.toString(), equals('<tagname class="myclass"'));
  }

  // ignore: non_constant_identifier_names
  void test_cloneHasItsOwnClasses() {
    final tag = new HtmlTagForSelector()..name = "tagname";
    final clone = tag.clone()..addClass("myclass");
    expect(tag.toString(), "<tagname");
    expect(clone.toString(), '<tagname class="myclass"');
  }

  // ignore: non_constant_identifier_names
  void test_cloneHasItsOwnProperties() {
    final tag = new HtmlTagForSelector()..name = "tagname";
    final clone = tag.clone()..setAttribute("attr");
    expect(tag.toString(), "<tagname");
    expect(clone.toString(), "<tagname attr");
  }

  // ignore: non_constant_identifier_names
  void test_cloneIsAClone() {
    final tag = new HtmlTagForSelector();
    final clone = tag.clone();
    tag.name = "original";
    clone.name = "clone";
    expect(tag, isNot(equals(clone)));
    expect(tag.isValid, isTrue);
    expect(tag.toString(), "<original");
    expect(clone.isValid, isTrue);
    expect(clone.toString(), "<clone");
  }

  // ignore: non_constant_identifier_names
  void test_cloneKeepsAttributes() {
    var tag = new HtmlTagForSelector()
      ..name = "tagname"
      ..setAttribute("attr1")
      ..setAttribute("attr2");
    tag = tag.clone();
    expect(tag.toString(), equals("<tagname attr1 attr2"));
  }

  // ignore: non_constant_identifier_names
  void test_cloneKeepsAttributeValues() {
    var tag = new HtmlTagForSelector()
      ..name = "tagname"
      ..setAttribute("attr1", value: 'value1')
      ..setAttribute("attr2", value: 'value2');
    tag = tag.clone();
    expect(tag.toString(), equals('<tagname attr1="value1" attr2="value2"'));
  }

  // ignore: non_constant_identifier_names
  void test_cloneKeepsClassnames() {
    var tag = new HtmlTagForSelector()
      ..name = "tagname"
      ..addClass("class1")
      ..addClass("class2");
    tag = tag.clone();
    expect(tag.isValid, isTrue);
    expect(tag.toString(), equals('<tagname class="class1 class2"'));
  }

  // ignore: non_constant_identifier_names
  void test_cloneKeepsName() {
    var tag = new HtmlTagForSelector()..name = "tagname";
    tag = tag.clone();
    expect(tag.toString(), equals("<tagname"));
  }

  // ignore: non_constant_identifier_names
  void test_cloneKeepsValid() {
    var tag = new HtmlTagForSelector()..name = "tagname";

    // ignore: cascade_invocations
    tag.name = "break this tag";

    // ignore: cascade_invocations
    tag = tag.clone();
    expect(tag.isValid, isFalse);
  }

  // ignore: non_constant_identifier_names
  void test_cloneWithoutNameCanBecomeValid() {
    var tag = new HtmlTagForSelector();
    tag = tag.clone()..name = "tagname";
    expect(tag.isValid, isTrue);
  }

  // ignore: non_constant_identifier_names
  void test_noNameIsInvalid() {
    final tag = new HtmlTagForSelector();
    expect(tag.isValid, isFalse);
  }

  // ignore: non_constant_identifier_names
  void test_setAttributeConflictingValues() {
    final tag = new HtmlTagForSelector()
      ..name = "tagname"
      ..setAttribute("attr", value: "value1");
    // ignore: cascade_invocations
    tag.setAttribute("attr", value: "value2");
    expect(tag.isValid, isFalse);
  }

  // ignore: non_constant_identifier_names
  void test_setAttributeNoValue() {
    final tag = new HtmlTagForSelector()
      ..name = "tagname"
      ..setAttribute("attr");
    expect(tag.isValid, isTrue);
    expect(tag.toString(), equals("<tagname attr"));
  }

  // ignore: non_constant_identifier_names
  void test_setAttributeNoValueAfterValue() {
    final tag = new HtmlTagForSelector()
      ..name = "tagname"
      ..setAttribute("attr", value: "value");
    // ignore: cascade_invocations
    tag.setAttribute("attr");
    expect(tag.isValid, isTrue);
    expect(tag.toString(), equals('<tagname attr="value"'));
  }

  // ignore: non_constant_identifier_names
  void test_setAttributeNoValueTwice() {
    final tag = new HtmlTagForSelector()
      ..name = "tagname"
      ..setAttribute("attr");
    // ignore: cascade_invocations
    tag.setAttribute("attr");
    expect(tag.isValid, isTrue);
    expect(tag.toString(), equals("<tagname attr"));
  }

  // ignore: non_constant_identifier_names
  void test_setAttributeValue() {
    final tag = new HtmlTagForSelector()
      ..name = "tagname"
      ..setAttribute("attr", value: "value");
    expect(tag.isValid, isTrue);
    expect(tag.toString(), equals('<tagname attr="value"'));
  }

  // ignore: non_constant_identifier_names
  void test_setAttributeValueAfterJustAttr() {
    final tag = new HtmlTagForSelector()
      ..name = "tagname"
      ..setAttribute("attr");
    // ignore: cascade_invocations
    tag.setAttribute("attr", value: "value");
    expect(tag.isValid, isTrue);
    expect(tag.toString(), equals('<tagname attr="value"'));
  }

  // ignore: non_constant_identifier_names
  void test_setAttributeValueTwice() {
    final tag = new HtmlTagForSelector()
      ..name = "tagname"
      ..setAttribute("attr", value: "value");
    // ignore: cascade_invocations
    tag.setAttribute("attr", value: "value");
    expect(tag.isValid, isTrue);
    expect(tag.toString(), equals('<tagname attr="value"'));
  }

  // ignore: non_constant_identifier_names
  void test_setName() {
    final tag = new HtmlTagForSelector()..name = "myname";
    expect(tag.isValid, isTrue);
    expect(tag.toString(), equals("<myname"));
  }

  // ignore: non_constant_identifier_names
  void test_setNameConflicting() {
    final tag = new HtmlTagForSelector()..name = "myname1";
    // ignore: cascade_invocations
    tag.name = "myname2";
    expect(tag.isValid, isFalse);
  }

  // ignore: non_constant_identifier_names
  void test_setNameTwice() {
    final tag = new HtmlTagForSelector()..name = "myname";
    // ignore: cascade_invocations
    tag.name = "myname";
    expect(tag.isValid, isTrue);
    expect(tag.toString(), equals("<myname"));
  }

  // ignore: non_constant_identifier_names
  void test_toStringIsAlphabeticalClasses() {
    final tag = new HtmlTagForSelector()
      ..name = "tagname"
      ..addClass("apple")
      ..addClass("flick")
      ..addClass("ziggy")
      ..addClass("cow");
    expect(tag.toString(), '<tagname class="apple cow flick ziggy"');
  }

  // ignore: non_constant_identifier_names
  void test_toStringIsAlphabeticalProperties() {
    final tag = new HtmlTagForSelector()
      ..name = "tagname"
      ..setAttribute("apple")
      ..setAttribute("flick")
      ..setAttribute("ziggy")
      ..setAttribute("cow")
      ..addClass("classes");
    expect(tag.toString(), '<tagname apple class="classes" cow flick ziggy');
  }
}

@reflectiveTest
class NotSelectorTest extends _SelectorTest {
  final condition = new _SelectorMock('aaa');

  NotSelector selector;

  @override
  void setUp() {
    super.setUp();
    selector = new NotSelector(condition);
  }

  // ignore: non_constant_identifier_names
  void test_notAttribute_availableTo_false() {
    final nameElement = new AngularElementImpl('kind', 10, 5, null);
    final attributeSelector = new AttributeSelector(nameElement, null);
    when(element.attributes).thenReturn({'kind': 'strange'});
    when(element.attributeNameSpans)
        .thenReturn({'kind': _newStringSpan(100, 'kind')});
    selector = new NotSelector(attributeSelector);
    expect(selector.availableTo(element), equals(false));
  }

  // ignore: non_constant_identifier_names
  void test_notAttribute_availableTo_true() {
    final nameElement = new AngularElementImpl('kind', 10, 5, null);
    final attributeSelector = new AttributeSelector(nameElement, null);
    when(element.attributes).thenReturn({'not-kind': 'strange'});
    when(element.attributeNameSpans)
        .thenReturn({'not-kind': _newStringSpan(100, 'not-kind')});
    selector = new NotSelector(attributeSelector);
    expect(selector.availableTo(element), true);
  }

  // ignore: non_constant_identifier_names
  void test_notFalse() {
    when(condition.match(typed(any), typed(any)))
        .thenReturn(SelectorMatch.NoMatch);
    when(condition.availableTo(typed(any))).thenReturn(false);
    expect(
        selector.match(element, template), equals(SelectorMatch.NonTagMatch));
    expect(selector.availableTo(element), true);
  }

  // ignore: non_constant_identifier_names
  void test_notNonTagMatch() {
    when(condition.match(typed(any), typed(any)))
        .thenReturn(SelectorMatch.NonTagMatch);
    when(condition.availableTo(typed(any))).thenReturn(true);
    expect(selector.match(element, template), equals(SelectorMatch.NoMatch));
    expect(selector.availableTo(element), equals(false));
  }

  // ignore: non_constant_identifier_names
  void test_notTagMatch() {
    when(condition.match(typed(any), typed(any)))
        .thenReturn(SelectorMatch.TagMatch);
    when(condition.availableTo(typed(any))).thenReturn(true);
    expect(selector.match(element, template), equals(SelectorMatch.NoMatch));
    expect(selector.availableTo(element), equals(false));
  }
}

@reflectiveTest
class OrSelectorTest extends _SelectorTest {
  final selector1 = new _SelectorMock('aaa');
  final selector2 = new _SelectorMock('bbb');
  final selector3 = new _SelectorMock('ccc');

  OrSelector selector;

  @override
  void setUp() {
    super.setUp();
    selector = new OrSelector(<Selector>[selector1, selector2, selector3]);
    when(selector1.match(typed(any), typed(any)))
        .thenReturn(SelectorMatch.NoMatch);
    when(selector1.availableTo(typed(any))).thenReturn(false);
    when(selector2.match(typed(any), typed(any)))
        .thenReturn(SelectorMatch.NoMatch);
    when(selector2.availableTo(typed(any))).thenReturn(false);
    when(selector3.match(typed(any), typed(any)))
        .thenReturn(SelectorMatch.NoMatch);
    when(selector3.availableTo(typed(any))).thenReturn(false);
  }

  // ignore: non_constant_identifier_names
  void test_match2NonTagMatch() {
    when(selector2.match(typed(any), typed(any)))
        .thenReturn(SelectorMatch.NonTagMatch);
    expect(
        selector.match(element, template), equals(SelectorMatch.NonTagMatch));
    verify(selector1.match(typed(any), typed(any))).called(1);
    verify(selector2.match(typed(any), typed(any))).called(1);
    verify(selector3.match(typed(any), typed(any))).called(1);
  }

  // ignore: non_constant_identifier_names
  void test_match2TagAndNonTagMatch() {
    when(selector1.match(typed(any), typed(any)))
        .thenReturn(SelectorMatch.NonTagMatch);
    when(selector2.match(typed(any), typed(any)))
        .thenReturn(SelectorMatch.TagMatch);
    expect(selector.match(element, template), equals(SelectorMatch.TagMatch));
    verify(selector1.match(typed(any), typed(any))).called(1);
    verify(selector2.match(typed(any), typed(any))).called(1);
    verifyNever(selector3.match(typed(any), typed(any)));
  }

  // ignore: non_constant_identifier_names
  void test_match2TagMatch() {
    when(selector2.match(typed(any), typed(any)))
        .thenReturn(SelectorMatch.TagMatch);
    when(selector2.availableTo(typed(any))).thenReturn(true);
    expect(selector.match(element, template), equals(SelectorMatch.TagMatch));
    verify(selector1.match(typed(any), typed(any))).called(1);
    verify(selector2.match(typed(any), typed(any))).called(1);
    verifyNever(selector3.match(typed(any), typed(any)));

    expect(selector.availableTo(element), true);
    verify(selector1.availableTo(typed(any))).called(1);
    verify(selector2.availableTo(typed(any))).called(1);
    verifyNever(selector3.availableTo(typed(any)));
  }

  // ignore: non_constant_identifier_names
  void test_match_false() {
    expect(selector.match(element, template), equals(SelectorMatch.NoMatch));
    verify(selector1.match(typed(any), typed(any))).called(1);
    verify(selector2.match(typed(any), typed(any))).called(1);
    verify(selector3.match(typed(any), typed(any))).called(1);

    expect(selector.availableTo(element), equals(false));
    verify(selector1.availableTo(typed(any))).called(1);
    verify(selector2.availableTo(typed(any))).called(1);
    verify(selector3.availableTo(typed(any))).called(1);
  }

  // ignore: non_constant_identifier_names
  void test_matchFirstIsNonTagMatch() {
    when(selector1.match(typed(any), typed(any)))
        .thenReturn(SelectorMatch.NonTagMatch);
    expect(
        selector.match(element, template), equals(SelectorMatch.NonTagMatch));
    verify(selector1.match(typed(any), typed(any))).called(1);
    verify(selector2.match(typed(any), typed(any))).called(1);
    verify(selector3.match(typed(any), typed(any))).called(1);
  }

  // ignore: non_constant_identifier_names
  void test_matchFirstIsTagMatch() {
    when(selector1.match(typed(any), typed(any)))
        .thenReturn(SelectorMatch.TagMatch);
    when(selector1.availableTo(typed(any))).thenReturn(true);
    expect(selector.match(element, template), equals(SelectorMatch.TagMatch));
    verify(selector1.match(typed(any), typed(any))).called(1);
    verifyNever(selector2.match(typed(any), typed(any)));
    verifyNever(selector3.match(typed(any), typed(any)));

    expect(selector.availableTo(element), true);
    verify(selector1.availableTo(typed(any))).called(1);
    verifyNever(selector2.availableTo(typed(any)));
    verifyNever(selector3.availableTo(typed(any)));
  }

  // ignore: non_constant_identifier_names
  void test_toString() {
    expect(selector.toString(), 'aaa || bbb || ccc');
  }
}

@reflectiveTest
class SelectorParserTest {
  final Source source = new _SourceMock();

  // ignore: non_constant_identifier_names
  void test_and() {
    final selector = new SelectorParser(source, 10, '[ng-for][ng-for-of]')
        .parse() as AndSelector;
    expect(selector.selectors, hasLength(2));
    {
      final subSelector = selector.selectors[0] as AttributeSelector;
      final nameElement = subSelector.nameElement;
      expect(nameElement.source, source);
      expect(nameElement.name, 'ng-for');
      expect(nameElement.nameOffset, 11);
      expect(nameElement.nameLength, 'ng-for'.length);
    }
    {
      final subSelector = selector.selectors[1] as AttributeSelector;
      final nameElement = subSelector.nameElement;
      expect(nameElement.source, source);
      expect(nameElement.name, 'ng-for-of');
      expect(nameElement.nameOffset, 19);
      expect(nameElement.nameLength, 'ng-for-of'.length);
    }
  }

  // ignore: non_constant_identifier_names
  void test_attribute_beginsWithOperator_noValue() {
    try {
      new SelectorParser(source, 0, '[foo^=]').parse();
    } on FormatException catch (e) {
      expect(e.message, contains('Expected a value after ^=, got ]'));
      expect(e.offset, '[foo^='.length);
      return;
    }
    fail("was supposed to throw");
  }

  // ignore: non_constant_identifier_names
  void test_attribute_containsOperator_noValue() {
    try {
      new SelectorParser(source, 0, '[foo*=]').parse();
    } on FormatException catch (e) {
      expect(e.message, contains('Expected a value after *=, got ]'));
      expect(e.offset, '[foo*='.length);
      return;
    }
    fail("was supposed to throw");
  }

  // ignore: non_constant_identifier_names
  void test_attribute_hasValue() {
    final selector = new SelectorParser(source, 10, '[kind=pretty]').parse()
        as AttributeSelector;
    {
      final nameElement = selector.nameElement;
      expect(nameElement.source, source);
      expect(nameElement.name, 'kind');
      expect(nameElement.nameOffset, 11);
      expect(nameElement.nameLength, 'kind'.length);
    }
    expect(selector.value, 'pretty');
  }

  // ignore: non_constant_identifier_names
  void test_attribute_hasValueWithQuotes() {
    final selector =
        new SelectorParser(source, 10, '''[single='quotes'][double="quotes"]''')
            .parse() as AndSelector;
    expect(selector.selectors, hasLength(2));
    {
      final subSelector = selector.selectors[0] as AttributeSelector;
      {
        final nameElement = subSelector.nameElement;
        expect(nameElement.source, source);
        expect(nameElement.name, 'single');
      }
      // Ensure there are no quotes within the value
      expect(subSelector.value, 'quotes');
    }
    {
      final subSelector = selector.selectors[1] as AttributeSelector;
      {
        final nameElement = subSelector.nameElement;
        expect(nameElement.source, source);
        expect(nameElement.name, 'double');
      }
      // Ensure there are no quotes within the value
      expect(subSelector.value, 'quotes');
    }
  }

  // ignore: non_constant_identifier_names
  void test_attribute_hasWildcard() {
    final selector = new SelectorParser(source, 10, '[kind*=pretty]').parse()
        as AttributeContainsSelector;
    {
      final nameElement = selector.nameElement;
      expect(nameElement.source, source);
      expect(nameElement.name, 'kind');
      expect(nameElement.nameOffset, 11);
      expect(nameElement.nameLength, 'kind'.length);
    }
    expect(selector.value, 'pretty');
  }

  // ignore: non_constant_identifier_names
  void test_attribute_noValue() {
    final selector =
        new SelectorParser(source, 10, '[ng-for]').parse() as AttributeSelector;
    {
      final nameElement = selector.nameElement;
      expect(nameElement.source, source);
      expect(nameElement.name, 'ng-for');
      expect(nameElement.nameOffset, 11);
      expect(nameElement.nameLength, 'ng-for'.length);
    }
    expect(selector.value, isNull);
  }

  // ignore: non_constant_identifier_names
  void test_attribute_regularOperator_noValue() {
    try {
      new SelectorParser(source, 0, '[foo=]').parse();
    } on FormatException catch (e) {
      expect(e.message, contains('Expected a value after =, got ]'));
      expect(e.offset, '[foo='.length);
      return;
    }
    fail("was supposed to throw");
  }

  // ignore: non_constant_identifier_names
  void test_attribute_startsWith() {
    final selector = new SelectorParser(source, 10, '[foo^=bar]').parse()
        as AttributeStartsWithSelector;
    expect(selector.nameElement.name, 'foo');
    expect(selector.value, 'bar');
  }

  // ignore: non_constant_identifier_names
  void test_attribute_startsWith_quoted() {
    final selector = new SelectorParser(source, 10, '[foo^="bar"]').parse()
        as AttributeStartsWithSelector;
    expect(selector.nameElement.name, 'foo');
    expect(selector.value, 'bar');
  }

  // ignore: non_constant_identifier_names
  void test_attribute_textRegex() {
    final selector = new SelectorParser(source, 10, '[*=/pretty/]').parse()
        as AttributeValueRegexSelector;
    expect(selector.regexpStr, 'pretty');
  }

  // ignore: non_constant_identifier_names
  void test_bad() {
    try {
      new SelectorParser(source, 0, '+name').parse();
    } catch (e) {
      return;
    }
    fail("was supposed to throw");
  }

  // ignore: non_constant_identifier_names
  void test_class() {
    final selector =
        new SelectorParser(source, 10, '.nice').parse() as ClassSelector;
    final nameElement = selector.nameElement;
    expect(nameElement.source, source);
    expect(nameElement.name, 'nice');
    expect(nameElement.nameOffset, 11);
    expect(nameElement.nameLength, 'nice'.length);
  }

  // ignore: non_constant_identifier_names
  void test_complex_ast() {
    final selector = new SelectorParser(
            source, 10, 'aaa, bbb:not(ccc), :not(:not(ddd)[eee], fff[ggg])')
        .parse() as OrSelector;

    expect(
        selector.toString(),
        equals('aaa || bbb && :not(ccc) || '
            ':not(:not(ddd) && [eee] || fff && [ggg])'));
    {
      final subSelector = selector.selectors[0] as ElementNameSelector;
      expect(subSelector.toString(), "aaa");
    }
    {
      final subSelector = selector.selectors[1] as AndSelector;
      expect(subSelector.toString(), "bbb && :not(ccc)");
      {
        final subSelector2 = subSelector.selectors[0] as ElementNameSelector;
        expect(subSelector2.toString(), "bbb");
      }
      {
        final subSelector2 = subSelector.selectors[1] as NotSelector;
        expect(subSelector2.toString(), ":not(ccc)");
        {
          final subSelector3 = subSelector2.condition as ElementNameSelector;
          expect(subSelector3.toString(), "ccc");
        }
      }
    }
    {
      final subSelector = selector.selectors[2] as NotSelector;
      expect(
          subSelector.toString(), ":not(:not(ddd) && [eee] || fff && [ggg])");
      {
        final subSelector2 = subSelector.condition as OrSelector;
        expect(subSelector2.toString(), ":not(ddd) && [eee] || fff && [ggg]");
        {
          final subSelector3 = subSelector2.selectors[0] as AndSelector;
          expect(subSelector3.toString(), ":not(ddd) && [eee]");
          {
            final subSelector4 = subSelector3.selectors[0] as NotSelector;
            expect(subSelector4.toString(), ":not(ddd)");
            {
              final subSelector5 =
                  subSelector4.condition as ElementNameSelector;
              expect(subSelector5.toString(), "ddd");
            }
          }
          {
            final subSelector4 = subSelector3.selectors[1] as AttributeSelector;
            expect(subSelector4.toString(), "[eee]");
          }
        }
        {
          final subSelector3 = subSelector2.selectors[1] as AndSelector;
          expect(subSelector3.toString(), "fff && [ggg]");
          {
            final subSelector4 =
                subSelector3.selectors[0] as ElementNameSelector;
            expect(subSelector4.toString(), "fff");
          }
          {
            final subSelector4 = subSelector3.selectors[1] as AttributeSelector;
            expect(subSelector4.toString(), "[ggg]");
          }
        }
      }
    }
  }

  // ignore: non_constant_identifier_names
  void test_contains() {
    final selector = new SelectorParser(source, 10, ':contains(/aaa/)').parse()
        as ContainsSelector;
    expect(selector.regex, 'aaa');
  }

  // ignore: non_constant_identifier_names
  void test_elementName() {
    final selector = new SelectorParser(source, 10, 'text-panel').parse()
        as ElementNameSelector;
    final nameElement = selector.nameElement;
    expect(nameElement.source, source);
    expect(nameElement.name, 'text-panel');
    expect(nameElement.nameOffset, 10);
    expect(nameElement.nameLength, 'text-panel'.length);
  }

  // ignore: non_constant_identifier_names
  void test_not() {
    final selector =
        new SelectorParser(source, 10, ':not(aaa)').parse() as NotSelector;
    {
      final condition = selector.condition as ElementNameSelector;
      final nameElement = condition.nameElement;
      expect(nameElement.source, source);
      expect(nameElement.name, 'aaa');
      expect(nameElement.nameOffset, 15);
      expect(nameElement.nameLength, 'aaa'.length);
    }
  }

  // ignore: non_constant_identifier_names
  void test_or() {
    final selector =
        new SelectorParser(source, 10, 'aaa,bbb').parse() as OrSelector;
    expect(selector.selectors, hasLength(2));
    {
      final subSelector = selector.selectors[0] as ElementNameSelector;
      final nameElement = subSelector.nameElement;
      expect(nameElement.source, source);
      expect(nameElement.name, 'aaa');
      expect(nameElement.nameOffset, 10);
      expect(nameElement.nameLength, 'aaa'.length);
    }
    {
      final subSelector = selector.selectors[1] as ElementNameSelector;
      final nameElement = subSelector.nameElement;
      expect(nameElement.source, source);
      expect(nameElement.name, 'bbb');
      expect(nameElement.nameOffset, 14);
      expect(nameElement.nameLength, 'bbb'.length);
    }
  }
}

@reflectiveTest
class SuggestTagsTest {
  // ignore: non_constant_identifier_names
  void test_suggestAndMergesSuggestionConstraints() {
    final nameSelector =
        new ElementNameSelector(new AngularElementImpl('panel', 10, 5, null));
    final attrSelector = new AttributeContainsSelector(
        new AngularElementImpl('attr', 10, 5, null), "value");
    final selector = new AndSelector([nameSelector, attrSelector]);

    final suggestions = selector.suggestTags();
    expect(suggestions.length, 1);
    expect(suggestions.first.isValid, isTrue);
    expect(suggestions.first.toString(), equals('<panel attr="value"'));
  }

  // ignore: non_constant_identifier_names
  void test_suggestAndOr() {
    final nameSelector1 =
        new ElementNameSelector(new AngularElementImpl('name1', 10, 5, null));
    final nameSelector2 =
        new ElementNameSelector(new AngularElementImpl('name2', 10, 5, null));
    final orSelector1 = new OrSelector([nameSelector1, nameSelector2]);

    final attrSelector1 = new AttributeContainsSelector(
        new AngularElementImpl('attr1', 10, 5, null), "value");
    final attrSelector2 = new AttributeContainsSelector(
        new AngularElementImpl('attr2', 10, 5, null), "value");
    final orSelector2 = new OrSelector([attrSelector1, attrSelector2]);

    final selector = new AndSelector([orSelector1, orSelector2]);

    final suggestions = selector.suggestTags();
    expect(suggestions.length, 4);
    final suggestionsMap = <String, HtmlTagForSelector>{};
    suggestions.forEach((s) => suggestionsMap[s.toString()] = s);

    // basically (name1, name2)(attr1, attr2) though I'm not sure that's legal
    expect(suggestionsMap['<name1 attr1="value"'], isNotNull);
    expect(suggestionsMap['<name1 attr2="value"'], isNotNull);
    expect(suggestionsMap['<name2 attr1="value"'], isNotNull);
    expect(suggestionsMap['<name2 attr2="value"'], isNotNull);
  }

  // ignore: non_constant_identifier_names
  void test_suggestClass() {
    final selector =
        new ClassSelector(new AngularElementImpl('myclass', 10, 5, null));

    final suggestions = _evenInvalidSuggestions(selector);
    expect(suggestions.length, 1);
    expect(suggestions.first.isValid, isFalse);
    expect(suggestions.first.toString(), equals('<null class="myclass"'));
  }

  // ignore: non_constant_identifier_names
  void test_suggestClasses() {
    final selector1 =
        new ClassSelector(new AngularElementImpl('class1', 10, 5, null));
    final selector2 =
        new ClassSelector(new AngularElementImpl('class2', 10, 5, null));

    final suggestions =
        selector2.refineTagSuggestions(_evenInvalidSuggestions(selector1));
    expect(suggestions.length, 1);
    expect(suggestions.first.isValid, isFalse);
    // check ClassSelector used tag.addClass(x), not tag.setAttr("class", x)
    expect(suggestions.first.toString(), equals('<null class="class1 class2"'));
  }

  // ignore: non_constant_identifier_names
  void test_suggestContainsIsInvalid() {
    final selector = new ContainsSelector("foo");

    final suggestions = _evenInvalidSuggestions(selector);
    expect(suggestions.length, 1);
    expect(suggestions.first.isValid, isFalse);
    // we could assert that it can't be made valid by adding a name,
    // but :contains is only allowed if it comprises the WHOLE selector (which
    // is admittedly not as well as the angular team coulddo and might change,
    // but :contains is so rare we can leave this).
  }

  // ignore: non_constant_identifier_names
  void test_suggestNodeName() {
    final selector =
        new ElementNameSelector(new AngularElementImpl('panel', 10, 5, null));

    final suggestions = selector.suggestTags();
    expect(suggestions.length, 1);
    expect(suggestions.first.isValid, isTrue);
    expect(suggestions.first.toString(), equals("<panel"));
  }

  // ignore: non_constant_identifier_names
  void test_suggestOrAnd() {
    final nameSelector1 =
        new ElementNameSelector(new AngularElementImpl('name1', 10, 5, null));
    final attrSelector1 = new AttributeContainsSelector(
        new AngularElementImpl('attr1', 10, 5, null), "value");
    final andSelector1 = new AndSelector([nameSelector1, attrSelector1]);
    final nameSelector2 =
        new ElementNameSelector(new AngularElementImpl('name2', 10, 5, null));
    final attrSelector2 = new AttributeContainsSelector(
        new AngularElementImpl('attr2', 10, 5, null), "value");
    final andSelector2 = new AndSelector([nameSelector2, attrSelector2]);
    final selector = new OrSelector([andSelector1, andSelector2]);

    final suggestions = selector.suggestTags();
    expect(suggestions.length, 2);
    final suggestionsMap = <String, HtmlTagForSelector>{};
    suggestions.forEach((s) => suggestionsMap[s.toString()] = s);
    expect(suggestionsMap['<name1 attr1="value"'], isNotNull);
    expect(suggestionsMap['<name2 attr2="value"'], isNotNull);
  }

  // ignore: non_constant_identifier_names
  void test_suggestOrMergesSuggestionConstraints() {
    final nameSelector =
        new ElementNameSelector(new AngularElementImpl('panel', 10, 5, null));
    final attrSelector = new AttributeContainsSelector(
        new AngularElementImpl('attr', 10, 5, null), "value");
    final selector = new OrSelector([nameSelector, attrSelector]);

    final suggestions = _evenInvalidSuggestions(selector);
    expect(suggestions.length, 2);
    final suggestionsMap = <String, HtmlTagForSelector>{};
    suggestions.forEach((s) => suggestionsMap[s.toString()] = s);
    expect(suggestionsMap["<panel"], isNotNull);
    expect(suggestionsMap["<panel"].isValid, isTrue);
    expect(suggestionsMap['<null attr="value"'], isNotNull);
    expect(suggestionsMap['<null attr="value"'].isValid, isFalse);
  }

  // ignore: non_constant_identifier_names
  void test_suggestOrOr() {
    final nameSelector1 =
        new ElementNameSelector(new AngularElementImpl('name1', 10, 5, null));
    final nameSelector2 =
        new ElementNameSelector(new AngularElementImpl('name2', 10, 5, null));
    final orSelector1 = new OrSelector([nameSelector1, nameSelector2]);

    final attrSelector1 = new AttributeContainsSelector(
        new AngularElementImpl('attr1', 10, 5, null), "value");
    final attrSelector2 = new AttributeContainsSelector(
        new AngularElementImpl('attr2', 10, 5, null), "value");
    final orSelector2 = new OrSelector([attrSelector1, attrSelector2]);

    final selector = new OrSelector([orSelector1, orSelector2]);

    final suggestions = _evenInvalidSuggestions(selector);
    expect(suggestions.length, 4);
    final suggestionsMap = <String, HtmlTagForSelector>{};
    suggestions.forEach((s) => suggestionsMap[s.toString()] = s);

    // basically (name1, name2),(attr1, attr2) though I'm not sure that's legal
    expect(suggestionsMap['<name1'], isNotNull);
    expect(suggestionsMap['<null attr2="value"'], isNotNull);
    expect(suggestionsMap['<name2'], isNotNull);
    expect(suggestionsMap['<null attr2="value"'], isNotNull);
  }

  // ignore: non_constant_identifier_names
  void test_suggestPropertyNoValue() {
    final selector = new AttributeSelector(
        new AngularElementImpl('attr', 10, 5, null), null);

    final suggestions = _evenInvalidSuggestions(selector);
    expect(suggestions.length, 1);
    expect(suggestions.first.isValid, isFalse);
    expect(suggestions.first.toString(), equals("<null attr"));
  }

  // ignore: non_constant_identifier_names
  void test_suggestPropertyWithValue() {
    final selector = new AttributeSelector(
        new AngularElementImpl('attr', 10, 5, null), "blah");

    final suggestions = _evenInvalidSuggestions(selector);
    expect(suggestions.length, 1);
    expect(suggestions.first.isValid, isFalse);
    expect(suggestions.first.toString(), equals('<null attr="blah"'));
  }

  // ignore: non_constant_identifier_names
  void test_suggestRegexPropertyValueNoops() {
    final selector = new AttributeValueRegexSelector("foo");

    final suggestions = _evenInvalidSuggestions(selector);
    expect(suggestions.length, 1);
    expect(suggestions.first.isValid, isFalse);
    expect(suggestions.first.toString(),
        equals(new HtmlTagForSelector().toString()));
  }

  // ignore: non_constant_identifier_names
  void test_suggestTagsFiltersInvalidResults() {
    final selector =
        new ClassSelector(new AngularElementImpl('class', 10, 5, null));
    expect(_evenInvalidSuggestions(selector), hasLength(1));
    expect(_evenInvalidSuggestions(selector).first.isValid, isFalse);
    expect(selector.suggestTags(), hasLength(0));
  }

  // ignore: non_constant_identifier_names
  void test_suggestWildcardProperty() {
    final selector = new AttributeContainsSelector(
        new AngularElementImpl('attr', 10, 5, null), "value");

    final suggestions = _evenInvalidSuggestions(selector);
    expect(suggestions.length, 1);
    expect(suggestions.first.isValid, isFalse);
    // [attr*=x] tells us they at LEAST want attr=x
    expect(suggestions.first.toString(), equals('<null attr="value"'));
  }

  /// [refineTagSuggestions] filters out invalid tags, but those are important
  /// for us to test sometimes. This will do the same thing, but keep invalid
  /// suggestions so we can inspect them.
  List<HtmlTagForSelector> _evenInvalidSuggestions(Selector selector) {
    final tags = <HtmlTagForSelector>[new HtmlTagForSelector()];
    return selector.refineTagSuggestions(tags);
  }
}

class _ElementViewMock extends Mock implements ElementView {}

class _SelectorMock extends Mock implements Selector {
  final String text;

  _SelectorMock(this.text);

  @override
  String toString() => text;
}

class _SelectorTest {
  ElementView element = new _ElementViewMock();
  Template template = new _TemplateMock();

  List<ResolvedRange> resolvedRanges = <ResolvedRange>[];

  void setUp() {
    // TODO(mfairhurst): remove `as dynamic`. See https://github.com/dart-lang/sdk/issues/33934
    when(template.addRange(typed(any), typed(any)) as dynamic)
        .thenAnswer((invocation) {
      final range = invocation.positionalArguments[0] as SourceRange;
      final element = invocation.positionalArguments[1] as AngularElement;
      resolvedRanges.add(new ResolvedRange(range, element));
    });
  }

  void _assertRange(ResolvedRange resolvedRange, int offset, int length,
      AngularElement element) {
    final range = resolvedRange.range;
    expect(range.offset, offset);
    expect(range.length, length);
    expect(resolvedRange.element, element);
  }

  SourceRange _newStringSpan(int offset, String value) =>
      new SourceRange(offset, value.length);
}

class _SourceMock extends Mock implements Source {}

class _TemplateMock extends Mock implements Template {}
