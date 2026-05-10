class NewLoginState {
  final bool isLoading;
  final String? errorMessage;

  const NewLoginState({
    this.isLoading = false,
    this.errorMessage,
  });

  NewLoginState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return NewLoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
