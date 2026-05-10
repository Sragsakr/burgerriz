import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_model.dart';
import 'sellpage_widget.dart' show SellpageWidget;
import 'package:flutter/material.dart';

class SellpageModel extends FlutterFlowModel<SellpageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
