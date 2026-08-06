import 'package:flutter/foundation.dart';

/// Controls navigation and state for [SuperStepper].
class SuperStepperController extends ChangeNotifier {
  /// Creates a controller.
  SuperStepperController({int initialStep = 0}) : _currentStep = initialStep;

  int _currentStep;
  final Set<int> _completedSteps = <int>{};
  final Set<int> _errorSteps = <int>{};
  final Set<int> _disabledSteps = <int>{};
  final Set<int> _loadingSteps = <int>{};

  /// Current selected step.
  int get currentStep => _currentStep;

  /// Completed steps.
  Set<int> get completedSteps => Set<int>.unmodifiable(_completedSteps);

  /// Error steps.
  Set<int> get errorSteps => Set<int>.unmodifiable(_errorSteps);

  /// Disabled steps.
  Set<int> get disabledSteps => Set<int>.unmodifiable(_disabledSteps);

  /// Loading steps.
  Set<int> get loadingSteps => Set<int>.unmodifiable(_loadingSteps);

  /// Whether [index] is completed.
  bool isCompleted(int index) => _completedSteps.contains(index);

  /// Whether [index] has an error.
  bool hasError(int index) => _errorSteps.contains(index);

  /// Whether [index] is disabled.
  bool isDisabled(int index) => _disabledSteps.contains(index);

  /// Whether [index] is loading.
  bool isLoading(int index) => _loadingSteps.contains(index);

  /// Selects [index].
  void jumpTo(int index) {
    if (index < 0 || isDisabled(index)) return;
    _currentStep = index;
    notifyListeners();
  }

  /// Advances to the next available step.
  void next({required int totalSteps, bool completeCurrent = true}) {
    if (totalSteps <= 0) return;
    if (completeCurrent) complete(_currentStep, notify: false);

    var target = _currentStep + 1;
    while (target < totalSteps && isDisabled(target)) {
      target++;
    }
    if (target < totalSteps) _currentStep = target;
    notifyListeners();
  }

  /// Returns to the previous available step.
  void previous() {
    var target = _currentStep - 1;
    while (target >= 0 && isDisabled(target)) {
      target--;
    }
    if (target >= 0) {
      uncompleteFrom(target, notify: false);
      _currentStep = target;
      notifyListeners();
    }
  }

  /// Marks [index] completed.
  void complete(int index, {bool notify = true}) {
    _errorSteps.remove(index);
    _loadingSteps.remove(index);
    _completedSteps.add(index);
    if (notify) notifyListeners();
  }

  /// Removes completed state from [index].
  void uncomplete(int index) {
    _completedSteps.remove(index);
    notifyListeners();
  }

  /// Removes completion from [index] and every following step.
  void uncompleteFrom(int index, {bool notify = true}) {
    _completedSteps.removeWhere((step) => step >= index);
    if (notify) notifyListeners();
  }

  /// Marks [index] as an error.
  void setError(int index) {
    _completedSteps.remove(index);
    _loadingSteps.remove(index);
    _errorSteps.add(index);
    notifyListeners();
  }

  /// Clears error state from [index].
  void clearError(int index) {
    _errorSteps.remove(index);
    notifyListeners();
  }

  /// Marks [index] as loading or not loading.
  void setLoading(int index, {bool value = true}) {
    if (value) {
      _loadingSteps.add(index);
    } else {
      _loadingSteps.remove(index);
    }
    notifyListeners();
  }

  /// Disables [index].
  void disable(int index) {
    _disabledSteps.add(index);
    notifyListeners();
  }

  /// Enables [index].
  void enable(int index) {
    _disabledSteps.remove(index);
    notifyListeners();
  }

  /// Resets all state.
  void reset({int initialStep = 0}) {
    _currentStep = initialStep;
    _completedSteps.clear();
    _errorSteps.clear();
    _disabledSteps.clear();
    _loadingSteps.clear();
    notifyListeners();
  }
}
