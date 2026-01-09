# Scrollable Widget Testing

This guide explains how to test scrollable widgets.

## Overview

This covers methods for finding and testing specific items in long lists or scrollable widgets. You can use the `WidgetTester`'s `scrollUntilVisible()` method to find widgets that are not visible on screen.

## Core Method

### scrollUntilVisible()

Scrolls until a specific widget becomes visible on screen.

```dart
await tester.scrollUntilVisible(
  finder,           // Finder for the widget you want to find
  delta,           // Distance to scroll (in pixels)
  scrollable: scrollableFinder,  // Finder for scrollable widget (optional)
);
```

## Basic Usage Patterns

### 1. Finding Specific Item in Long List

```dart
testWidgets('Find item in long list', (WidgetTester tester) async {
  // Create long list with 10,000 items
  final items = List<String>.generate(10000, (i) => 'Item $i');

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            key: ValueKey('item_${index}_text'),
            title: Text(items[index]),
          );
        },
      ),
    ),
  ));

  // Find scrollable widget
  final listFinder = find.byType(Scrollable);

  // Find specific item (50th item)
  final itemFinder = find.byKey(const ValueKey('item_50_text'));

  // Scroll until item is visible
  await tester.scrollUntilVisible(
    itemFinder,
    500.0,  // Scroll 500 pixels at a time
    scrollable: listFinder,
  );

  // Verify item is visible on screen
  expect(itemFinder, findsOneWidget);
});
```

### 2. Vertical Scrolling

```dart
testWidgets('Vertical scrolling test', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: ListView(
        children: List.generate(100, (index) =>
          Container(
            key: ValueKey('container_$index'),
            height: 100,
            child: Center(child: Text('Item $index')),
          ),
        ),
      ),
    ),
  ));

  // Scroll to last item
  final lastItem = find.byKey(const ValueKey('container_99'));
  await tester.scrollUntilVisible(lastItem, 500.0);

  expect(lastItem, findsOneWidget);
  expect(find.text('Item 99'), findsOneWidget);
});
```

### 3. Horizontal Scrolling

```dart
testWidgets('Horizontal scrolling test', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: ListView(
        scrollDirection: Axis.horizontal,
        children: List.generate(50, (index) =>
          Container(
            key: ValueKey('horizontal_item_$index'),
            width: 200,
            child: Center(child: Text('Item $index')),
          ),
        ),
      ),
    ),
  ));

  // Scroll to rightmost item
  final rightItem = find.byKey(const ValueKey('horizontal_item_49'));
  await tester.scrollUntilVisible(rightItem, 200.0);

  expect(rightItem, findsOneWidget);
});
```

## Advanced Scroll Testing

### CustomScrollView Testing

```dart
testWidgets('CustomScrollView with slivers', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('Scrollable App Bar'),
            expandedHeight: 200,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                key: ValueKey('sliver_item_$index'),
                title: Text('Sliver Item $index'),
              ),
              childCount: 100,
            ),
          ),
        ],
      ),
    ),
  ));

  // Find specific item in SliverList
  final sliverItem = find.byKey(const ValueKey('sliver_item_80'));
  await tester.scrollUntilVisible(sliverItem, 500.0);

  expect(sliverItem, findsOneWidget);
});
```

### Nested Scroll Views Testing

```dart
testWidgets('Nested scroll views', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: ListView(
        children: [
          Container(height: 200, child: Text('Header')),
          Container(
            height: 300,
            child: ListView(
              children: List.generate(20, (index) =>
                ListTile(
                  key: ValueKey('nested_item_$index'),
                  title: Text('Nested Item $index'),
                ),
              ),
            ),
          ),
          Container(height: 200, child: Text('Footer')),
        ],
      ),
    ),
  ));

  // Find specific item in nested ListView
  final nestedItem = find.byKey(const ValueKey('nested_item_15'));

  // Specify outer scrollable
  final outerScrollable = find.byType(Scrollable).first;
  await tester.scrollUntilVisible(nestedItem, 100.0, scrollable: outerScrollable);

  expect(nestedItem, findsOneWidget);
});
```

## Scroll Gesture Testing

### Manual Scroll Gestures

```dart
testWidgets('Manual scroll gestures', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: ListView(
        children: List.generate(50, (index) =>
          Container(
            key: ValueKey('manual_item_$index'),
            height: 100,
            child: Text('Manual Item $index'),
          ),
        ),
      ),
    ),
  ));

  // Manually scroll down
  await tester.drag(find.byType(ListView), const Offset(0, -300));
  await tester.pumpAndSettle();

  // Check if specific item is visible
  expect(find.text('Manual Item 3'), findsOneWidget);
});
```

### Checking Scroll Position

```dart
testWidgets('Check scroll position', (WidgetTester tester) async {
  final scrollController = ScrollController();

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: ListView(
        controller: scrollController,
        children: List.generate(100, (index) =>
          Container(height: 100, child: Text('Item $index')),
        ),
      ),
    ),
  ));

  // Scroll to specific position
  scrollController.jumpTo(500.0);
  await tester.pump();

  // Check scroll position
  expect(scrollController.offset, equals(500.0));
});
```

## Key Tips

1. **Use Keys**: Always assign unique Keys to items in scrollable widgets.
2. **Appropriate delta value**: Adjust the delta value in `scrollUntilVisible()` according to item size.
3. **Use pumpAndSettle**: Use `pumpAndSettle()` to wait for scroll animations to complete.
4. **Performance consideration**: For very long lists, use `ListView.builder` for performance optimization.
5. **Scroll direction**: For horizontal scrolling, explicitly specify `scrollDirection: Axis.horizontal`.

## Real-world Use Case

```dart
testWidgets('Complete scrolling scenario', (WidgetTester tester) async {
  // Long list scenario similar to real apps
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Long List')),
      body: ListView.builder(
        itemCount: 1000,
        itemBuilder: (context, index) {
          return Card(
            key: ValueKey('card_$index'),
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text('User $index'),
              subtitle: Text('Email: user$index@example.com'),
              trailing: IconButton(
                key: ValueKey('delete_$index'),
                icon: Icon(Icons.delete),
                onPressed: () {},
              ),
            ),
          );
        },
      ),
    ),
  ));

  // Find user at middle point
  final targetUser = find.byKey(const ValueKey('card_500'));
  await tester.scrollUntilVisible(targetUser, 500.0);
  expect(targetUser, findsOneWidget);

  // Test delete button for that user
  final deleteButton = find.byKey(const ValueKey('delete_500'));
  expect(deleteButton, findsOneWidget);

  await tester.tap(deleteButton);
  await tester.pump();

  // Check state after deletion (deletion logic should be implemented in real app)
});
```