# Example of form that can be generated
Note that the labels on the buttons are not translated due to the implementation of the 'Translate' method.

![image info](https://raw.githubusercontent.com/davidlapetina/form_simplified/main/example/example.png)

# Dart code
```dart

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Form',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: Colors.white,
            backgroundColor: Colors.blue
          ),
        ),
      ),
      home: const MyHomePage(title: 'Simple Form'),
      localizationsDelegates: [SimpleForm.delegate],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SimpleForm? simpleForm;

  @override
  void initState() {
    super.initState();
    easyForm = SimpleForm.build("assets/samples/");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: Text(widget.title),
      ),
      body: Center(
          child: simpleForm!.getFormWithDefaultLayout(FormBuilderConfiguration(
              onSubmit: (Map<String, dynamic> value) => {print('click')},
              onCancel: () => {print('click')},
              formKey: FormKey(),
              descriptionFileName: 'complete',
              translate: (buildContext, fieldId, labelOrKey) {
                return labelOrKey;
              }))),
    );
  }
}

```
# Json descriptor file
```json
{
  "submit": {
    "label": "form1.submit",
    "icon" : "asset://assets/icons/submit.png"
  },
  "cancel": {
    "label": "form1.cancel"
  },
  "fields": [
    {
      "type": "FilterChip",
      "id": "filter_chip",
      "label": "Select many options",
      "options": [
        {
          "value": "test",
          "label": "Test"
        },
        {
          "value": "test1",
          "label": "Test 1"
        },
        {
          "value": "test2",
          "label": "Test 2"
        }
      ]
    },
    {
      "type": "ChoiceChip",
      "id": "choice_chip",
      "label": "Select one option",
      "options": [
        {
          "value": "test",
          "label": "Test"
        },
        {
          "value": "test1",
          "label": "Test 1"
        },
        {
          "value": "test2",
          "label": "Test 2"
        }
      ]
    },
    {
      "type": "DateTimePicker",
      "id": "datePicker",
      "label": "Appointment Time",
      "inputType": "time|date|both",
      "initialTime": "08:08",
      "initialDate": "now"
    },
    {
      "type": "DateRangePicker",
      "id": "dateRangePicker",
      "label": "Appointment Time",
      "firstDate": "1970-01-19",
      "lastDate": "2030-01-19",
      "format": "yyyy-MM-dd",
      "onChanged": "_onChanged"
    },
    {
      "type": "Slider",
      "id": "slider",
      "label": "Number of things",
      "validators": [
        {
          "type": "min",
          "value": 6,
          "errorText": "This is not good!"
        },
        {
          "type": "max",
          "value": 16
        }
      ],
      "onChanged": "_onChanged",
      "min": 0.0,
      "max": 20.0,
      "initialValue": 7.0,
      "divisions": 20
    },
    {
      "type": "Checkbox",
      "id": "accept_terms",
      "label": "I have read and agree to the Agreement",
      "labelStyle": "MyClassWithStyles.constantStyle",
      "initialValue" : false,
      "validators": [
        {
          "type": "equal",
          "value": true,
          "errorText": "This is not good!"
        }
      ]
    },
    {
      "type": "Dropdown",
      "id": "dropdown",
      "label": "Select one option",
      "allowClear": true,
      "hint": "Select Gender",
      "options": [
        {
          "value": "test",
          "label": "Test"
        },
        {
          "value": "test1",
          "label": "Test 1"
        },
        {
          "value": "test2",
          "label": "Test 2"
        }
      ]
    },
    {
      "type": "TextField",
      "id": "age",
      "label": "How old are you?",
      "onChanged": "_onChanged",
      "inputType": "dateTime|emailAddress|number|phone|text",
      "validators": [
        {
          "type": "required"
        },
        {
          "type": "numeric"
        },
        {
          "type": "max",
          "value": 70
        }
      ]
    }
  ]
}
```
