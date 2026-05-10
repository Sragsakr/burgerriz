import 'package:flutter/material.dart';

import '../../../core/flutter_flow/flutter_flow_util.dart';
import '../../../core/flutter_flow/form_field_controller.dart';
import 'login_widget.dart' show LoginWidget;

class LoginModel extends FlutterFlowModel<LoginWidget> {
  ///  State fields for stateful widgets in this page.
  ///
  TabController? tabBarController;

  final unfocusNode = FocusNode();
  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressController;
  String? Function(BuildContext, String?)? emailAddressControllerValidator;
  // State field(s) for password widget.
  FocusNode? passwordFocusNode;
  TextEditingController? passwordController;
  late bool passwordVisibility;
  late bool showPinCode;
  String? Function(BuildContext, String?)? passwordControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? pinCodeController;
  String? Function(BuildContext, String?)? textController3Validator;
  // State field(s) for TextField widget.
  FocusNode? tenantFieldFocusNode;
  TextEditingController? tenantController3;
  String? Function(BuildContext, String?)? tenantController3Validator;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    passwordVisibility = false;
    showPinCode = true;
  }

  @override
  void dispose() {
    tabBarController?.dispose();

    unfocusNode.dispose();
    emailAddressFocusNode?.dispose();
    emailAddressController?.dispose();
    passwordFocusNode?.dispose();
    passwordController?.dispose();
    textFieldFocusNode?.dispose();
    pinCodeController?.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
