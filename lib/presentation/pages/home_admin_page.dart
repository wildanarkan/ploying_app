import 'package:d_button/d_button.dart';
import 'package:d_info/d_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ploying_app/common/app_color.dart';
import 'package:ploying_app/common/app_info.dart';
import 'package:ploying_app/common/app_route.dart';
import 'package:ploying_app/common/enums.dart';
import 'package:ploying_app/data/models/task.dart';
import 'package:ploying_app/data/models/user.dart';
import 'package:ploying_app/data/source/user_source.dart';
import 'package:ploying_app/presentation/bloc/employee/employee_bloc.dart';
import 'package:ploying_app/presentation/bloc/need_review/need_review_bloc.dart';
import 'package:ploying_app/presentation/bloc/user/user_cubit.dart';
import 'package:ploying_app/presentation/widgets/failed_ui.dart';

class HomeAdminPage extends StatefulWidget {
  const HomeAdminPage({super.key});

  @override
  State<HomeAdminPage> createState() => _HomeAdminPageState();
}

class _HomeAdminPageState extends State<HomeAdminPage> {
  getNeedReview() {
    context.read<NeedReviewBloc>().add(OnFetchNeedReview());
  }

  getEmployee() {
    context.read<EmployeeBloc>().add(OnFetchEmployee());
  }

  deleteEmployee(User employee) {
    DInfo.dialogConfirmation(context, "Delete", "Yes to confirm!")
        .then((bool? yes) {
      if (yes ?? false) {
        UserSource.delete(employee.id!).then((success) {
          if (success) {
            AppInfo.success(context, 'Success Delete');
            getEmployee();
          } else {
            AppInfo.failed(context, 'Failed Delete');
          }
        });
      }
    });
  }

  refresh() {
    getNeedReview();
    getEmployee();
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              homeHeader(context),
              Positioned(
                left: 20,
                right: 20,
                bottom: 0,
                child: addEmployee(context, refresh),
              )
            ],
          ),
          const Gap(10),
          Expanded(
              child: RefreshIndicator(
            onRefresh: () async => refresh(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Gap(10),
                needReview(refresh),
                const Gap(30),
                listEmployee(refresh, deleteEmployee),
                const Gap(20)
              ],
            ),
          ))
        ],
      ),
    );
  }
}

Widget listEmployee(VoidCallback refresh,  Function(User) deleteEmployee) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "List Employees",
        style: GoogleFonts.poppins(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      BlocBuilder<EmployeeBloc, EmployeeState>(
        builder: (context, state) {
          if (state is EmployeeLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is EmployeeFailed) {
            return const Center(
              child: FailedUI(
                message: "Something Wrong!",
                margin: EdgeInsets.only(top: 20),
              ),
            );
          }
          if (state is EmployeeLoaded) {
            List<User> employees = state.employees;
            if (employees.isEmpty) {
              return const FailedUI(
                message: "No Employees",
                icon: Icons.supervised_user_circle_outlined,
                margin: EdgeInsets.only(top: 20),
              );
            }
            return ListView.builder(
              itemCount: employees.length,
              shrinkWrap: true,
              padding: const EdgeInsets.all(0),
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                User employee = employees[index];
                return itemEmployee(employee, context, refresh, deleteEmployee);
              },
            );
          }
          return const SizedBox.shrink();
        },
      )
    ],
  );
}

Widget itemEmployee(User employee, BuildContext context, VoidCallback refresh, Function(User) deleteEmployee) {
  return Container(
    margin: const EdgeInsets.only(top: 20),
    height: 70,
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(10)),
    child: Row(
      children: [
        Container(
          height: 40,
          width: 6,
          decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              )),
        ),
        const Gap(16),
        ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Image.asset(
            'assets/profile.png',
            width: 40,
            height: 40,
          ),
        ),
        const Gap(16),
        Expanded(
          child: Text(
            employee.name ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: AppColor.textTitle,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        PopupMenuButton(
          onSelected: (value) {
            if (value == 'Monitor') {
              Navigator.pushNamed(
                context,
                AppRoute.monitorEmployee,
                arguments: employee,
              ).then(
                (value) => refresh,
              );
            }
            if (value == 'Delete') {
              deleteEmployee(employee);
            }
          },
          itemBuilder: (context) => ['Monitor', 'Delete'].map((e) {
            return PopupMenuItem(
              value: e,
              child: Text(e),
            );
          }).toList(),
        )
      ],
    ),
  );
}

Widget needReview(VoidCallback refresh) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Need to be Reviewed",
        style: GoogleFonts.poppins(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      BlocBuilder<NeedReviewBloc, NeedReviewState>(
        builder: (context, state) {
          if (state.requestStatus == RequestStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state.requestStatus == RequestStatus.failed) {
            return const Center(
              child: FailedUI(
                message: "Something Wrong!",
                margin: EdgeInsets.only(top: 20),
              ),
            );
          }
          if (state.requestStatus == RequestStatus.success) {
            List<Task> tasks = state.tasks;
            if (tasks.isEmpty) {
              return const FailedUI(
                message: "There are no assignments to review",
                icon: Icons.work_off_outlined,
                margin: EdgeInsets.only(top: 20),
              );
            }
            return Column(
              children: tasks.map((e) {
                return itemNeedReview(e, context, refresh);
              }).toList(),
            );
          }
          return const SizedBox.shrink();
        },
      )
    ],
  );
}

Widget itemNeedReview(Task task, BuildContext context, VoidCallback refresh) {
  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(
        context,
        AppRoute.detailTask,
        arguments: task.id,
      ).then(
        (value) => refresh,
      );
    },
    child: Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.asset(
              'assets/profile.png',
              width: 40,
              height: 40,
            ),
          ),
          const Gap(16),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: AppColor.textTitle,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const Gap(2),
              Text(
                task.user?.name ?? '',
                style: TextStyle(
                  color: AppColor.textBody,
                  fontSize: 12,
                ),
              ),
            ],
          )),
          const Icon(
            Icons.navigate_next_rounded,
            color: Colors.black,
          )
        ],
      ),
    ),
  );
}

Widget addEmployee(BuildContext context, VoidCallback refresh) {
  return DButtonElevation(
      elevation: 4,
      onClick: () {
        Navigator.pushNamed(context, AppRoute.addEmployee).then((value) {
          refresh();
        });
      },
      height: 50,
      radius: 12,
      mainColor: Colors.white,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add),
          Gap(4),
          Text(
            "Add New Employee",
          )
        ],
      ));
}

Widget homeHeader(BuildContext context) {
  return Container(
    height: 160,
    margin: const EdgeInsets.only(bottom: 25),
    color: AppColor.primary,
    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
    alignment: Alignment.topCenter,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, AppRoute.profile);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.asset(
              "assets/profile.png",
              height: 40,
              width: 40,
            ),
          ),
        ),
        const Gap(15),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome,",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),
              BlocBuilder<UserCubit, User>(
                builder: (context, state) {
                  return Text(
                    state.name ?? ''.toString(),
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  );
                },
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            DateFormat('d MMMM, yyyy').format(DateTime.now()),
            style: GoogleFonts.poppins(fontSize: 13),
          ),
        )
      ],
    ),
  );
}
