import 'package:flutter/material.dart';

double getHeading1Size(BuildContext context) {
  bool isLandscape =
      MediaQuery.of(context).orientation == Orientation.landscape;

  return MediaQuery.of(context).size.width *
      (isLandscape ? 0.03 : 0.08); // 8% of screen width
}

double getHeading2Size(BuildContext context) {
  bool isLandscape =
      MediaQuery.of(context).orientation == Orientation.landscape;

  return MediaQuery.of(context).size.width *
      (isLandscape ? 0.02 : 0.06); // 6% of screen width
}

double getHeading3Size(BuildContext context) {
  return MediaQuery.of(context).size.width * 0.05; // 5% of screen width
}

double getSubheadingSize(BuildContext context) {
  return MediaQuery.of(context).size.width * 0.04; // 4% of screen width
}

double getBodyTextSize(BuildContext context) {
  bool isLandscape =
      MediaQuery.of(context).orientation == Orientation.landscape;

  return MediaQuery.of(context).size.width * (isLandscape ? 0.03 : 0.035);
}

double getCaptionSize(BuildContext context) {
  bool isLandscape =
      MediaQuery.of(context).orientation == Orientation.landscape;

  return MediaQuery.of(context).size.width *
      (isLandscape ? 0.015 : 0.025); // 2.5% of screen width
}

double getSmallTextSize(BuildContext context) {
  return MediaQuery.of(context).size.width * 0.02; // 2% of screen width
}

// double getHeading1Size(BuildContext context, String orientation) {
//   final mediaQuery = MediaQuery.of(context);

//   if (orientation.toLowerCase() == 'vertical') {
//     return mediaQuery.size.width * 0.08; // 8% of screen width
//   }
//   if (orientation.toLowerCase() == 'horizontal') {
//     return mediaQuery.size.height * 0.08; // 8% of screen height
//   }

//   return 0.0;
// }

// double getHeading2Size(BuildContext context, String orientation) {
//   final mediaQuery = MediaQuery.of(context);

//   if (orientation.toLowerCase() == 'vertical') {
//     return mediaQuery.size.width * 0.06; // 6% of screen width
//   }
//   if (orientation.toLowerCase() == 'horizontal') {
//     return mediaQuery.size.height * 0.06; // 6% of screen height
//   }

//   return 0.0;
// }

// double getHeading3Size(BuildContext context, String orientation) {
//   final mediaQuery = MediaQuery.of(context);

//   if (orientation.toLowerCase() == 'vertical') {
//     return mediaQuery.size.width * 0.05; // 5% of screen width
//   }
//   if (orientation.toLowerCase() == 'horizontal') {
//     return mediaQuery.size.height * 0.05; // 5% of screen height
//   }

//   return 0.0;
// }

// double getSubheadingSize(BuildContext context, String orientation) {
//   final mediaQuery = MediaQuery.of(context);

//   if (orientation.toLowerCase() == 'vertical') {
//     return mediaQuery.size.width * 0.04; // 4% of screen width
//   }
//   if (orientation.toLowerCase() == 'horizontal') {
//     return mediaQuery.size.height * 0.04; // 4% of screen height
//   }

//   return 0.0;
// }

// double getBodyTextSize(BuildContext context, String orientation) {
//   final mediaQuery = MediaQuery.of(context);

//   if (orientation.toLowerCase() == 'vertical') {
//     return mediaQuery.size.width * 0.035; // 3.5% of screen width
//   }
//   if (orientation.toLowerCase() == 'horizontal') {
//     return mediaQuery.size.height * 0.035; // 3.5% of screen height
//   }

//   return 0.0;
// }

// double getCaptionSize(BuildContext context, String orientation) {
//   final mediaQuery = MediaQuery.of(context);

//   if (orientation.toLowerCase() == 'vertical') {
//     return mediaQuery.size.width * 0.025; // 2.5% of screen width
//   }
//   if (orientation.toLowerCase() == 'horizontal') {
//     return mediaQuery.size.height * 0.025; // 2.5% of screen height
//   }

//   return 0.0;
// }

// double getSmallTextSize(BuildContext context, String orientation) {
//   final mediaQuery = MediaQuery.of(context);

//   if (orientation.toLowerCase() == 'vertical') {
//     return mediaQuery.size.width * 0.02; // 2% of screen width
//   }
//   if (orientation.toLowerCase() == 'horizontal') {
//     return mediaQuery.size.height * 0.02; // 2% of screen height
//   }

//   return 0.0;
// }
