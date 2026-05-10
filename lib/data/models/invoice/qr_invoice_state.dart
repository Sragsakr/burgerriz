class QrInvoiceState {
  final String? feedbackUrl;
  final String? invoiceUrl;
  final String? finalQrUrl;
  final bool isLoading;
  final String? error;

  const QrInvoiceState({
    this.feedbackUrl,
    this.invoiceUrl,
    this.finalQrUrl,
    this.isLoading = false,
    this.error,
  });

  const QrInvoiceState.initial()
      : feedbackUrl = null,
        invoiceUrl = null,
        finalQrUrl = null,
        isLoading = false,
        error = null;

  QrInvoiceState copyWith({
    String? feedbackUrl,
    String? invoiceUrl,
    String? finalQrUrl,
    bool? isLoading,
    String? error,
  }) {
    return QrInvoiceState(
      feedbackUrl: feedbackUrl ?? this.feedbackUrl,
      invoiceUrl: invoiceUrl ?? this.invoiceUrl,
      finalQrUrl: finalQrUrl ?? this.finalQrUrl,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasQrUrl => finalQrUrl != null && finalQrUrl!.isNotEmpty;
  bool get hasError => error != null && error!.isNotEmpty;
}
