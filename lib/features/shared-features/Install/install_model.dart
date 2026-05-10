import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_util.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/form_field_controller.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Install/install_helper.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Install/install_widget_kiosk.dart';


class InstallModel extends FlutterFlowModel<InstallWidgetKiosk> {
  ///  State fields for stateful widgets in this page.
  bool initalizing = false;

  final formKey = GlobalKey<FormState>();
  // State field(s) for Device Name widget.
  FocusNode? deviceNameFocusNode;
  TextEditingController? deviceNameTextController;
  String? Function(BuildContext, String?)? deviceNameTextControllerValidator;
  // State field(s) for Tenant widget.
  FocusNode? deviceNumberFocusNode;
  TextEditingController? deviceNumberTextController;
  String? Function(BuildContext, String?)? deviceNumberTextControllerValidator;
  TextEditingController? ipTextController;
  String? Function(BuildContext, String?)? ipTextControllerValidator;
  // State field(s) for Tenant widget.
  FocusNode? ipFocusNode;
  FocusNode? tenantFocusNode;
  TextEditingController? tenantTextController;
  String? Function(BuildContext, String?)? tenantTextControllerValidator;
  // State field(s) for Store widget.
  FocusNode? storeFocusNode;
  TextEditingController? storeTextController;
  String? Function(BuildContext, String?)? storeTextControllerValidator;
  // State field(s) for TenderType widget.
  FocusNode? tenderTypeFocusNode1;
  TextEditingController? tenderTypeTextController1;
  String? Function(BuildContext, String?)? tenderTypeTextController1Validator;
  // State field(s) for Language widget.
  String? languageValue;
  FormFieldController<InstallOptionModel>? languageValueController;
  String? versionValue;
  FormFieldController<InstallOptionModel>? versionValueController;
  // State field(s) for LanguageSec widget.
  String? languageSecValue;
  FormFieldController<InstallOptionModel>? languageSecValueController;
  // State field(s) for Align widget.
  String? naturalValue1;
  FormFieldController<InstallOptionModel>? naturalValueController1;
  // State field(s) for Align widget.
  String? timeZoneValue2;
  FormFieldController<InstallOptionModel>? timeZoneValueController2;
  // State field(s) for Align widget.
  String? loginMethodValue3;
  FormFieldController<InstallOptionModel>? loginMethodValueController3;
  // State field(s) for TenderType widget.
  FocusNode? syncInternFocusNode2;
  TextEditingController? syncIntrenController;
  String? Function(BuildContext, String?)? tenderTypeTextController2Validator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    deviceNameFocusNode?.dispose();
    deviceNameTextController?.dispose();

    tenantFocusNode?.dispose();
    tenantTextController?.dispose();

    storeFocusNode?.dispose();
    storeTextController?.dispose();

    tenderTypeFocusNode1?.dispose();
    tenderTypeTextController1?.dispose();

    syncInternFocusNode2?.dispose();
    syncIntrenController?.dispose();
  }
}
