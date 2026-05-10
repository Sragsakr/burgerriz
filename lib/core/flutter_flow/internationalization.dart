import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kiosk_point_of_sale/core/helpers/app_pref.dart';

class FFLocalizations {
  FFLocalizations(this.locale);

  final Locale locale;

  static FFLocalizations of(BuildContext context) => Localizations.of<FFLocalizations>(context, FFLocalizations)!;

  static List<String> languages() => ['en', 'ar'];

  static bool _isInitialized = false;

  static Future initialize() async {
    print("FFLocalizations.initialize - Starting initialization");
    // AppPreferences is already initialized in main.dart before this is called
    _isInitialized = true;
    print("FFLocalizations.initialize - Initialization complete");
  }

  static bool get isInitialized => _isInitialized;
  static Future storeLocale(String locale) async {
    if (!_isInitialized) {
      print("FFLocalizations.storeLocale - Not initialized yet, cannot store locale");
      throw Exception("FFLocalizations not initialized yet");
    }

    try {
      final appPrefs = AppPreferences();
      final savedLocale = await appPrefs.getLanguage();
      print("FFLocalizations.storeLocale - Previous savedLocale: $savedLocale, New locale: $locale");
      await appPrefs.setLanguage(locale);
    } catch (e) {
      print("FFLocalizations.storeLocale - Error: $e");
      rethrow;
    }
  }

  static Future<Locale?> getStoredLocale() async {
    if (!_isInitialized) {
      print("FFLocalizations.getStoredLocale - Not initialized yet, returning default locale");
      return const Locale('en'); // Default: English
    }

    try {
      final appPrefs = AppPreferences();
      final locale = await appPrefs.getLanguage();
      print("FFLocalizations.getStoredLocale - Retrieved locale: $locale");

      // Check if locale is valid and not empty
      if (locale.isNotEmpty && languages().contains(locale)) {
        return createLocale(locale);
      } else {
        print("FFLocalizations.getStoredLocale - Invalid or empty locale, using default");
        return const Locale('en'); // Default: English
      }
    } catch (e) {
      print("FFLocalizations.getStoredLocale - Error: $e");
      return const Locale('en'); // Default: English
    }
  }

  String get languageCode => locale.toString();
  String? get languageShortCode =>
      _languagesWithShortCode.contains(locale.toString()) ? '${locale.toString()}_short' : null;
  int get languageIndex => languages().contains(languageCode) ? languages().indexOf(languageCode) : 0;

  String getText(String key) => (kTranslationsMap[key] ?? {})[locale.toString()] ?? '';

  String getVariableText({
    String? enText = '',
    String? arText = '',
  }) =>
      [enText, arText][languageIndex] ?? '';

  static const Set<String> _languagesWithShortCode = {
    'ar',
    'az',
    'ca',
    'cs',
    'da',
    'de',
    'dv',
    'en',
    'es',
    'et',
    'fi',
    'fr',
    'gr',
    'he',
    'hi',
    'hu',
    'it',
    'km',
    'ku',
    'mn',
    'ms',
    'no',
    'pt',
    'ro',
    'ru',
    'rw',
    'sv',
    'th',
    'uk',
    'vi',
  };
}

class FFLocalizationsDelegate extends LocalizationsDelegate<FFLocalizations> {
  const FFLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    final language = locale.toString();
    return FFLocalizations.languages().contains(
      language.endsWith('_') ? language.substring(0, language.length - 1) : language,
    );
  }

  @override
  Future<FFLocalizations> load(Locale locale) => SynchronousFuture<FFLocalizations>(FFLocalizations(locale));

  @override
  bool shouldReload(FFLocalizationsDelegate old) => false;
}

Locale createLocale(String language) => language.contains('_')
    ? Locale.fromSubtags(
        languageCode: language.split('_').first,
        scriptCode: language.split('_').last,
      )
    : Locale(language);

