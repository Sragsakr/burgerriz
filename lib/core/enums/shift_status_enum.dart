enum ShiftSyncStatus {
  UserIsNotACashier(1, "User is not a cashier", "المستخدم ليس كاشيرًا"),
  StoreIsClosed(2, "Store is closed", "المتجر مغلق"),
  NoActiveStoreShifts(3, "No active store shifts", "لا توجد مناوبات نشطة في المتجر"),
  NoActiveSupervisorShifts(4, "No active supervisor shifts", "لا توجد مناوبات نشطة للمشرف"),
  LastShiftIsNotClosed(5, "Last shift is not closed", "المناوبة الأخيرة لم تُغلق"),
  ExistEndOfDay_NotValidToCreateCashierShift(6, "End of day exists, not valid to create cashier shift", "يوجد نهاية يوم، لا يمكن إنشاء مناوبة كاشير"),
  ExpiredEndOfDay_MustCloseEndOfDay_ThenOpenNewDay(7, "End of day expired, must close end of day then open a new day", "انتهت صلاحية نهاية اليوم، يجب إغلاق نهاية اليوم ثم فتح يوم جديد"),
  ValidEndOfDay_ExpiredShift(8, "Valid end of day, expired shift", "نهاية اليوم صالحة، لكن المناوبة منتهية"),
  ExpiredEndOfDay_ExpiredShift(9, "Expired end of day and expired shift", "انتهت صلاحية نهاية اليوم والمناوبة"),
  InvalidWorkingHourShift_NoDay_NoShift(10, "Invalid working hour shift, no day and no shift", "وقت عمل غير صالح، لا يوجد يوم ولا مناوبة"),
  CannotOpenANewDayAtThisTime(11, "Cannot open a new day at this time", "لا يمكن فتح يوم جديد في هذا الوقت"),
  ThereIsNoOpenDayToEnd(12, "There is no open day to end", "لا يوجد يوم مفتوح لإنهائه"),
  CanNotEndOfDayPleaseCloseShiftFirst(13, "Cannot end the day, please close the shift first", "لا يمكن إنهاء اليوم، يرجى إغلاق المناوبة أولاً"),
  EditionNotValid(14, "Edition is not valid", "الإصدار غير صالح"),
  Done(15, "Operation completed successfully", "تمت العملية بنجاح"),
  ValidShift_ExpiredEndOfDay(16, "Valid shift, expired end of day", "المناوبة صالحة، لكن نهاية اليوم منتهية"),
  InvalidWorkingHourDay_NoDay_NoShift(17, "Invalid working hour day, no day and no shift", "يوم عمل غير صالح، لا يوجد يوم ولا مناوبة"),
  YouClosedShift(18, "You closed the shift", "لقد أغلقت المناوبة"),
  DayHasBeenEnded(19, "Day has been ended", "تم إنهاء اليوم"),
  CanNotEndOfDay_UntilEndTimeOfDay_NewBeginOfDay(20, "Cannot end the day until the end time of the day and new begin of the day", "لا يمكن إنهاء اليوم حتى انتهاء وقت اليوم وبداية يوم جديد"),
  ThereIsNoWorkingHourRuleRelatedWithStore(21, "There is no working hour rule related with the store", "لا توجد قاعدة ساعات عمل مرتبطة بالمتجر"),
  LastShiftIsNotClosedForThisUser(22, "Last shift is not closed for this user", "المناوبة الأخيرة لهذا المستخدم لم تُغلق"),
  InvalidWorkingHourDay(23, "Invalid working hour day", "يوم عمل غير صالح"),
  StartEndTimesOfTheDayAreNotSpecified_PleaseEnterStartOfDayEndOfDay(24, "Start and end times of the day are not specified, please enter start and end times", "لم يتم تحديد أوقات بداية ونهاية اليوم، يرجى إدخالها"),
  ExpiredEndOfDay_ClosedShift(25, "Expired end of day and closed shift", "انتهت صلاحية نهاية اليوم وتم إغلاق المناوبة"),
  ExpiredShift_CloseOldShift_ThenOpenNewShift(26, "Expired shift, close old shift then open new shift", "المناوبة منتهية، يرجى إغلاق المناوبة القديمة ثم فتح مناوبة جديدة"),
  ExpiredEndOfDay_ExpiredShift_MustCloseEndOfDay_MustCloseShift_ThenOpenNewDay_ThenOpenNewShift(27, "Expired end of day and expired shift, must close end of day, close shift, then open new day and new shift", "انتهت صلاحية نهاية اليوم والمناوبة، يجب إغلاق نهاية اليوم والمناوبة ثم فتح يوم ومناوبة جديدة"),
  NotStoreSupervisorFound(28, "No store supervisor found", "لم يتم العثور على مشرف المتجر");

  final int value;
  final String descriptionEn;
  final String descriptionAr;

  const ShiftSyncStatus(this.value, this.descriptionEn, this.descriptionAr);

  /// Get `ShiftSyncStatus` by value
  static ShiftSyncStatus? fromValue(int value) {
    return ShiftSyncStatus.values.firstWhere(
          (status) => status.value == value,
      orElse: () => throw ArgumentError('Invalid ShiftSyncStatus value: $value'),
    );
  }
}
