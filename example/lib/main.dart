import 'package:flutter/material.dart';
import 'package:super_stepper/super_stepper.dart';

void main() => runApp(const ExampleApp());

/// Example application showcasing the super stepper package.
class ExampleApp extends StatefulWidget {
  /// Creates the example application.
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode themeMode = ThemeMode.light;

  static const lightColors = ColorScheme.light(
    primary: Color(0xFF4F46E5),
    onPrimary: Colors.white,
    secondary: Color(0xFF7C3AED),
    tertiary: Color(0xFF0891B2),
    surface: Color(0xFFF8FAFC),
    error: Color(0xFFDC2626),
  );

  static const darkColors = ColorScheme.dark(
    primary: Color(0xFFA5B4FC),
    onPrimary: Color(0xFF1E1B4B),
    secondary: Color(0xFFC4B5FD),
    tertiary: Color(0xFF67E8F9),
    surface: Color(0xFF0F172A),
    error: Color(0xFFFCA5A5),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: lightColors,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: darkColors,
        useMaterial3: true,
      ),
      home: StepperExamplePage(
        darkMode: themeMode == ThemeMode.dark,
        onToggleTheme: () => setState(() {
          themeMode =
              themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
        }),
      ),
    );
  }
}

/// Demonstrates the available stepper states and customization options.
class StepperExamplePage extends StatefulWidget {
  /// Creates the stepper example page.
  const StepperExamplePage({
    super.key,
    required this.darkMode,
    required this.onToggleTheme,
  });

  /// Whether the dark theme is currently selected.
  final bool darkMode;

  /// Switches between the light and dark example themes.
  final VoidCallback onToggleTheme;

  @override
  State<StepperExamplePage> createState() => _StepperExamplePageState();
}

class _StepperExamplePageState extends State<StepperExamplePage> {
  final controller = SuperStepperController();
  int currentStep = 0;

  final steps = const <SuperStep<void>>[
    SuperStep(
      title: 'Account',
      subtitle: 'Personal details',
      icon: Icons.person_outline,
      content: _ExampleCard(
        title: 'Account information',
        text: 'Add the fields for name, email, and phone here.',
      ),
    ),
    SuperStep(
      title: 'Address',
      subtitle: 'Delivery location',
      icon: Icons.location_on_outlined,
      content: _ExampleCard(
        title: 'Address information',
        text: 'Add address and map controls here.',
      ),
    ),
    SuperStep(
      title: 'Payment',
      subtitle: 'Choose a method',
      icon: Icons.credit_card_outlined,
      content: _ExampleCard(
        title: 'Payment method',
        text: 'Add payment options here.',
      ),
    ),
    SuperStep(
      title: 'Finish',
      subtitle: 'Review and submit',
      icon: Icons.flag_outlined,
      content: _ExampleCard(
        title: 'Ready to submit',
        text: 'Review everything before completing the flow.',
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    currentStep = controller.currentStep;
    controller.addListener(_handleStepChanged);
  }

  void _handleStepChanged() {
    if (!mounted || currentStep == controller.currentStep) return;
    setState(() => currentStep = controller.currentStep);

    // Save step data, run validation, analytics, or another action here.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Changed to step ${currentStep + 1}')),
    );
  }

  Future<void> _finish() async {
    // Submit all saved step data or navigate to another page here.
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finished'),
        content: const Text('All steps are complete.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.removeListener(_handleStepChanged);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Stepper'),
        actions: [
          IconButton(
            tooltip: widget.darkMode ? 'Use light mode' : 'Use dark mode',
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.darkMode ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SuperStepper<void>(
              controller: controller,
              steps: steps,
              scrollable: true,
              keepAlive: true,
              style: const SuperStepperStyle(
                glassEffect: true,
                activeColor: Colors.indigoAccent,
                borderWidth: 0,
                stepSize: 60,
                inactiveColor: Colors.grey,
              ),
              connectorStyle: const SuperStepperConnectorStyle(
                type: SuperConnectorType.solid,
                length: 54,
              ),
              animation: const SuperStepperAnimation(
                type: SuperStepAnimationType.scaleAndFade,
              ),
              behavior: const SuperStepperBehavior(
                allowFutureStepTapping: true,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Current step: ${currentStep + 1} of ${steps.length}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: controller.previous,
                  label: const Text('Previous'),
                  icon: const Icon(Icons.arrow_back),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: currentStep == steps.length - 1
                      ? _finish
                      : () => controller.next(totalSteps: steps.length),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentStep == steps.length - 1 ? 'Finish' : 'Next',
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        currentStep == steps.length - 1
                            ? Icons.check
                            : Icons.arrow_forward,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: controller.reset,
              child: const Text('Reset'),
            ),
            const Divider(height: 48),
            const Text(
              'Fully custom indicators',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SuperStepper<void>(
              steps: steps.take(3).toList(),
              currentStep: 1,
              scrollable: true,
              showContent: false,
              connectorBuilder: (context, state) => Container(
                width: 46,
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.tertiary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              stepBuilder: (context, step, state) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: state.isActive ? 64 : 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: state.isActive
                      ? const LinearGradient(
                          colors: [Colors.indigo, Colors.purple],
                        )
                      : null,
                  color: state.isActive ? null : Colors.black12,
                ),
                child: Icon(
                  step.icon,
                  color: state.isActive ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(text),
          ],
        ),
      ),
    );
  }
}
