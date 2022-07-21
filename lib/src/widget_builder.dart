import 'package:form_simplified/form_simplified.dart';
import 'package:form_simplified/form_builder_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

class FormWidgetBuilder {
  final FormBuilderConfiguration _configuration;

  final dynamic _formData;

  FormWidgetBuilder({required FormBuilderConfiguration configuration,
    required dynamic formData})
      : _configuration = configuration,
        _formData = formData;

  WidgetBuilderResult getFormContent(BuildContext buildContext) {
    Widget? submit = _buildSubmit(buildContext);
    Widget? cancel = _buildCancel(buildContext);

    Map<String, Widget> fields = {};
    List<dynamic>? fieldsDescription = _formData['fields'];
    if (fieldsDescription == null || fieldsDescription.isEmpty) {
      return WidgetBuilderResult(
          fields: fields,
          submit: submit,
          cancel: cancel); //in case we want an empty form we just submit/cancel
    }
    for (dynamic fieldDescription in fieldsDescription) {
      String? type = fieldDescription['type'];
      String? label = fieldDescription['label'];
      String? id = fieldDescription['id'];
      if (type == null || label == null || id == null) {
        throw Exception('Type, Label and Id are mandatory');
      }

      Widget widget;
      switch (type) {
        case "FilterChip":
          widget = _buildFilterChip(id, label, fieldDescription, buildContext);
          break;
        case "ChoiceChip":
          widget = _buildChoiceChip(id, label, fieldDescription, buildContext);
          break;
        case "DateTimePicker":
          widget =
              _buildDateTimePicker(id, label, fieldDescription, buildContext);
          break;
        case "DateRangePicker":
          widget =
              _buildDateRangePicker(id, label, fieldDescription, buildContext);
          break;
        case "Slider":
          widget = _buildSlider(id, label, fieldDescription, buildContext);
          break;
        case "Checkbox":
          widget = _buildCheckbox(id, label, fieldDescription, buildContext);
          break;
        case "TextField":
          widget = _buildTextField(id, label, fieldDescription, buildContext);
          break;
        case "Dropdown":
          widget = _buildDropdown(id, label, fieldDescription, buildContext);
          break;
        default:
          throw Exception('Unsupported field type $type');
      }
      fields[id] = widget;
    }
    return WidgetBuilderResult(fields: fields, submit: submit, cancel: cancel);
  }

  Widget? _buildSubmit(BuildContext context) {
    dynamic submit = _formData['submit'];
    if (submit == null) {
      return null;
    }

    String label = _configuration.translate(context, 'submit', submit['label']);
    String? icon = submit['icon'];
    Function onPressed = () {
      _configuration.formKey.currentState!.save();
      if (_configuration.formKey.currentState!.validate()) {
        _configuration.onSubmit(_configuration.formKey.currentState!.value);
      }
    };

    //For now we only have protocol asset://
    return _buildButton(label, icon, onPressed);
  }

  Widget? _buildCancel(BuildContext context) {
    dynamic cancel = _formData['cancel'];
    if (cancel == null) {
      return null;
    }

    String label = _configuration.translate(context, 'cancel', cancel['label']);
    String? icon = cancel['icon'];

    Function onPressed = () {
      _configuration.formKey.currentState!.reset();
      _configuration.onCancel();
    };


    return _buildButton(label, icon, onPressed);
  }

  TextButton _buildButton(String label, String? icon, Function onPressed) {
    //For now we only have protocol asset://
    if (icon == null || !icon.startsWith("asset://")) {
      return TextButton(
        onPressed: () => {onPressed()},
        child: Text(
          label,
        ),
      );
    }

    //For now we only have protocol asset://

    Widget iconWidget = ImageIcon(
      AssetImage(icon.substring("asset://".length)),
    );
    return TextButton.icon(
      onPressed: () => {onPressed()},
      label: Text(label),
      icon: iconWidget,
    );
  }

  Widget _buildFilterChip(String id, String label, dynamic fieldDescription,
      BuildContext buildContext) {
    List<FormBuilderChipOption<dynamic>> options = [];
    List<dynamic>? fieldOptions = fieldDescription['options'];
    if (fieldOptions == null || fieldOptions.isEmpty) {
      throw Exception('Need at least on option');
    }
    for (dynamic option in fieldOptions) {
      dynamic? value = option['value'];
      String? text = option['label'];
      if (value == null || text == null) {
        throw Exception('value and text are mandatory');
      }
      options.add(FormBuilderChipOption(value: value, child: Text(text)));
    }
    return FormBuilderFilterChip(
        name: id,
        onChanged: _configuration.getOnChange(id),
        decoration: InputDecoration(
          labelText: _configuration.translate(buildContext, id, label),
        ),
        validator: _buildGenericValidators(id, fieldDescription),
        options: options);
  }

