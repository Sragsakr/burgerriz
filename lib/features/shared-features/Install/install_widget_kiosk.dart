import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiosk_point_of_sale/core/components/install_form_field.dart';
import 'package:kiosk_point_of_sale/core/components/install_option_dropdown.dart';
import 'package:kiosk_point_of_sale/core/components/install_title.dart';
import 'package:kiosk_point_of_sale/core/assets/app_assets.dart';
import 'package:kiosk_point_of_sale/core/config/app_config.dart';
import 'package:kiosk_point_of_sale/core/enums/environment_enums.dart';
import 'package:kiosk_point_of_sale/core/extentions/app_extentions.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_animations.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_util.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_widgets.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/form_field_controller.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/helper_functions.dart';
import 'package:kiosk_point_of_sale/core/helpers/install_functions.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Install/install_helper.dart';

import '../../../core/helpers/responsive_helper.dart';
import 'install_model.dart';

export 'install_model.dart';

class InstallWidgetKiosk extends ConsumerStatefulWidget {
  static late BuildContext installContext;
  static String routeName = 'InstallKiosk';
  static String routePath = '/install-kiosk';
  const InstallWidgetKiosk({super.key});

  @override
  ConsumerState<InstallWidgetKiosk> createState() => _InstallWidgetState();
}

