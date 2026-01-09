enum FeedbackStatus {
  pending('Pending'),
  complete('Complete');

  const FeedbackStatus(this.displayName);
  final String displayName;
}
