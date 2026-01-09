# User Interaction Testing

This guide explains how to simulate and test user interactions (taps, drags, text input, etc.).

## Overview

In Flutter widget testing, you simulate real user actions to verify app responsiveness and functionality. You can reproduce user gestures using various methods from `WidgetTester`.

## Core Interaction Methods

### enterText() - Text Input

Enters text into text fields.

```dart
await tester.enterText(find.byType(TextField), 'Hello World');
```

### tap() - Tap Gesture

Taps on widgets.

```dart
await tester.tap(find.byType(ElevatedButton));
```

### drag() - Drag Gesture

Drags or swipes widgets.

```dart
await tester.drag(find.byType(Dismissible), const Offset(500.0, 0.0));
```

## Basic Interaction Tests

### 1. Button Tap Test

```dart
testWidgets('Button tap test', (WidgetTester tester) async {
  bool buttonPressed = false;

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: ElevatedButton(
        onPressed: () {
          buttonPressed = true;
        },
        child: Text('Tap Me'),
      ),
    ),
  ));

  // Verify button exists
  expect(find.text('Tap Me'), findsOneWidget);

  // Tap the button
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();

  // Verify button was pressed
  expect(buttonPressed, isTrue);
});
```

### 2. Text Input Test

```dart
testWidgets('Text input test', (WidgetTester tester) async {
  final textController = TextEditingController();

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: TextField(
        controller: textController,
        decoration: InputDecoration(hintText: 'Enter text'),
      ),
    ),
  ));

  // Find text field
  final textField = find.byType(TextField);
  expect(textField, findsOneWidget);

  // Enter text
  await tester.enterText(textField, 'Hello Flutter');
  await tester.pump();

  // Verify entered text
  expect(textController.text, equals('Hello Flutter'));
  expect(find.text('Hello Flutter'), findsOneWidget);
});
```

### 3. Swipe/Drag Test

```dart
testWidgets('Swipe to dismiss test', (WidgetTester tester) async {
  bool itemDismissed = false;

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Dismissible(
        key: const Key('dismissible_item'),
        onDismissed: (direction) {
          itemDismissed = true;
        },
        child: ListTile(
          title: Text('Swipe to dismiss'),
        ),
      ),
    ),
  ));

  // Verify item exists
  expect(find.text('Swipe to dismiss'), findsOneWidget);

  // Swipe left
  await tester.drag(
    find.byKey(const Key('dismissible_item')),
    const Offset(-500.0, 0.0),
  );
  await tester.pumpAndSettle();

  // Verify item was dismissed
  expect(itemDismissed, isTrue);
  expect(find.text('Swipe to dismiss'), findsNothing);
});
```

## Complex Interaction Tests

### Todo App Scenario

```dart
testWidgets('Todo app interaction test', (WidgetTester tester) async {
  final todos = <String>[];
  final textController = TextEditingController();

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Todo App')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: 'Enter todo item',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (textController.text.isNotEmpty) {
                      todos.add(textController.text);
                      textController.clear();
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key('todo_$index'),
                  onDismissed: (direction) {
                    todos.removeAt(index);
                  },
                  child: ListTile(
                    title: Text(todos[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  ));

  // 1. Enter text
  await tester.enterText(find.byType(TextField), 'Buy groceries');
  await tester.pump();

  // 2. Tap add button
  await tester.tap(find.text('Add'));
  await tester.pump();

  // 3. Verify item was added
  expect(find.text('Buy groceries'), findsOneWidget);
  expect(todos.length, equals(1));

  // 4. Add second item
  await tester.enterText(find.byType(TextField), 'Walk the dog');
  await tester.pump();
  await tester.tap(find.text('Add'));
  await tester.pump();

  expect(find.text('Walk the dog'), findsOneWidget);
  expect(todos.length, equals(2));

  // 5. Swipe first item to delete
  await tester.drag(
    find.byKey(const Key('todo_0')),
    const Offset(500.0, 0.0),
  );
  await tester.pumpAndSettle();

  // 6. Verify deletion
  expect(find.text('Buy groceries'), findsNothing);
  expect(todos.length, equals(1));
  expect(todos.first, equals('Walk the dog'));
});
```

## Advanced Interaction Tests

### 1. Long Press

```dart
testWidgets('Long press test', (WidgetTester tester) async {
  bool longPressed = false;

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: GestureDetector(
        onLongPress: () {
          longPressed = true;
        },
        child: Container(
          width: 100,
          height: 100,
          color: Colors.blue,
          child: Text('Long Press Me'),
        ),
      ),
    ),
  ));

  // Long press
  await tester.longPress(find.text('Long Press Me'));
  await tester.pump();

  expect(longPressed, isTrue);
});
```

