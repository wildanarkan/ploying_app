import 'package:ploying_app/data/models/user.dart';
import 'package:ploying_app/data/source/user_source.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'employee_event.dart';
part 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  EmployeeBloc() : super(EmployeeInitial()) {
    on<OnFetchEmployee>((event, emit) async {
      emit(EmployeeLoading());
      List<User>? result = await UserSource.getEmlpoyee();
      if (result == null) {
        emit(EmployeeFailed('Something wrong'));
      } else {
        emit(EmployeeLoaded(result));
      }
    });
  }
}
