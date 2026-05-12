import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/core/assets/app_assets.dart';
import 'package:kiosk_point_of_sale/core/components/install_form_field.dart';
import 'package:kiosk_point_of_sale/core/components/install_option_dropdown.dart';
import 'package:kiosk_point_of_sale/core/components/install_title.dart';
import 'package:kiosk_point_of_sale/core/enums/environment_enums.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_widgets.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/form_field_controller.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/internationalization.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Install/install_helper.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Install/new_install_controller.dart';
import 'package:kiosk_point_of_sale/features/shared-features/Login/new_login_widget.dart';

class NewInstallWidget extends ConsumerStatefulWidget {
  static const routeName = 'NewInstall';
  static const routePath = '/install-v2';

  final NewInstallController? controller;

  const NewInstallWidget({super.key, this.controller});

  @override
  ConsumerState<NewInstallWidget> createState() => _NewInstallWidgetState();
}

class _NewInstallWidgetState extends ConsumerState<NewInstallWidget> {
  late final NewInstallController _controller;
  late final bool _ownsController;
  final _formKey = GlobalKey<FormState>();

  final _ipController = TextEditingController();
  final _ipFocusNode = FocusNode();
  final _clusterController = TextEditingController();
  final _clusterFocusNode = FocusNode();

  final _tenderTypeController = TextEditingController();
  final _tenderTypeFocusNode = FocusNode();

  final _syncController = TextEditingController();
  final _syncFocusNode = FocusNode();

  late final FormFieldController<InstallOptionModel> _firstLangController;
  late final FormFieldController<InstallOptionModel> _secondLangController;
  late final FormFieldController<InstallOptionModel> _environmentController;

  bool _ipLookupDone = false;

