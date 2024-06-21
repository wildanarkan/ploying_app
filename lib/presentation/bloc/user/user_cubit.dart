// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:ploying_app/data/models/user.dart';

class UserCubit extends Cubit<User> {
  UserCubit() : super(User());

    update(User n) => emit(n);
}
