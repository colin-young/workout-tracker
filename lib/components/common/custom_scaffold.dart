import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/common/timer_widget.dart';
import 'package:workout_tracker/controller/timer_controller.dart';
import 'package:workout_tracker/timer/timer_context.dart';

class CustomScaffold extends Scaffold {
  CustomScaffold(
      {super.key,
      super.appBar,
      super.backgroundColor,
      super.body,
      super.bottomNavigationBar,
      super.drawer,
      super.drawerDragStartBehavior,
      super.drawerEdgeDragWidth,
      super.drawerEnableOpenDragGesture,
      super.drawerScrimColor,
      super.endDrawer,
      super.endDrawerEnableOpenDragGesture,
      super.extendBody,
      super.extendBodyBehindAppBar,
      super.floatingActionButton,
      super.floatingActionButtonAnimator,
      FloatingActionButtonLocation? floatingActionButtonLocation,
      super.onDrawerChanged,
      super.onEndDrawerChanged,
      super.persistentFooterAlignment,
      super.persistentFooterButtons,
      super.primary,
      super.resizeToAvoidBottomInset,
      super.restorationId})
      : super(
            bottomSheet: Consumer(
              builder: (context, ref, child) {
                final timerResult = ref.watch(getTimerProvider);

                return switch (timerResult) {
                  AsyncValue(:final value?) => TimerWidget(
                      isVisible: value.state != Initiated(),
                    ),
                  _ => const SizedBox(width: 0, height: 0)
                };
              },
            ),
            floatingActionButtonLocation: floatingActionButtonLocation ??
                FloatingActionButtonLocation.endFloat);
}
