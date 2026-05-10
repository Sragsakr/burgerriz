enum TransactionStatus{
  paidOrder(1),
  susbendOrder(2),
  voidOrder(3),
  returned(4);

  final int value;

 const TransactionStatus(this.value);
}