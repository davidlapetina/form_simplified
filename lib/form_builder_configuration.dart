import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// Type of the function to define in order to translate labels and texts
typedef Translate = String Function(
    BuildContext buildContext, String fieldId, String labelOrKey);

/// Type of the function to implement to get the content of the form upon validation
typedef OnSubmit = void Function(Map<String, dynamic> formData);

/// Type of the function to implement to get the content of the form upon cancelation
typedef OnCancel = void Function();
typedef FormKey = GlobalKey<FormBuilderState>;

class FormBuilderConfiguration {
  final Map<String, ValueChanged> _functionsByFieldId = {};
  final Map<String, FormFieldValidator> _extraValidatorsByFieldId = {};
  OnSubmit _onSubmit;
  OnCancel? _onCancel;
  FormKey _formKey;
  String _descriptionFileName;
  AutovalidateMode _autovalidateMode;
  Translate _translate;

  FormBuilderConfiguration(
      {required OnSubmit onSubmit,
      OnCancel? onCancel,
      required FormKey formKey,
      AutovalidateMode? autovalidateMode,
      required descriptionFileName,
      Translate? translate})
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

  OnCancel? get onCancel => _onCancel;

  OnSubmit get onSubmit => _onSubmit;

  AutovalidateMode get autovalidateMode => _autovalidateMode;

  Map<String, FormFieldValidator> get extraValidatorsByFieldId =>
      _extraValidatorsByFieldId;

  Map<String, ValueChanged> get functionsByFieldId => _functionsByFieldId;

  Translate get translate => _translate;
}

Translate flutterI18nTranslate = (buildContext, fieldId, labelOrKey) {
  return FlutterI18n.translate(buildContext, labelOrKey);
};
