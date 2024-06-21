  import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ploying_app/presentation/bloc/employee/employee_bloc.dart';
import 'package:ploying_app/presentation/bloc/login/login_cubit.dart';
import 'package:ploying_app/presentation/bloc/need_review/need_review_bloc.dart';
import 'package:ploying_app/presentation/bloc/progress_task/progress_task_bloc.dart';
import 'package:ploying_app/presentation/bloc/stat_employee/stat_employee_cubit.dart';
import 'package:ploying_app/presentation/bloc/user/user_cubit.dart';

var blocProvider = [
        BlocProvider(
          create: (context) => UserCubit(),
        ),
        BlocProvider(
          create: (context) => LoginCubit(),
        ),
        BlocProvider(
          create: (context) => NeedReviewBloc(),
        ),
        BlocProvider(
          create: (context) => EmployeeBloc(),
        ),
        BlocProvider(
          create: (context) => StatEmployeeCubit(),
        ),
        BlocProvider(
          create: (context) => ProgressTaskBloc(),
        ),
      ];