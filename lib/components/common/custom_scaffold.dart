import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/common/timer_widget.dart';

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
      super.floatingActionButtonLocation,
      super.onDrawerChanged,
      super.onEndDrawerChanged,
      super.persistentFooterAlignment,
      super.persistentFooterButtons,
      super.primary,
      super.resizeToAvoidBottomInset,
      super.restorationId}) : super(bottomSheet: Consumer(        
        builder: (context, ref, child) => const TimerWidget(),
      ));
}
