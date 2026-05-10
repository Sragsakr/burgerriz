import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_model.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/form_field_controller.dart';
import 'package:kiosk_point_of_sale/features/mobile-features/CheckOut/check_out_widget.dart';

class CheckOutModel extends FlutterFlowModel<CheckOutWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for ChoiceChips widget.
  FormFieldController<List<String>>? choiceChipsValueController;
  String? get choiceChipsValue =>
      choiceChipsValueController?.value?.firstOrNull;
  set choiceChipsValue(String? val) =>
      choiceChipsValueController?.value = val != null ? [val] : [];
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