  Widget _buildChoiceChip(String id, String label, fieldDescription,
      BuildContext buildContext) {
    List<FormBuilderChipOption<dynamic>> options = [];
    List<dynamic>? fieldOptions = fieldDescription['options'];
    if (fieldOptions == null || fieldOptions.isEmpty) {
      throw Exception('Need at least on option');
    }
    for (dynamic option in fieldOptions) {
      dynamic? value = option['value'];
      String? text = option['label'];
      if (value == null || text == null) {
        throw Exception('value and text are mandatory');
      }
      options.add(FormBuilderChipOption(
          value: value,
          child: Text(_configuration.translate(buildContext, id, text))));
    }
    return FormBuilderChoiceChip(
        name: id,
        decoration: InputDecoration(
          labelText: _configuration.translate(buildContext, id, label),
        ),
        onChanged: _configuration.getOnChange(id),
        validator: _buildGenericValidators(id, fieldDescription),
        options: options);
  }

  Widget _buildDateTimePicker(String id, String label, fieldDescription,
      BuildContext buildContext) {
    InputType inputType;
    switch (fieldDescription['inputType']) {
      case 'time':
        inputType = InputType.time;
        break;
      case 'date':
        inputType = InputType.date;
        break;
      default:
        inputType = InputType.both;
    }
    TimeOfDay initialTime = _parseTime(fieldDescription['initialTime']);
    DateTime initialDate = _parseDate(fieldDescription['initialDate']);
    return FormBuilderDateTimePicker(
      name: id,
      // onChanged: _onChanged,
      inputType: inputType,
      decoration: InputDecoration(
        labelText: _configuration.translate(buildContext, id, label),
      ),
      onChanged: _configuration.getOnChange(id),
      validator: _buildGenericValidators(id, fieldDescription),
      initialTime: initialTime,
      initialDate: initialDate,
    );
  }

  Widget _buildDateRangePicker(String id, String label, fieldDescription,
      BuildContext buildContext) {
    String format = fieldDescription['format'] ?? 'yyyy-MM-dd';
    return FormBuilderDateRangePicker(
      name: id,
      firstDate: _parseDate(fieldDescription['firstDate']),
      lastDate: _parseDate(fieldDescription['lastDate']),
      format: DateFormat(format),
      onChanged: _configuration.getOnChange(id),
      validator: _buildGenericValidators(id, fieldDescription),
      decoration: InputDecoration(
        labelText: _configuration.translate(buildContext, id, label),
      ),
    );
  }

  Widget _buildSlider(String id, String label, fieldDescription,
      BuildContext buildContext) {
    return FormBuilderSlider(
      name: id,
      onChanged: _configuration.getOnChange(id),
      validator: _buildGenericValidators(id, fieldDescription),
      min: fieldDescription['min'],
      max: fieldDescription['max'],
      initialValue: fieldDescription['initialValue'],
      divisions: fieldDescription['divisions'],
      decoration: InputDecoration(
        labelText: _configuration.translate(buildContext, id, label),
      ),
    );
  }

  Widget _buildCheckbox(String id, String label, fieldDescription,
      BuildContext buildContext) {
    return FormBuilderCheckbox(
      name: id,
      initialValue: fieldDescription['initialValue'],
      onChanged: _configuration.getOnChange(id),
      validator: _buildGenericValidators(id, fieldDescription),
      title: Text(
        _configuration.translate(buildContext, id, label),
      ),
    );
  }

  Widget _buildDropdown(String id, String label, fieldDescription,
      BuildContext buildContext) {
    List<DropdownMenuItem<dynamic>> options = [];
    List<dynamic>? fieldOptions = fieldDescription['options'];
    if (fieldOptions == null || fieldOptions.isEmpty) {
      throw Exception('Need at least on option');
    }
    for (dynamic option in fieldOptions) {
      dynamic? value = option['value'];
      String? text = option['label'];
      if (value == null || text == null) {
        throw Exception('value and text are mandatory');
      }
      options.add(DropdownMenuItem(
          value: value,
          child: Text(_configuration.translate(buildContext, id, text))));
    }

    String? hint = fieldDescription['hint'];
    return FormBuilderDropdown(
        name: id,
        decoration: InputDecoration(
          labelText: _configuration.translate(buildContext, id, label),
        ),
        // initialValue: 'Male',
        allowClear: fieldDescription['allowClear'] ?? true,
        hint: hint != null
            ? Text(_configuration.translate(buildContext, id, hint))
            : null,
        onChanged: _configuration.getOnChange(id),
        validator: _buildGenericValidators(id, fieldDescription),
        items: options);
  }

  Widget _buildTextField(String id, String label, fieldDescription,
      BuildContext buildContext) {
    TextInputType inputType;
    switch (fieldDescription['inputType']) {
      case 'dateTime':
        inputType = TextInputType.datetime;
        break;
      case 'emailAddress':
        inputType = TextInputType.emailAddress;
        break;
      case 'number':
        inputType = TextInputType.number;
        break;
      case 'phone':
        inputType = TextInputType.phone;
        break;
      default:
        inputType = TextInputType.text;
    }

    return FormBuilderTextField(
      name: id,
      decoration: InputDecoration(
        labelText: _configuration.translate(buildContext, id, label),
      ),
      onChanged: _configuration.getOnChange(id),
      // valueTransformer: (text) => num.tryParse(text),
      validator: _buildStringValidators(id, fieldDescription),
      keyboardType: inputType,
    );
  }