### 2. Double Tap

```dart
testWidgets('Double tap test', (WidgetTester tester) async {
  int tapCount = 0;

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: GestureDetector(
        onTap: () => tapCount++,
        child: Container(
          width: 100,
          height: 100,
          child: Text('Double Tap Me'),
        ),
      ),
    ),
  ));

  final finder = find.text('Double Tap Me');

  // Simulate double tap
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(finder);
  await tester.pump();

  expect(tapCount, equals(2));
});
```

### 3. Multi-touch Gestures

```dart
testWidgets('Pinch zoom test', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: InteractiveViewer(
        child: Container(
          width: 200,
          height: 200,
          color: Colors.red,
          child: Text('Pinch to zoom'),
        ),
      ),
    ),
  ));

  // Simulate pinch zoom gesture
  final center = tester.getCenter(find.byType(InteractiveViewer));
  final gesture1 = await tester.startGesture(center + const Offset(-50, 0));
  final gesture2 = await tester.startGesture(center + const Offset(50, 0));

  // Zoom gesture
  await gesture1.moveTo(center + const Offset(-100, 0));
  await gesture2.moveTo(center + const Offset(100, 0));
  await tester.pump();

  await gesture1.up();
  await gesture2.up();
  await tester.pumpAndSettle();

  // Verify zoom state (depends on actual implementation)
});
```

## Form Interaction Tests

### Complete Form Test

```dart
testWidgets('Complete form interaction test', (WidgetTester tester) async {
  final formKey = GlobalKey<FormState>();
  String? name;
  String? email;
  bool formSubmitted = false;

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              key: const Key('name_field'),
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
              onSaved: (value) => name = value,
            ),
            TextFormField(
              key: const Key('email_field'),
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) => value?.contains('@') != true ? 'Invalid email' : null,
              onSaved: (value) => email = value,
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() == true) {
                  formKey.currentState?.save();
                  formSubmitted = true;
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    ),
  ));

  // 1. Enter name
  await tester.enterText(find.byKey(const Key('name_field')), 'John Doe');
  await tester.pump();

  // 2. Enter email
  await tester.enterText(find.byKey(const Key('email_field')), 'john@example.com');
  await tester.pump();

  // 3. Submit form
  await tester.tap(find.text('Submit'));
  await tester.pump();

  // 4. Verify form was submitted successfully
  expect(formSubmitted, isTrue);
  expect(name, equals('John Doe'));
  expect(email, equals('john@example.com'));

  // 5. Test validation
  formSubmitted = false;
  await tester.enterText(find.byKey(const Key('email_field')), 'invalid-email');
  await tester.pump();
  await tester.tap(find.text('Submit'));
  await tester.pump();

  expect(formSubmitted, isFalse);
  expect(find.text('Invalid email'), findsOneWidget);
});
```

## Animation and Interaction

### Waiting for Animation Completion

```dart
testWidgets('Animation interaction test', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Center(
        child: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
        ),
      ),
    ),
  ));

  // Tap FAB
  await tester.tap(find.byType(FloatingActionButton));

  // Wait for animation to complete
  await tester.pumpAndSettle();

  // Verify state after animation
  expect(find.byType(FloatingActionButton), findsOneWidget);
});
```

## Key Tips

1. **pump() vs pumpAndSettle()**: Use `pump()` after state changes, `pumpAndSettle()` after animations complete.
2. **Gesture sequence**: Write tests in the order of actual user actions.
3. **State verification**: Always verify expected state after each interaction.
4. **Use Keys**: Use Keys for precise targeting in complex widgets.
5. **Timing**: Consider appropriate wait times for animations or async operations.

## Real-world Use Case

```dart
testWidgets('Real world app interaction', (WidgetTester tester) async {
  // Complex interaction scenario from real app
  await tester.pumpWidget(MyComplexApp());

  // Start from login screen
  expect(find.text('Login'), findsOneWidget);

  // Enter login credentials
  await tester.enterText(find.byKey(const Key('username')), 'testuser');
  await tester.enterText(find.byKey(const Key('password')), 'password123');

  // Tap login button
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();

  // Verify navigation to main screen
  expect(find.text('Welcome'), findsOneWidget);

  // Open navigation drawer
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();

  // Tap settings menu
  await tester.tap(find.text('Settings'));
  await tester.pumpAndSettle();

  // Toggle switch in settings screen
  await tester.tap(find.byType(Switch));
  await tester.pump();

  // Save settings
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();

  // Verify save completion
  expect(find.text('Settings saved'), findsOneWidget);
});
```