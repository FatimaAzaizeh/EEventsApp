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
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.8,
          width: double.maxFinite,
          child: WizardSteps(
            activeStep: activeStep,
            imagePaths: imagePaths,
            titles: titles,
            pages: pages,
            onStepTapped: onStepTapped,
          ),
        ),
      ],
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
    return Expanded(
      child: SingleChildScrollView(
        child: EasyStepper(
          activeStepTextColor: Colors.black87,
          internalPadding: 0,
          showStepBorder: false,
          activeStep: activeStep,
          stepShape: StepShape.rRectangle,
          stepBorderRadius: 15,
          borderThickness: 2,
          stepRadius: 28,
          finishedStepBorderColor: Colors.deepOrange,
          finishedStepTextColor: Colors.deepOrange,
          finishedStepBackgroundColor: Colors.deepOrange,
          activeStepIconColor: Colors.deepOrange,
          showLoadingAnimation: false,
          steps: List.generate(widget.imagePaths.length, (index) {
            return EasyStep(
              customStep: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Opacity(
                  opacity: activeStep >= index ? 1 : 0.3,
                  child: Image.network(widget.imagePaths[index]),
                ),
              ),
              customTitle: Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(widget.titles[index]),
                          // إظهار الصفحة المرتبطة بالخطوة النشطة فقط
                          if (activeStep == index)
                            Container(
                              width: double.maxFinite,
                              height: double.maxFinite,
                              child: DisplayService(
                                idService: widget.pages[index],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
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
    );
  }
}
 // Display the page associated with the active step
      