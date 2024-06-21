part of 'need_review_bloc.dart';

class NeedReviewState {
  final RequestStatus requestStatus;
  final List<Task> tasks;

  NeedReviewState(this.requestStatus, this.tasks);

  factory NeedReviewState.init() => NeedReviewState(RequestStatus.init, []);
}
