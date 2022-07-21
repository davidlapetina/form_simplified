library form_simplified;

import 'dart:convert';

import 'package:form_simplified/form_builder_configuration.dart';
import 'package:form_simplified/src/widget_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// Main class for our Form Builder
class FormSimplified {

  /// This constant must be used when creating the app:
  /// MaterialApp(
  /// ...
  /// localizationsDelegates: [FormSimplified.delegate],
  /// ...
  static const AppLocalizationDelegate delegate = FormBuilderLocalizations.delegate;

  String basePath;

  FormSimplified._({required this.basePath});

  ///In basePath folder we expect files to be such as
  /// assets/{basePath}/form1Key.form.json
  /// Hence the extension must be .form.json
  static FormSimplified build(String basePath) {
    return FormSimplified._(basePath: basePath);
  }

  Future<String> _parseFile(String descriptionFileName) {
    return rootBundle.loadString(_getFullPath(descriptionFileName),
        cache: true);
  }

  String _getFullPath(String descriptionFileName) =>
      basePath + descriptionFileName + ".form.json";

  dynamic _loadJson(String descriptionFileName) async {
    return json.decode(await _parseFile(descriptionFileName));
  }

  /// Return the Content of the form produced based on the Json descriptor file
  Future<WidgetBuilderResult> getFormContent(
      FormBuilderConfiguration configuration, BuildContext buildContext) async {
    var loadJson = await _loadJson(configuration.descriptionFileName);
    if (loadJson == null) {
      throw Exception('Unable to load file ' +
          _getFullPath(configuration.descriptionFileName));
    }
    print(loadJson);
    FormWidgetBuilder impl =
    FormWidgetBuilder(configuration: configuration, formData: loadJson);
    return impl.getFormContent(buildContext);
  }

  Widget getForm(FormBuilderConfiguration configuration,
      Widget fieldsContainer) {
    return FormBuilder(
        key: configuration.formKey,
        autovalidateMode: configuration.autovalidateMode,
        child: fieldsContainer);
  }

  /// For an easy integration, provide a default Widget that will display the form with a default layout.
  /// This default layout consist of a Column with one Widget per row and the buttons (if any) as a last row in the Column
  Widget getFormWithDefaultLayout(FormBuilderConfiguration configuration) {
    return _FormWithDefaultLayout(configuration: configuration, easyForm: this);
  }
}

/// Container for the resulting generated widgets
class WidgetBuilderResult {
  final Map<String, Widget> _fields;
  final Widget? _submit;
  final Widget? _cancel;

  WidgetBuilderResult(
      {required Map<String, Widget> fields, Widget? submit, Widget? cancel})
      : _fields = fields,
        _submit = submit,
        _cancel = cancel;

  /// Returns the cancel button if any
  Widget? get cancel => _cancel;

  /// Returns the submit button if any
  Widget? get submit => _submit;

  /// Returns the map with all the widget by their id.
  /// The ids allow you to retrieve each widget easily in order to let you do the layout you desire
  Map<String, Widget> get fields => _fields;

  /// Easy accessor to the list of widgets
  List<Widget> get widgets => _fields.values.toList();
}

class _FormWithDefaultLayout extends StatefulWidget {
  final FormBuilderConfiguration configuration;
  final FormSimplified easyForm;

  _FormWithDefaultLayout({required this.configuration, required this.easyForm});

  @override
  State<StatefulWidget> createState() => _FormWithDefaultLayoutState();
}

class _FormWithDefaultLayoutState extends State<_FormWithDefaultLayout> {
  @override
  Widget build(BuildContext context) {
    return
      SizedBox( width: MediaQuery.of(context).size.width/2, child:
      FutureBuilder<WidgetBuilderResult>(
        future: widget.easyForm.getFormContent(widget.configuration, context),
        builder:
            (BuildContext context, AsyncSnapshot<WidgetBuilderResult> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: Container(
                  width: 50,
                  height: 50,
                  child: const CircularProgressIndicator(),
                ),
              );
            default:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                List<Widget> children = [];
                children.addAll(snapshot.data!.fields.values);
                children.add(Row(
                  children: <Widget>[
                    Expanded(
                        child: snapshot.data!.submit!),
                    const SizedBox(width: 20),
                    Expanded(
                      child: snapshot.data!.cancel!,
                    ),
                  ],
                ));
                return FormBuilder(
                    key: widget.configuration.formKey,
                    autovalidateMode: widget.configuration.autovalidateMode,
                    child:
                    Column(children: children));
              }
          }
        },
      ));
  }
}