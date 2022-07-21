import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:form_builder_validators/localization/l10n.dart';

typedef Translate = String Function(BuildContext buildContext, String fieldId, String labelOrKey);
typedef OnSubmit = void Function(Map<String, String> formData);
typedef OnCancel = void Function();
typedef FormKey = GlobalKey<FormBuilderState>;

class FormBuilderConfiguration {
  final Map<String, ValueChanged> _functionsByFieldId = {};
  final Map<String, FormFieldValidator> _extraValidatorsByFieldId = {};
  OnSubmit _onSubmit;
  OnCancel _onCancel;
  FormKey _formKey;
  String _descriptionFileName;
  AutovalidateMode _autovalidateMode;
  Translate _translate;

  FormBuilderConfiguration(
      {required onSubmit,
      required onCancel,
      required formKey,
      AutovalidateMode? autovalidateMode,
      required descriptionFileName, Translate? translate})
      : _onSubmit = onSubmit,
        _onCancel = onCancel,
        _descriptionFileName = descriptionFileName,
        _autovalidateMode = autovalidateMode ?? AutovalidateMode.disabled,
        _translate = translate ?? flutterI18nTranslate,
        _formKey = formKey;

  void addOnChange(String fieldId, ValueChanged function) {
    _functionsByFieldId[fieldId] = function;
  }

  ValueChanged? getOnChange(String fieldId) {
    return _functionsByFieldId[fieldId];
  }

  String get descriptionFileName => _descriptionFileName;

  FormKey get formKey => _formKey;

  Function get onCancel => _onCancel;

  Function get onSubmit => _onSubmit;

  AutovalidateMode get autovalidateMode => _autovalidateMode;

  Map<String, FormFieldValidator> get extraValidatorsByFieldId =>
      _extraValidatorsByFieldId;

  Map<String, ValueChanged> get functionsByFieldId => _functionsByFieldId;

  Translate get translate => _translate;
}

Translate flutterI18nTranslate = (buildContext, fieldId, labelOrKey)  {
  return FlutterI18n.translate(buildContext, labelOrKey);
};