class _InstallWidgetState extends ConsumerState<InstallWidgetKiosk>
    with TickerProviderStateMixin {
  late InstallModel _model;
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    InstallWidgetKiosk.installContext = context;
    _model = createModel(context, () => InstallModel());

    _model.deviceNameTextController ??= TextEditingController();
    _model.deviceNameFocusNode ??= FocusNode();
    _model.deviceNumberTextController ??= TextEditingController();
    _model.deviceNumberFocusNode ??= FocusNode();

    _model.tenantTextController ??= TextEditingController();
    _model.tenantFocusNode ??= FocusNode();

    _model.storeTextController ??= TextEditingController();
    _model.storeFocusNode ??= FocusNode();

    _model.tenderTypeTextController1 ??= TextEditingController();
    _model.tenderTypeFocusNode1 ??= FocusNode();

    _model.syncIntrenController ??= TextEditingController();
    _model.syncInternFocusNode2 ??= FocusNode();
    _model.ipTextController ??= TextEditingController();
    _model.ipFocusNode ??= FocusNode();
    _model.languageValueController ??=
        FormFieldController<InstallOptionModel>(null);
    _model.versionValueController ??=
        FormFieldController<InstallOptionModel>(null);
    _model.languageSecValueController ??=
        FormFieldController<InstallOptionModel>(null);
    _model.naturalValueController1 ??=
        FormFieldController<InstallOptionModel>(null);
    _model.loginMethodValueController3 ??=
        FormFieldController<InstallOptionModel>(null);
    _model.timeZoneValueController2 ??=
        FormFieldController<InstallOptionModel>(null);

    animationsMap.addAll({
      'containerOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: [
          VisibilityEffect(duration: 200.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 200.ms,
            duration: 600.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'containerOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: [
          VisibilityEffect(duration: 200.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 200.ms,
            duration: 600.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
    });
    setState(() {
      InstallFunctions().loadValues(_model);
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Align(
            alignment: const AlignmentDirectional(0, 0),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Align(
                                alignment: const AlignmentDirectional(0, 0),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 50, 0, 10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      AppAssets.newLogo,
                                      width: 300,
                                      height: 71,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                            ),
                            child: Form(
                              key: _model.formKey,
                              autovalidateMode: AutovalidateMode.disabled,
                              child: Padding(
                                padding: EdgeInsetsDirectional.symmetric(
                                    horizontal: 3.w),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InstallTitleFactory.deviceNumber(),
                                    InstallFormFieldFactory.deviceNumber(
                                      controller:
                                          _model.deviceNumberTextController!,
                                      focusNode: _model.deviceNumberFocusNode!,
                                      validator: _model
                                          .deviceNumberTextControllerValidator
                                          .asValidator(context),
                                    ),
// Device Name
                                  if(AppConfig.isKiosk)
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              4, 5, 0, 0),
                                      child: Text(
                                        translator(
                                            arText: "اسم الجهاز",
                                            enText: "Device Name"),
                                        style: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              fontFamily: 'Readex Pro',
                                              fontSize: ResponsiveHelper
                                                  .getResponsiveFontSize(
                                                      context, 18),
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                    if(AppConfig.isKiosk)
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 12, 0, 12),
                                      child: TextFormField(
                                        controller:
                                            _model.deviceNameTextController,
                                        focusNode: _model.deviceNameFocusNode,
                                        autofocus: false,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          labelStyle: FlutterFlowTheme.of(
                                                  context)
                                              .labelLarge
                                              .override(
                                                fontFamily: 'Plus Jakarta Sans',
                                                color: const Color(0xFF57636C),
                                                fontSize: ResponsiveHelper
                                                    .getResponsiveFontSize(
                                                        context, 16),
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                          hintText: translator(
                                              arText: "اسم الجهاز",
                                              enText: "Device Name"),
                                          hintStyle: FlutterFlowTheme.of(
                                                  context)
                                              .labelLarge
                                              .override(
                                                fontFamily: 'Plus Jakarta Sans',
                                                color: const Color(0xFF57636C),
                                                fontSize: ResponsiveHelper
                                                    .getResponsiveFontSize(
                                                        context, 16),
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFFE0E3E7),
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4.0),
                                              topRight: Radius.circular(4.0),
                                            ),
                                          ),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFF4B39EF),
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4.0),
                                              topRight: Radius.circular(4.0),
                                            ),
                                          ),
                                          errorBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFFFF5963),
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4.0),
                                              topRight: Radius.circular(4.0),
                                            ),
                                          ),
                                          focusedErrorBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFFFF5963),
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4.0),
                                              topRight: Radius.circular(4.0),
                                            ),
                                          ),
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .override(
                                              fontFamily: 'Plus Jakarta Sans',
                                              color: const Color(0xFF14181B),
                                              fontSize: ResponsiveHelper
                                                  .getResponsiveFontSize(
                                                      context, 16),
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                        keyboardType: TextInputType.text,
                                        validator: _model
                                            .deviceNameTextControllerValidator
                                            .asValidator(context),
                                      ),
                                    ),
                                    // Tenant
                                    InstallTitleFactory.tenant(),
                                    InstallFormFieldFactory.tenant(
                                      controller: _model.tenantTextController!,
                                      focusNode: _model.tenantFocusNode!,
                                      validator: _model
                                          .tenantTextControllerValidator
                                          .asValidator(context),
                                    ),

                                    // Store
                                    InstallTitleFactory.store(),
                                    InstallFormFieldFactory.store(
                                      controller: _model.storeTextController!,
                                      focusNode: _model.storeFocusNode!,
                                      validator: _model
                                          .storeTextControllerValidator
                                          .asValidator(context),
                                    ),

                                    // Tender Type
                                    InstallTitleFactory.tenderType(),
                                    InstallFormFieldFactory.tenderType(
                                      controller:
                                          _model.tenderTypeTextController1!,
                                      focusNode: _model.tenderTypeFocusNode1!,
                                      validator: _model
                                          .tenderTypeTextController1Validator
                                          .asValidator(context),
                                    ),

                                    // Version
                                    InstallTitleFactory.version(),
                                    InstallOptionDropdownFactory.version(
                                      controller:
                                          _model.versionValueController!,
                                      options: versionOptions,
                                      onChanged: (val) async {
                                        safeSetState(() =>
                                            _model.versionValue = val?.value);
                                        dPrint(val?.value.toString());
                                      },
                                    ),

                                    // First Language
                                    InstallTitleFactory.firstLanguage(),
                                    InstallOptionDropdownFactory.language(
                                      controller:
                                          _model.languageValueController!,
                                      options: languageOptions,
                                      onChanged: (val) async {
                                        safeSetState(() =>
                                            _model.languageValue = val?.value);
                                        dPrint(val?.value.toString());
                                        await switchAppLanguage(ref, context,
                                            newLang: val?.value);
                                      },
                                    ),

                                    // Second Language
                                    InstallTitleFactory.secondLanguage(),
                                    InstallOptionDropdownFactory.language(
                                      controller:
                                          _model.languageSecValueController!,
                                      options: languageOptions,
                                      onChanged: (val) => safeSetState(() =>
                                          _model.languageSecValue = val?.value),
                                    ),

                                    // Natural (Environment)
                                    InstallTitleFactory.natural(),
                                    InstallOptionDropdownFactory.environment(
                                      controller:
                                          _model.naturalValueController1!,
                                      options: naturalOptions,
                                      onChanged: (val) => safeSetState(() =>
                                          _model.naturalValue1 = val?.value),
                                    ),

                                    // IP Address (conditional)
                                    if (_model.naturalValue1 ==
                                        Environment.LocalHost.name
                                            .toString()) ...[
                                      InstallTitleFactory.ipAddress(),
                                      InstallFormFieldFactory.ipAddress(
                                        controller: _model.ipTextController!,
                                        focusNode: _model.ipFocusNode!,
                                        validator: _model
                                            .ipTextControllerValidator
                                            .asValidator(context),
                                      ),
                                    ],

                                    // Time Zone
                                    InstallTitleFactory.timeZone(),
                                    InstallOptionDropdownFactory.timeZone(
                                      controller:
                                          _model.timeZoneValueController2!,
                                      options: timeZoneOptions,
                                      onChanged: (val) => safeSetState(() =>
                                          _model.timeZoneValue2 = val?.value),
                                    ),

                                    // Login Method
                                    InstallTitleFactory.loginMethod(),
                                    InstallOptionDropdownFactory.loginMethod(
                                      controller:
                                          _model.loginMethodValueController3!,
                                      options: loginMethodOptions,
                                      onChanged: (val) => safeSetState(() =>
                                          _model.loginMethodValue3 =
                                              val?.value),
                                    ),

                                    // Connection String (Sync Interval)
                                    InstallTitleFactory.syncInterval(),
                                    InstallFormFieldFactory.syncInterval(
                                      controller: _model.syncIntrenController!,
                                      focusNode: _model.syncInternFocusNode2!,
                                      validator: _model
                                          .tenderTypeTextController2Validator
                                          .asValidator(context),
                                    ),

                                    // Install Button
                                    buildInstallButton(context),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation1']!);
  }

  Align buildInstallButton(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0, 0),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 4, 0),
        child: FFButtonWidget(
          onPressed: () async {
            if (_model.formKey.currentState!.validate()) {
              await InstallFunctions()
                  .handleSaveAndNavigate(context, _model, ref);
            }
          },
          text: FFLocalizations.of(context).getText(
            'h02xw3hg' /* Install */,
          ),
          options: FFButtonOptions(
            width: MediaQuery.of(context).size.width * 0.30,
            height: 50,
            padding: const EdgeInsets.all(0),
            iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            color: const Color(0xFFAF2A26),
            textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: 'Readex Pro',
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                ),
            elevation: 2,
            borderSide: const BorderSide(
              color: Colors.transparent,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(40),
            hoverColor: const Color(0xFF32343A),
          ),
        ),
      ),
    );
  }
}
