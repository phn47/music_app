import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'button_state_notifier.g.dart';

@riverpod
class ButtonStateNotifier extends _$ButtonStateNotifier {
  // Trạng thái của nút bấm
  bool isPressed = false;

  @override
  bool build() {
    return isPressed;
  }

  void toggleButton() {
    isPressed = !isPressed;
    state = isPressed;
  }
}
