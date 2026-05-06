/// Temporary widget gallery for the TM-358 redesign foundational widgets.
/// Not wired into the navigation graph by default. To preview on an emulator:
///
///   1. Open `lib/riverpod_app.dart`.
///   2. Replace the `home: _buildHome(authState)` line with:
///        home: const Tm358WidgetGallery(),
///   3. `flutter run` and inspect the screen.
///   4. Revert before committing.
///
/// This file will be deleted in the final TM-358 PR.
library;

import 'package:flutter/material.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/field_label.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/length_bucket_picker.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/pill.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/points_picker.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/segmented_bar.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/tm_bottom_action_bar.dart';
import 'package:taskmaestro/models/task_colors.dart';

class Tm358WidgetGallery extends StatefulWidget {
  const Tm358WidgetGallery({super.key});

  @override
  State<Tm358WidgetGallery> createState() => _Tm358WidgetGalleryState();
}

class _Tm358WidgetGalleryState extends State<Tm358WidgetGallery> {
  int? _priority = 3;
  int? _points = 5;
  int? _length = 60;
  int? _recurUnit = 2; // Weeks
  int? _recurAnchor = 1; // Completed Date

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaskColors.cardColor,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 110),
            children: [
              const Text(
                'TM-358 widget gallery',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              FieldLabel('Priority', hint: '${_priority ?? 0}/5'),
              SegmentedBar(
                value: _priority,
                segments: 5,
                accent: SegmentedBarAccent.priority,
                onChanged: (v) => setState(() => _priority = v),
              ),
              const SizedBox(height: 20),

              FieldLabel('Points', hint: _points == null ? 'unset' : '$_points pts'),
              PointsPicker(
                value: _points,
                onChanged: (v) => setState(() => _points = v),
              ),
              const SizedBox(height: 20),

              FieldLabel('Length', hint: _length == null ? 'unset' : '$_length min'),
              LengthBucketPicker(
                minutes: _length,
                onChanged: (m) => setState(() => _length = m),
              ),
              const SizedBox(height: 20),

              const FieldLabel('Recurrence Unit'),
              SegmentedBar(
                value: _recurUnit,
                segments: 4,
                labels: const ['Days', 'Weeks', 'Months', 'Years'],
                onChanged: (v) => setState(() => _recurUnit = v),
              ),
              const SizedBox(height: 20),

              const FieldLabel('Recurrence Anchor'),
              SegmentedBar(
                value: _recurAnchor,
                segments: 2,
                labels: const ['Completed Date', 'Schedule Date'],
                onChanged: (v) => setState(() => _recurAnchor = v),
              ),
              const SizedBox(height: 32),

              const FieldLabel('Pills'),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  Pill(
                    label: const Text('Computer'),
                    color: TaskColors.areaPalette[2],
                    onRemove: () {},
                  ),
                  Pill(
                    label: const Text('Phone'),
                    onRemove: () {},
                  ),
                  Pill(
                    label: const Text('Tappable'),
                    onTap: () {},
                  ),
                  AddPill(label: 'Add', onTap: () {}),
                ],
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: TmBottomActionBar(
              saveLabel: 'Save changes',
              cancelLabel: 'Cancel',
              onSave: () {},
              onCancel: () {},
            ),
          ),
        ],
      ),
    );
  }
}
