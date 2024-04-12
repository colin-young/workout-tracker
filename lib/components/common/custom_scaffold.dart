import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/common/timer_widget.dart';
import 'package:workout_tracker/components/common/ui/workout_run_menu.dart';
import 'package:workout_tracker/controller/timer_controller.dart';
import 'package:workout_tracker/timer/timer_context.dart';
import 'package:workout_tracker/timer/timer_event.dart';
import 'package:workout_tracker/utility/separated_list.dart';

class CustomScaffold extends Scaffold {
  CustomScaffold(
      {super.key,
      super.appBar,
      super.backgroundColor,
      super.body,
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
                  AsyncData(:final value) => TimerWidget(
                      isVisible: value.state != Initiated(),
                    ),
                  _ => const SizedBox(width: 0, height: 0)
                };
              },
            ),
            bottomNavigationBar: BottomAppBar(
              elevation: 2.5,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const WorkoutRunMenu(),
                      Consumer(
                        builder: (BuildContext context, WidgetRef ref,
                            Widget? child) {
                          return ActionChip(
                            label: const Text('Timer'),
                            onPressed: () {
                              ref
                                  .read(getAllowedEventsProvider.future)
                                  .then((value) {
                                if (value.any((element) =>
                                    element.name == Running().name)) {
                                  ref
                                      .read(timerControllerProvider.notifier)
                                      .handleEvent(Reset());
                                } else {
                                  ref
                                      .read(timerControllerProvider.notifier)
                                      .handleEvent(Start());
                                }
                              });
                            },
                          );
                        },
                      ),
                    ].separatedList(const SizedBox(width: 8)),
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation: floatingActionButtonLocation ??
                FloatingActionButtonLocation.endDocked);
}
