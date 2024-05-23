import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:testtapp/screens/Admin/widgets_admin/Service/DisplayService.dart';

class WizardStepsContainer extends StatelessWidget {
  final int activeStep;
  final List<String> imagePaths;
  final List<String> titles;
  final List<DocumentReference> pages;
  final ValueChanged<int> onStepTapped;

  WizardStepsContainer({
    required this.activeStep,
    required this.imagePaths,
    required this.titles,
    required this.pages,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: WizardSteps(
                        activeStep: activeStep,
                        imagePaths: imagePaths,
                        titles: titles,
                        pages: pages,
                        onStepTapped: onStepTapped,
                      ),
                    ),
                  );
                },
              );
            },
            child: Text('تحميل الشكل '),
          ),
        ],
      ),
    );
  }
}

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
    double squareSize = 420.0;

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
                        child: Image.network(widget.imagePaths[index]),
                      ),
                    ),
                    if (activeStep >= index)
                      Positioned.fill(
                        child: Icon(
                          Icons.check_circle,
                          color: Color.fromARGB(196, 196, 179,
                              225), // You can customize the color here
                          size: 36,
                        ),
                      ),
                  ],
                ),
                customTitle: Text(widget.titles[index]),
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
          padding: EdgeInsets.all(16.0),
          child: DisplayService(
            idService: widget.pages[activeStep],
          ),
        ),
      ],
    );
  }
}