  InstallOptionModel _langOrFallback(String code, InstallOptionModel fallback) {
    try {
      return languageOptions.firstWhere((e) => e.value == code);
    } catch (_) {
      return fallback;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = NewInstallController();
      _ownsController = true;
    }

    _firstLangController = FormFieldController<InstallOptionModel>(
      languageOptions.firstWhere((o) => o.value == 'en',
          orElse: () => languageOptions.first),
    );
    _secondLangController = FormFieldController<InstallOptionModel>(
      languageOptions.firstWhere((o) => o.value == 'ar',
          orElse: () => languageOptions.last),
    );

    final initialEnv = naturalOptions.firstWhere(
      (o) => o.value == Environment.Production.name,
      orElse: () => naturalOptions.first,
    );
    _environmentController =
        FormFieldController<InstallOptionModel>(initialEnv);

    _syncController.text = '0';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hydrateFromPrefs();
    });

    _loadIp();
  }

  Future<void> _hydrateFromPrefs() async {
    final p = AppPreferences();
    final lang = await p.getLanguage();
    final sec = await p.getSecLanguage();
    final sync = await p.getSyncInterval();
    final tenderType = await p.getTenderType();
    final env = await p.getEnvironmentType();
    final clusterId = await p.getClusterId();

    if (!mounted) return;
    setState(() {
      _firstLangController.value = _langOrFallback(lang, languageOptions.first);
      if (sec.isNotEmpty) {
        _secondLangController.value =
            _langOrFallback(sec, languageOptions.last);
      }
      if (sync.isNotEmpty) {
        _syncController.text = sync;
      }
      if (tenderType.isNotEmpty) {
        _tenderTypeController.text = tenderType;
      }
      if (env.isNotEmpty) {
        _environmentController.value =
            naturalOptions.firstWhere((e) => e.value == env, orElse: () => naturalOptions.first);
      }
      if (clusterId > 0) {
        _clusterController.text = clusterId.toString();
      }
    });
  }

  Future<void> _loadIp() async {
    String ip = '';
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      ip = interfaces
          .expand((element) => element.addresses)
          .map((element) => element.address)
          .firstWhere((element) => element.isNotEmpty, orElse: () => '');
    } catch (_) {
      ip = '';
    }

    if (!mounted) return;
    setState(() {
      _ipLookupDone = true;
      _ipController.text = ip;
    });
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    _firstLangController.dispose();
    _secondLangController.dispose();
    _environmentController.dispose();
    _ipController.dispose();
    _ipFocusNode.dispose();
    _clusterController.dispose();
    _clusterFocusNode.dispose();
    _tenderTypeController.dispose();
    _tenderTypeFocusNode.dispose();
    _syncController.dispose();
    _syncFocusNode.dispose();
    super.dispose();
  }

  String _t(BuildContext context, String key) =>
      FFLocalizations.of(context).getText(key);

  String _environmentValue() =>
      _environmentController.value?.value ?? Environment.Production.name;

  String? _validateTenderType(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) {
      return FFLocalizations.of(context).getText('fillAllData');
    }
    if (int.tryParse(t) == null) {
      return FFLocalizations.of(context).getText('fillAllData');
    }
    return null;
  }

  String? _validateSync(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) {
      return FFLocalizations.of(context).getText('fillAllData');
    }
    if (int.tryParse(s) == null) {
      return FFLocalizations.of(context).getText('fillAllData');
    }
    return null;
  }

  Align _buildSubmitButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: AlignmentDirectional.center,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 4, 24),
        child: FFButtonWidget(
          showLoadingIndicator: true,
          onPressed: () async {
            FocusScope.of(context).unfocus();
            if (!(_formKey.currentState?.validate() ?? false)) {
              return;
            }
            final first = _firstLangController.value?.value ?? 'en';
            final second = _secondLangController.value?.value ?? 'ar';
            final l10n = FFLocalizations.of(context);
            final clusterId = int.tryParse(_clusterController.text.trim()) ?? 0;
            final ip = _ipController.text.trim();

            final ok = await _controller.submit(
              ipAddress: ip,
              // ipAddress: "10.0.2.15",
              clusterId: clusterId,
              environment: _environmentValue(),
              firstLanguageCode: first,
              secondLanguageCode: second,
              syncInterval: _syncController.text.trim(),
              tenderType: _tenderTypeController.text.trim(),
              localizeKey: l10n.getText,
            );
            if (!ok || !context.mounted) return;
            context.go(NewLoginWidget.routePath);
          },
          text: _t(context, 'auth_flow_install_validate_continue'),
          options: FFButtonOptions(
            width:
                (MediaQuery.sizeOf(context).width * 0.92).clamp(260.0, 520.0),
            height: 52,
            padding: EdgeInsets.zero,
            iconPadding: EdgeInsets.zero,
            color: colorScheme.primary,
            textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: 'Readex Pro',
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onPrimary,
                ),
            elevation: 2,
            borderSide: const BorderSide(color: Colors.transparent, width: 1),
            borderRadius: BorderRadius.circular(40),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveHelper.getResponsivePadding(context).clamp(
      12.0,
      36.0,
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: hPad),
                  child: Form(
                    key: _formKey,
                    child: SizedBox(
                      height: MediaQuery.sizeOf(context).height,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 36, 0, 8),
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    AppAssets.newLogo,
                                    width: 300,
                                    height: 100,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  4, 8, 4, 4),
                              child: Text(
                                _t(context, 'auth_flow_install_title'),
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .override(
                                      fontFamily: 'Readex Pro',
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  InstallTitle(
                                    title: _t(context,
                                        'auth_flow_install_cluster_id'),
                                  ),
                                  InstallFormFieldFactory.clusterId(
                                    controller: _clusterController,
                                    focusNode: _clusterFocusNode,
                                    validator: (v) {
                                      final id = int.tryParse(v ?? '') ?? 0;
                                      if (id <= 0) {
                                        return FFLocalizations.of(context)
                                            .getText('fillAllData');
                                      }
                                      return null;
                                    },
                                  ),
                                  InstallTitleFactory.tenderType(),
                                  InstallFormFieldFactory.tenderType(
                                    controller: _tenderTypeController,
                                    focusNode: _tenderTypeFocusNode,
                                    validator: _validateTenderType,
                                  ),
                                  InstallTitleFactory.ipAddress(),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child:
                                            InstallFormFieldFactory.ipAddress(
                                          controller: _ipController,
                                          focusNode: _ipFocusNode,
                                          readOnly: true,
                                          validator: (v) {
                                            if ((v ?? '').trim().isEmpty) {
                                              return FFLocalizations.of(context)
                                                  .getText(
                                                      'auth_flow_install_ip_missing');
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      if (!_ipLookupDone)
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                  start: 8, top: 24),
                                          child: SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  InstallTitleFactory.syncInterval(),
                                  InstallFormFieldFactory.syncInterval(
                                    controller: _syncController,
                                    focusNode: _syncFocusNode,
                                    validator: _validateSync,
                                  ),
                                  InstallTitleFactory.natural(),
                                  InstallOptionDropdownFactory.environment(
                                    controller: _environmentController,
                                    options: naturalOptions,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  InstallTitleFactory.firstLanguage(),
                                  InstallOptionDropdownFactory.language(
                                    controller: _firstLangController,
                                    options: languageOptions,
                                    onChanged: (val) async {
                                      setState(() {});
                                      await switchAppLanguage(ref, context,
                                          newLang: val?.value);
                                    },
                                  ),
                                  InstallTitleFactory.secondLanguage(),
                                  InstallOptionDropdownFactory.language(
                                    controller: _secondLangController,
                                    options: languageOptions,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  if (_controller.state.errorMessage != null)
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              4, 8, 4, 0),
                                      child: SelectableText(
                                        _controller.state.errorMessage!,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Readex Pro',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.sizeOf(context).height * 0.04),
                            _buildSubmitButton(context),
                            SizedBox(
                              height:
                                  ResponsiveHelper.getResponsivePadding(context)
                                      .clamp(16.0, 48.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
