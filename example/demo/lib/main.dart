import 'package:flutter/material.dart';
import 'package:persistent_top_sheet/persistent_top_sheet.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late PersistentTopSheetController controller;

  @override
  void initState() {
    super.initState();
    controller = PersistentTopSheetController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey,
        appBar: AppBar(
          title: const Text('Persistent Top Sheet Example'),
          backgroundColor: Colors.blue,
        ),
        body: Stack(
          children: [
            LayoutBuilder(builder: (context, constraints) {
              // get the screen height
              return PersistentTopSheet(
                maxHeight: constraints.maxHeight - 48,
                minHeight: 50,
                controller: controller,
                childBuilder: (currentHeight) => SheetBody(currentHeight: currentHeight),
                handleBuilder: (currentHeight) => const DragHandle(),
                onStateChanged: (state) => debugPrint('isOpen: $state'),
              );
            }),
            Center(
              child: ElevatedButton(
                onPressed: controller.toggle, // you can also use open() or close()
                child: const Text('Toggle open/close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SheetBody extends StatelessWidget {
  const SheetBody({
    super.key,
    required this.currentHeight,
  });

  final double currentHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Align(
          alignment: Alignment.topCenter,
          child: Text('height: ${currentHeight.round()}'),
        ),
      ),
    );
  }
}

class DragHandle extends StatelessWidget {
  const DragHandle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        height: kMinInteractiveDimension,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                height: 4,
                width: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
