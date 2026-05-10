abstract final class QrInvoiceConstants {
  static const String feedmenaBaseUrl = 'https://staging-api.feedmena.com';
  static const String feedmenaEndpoint = '/api/v1/feedback-requests/';
  static const String feedmenaAccountId = 'FM873b39e759d7e58d841b64ba47116999';
  static const String feedmenaAuthKey = 'QMYFUOPLJ2ISN6PYMEICXO7BMDYBDA6D';

  static const String zigsBaseUrl = 'https://zigs.menaplatform.com';
  static const String zigsEndpoint = '/invoicing/generate-invoice/';
  static const String zigsAccountId = 'FMe7649df34eedf4d0712d153ddca41465';
  static const String zigsAuthKey = '6XZ6NXRAKS7VGQVXNRE2HGJJMW5WAQOE';

  static const String qrBaseUrl = 'https://go.menaplatform.com/';

  static const String defaultBranchId = 'TM-Tabuk-01';
  static const String defaultShiftId = 'Shift-1';
  static const String defaultResponseChannel = 'Link';
  static const String defaultVatNumber = 'VAT123456789';
  static const String defaultPhoneNumber = '+966542816173';
  static const String defaultAddress =
      'طريق أنس ابن مالك، حي الملقا، الرياض 13525، Saudi Arabia';
  static const double defaultVatPercentage = 15.0;
  static const String defaultQrCode =
      'AQtCbHVlIEdhcmRlbgIPMzEyNTEyMTE0NjAwMDAzAxQyMDI0LTExLTIxVDEyOjM5OjAwWgQHMjUzMC4wMAUGMzMwLjAw';
}
