import 'package:d_session/d_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ploying_app/common/app_color.dart';
import 'package:ploying_app/common/app_route.dart';
import 'package:ploying_app/data/models/user.dart';
import 'package:ploying_app/presentation/bloc/detail_task/detail_task_cubit.dart';
import 'package:ploying_app/presentation/bloc/employee/employee_bloc.dart';
import 'package:ploying_app/presentation/bloc/list_task/list_task_bloc.dart';
import 'package:ploying_app/presentation/bloc/login/login_cubit.dart';
import 'package:ploying_app/presentation/bloc/need_review/need_review_bloc.dart';
import 'package:ploying_app/presentation/bloc/progress_task/progress_task_bloc.dart';
import 'package:ploying_app/presentation/bloc/stat_employee/stat_employee_cubit.dart';
import 'package:ploying_app/presentation/bloc/user/user_cubit.dart';
import 'package:ploying_app/presentation/pages/add_employee_page.dart';
import 'package:ploying_app/presentation/pages/add_task_page.dart';
import 'package:ploying_app/presentation/pages/detail_task_page.dart';
import 'package:ploying_app/presentation/pages/home_admin_page.dart';
import 'package:ploying_app/presentation/pages/home_employee_page.dart';
import 'package:ploying_app/presentation/pages/list_task_page.dart';
import 'package:ploying_app/presentation/pages/login_page.dart';
import 'package:ploying_app/presentation/pages/monitor_employee_page.dart';
import 'package:ploying_app/presentation/pages/profile_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((value) {
    runApp(const MainApp());
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(useMaterial3: true).copyWith(
          primaryColor: AppColor.primary,
          colorScheme: ColorScheme.light(
            primary: AppColor.primary,
            secondary: AppColor.secondary,
          ),
          scaffoldBackgroundColor: AppColor.scaffold,
          textTheme: GoogleFonts.poppinsTextTheme(),
          appBarTheme: AppBarTheme(
            surfaceTintColor: AppColor.primary,
            backgroundColor: AppColor.primary,
            foregroundColor: Colors.white,
            titleTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          popupMenuTheme: const PopupMenuThemeData(
            color: Colors.white,
            surfaceTintColor: Colors.white,
          ),
          dialogTheme: const DialogTheme(
            surfaceTintColor: Colors.white,
            backgroundColor: Colors.white,
          ),
        ),
        initialRoute: AppRoute.home,
        routes: {
          AppRoute.home: (context) {
            return FutureBuilder(
              future: DSession.getUser(),
              builder: (context, snapshot) {
                if (snapshot.data == null) return const LoginPage();
                User user = User.fromJson(Map.from(snapshot.data!));
                context.read<UserCubit>().update(user);
                if (user.role == "Admin") return const HomeAdminPage();
                return const HomeEmployeePage();
              },
            );
          },
          AppRoute.addEmployee: (context) => const AddEmployeePage(),
          AppRoute.addTask: (context) {
            User employee = ModalRoute.of(context)!.settings.arguments as User;
            return AddTaskPage(employee: employee);
          },
          AppRoute.detailTask: (context) {
            int id = ModalRoute.of(context)!.settings.arguments as int;
            return BlocProvider(
              create: (context) => DetailTaskCubit(),
              child: DetailTaskPage(id: id),
            );
          },
          AppRoute.listTask: (context) {
            Map data = ModalRoute.of(context)!.settings.arguments as Map;
            return BlocProvider(
              create: (context) => ListTaskBloc(),
              child: ListTaskPage(
                status: data['status'],
                employee: data['employee'],
              ),
            );
          },
          AppRoute.login: (context) => const LoginPage(),
          AppRoute.monitorEmployee: (context) {
            User employee = ModalRoute.of(context)!.settings.arguments as User;
            return MonitorEmployeePage(employee: employee);
          },
          AppRoute.profile: (context) => const ProfilePage(),
        },
      ),
    );
  }
}
