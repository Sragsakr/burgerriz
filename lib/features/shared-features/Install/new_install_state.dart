class NewInstallState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const NewInstallState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  NewInstallState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return NewInstallState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
