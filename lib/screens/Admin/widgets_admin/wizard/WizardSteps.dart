import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:testtapp/screens/Admin/widgets_admin/Service/DisplayService.dart';

class WizardSteps extends StatefulWidget {
  final int activeStep;
  final List<String> imagePaths;
  final List<String> titles;
  final List<DocumentReference> pages;
  final ValueChanged<int> onStepTapped;

  WizardSteps({
    Key? key,
    required this.activeStep,
    required this.imagePaths,
    required this.titles,
    required this.pages,
    required this.onStepTapped,
  }) : super(key: key);

  @override
  State<WizardSteps> createState() => _WizardStepsState();
}

class _WizardStepsState extends State<WizardSteps> {
  late int activeStep;

  @override
  void initState() {
    super.initState();
    activeStep = widget.activeStep;
  }

  @override
  Widget build(BuildContext context) {
    double squareSize = double.maxFinite;

    return Column(
      children: [
        // EasyStepper for navigation at the top
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: EasyStepper(
            activeStepTextColor: Colors.black87,
            internalPadding: 0,
            showStepBorder: false,
            activeStep: activeStep,
            stepShape: StepShape.rRectangle,
            stepBorderRadius: 15,
            borderThickness: 2,
            stepRadius: 28,
            finishedStepBorderColor: const Color.fromARGB(255, 248, 241, 239),
            finishedStepTextColor: Color.fromARGB(255, 209, 205, 203),
            finishedStepBackgroundColor:
                const Color.fromARGB(255, 244, 232, 228),
            showLoadingAnimation: false,
            steps: List.generate(widget.imagePaths.length, (index) {
              return EasyStep(
                customStep: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Opacity(
                          opacity: activeStep >= index ? 1 : 0.3,
                          child: Image.network(widget.imagePaths[index])),
                    ),
                  ],
                ),
              );
            }),
            onStepReached: (index) {
              setState(() {
                activeStep = index;
                widget.onStepTapped(index);
              });
            },
          ),
        ),
        // Central container to display the DisplayService in a small square shape
        Container(
          width: squareSize,
          height: squareSize,
          padding: EdgeInsets.all(20.0),
          child: DisplayService(
            idService: widget.pages[activeStep],
          ),
        ),
      ],
    );
  }
}