  FormFieldValidator? _buildGenericValidators(String id, fieldDescription) {
    List<dynamic>? validatorsConf = fieldDescription['validators'];

    var customValidator = _configuration.extraValidatorsByFieldId[id];
    if (validatorsConf == null || validatorsConf.isEmpty) {
      return customValidator; //if one good, if none then null
    }

    List<FormFieldValidator<dynamic>> validators = [];
    for (dynamic validatorConf in validatorsConf) {
      String? type = validatorConf['type'];
      if (type == null) {
        throw Exception('Type of validator cannot be null');
      }
      dynamic value = validatorConf['value'];
      switch (type) {
        case 'equal':
          validators.add(FormBuilderValidators.equal(value));
          break;
        case 'max':
          validators.add(FormBuilderValidators.max(value));
          break;
        case 'maxLength':
          validators.add(FormBuilderValidators.maxLength(value));
          break;
        case 'min':
          validators.add(FormBuilderValidators.min(value));
          break;
        case 'minLength':
          validators.add(FormBuilderValidators.minLength(value));
          break;
        case 'equalLength':
          validators.add(FormBuilderValidators.equalLength(value));
          break;
        case 'required':
          validators.add(FormBuilderValidators.required());
          break;
        default:
          throw Exception('Type of validator unkown:  ${type}');
      }
    }

    if (customValidator != null) {
      validators.add(customValidator);
    }

    return FormBuilderValidators.compose(validators);
  }

  FormFieldValidator<String?>? _buildStringValidators(String id,
      fieldDescription) {
    List<dynamic>? validatorsConf = fieldDescription['validators'];

    var customValidator = _configuration.extraValidatorsByFieldId[id];
    if (validatorsConf == null || validatorsConf.isEmpty) {
      return customValidator; //if one good, if none then null
    }

    List<FormFieldValidator<String?>> validators = [];
    for (dynamic validatorConf in validatorsConf) {
      String? type = validatorConf['type'];
      if (type == null) {
        throw Exception('Type of validator cannot be null');
      }
      dynamic value = validatorConf['value'];
      switch (type) {
        case 'creditCard':
          validators.add(FormBuilderValidators.creditCard());
          break;
        case 'date':
          validators.add(FormBuilderValidators.dateString());
          break;
        case 'email':
          validators.add(FormBuilderValidators.email());
          break;
        case 'equal':
          validators.add(FormBuilderValidators.equal(value));
          break;
        case 'equalLength':
          validators.add(FormBuilderValidators.equalLength(value));
          break;
        case 'integer':
          validators.add(FormBuilderValidators.integer());
          break;
        case 'ip':
          validators.add(FormBuilderValidators.ip());
          break;
        case 'match':
          validators.add(FormBuilderValidators.match(value));
          break;
        case 'max':
          validators.add(FormBuilderValidators.max(value));
          break;
        case 'maxLength':
          validators.add(FormBuilderValidators.maxLength(value));
          break;
        case 'min':
          validators.add(FormBuilderValidators.min(value));
          break;
        case 'minLength':
          validators.add(FormBuilderValidators.minLength(value));
          break;
        case 'required':
          validators.add(FormBuilderValidators.required());
          break;
        case 'numeric':
          validators.add(FormBuilderValidators.numeric());
          break;
        case 'url':
          validators.add(FormBuilderValidators.url());
          break;
        default:
          throw Exception('Type of validator unkown:  ${type}');
      }
    }

    if (customValidator != null) {
      validators.add(customValidator);
    }

    return FormBuilderValidators.compose<String?>(validators);
  }

  TimeOfDay _parseTime(String? fieldDescription) {
    if (fieldDescription == null || fieldDescription == 'now') {
      return TimeOfDay.now();
    }
    List<String> fields = fieldDescription.split(':');
    if (fields.length != 2) {
      throw Exception('Time format is incorrect, should be hh:mm');
    }
    int hour = int.parse(fields.elementAt(0));
    int minutes = int.parse(fields.elementAt(1));
    return TimeOfDay(hour: hour, minute: minutes);
  }

  DateTime _parseDate(String? fieldDescription) {
    if (fieldDescription == null || fieldDescription == 'now') {
      return DateTime.now();
    }
    List<String> fields = fieldDescription.split('-');
    if (fields.length != 3) {
      throw Exception('Time format is incorrect, should be yyyy-MM-dd');
    }
    int year = int.parse(fields.elementAt(0));
    int month = int.parse(fields.elementAt(1));
    int day = int.parse(fields.elementAt(2));
    return DateTime(year, month, day);
  }
}
