part of 'employee_bloc.dart';

@immutable
sealed class EmployeeState {}

final class EmployeeInitial extends EmployeeState {}

final class EmployeeLoading extends EmployeeState {}

final class EmployeeFailed extends EmployeeState {
  final String message;

  EmployeeFailed(this.message);
}

final class EmployeeLoaded extends EmployeeState {
  final List<User> employees;

  EmployeeLoaded(this.employees);
}