final kTranslationsMap = <Map<String, Map<String, String>>>[
  // Login
  {
    'xReport.title': {
      'en': 'X Report',
      'ar': 'تقرير X',
    },
    'xReport.preview': {
      'en': 'Preview',
      'ar': 'معاينة',
    },
    'xReport.print': {
      'en': 'Print',
      'ar': 'طباعة',
    },
    'xReport.sharePdf': {
      'en': 'Share PDF',
      'ar': 'مشاركة ملف PDF',
    },
    'xReport.noOpenShift': {
      'en': 'No open shift. Start a shift to view the X-Report.',
      'ar': 'لا توجد وردية مفتوحة. ابدأ وردية لعرض تقرير X.',
    },
    'xReport.generatedAt': {
      'en': 'Generated at',
      'ar': 'تم الإنشاء في',
    },
    'xReport.currentShift': {
      'en': 'Current Shift',
      'ar': 'الوردية الحالية',
    },
    '1qazxsw2': {
      'en': 'Table booked. Please choose a different table.',
      'ar': 'الطاولة محجوزة. الرجاء اختيار طاولة أخرى',
    },
    'saleType': {
      'en': 'Sale Type',
      'ar': 'نوع البيع',
    },
    'fillAllData': {
      'en': 'Please fill in all the fields',
      'ar': 'الرجاء ملء جميع الحقول',
    },
    'erroOcureWithgettingConfigorations': {
      'en': 'Error ocurred while getting configurations',
      'ar': 'حدث خطأ اثناء الحصول على الاعدادات',
    },
    'deviceNumber': {
      'en': 'Device Number',
      'ar': 'رقم الجهاز',
    },
    '679kunro': {
      'en': 'Welcome',
      'ar': 'مرحباً',
    },
    't9abm3vl': {
      'en': 'To Your POS System',
      'ar': 'إلى نظام نقاط البيع الخاص بك',
    },
    '3ggxepf3': {
      'en': 'Enter your username and password',
      'ar': 'أدخل اسم المستخدم وكلمة المرور',
    },
    '78gfsss7': {
      'en': 'Enter your unique identification code',
      'ar': 'أدخل رمز التعريف الفريد الخاص بك',
    },
    'enter_tenant': {
      'en': 'Enter your TenantId',
      'ar': 'أدخل رقم المستأجر الخاص بك',
    },
    'tenant': {
      'en': 'your TenantId',
      'ar': 'رقم المستأجر الخاص بك',
    },
    'ovm5vn6o': {
      'en': 'Username/Email',
      'ar': 'البريد الإلكتروني',
    },
    'sqabz9sq': {
      'en': '',
      'ar': '',
    },
    '5xyu281n': {
      'en': 'Password',
      'ar': 'كلمة المرور',
    },
    '4mj4b3yb': {
      'en': 'Agent PIN Code...',
      'ar': 'رمز PIN للمستخدم...',
    },
    '3z445p83': {
      'en': 'EXIT',
      'ar': 'خروج',
    },
    'fyss8fwz': {
      'en': 'LOGIN',
      'ar': 'تسجيل الدخول',
    },
    'o1ps2y3h1': {
      'en': 'Error encountered',
      'ar': 'حدث خطأ',
    },
    'o1ps2y3t1': {
      'en': 'Username and password cannot be empty.',
      'ar': 'لا يمكن أن يكون اسم المستخدم وكلمة المرور فارغين',
    },
    'o1ps2y3t2': {
      'en': 'Invalid user name or password.',
      'ar': 'خطأ في اسم المستخدم أو كلمة مرور',
    },
    'auth_flow_install_title': {
      'en': 'Install Device',
      'ar': 'تثبيت الجهاز',
    },
    'auth_flow_install_ip_address': {
      'en': 'IP Address',
      'ar': 'عنوان IP',
    },
    'auth_flow_install_ip_missing': {
      'en': 'Could not detect this device IP address. Connect to Wi‑Fi or Ethernet and try again.',
      'ar': 'تعذّر اكتشاف عنوان IP للجهاز. تأكد من الاتصال بالواي فاي أو الشبكة السلكية ثم أعد المحاولة.',
    },
    'auth_flow_install_cluster_id': {
      'en': 'Cluster ID',
      'ar': 'معرّف العنقود',
    },
    'auth_flow_install_environment': {
      'en': 'Environment',
      'ar': 'البيئة',
    },
    'auth_flow_install_validate_continue': {
      'en': 'Validate & Continue',
      'ar': 'تحقق ومتابعة',
    },
    'auth_flow_install_validation_failed': {
      'en': 'Installation validation failed',
      'ar': 'فشل التحقق من التثبيت',
    },
    'auth_flow_login_title': {
      'en': 'Device Login',
      'ar': 'تسجيل دخول الجهاز',
    },
    'auth_flow_login_pin_code': {
      'en': 'PIN Code',
      'ar': 'رمز PIN',
    },
    'auth_flow_login_submit': {
      'en': 'Login',
      'ar': 'تسجيل الدخول',
    },
    'auth_flow_error_pin_required': {
      'en': 'PIN is required',
      'ar': 'رمز PIN مطلوب',
    },
    'auth_flow_error_online_required': {
      'en': 'Online authentication is required',
      'ar': 'يلزم الاتصال بالإنترنت للمصادقة',
    },
    'auth_flow_error_install_missing': {
      'en': 'Installation data is missing',
      'ar': 'بيانات التثبيت غير متوفرة',
    },
    'aa11aa11a': {
      'en': 'Please select a payment method and add a value.',
      'ar': 'الرجاء تحديد طريقة الدفع وإضافة قيمة',
    },
    'cxc6v30g': {
      'en': '2.8.2023 ',
      'ar': '2.8.2023',
    },
    'gctezycy': {
      'en': 'V3',
      'ar': 'V3',
    },
    'qxng8x3v': {
      'en': 'English',
      'ar': 'الإنجليزية',
    },
    'r20g2lcm': {
      'en': 'English',
      'ar': 'الإنجليزية',
    },
    'h41jyeam': {
      'en': 'Arabic',
      'ar': 'عربي',
    },
    'g1fsz32d': {
      'en': 'Please select...',
      'ar': 'الرجاء التحديد...',
    },
    '8142oqw5': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    '804yj6p8': {
      'en': 'Home',
      'ar': 'الرئيسية',
    },
    'customers': {
      'en': 'Customers',
      'ar': 'العملاء',
    },
    'customerAddresses': {
      'en': 'Customer Addresses',
      'ar': 'عناوين العميل',
    },
  },
  // ReportsDone
  {
    'hxudof7b': {
      'en': '',
      'ar': 'مبيعات',
    },
    '12b8fhs7': {
      'en': 'Total Sales Today',
      'ar': 'إجمالي المبيعات اليوم',
    },
    '10q4wedx': {
      'en': 'SAR 500.20',
      'ar': '500.20 ريال سعودي',
    },
    'lw127p2i': {
      'en': '35%',
      'ar': '35%',
    },
    'ich0mz1u': {
      'en': 'Numbers of Orders',
      'ar': 'أعداد الطلبات',
    },
    's5gomgmw': {
      'en': 'Total Orders Today',
      'ar': 'إجمالي الطلبات اليوم',
    },
    '1y66qtq6': {
      'en': '6  Orders',
      'ar': '6 طلبات',
    },
    'gk97a07c': {
      'en': '15%',
      'ar': '15٪',
    },
    'zfwip53p': {
      'en': 'System Report',
      'ar': 'تقرير النظام',
    },
    'tqxnronw': {
      'en': 'Cashier\'s report',
      'ar': 'تقرير أمين الصندوق',
    },
    'd6zzp9gv': {
      'en': 'End of day report',
      'ar': 'تقرير نهاية اليوم',
    },
    '00q18wdn': {
      'en': 'Items Report',
      'ar': 'تقرير العناصر',
    },
    'zxj5u4xx': {
      'en': 'Invoice Printing',
      'ar': 'طباعة الفاتورة',
    },
    'vqra1hdn': {
      'en': 'Categories Report',
      'ar': 'تقرير الفئات',
    },
    'f4bz89mv': {
      'en': 'Last Bill',
      'ar': 'الفاتورة الأخيرة',
    },
    'r05u505x': {
      'en': 'First Bill',
      'ar': 'الفاتورة الأولى',
    },
    '6qgcpnw3': {
      'en': 'POSMena Reports',
      'ar': 'تقارير بوسمينا',
    },
    'fbqb7hcm': {
      'en': 'Cashier,',
      'ar': 'أمين الصندوق،',
    },
    '8o4glduh': {
      'en': 'Osama',
      'ar': 'أسامة',
    },
    '5hs5t58y': {
      'en': 'Home',
      'ar': 'الرئيسية',
    },
  },
  // DeliveryOrdersInvoices
  {
    'ka4qna8m': {
      'en': 'Delivery Orders Invoices',
      'ar': 'فواتير طلبات التوصيل',
    },
    'outnrk2x': {
      'en': 'Cashier,',
      'ar': 'أمين الصندوق،',
    },
    'tuadw4ym': {
      'en': 'Osama',
      'ar': 'أسامة',
    },
    'difr0z0c': {
      'en': 'Invoice',
      'ar': 'فاتورة',
    },
    'nscjcu36': {
      'en': '3',
      'ar': '3',
    },
    'hfrd4y4h': {
      'en': 'Delivery Orders Invoices table in details',
      'ar': 'جدول فواتير طلبات التوصيل بالتفصيل',
    },
    'wbsj48ch': {
      'en': 'Search users...',
      'ar': 'البحث عن المستخدمين...',
    },
    '6rn36lc0': {
      'en': '#',
      'ar': '#',
    },
    'hnh9j1el': {
      'en': 'DATE',
      'ar': 'التاريخ',
    },
    'jwqo07kq': {
      'en': 'TOTAL',
      'ar': 'المجموع',
    },
    'n0o39qoa': {
      'en': 'VAT',
      'ar': 'ضريبة القيمة المضافة',
    },
    'ynt1q7h3': {
      'en': 'STATUS',
      'ar': 'الحالة',
    },
    '17w49d9t': {
      'en': 'GRAND TOTAL',
      'ar': 'المجموع الكلي',
    },
    'dh8zni8m': {
      'en': 'DISCOUNT',
      'ar': 'الخصم',
    },
    's33gifus': {
      'en': '#42925424',
      'ar': '#42925424',
    },
    '4my02d0g': {
      'en': 'Jan. 30th, 2023',
      'ar': '30 يناير 2023',
    },
    '2f4sjtcx': {
      'en': '12:23:47 PM',
      'ar': '12:23:47 مساءً',
    },
    'ezude6cv': {
      'en': '42',
      'ar': '42',
    },
    'qmfaohp2': {
      'en': '5',
      'ar': '5',
    },
    '5knqbgy3': {
      'en': 'Paid',
      'ar': 'مدفوع',
    },
    '423q9gup': {
      'en': 'SR 47.00',
      'ar': '47.00 ريال سعودي',
    },
    'rd45urw2': {
      'en': '0',
      'ar': '0',
    },
    'i8vyu4kk': {
      'en': '#42925424',
      'ar': '#42925424',
    },
    'ag3whcdb': {
      'en': 'Jan. 30th, 2023',
      'ar': '30 يناير 2023',
    },
    'wb0heq91': {
      'en': '12:23:47 PM',
      'ar': '12:23:47 مساءً',
    },
    '98crtasn': {
      'en': '24',
      'ar': '24',
    },
    'ksii3ans': {
      'en': '24',
      'ar': '24',
    },
    'inxztqir': {
      'en': 'Paid',
      'ar': 'مدفوع',
    },
    'nj8kaaqx': {
      'en': 'SR 56.98',
      'ar': '56.98 ريال سعودي',
    },
    'xfhkxn5q': {
      'en': '0',
      'ar': '0',
    },
    'e7vitz6z': {
      'en': '#42925424',
      'ar': '#42925424',
    },
    'y2jofz70': {
      'en': 'Jan. 30th, 2023',
      'ar': '30 يناير 2023',
    },
    '8ppcaaj5': {
      'en': '12:23:47 PM',
      'ar': '12:23:47 مساءً',
    },
    'wj1rb76o': {
      'en': '24',
      'ar': '24',
    },
    's8gv6zmx': {
      'en': '24',
      'ar': '24',
    },
    'hhdexzme': {
      'en': 'Paid',
      'ar': 'مدفوع',
    },
    'ircvb5zg': {
      'en': 'SR 304.90',
      'ar': '304.90 ريال سعودي',
    },
    '8fs4x9of': {
      'en': '0',
      'ar': '0',
    },
    'tijezk6d': {
      'en': 'Receipt',
      'ar': 'إيصال',
    },
    'y9rar49z': {
      'en': 'Receipt details ',
      'ar': 'تفاصيل الاستلام',
    },
    'kbjoh6gc': {
      'en': 'QTY',
      'ar': 'الكمية',
    },
    'fo0mqyqn': {
      'en': 'MENU ITEM',
      'ar': 'عنصر من  القائمة',
    },
    '00b8z7g9': {
      'en': 'DISCOUNT',
      'ar': 'الخصم',
    },
    'shekyq5x': {
      'en': 'PRICE',
      'ar': 'السعر',
    },
    'thi174fn': {
      'en': '1',
      'ar': '1',
    },
    'ekerkfyz': {
      'en': 'ff',
      'ar': 'وما يليها',
    },
    'bxw3db9g': {
      'en': '0',
      'ar': '0',
    },
    '1mzylci5': {
      'en': '8',
      'ar': '8',
    },
    'r3uflk13': {
      'en': '2',
      'ar': '2',
    },
    '3w89a0um': {
      'en': 'pasta',
      'ar': 'مكرونة',
    },
    'qbu4xqod': {
      'en': '0',
      'ar': '0',
    },
    'jam5q6hn': {
      'en': '8',
      'ar': '8',
    },
    '79gx8u3k': {
      'en': '2',
      'ar': '2',
    },
    'qwh2ycn7': {
      'en': 'pasta',
      'ar': 'مكرونة',
    },
    'f2g3wnok': {
      'en': '0',
      'ar': '0',
    },
    '1auo1l62': {
      'en': '8',
      'ar': '8',
    },
    '2hu1ibq5': {
      'en': '2',
      'ar': '2',
    },
    '20ue49pf': {
      'en': 'pasta',
      'ar': 'مكرونة',
    },
    't1bhhwp1': {
      'en': '0',
      'ar': '0',
    },
    'fxabfdf3': {
      'en': '8',
      'ar': '8',
    },
    '86efo2uu': {
      'en': '2',
      'ar': '2',
    },
    'uwh40ur6': {
      'en': 'pasta',
      'ar': 'مكرونة',
    },
    'wcqekxi0': {
      'en': '0',
      'ar': '0',
    },
    'utkmmyaz': {
      'en': '8',
      'ar': '8',
    },
    'rnu2o93p': {
      'en': '2',
      'ar': '2',
    },
    'uuwdxpux': {
      'en': 'pasta',
      'ar': 'مكرونة',
    },
    '0qlpfbaj': {
      'en': '0',
      'ar': '0',
    },
    '2cdf3doo': {
      'en': '8',
      'ar': '8',
    },
    '4nulwyto': {
      'en': '2',
      'ar': '2',
    },
    'jivda7rw': {
      'en': 'pasta',
      'ar': 'مكرونة',
    },
    's2ovovme': {
      'en': '0',
      'ar': '0',
    },
    '6ljvba0f': {
      'en': '8',
      'ar': '8',
    },
    's05vx48o': {
      'en': '2',
      'ar': '2',
    },
    'mb48bbeu': {
      'en': 'pasta',
      'ar': 'مكرونة',
    },
    'f5mlktoo': {
      'en': '0',
      'ar': '0',
    },
    '1i9jg6px': {
      'en': '8',
      'ar': '8',
    },
    'yrjkfnzx': {
      'en': '2',
      'ar': '2',
    },
    'f6sixm0j': {
      'en': 'pasta',
      'ar': 'مكرونة',
    },
    'ccacc55s': {
      'en': '0',
      'ar': '0',
    },
    'lqs9r7li': {
      'en': '8',
      'ar': '8',
    },
    'lsx7uh2q': {
      'en': 'Grant Total & Items',
      'ar': 'إجمالي المنحة وعناصرها',
    },
    '1ggcj3lg': {
      'en': 'NUMBER OF ITEMS :',
      'ar': 'عدد العناصر :',
    },
    'dfvp9d6n': {
      'en': '5',
      'ar': '5',
    },
    '7zpm8s3q': {
      'en': 'GRAND TOTAL',
      'ar': 'المجموع الكلي',
    },
    'jo0va4wk': {
      'en': 'SR 47.00',
      'ar': '47.00 ريال سعودي',
    },
    'ksv2zgwo': {
      'en': 'Home',
      'ar': 'الرئيسية',
    },
  },
  // ConfigurationDone
  {
    'pqhsyy8p': {
      'en': 'Essential',
      'ar': 'ضروري',
    },
    'qezsirbz': {
      'en': 'Essential',
      'ar': 'ضروري',
    },
    'b54roekl': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'k24m5xkz': {
      'en': 'Add Photo',
      'ar': 'إضافة صورة',
    },
    'mrz7eoc3': {
      'en': 'Upload an image here...',
      'ar': 'ارفع صورة هنا...',
    },
    '6kxem3bh': {
      'en': 'Show logo ',
      'ar': 'إظهار الشعار',
    },
    '5drs1qbb': {
      'en': 'Show logo in kitchen bill',
      'ar': 'إظهار الشعار في فاتورة المطبخ',
    },
    'cnn960jh': {
      'en': 'Browse File',
      'ar': 'ملف الاستعراض',
    },
    'l79xi3cj': {
      'en': 'Clear File',
      'ar': 'ملف اضح',
    },
    'q0ne9z2r': {
      'en': 'Width',
      'ar': 'عرض',
    },
    'kwsw6sr9': {
      'en': 'Input logo width',
      'ar': 'عرض شعار الإدخال',
    },
    'id3kz8lk': {
      'en': 'Height',
      'ar': 'ارتفاع',
    },
    'lp5bdjjq': {
      'en': 'Input logo height',
      'ar': 'ارتفاع شعار الإدخال',
    },
    '5gaz9f3t': {
      'en': 'Align',
      'ar': 'محاذاة',
    },
    'oyxiayb7': {
      'en': 'Left',
      'ar': 'غادر',
    },
    'ew0i4po9': {
      'en': 'Center',
      'ar': 'مركز',
    },
    'rpgs86xt': {
      'en': 'Right',
      'ar': 'يمين',
    },
    's37z16f7': {
      'en': 'Please select...',
      'ar': 'الرجاء التحديد...',
    },
    '6ddtv099': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'vkkr0nz9': {
      'en': 'PCs',
      'ar': 'أجهزة الكمبيوتر',
    },
    'a6d6yu0j': {
      'en': 'Desktop pt1vffv',
      'ar': 'سطح المكتب pt1vffv',
    },
    'riggnbgk': {
      'en': 'Please select...',
      'ar': 'الرجاء التحديد...',
    },
    'uohjgfs9': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'l1aij1u6': {
      'en': 'Cashier Printer',
      'ar': 'طابعة كاشير',
    },
    'd98znbhr': {
      'en': 'OneNote for Windows 10',
      'ar': 'ون نوت لنظام التشغيل Windows 10',
    },
    '09gdw8gc': {
      'en': 'Microsoft XPS Document Writer',
      'ar': 'كاتب مستندات مايكروسوفت XPS',
    },
    '9hgmopy8': {
      'en': 'Microsoft Print to PDF',
      'ar': 'مايكروسوفت طباعة إلى PDF',
    },
    'rt5v7gdx': {
      'en': 'Fax',
      'ar': 'فاكس',
    },
    'fmkfr5mw': {
      'en': 'EPSON L3250 Series',
      'ar': 'سلسلة إبسون L3250',
    },
    '3kqzlwwv': {
      'en': 'Default',
      'ar': 'افتراضي',
    },
    'tebqu0tr': {
      'en': 'Please select...',
      'ar': 'الرجاء التحديد...',
    },
    'myq983y6': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    '4ac4dcpk': {
      'en': 'Date Format',
      'ar': 'صيغة التاريخ',
    },
    's4803ryp': {
      'en': 'MM/dd/yy',
      'ar': 'ش ش / ي ي / س س',
    },
    'vr2etbq2': {
      'en': 'dd/MM/yy',
      'ar': 'ي ي/ش ش/س س س',
    },
    'cr6czi4z': {
      'en': 'Please select...',
      'ar': 'الرجاء التحديد...',
    },
    '9evj9qe7': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    '88kiql0q': {
      'en': 'Printer Size',
      'ar': 'حجم الطابعة',
    },
    'b2ndnwcn': {
      'en': 'Custom',
      'ar': 'مخصص',
    },
    '2wb3uuhj': {
      'en': 'A4',
      'ar': 'A4',
    },
    'xidvdqmm': {
      'en': 'Please select...',
      'ar': 'الرجاء التحديد...',
    },
    '878w4ycv': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    '5329fkaz': {
      'en': 'Tax Number',
      'ar': 'الرقم الضريبي',
    },
    'jy59oc5k': {
      'en': 'Input tax number',
      'ar': 'رقم ضريبة الإدخال',
    },
    'eyw2vhi4': {
      'en': 'Telephone',
      'ar': 'هاتف',
    },
    'w6s216dd': {
      'en': 'Input telephone number',
      'ar': 'إدخال رقم الهاتف',
    },
    'p95va5qk': {
      'en': 'Seller Name',
      'ar': 'اسم البائع ',
    },
    'na26ctcv': {
      'en': 'Input  saller name',
      'ar': 'أدخل اسم البائع',
    },
    '3r2tw2i5': {
      'en': 'Login By PIN',
      'ar': 'تسجيل الدخول عن طريق رقم التعريف الشخصي',
    },
    'u0f2bpr6': {
      'en': 'Show QR Code ',
      'ar': 'إظهار رمز QR',
    },
    '57b2urjm': {
      'en': 'Printer Language',
      'ar': 'لغة الطابعة',
    },
    'w0w2x1a7': {
      'en': 'English',
      'ar': 'إنجليزي',
    },
    '80a944ef': {
      'en': 'Arabic',
      'ar': 'عربي',
    },
    '80nyy3da': {
      'en': 'English & Arabic',
      'ar': 'الإنجليزية/ العربية',
    },
    '1rlv82qe': {
      'en': 'Please select...',
      'ar': 'الرجاء التحديد...',
    },
    '8ny9zy5a': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    '2tq6fjss': {
      'en': 'Import',
      'ar': 'استيراد',
    },
    'fflmzq2x': {
      'en': 'Export',
      'ar': 'تصدير',
    },
    's55cls99': {
      'en': 'Save',
      'ar': 'حفظ',
    },
    '6oggnos7': {
      'en': 'Close',
      'ar': 'إغلاق',
    },
    '1wf6ptgl': {
      'en': 'Field is required',
      'ar': 'الحقل مطلوب',
    },
    '1ixswfsq': {
      'en': 'Please choose an option from the dropdown',
      'ar': 'يرجى اختيار خيار من القائمة المنسدلة',
    },
    'gu305fl4': {
      'en': 'Field is required',
      'ar': 'الحقل مطلوب',
    },
    'gjnks8x5': {
      'en': 'Please choose an option from the dropdown',
      'ar': 'يرجى اختيار خيار من القائمة المنسدلة',
    },
    'umgsxhr2': {
      'en': 'Advance',
      'ar': 'تقدم',
    },
    'rl5z9s13': {
      'en': 'Advance',
      'ar': 'تقدم',
    },
    'uhrj8w30': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'rcamngin': {
      'en': 'Controller Printer',
      'ar': 'طابعة تحكم',
    },
    '949qzm99': {
      'en': 'OneNote for Windows 10',
      'ar': 'ون نوت لنظام التشغيل Windows 10',
    },
    'arl0sb8m': {
      'en': 'Microsoft XPS Document Writer',
      'ar': 'كاتب مستندات مايكروسوفت XPS',
    },
    'epsl1opu': {
      'en': 'Microsoft Print to PDF',
      'ar': 'مايكروسوفت طباعة إلى PDF',
    },
    'omtlz700': {
      'en': 'Fax',
      'ar': 'فاكس',
    },
    'e4sr9t5l': {
      'en': 'EPSON L3250 Series',
      'ar': 'سلسلة إبسون L3250',
    },
    'jbmnpqy2': {
      'en': 'Default',
      'ar': 'تقصير',
    },
    'nuq10i0n': {
      'en': 'Please select...',
      'ar': 'الرجاء التحديد...',
    },
    'qexd3zqm': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    '3yifjk54': {
      'en': 'Enable ',
      'ar': 'يُمكَِن',
    },
    'qbp697y3': {
      'en': 'Printer Language Kitchen',
      'ar': 'مطبخ لغة الطابعة',
    },
    'wzsdi9k2': {
      'en': 'English',
      'ar': 'إنجليزي',
    },
    'yoh49yf3': {
      'en': 'Arabic',
      'ar': 'عربي',
    },
    'lihz7uov': {
      'en': 'English & Arabic',
      'ar': 'الإنجليزية و العربية',
    },
    'v86stk9t': {
      'en': 'Please select...',
      'ar': 'الرجاء التحديد...',
    },
    's5fy3mey': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'omhcbn5o': {
      'en': 'Check Connection ?',
      'ar': 'تحقق من اتصال ؟',
    },
    'yopfj7gr': {
      'en': 'Digits',
      'ar': 'أرقام',
    },
    'dt9bvwtg': {
      'en': '0',
      'ar': '0',
    },
    'qbnc39gr': {
      'en': 'Invoice Print Counter',
      'ar': 'عداد طباعة الفاتورة',
    },
    'q4sky85x': {
      'en': '1',
      'ar': '1',
    },
    'dr19o8lt': {
      'en': 'Invoice Date',
      'ar': 'تاريخ الفاتورة',
    },
    'm5q3e96q': {
      'en': 'MM/dd/yy',
      'ar': 'ش ش / ي ي / س س',
    },
    'tuy37xwz': {
      'en': 'dd/MM/yy',
      'ar': 'ي ي/ش ش/س س س',
    },
    '7rt0fi6o': {
      'en': 'Select a date ',
      'ar': 'حدد تاريخا',
    },
    '4f42dts7': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'skzwnt3o': {
      'en': 'Fixed Date',
      'ar': 'التاريخ المحدد',
    },
    '5q1uyahg': {
      'en': 'Auto Cretificate?',
      'ar': 'شهادة السيارات؟',
    },
    'm302cqqa': {
      'en': 'Activate ?',
      'ar': 'تفعيل ؟',
    },
    'mda20mwe': {
      'en': 'Show QR Code (Kitchens)',
      'ar': 'إظهار رمز الاستجابة السريعة (المطابخ)',
    },
    'r44q7eig': {
      'en': 'Report Path',
      'ar': 'مسار التقرير',
    },
    'p33aafx1': {
      'en': 'Input Path URL',
      'ar': 'عنوان URL لمسار الإدخال',
    },
    'k148d7y0': {
      'en': 'Import',
      'ar': 'استيراد',
    },
    '9c7wsfrl': {
      'en': 'Show Auxation Screen ?',
      'ar': 'عرض شاشة المساعدة؟',
    },
    'undg0plr': {
      'en': 'Show Auxation Screen ?',
      'ar': 'عرض شاشة المساعدة؟',
    },
    'y37jrs4r': {
      'en': 'Limit Number',
      'ar': 'رقم الحد',
    },
    '80sgj4mf': {
      'en': '0',
      'ar': '0',
    },
    '0k0r6ic9': {
      'en': 'Reset Counter',
      'ar': 'إعادة تعيين العداد',
    },
    'yj25hab6': {
      'en': 'Period (Minute)',
      'ar': 'الفترة (دقيقة)',
    },
    'r8gmtnmp': {
      'en': '0',
      'ar': '0',
    },
    'tzqzgm24': {
      'en': 'Synchronization',
      'ar': 'التزامن',
    },
    'topbmt00': {
      'en': 'Import',
      'ar': 'استيراد',
    },
    'm5dpzdei': {
      'en': 'Export',
      'ar': 'تصدير',
    },
    'gc3lwm4w': {
      'en': 'Save',
      'ar': 'حفظ',
    },
    'xctk4aji': {
      'en': 'Close',
      'ar': 'إغلاق',
    },
    '677ejlxa': {
      'en': 'Field is required',
      'ar': 'الحقل مطلوب',
    },
    'f52cwcmg': {
      'en': 'Please choose an option from the dropdown',
      'ar': 'يرجى اختيار خيار من القائمة المنسدلة',
    },
    'vrs5e3ew': {
      'en': 'Field is required',
      'ar': 'الحقل مطلوب',
    },
    'mxeixh2p': {
      'en': 'Please choose an option from the dropdown',
      'ar': 'يرجى اختيار خيار من القائمة المنسدلة',
    },
    '2zt7gzq1': {
      'en': 'Format',
      'ar': 'شكل',
    },
    '9qv3an09': {
      'en': 'Header Format',
      'ar': 'تنسيق الرأس',
    },
    '1dp9g7o5': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    '09ibnz9q': {
      'en': 'Font Size',
      'ar': 'حجم الخط',
    },
    'tun6bo6h': {
      'en': '11',
      'ar': '11',
    },
    'u1az3pry': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    '5f7l5gi6': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'zjwawi25': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'qcdj1qyt': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'diliqzqm': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'r382k13j': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'a4hn46sc': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'rh2jikiq': {
      'en': 'Body Format',
      'ar': 'تنسيق الجسم',
    },
    'np5acxs5': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'uqzru9lt': {
      'en': 'Font Size',
      'ar': 'حجم الخط',
    },
    'at3373de': {
      'en': '11',
      'ar': '11',
    },
    '36160ai5': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    'dwnaqim6': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'ds7dqzdq': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'tgvosqrm': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'w05wlhds': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'i5ecpsue': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    '0ibu1got': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    '2f5es9qx': {
      'en': 'Grand Total Format',
      'ar': 'تنسيق المجموع الكلي',
    },
    '7zlpsl8v': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    '3tm371d1': {
      'en': 'Font Size',
      'ar': 'حجم الخط',
    },
    'suymwgw1': {
      'en': '11',
      'ar': '11',
    },
    'pk4fp25r': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    '3vzq6ykh': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    '28lu7nlv': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'qy8ygrnc': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'gtbbhh3p': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'b4yrb9ie': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'bqx5y8xr': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'x977adep': {
      'en': 'Show Kitchen',
      'ar': 'عرض المطبخ',
    },
    'dhops6xj': {
      'en': 'Payment Format',
      'ar': 'تنسيق الدفع',
    },
    '7xsczo88': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'uzybn82g': {
      'en': 'Font Size',
      'ar': 'حجم الخط',
    },
    'kzgw01x8': {
      'en': '11',
      'ar': '11',
    },
    'jobmv3a5': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    'v9nsxdnz': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    '3ly2yjzl': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'ilwrgan0': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'b3sydm3r': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    '724wytqs': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'j24y5911': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'f5wd49uy': {
      'en': 'Show Kitchen',
      'ar': 'عرض المطبخ',
    },
    '2v743ocg': {
      'en': 'Invoice Number Format',
      'ar': 'تنسيق رقم الفاتورة',
    },
    'g5v6i7d4': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    '42tu4rmz': {
      'en': 'Font Size',
      'ar': 'حجم الخط',
    },
    'ejxzitbs': {
      'en': '11',
      'ar': '11',
    },
    'squip5um': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    'vq38iwka': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'j5hswiv2': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'pzoraemc': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    '5kjpkhig': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'zm3sv51h': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'odrl1a2n': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'cfhlkhgj': {
      'en': 'Price Format',
      'ar': 'تنسيق السعر',
    },
    'p6nffvyg': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'happbbda': {
      'en': 'Font Size',
      'ar': 'حجم الخط',
    },
    'ui1nk6js': {
      'en': '11',
      'ar': '11',
    },
    'djg7qtaq': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    'vglyfhiy': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    '8ua8hyf9': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'xtkgb1bb': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'kiixvuzi': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    '3zd1v4mn': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    '6is9tws0': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'duw4yw10': {
      'en': 'Show Kitchen',
      'ar': 'عرض المطبخ',
    },
    '67k725ic': {
      'en': 'Total Format',
      'ar': 'التنسيق الإجمالي',
    },
    '1eoglv0k': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'fnw1m02j': {
      'en': 'Font Size',
      'ar': 'حجم الخط',
    },
    'hj8b2nu1': {
      'en': '11',
      'ar': '11',
    },
    '20j2mbaf': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    '9ii93vj6': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'e9t3vd3y': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'pbp70gtd': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'n66gzqrh': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'w3kkqwqs': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'dedl3lx7': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'ax6zzjly': {
      'en': 'Import',
      'ar': 'استيراد',
    },
    '05vmno6y': {
      'en': 'Export',
      'ar': 'تصدير',
    },
    'efziiag0': {
      'en': 'Save',
      'ar': 'حفظ',
    },
    'n6qnnkyv': {
      'en': 'Close',
      'ar': 'إغلاق',
    },
    '8nbxg9yf': {
      'en': 'Field is required',
      'ar': 'الحقل مطلوب',
    },
    '8e0qr48o': {
      'en': 'Please choose an option from the dropdown',
      'ar': 'يرجى اختيار خيار من القائمة المنسدلة',
    },
    'ytkc1fry': {
      'en': 'Field is required',
      'ar': 'الحقل مطلوب',
    },
    '7z82ypgd': {
      'en': 'Please choose an option from the dropdown',
      'ar': 'يرجى اختيار خيار من القائمة المنسدلة',
    },
    'ex2ww8pa': {
      'en': 'Header',
      'ar': 'رأس',
    },
    'esuck3b0': {
      'en': 'Header (P) Format',
      'ar': 'تنسيق الرأس (P).',
    },
    'oguebrfn': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'l1usnlw3': {
      'en': 'Header (P)',
      'ar': 'رأس (ف)',
    },
    'huqmxy66': {
      'en': 'Font Size Header P',
      'ar': 'حجم الخط، الرأس P',
    },
    '4wk6h82g': {
      'en': '11',
      'ar': '11',
    },
    'q0dnrmv6': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    'ope6q30f': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'b6mmer6c': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'k1da2n5w': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'lbf46hoe': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'm6xon3oo': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    '8j6szccr': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'mbitk9v3': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'ltz5evim': {
      'en': 'Header (1) Format',
      'ar': 'رأس (1) الشكل',
    },
    'qm85s7am': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    '839u9q98': {
      'en': 'Header (1)',
      'ar': 'رأس (1)',
    },
    'ojpat5ns': {
      'en': 'Font Size Header 1',
      'ar': 'رأس حجم الخط 1',
    },
    'o8lf25fz': {
      'en': '11',
      'ar': '11',
    },
    '6ifj6enp': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    'dqq9j6oy': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    '9cnqgj0q': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'fqb8eqxr': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'jt84i4p9': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'l50qzb45': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'bopayhtc': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'ar5j1m0w': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'z5kl7mi9': {
      'en': 'Header (2) Format',
      'ar': 'رأس (2) الشكل',
    },
    'ka11o0nl': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    '6jzbmggt': {
      'en': 'Header (2)',
      'ar': 'رأس (2)',
    },
    'y2fyn432': {
      'en': 'Font Size Header 2',
      'ar': 'حجم الخط 2',
    },
    'p2zttrnq': {
      'en': '11',
      'ar': '11',
    },
    '6qdssnkx': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    '7zc1tw3h': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'vlfiwc2l': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'bkoyaejc': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'ekaeqoaa': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    '2fruw3iq': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'ktopaiyz': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'fewgwea0': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'xy36u86o': {
      'en': 'Header (3) Format',
      'ar': 'رأس (3) الشكل',
    },
    'ytp4aur0': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    '3nrt67im': {
      'en': 'Header (3)',
      'ar': 'رأس (3)',
    },
    'snihz3l4': {
      'en': 'Font Size Header 3',
      'ar': 'حجم الخط 3',
    },
    'w262iekx': {
      'en': '11',
      'ar': '11',
    },
    '2fvi286t': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    '858cdvn1': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'm6k7dfut': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'p097g2l7': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'lxd7smfd': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'kkx71sqv': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'fss6qr9v': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'gnpii1hb': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'da2hb5ug': {
      'en': 'Header (4) Format',
      'ar': 'رأس (4) الشكل',
    },
    '42sghonb': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    '35wp3xtn': {
      'en': 'Header (4)',
      'ar': 'رأس (4)',
    },
    'qvbxk177': {
      'en': 'Font Size Header 4',
      'ar': 'حجم الخط 4',
    },
    'ff5fa5tr': {
      'en': '11',
      'ar': '11',
    },
    '0odh10di': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    'uk3pperx': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    're32xdxe': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'znxwydyp': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    '6w7sp91p': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'dx5lldzv': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'z5nih19s': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'mtcned50': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'ktxib0az': {
      'en': 'Header (5) Format',
      'ar': 'رأس (5) الشكل',
    },
    'fmw1zcsv': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    '8h5zz7j5': {
      'en': 'Header (5)',
      'ar': 'رأس (5)',
    },
    'zey0nu9i': {
      'en': 'Font Size Header 5',
      'ar': 'حجم الخط 5',
    },
    'ftlzcf13': {
      'en': '11',
      'ar': '11',
    },
    'xi9ee7kn': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    'egzkhh41': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'huok9bpq': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'f5uhegle': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'taufjlvg': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    '4q9lcmlc': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'fdatwf23': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'we8tde44': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'bdhufjkq': {
      'en': 'Header (6) Format',
      'ar': 'رأس (6) الشكل',
    },
    'zhmp3eiz': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'ec851d0w': {
      'en': 'Header (6)',
      'ar': 'رأس (6)',
    },
    'rg3fqmxn': {
      'en': 'Font Size Header 6',
      'ar': 'حجم الخط 6',
    },
    'if1pp8sm': {
      'en': '11',
      'ar': '11',
    },
    'uy2wgzv6': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    '2kgiohuo': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'yzfg3175': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'pfnrwlwd': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'yjxm3oue': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'r0m1ph5c': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'z5iola8g': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    '7vtic5nw': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    '5e195mfu': {
      'en': 'Header (7) Format',
      'ar': 'رأس (7) الشكل',
    },
    'v94dp83p': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'd8e7be7v': {
      'en': 'Header (7)',
      'ar': 'رأس (7)',
    },
    'edfxtx9o': {
      'en': 'Font Size Header 7',
      'ar': 'حجم الخط 7',
    },
    'lxkrfipd': {
      'en': '11',
      'ar': '11',
    },
    '9dnscua5': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    '9yikkws6': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'intadk0j': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    '0n6jol2b': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'ys8jsieg': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    't4eztgbh': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    '9zs0ilqc': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'wowmxfva': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'y9suz8sh': {
      'en': 'Header (8) Format',
      'ar': 'رأس (8) الشكل',
    },
    'idd74vxw': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'r143zu6t': {
      'en': 'Header (8)',
      'ar': 'رأس (8)',
    },
    '654fkl8e': {
      'en': 'Font Size Header 8',
      'ar': 'حجم الخط 8',
    },
    'fg08fqce': {
      'en': '11',
      'ar': '11',
    },
    'wuhysqzy': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    'wpz1b86e': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'g9lymi1c': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'imb3pjww': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'o4irqub2': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    't48650wy': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'jn3lduln': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'q0yccq3e': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    '2w79hl24': {
      'en': 'Header (9) Format',
      'ar': 'رأس (9) الشكل',
    },
    'jebupca8': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'pbh03rhp': {
      'en': 'Header (9)',
      'ar': 'رأس (9)',
    },
    'zip00kyg': {
      'en': 'Font Size Header 9',
      'ar': 'حجم الخط 9',
    },
    'v82uz1yn': {
      'en': '11',
      'ar': '11',
    },
    'otds242d': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    '5beyg453': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'al9zu1np': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'd4hmlugy': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'fcpmv8ni': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'i4n71jvc': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    '7yv5955z': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'sxnrb62h': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'f6tgc3oj': {
      'en': 'Header (10) Format',
      'ar': 'رأس (10) الشكل',
    },
    'xpcskd8f': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'fmff0iv5': {
      'en': 'Header (10)',
      'ar': 'رأس (10)',
    },
    'p11dquvy': {
      'en': 'Font Size Header 10',
      'ar': 'حجم الخط 10',
    },
    'sq3cu800': {
      'en': '11',
      'ar': '11',
    },
    'o9zvh0ui': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    '1xap8k1e': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'o0g4e4s7': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'jhntalzt': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'kawdkdc9': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'a1px93y1': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'w0lliztt': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'mffumt6o': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    '1z9czbyn': {
      'en': 'Header (11) Format',
      'ar': 'رأس (11) الشكل',
    },
    'g97ccm6z': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'hshzoj0z': {
      'en': 'Header (11)',
      'ar': 'رأس (11)',
    },
    'o0bc13l5': {
      'en': 'Font Size Header 11',
      'ar': 'حجم الخط 11',
    },
    '90695s9v': {
      'en': '11',
      'ar': '11',
    },
    'spzzf7pb': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    'hj1wxd7m': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'k9qvafbs': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    '5tj93720': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'kxkex6yw': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'tx6f9v12': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'mfy6erfd': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'w7v4hbcj': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    '33e9oeg6': {
      'en': 'Header (12) Format',
      'ar': 'رأس (12) الشكل',
    },
    '8kw6b6nb': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'mmtpz76b': {
      'en': 'Header (12)',
      'ar': 'رأس (12)',
    },
    'tw1tlps5': {
      'en': 'Font Size Header 12',
      'ar': 'حجم الخط 12',
    },
    'k5tty6aq': {
      'en': '11',
      'ar': '11',
    },
    '005guiog': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    'j2qo5wc6': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    '09jrel76': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'aq7s02q8': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    '92g55al2': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    '97d9w7f5': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'xs2l960u': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'p8m42e3e': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    '03sifjj9': {
      'en': 'Header (13) Format',
      'ar': 'رأس (13) الشكل',
    },
    '914ertf0': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'hiuyo7us': {
      'en': 'Header (13)',
      'ar': 'رأس (13)',
    },
    '9ehregw7': {
      'en': 'Font Size Header 13',
      'ar': 'حجم الخط 13',
    },
    'kszowqd2': {
      'en': '11',
      'ar': '11',
    },
    'iax3p378': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    'mr883pi2': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    '575uq0xz': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'vfbaqwvs': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'yvpn9cej': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'l5l2w50w': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    '4r5lz50q': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'ek5onx4z': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'rx57hrk9': {
      'en': 'Header (14) Format',
      'ar': 'رأس (14) الشكل',
    },
    'hjrbivui': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'yctjmb8k': {
      'en': 'Header (14)',
      'ar': 'رأس (14)',
    },
    'pv8ox9l5': {
      'en': 'Font Size Header 14',
      'ar': 'حجم الخط 14',
    },
    'xr9x6j85': {
      'en': '11',
      'ar': '11',
    },
    '3a5nxwi4': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    'tpgmr3bv': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'qg24se65': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    '4nlzshkt': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'uu853vaq': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'mptmzx9a': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'b2tdqj2z': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    '1859d4gh': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'b6r1wqwp': {
      'en': 'Import',
      'ar': 'يستورد',
    },
    'u3g2evx2': {
      'en': 'Export',
      'ar': 'يصدّر',
    },
    'frgcjl0m': {
      'en': 'Save',
      'ar': 'يحفظ',
    },
    'f9pkmi3y': {
      'en': 'Close',
      'ar': 'يغلق',
    },
    'l18m68da': {
      'en': 'Field is required',
      'ar': 'الحقل مطلوب',
    },
    'fhgegefs': {
      'en': 'Please choose an option from the dropdown',
      'ar': 'يرجى اختيار خيار من القائمة المنسدلة',
    },
    '6aaj64fk': {
      'en': 'Field is required',
      'ar': 'الحقل مطلوب',
    },
    '8j20gcaw': {
      'en': 'Please choose an option from the dropdown',
      'ar': 'يرجى اختيار خيار من القائمة المنسدلة',
    },
    'jnm1gs9q': {
      'en': 'Footer',
      'ar': 'تذييل',
    },
    'thnqxuci': {
      'en': 'Footer (P) Format',
      'ar': 'تنسيق التذييل (P).',
    },
    'irqtvkff': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    '0q2ilqns': {
      'en': 'Footer (P)',
      'ar': 'تذييل (ع)',
    },
    'b25p95z8': {
      'en': 'Font Size Footer P',
      'ar': 'حجم الخط تذييل الصفحة P',
    },
    'nzj5w4wb': {
      'en': '11',
      'ar': '11',
    },
    'kxos7unm': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    'ceh2wedb': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'tnvzfxkn': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    '7coc97ay': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    '4lgcneur': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'g3tllbqg': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'kqs7yfvx': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'v1m25hr8': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'aw98mdxm': {
      'en': 'Footer (1) Format',
      'ar': 'تذييل (1) تنسيق',
    },
    't2v0mbkc': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    '70kkebe5': {
      'en': 'Footer (1)',
      'ar': 'تذييل الصفحة (1)',
    },
    '4wz1gl7v': {
      'en': 'Font Size Footer 1',
      'ar': 'حجم الخط التذييل 1',
    },
    '0wovnlrb': {
      'en': '11',
      'ar': '11',
    },
    'j43iqnuw': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    'd943agtw': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'udra9fp6': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'czqhyagb': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'k9lex1jq': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'sdl7done': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    '5powhwxy': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    '1sqlsn7d': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    's4mokcf5': {
      'en': 'Footer (2) Format',
      'ar': 'تنسيق التذييل (2).',
    },
    '2o8jo7jf': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'y64fdc9s': {
      'en': 'Footer (2)',
      'ar': 'تذييل الصفحة (2)',
    },
    'rejmnbls': {
      'en': 'Font Size Footer 2',
      'ar': 'حجم الخط التذييل 2',
    },
    '113wabi7': {
      'en': '11',
      'ar': '11',
    },
    'etxsb26j': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    'v7mrl2px': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'gioigacq': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    '32bk5zx6': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'btf1ilrx': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'zd8e82ic': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    's64ri2fa': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'g750atnx': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'ble95om0': {
      'en': 'Footer (3) Format',
      'ar': 'تذييل (3) تنسيق',
    },
    '4shjx4wk': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'k6i7211p': {
      'en': 'Footer (3)',
      'ar': 'تذييل الصفحة (3)',
    },
    'iropebc8': {
      'en': 'Font Size Footer 3',
      'ar': 'حجم الخط 3',
    },
    'm675edsf': {
      'en': '11',
      'ar': '11',
    },
    'lms5yoal': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    'ta9mnpzo': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'v68ehqhf': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'ofwc76i0': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'frzhgxly': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'i1lt41or': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'r75om4oc': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    '8wl127d1': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'v62838cz': {
      'en': 'Footer (4) Format',
      'ar': 'تذييل (4) تنسيق',
    },
    'hnu9n7hu': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'idibi8yl': {
      'en': 'Footer (4)',
      'ar': 'تذييل الصفحة (4)',
    },
    'voozw7p8': {
      'en': 'Font Size Footer 4',
      'ar': 'حجم الخط 4',
    },
    'u4s3fdkb': {
      'en': '11',
      'ar': '11',
    },
    'cz744msj': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    '9ncdhvfu': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    '1wixiq9l': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'be5d9swk': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    '1cudykdx': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'lvf6cg18': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'rjxfxv8v': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'kh4ohh52': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'tf5rorx9': {
      'en': 'Footer (5) Format',
      'ar': 'تذييل (5) تنسيق',
    },
    'dn5fqk3i': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    '15wsvvfp': {
      'en': 'Footer (5)',
      'ar': 'تذييل الصفحة (5)',
    },
    'zy56msn2': {
      'en': 'Font Size Footer 5',
      'ar': 'حجم الخط 5',
    },
    'xoero5km': {
      'en': '11',
      'ar': '11',
    },
    'axw8cznp': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    '8iy85ve1': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'evnzlpsi': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'qpa9gqon': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    '726b79bf': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'sjfz4roo': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'eih6m2d4': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'x9two5t0': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    '5dzt6e6m': {
      'en': 'Footer (6) Format',
      'ar': 'تذييل (6) تنسيق',
    },
    'yavn5ybe': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'z9sajej7': {
      'en': 'Footer (6)',
      'ar': 'تذييل الصفحة (6)',
    },
    '2sg0rj43': {
      'en': 'Font Size Footer 6',
      'ar': 'حجم الخط 6',
    },
    'l7nxf37o': {
      'en': '11',
      'ar': '11',
    },
    'felrh7if': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    '1ifwg1m1': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'cky9o2dv': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'e0zylhvy': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'f49tcxoy': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'l3gw1rl1': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'n265ku2h': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    '9rwxhdit': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'zohqvcxr': {
      'en': 'Footer (7) Format',
      'ar': 'تذييل (7) الشكل',
    },
    '4i63xprs': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'ewgly7z5': {
      'en': 'Footer (7)',
      'ar': 'تذييل الصفحة (7)',
    },
    'ku8qwm57': {
      'en': 'Font Size Footer 7',
      'ar': 'حجم الخط 7',
    },
    'g7hp6y9q': {
      'en': '11',
      'ar': '11',
    },
    'fmeqeytj': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    'igt89zos': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    '3kq2ylpk': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'y4qvrzkq': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    '9jjix04d': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'jz8gpiwo': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'i39bybbu': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'mar4os84': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    '34agqs6m': {
      'en': 'Footer (8) Format',
      'ar': 'تنسيق التذييل (8).',
    },
    'lmfaau0j': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'r3bl28gg': {
      'en': 'Footer (8)',
      'ar': 'تذييل الصفحة (8)',
    },
    '5aj8cwtd': {
      'en': 'Font Size Footer 8',
      'ar': 'حجم الخط 8',
    },
    'zn3i6d5e': {
      'en': '11',
      'ar': '11',
    },
    '2737j6qs': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    '2pgee2hx': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'neveg2sa': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'ux09eeo4': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    '1486a8g0': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'co5t9lr2': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'uyp6ls85': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    '3waukkej': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'ijaprg8u': {
      'en': 'Footer (9) Format',
      'ar': 'تذييل (9) تنسيق',
    },
    '7atkmxbk': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'jw7twopk': {
      'en': 'Footer (9)',
      'ar': 'تذييل الصفحة (9)',
    },
    '1gxwzenm': {
      'en': 'Font Size Footer 9',
      'ar': 'حجم الخط 9',
    },
    'qhaz4xyi': {
      'en': '11',
      'ar': '11',
    },
    'nnjeyhtv': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    'pe5cc05a': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    '3r2qnitq': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    '7fggh6gz': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'ugbn5nik': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'e8m4mtja': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'wq7scgfm': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'ro58cykr': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'zsozjq18': {
      'en': 'Footer (10) Format',
      'ar': 'تذييل (10) تنسيق',
    },
    'gkt8ev3g': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'oq6i5n0a': {
      'en': 'Footer (10)',
      'ar': 'تذييل الصفحة (10)',
    },
    'qib9osqy': {
      'en': 'Font Size Footer 10',
      'ar': 'حجم الخط 10',
    },
    'n70kheq7': {
      'en': '11',
      'ar': '11',
    },
    'o16w4xmd': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    'maqvkfxd': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    '0jv02sso': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    '1a6jfpgt': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'nwhptyj1': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'c2szsphi': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'w9msoi6t': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'wtg6zwmo': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'trs550dx': {
      'en': 'Footer (11) Format',
      'ar': 'تذييل (11) تنسيق',
    },
    'g64xi8u7': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'kf7pyvwi': {
      'en': 'Footer (11)',
      'ar': 'تذييل الصفحة (11)',
    },
    'fqblmz1g': {
      'en': 'Font Size Footer 11',
      'ar': 'حجم الخط 11',
    },
    'md0s06by': {
      'en': '11',
      'ar': '11',
    },
    'u3u004zd': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    'w1qje7si': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'uhio263l': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'c0wxj8w1': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'hxbhttdn': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    '1t4ckv00': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'h2lowfwo': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'k54fb98x': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'i6onunfh': {
      'en': 'Footer (12) Format',
      'ar': 'تذييل (12) تنسيق',
    },
    'va6xbzvg': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'ivtgzlso': {
      'en': 'Footer (12)',
      'ar': 'تذييل الصفحة (12)',
    },
    'c3e5392w': {
      'en': 'Font Size Footer 12',
      'ar': 'حجم الخط 12',
    },
    '1krg7i8y': {
      'en': '11',
      'ar': '11',
    },
    '02fpp5g4': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    'lexvio37': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    '848x8pln': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    '79jfbcw6': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'afad1stf': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'zsckdeg1': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'ara9c9o0': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'ais32fty': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'j9a74cu1': {
      'en': 'Footer (13) Format',
      'ar': 'تذييل (13) تنسيق',
    },
    'ep0j3p69': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    'rxaezt9z': {
      'en': 'Footer (13)',
      'ar': 'تذييل الصفحة (13)',
    },
    'm69q99wh': {
      'en': 'Font Size Footer 13',
      'ar': 'حجم الخط 13',
    },
    '7micpbff': {
      'en': '11',
      'ar': '11',
    },
    '1z9d96gp': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    'f9nxc4ce': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'jn61lon2': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'zz9v5tu5': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'to6c8g4w': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'thywz4hd': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'iy2yzhjd': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'unyfn9j2': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'ctq12cyw': {
      'en': 'Footer (14) Format',
      'ar': 'تذييل (14) تنسيق',
    },
    'i128b6mo': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    '7p4rj9ye': {
      'en': 'Footer (14)',
      'ar': 'تذييل الصفحة (14)',
    },
    'nrymw5l7': {
      'en': 'Font Size Footer 14',
      'ar': 'حجم الخط 14',
    },
    '7hk55ihf': {
      'en': '11',
      'ar': '11',
    },
    'x1g8b238': {
      'en': 'Font Family',
      'ar': 'خط العائلة',
    },
    '4mk5r0fd': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'stethku0': {
      'en': 'Arial',
      'ar': 'اريال',
    },
    'n2a771tj': {
      'en': 'Arial Black',
      'ar': 'ارييل الأسود',
    },
    'flmlbdk7': {
      'en': 'Bahnschrift',
      'ar': 'باهنتشريفت',
    },
    'bgqurkdw': {
      'en': 'Please select Font...',
      'ar': 'الرجاء تحديد الخط...',
    },
    'dxkk2hif': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    '013425g3': {
      'en': 'Is Bold',
      'ar': 'جريئة',
    },
    'jd9m3m84': {
      'en': 'Import',
      'ar': 'يستورد',
    },
    'amoj5pt4': {
      'en': 'Export',
      'ar': 'يصدّر',
    },
    'ro4yrspk': {
      'en': 'Save',
      'ar': 'يحفظ',
    },
    'qajhr59x': {
      'en': 'Close',
      'ar': 'يغلق',
    },
    '7nxn6mk7': {
      'en': 'Field is required',
      'ar': 'الحقل مطلوب',
    },
    '6epb6u6v': {
      'en': 'Please choose an option from the dropdown',
      'ar': 'يرجى اختيار خيار من القائمة المنسدلة',
    },
    'fhd4io7e': {
      'en': 'Field is required',
      'ar': 'الحقل مطلوب',
    },
    '8t58qjgp': {
      'en': 'Please choose an option from the dropdown',
      'ar': 'يرجى اختيار خيار من القائمة المنسدلة',
    },
    'qv3q3as7': {
      'en': 'Issues',
      'ar': 'مشاكل',
    },
    'ra91tb6o': {
      'en': 'Issues',
      'ar': 'مشاكل',
    },
    'a3qnope4': {
      'en': '13',
      'ar': '13',
    },
    'ui28el4u': {
      'en': 'Filter',
      'ar': 'منقي',
    },
    'r4nr1lxy': {
      'en': 'Search users...',
      'ar': 'البحث عن المستخدمين...',
    },
    '6v87kuq1': {
      'en': 'Exception',
      'ar': 'استثناء',
    },
    'zk19v6lx': {
      'en': 'Date',
      'ar': 'تاريخ',
    },
    'g1f1l01e': {
      'en': 'Class',
      'ar': 'فصل',
    },
    'f53017en': {
      'en': 'Object reference not set to an instance of an object',
      'ar': 'مرجع كائن لم يتم تعيين إلى مثيل كائن',
    },
    'zfitol26': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    '605757kd': {
      'en': 'FAB.Views.ItemAvailable',
      'ar': 'FAB.Views.ItemAvailable',
    },
    'l9t31r1x': {
      'en': 'Object reference not set to an instance of an object',
      'ar': 'مرجع كائن لم يتم تعيين إلى مثيل كائن',
    },
    'd711f2jt': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    'w7rasgls': {
      'en': 'FAB.Views.ItemAvailable',
      'ar': 'FAB.Views.ItemAvailable',
    },
    '9m4jats0': {
      'en': 'Object reference not set to an instance of an object',
      'ar': 'مرجع كائن لم يتم تعيين إلى مثيل كائن',
    },
    'vpfqmbc3': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    'm3ofhoe6': {
      'en': 'FAB.Views.ItemAvailable',
      'ar': 'FAB.Views.ItemAvailable',
    },
    'qat7j0nk': {
      'en': 'Object reference not set to an instance of an object',
      'ar': 'مرجع كائن لم يتم تعيين إلى مثيل كائن',
    },
    '5iq8k2o5': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    'usulyujs': {
      'en': 'FAB.Views.ItemAvailable',
      'ar': 'FAB.Views.ItemAvailable',
    },
    '13temxx6': {
      'en': 'Object reference not set to an instance of an object',
      'ar': 'مرجع كائن لم يتم تعيين إلى مثيل كائن',
    },
    'y7l5tjin': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    '5wcx2ms4': {
      'en': 'FAB.Views.ItemAvailable',
      'ar': 'FAB.Views.ItemAvailable',
    },
    'aiepmbcc': {
      'en': 'Object reference not set to an instance of an object',
      'ar': 'مرجع كائن لم يتم تعيين إلى مثيل كائن',
    },
    'v23ewwxv': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    'bndwn4s7': {
      'en': 'FAB.Views.ItemAvailable',
      'ar': 'FAB.Views.ItemAvailable',
    },
    'brmj2ydr': {
      'en': 'Object reference not set to an instance of an object',
      'ar': 'مرجع كائن لم يتم تعيين إلى مثيل كائن',
    },
    'dmw7o3x8': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    'n6rfj8m7': {
      'en': 'FAB.Views.ItemAvailable',
      'ar': 'FAB.Views.ItemAvailable',
    },
    'r57722j9': {
      'en': 'Object reference not set to an instance of an object',
      'ar': 'مرجع كائن لم يتم تعيين إلى مثيل كائن',
    },
    'x07e43f9': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    'fvyq8gqf': {
      'en': 'FAB.Views.ItemAvailable',
      'ar': 'FAB.Views.ItemAvailable',
    },
    'fmqbgite': {
      'en': 'Object reference not set to an instance of an object',
      'ar': 'مرجع كائن لم يتم تعيين إلى مثيل كائن',
    },
    'lr05b0af': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    'f4y4k0yt': {
      'en': 'FAB.Views.ItemAvailable',
      'ar': 'FAB.Views.ItemAvailable',
    },
    'sh6r5ld7': {
      'en': 'Object reference not set to an instance of an object',
      'ar': 'مرجع كائن لم يتم تعيين إلى مثيل كائن',
    },
    'kvzg26hp': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    '02q5oow8': {
      'en': 'FAB.Views.ItemAvailable',
      'ar': 'FAB.Views.ItemAvailable',
    },
    'i33jrkxe': {
      'en': 'Object reference not set to an instance of an object',
      'ar': 'مرجع كائن لم يتم تعيين إلى مثيل كائن',
    },
    '6f5lggyl': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    '0lnuosh1': {
      'en': 'FAB.Views.ItemAvailable',
      'ar': 'FAB.Views.ItemAvailable',
    },
    '3597alp4': {
      'en': 'Object reference not set to an instance of an object',
      'ar': 'مرجع كائن لم يتم تعيين إلى مثيل كائن',
    },
    'wz846kb8': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    'b9v1bzxu': {
      'en': 'FAB.Views.ItemAvailable',
      'ar': 'FAB.Views.ItemAvailable',
    },
    'lr85rgk7': {
      'en': 'Object reference not set to an instance of an object',
      'ar': 'مرجع كائن لم يتم تعيين إلى مثيل كائن',
    },
    '91dfqsf4': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    's0fsz2ch': {
      'en': 'FAB.Views.ItemAvailable',
      'ar': 'FAB.Views.ItemAvailable',
    },
    'hs9hu6zk': {
      'en': 'Object reference not set to an instance of an object',
      'ar': 'مرجع كائن لم يتم تعيين إلى مثيل كائن',
    },
    '805g9ist': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    'cp1nluah': {
      'en': 'FAB.Views.ItemAvailable',
      'ar': 'FAB.Views.ItemAvailable',
    },
    'vctpl6um': {
      'en': 'Object reference not set to an instance of an object',
      'ar': 'مرجع كائن لم يتم تعيين إلى مثيل كائن',
    },
    'mutktss6': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    'avjtd4c5': {
      'en': 'FAB.Views.ItemAvailable',
      'ar': 'FAB.Views.ItemAvailable',
    },
    'kch9vae2': {
      'en': 'Import',
      'ar': 'يستورد',
    },
    'wdb9kzbg': {
      'en': 'Export',
      'ar': 'تصدير',
    },
    'xv642u29': {
      'en': 'Save',
      'ar': 'حفظ',
    },
    '0wr3fws1': {
      'en': 'Close',
      'ar': 'إغلاق',
    },
    'caa1ces2': {
      'en': 'Field is required',
      'ar': 'الحقل مطلوب',
    },
    'pjsnp2gl': {
      'en': 'Please choose an option from the dropdown',
      'ar': 'يرجى اختيار خيار من القائمة المنسدلة',
    },
    'qhocu9mv': {
      'en': 'Field is required',
      'ar': 'الحقل مطلوب',
    },
    '5thq8r9z': {
      'en': 'Please choose an option from the dropdown',
      'ar': 'يرجى اختيار خيار من القائمة المنسدلة',
    },
    'r27ncyan': {
      'en': 'Module',
      'ar': 'وحدة',
    },
    'fuqmahoo': {
      'en': 'Module',
      'ar': 'وحدة',
    },
    'jsguubom': {
      'en': '15',
      'ar': '15',
    },
    'anuhcs5z': {
      'en': 'Filter',
      'ar': 'تصفية',
    },
    'grj5c3u1': {
      'en': 'Search users...',
      'ar': 'البحث عن المستخدمين...',
    },
    'w4v6o3hn': {
      'en': 'Module Name',
      'ar': 'اسم وحدة',
    },
    'btinzunw': {
      'en': 'Date',
      'ar': 'التاريخ',
    },
    'pvon4qh5': {
      'en': 'Period',
      'ar': 'فترة',
    },
    'zxlezz40': {
      'en': 'Exception is Done',
      'ar': 'تم الاستثناء',
    },
    'hiic3k7p': {
      'en': 'CustomerAddress',
      'ar': 'عنوان العميل',
    },
    '52m9jorz': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    '8un7wbh0': {
      'en': '340.012',
      'ar': '340.012',
    },
    'ijbdxjif': {
      'en': 'True',
      'ar': 'صحيح',
    },
    '0aeno2kc': {
      'en': 'CustomerAddress',
      'ar': 'عنوان العميل',
    },
    'ju2uww8z': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    'cfhmszr0': {
      'en': '0.0000',
      'ar': '0.0000',
    },
    'wsckxkqc': {
      'en': 'True',
      'ar': 'صحيح',
    },
    'u76g9mwq': {
      'en': 'CustomerAddress',
      'ar': 'عنوان العميل',
    },
    'kt0913qr': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    'q0cdmbcj': {
      'en': '0.0000',
      'ar': '0.0000',
    },
    'wpcewiyh': {
      'en': 'True',
      'ar': 'صحيح',
    },
    '7plwtxam': {
      'en': 'CustomerAddress',
      'ar': 'عنوان العميل',
    },
    '8fhwdr9j': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    'p1m52nj4': {
      'en': '0.0000',
      'ar': '0.0000',
    },
    'q8j47big': {
      'en': 'True',
      'ar': 'صحيح',
    },
    'u4hv9foo': {
      'en': 'CustomerAddress',
      'ar': 'عنوان العميل',
    },
    'hgnaur54': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    'diesuxmb': {
      'en': '0.0000',
      'ar': '0.0000',
    },
    't5dtbyvk': {
      'en': 'True',
      'ar': 'صحيح',
    },
    '7fpfbubc': {
      'en': 'CustomerAddress',
      'ar': 'عنوان العميل',
    },
    'zghkcoru': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    'g72tbdq2': {
      'en': '0.0000',
      'ar': '0.0000',
    },
    '51uvqqhd': {
      'en': 'True',
      'ar': 'صحيح',
    },
    '5jhzxvxk': {
      'en': 'CustomerAddress',
      'ar': 'عنوان العميل',
    },
    'a9ikck89': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    'dxap3vcc': {
      'en': '0.0000',
      'ar': '0.0000',
    },
    'im7w8vq6': {
      'en': 'True',
      'ar': 'صحيح',
    },
    'yhpr3djb': {
      'en': 'CustomerAddress',
      'ar': 'عنوان العميل',
    },
    'y7s00dum': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    'n526oi1n': {
      'en': '0.0000',
      'ar': '0.0000',
    },
    '7726t0y1': {
      'en': 'True',
      'ar': 'صحيح',
    },
    'cre50lhn': {
      'en': 'CustomerAddress',
      'ar': 'عنوان العميل',
    },
    'a8jbf9ep': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    'dy9yqiwr': {
      'en': '0.0000',
      'ar': '0.0000',
    },
    'cnpw331z': {
      'en': 'True',
      'ar': 'صحيح',
    },
    'rm0f23go': {
      'en': 'CustomerAddress',
      'ar': 'عنوان العميل',
    },
    'sdc9g4t5': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    'rmxbol2w': {
      'en': '0.0000',
      'ar': '0.0000',
    },
    'w9zyruvm': {
      'en': 'True',
      'ar': 'صحيح',
    },
    'zenwvfgp': {
      'en': 'CustomerAddress',
      'ar': 'عنوان العميل',
    },
    '7hgy73g7': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    'sfaialk5': {
      'en': '0.0000',
      'ar': '0.0000',
    },
    'rv0twa6b': {
      'en': 'True',
      'ar': 'صحيح',
    },
    'c2k5z298': {
      'en': 'CustomerAddress',
      'ar': 'عنوان العميل',
    },
    'oeqr1931': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    'vzr47vay': {
      'en': '0.0000',
      'ar': '0.0000',
    },
    'aimtuedx': {
      'en': 'True',
      'ar': 'صحيح',
    },
    'dvjbfptz': {
      'en': 'CustomerAddress',
      'ar': 'عنوان العميل',
    },
    '506c7kvu': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    '9ubdhb7e': {
      'en': '0.0000',
      'ar': '0.0000',
    },
    'frsi8xi2': {
      'en': 'True',
      'ar': 'صحيح',
    },
    'xu55lltu': {
      'en': 'Customer Address',
      'ar': 'عنوان العميل',
    },
    '8aumzt71': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    'baz0akpe': {
      'en': '0.0000',
      'ar': '0.0000',
    },
    'vb8yxcme': {
      'en': 'True',
      'ar': 'حقيقي',
    },
    'qo99lv9g': {
      'en': 'CustomerAddress',
      'ar': 'عنوان العميل',
    },
    'tofef1yi': {
      'en': '7/20/2023  2:50:36 PM',
      'ar': '20/07/2023 الساعة 2:50:36 مساءً',
    },
    '7rca7ab2': {
      'en': '0.0000',
      'ar': '0.0000',
    },
    '27gsqgc4': {
      'en': 'True',
      'ar': 'صحيح',
    },
    'zh62y36h': {
      'en': 'Import',
      'ar': 'استيراد',
    },
    '1ordo8zo': {
      'en': 'Export',
      'ar': 'تصدير',
    },
    '3jtg5g2h': {
      'en': 'Save',
      'ar': 'حفظ',
    },
    '84jysrmj': {
      'en': 'Close',
      'ar': 'إغلاق',
    },
    'pi4tjny2': {
      'en': 'Field is required',
      'ar': 'الحقل مطلوب',
    },
    'wwy13s7k': {
      'en': 'Please choose an option from the dropdown',
      'ar': 'يرجى اختيار خيار من القائمة المنسدلة',
    },
    'y3v3b2ur': {
      'en': 'Field is required',
      'ar': 'الحقل مطلوب',
    },
    '2ept2alf': {
      'en': 'Please choose an option from the dropdown',
      'ar': 'يرجى اختيار خيار من القائمة المنسدلة',
    },
    '695olsv4': {
      'en': 'Configuration',
      'ar': 'إعدادات',
    },
    'duoepmi4': {
      'en': 'Cashier,',
      'ar': 'أمين الصندوق،',
    },
    'hij2hvg3': {
      'en': 'Osama',
      'ar': 'أسامة',
    },
    '5zb7e9k3': {
      'en': 'Home',
      'ar': 'الرئيسية',
    },
  },
  // Managementlastedit
  {
    'rxq6hp88': {
      'en': 'Osama kuhail',
      'ar': 'أسامة كحيل',
    },
    'hwpp485t': {
      'en': 'Estimated Shift TIme',
      'ar': 'وقت التحول المقدر',
    },
    'ylb56v4c': {
      'en': '8:00am to 4:00pm',
      'ar': '8:00 صباحًا إلى 4:00 مساءً',
    },
    '0ut75x8d': {
      'en': 'Mon 7 August 2023',
      'ar': 'الإثنين 7 أغسطس 2023',
    },
    '1xgivobt': {
      'en': 'Order Summary',
      'ar': 'ملخص الطلب',
    },
    '8us55vh4': {
      'en': 'SAR 250.40',
      'ar': '250.40 ريال سعودي',
    },
    'i2s4vr0d': {
      'en': '(4 Orders)',
      'ar': '(4 الطلبات)',
    },
    'pfm87y5x': {
      'en': 'X Report',
      'ar': 'تقرير X',
    },
    'bmy8fmqp': {
      'en': 'Change Price',
      'ar': 'تغيير السعر',
    },
    'fiz6se6i': {
      'en': 'Delete Invoice',
      'ar': 'حذف الفاتورة',
    },
    'w6q8kaxp': {
      'en': 'End Of Day',
      'ar': 'نهاية يوم',
    },
    'gi5exsuw': {
      'en': 'Edit Invoice',
      'ar': 'تحرير الفاتورة',
    },
    'c5fsohfl': {
      'en': 'Mark as not available',
      'ar': 'وضع علامة على أنها غير متوفرة',
    },
    'hgi6mwr4': {
      'en': 'Item Quantity',
      'ar': 'البند الكمية',
    },
    '174gx1ut': {
      'en': 'Management',
      'ar': 'إدارة',
    },
    'gjedl6ke': {
      'en': 'Cashier,',
      'ar': 'أمين الصندوق،',
    },
    'ogl7tcej': {
      'en': 'Osama',
      'ar': 'أسامة',
    },
    'w77b8fe2': {
      'en': 'Home',
      'ar': 'بيت',
    },
  },
  // DoneItemQuantity
  {
    'por697oy': {
      'en': 'Available Product',
      'ar': 'المنتج المتاح',
    },
    'ps49vu0u': {
      'en': '2 Product',
      'ar': '2 المنتج',
    },
    'avv8oxke': {
      'en': 'Unavailable Product',
      'ar': 'منتج غير متوفر',
    },
    '31ksj7rr': {
      'en': '1 Product',
      'ar': '1 منتج',
    },
    'm1vefbrx': {
      'en': 'Item QTY Table',
      'ar': 'جدول كمية العناصر',
    },
    'h24n4c6n': {
      'en': 'Edit QTY items for products',
      'ar': 'تعديل كمية عناصر  المنتجات',
    },
    '4wlh3irb': {
      'en': 'Search items...',
      'ar': 'البحث عن العناصر...',
    },
    'mhr4hl5a': {
      'en': 'Search',
      'ar': 'بحث',
    },
    '777i31bg': {
      'en': 'ID',
      'ar': 'رقم التعريف',
    },
    'u3gjwdt6': {
      'en': 'Product Name',
      'ar': 'اسم المنتج',
    },
    'p78eqzc7': {
      'en': 'Forced QTY',
      'ar': 'الكمية الاجبارية',
    },
    'qn4q3vdr': {
      'en': 'Expected QTY',
      'ar': 'الكمية المتوقعة',
    },
    '0t68cjj6': {
      'en': 'Status',
      'ar': 'الحالة',
    },
    'pvf2mo35': {
      'en': 'Actions',
      'ar': 'أجراءات',
    },
    'vf0q9sy9': {
      'en': '#2424552',
      'ar': '#2424552',
    },
    'wg2jk76r': {
      'en': 'Randy Peterson',
      'ar': 'راندي بيترسون',
    },
    '1jfr20rq': {
      'en': '1000',
      'ar': '1000',
    },
    'im37d4wr': {
      'en': '1000',
      'ar': '1000',
    },
    '3nupdlx7': {
      'en': 'Available',
      'ar': 'متاح',
    },
    '2knid4l5': {
      'en': '#2424552',
      'ar': '#2424552',
    },
    '5hyguuj0': {
      'en': 'Randy Peterson',
      'ar': 'راندي بيترسون',
    },
    'k3r76a1t': {
      'en': '0',
      'ar': '0',
    },
    'gc9wa9iq': {
      'en': '0',
      'ar': '0',
    },
    'axl9y3pq': {
      'en': 'Unavailable',
      'ar': 'غير متوفر',
    },
    '2o6rn1hx': {
      'en': '#2424552',
      'ar': '#2424552',
    },
    'gzoqv96c': {
      'en': 'Randy Peterson',
      'ar': 'راندي بيترسون',
    },
    'nilcrdxa': {
      'en': '30',
      'ar': '30',
    },
    'wvwe3xcs': {
      'en': '30',
      'ar': '30',
    },
    'hettrkyq': {
      'en': 'Available',
      'ar': 'متاح',
    },
    'j4utmo3s': {
      'en': 'Item Quantity',
      'ar': 'البند الكمية',
    },
    'sx5pkrgh': {
      'en': 'Cashier,',
      'ar': 'أمين الصندوق،',
    },
    'hao61g7a': {
      'en': 'Osama',
      'ar': 'أسامة',
    },
    '50rznv1w': {
      'en': 'Home',
      'ar': 'الرئيسية',
    },
  },
  // Markasnotavailable
  {
    '8ttspcg7': {
      'en': 'Mark as not available ',
      'ar': 'تحديد كغير متوفر',
    },
    '700iwb9s': {
      'en': 'Cashier,',
      'ar': 'أمين الصندوق،',
    },
    'ne1bi9yh': {
      'en': 'Osama',
      'ar': 'أسامة',
    },
    'hl78qtic': {
      'en': 'Nubmer of categories',
      'ar': 'عدد الفئات',
    },
    '70ajh91t': {
      'en': '3 Gategories',
      'ar': '3 بوابات',
    },
    'kcpxfp7x': {
      'en': 'Number of items',
      'ar': 'عدد العناصر',
    },
    'rufr2lrh': {
      'en': '12 Items',
      'ar': '12 عنصر',
    },
    '42twljra': {
      'en': 'Item QTY Table',
      'ar': 'جدول كمية العناصر',
    },
    'uuxwa71q': {
      'en': 'Edit QTY items for products',
      'ar': 'تعديل  كمية عناصر المنتجات',
    },
    'qxdxho5c': {
      'en': 'Search it...',
      'ar': 'البحث عن العناصر...',
    },
    '1jptn4ku': {
      'en': 'Search',
      'ar': 'بحث',
    },
    '31djzslr': {
      'en': 'ID',
      'ar': 'رقم التعريف',
    },
    'uvtnzh6t': {
      'en': 'Product Name',
      'ar': 'اسم المنتج',
    },
    'xouww8w9': {
      'en': 'Status',
      'ar': 'حالة',
    },
    'v4u8ophy': {
      'en': 'Actions',
      'ar': 'أجراءات',
    },
    'xky094pb': {
      'en': '#2424552',
      'ar': '#2424552',
    },
    'catddt14': {
      'en': 'Randy Peterson',
      'ar': 'راندي بيترسون',
    },
    'yvee6hqr': {
      'en': 'Available',
      'ar': 'متاح',
    },
    '0ruebx8i': {
      'en': '#2424552',
      'ar': '#2424552',
    },
    'tor5mjmg': {
      'en': 'Randy Peterson',
      'ar': 'راندي بيترسون',
    },
    'tc99w4zd': {
      'en': 'Unavailable',
      'ar': 'غير متوفره',
    },
    'zq3tpwj2': {
      'en': '#2424552',
      'ar': '#2424552',
    },
    '54tiokgz': {
      'en': 'Randy Peterson',
      'ar': 'راندي بيترسون',
    },
    'm5tis0h8': {
      'en': 'Available',
      'ar': 'متاح',
    },
    '3c2bqda0': {
      'en': 'Home',
      'ar': 'بيت',
    },
  },
  // Editinvoice
  {
    'b0760ovq': {
      'en': 'Edit Invoice',
      'ar': 'تعديل الفاتورة',
    },
    'mm2v4mxt': {
      'en': 'Cashier,',
      'ar': 'أمين الصندوق،',
    },
    'tno47zlo': {
      'en': 'Osama',
      'ar': 'أسامة',
    },
    'cqo6y7zx': {
      'en': 'Invoice',
      'ar': 'فاتورة',
    },
    'q2dwdjf2': {
      'en': '3',
      'ar': '3',
    },
    '00m8xf3t': {
      'en': 'Invoice table in details',
      'ar': 'جدول الفاتورة بالتفاصيل',
    },
    'vi7b5ot9': {
      'en': 'Search items...',
      'ar': 'البحث عن عناصر...',
    },
    '3ctg4k59': {
      'en': 'INVOICE #',
      'ar': 'فاتورة #',
    },
    'd1w62bym': {
      'en': 'DATE',
      'ar': 'التاريخ',
    },
    'zqfiequu': {
      'en': 'TOTAL',
      'ar': 'المجموع',
    },
    '8iydxro0': {
      'en': 'VAT',
      'ar': 'ضريبة القيمة المضافة',
    },
    'v185ikyk': {
      'en': 'STATUS',
      'ar': 'الحالة',
    },
    'ghy1hnid': {
      'en': 'GRAND TOTAL',
      'ar': 'المجموع الكلي',
    },
    'lcnl5vau': {
      'en': '#42925424',
      'ar': '#42925424',
    },
    'izzqynbb': {
      'en': 'Jan. 30th, 2023',
      'ar': '30 يناير 2023',
    },
    'hszntzny': {
      'en': '12:23:47 PM',
      'ar': '12:23:47 مساءً',
    },
    'yo4vrpw1': {
      'en': '42',
      'ar': '42',
    },
    '624bm3pn': {
      'en': '5',
      'ar': '5',
    },
    '47o0y3e9': {
      'en': 'Paid',
      'ar': 'مدفوع',
    },
    '653nebtq': {
      'en': 'SR 47.00',
      'ar': '47.00 ريال سعودي',
    },
    'ajvkfksi': {
      'en': '#42925424',
      'ar': '#42925424',
    },
    'kda9btc1': {
      'en': 'Jan. 30th, 2023',
      'ar': '30 يناير 2023',
    },
    '9xacsir9': {
      'en': '12:23:47 PM',
      'ar': '12:23:47 مساءً',
    },
    'wa79wgl2': {
      'en': '24',
      'ar': '24',
    },
    's5ll8lfv': {
      'en': '24',
      'ar': '24',
    },
    '13dg8u1x': {
      'en': 'Paid',
      'ar': 'مدفوع',
    },
    '2h1isfsw': {
      'en': 'SR 56.98',
      'ar': '56.98 ريال سعودي',
    },
    'i71ahug7': {
      'en': '#42925424',
      'ar': '#42925424',
    },
    'ni8kqmg3': {
      'en': 'Jan. 30th, 2023',
      'ar': '30 يناير 2023',
    },
    'p1yr82tl': {
      'en': '12:23:47 PM',
      'ar': '12:23:47 مساءً',
    },
    'r86js7z5': {
      'en': '24',
      'ar': '24',
    },
    'ddw6iomj': {
      'en': '24',
      'ar': '24',
    },
    'ii9neeyp': {
      'en': 'Paid',
      'ar': 'مدفوع',
    },
    '3td53ryj': {
      'en': 'SR 304.90',
      'ar': '304.90 ريال سعودي',
    },
    'mo57pjl8': {
      'en': 'Receipt',
      'ar': 'إيصال',
    },
    'tf37ae3c': {
      'en': 'Edit receipt item QTY',
      'ar': 'تعديل كمية عنصر الإيصال ',
    },
    'wr682eqk': {
      'en': 'QTY',
      'ar': 'الكمية',
    },
    'bjdvx3xv': {
      'en': 'MENU ITEM',
      'ar': 'عنصر القائمة',
    },
    'vzy884ye': {
      'en': 'DISCOUNT',
      'ar': 'تخفيض',
    },
    'csw9e4cx': {
      'en': 'PRICE',
      'ar': 'سعر',
    },
    '19s1raq0': {
      'en': 'EDIT QTY',
      'ar': 'تحرير الكمية',
    },
    'f61nj9zg': {
      'en': '1',
      'ar': '1',
    },
    'nbzcb0bl': {
      'en': 'ff',
      'ar': 'وما يليها',
    },
    'k18sz9j8': {
      'en': '0',
      'ar': '0',
    },
    'lx014c7j': {
      'en': '8',
      'ar': '8',
    },
    '7kewjfxq': {
      'en': '2',
      'ar': '2',
    },
    'iariegl4': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'dcjv3c49': {
      'en': '0',
      'ar': '0',
    },
    '8p1wsmpe': {
      'en': '8',
      'ar': '8',
    },
    '7d7w1zqq': {
      'en': '2',
      'ar': '2',
    },
    '79gqn7gd': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    's1c1rybr': {
      'en': '0',
      'ar': '0',
    },
    '7n64hsru': {
      'en': '8',
      'ar': '8',
    },
    '6wt2vfgx': {
      'en': '2',
      'ar': '2',
    },
    'kmy0vlwj': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'pf6b9neh': {
      'en': '0',
      'ar': '0',
    },
    '83u0kjju': {
      'en': '8',
      'ar': '8',
    },
    '5qhr0n1w': {
      'en': '2',
      'ar': '2',
    },
    'pw8hi0up': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'u1itlyfg': {
      'en': '0',
      'ar': '0',
    },
    'qpx0pzlo': {
      'en': '8',
      'ar': '8',
    },
    '5avoro1e': {
      'en': '2',
      'ar': '2',
    },
    'emxmxg19': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'pjwt89g2': {
      'en': '0',
      'ar': '0',
    },
    'oyyrwpmq': {
      'en': '8',
      'ar': '8',
    },
    'hmlf65d3': {
      'en': '2',
      'ar': '2',
    },
    's1zypoz9': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'ruzrdazd': {
      'en': '0',
      'ar': '0',
    },
    'ug1iw3k7': {
      'en': '8',
      'ar': '8',
    },
    't2ec6xiz': {
      'en': '2',
      'ar': '2',
    },
    '8k7xjelx': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    '49k05ink': {
      'en': '0',
      'ar': '0',
    },
    'xrv6qg7q': {
      'en': '8',
      'ar': '8',
    },
    'kooauhb1': {
      'en': '2',
      'ar': '2',
    },
    '6n3lb2na': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'uyl8z9d4': {
      'en': '0',
      'ar': '0',
    },
    'l44ig1m4': {
      'en': '8',
      'ar': '8',
    },
    'iiveql48': {
      'en': 'Grant Total & Items',
      'ar': 'إجمالي المنحة وعناصرها',
    },
    '5zpnmahq': {
      'en': 'NUMBER OF ITEMS :',
      'ar': 'عدد العناصر :',
    },
    'v94qky0z': {
      'en': '5',
      'ar': '5',
    },
    '5g41jx65': {
      'en': 'GRANT TOTAL',
      'ar': 'مجموع المنح',
    },
    'x15sbj5g': {
      'en': 'SR 47.00',
      'ar': '47.00 ريال سعودي',
    },
    '6msyj2wm': {
      'en': 'Home',
      'ar': 'بيت',
    },
  },
  // DeleteSaleInvoice
  {
    'f5513b2h': {
      'en': 'Delete Sale Invoice',
      'ar': 'حذف فاتورة البيع',
    },
    'q1v2fv2a': {
      'en': 'Cashier,',
      'ar': 'أمين الصندوق،',
    },
    'ryjvx62p': {
      'en': 'Osama',
      'ar': 'أسامة',
    },
    '37zfoobb': {
      'en': 'Invoice',
      'ar': 'فاتورة',
    },
    'g67wd6bo': {
      'en': '3',
      'ar': '3',
    },
    '9w0faf8u': {
      'en': 'Delete invoice ',
      'ar': 'حذف الفاتورة',
    },
    'coa3g92y': {
      'en': 'Search users...',
      'ar': 'البحث عن المستخدمين...',
    },
    'zlf5uv0v': {
      'en': 'INVOICE #',
      'ar': 'فاتورة #',
    },
    'oq0s1ekv': {
      'en': 'DATE',
      'ar': 'تاريخ',
    },
    '04yteceu': {
      'en': 'TOTAL',
      'ar': 'المجموع',
    },
    'yiyuxz8o': {
      'en': 'VAT',
      'ar': 'ضريبة القيمة المضافة',
    },
    'nzsance3': {
      'en': 'STATUS',
      'ar': 'حالة',
    },
    'kdbxdr1e': {
      'en': 'GRANT TOTAL',
      'ar': 'مجموع المنح',
    },
    'qwcp67ty': {
      'en': 'Delete',
      'ar': 'يمسح',
    },
    '0honu6ny': {
      'en': 'print',
      'ar': 'مطبعة',
    },
    '95n9m3l2': {
      'en': '#42925424',
      'ar': '#42925424',
    },
    'm3liz0ho': {
      'en': 'Jan. 30th, 2023',
      'ar': '30 يناير 2023',
    },
    '4o2ec1q2': {
      'en': '12:23:47 PM',
      'ar': '12:23:47 مساءً',
    },
    'p2s3wmn8': {
      'en': '42',
      'ar': '42',
    },
    '52h85dtt': {
      'en': '5',
      'ar': '5',
    },
    'obgq78r9': {
      'en': 'Paid',
      'ar': 'مدفوع',
    },
    'lx1v7szv': {
      'en': 'SR 47.00',
      'ar': '47.00 ريال سعودي',
    },
    'ghfc5s37': {
      'en': '#42925424',
      'ar': '#42925424',
    },
    'kd85kdqs': {
      'en': 'Jan. 30th, 2023',
      'ar': '30 يناير 2023',
    },
    'r2t1xv4e': {
      'en': '12:23:47 PM',
      'ar': '12:23:47 مساءً',
    },
    'b6gq71hb': {
      'en': '24',
      'ar': '24',
    },
    '7ddon6ll': {
      'en': '24',
      'ar': '24',
    },
    'o0awvu50': {
      'en': 'Paid',
      'ar': 'مدفوع',
    },
    's3q4bx1u': {
      'en': 'SR 56.98',
      'ar': '56.98 ريال سعودي',
    },
    '87un0n7o': {
      'en': '#42925424',
      'ar': '#42925424',
    },
    '3uabmxs8': {
      'en': 'Jan. 30th, 2023',
      'ar': '30 يناير 2023',
    },
    'qbfpxn1n': {
      'en': '12:23:47 PM',
      'ar': '12:23:47 مساءً',
    },
    'qvd6fjqa': {
      'en': '24',
      'ar': '24',
    },
    'xyxdyxxk': {
      'en': '24',
      'ar': '24',
    },
    'grxpjrlp': {
      'en': 'Paid',
      'ar': 'مدفوع',
    },
    'epcfe1f2': {
      'en': 'SR 304.90',
      'ar': '304.90 ريال سعودي',
    },
    'xard9zfi': {
      'en': 'Receipt',
      'ar': 'إيصال',
    },
    '6883hxrc': {
      'en': 'Numbers of items:',
      'ar': 'عدد العناصر:',
    },
    'qhmsqx8e': {
      'en': '9',
      'ar': '9',
    },
    'zybsp2y0': {
      'en': 'Grant total:',
      'ar': 'مجموع المنح:',
    },
    '1uinzeso': {
      'en': 'SR 299.000',
      'ar': '299.000 ريال سعودي',
    },
    '3ak9dzjg': {
      'en': 'QTY',
      'ar': 'الكمية',
    },
    'ym1606k5': {
      'en': 'MENU ITEM',
      'ar': 'عنصر القائمة',
    },
    'qng6t7p3': {
      'en': 'DISCOUNT',
      'ar': 'تخفيض',
    },
    '6fqu1ihb': {
      'en': 'PRICE',
      'ar': 'سعر',
    },
    'kp8hjj7y': {
      'en': 'Delete',
      'ar': 'يمسح',
    },
    '1v38p3x4': {
      'en': '1',
      'ar': '1',
    },
    '4sdpgcv4': {
      'en': 'ff',
      'ar': 'وما يليها',
    },
    'c4s3lud5': {
      'en': '0',
      'ar': '0',
    },
    'uypujgqc': {
      'en': '8',
      'ar': '8',
    },
    'bygtje1q': {
      'en': '2',
      'ar': '2',
    },
    '9ygoygm6': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'gdqfe3yd': {
      'en': '0',
      'ar': '0',
    },
    'jpohkmyg': {
      'en': '8',
      'ar': '8',
    },
    'l45cvp28': {
      'en': '2',
      'ar': '2',
    },
    'ccor3so6': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'udatia1p': {
      'en': '0',
      'ar': '0',
    },
    'bhih0i4a': {
      'en': '8',
      'ar': '8',
    },
    'f7vddysb': {
      'en': '2',
      'ar': '2',
    },
    '0k9s7m1v': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'tx0nli4a': {
      'en': '0',
      'ar': '0',
    },
    'dcwrpx23': {
      'en': '8',
      'ar': '8',
    },
    'd6l0zvw4': {
      'en': '2',
      'ar': '2',
    },
    'm96vhp3d': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    '4dev5cnv': {
      'en': '0',
      'ar': '0',
    },
    'cyhbw62b': {
      'en': '8',
      'ar': '8',
    },
    '7vfcx814': {
      'en': '2',
      'ar': '2',
    },
    'b5npcdij': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'kf6gwzgz': {
      'en': '0',
      'ar': '0',
    },
    'byvi4hn4': {
      'en': '8',
      'ar': '8',
    },
    '3jzxhb7o': {
      'en': '2',
      'ar': '2',
    },
    'o8w6l21k': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    '19l0qljo': {
      'en': '0',
      'ar': '0',
    },
    'ijlu6qjg': {
      'en': '8',
      'ar': '8',
    },
    'z5f1pudv': {
      'en': '2',
      'ar': '2',
    },
    '340meyx0': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'lq2yolwi': {
      'en': '0',
      'ar': '0',
    },
    'cjcaptsl': {
      'en': '8',
      'ar': '8',
    },
    'nb4av0af': {
      'en': '2',
      'ar': '2',
    },
    'jgg9gdxv': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'xfwpy084': {
      'en': '0',
      'ar': '0',
    },
    'q51c9vfd': {
      'en': '8',
      'ar': '8',
    },
    'vn3646kg': {
      'en': 'Home',
      'ar': 'بيت',
    },
  },
  // Home
  {
    'e2ajvrop': {
      'en': 'POSMena  ',
      'ar': 'بوسمينا',
    },
    'bikv83ji': {
      'en': 'Restaurant or cafe Name',
      'ar': 'اسم المطعم أو المقهى',
    },
    'a1269u3n': {
      'en': 'Sale Type',
      'ar': 'نوع البيع',
    },
    'j190om6b': {
      'en': 'Make New Takeaway Order, Online Ordering or Dine In Order',
      'ar': 'قم بإجراء طلب جديد خارجي، محلي  أو  عبر تطبيقات التوصيل ',
    },
    't2vtdl0z': {
      'en': 'Takeaway Order',
      'ar': 'الطلبات  الخارجية',
    },
    '3vepf4dn': {
      'en': 'Takeaway',
      'ar': 'سفري',
    },
    'kx7nmrmi': {
      'en': 'Online Ordering',
      'ar': 'الطلب عبر التطبيقات',
    },
    '5a39zdeu': {
      'en': 'Online',
      'ar': 'متصل',
    },
    't0kenwa9': {
      'en': 'Dine In Order',
      'ar': 'الطلبات المحلية',
    },
    'ptojefok': {
      'en': 'Dine In',
      'ar': 'محلي',
    },
    'p7dvoysq': {
      'en': 'Invoices',
      'ar': 'الفواتير',
    },
    'um1m5m6p': {
      'en': 'Invoice For Delivery, Mobile App, and Dine-In Orders',
      'ar': 'فاتورة التوصيل، وتطبيق الهاتف المحمول، وطلبات تناول الطعام',
    },
    '421aovoe': {
      'en': 'Delivery Orders Invoices',
      'ar': 'فواتير طلبات التوصيل',
    },
    'l3eovibp': {
      'en': 'Takeaway',
      'ar': 'سفري',
    },
    '5cbvf2sy': {
      'en': 'Applications Orders  Invoices',
      'ar': 'فواتير طلبات التطبيقات',
    },
    'bdxsgvz7': {
      'en': 'Online',
      'ar': 'متصل',
    },
    'wme3v3v6': {
      'en': 'Dine In Orders Invoices',
      'ar': ' فواتير الطلبات المحلية',
    },
    'hnst8xy7': {
      'en': 'Dine In',
      'ar': 'محلي',
    },
    'puv2b5bc': {
      'en': 'Management, Reports and  Settings',
      'ar': 'الإدارة والتقارير والإعدادات',
    },
    's5ccahcn': {
      'en': 'Management, Reports and Settings',
      'ar': 'الإدارة والتقارير والإعدادات',
    },
    'z2hkq4qt': {
      'en': 'Management',
      'ar': 'إدارة',
    },
    '7ax0icsq': {
      'en': 'Reports',
      'ar': 'التقارير',
    },
    'qbfjdslq': {
      'en': 'Settings',
      'ar': 'إعدادات',
    },
    'fpabqk27': {
      'en': 'Home',
      'ar': 'الرئيسية',
    },
    '5p5nlp2r': {
      'en': 'Cashier',
      'ar': 'أمين الصندوق',
    },
    'g9c833ax': {
      'en': 'Osama',
      'ar': 'أسامة',
    },
    'art75mr8': {
      'en': 'Home',
      'ar': 'الرئيسية',
    },
  },
  // DineInOrdersInvoices
  {
    '5498sx5w': {
      'en': 'Dine In Orders Invoices',
      'ar': 'فواتير الطلبات المحلية',
    },
    'o23777nq': {
      'en': 'Cashier,',
      'ar': 'أمين الصندوق،',
    },
    '5vzhbkbv': {
      'en': 'Osama',
      'ar': 'أسامة',
    },
    '58eflg66': {
      'en': 'Invoice',
      'ar': 'فاتورة',
    },
    'iwqw4yup': {
      'en': '3',
      'ar': '3',
    },
    's2fuao3h': {
      'en': 'Dine In Orders Invoices table in details',
      'ar': 'جدول فواتير الطلبات المحلية بالتفصيل',
    },
    'wnsdd7si': {
      'en': 'Search users...',
      'ar': 'البحث عن المستخدمين...',
    },
    'fp8iw1uu': {
      'en': 'INVOICE #',
      'ar': 'فاتورة #',
    },
    'fuc2v1ir': {
      'en': 'DATE',
      'ar': 'تاريخ',
    },
    'jwyt15xn': {
      'en': 'TOTAL',
      'ar': 'المجموع',
    },
    'sydhy5ic': {
      'en': 'VAT',
      'ar': 'ضريبة القيمة المضافة',
    },
    '38lep94d': {
      'en': 'STATUS',
      'ar': 'الحالة',
    },
    '7kiokqrp': {
      'en': 'GRANT TOTAL',
      'ar': 'المجموع الكلي',
    },
    'cqduziap': {
      'en': 'DISCOUNT',
      'ar': 'الخصم',
    },
    'uigumjvl': {
      'en': '#42925424',
      'ar': '#42925424',
    },
    'z0tdxlxe': {
      'en': 'Jan. 30th, 2023',
      'ar': '30 يناير 2023',
    },
    'tgxuohsg': {
      'en': '12:23:47 PM',
      'ar': '12:23:47 مساءً',
    },
    'p2uh8jcd': {
      'en': '42',
      'ar': '42',
    },
    'e0k32r92': {
      'en': '5',
      'ar': '5',
    },
    '52dy2c5j': {
      'en': 'Paid',
      'ar': 'مدفوع',
    },
    'gjmavaub': {
      'en': 'SR 47.00',
      'ar': '47.00 ريال سعودي',
    },
    'dxsjofso': {
      'en': '0',
      'ar': '0',
    },
    'i60tv12n': {
      'en': '#42925424',
      'ar': '#42925424',
    },
    '6ywox9p0': {
      'en': 'Jan. 30th, 2023',
      'ar': '30 يناير 2023',
    },
    'xhxmxo18': {
      'en': '12:23:47 PM',
      'ar': '12:23:47 مساءً',
    },
    's9kl9ecr': {
      'en': '24',
      'ar': '24',
    },
    'w27c1qlj': {
      'en': '24',
      'ar': '24',
    },
    'mzhwh68e': {
      'en': 'Paid',
      'ar': 'مدفوع',
    },
    'nc69xlz9': {
      'en': 'SR 56.98',
      'ar': '56.98 ريال سعودي',
    },
    'mlouob5a': {
      'en': '0',
      'ar': '0',
    },
    'o0roh63f': {
      'en': '#42925424',
      'ar': '#42925424',
    },
    'tkt6jut0': {
      'en': 'Jan. 30th, 2023',
      'ar': '30 يناير 2023',
    },
    'sqi91n55': {
      'en': '12:23:47 PM',
      'ar': '12:23:47 مساءً',
    },
    'p2e3ztnw': {
      'en': '24',
      'ar': '24',
    },
    'm6rsmjzb': {
      'en': '24',
      'ar': '24',
    },
    '7965ggnh': {
      'en': 'Paid',
      'ar': 'مدفوع',
    },
    'bd6loyp9': {
      'en': 'SR 304.90',
      'ar': '304.90 ريال سعودي',
    },
    'w3kt7qmb': {
      'en': '0',
      'ar': '0',
    },
    'plwuglfu': {
      'en': 'Receipt',
      'ar': 'إيصال',
    },
    'c98cc9ik': {
      'en': 'Receipt details ',
      'ar': 'تفاصيل الاستلام',
    },
    'lakagumh': {
      'en': 'QTY',
      'ar': 'الكمية',
    },
    'om5pstkb': {
      'en': 'MENU ITEM',
      'ar': 'قائمة العناصر',
    },
    '61hcwc3d': {
      'en': 'DISCOUNT',
      'ar': 'الخصم',
    },
    'wn3l3fpv': {
      'en': 'PRICE',
      'ar': 'سعر',
    },
    'ssyb7985': {
      'en': '1',
      'ar': '1',
    },
    'k09ipgtw': {
      'en': 'ff',
      'ar': 'وما يليها',
    },
    'otkeor0d': {
      'en': '0',
      'ar': '0',
    },
    'saddxiov': {
      'en': '8',
      'ar': '8',
    },
    'tbyqctzc': {
      'en': '2',
      'ar': '2',
    },
    'pvt2ov8g': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    '4iax0ouf': {
      'en': '0',
      'ar': '0',
    },
    '3lcpjviz': {
      'en': '8',
      'ar': '8',
    },
    '7l2uqi2t': {
      'en': '2',
      'ar': '2',
    },
    'rqvmf76h': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'k6pfqpcg': {
      'en': '0',
      'ar': '0',
    },
    '214t4n2z': {
      'en': '8',
      'ar': '8',
    },
    'zzu7jlj2': {
      'en': '2',
      'ar': '2',
    },
    'bvmpykym': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'sj86syrj': {
      'en': '0',
      'ar': '0',
    },
    'p77afjoq': {
      'en': '8',
      'ar': '8',
    },
    'cf2wb4q3': {
      'en': '2',
      'ar': '2',
    },
    '14llqsea': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    '0eo05n9a': {
      'en': '0',
      'ar': '0',
    },
    '0g22ay4y': {
      'en': '8',
      'ar': '8',
    },
    'k2bt04fl': {
      'en': '2',
      'ar': '2',
    },
    'k4buwez6': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'cxlj34ps': {
      'en': '0',
      'ar': '0',
    },
    '0apguqvi': {
      'en': '8',
      'ar': '8',
    },
    '2aj0cgym': {
      'en': '2',
      'ar': '2',
    },
    'yqx2u5ve': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'gkgjyuau': {
      'en': '0',
      'ar': '0',
    },
    'nrt5ez7l': {
      'en': '8',
      'ar': '8',
    },
    '3ba03ez3': {
      'en': '2',
      'ar': '2',
    },
    'n1xribdi': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    '0343irat': {
      'en': '0',
      'ar': '0',
    },
    'otsvpgno': {
      'en': '8',
      'ar': '8',
    },
    '6lh1ft10': {
      'en': '2',
      'ar': '2',
    },
    'b4foz1k9': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'fd955kfe': {
      'en': '0',
      'ar': '0',
    },
    'vlth4kjo': {
      'en': '8',
      'ar': '8',
    },
    '3ulcgf5g': {
      'en': 'Grant Total & Items',
      'ar': 'الإجمالي الكلي والعناصر',
    },
    'm2e5pz3y': {
      'en': 'NUMBER OF ITEMS :',
      'ar': 'عدد العناصر :',
    },
    'y1itbc2z': {
      'en': '5',
      'ar': '5',
    },
    'try33lrz': {
      'en': 'GRANT TOTAL',
      'ar': 'مجموع المنح',
    },
    '1klzmted': {
      'en': 'SR 47.00',
      'ar': '47.00 ريال سعودي',
    },
    'ndb0qv7x': {
      'en': 'Home',
      'ar': 'الرئيسية',
    },
  },
  // ApplicationsOrdersInvoices
  {
    'j5zzyqmd': {
      'en': 'Applications Orders  Invoices',
      'ar': 'فواتير طلبات التطبيقات',
    },
    'cq774nol': {
      'en': 'Cashier,',
      'ar': 'أمين الصندوق،',
    },
    'khbkr0vk': {
      'en': 'Osama',
      'ar': 'أسامة',
    },
    '3e2azwon': {
      'en': 'Invoice',
      'ar': 'فاتورة',
    },
    'rict26sv': {
      'en': '3',
      'ar': '3',
    },
    'kf1s8pre': {
      'en': 'Applications Orders  Invoices table in details',
      'ar': 'جدول فواتير طلبات الوصيل بالتفصيل',
    },
    'omkmv5p2': {
      'en': 'Search users...',
      'ar': 'البحث عن المستخدمين...',
    },
    '6nfgaxw7': {
      'en': 'INVOICE #',
      'ar': 'فاتورة #',
    },
    'a8j2df4x': {
      'en': 'DATE',
      'ar': 'تاريخ',
    },
    'nlimhn37': {
      'en': 'TOTAL',
      'ar': 'المجموع',
    },
    'zkshkwhs': {
      'en': 'VAT',
      'ar': 'ضريبة القيمة المضافة',
    },
    '0vcqtnsc': {
      'en': 'STATUS',
      'ar': 'حالة',
    },
    'sb3wtctf': {
      'en': 'GRANT TOTAL',
      'ar': 'مجموع المنح',
    },
    'qxzmpkah': {
      'en': 'DISCOUNT',
      'ar': 'تخفيض',
    },
    '49f4pa2q': {
      'en': '#42925424',
      'ar': '#42925424',
    },
    'yiczgwnm': {
      'en': 'Jan. 30th, 2023',
      'ar': '30 يناير 2023',
    },
    'g7jr0c0o': {
      'en': '12:23:47 PM',
      'ar': '12:23:47 مساءً',
    },
    'dc6ca68k': {
      'en': '42',
      'ar': '42',
    },
    'namjcajz': {
      'en': '5',
      'ar': '5',
    },
    'yarruj2l': {
      'en': 'Paid',
      'ar': 'مدفوع',
    },
    'fl1zc4fy': {
      'en': 'SR 47.00',
      'ar': '47.00 ريال سعودي',
    },
    'l6xwyyom': {
      'en': '0',
      'ar': '0',
    },
    'xrxckydl': {
      'en': '#42925424',
      'ar': '#42925424',
    },
    'sfbq7rb9': {
      'en': 'Jan. 30th, 2023',
      'ar': '30 يناير 2023',
    },
    '1nl9xmon': {
      'en': '12:23:47 PM',
      'ar': '12:23:47 مساءً',
    },
    'bjqtx6br': {
      'en': '24',
      'ar': '24',
    },
    'wsqdlbqc': {
      'en': '24',
      'ar': '24',
    },
    'qmwsi0gl': {
      'en': 'Paid',
      'ar': 'مدفوع',
    },
    '0iqhrzvp': {
      'en': 'SR 56.98',
      'ar': '56.98 ريال سعودي',
    },
    'ygjslqw7': {
      'en': '0',
      'ar': '0',
    },
    'yl5kpp4c': {
      'en': '#42925424',
      'ar': '#42925424',
    },
    'auciasiu': {
      'en': 'Jan. 30th, 2023',
      'ar': '30 يناير 2023',
    },
    'igoiwuw0': {
      'en': '12:23:47 PM',
      'ar': '12:23:47 مساءً',
    },
    'jjtd2mfk': {
      'en': '24',
      'ar': '24',
    },
    'p1vdn982': {
      'en': '24',
      'ar': '24',
    },
    's1e8do8h': {
      'en': 'Paid',
      'ar': 'مدفوع',
    },
    'nterbzt1': {
      'en': 'SR 304.90',
      'ar': '304.90 ريال سعودي',
    },
    'w8zze0lt': {
      'en': '0',
      'ar': '0',
    },
    'l5m7uvz2': {
      'en': 'Receipt',
      'ar': 'إيصال',
    },
    '3xavonff': {
      'en': 'Receipt details ',
      'ar': 'تفاصيل الاستلام',
    },
    '5rpymb93': {
      'en': 'QTY',
      'ar': 'الكمية',
    },
    '6gpvaadd': {
      'en': 'MENU ITEM',
      'ar': 'عنصر القائمة',
    },
    '969wfufm': {
      'en': 'DISCOUNT',
      'ar': 'تخفيض',
    },
    'v6abhvcj': {
      'en': 'PRICE',
      'ar': 'سعر',
    },
    'sbyuhl1s': {
      'en': '1',
      'ar': '1',
    },
    'fcnbcifc': {
      'en': 'ff',
      'ar': 'وما يليها',
    },
    'osb5j5sw': {
      'en': '0',
      'ar': '0',
    },
    'zeg1hbux': {
      'en': '8',
      'ar': '8',
    },
    'dkfuax35': {
      'en': '2',
      'ar': '2',
    },
    'fcgiqpyx': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'rif55xap': {
      'en': '0',
      'ar': '0',
    },
    '1x7z2gka': {
      'en': '8',
      'ar': '8',
    },
    '6b67gyeo': {
      'en': '2',
      'ar': '2',
    },
    'b94hxqgr': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'a0wyr18q': {
      'en': '0',
      'ar': '0',
    },
    'y0ivehba': {
      'en': '8',
      'ar': '8',
    },
    'yyihequv': {
      'en': '2',
      'ar': '2',
    },
    '6xb2do9n': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'kmi6zdv8': {
      'en': '0',
      'ar': '0',
    },
    'ix7b1791': {
      'en': '8',
      'ar': '8',
    },
    'xg159fyh': {
      'en': '2',
      'ar': '2',
    },
    '8zf1cl9b': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    '6z930avf': {
      'en': '0',
      'ar': '0',
    },
    'zgb2h8a1': {
      'en': '8',
      'ar': '8',
    },
    '3bhtoy71': {
      'en': '2',
      'ar': '2',
    },
    'qlj9xre6': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'a0my4zy9': {
      'en': '0',
      'ar': '0',
    },
    'ttxo872s': {
      'en': '8',
      'ar': '8',
    },
    'kvu7wqxx': {
      'en': '2',
      'ar': '2',
    },
    'l4rqcoxj': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'bmlugmzi': {
      'en': '0',
      'ar': '0',
    },
    '9c0fyi1x': {
      'en': '8',
      'ar': '8',
    },
    '3k9ew1s5': {
      'en': '2',
      'ar': '2',
    },
    'c0mgdna6': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'dabc3keh': {
      'en': '0',
      'ar': '0',
    },
    'w7ibo2xy': {
      'en': '8',
      'ar': '8',
    },
    'qwuyl0q0': {
      'en': '2',
      'ar': '2',
    },
    'u89uk3yi': {
      'en': 'pasta',
      'ar': 'معكرونة',
    },
    'e5ag2ij0': {
      'en': '0',
      'ar': '0',
    },
    'd2u8upwr': {
      'en': '8',
      'ar': '8',
    },
    'b23f9r1n': {
      'en': 'Grant Total & Items',
      'ar': 'إجمالي المنحة وعناصرها',
    },
    'nmoygq8r': {
      'en': 'NUMBER OF ITEMS :',
      'ar': 'عدد العناصر :',
    },
    'qzbnmsua': {
      'en': '5',
      'ar': '5',
    },
    '3jowy02c': {
      'en': 'GRAND TOTAL',
      'ar': 'المجموع الكلي',
    },
    '24eqyc9h': {
      'en': 'SR 47.00',
      'ar': '47.00 ريال سعودي',
    },
    '68w0vkpf': {
      'en': 'Home',
      'ar': 'بيت',
    },
  },
  // DineIn
  {
    '6vnzhdpb': {
      'en': 'available',
      'ar': 'متاح',
    },
    '98ji3hxt': {
      'en': 'Has Customer',
      'ar': 'مشغول',
    },
    'cqc0m26x': {
      'en': 'Ordered',
      'ar': 'تم الطلب',
    },
    'xo1vjlha': {
      'en': 'Area: 5',
      'ar': 'المنطقة: 5',
    },
    'ni1wguml': {
      'en': 'Family',
      'ar': 'عائلة',
    },
    '90tngsit': {
      'en': '7',
      'ar': '7',
    },
    'ffhuvn5a': {
      'en': 'Area: 5',
      'ar': 'المنطقة: 5',
    },
    '63lb4hyq': {
      'en': 'Individuals',
      'ar': 'أفراد',
    },
    'sqjpy64v': {
      'en': '7',
      'ar': '7',
    },
    'vgior9xq': {
      'en': 'Area: 5',
      'ar': 'المنطقة: 5',
    },
    'fxl66jzv': {
      'en': 'Family',
      'ar': 'عائلات',
    },
    'q4syyh08': {
      'en': '7',
      'ar': '7',
    },
    '6xoifet4': {
      'en': 'Area: 5',
      'ar': 'المنطقة: 5',
    },
    'l46wvwih': {
      'en': 'Individuals',
      'ar': 'أفراد',
    },
    '64zno2to': {
      'en': '7',
      'ar': '7',
    },
    'c06o4plk': {
      'en': 'Area: 5',
      'ar': 'المنطقة: 5',
    },
    'i1tkdh5a': {
      'en': 'Family',
      'ar': 'عائلة',
    },
    'zbmfy7bu': {
      'en': '7',
      'ar': '7',
    },
    'n5c0hzbu': {
      'en': 'Area: 5',
      'ar': 'المنطقة: 5',
    },
    'f4j8djd3': {
      'en': 'Family',
      'ar': 'عائلة',
    },
    'u9wr7apm': {
      'en': '7',
      'ar': '7',
    },
    'd2vxq8xd': {
      'en': 'Area: 5',
      'ar': 'المنطقة: 5',
    },
    '1qnc9oo6': {
      'en': 'Family',
      'ar': 'عائلة',
    },
    '054hcfmj': {
      'en': '7',
      'ar': '7',
    },
    'tgh3w672': {
      'en': 'Area: 5',
      'ar': 'المنطقة: 5',
    },
    '3sjxzjij': {
      'en': 'Individuals',
      'ar': 'أفراد',
    },
    'l08r3ekg': {
      'en': '7',
      'ar': '7',
    },
    'd805lk6r': {
      'en': 'Area: 5',
      'ar': 'المنطقة: 5',
    },
    'sp20u0dv': {
      'en': 'Family',
      'ar': 'عائلة',
    },
    'y5q1uciy': {
      'en': '7',
      'ar': '7',
    },
    '5qf9rjxc': {
      'en': 'Area: 5',
      'ar': 'المنطقة: 5',
    },
    '86kujkdg': {
      'en': 'Individuals',
      'ar': 'أفراد',
    },
    'u5lpozy8': {
      'en': '7',
      'ar': '7',
    },
    'rd2frclp': {
      'en': 'Area: 5',
      'ar': 'المنطقة: 5',
    },
    'zgbv5w5x': {
      'en': 'Family',
      'ar': 'عائلة',
    },
    'p735k9z0': {
      'en': '7',
      'ar': '7',
    },
    '37h33vor': {
      'en': 'Area: 5',
      'ar': 'المنطقة: 5',
    },
    '785sfia8': {
      'en': 'Family',
      'ar': 'عائلة',
    },
    '851neki2': {
      'en': '7',
      'ar': '7',
    },
    'r1re57up': {
      'en': 'Area: 5',
      'ar': 'المنطقة: 5',
    },
    'edcolnpw': {
      'en': 'Family',
      'ar': 'عائلة',
    },
    'mdxt18xw': {
      'en': '7',
      'ar': '7',
    },
    'iwk59lh2': {
      'en': 'Area: 5',
      'ar': 'المنطقة: 5',
    },
    'whdz3616': {
      'en': 'Individuals',
      'ar': 'أفراد',
    },
    'olsr9rla': {
      'en': '7',
      'ar': '7',
    },
    'nao00xok': {
      'en': 'Area: 5',
      'ar': 'المنطقة: 5',
    },
    '0hru60ez': {
      'en': 'Family',
      'ar': 'عائلة',
    },
    '90wiqs9i': {
      'en': '7',
      'ar': '7',
    },
    'wp26xhi1': {
      'en': 'Area: 5',
      'ar': 'المنطقة: 5',
    },
    'i3k4s7o1': {
      'en': 'Individuals',
      'ar': 'أفراد',
    },
    'ngu31nx0': {
      'en': '7',
      'ar': '7',
    },
    'wria3yrw': {
      'en': 'Area: 5',
      'ar': 'المنطقة: 5',
    },
    'xtonvhom': {
      'en': 'Family',
      'ar': 'عائلة',
    },
    'rl6voqzx': {
      'en': '7',
      'ar': '7',
    },
    '7kzrhvof': {
      'en': 'Area: 5',
      'ar': 'المنطقة: 5',
    },
    'lzn2uye3': {
      'en': 'Family',
      'ar': 'عائلة',
    },
    'zhgtxcht': {
      'en': '7',
      'ar': '7',
    },
    'p8vvu917': {
      'en': 'Join',
      'ar': 'دمج ',
    },
    'edbew6dl': {
      'en': 'Split',
      'ar': 'فصل ',
    },
    'u1cqz34u': {
      'en': 'Change',
      'ar': 'تغيير',
    },
    'ephg3zq3': {
      'en': 'Hold',
      'ar': 'تعليق',
    },
    '09mqpb3g': {
      'en': 'Dine In Orders',
      'ar': 'الطلبات المحلية',
    },
    'b9dccakz': {
      'en': 'Cashier,',
      'ar': 'أمين الصندوق،',
    },
    'vq0njdp6': {
      'en': 'Osama',
      'ar': 'أسامة',
    },
    'p363putp': {
      'en': 'Home',
      'ar': 'الرئيسية',
    },
  },
  // orderPageoid
  {
    'ftdptc4x': {
      'en': 'Search for items...',
      'ar': 'البحث عن عناصر...',
    },
    'qoryeib3': {
      'en': 'Appetizers',
      'ar': 'المقبلات',
    },
    'gvp9q35i': {
      'en': 'Tabbouleh',
      'ar': 'تبولة',
    },
    'vfnjde4q': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'i8vtt7pr': {
      'en': 'Kebbah',
      'ar': 'كبة',
    },
    '5rvioyk4': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    '2cazoeps': {
      'en': 'Kebbah',
      'ar': 'كبة',
    },
    'fyfiv6nf': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'jo8wd0vd': {
      'en': 'Hummos',
      'ar': 'حمص',
    },
    'yd8mjbeu': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'khamrfcy': {
      'en': 'Tabbouleh',
      'ar': 'تبولة',
    },
    'vft3nw87': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    '48kj8h7g': {
      'en': 'Kebbah',
      'ar': 'كبة',
    },
    '28hm1lyk': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'hame36c1': {
      'en': 'Kebbah',
      'ar': 'كبة',
    },
    '11oajb0s': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'pw0motug': {
      'en': 'Hummos',
      'ar': 'حمص',
    },
    'cj06xhr7': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    '1efw6yk6': {
      'en': 'Sandwitches',
      'ar': 'السندويشات',
    },
    'rqwd5q4c': {
      'en': 'Tab View 2',
      'ar': 'عرض علامة التبويب 2',
    },
    'ez0k5m0w': {
      'en': 'Meals',
      'ar': 'وجبات',
    },
    '2dmq4m87': {
      'en': 'Tab View 3',
      'ar': 'عرض علامة التبويب 3',
    },
    'ijgoy67w': {
      'en': 'Order Summary',
      'ar': 'ملخص الطلب',
    },
    '3bn2hgcv': {
      'en': 'Review the order below before checking out.',
      'ar': 'قم بمراجعة الطلب أدناه قبل المغادرة.',
    },
    '8uod79by': {
      'en': 'Delivery',
      'ar': 'توصيل',
    },
    'bla4lan7': {
      'en': 'App',
      'ar': 'برنامج',
    },
    'g25cqtrm': {
      'en': 'Select Sale Type...',
      'ar': 'اختر نوع البيع...',
    },
    'zphlaf5q': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'dg54y5hk': {
      'en': 'Tabouleh',
      'ar': 'تبولة',
    },
    '0agirr6u': {
      'en': ' Large size , wiythout onion',
      'ar': 'حجم كبير بدون بصل',
    },
    'dls86ntk': {
      'en': '2',
      'ar': '2',
    },
    'xwqynj2e': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'au8uovte': {
      'en': 'Kebbeh',
      'ar': 'كبة',
    },
    '9eo57u56': {
      'en': 'Meat Kebbah, large',
      'ar': 'كبة لحم، كبيرة',
    },
    'hfe8p9sq': {
      'en': ' 3 ',
      'ar': '3',
    },
    'tcnr814v': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    '69v8yjdi': {
      'en': '2 items added',
      'ar': 'تمت إضافة 2 عنصر',
    },
    '6hvq5kb5': {
      'en': 'Remove all items',
      'ar': 'إزالة كافة العناصر',
    },
    'dady0k9l': {
      'en': 'Price Breakdown',
      'ar': 'تفصيل الأسعار',
    },
    '3x3xhnbj': {
      'en': 'Base Price',
      'ar': 'السعر الأساسي',
    },
    's5j9d4bp': {
      'en': '156.00 SR',
      'ar': '156.00 ريال',
    },
    'y5dizmnz': {
      'en': 'Taxes',
      'ar': 'الضرائب',
    },
    '3wg2fggv': {
      'en': '24.20 SR',
      'ar': '24.20 ريال سعودي',
    },
    'nr1h06h4': {
      'en': 'Service Fee',
      'ar': 'رسوم الخدمة',
    },
    'ler8brep': {
      'en': '40.00 SR',
      'ar': '40.00 ريال',
    },
    'jlciy5za': {
      'en': 'Discount',
      'ar': 'الخصم',
    },
    'p368sbs5': {
      'en': '40.00 SR',
      'ar': '40.00 ريال',
    },
    'rohwg3mw': {
      'en': 'Total',
      'ar': 'المجموع',
    },
    '44cwin6b': {
      'en': '230.20 SR',
      'ar': '230.20 ريال',
    },
    'sr9yaacy': {
      'en': 'Send',
      'ar': 'إرسال',
    },
    '7ac5i9y3': {
      'en': 'Note',
      'ar': 'ملاحظة',
    },
    '0bjpmyaf': {
      'en': 'Off',
      'ar': 'خصم',
    },
    '1r3u0mua': {
      'en': 'Hold',
      'ar': 'تعليق',
    },
    '75of1m1k': {
      'en': 'Un-Hold Orders',
      'ar': 'إلغاء تعليق الأوامر',
    },
    '5stsrwdy': {
      'en': 'Proceed to Checkout',
      'ar': 'المتابعة للدفع',
    },
    'jcm4wde1': {
      'en': 'Page Title',
      'ar': 'عنوان الصفحة',
    },
    'igje4lc7': {
      'en': 'Home',
      'ar': 'الرئيسية',
    },
  },
  // Takeaway
  {
    '02v5dp09': {
      'en': 'Search for item...',
      'ar': 'البحث عن عناصر...',
    },
    'z0didu3b': {
      'en': 'Appetizers',
      'ar': 'المقبلات',
    },
    'svus1w8f': {
      'en': 'Tabbouleh',
      'ar': 'تبولة',
    },
    'okznuwvn': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'pu83d3ws': {
      'en': 'Kebbah',
      'ar': 'كبة',
    },
    'nl7fy17g': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    '4zq53cp3': {
      'en': 'Kebbah',
      'ar': 'كبة',
    },
    'qixrg3ce': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    '864i4jvf': {
      'en': 'Hummos',
      'ar': 'حمص',
    },
    'hcu32mqh': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'joc9m320': {
      'en': 'Tabbouleh',
      'ar': 'تبولة',
    },
    '06an6wk2': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'npa2lwof': {
      'en': 'Kebbah',
      'ar': 'كبة',
    },
    '059znn08': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    '6nu6io0k': {
      'en': 'Kebbah',
      'ar': 'كبة',
    },
    'fup87aly': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'vcecrns4': {
      'en': 'Hummos',
      'ar': 'حمص',
    },
    'dgr1gfyh': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'ayvd1emp': {
      'en': 'Sandwitches',
      'ar': 'السندويشات',
    },
    'czvvazr1': {
      'en': 'Tab View 2',
      'ar': 'عرض علامة التبويب 2',
    },
    '7jqcinar': {
      'en': 'Meals',
      'ar': 'وجبات',
    },
    'iidaqokj': {
      'en': 'Tab View 3',
      'ar': 'عرض علامة التبويب 3',
    },
    '6bqekhiw': {
      'en': 'Order Summary',
      'ar': 'ملخص الطلب',
    },
    'se2ip6vw': {
      'en': 'Review the order below before checking out.',
      'ar': 'قم بمراجعة الطلب أدناه قبل المغادرة.',
    },
    'rs9mjlnj': {
      'en': 'Takeaway',
      'ar': 'سفري',
    },
    '49altt2m': {
      'en': 'Takeaway',
      'ar': 'سفري',
    },
    '8ksr9ril': {
      'en': 'Online Ordering',
      'ar': 'الطلب عبر تطبيقات التوصيل',
    },
    '0ls16ueh': {
      'en': 'Dine In',
      'ar': 'تناول الطعام في',
    },
    'g23yb6c7': {
      'en': 'Select Sale Type...',
      'ar': 'اختر نوع البيع...',
    },
    'pxu8cxu1': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'hecy9sjw': {
      'en': 'Tabouleh',
      'ar': 'تبولة',
    },
    'i2ajgnvu': {
      'en': ' Large size , wiythout onion',
      'ar': 'حجم كبير بدون بصل',
    },
    'rrb3vbnl': {
      'en': '2',
      'ar': '2',
    },
    'y6jqx6gv': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    '5k8wp1vw': {
      'en': 'Kebbeh',
      'ar': 'كبة',
    },
    '61jlnqub': {
      'en': 'Meat Kebbah, large',
      'ar': 'كبة لحم، كبيرة',
    },
    '974gz774': {
      'en': ' 3 ',
      'ar': '3',
    },
    'bjif64vh': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'y3u9wqul': {
      'en': 'Kebbeh',
      'ar': 'كبة',
    },
    'o30i9euu': {
      'en': 'Meat Kebbah, large',
      'ar': 'كبة لحم، كبيرة',
    },
    'zojw9sx4': {
      'en': ' 3 ',
      'ar': '3',
    },
    'eldsx0ws': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'sktti5qd': {
      'en': 'Kebbeh',
      'ar': 'كبة',
    },
    'ej968g6s': {
      'en': 'Meat Kebbah, large',
      'ar': 'كبة لحم، كبيرة',
    },
    'xfl4347c': {
      'en': ' 3 ',
      'ar': '3',
    },
    '9fmuzgvh': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'rihx9iy8': {
      'en': 'Kebbeh',
      'ar': 'كبة',
    },
    '5si90m8c': {
      'en': 'Meat Kebbah, large',
      'ar': 'كبة لحم، كبيرة',
    },
    'f2hm5vw2': {
      'en': ' 3 ',
      'ar': '3',
    },
    '24x3owof': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    '0e14rax0': {
      'en': 'Kebbeh',
      'ar': 'كبة',
    },
    'myj0py55': {
      'en': 'Meat Kebbah, large',
      'ar': 'كبة لحم، كبيرة',
    },
    'ionyrmjx': {
      'en': ' 3 ',
      'ar': '3',
    },
    'pzbiwvyx': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'tvbw1fxu': {
      'en': 'Kebbeh',
      'ar': 'كبة',
    },
    'ikd9r9d4': {
      'en': 'Meat Kebbah, large',
      'ar': 'كبة لحم، كبيرة',
    },
    'ko312fxj': {
      'en': ' 3 ',
      'ar': '3',
    },
    'bzoyd24k': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'qub94pdk': {
      'en': 'Added items: ',
      'ar': 'العناصر المضافة: ',
    },
    'pdbf71vw': {
      'en': 'Remove all items',
      'ar': 'إزالة كافة العناصر',
    },
    't3lpkjfw': {
      'en': 'Price Breakdown',
      'ar': 'تفصيل الأسعار',
    },
    'bvhple7q': {
      'en': 'Base Price',
      'ar': 'السعر الأساسي',
    },
    'diagw2sx': {
      'en': '156.00 SR',
      'ar': '156.00 ريال',
    },
    '25f3baxc': {
      'en': 'Taxes',
      'ar': 'الضرائب',
    },
    '69usbg3g': {
      'en': '24.20 SR',
      'ar': '24.20 ريال سعودي',
    },
    'svs6xyw6': {
      'en': 'Service Fee',
      'ar': 'رسوم الخدمة',
    },
    '5vox1wx1': {
      'en': '40.00 SR',
      'ar': '40.00 ريال',
    },
    'xhjeggiw': {
      'en': 'Discount',
      'ar': 'الخصم',
    },
    'cddak8et': {
      'en': '40.00 SR',
      'ar': '40.00 ريال',
    },
    '8l4t1mtv': {
      'en': 'Total',
      'ar': 'المجموع',
    },
    'j4pxog6z': {
      'en': '230.20 SR',
      'ar': '230.20 ريال',
    },
    'ca43cqzy': {
      'en': 'Send',
      'ar': 'إرسال',
    },
    'if3tqhmq': {
      'en': 'Note',
      'ar': 'ملاحظة',
    },
    'wassvxzd': {
      'en': 'Off',
      'ar': 'خصم',
    },
    '7iweym2w': {
      'en': 'Hold',
      'ar': 'تعليق',
    },
    '2wedsa22': {
      'en': 'UnHold',
      'ar': 'عدم الانتظار',
    },
    '4dgyy3ks': {
      'en': 'Un-Hold Orders',
      'ar': 'إلغاء تعليق الأوامر',
    },
    'ozndb0d9': {
      'en': 'Proceed to Checkout',
      'ar': 'المتابعة للدفع',
    },
    'yj2s39s3': {
      'en': 'Takeaway',
      'ar': 'سفري',
    },
    'cbq4jw51': {
      'en': 'Cashier,',
      'ar': 'أمين الصندوق،',
    },
    'ax2upzo5': {
      'en': 'Osama',
      'ar': 'أسامة',
    },
    'fcr0mvd5': {
      'en': 'Home',
      'ar': 'الرئيسية',
    },
  },
  // ChangePrice
  {
    '0cbo551l': {
      'en': 'Change Price',
      'ar': 'تغيير السعر',
    },
    'a3ddc8yq': {
      'en': 'Cashier,',
      'ar': 'أمين الصندوق،',
    },
    'emnci2zy': {
      'en': 'Osama',
      'ar': 'أسامة',
    },
    '7hqykxvg': {
      'en': 'Items Table',
      'ar': 'جدول العناصر',
    },
    'sux9saux': {
      'en': 'Set the price for each item below',
      'ar': 'حدد السعر لكل عنصر أدناه',
    },
    'cahilc1u': {
      'en': 'Search items...',
      'ar': 'البحث عن عناصر...',
    },
    'o54kmhal': {
      'en': 'Search',
      'ar': 'بحث',
    },
    'gfkbyxzm': {
      'en': 'Title',
      'ar': 'العنوان',
    },
    '0c6lspqb': {
      'en': 'Price',
      'ar': 'السعر',
    },
    'f4qrbep0': {
      'en': 'Sale Type',
      'ar': 'نوع البيع',
    },
    'fzb3kvfs': {
      'en': 'Set Price',
      'ar': 'تحديد السعر',
    },
    '1cjvzhs9': {
      'en': 'Coffee Latte',
      'ar': 'قهوة لاتيه',
    },
    '2oco6sil': {
      'en': 'SR 10.00',
      'ar': '10.00 ريال سعودي',
    },
    'bxr0s52t': {
      'en': 'Takeaways',
      'ar': 'الوجبات الجاهزة',
    },
    '6zvscazs': {
      'en': 'Coffee Latte',
      'ar': 'قهوة لاتيه',
    },
    'mib5mpun': {
      'en': 'SR 10.00',
      'ar': '10.00 ريال سعودي',
    },
    '4364sidb': {
      'en': 'Family',
      'ar': 'عائلات',
    },
    'e76lnunm': {
      'en': 'Coffee Latte',
      'ar': 'قهوة لاتيه',
    },
    'pqlgh2f9': {
      'en': 'SR 10.00',
      'ar': '10.00 ريال سعودي',
    },
    'tn10x6gw': {
      'en': 'Single',
      'ar': 'مفرد',
    },
    'ygo465ex': {
      'en': 'Home',
      'ar': 'الرئيسية',
    },
  },
  // OnlineOrdering
  {
    'wf70j3hf': {
      'en': 'Search for item...',
      'ar': 'البحث عن عنصر...',
    },
    'xwqwi1ey': {
      'en': 'Appetizers',
      'ar': 'المقبلات',
    },
    'e8ti49wr': {
      'en': 'Tabbouleh',
      'ar': 'تبولة',
    },
    '7ofgnpkw': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    '6ezdj41o': {
      'en': 'Kebbah',
      'ar': 'كبة',
    },
    'slklzmeg': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'xftaluc5': {
      'en': 'Kebbah',
      'ar': 'كبة',
    },
    'vssset15': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'kijzid20': {
      'en': 'Hummos',
      'ar': 'حمص',
    },
    'je30xsjn': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'u958xv1u': {
      'en': 'Tabbouleh',
      'ar': 'تبولة',
    },
    'tonfcpr1': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'ig1klnqc': {
      'en': 'Kebbah',
      'ar': 'كبة',
    },
    '7i04dnj6': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    '65188lr9': {
      'en': 'Kebbah',
      'ar': 'كبة',
    },
    'bk9k1sxh': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'b7i9b6c3': {
      'en': 'Hummos',
      'ar': 'حمص',
    },
    'slkt2xmf': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'ht9sunlh': {
      'en': 'Tabbouleh',
      'ar': 'تبولة',
    },
    '0tc599r8': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'v2xe0ks0': {
      'en': 'Kebbah',
      'ar': 'كبة',
    },
    '1byh78bl': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'fseosv72': {
      'en': 'Kebbah',
      'ar': 'كبة',
    },
    'k8842ix0': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'hna63m2t': {
      'en': 'Hummos',
      'ar': 'حمص',
    },
    'nayzph0e': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'o29ckjjl': {
      'en': 'Sandwitches',
      'ar': 'السندويشات',
    },
    'ro29i652': {
      'en': 'Tab View 2',
      'ar': 'عرض علامة التبويب 2',
    },
    '8c4at156': {
      'en': 'Meals',
      'ar': 'وجبات',
    },
    'hr2wothh': {
      'en': 'Tab View 3',
      'ar': 'عرض علامة التبويب 3',
    },
    '5npb5gju': {
      'en': 'Order Summary',
      'ar': 'ملخص الطلب',
    },
    'gfzmazt4': {
      'en': 'Review the order below before checking out.',
      'ar': 'قم بمراجعة الطلب أدناه قبل المغادرة.',
    },
    'vk679p24': {
      'en': 'Online Ordering',
      'ar': 'الطلب عبر تطبيقات التوصيل',
    },
    'gam2ckbq': {
      'en': 'Takeaway',
      'ar': 'سفري',
    },
    'wag1sgig': {
      'en': 'Online Ordering',
      'ar': 'الطلب عبر تطبيقات التوصيل',
    },
    '74pe9xua': {
      'en': 'Dine In',
      'ar': 'محلي',
    },
    'fmzr3we9': {
      'en': 'Select Sale Type...',
      'ar': 'اختر نوع البيع...',
    },
    'l75dcki2': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'zzltu1sb': {
      'en': 'Tabouleh',
      'ar': 'تبولة',
    },
    'mcjw78to': {
      'en': ' Large size , wiythout onion',
      'ar': 'حجم كبير بدون بصل',
    },
    'uh5r3mqe': {
      'en': '2',
      'ar': '2',
    },
    'caws9aok': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'u0xxuwc6': {
      'en': 'Kebbeh',
      'ar': 'كبة',
    },
    '5tlmow4s': {
      'en': 'Meat Kebbah, large',
      'ar': 'كبة لحم، كبيرة',
    },
    'aln8zoxn': {
      'en': ' 3 ',
      'ar': '3',
    },
    '37z6xlaq': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'sea0eu79': {
      'en': 'Kebbeh',
      'ar': 'كبة',
    },
    'l4b3bszv': {
      'en': 'Meat Kebbah, large',
      'ar': 'كبة لحم، كبيرة',
    },
    'p2k2vipr': {
      'en': ' 3 ',
      'ar': '3',
    },
    'fo07x24x': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'kh4s0gfo': {
      'en': 'Kebbeh',
      'ar': 'كبة',
    },
    'qsdksem0': {
      'en': 'Meat Kebbah, large',
      'ar': 'كبة لحم، كبيرة',
    },
    'pk3mwaxo': {
      'en': ' 3 ',
      'ar': '3',
    },
    'gcw3elke': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'uyhdjdcb': {
      'en': 'Kebbeh',
      'ar': 'كبة',
    },
    '3r0o3vaf': {
      'en': 'Meat Kebbah, large',
      'ar': 'كبة لحم، كبيرة',
    },
    '8hkc9fch': {
      'en': ' 3 ',
      'ar': '3',
    },
    'yju2fpck': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    '15zsghbp': {
      'en': 'Kebbeh',
      'ar': 'كبة',
    },
    'ub86d8iv': {
      'en': 'Meat Kebbah, large',
      'ar': 'كبة لحم، كبيرة',
    },
    'csji9jun': {
      'en': ' 3 ',
      'ar': '3',
    },
    'vuvkzjpi': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    '8mfp4iix': {
      'en': 'Kebbeh',
      'ar': 'كبة',
    },
    '0lgyz7xd': {
      'en': 'Meat Kebbah, large',
      'ar': 'كبة لحم، كبيرة',
    },
    'i2m19apz': {
      'en': ' 3 ',
      'ar': '3',
    },
    'mqxo4a0i': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    't73eyroo': {
      'en': '8 items added',
      'ar': 'تمت إضافة 8 عناصر',
    },
    'auubt11l': {
      'en': 'Remove all items',
      'ar': 'إزالة كافة العناصر',
    },
    'jdm2dr6j': {
      'en': 'Price Breakdown',
      'ar': 'تحطيم الأسعار',
    },
    '7aj7n2pm': {
      'en': 'Base Price',
      'ar': 'السعر الأساسي',
    },
    '8m3e0qj3': {
      'en': '156.00 SR',
      'ar': '156.00 ريال',
    },
    'ufoaevfv': {
      'en': 'Taxes',
      'ar': 'الضرائب',
    },
    '5swfpjyq': {
      'en': '24.20 SR',
      'ar': '24.20 ريال سعودي',
    },
    'a0x9yxbm': {
      'en': 'Service Fee',
      'ar': 'رسوم الخدمة',
    },
    '23rl18gs': {
      'en': '40.00 SR',
      'ar': '40.00 ريال',
    },
    'l259imlr': {
      'en': 'Discount',
      'ar': 'تخفيض',
    },
    'p4bwgi1g': {
      'en': '40.00 SR',
      'ar': '40.00 ريال',
    },
    'bjnn8xw3': {
      'en': 'Total',
      'ar': 'المجموع',
    },
    'vr5ntxff': {
      'en': '230.20 SR',
      'ar': '230.20 ريال',
    },
    'n4buogc5': {
      'en': 'Send',
      'ar': 'يرسل',
    },
    'uu4b2nxb': {
      'en': 'Note',
      'ar': 'ملحوظة',
    },
    'a58eigo7': {
      'en': 'Off',
      'ar': 'عن',
    },
    '1s0yf0fo': {
      'en': 'Hold',
      'ar': 'يمسك',
    },
    '43ohdji0': {
      'en': 'Un-Hold Orders',
      'ar': 'إلغاء تعليق الأوامر',
    },
    'yhk67at5': {
      'en': 'Proceed to Checkout',
      'ar': 'الشروع في الخروج',
    },
    'bu1ccx5i': {
      'en': 'Online Ordering',
      'ar': 'الطلب على الانترنيت',
    },
    'wudeebzz': {
      'en': 'Cashier,',
      'ar': 'أمين الصندوق،',
    },
    'qdm127bo': {
      'en': 'Osama',
      'ar': 'أسامة',
    },
    'w5if10td': {
      'en': 'Home',
      'ar': 'بيت',
    },
  },
  // orderPage
  {
    '41t1g5qe': {
      'en': 'Search for item...',
      'ar': 'البحث عن عنصر...',
    },
    't4w4zjtc': {
      'en': 'Appetizers',
      'ar': 'المقبلات',
    },
    '9mnk2lvx': {
      'en': 'Tabbouleh',
      'ar': 'تبولة',
    },
    'nsm2ekbs': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'gfqmobep': {
      'en': 'Kebbah',
      'ar': 'كبة',
    },
    'lx2t2oke': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'b0z6zcno': {
      'en': 'Kebbah',
      'ar': 'كبة',
    },
    'sko08lz6': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'u46zi9f6': {
      'en': 'Hummos',
      'ar': 'حمص',
    },
    'z3w2qo47': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'fl8ccu70': {
      'en': 'Tabbouleh',
      'ar': 'تبولة',
    },
    '9248fa3k': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'f56yqrjl': {
      'en': 'Kebbah',
      'ar': 'كبة',
    },
    '3ynkkmuf': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'htjdtunb': {
      'en': 'Kebbah',
      'ar': 'كبة',
    },
    'ynwnxwq8': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    '9ohoi5u2': {
      'en': 'Hummos',
      'ar': 'حمص',
    },
    'r966n7el': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'rc7ogy25': {
      'en': 'Tabbouleh',
      'ar': 'تبولة',
    },
    'l3o2jjgw': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'mz69om3x': {
      'en': 'Kebbah',
      'ar': 'كبة',
    },
    'h0qrx8jq': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'rw5wyt7y': {
      'en': 'Kebbah',
      'ar': 'كبة',
    },
    'in5wvtjx': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    '0b97s8hh': {
      'en': 'Hummos',
      'ar': 'حمص',
    },
    '3c8qq7hd': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'tb3orogh': {
      'en': 'Sandwitches',
      'ar': 'السندويشات',
    },
    'rpp6g7p0': {
      'en': 'Tab View 2',
      'ar': 'عرض علامة التبويب 2',
    },
    '6ff8xq8j': {
      'en': 'Meals',
      'ar': 'وجبات',
    },
    'lz1eiu3f': {
      'en': 'Tab View 3',
      'ar': 'عرض علامة التبويب 3',
    },
    'sguwj3o8': {
      'en': 'Order Summary',
      'ar': 'ملخص الطلب',
    },
    'a0lervhw': {
      'en': 'Review the order below before checking out.',
      'ar': 'قم بمراجعة الطلب أدناه قبل المغادرة.',
    },
    '21xpq9xt': {
      'en': 'Dine In',
      'ar': 'محلي',
    },
    'iers3erg': {
      'en': 'Takeaway',
      'ar': 'سفري',
    },
    '0lnt635m': {
      'en': 'Online Ordering',
      'ar': 'الطلب عبر تطبيقات التوصيل',
    },
    '5ic4yjrv': {
      'en': 'Dine In',
      'ar': 'محلي',
    },
    'ahystwbn': {
      'en': 'Select Sale Type...',
      'ar': 'اختر نوع البيع...',
    },
    'jwm7d6jr': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'pymujnml': {
      'en': 'Tabouleh',
      'ar': 'تبولة',
    },
    'yvqptk1o': {
      'en': ' Large size , wiythout onion',
      'ar': 'حجم كبير بدون بصل',
    },
    'v0p032nz': {
      'en': '2',
      'ar': '2',
    },
    '6r7l66xe': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'v6tgba9u': {
      'en': 'Kebbeh',
      'ar': 'كبة',
    },
    'f5ya9inu': {
      'en': 'Meat Kebbah, large',
      'ar': 'كبة لحم، كبيرة',
    },
    'pt43kk0b': {
      'en': ' 3 ',
      'ar': '3',
    },
    'r1d8vimr': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'ub6a64j4': {
      'en': 'Kebbeh',
      'ar': 'كبة',
    },
    'lhia57eu': {
      'en': 'Meat Kebbah, large',
      'ar': 'كبة لحم، كبيرة',
    },
    'ibn6vfp9': {
      'en': ' 3 ',
      'ar': '3',
    },
    'bp6w7dzv': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'olmw3b59': {
      'en': 'Kebbeh',
      'ar': 'كبة',
    },
    '6hhy6a9q': {
      'en': 'Meat Kebbah, large',
      'ar': 'كبة لحم، كبيرة',
    },
    'dqnjrq57': {
      'en': ' 3 ',
      'ar': '3',
    },
    'agero6qn': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'is7t4p48': {
      'en': 'Kebbeh',
      'ar': 'كبة',
    },
    '7hhnm5ar': {
      'en': 'Meat Kebbah, large',
      'ar': 'كبة لحم، كبيرة',
    },
    'xkef9uwf': {
      'en': ' 3 ',
      'ar': '3',
    },
    '3lx9370z': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'p2ctwil8': {
      'en': 'Kebbeh',
      'ar': 'كبة',
    },
    'k7ie6p73': {
      'en': 'Meat Kebbah, large',
      'ar': 'كبة لحم، كبيرة',
    },
    '81eaowmt': {
      'en': ' 3 ',
      'ar': '3',
    },
    '1ohgsshr': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'wceoan9v': {
      'en': 'Kebbeh',
      'ar': 'كبة',
    },
    'q75e3lta': {
      'en': 'Meat Kebbah, large',
      'ar': 'كبة لحم، كبيرة',
    },
    'oae25v6w': {
      'en': ' 3 ',
      'ar': '3',
    },
    'a55ezp4f': {
      'en': '25 SR',
      'ar': '25 ريال',
    },
    'jpsabdpo': {
      'en': '8 items added',
      'ar': 'تمت إضافة 8 عناصر',
    },
    '60evjlbg': {
      'en': 'Remove all items',
      'ar': 'إزالة كافة العناصر',
    },
    'ktpmang1': {
      'en': 'Price Breakdown',
      'ar': 'تفصيل الأسعار',
    },
    '701v3dk4': {
      'en': 'Base Price',
      'ar': 'السعر الأساسي',
    },
    '9sde1zv7': {
      'en': '156.00 SR',
      'ar': '156.00 ريال',
    },
    '2hm9baop': {
      'en': 'Taxes',
      'ar': 'الضرائب',
    },
    'zrj06kut': {
      'en': '24.20 SR',
      'ar': '24.20 ريال سعودي',
    },
    '5m18a0zr': {
      'en': 'Service Fee',
      'ar': 'رسوم الخدمة',
    },
    '3cdhotg0': {
      'en': '40.00 SR',
      'ar': '40.00 ريال',
    },
    'jx0vmhh9': {
      'en': 'Discount',
      'ar': 'الخصم',
    },
    'o6ewu8bd': {
      'en': '40.00 SR',
      'ar': '40.00 ريال',
    },
    'bwjtyo0d': {
      'en': 'Total',
      'ar': 'المجموع',
    },
    'xzlnuu06': {
      'en': '230.20 SR',
      'ar': '230.20 ريال',
    },
    'gqwdgyxl': {
      'en': 'Send',
      'ar': 'إرسال',
    },
    'a1stn5j6': {
      'en': 'Note',
      'ar': 'ملاحظة',
    },
    'gf7drs3x': {
      'en': 'Off',
      'ar': 'خصم',
    },
    'x0lkq0o6': {
      'en': 'Hold',
      'ar': 'تعليق',
    },
    '08osxv8c': {
      'en': 'Un-Hold Orders',
      'ar': 'إلغاء تعليق الطلبات',
    },
    'pm6fjczj': {
      'en': 'Proceed to Checkout',
      'ar': 'المتابعة للدفع',
    },
    't3od09qu': {
      'en': 'Order Page',
      'ar': 'صفحة الطلب',
    },
    'mktbrqb1': {
      'en': 'Cashier',
      'ar': 'أمين الصندوق',
    },
    'qtiueq8c': {
      'en': 'Osama',
      'ar': 'أسامة',
    },
    'xfngitn8': {
      'en': 'Home',
      'ar': 'الرئيسية',
    },
  },
  // Install
  {
    '5bay0doi': {
      'en': 'Install POSMena App',
      'ar': 'قم بتنزيل تطبيق POSMena',
    },
    'b8ux6mkj': {
      'en': 'Please enter the information below.',
      'ar': 'الرجاء إدخال المعلومات أدناه.',
    },
    '3gknumy5': {
      'en': 'Tenant',
      'ar': 'مستأجر',
    },
    'l5bvq93y': {
      'en': '0',
      'ar': '0',
    },
    'q14st7pk': {
      'en': 'Store',
      'ar': 'متجر',
    },
    'm3sgbm85': {
      'en': '0',
      'ar': '0',
    },
    'gkx93wxd': {
      'en': 'Tender Type ',
      'ar': 'نوع العطاء',
    },
    'api94x4a': {
      'en': '0',
      'ar': '1',
    },
    '0u05rbsw': {
      'en': 'Language',
      'ar': 'اللغة',
    },
    '2hl7uwif': {
      'en': 'Arabic',
      'ar': 'العربية',
    },
    'slyxlcd6': {
      'en': 'English',
      'ar': 'الإنجليزية',
    },
    't22p3r3d': {
      'en': 'Please select...',
      'ar': 'الرجاء التحديد...',
    },
    'bnirbn2b': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'j90jc9az': {
      'en': 'Second Language ',
      'ar': 'اللغة الثانية',
    },
    'efqqcy7x': {
      'en': 'Arabic',
      'ar': 'العربية',
    },
    '8ma9yfyy': {
      'en': 'English',
      'ar': 'الإنجليزية',
    },
    'xclzuk5r': {
      'en': 'Please select...',
      'ar': 'الرجاء التحديد...',
    },
    'l5p19tc2': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    '4i29tqg8': {
      'en': 'Natural',
      'ar': 'عادي',
    },
    '0tp8if5t': {
      'en': 'Localhost',
      'ar': 'الخادم المحلي',
    },
    'kqeqpqdr': {
      'en': 'Production',
      'ar': 'إنتاج',
    },
    'vhdoa51q': {
      'en': 'Staging',
      'ar': 'تحضير',
    },
    'tl9hab8q': {
      'en': 'Testing',
      'ar': 'اختبار',
    },
    'qwaedrhl': {
      'en': 'Developing',
      'ar': 'تطوير',
    },
    '6g3j1tlg': {
      'en': 'Please select...',
      'ar': 'الرجاء التحديد...',
    },
    'm4cassyu': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'i8xses6s': {
      'en': 'Time Zone',
      'ar': 'المنطقة الزمنية',
    },
    'mkkhpmzb': {
      'en': '3',
      'ar': '3',
    },
    '308b9t2z': {
      'en': '2',
      'ar': '2',
    },
    'ds5b30v3': {
      'en': '1',
      'ar': '1',
    },
    'w5wrlqjd': {
      'en': '0',
      'ar': '0',
    },
    '9yk7uyyx': {
      'en': '-1',
      'ar': '-1',
    },
    'dpixz83x': {
      'en': '-2',
      'ar': '-2',
    },
    'q5u0f825': {
      'en': '-3',
      'ar': '-3',
    },
    '2ii8wvye': {
      'en': 'Please select...',
      'ar': 'الرجاء التحديد...',
    },
    'xbzgvwqu': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    '2iovu3vs': {
      'en': 'Login Method',
      'ar': 'طريقة تسجيل الدخول',
    },
    'v1ung5hh': {
      'en': 'User Name  and Password',
      'ar': 'اسم المستخدم وكلمة المرور',
    },
    'al8z9wy0': {
      'en': 'Pin Code',
      'ar': 'رمز PIN',
    },
    '85my7f3s': {
      'en': 'Please select...',
      'ar': 'الرجاء التحديد...',
    },
    '5kb76lkw': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    // '73zw15zl': {
    //   'en': 'Connection String',
    //   'ar': 'سلسلة الاتصال',
    // },
    '73zw15zl': {
      'en': 'Sync Interval (Minutes)',
      'ar': 'الفاصل الزمني للمزامنة (بالدقائق)',
    },
    '08z2s46i': {
      'en': '',
      'ar': '1',
    },
    '2ngvv2nl': {
      'en': 'Export',
      'ar': 'استيراد',
    },
    'onv0k59p': {
      'en': 'Import',
      'ar': 'تصدير',
    },
    'ajokyoub': {
      'en': 'Close',
      'ar': 'إغلاق',
    },
    'h02xw3hg': {
      'en': 'Install',
      'ar': 'تثبيت',
    },
    'yama74no': {
      'en': 'Field is required',
      'ar': 'الحقل مطلوب',
    },
    'lg4k3rz3': {
      'en': 'Please choose an option from the dropdown',
      'ar': 'يرجى اختيار خيار من القائمة المنسدلة',
    },
    '7lcm5sg8': {
      'en': 'Field is required',
      'ar': 'الحقل مطلوب',
    },
    'rt86me7w': {
      'en': 'Please choose an option from the dropdown',
      'ar': 'يرجى اختيار خيار من القائمة المنسدلة',
    },
    'f0w9nbpt': {
      'en': 'Home',
      'ar': 'الرئيسية',
    },
  },
  // POSMenaLoadingPOP
  {
    'lylf2oag': {
      'en': '80%',
      'ar': '80%',
    },
    'ansfg2yz': {
      'en': 'Hide',
      'ar': 'إخفاء',
    },
  },
  // XReportPop
  {
    'ou21wjtp': {
      'en': 'X REPORT',
      'ar': 'تقرير X',
    },
    'zo6p84l8': {
      'en': 'Are you sure to close this shift?',
      'ar': 'هل أنت متأكد من إغلاق هذه الفترة؟',
    },
    '918yc1s7': {
      'en': 'Yes',
      'ar': 'نعم',
    },
    'q7grl47e': {
      'en': 'No',
      'ar': 'لا',
    },
  },
  // ChangeItemQuantity
  {
    'cq971la8': {
      'en': 'Change Forced QTY',
      'ar': 'تغيير الكمية الاجبارية',
    },
    'ij1p70uk': {
      'en': 'Item Name: ',
      'ar': 'اسم العنصر:',
    },
    'z2bcd43j': {
      'en': 'Water',
      'ar': 'ماء',
    },
    'wusva4ay': {
      'en': 'Item QTY: ',
      'ar': 'كمية السلعة:',
    },
    'l3b8xqg1': {
      'en': '1000 ',
      'ar': '1000',
    },
    '3ko52nun': {
      'en': 'New QTY',
      'ar': 'الكمية الجديدة',
    },
    'dbxyukic': {
      'en': 'Change Forced QTY...',
      'ar': 'تغيير الكمية الاجبارية...',
    },
    'sdh7c8fg': {
      'en': 'Cancel',
      'ar': 'الغاء',
    },
    'jh7ddt8c': {
      'en': 'Change',
      'ar': 'تغيير',
    },
  },
  // ChangeExpectedQTY
  {
    'x7w2c0tb': {
      'en': 'Change Expected QTY',
      'ar': 'تغيير الكمية المتوقعة',
    },
    'tspdi3je': {
      'en': 'Item Name: ',
      'ar': 'اسم العنصر:',
    },
    'ik3b48cx': {
      'en': 'Water',
      'ar': 'ماء',
    },
    'xspqhjnf': {
      'en': 'Item QTY: ',
      'ar': 'كمية السلعة:',
    },
    'he56t5le': {
      'en': '1000 ',
      'ar': '1000',
    },
    'mxc87i3o': {
      'en': 'New QTY',
      'ar': 'الكمية الجديدة',
    },
    'asl9ydhq': {
      'en': 'Change Expected QTY...',
      'ar': 'تغيير الكمية المتوقعة...',
    },
    'uy05q8r4': {
      'en': 'Cancel',
      'ar': 'الغاء',
    },
    '49kra5bm': {
      'en': 'Change',
      'ar': 'تغيير',
    },
  },
  // ChangeItemQuantityCopy
  {
    'ta26l6qx': {
      'en': 'Change QTY',
      'ar': 'تغيير الكمية',
    },
    'v73xa1x5': {
      'en': 'Item Name: ',
      'ar': 'اسم العنصر:',
    },
    'c4nvedvj': {
      'en': 'Water',
      'ar': 'ماء',
    },
    'gjx4y76h': {
      'en': 'Forced QTY: ',
      'ar': 'الكمية الاجبارية:',
    },
    '8ep9v1ys': {
      'en': '1000 ',
      'ar': '1000',
    },
    'zlqkd2fb': {
      'en': 'Expected QTY: ',
      'ar': 'الكمية المتوقعة:',
    },
    'gfl3z0dv': {
      'en': '1000 ',
      'ar': '1000',
    },
    'b07yt23u': {
      'en': 'New Forced QTY',
      'ar': 'الكمية الاجبارية الجديدة',
    },
    'xdtatvbe': {
      'en': 'Change Forced QTY...',
      'ar': 'تغيير الكمية القسرية...',
    },
    'wdjx7zil': {
      'en': 'New Expected QTY',
      'ar': 'الكمية المتوقعة الجديدة',
    },
    'gvapv4i3': {
      'en': 'Change Expected QTY...',
      'ar': 'تغيير الكمية المتوقعة...',
    },
    'thm0j7xv': {
      'en': 'Cancel',
      'ar': 'الغاء',
    },
    's06knla5': {
      'en': 'Change',
      'ar': 'تغيير',
    },
  },
  // MarkasAvailable
  {
    's79cnhey': {
      'en': 'Availability',
      'ar': 'التوافر',
    },
    'ml1k2oss': {
      'en': 'Item Name: ',
      'ar': 'اسم العنصر:',
    },
    'ohi6v7y7': {
      'en': 'Water',
      'ar': 'ماء',
    },
    '3y3c8it1': {
      'en': 'Availability',
      'ar': 'التوافر',
    },
    'q5eqgj1j': {
      'en': 'Available',
      'ar': 'متاح',
    },
    'h0847sid': {
      'en': 'Unavailable',
      'ar': 'غير متوفر',
    },
    '0b469m2e': {
      'en': 'Please select...',
      'ar': 'الرجاء التحديد...',
    },
    'ccpzpi53': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    '2jew1dxa': {
      'en': 'Cancel',
      'ar': 'الغاء',
    },
    'rl3a1u8b': {
      'en': 'Change',
      'ar': 'تغيير',
    },
  },
  // ChangePriceAuthPop
  {
    '0252tnl4': {
      'en': 'Supervisor Authentication',
      'ar': 'مصادقة هوية المشرف',
    },
    '4qh0buk8': {
      'en': 'Log In',
      'ar': 'تسجيل الدخول',
    },
    'bp5e8gg5': {
      'en': 'Email',
      'ar': 'البريد الإلكتروني',
    },
    'h6j9tevh': {
      'en': 'Password',
      'ar': 'كلمة المرور',
    },
    'kub4372p': {
      'en': 'Login',
      'ar': 'تسجيل الدخول',
    },
    't8hce03p': {
      'en': 'Code',
      'ar': 'الرمز',
    },
    'kiyuil82': {
      'en': '7',
      'ar': '7',
    },
    'rho3zbf6': {
      'en': '8',
      'ar': '8',
    },
    'r4af3bvv': {
      'en': '9',
      'ar': '9',
    },
    'cdpvkar0': {
      'en': '4',
      'ar': '4',
    },
    'bvwcgce0': {
      'en': '5',
      'ar': '5',
    },
    'd42u60vc': {
      'en': '6',
      'ar': '6',
    },
    'vvp9u8t5': {
      'en': '1',
      'ar': '1',
    },
    '5cp6olhs': {
      'en': '2',
      'ar': '2',
    },
    'k1hpym9v': {
      'en': '3',
      'ar': '3',
    },
    'zc6dbabz': {
      'en': '0',
      'ar': '0',
    },
    'po8rhpek': {
      'en': 'Enter Code',
      'ar': 'ادخل الرمز',
    },
    '8k1ewr64': {
      'en': 'Login',
      'ar': 'تسجيل الدخول',
    },
  },
  // SetPricePopUp
  {
    'mu3cob1n': {
      'en': 'Set Price for "Coffee Latte"',
      'ar': 'تحديد سعر "قهوة لاتيه"',
    },
    '2enuhwiy': {
      'en': '7',
      'ar': '7',
    },
    'k7h4cyt0': {
      'en': '8',
      'ar': '8',
    },
    '0aq6q08o': {
      'en': '9',
      'ar': '9',
    },
    'az91j8qm': {
      'en': '4',
      'ar': '4',
    },
    'a4j16a3z': {
      'en': '5',
      'ar': '5',
    },
    '66tnzgqw': {
      'en': '6',
      'ar': '6',
    },
    'armhkjzd': {
      'en': '1',
      'ar': '1',
    },
    'ajxskhum': {
      'en': '2',
      'ar': '2',
    },
    'j6xmtuce': {
      'en': '3',
      'ar': '3',
    },
    '3ku7i53f': {
      'en': '0',
      'ar': '0',
    },
    '3skbhewv': {
      'en': '.',
      'ar': '.',
    },
    'pzsjqq5l': {
      'en': 'AC',
      'ar': 'AC',
    },
    '5s0x7l1q': {
      'en': 'Set Price',
      'ar': 'تعيين السعر',
    },
    '079gjqbf': {
      'en': 'Cancel',
      'ar': 'الغاء',
    },
    'ksmrvygc': {
      'en': 'Set Price',
      'ar': 'تعيين السعر',
    },
  },
  // EditInvoiceQTY
  {
    '3cc93vl5': {
      'en': 'Edit Invoice QTY',
      'ar': 'تعديل كمية الفاتورة',
    },
    'n0xk49b0': {
      'en': 'Item Name: ',
      'ar': 'اسم العنصر:',
    },
    'gevy2qkn': {
      'en': 'Water',
      'ar': 'ماء',
    },
    'phyeomdi': {
      'en': 'Item QTY: ',
      'ar': 'كمية العنصر:',
    },
    'sqfxglrw': {
      'en': '2',
      'ar': '2',
    },
    '1vxx5817': {
      'en': 'New QTY',
      'ar': 'الكمية الجديدة',
    },
    'ergusznu': {
      'en': 'Change Forced QTY...',
      'ar': 'تغيير الكمية ...',
    },
    'gs80l4gn': {
      'en': 'Cancel',
      'ar': 'الغاء',
    },
    '30y6linc': {
      'en': 'Change',
      'ar': 'تغيير',
    },
  },
  // AddItemPopUp
  {
    'hcd6imb7': {
      'en': 'Mushroom & Swiss Burger',
      'ar': 'مشروم و برجر سويسري',
    },
    '5a2cil1v': {
      'en': 'Two slices of beaf burger with onion, pickle and ranch soas',
      'ar': 'شريحتين من برجر اللحم البقري مع البصل والمخلل وصوص الرانش',
    },
    '5q7yku44': {
      'en': 'Select Size ',
      'ar': 'أختر الحجم',
    },
    'ha5uauev': {
      'en': 'Large',
      'ar': 'كبير',
    },
    'flvd7y1j': {
      'en': 'Medium',
      'ar': 'وسط',
    },
    'jtlh9wn8': {
      'en': 'Small',
      'ar': 'صغير',
    },
    'uvvk92pu': {
      'en': 'Select bread',
      'ar': 'اختر نوع  الخبز',
    },
    'twihabx0': {
      'en': 'Regular ',
      'ar': 'عادي',
    },
    'www77ye7': {
      'en': 'Botato Bread',
      'ar': 'خبز البطاطس',
    },
    'l93keho5': {
      'en': 'Select dish prefrences...',
      'ar': 'تحديد تفضيلات الطبق...',
    },
    'jrqkegdo': {
      'en': 'A',
      'ar': 'A',
    },
    'mvw6fwwv': {
      'en': 'Add Cheese',
      'ar': 'أضف الجبن',
    },
    'gdpacyxf': {
      'en': '+ 3 SR',
      'ar': '+ 3 ريال',
    },
    'ndx3dobj': {
      'en': 'A',
      'ar': 'A',
    },
    'dc1isf5m': {
      'en': 'Add Extra Sos',
      'ar': 'أضف المزيد من الصوص',
    },
    'rr4bafjq': {
      'en': '+ 3 SR',
      'ar': '+ 3 ريال',
    },
    'bbtsdhdu': {
      'en': 'A',
      'ar': 'A',
    },
    '41wn8ihk': {
      'en': 'Add Meat Slice',
      'ar': 'أضف شريحة لحم',
    },
    'b5q8bobn': {
      'en': '+ 8 SR',
      'ar': '+ 8 ريال',
    },
    '96pb8ht3': {
      'en': 'R',
      'ar': 'R',
    },
    'qm5db740': {
      'en': 'Remove Onion',
      'ar': 'إزالة البصل',
    },
    'h90jsgp4': {
      'en': '0 SR',
      'ar': '0 ريال',
    },
    'c55pgbdi': {
      'en': 'Add a note...',
      'ar': 'إضافة ملاحظة...',
    },
    '6yxmpmbg': {
      'en': 'Include Customer specifications or prefrences.',
      'ar': 'قم بتضمين مواصفات العميل أو تفضيلاته.',
    },
    'fihnhkpf': {
      'en': 'Cancel',
      'ar': 'ابطال',
    },
    'cmjl2z2x': {
      'en': 'Add Order',
      'ar': 'أضف الطلب',
    },
  },
  // DisccountPopUp
  {
    'y21g3qq9': {
      'en': 'Discount Order',
      'ar': 'خصم الطلبات',
    },
    'ccyspz3y': {
      'en': 'Select Discount Type',
      'ar': 'حدد نوع الخصم',
    },
    'ddcumjr7': {
      'en': 'Cash',
      'ar': 'نقدي',
    },
    '0zf4qp84': {
      'en': 'Loyalty',
      'ar': 'البطاقات البنكية',
    },
    'kxw5fh5o': {
      'en': 'Enter value',
      'ar': 'أدخل القيمة',
    },
    '13cd9p1e': {
      'en': 'Cancel',
      'ar': 'الغاء',
    },
    '52gleul0': {
      'en': 'Apply',
      'ar': 'تطبيق',
    },
  },
  // CheckOutPopUp
  {
    'ag46q06s': {
      'en': 'Check Out',
      'ar': 'الدفع',
    },
    'vvftc6t3': {
      'en': 'Grant Total',
      'ar': 'مجموع المنح',
    },
    'e8nb0edi': {
      'en': '40.00 SR',
      'ar': '40.00 ريال',
    },
    'y380vq8s': {
      'en': 'Remain',
      'ar': 'الباقي',
    },
    'rjt67j4d': {
      'en': '40.00 SR',
      'ar': '40.00 ريال',
    },
    'dsq0jfdl': {
      'en': 'Tendered',
      'ar': 'hgl\'v,p',
    },
    'nh753o2d': {
      'en': 'Invoice #',
      'ar': 'فاتورة #',
    },
    'qfuvmr3s': {
      'en': 'Amount',
      'ar': 'الكمية',
    },
    'pjngf0zd': {
      'en': 'Delete',
      'ar': 'حذف',
    },
    'w3om840k': {
      'en': 'Cash',
      'ar': 'نقدي',
    },
    'bs0obbr8': {
      'en': '#42925424',
      'ar': '#42925424',
    },
    'xc4vkvyp': {
      'en': '\$2,100.00',
      'ar': '2,100.00 دولار',
    },
    'ai7rfhrf': {
      'en': 'Payment way',
      'ar': 'طريقة الدفع',
    },
    'ybzbrsmh': {
      'en': 'Cash',
      'ar': 'نقدي',
    },
    'vex0kjki': {
      'en': 'Loyalty',
      'ar': 'البطاقات البنكية',
    },
    'iyaezg6g': {
      'en': 'Amount',
      'ar': 'الكمية',
    },
    '2xyco7qh': {
      'en': 'Add',
      'ar': 'اضافة',
    },
    'm7m31ayl': {
      'en': '9.9',
      'ar': '9.9',
    },
    '7lwa4ji7': {
      'en': '7',
      'ar': '7',
    },
    'fytr308e': {
      'en': '8',
      'ar': '8',
    },
    'q41gzke4': {
      'en': '9',
      'ar': '9',
    },
    'sp648gx1': {
      'en': '100',
      'ar': '100',
    },
    'gzmm68zq': {
      'en': '4',
      'ar': '4',
    },
    'icrnf63v': {
      'en': '5',
      'ar': '5',
    },
    'pcz1pcvh': {
      'en': '6',
      'ar': '6',
    },
    '0k43mela': {
      'en': '500',
      'ar': '500',
    },
    'd320epz7': {
      'en': '1',
      'ar': '1',
    },
    '28yi4e0t': {
      'en': '2',
      'ar': '2',
    },
    'nfxrzdb9': {
      'en': '3',
      'ar': '3',
    },
    'dvpguphu': {
      'en': '1000',
      'ar': '1000',
    },
    'b6olr3wp': {
      'en': '0',
      'ar': '0',
    },
    'uczby56a': {
      'en': '.',
      'ar': '.',
    },
    '1tuoojz4': {
      'en': 'Done',
      'ar': 'انهاء',
    },
  },
  // NotePopUp
  {
    '4d5b4nvy': {
      'en': 'Add Note to Order',
      'ar': 'أضف ملاحظة للطلب',
    },
    'w0gyzhcf': {
      'en': 'Enter your note here...',
      'ar': 'أدخل ملاحظتك هنا...',
    },
    'p8vlyyts': {
      'en': 'Add Note',
      'ar': 'اضافة الملاحظة',
    },
  },
  // UnHoldPopUp
  {
    'mybt4gze': {
      'en': 'Un Hold Orders',
      'ar': 'الطلبات المعلقة',
    },
    'y881va84': {
      'en': '12',
      'ar': '12',
    },
    'p1tmlp5r': {
      'en': 'Select the order you want to un-hold',
      'ar': 'حدد الطلب الذي تريد إلغاء تعليقه',
    },
    '549qvv3t': {
      'en': 'Un Hold Order',
      'ar': '',
    },
    'ocou6qt2': {
      'en': 'Receipt Number',
      'ar': 'رقم الإيصال',
    },
    'eyz5oumf': {
      'en': 'Date',
      'ar': 'التاريخ',
    },
    'srwhe5a0': {
      'en': 'Table Numbers',
      'ar': 'أرقام الطاولات',
    },
    'rf6rbpzo': {
      'en': 'Status',
      'ar': 'الحالة',
    },
    'w0doe6av': {
      'en': 'Un-Hold',
      'ar': 'إلغاء التعليق',
    },
    '48gwn5g5': {
      'en': '#42925424',
      'ar': '#42925424',
    },
    'dt8vs6n6': {
      'en': 'Jan. 30th, 2023',
      'ar': '30 يناير 2023',
    },
    'gvvi46gm': {
      'en': '10 days ago',
      'ar': 'منذ 10 أيام',
    },
    '5ho30jld': {
      'en': '5',
      'ar': '5',
    },
    '99rsl24j': {
      'en': 'Dine in',
      'ar': 'محلي',
    },
    'g64ool4y': {
      'en': '#42925424',
      'ar': '#42925424',
    },
    's9qv9jc3': {
      'en': 'Jan. 30th, 2023',
      'ar': '30 يناير 2023',
    },
    '3arwxgmf': {
      'en': '10 days ago',
      'ar': 'منذ 10 أيام',
    },
    'kut3kzeg': {
      'en': '9',
      'ar': '9',
    },
    'buschk25': {
      'en': 'Takeaway',
      'ar': 'سفري',
    },
    'z5g7z0rh': {
      'en': '#42925424',
      'ar': '#42925424',
    },
    'wdafyn5t': {
      'en': 'Jan. 30th, 2023',
      'ar': '30 يناير 2023',
    },
    'cue4gr2b': {
      'en': '10 days ago',
      'ar': 'منذ 10 أيام',
    },
    'k2ygt56h': {
      'en': '1',
      'ar': '1',
    },
    'upebmou1': {
      'en': 'Dine in',
      'ar': 'محلي',
    },
  },
  // JoinTablesPopUp
  {
    'vvvsd86b': {
      'en': 'Join Table',
      'ar': 'دمج الطاولات',
    },
    'ith6chuc': {
      'en': '1/4 Families',
      'ar': '1/4 عائلات',
    },
    '713jozur': {
      'en': '2/4 Individuals',
      'ar': '2/4 أفراد',
    },
    'zuvd6fmk': {
      'en': '3/2 Families',
      'ar': '3/2 عائلات',
    },
    'rhuv89ot': {
      'en': 'Table Numbers...',
      'ar': 'أرقام الطاولات...',
    },
    '7hup2ygx': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'iw0j0la1': {
      'en': 'Close',
      'ar': 'اغلاق',
    },
    '0tob6r5s': {
      'en': 'Join Tables',
      'ar': 'دمج الطاولات',
    },
  },
  // ChangeTablePopUp
  {
    '262cprdd': {
      'en': 'Join Tables',
      'ar': 'دمج الطاولات',
    },
    'b30qrl2b': {
      'en': '1/4 Families',
      'ar': '1/4 عائلات',
    },
    'q8idyh6w': {
      'en': '2/4 Individuals',
      'ar': '2/4 أفراد',
    },
    'wqu8zeih': {
      'en': '3/2 Families',
      'ar': '3/2 عائلات',
    },
    'juvn4ppd': {
      'en': 'Table Numbers...',
      'ar': 'أرقام الطاولات...',
    },
    'a8rabifi': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    'hplleiaf': {
      'en': 'Close',
      'ar': 'اغلاق',
    },
    'wa6e9yeq': {
      'en': 'Join Tables',
      'ar': 'دمج الطاولات',
    },
  },
  // HoldOrderPopUp
  {
    'xqoz0hf8': {
      'en': 'Orders',
      'ar': 'الطلبات',
    },
    '96a1myjy': {
      'en': '12',
      'ar': '12',
    },
    'ocyb8w2s': {
      'en': 'Select the order you want to hold',
      'ar': 'حدد الطلب الذي تريد تعليقه',
    },
    'uhw5ravc': {
      'en': 'Hold Order',
      'ar': '',
    },
    'lb0x6pt1': {
      'en': 'Receipt Number',
      'ar': 'عدد الإيصالات',
    },
    'nx2kiwxl': {
      'en': 'Date',
      'ar': 'التاريخ',
    },
    '2nivdflu': {
      'en': 'Table Numbers',
      'ar': 'أرقام الطاولات',
    },
    'rwqisjcj': {
      'en': 'Status',
      'ar': 'الحالة',
    },
    'edv7hw4k': {
      'en': 'Hold',
      'ar': 'تعليق',
    },
    'pxxt5zoj': {
      'en': '#42925424',
      'ar': '#42925424',
    },
    '7jih0tv0': {
      'en': 'Jan. 30th, 2023',
      'ar': '30 يناير 2023',
    },
    '0zk4kjaw': {
      'en': '10 days ago',
      'ar': 'منذ 10 أيام',
    },
    'kultxg40': {
      'en': '5',
      'ar': '5',
    },
    '6wqvu0e6': {
      'en': 'Dine in',
      'ar': 'محلي',
    },
    'hhwg4fip': {
      'en': '#42925424',
      'ar': '#42925424',
    },
    'qln3k7w1': {
      'en': 'Jan. 30th, 2023',
      'ar': '30 يناير 2023',
    },
    '7r9lcby4': {
      'en': '10 days ago',
      'ar': 'منذ 10 أيام',
    },
    'o9metzxi': {
      'en': '8',
      'ar': '8',
    },
    '6u5mjm42': {
      'en': 'Takeaway',
      'ar': 'سفري',
    },
    'kb0gc0kb': {
      'en': '#42925424',
      'ar': '#42925424',
    },
    '2pwnn9jk': {
      'en': 'Jan. 30th, 2023',
      'ar': '30 يناير 2023',
    },
    'z4tb2g3y': {
      'en': '10 days ago',
      'ar': 'منذ 10 أيام',
    },
    'zz2cy11s': {
      'en': '2',
      'ar': '2',
    },
    'rhz6v57y': {
      'en': 'Dine in',
      'ar': 'محلي',
    },
  },
  // SplitTablesPopUp
  {
    'tlsrh7i8': {
      'en': 'Split Table',
      'ar': 'فصل الطاولات',
    },
    'gh4x0fxc': {
      'en': '1/4 Families',
      'ar': '1/4 عائلات',
    },
    '7h50jfb9': {
      'en': '2/4 Individuals',
      'ar': '2/4 أفراد',
    },
    'p8fqu2wl': {
      'en': '3/2 Families',
      'ar': '3/2 عائلات',
    },
    '4avad8fq': {
      'en': 'Table Numbers...',
      'ar': 'أرقام الطاولات...',
    },
    '2th03rz9': {
      'en': 'Search for an item...',
      'ar': 'البحث عن عنصر...',
    },
    '14uawx2u': {
      'en': 'Close',
      'ar': 'اغلاق',
    },
    'r8pc6geu': {
      'en': 'Split Tables',
      'ar': 'فصل الطاولات',
    },
  },
  // Miscellaneous
  {
    'u28o0sle': {
      'en': 'Hello World',
      'ar': 'مرحبا بالعالم',
    },
    'neww0koa': {
      'en': 'Point of Sale',
      'ar': 'نقطة البيع',
    },
    '6f8sjeax': {
      'en': 'Home Page',
      'ar': 'الصفحة الرئيسية',
    },
    '8aj1dytd': {
      'en': 'Supervisor',
      'ar': 'مسؤل',
    },
    'tsdd3ule': {
      'en': 'Sell',
      'ar': 'بيع',
    },
    'g54wbefp': {
      'en': 'Sync',
      'ar': 'مزامنة',
    },
    'molb9nhn': {
      'en': 'Cash',
      'ar': 'نقد',
    },
    'zc8zt0hv': {
      'en': 'Nearpay',
      'ar': 'نيرباي',
    },
    'ac1xvmbr': {
      'en': 'Point Of Sale',
      'ar': 'نقطة البيع',
    },
    'dprmfxrn': {
      'en': 'SAR',
      'ar': 'ريال',
    },
    'kh98lj6m': {
      'en': 'Total',
      'ar': 'الإجمالي',
    },
    'pchz7ef9': {
      'en': 'Payment Method',
      'ar': 'طريقة الدفع',
    },
    'qsp4ng6w': {
      'en': 'Please select a payment method first',
      'ar': 'الرجاء اختيار طريقة الدفع أولا',
    },
    'qsp4ng6m': {
      'en': 'Select a payment method first',
      'ar': 'اختر طريقة الدفع أولا',
    },
    '930d3x2p': {
      'en': 'Please enter a valid amount',
      'ar': 'الرجاء إدخال مبلغ',
    },
    '64xgeh4y': {
      'en': 'Enter amount',
      'ar': 'أدخل المبلغ',
    },
    'lu8ezi20': {
      'en': 'Payment Amount',
      'ar': 'مبلغ الدفع',
    },
    'fnxsob92': {
      'en': 'Price Breakdown',
      'ar': 'تفاصيل السعر',
    },
    'j6wble6y': {
      'en': 'Paid',
      'ar': 'مدفوع',
    },
    't9yri5sl': {
      'en': 'Remaining',
      'ar': 'متبقي',
    },
    '274fd8i0': {
      'en': 'Change',
      'ar': 'الباقي',
    },
    'kztj03z2': {
      'en': 'Payment Breakdown',
      'ar': 'تفاصيل الدفع',
    },
    'o7yfcj25': {
      'en': 'No payments added yet',
      'ar': 'لم تتم إضافة أي مدفوعات بعد',
    },
    'n5r1ls2y': {
      'en': 'Complete Payment',
      'ar': 'إكمال الدفع',
    },
    '7tizifaj': {
      'en': 'Not enough balance',
      'ar': 'ليس هناك رصيد كاف',
    },
    "1mm882bh": {
      "en": "Customer added successfully",
      "ar": "تمت إضافة العميل بنجاح",
    },
    "2we34r55": {
      "en": "Customer added successfully",
      "ar": "تمت إضافة العميل بنجاح",
    },
    "7iweym2f": {
      "en": "Error adding customer",
      "ar": "خطأ في إضافة العميل",
    },
    "3bnv74kl": {
      "en": "Please enter the customer name",
      "ar": "يرجى إدخال اسم العميل",
    },
    "4jfr83nc": {
      "en": "Please enter the tax number",
      "ar": "يرجى إدخال الرقم الضريبي",
    },
    "w3e4rsd1": {
      "en": "Added: ",
      "ar": "تمت الإضافة:",
    },
    "5htr64ld": {
      "en": "Please enter the phone number",
      "ar": "يرجى إدخال رقم الهاتف",
    },
    "9tfj2k6l": {
      "en": "Add Customer",
      "ar": "إضافة عميل",
    },
    "6ujf8y3k": {
      "en": "Customer Type",
      "ar": "نوع العميل",
    },
    "8xyz123a": {
      "en": "Name",
      "ar": "الاسم",
    },
    "9abc456d": {
      "en": "Tax Number",
      "ar": "الرقم الضريبي",
    },
    "7uvw789e": {
      "en": "Phone",
      "ar": "الهاتف",
    },
    "6def123f": {
      "en": "Cell Phone",
      "ar": "الهاتف المحمول",
    },
    "5ghi456g": {
      "en": "Email",
      "ar": "البريد الإلكتروني",
    },
    "4jkl789h": {
      "en": "Email2",
      "ar": "البريد الإلكتروني 2",
    },
    "3mno123i": {
      "en": "Website",
      "ar": "الموقع الإلكتروني",
    },
    "2pqr456j": {
      "en": "Fax",
      "ar": "الفاكس",
    },
    "1stu789k": {
      "en": "Note",
      "ar": "ملاحظة",
    },
    "0vwx123l": {
      "en": "Postal Code",
      "ar": "الرمز البريدي",
    },
    "9yz123m": {
      "en": "Commercial Number",
      "ar": "الرقم التجاري",
    },
    "8abc456n": {
      "en": "Address",
      "ar": "العنوان",
    },
    "7def789o": {
      "en": "Country",
      "ar": "البلد",
    },
    "6ghi123p": {
      "en": "City",
      "ar": "المدينة",
    },
    "6ghi123i": {
      "en": "Invoice",
      "ar": "فاتورة",
    },
    'n5c0hzbq': {
      'en': 'User is not a cashier',
      'ar': 'المستخدم ليس كاشير',
    },
    'f1k8mzpe': {
      'en': 'Store is closed',
      'ar': 'المتجر مغلق',
    },
    'j9d3qzly': {
      'en': 'No active store shifts',
      'ar': 'لا توجد نوبات متجر نشطة',
    },
    'p7x4rvao': {
      'en': 'No active supervisor shifts',
      'ar': 'لا توجد نوبات مشرف نشطة',
    },
    'b2w6htui': {
      'en': 'Last shift not closed',
      'ar': 'النوبة الأخيرة لم تُغلق',
    },
    'm4y7nvtk': {
      'en': 'Existing end of day not valid to create cashier shift',
      'ar': 'نهاية اليوم الحالية غير صالحة لإنشاء نوبة كاشير',
    },
    'g6z9aslp': {
      'en': 'Expired end of day, must close end of day then open new day',
      'ar': 'نهاية اليوم منتهية الصلاحية، يجب إغلاق نهاية اليوم ثم فتح يوم جديد',
    },
    'h2k1dwyr': {
      'en': 'Valid end of day expired shift',
      'ar': 'نوبة نهاية اليوم الصالحة منتهية',
    },
    'c4l3ftmo': {
      'en': 'Expired end of day expired shift',
      'ar': 'نوبة نهاية اليوم منتهية الصلاحية',
    },
    'x8j5gqvn': {
      'en': 'Invalid working hour shift, no day, no shift',
      'ar': 'نوبة ساعات العمل غير صالحة، لا يوم، لا نوبة',
    },
    'r0a7hsyp': {
      'en': 'Cannot open new day at this time',
      'ar': 'لا يمكن فتح يوم جديد في هذا الوقت',
    },
    'd9k9itqw': {
      'en': 'No open day to end',
      'ar': 'لا يوجد يوم مفتوح لإنهائه',
    },
    'v1n0juzx': {
      'en': 'Cannot end of day, please close shift first',
      'ar': 'لا يمكن إنهاء اليوم، يرجى إغلاق النوبة أولاً',
    },
    't5p2kwxy': {
      'en': 'Edition not valid',
      'ar': 'الإصدار غير صالح',
    },
    'q3s4lxvc': {
      'en': 'Done',
      'ar': 'تم',
    },
    'w7u6myzp': {
      'en': 'Valid shift expired end of day',
      'ar': 'نوبة صالحة منتهية نهاية اليوم',
    },
    'e0v8ntbd': {
      'en': 'Invalid working hour day, no day, no shift',
      'ar': 'يوم ساعات العمل غير صالح، لا يوم، لا نوبة',
    },
    'k1x9ovfa': {
      'en': 'You closed shift',
      'ar': 'أغلقت النوبة',
    },
    'z4y3pwml': {
      'en': 'Day has ended',
      'ar': 'اليوم قد انتهى',
    },
    'o6u2qxrn': {
      'en': 'Cannot end of day until end time of day, new begin of day',
      'ar': 'لا يمكن إنهاء اليوم حتى نهاية وقت اليوم، بداية يوم جديد',
    },
    'a7v5rwpl': {
      'en': 'No working hour rule related with store',
      'ar': 'لا توجد قاعدة لساعات العمل تتعلق بالمتجر',
    },
    'u8x0sykb': {
      'en': 'Last shift not closed for this user',
      'ar': 'النوبة الأخيرة لم تُغلق لهذا المستخدم',
    },
    'b3t9tzow': {
      'en': 'Start/end times of day not specified, please enter start of day/end of day',
      'ar': 'أوقات بداية/نهاية اليوم غير محددة، يرجى إدخال بداية اليوم/نهاية اليوم',
    },
    'y4j2uvxn': {
      'en': 'Expired end of day closed shift',
      'ar': 'نوبة مغلقة منتهية نهاية اليوم',
    },
    'n5k6wypm': {
      'en': 'Expired shift, close old shift then open new shift',
      'ar': 'نوبة منتهية الصلاحية، أغلق النوبة القديمة ثم افتح نوبة جديدة',
    },
    'x2l1zvrq': {
      'en':
          'Expired end of day, expired shift, must close end of day, must close shift, then open new day, then open new shift',
      'ar':
          'نهاية اليوم منتهية، النوبة منتهية، يجب إغلاق نهاية اليوم، يجب إغلاق النوبة، ثم فتح يوم جديد، ثم فتح نوبة جديدة',
    },
    'qwer0001': {
      'en': 'No pricing found for this product',
      'ar': 'لم يتم العثور على سعر لهذا المنتج',
    },
    'qwer0002': {
      'en': 'No product found',
      'ar': 'لم يتم العثور على المنتج',
    },
    'qwer0003': {
      'en': 'Error occurred while scanning',
      'ar': 'حدث خطأ أثناء المسح',
    },
    'qwer0004': {
      'en': 'No products in this category',
      'ar': 'لا يوجد منتجات في هذه الفئة',
    },
    'qwer0005': {
      'en': 'Ensure that an item is added first',
      'ar': 'تأكد من إضافة العنصر أولاً',
    },
    'qwer0006': {
      'en': '',
      'ar': '',
    },
    'qwer0007': {
      'en': '',
      'ar': '',
    },
    'qwer0008': {
      'en': '',
      'ar': '',
    },
    'qwer0009': {
      'en': '',
      'ar': '',
    },
    'qwer0010': {
      'en': '',
      'ar': '',
    },
  },
].reduce((a, b) => a..addAll(b));
