import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kiosk_point_of_sale/features/mobile-features/SellPage/widgets/product_grid.dart';
import 'package:kiosk_point_of_sale/core/flutter_flow/flutter_flow_theme.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_language_helper.dart';
import 'package:kiosk_point_of_sale/core/helpers/responsive_helper.dart';
import 'package:kiosk_point_of_sale/providers/menu_providers.dart';

class SearchProductsWidget extends ConsumerStatefulWidget {
  const SearchProductsWidget({super.key});

  @override
  ConsumerState<SearchProductsWidget> createState() =>
      SearchProductsWidgetState();
}

class SearchProductsWidgetState extends ConsumerState<SearchProductsWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Clear search when entering this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchQueryProvider.notifier).state = '';
    });
  }

  @override
  void dispose() {
    // Clear search when leaving this page
    ref.read(searchQueryProvider.notifier).state = '';
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final searchQuery = ref.watch(searchQueryProvider);
    final searchResults = ref.watch(searchProductsProvider);

    // Sync text controller with provider
    if (_controller.text != searchQuery) {
      _controller.text = searchQuery;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: (query) {
                // Update search query using provider
                ref.read(searchQueryProvider.notifier).state = query;

                // Clear any selected category when search is active
                // This ensures search results are shown instead of category-filtered products
              },
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText:
                    translator(arText: 'اسم المنتج', enText: 'Product Name'),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
              child: ProductGrid(
            products: searchResults,
            isEnglish: isEnglish,
            fromSearch: true,
          )),
        ],
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: Icon(
            Icons.language,
            size: ResponsiveHelper.getResponsiveSize(
              context,
              24,
            ),
          ),
          onPressed: () async {
            await switchAppLanguage(ref, context);
          },
        ),
      ],
      centerTitle: true,
      elevation: 0.8,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: Color(0xFFAF2A26),
          size: 30.0,
        ),
        onPressed: () {
          context.go('/sell-page');
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(2.0, 0.0, 0.0, 0.0),
          child: Text(
            translator(arText: "إبحث عن المنتج", enText: "Search For Product"),
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  fontFamily: 'Outfit',
                  color: FlutterFlowTheme.of(context).gray600,
                ),
          ),
        ),
        centerTitle: true,
        expandedTitleScale: 1.0,
      ),
    );
  }
}
