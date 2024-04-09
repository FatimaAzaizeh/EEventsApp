import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:testtapp/constants.dart';

class MyStepperPage extends StatefulWidget {
  @override
  _MyStepperPageState createState() => _MyStepperPageState();
}

class _MyStepperPageState extends State<MyStepperPage> {
  int activeStep = 0; // Variable to track the active step index
  PageController pageController = PageController(); // Controller for PageView

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Stepper Page'),
      ),
      body: Column(
        children: [
          // Stepper
          Container(
            padding: EdgeInsets.all(16),
            child: EasyStepper(
              activeStep: activeStep,
              lineStyle: LineStyle(lineLength: 50),
              stepShape: StepShape.rRectangle,
              stepBorderRadius: 15,
              borderThickness: 2,
              padding: EdgeInsets.all(10),
              stepRadius: 28,
              finishedStepBorderColor: kColor2,
              finishedStepTextColor: kColor2,
              finishedStepBackgroundColor: kColor2,
              activeStepIconColor: kColor2,
              showLoadingAnimation: false,
              steps: [
                EasyStep(
                  customStep: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Opacity(
                      opacity: activeStep >= 0 ? 1 : 0.3,
                      child: Image.asset('assets/images/logo.png'),
                    ),
                  ),
                  customTitle: const Text(
                    'Dash 1',
                    textAlign: TextAlign.center,
                  ),
                ),
                EasyStep(
                  customStep: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Opacity(
                      opacity: activeStep >= 1 ? 1 : 0.3,
                      child: Image.asset('assets/images/logo.png'),
                    ),
                  ),
                  customTitle: const Text(
                    'Dash 2',
                    textAlign: TextAlign.center,
                  ),
                ),
                EasyStep(
                  customStep: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Opacity(
                      opacity: activeStep >= 2 ? 1 : 0.3,
                      child: Image.asset('assets/images/logo.png'),
                    ),
                  ),
                  customTitle: const Text(
                    'Dash 3',
                    textAlign: TextAlign.center,
                  ),
                ),
                EasyStep(
                  customStep: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Opacity(
                      opacity: activeStep >= 3 ? 1 : 0.3,
                      child: Image.asset('assets/images/logo.png'),
                    ),
                  ),
                  customTitle: const Text(
                    'Dash 4',
                    textAlign: TextAlign.center,
                  ),
                ),
                EasyStep(
                  customStep: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Opacity(
                      opacity: activeStep >= 4 ? 1 : 0.3,
                      child: Image.asset('assets/images/logo.png'),
                    ),
                  ),
                  customTitle: const Text(
                    'Dash 5',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              // Callback function when a step is reached
              onStepReached: (index) {
                setState(() {
                  activeStep = index;
                });
                // Scroll to the corresponding page in PageView
                pageController.animateToPage(
                  index,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
            ),
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  activeStep = index;
                });
              },
              children: [
                // Define your content pages here
                Container(
                  color: Colors.blue,
                  child: Center(
                    child: Text('Page 1'),
                  ),
                ),
                Container(
                  color: Colors.green,
                  child: Center(
                    child: Text('Page 2'),
                  ),
                ),
                Container(
                  color: Colors.orange,
                  child: Center(
                    child: Text('Page 3'),
                  ),
                ),
                Container(
                  color: Colors.purple,
                  child: Center(
                    child: Text('Page 4'),
                  ),
                ),
                Container(
                  color: Colors.red,
                  child: Center(
                    child: Text('Page 5'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
