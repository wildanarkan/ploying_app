import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ploying_app/common/app_color.dart';
import 'package:ploying_app/common/app_route.dart';
import 'package:ploying_app/common/utils.dart';
import 'package:ploying_app/data/models/task.dart';
import 'package:ploying_app/data/models/user.dart';
import 'package:ploying_app/presentation/bloc/progress_task/progress_task_bloc.dart';
import 'package:ploying_app/presentation/bloc/stat_employee/stat_employee_cubit.dart';
import 'package:ploying_app/presentation/bloc/user/user_cubit.dart';
import 'package:ploying_app/presentation/widgets/failed_ui.dart';

class HomeEmployeePage extends StatefulWidget {
  const HomeEmployeePage({super.key});

  get employee => null;

  @override
  State<HomeEmployeePage> createState() => _HomeEmployeePageState();
}

class _HomeEmployeePageState extends State<HomeEmployeePage> {
  late User user;

  refresh() {
    context.read<StatEmployeeCubit>().fetcStatistic(user.id!);
    context.read<ProgressTaskBloc>().add(OnFetchProgressTasks(user.id!));
  }

  @override
  void initState() {
    user = context.read<UserCubit>().state;
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
                child: buildSearch(),
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
                buildTaskMenu(user, refresh),
                const Gap(40),
                buildProgressTask(refresh),
                const Gap(20),
              ],
            ),
          ))
        ],
      ),
    );
  }
}

// Stack(
//   children: [
//     Container(
//       color: AppColor.primary,
//       height: 150,
//     ),
//     RefreshIndicator(
//       onRefresh: () async => refresh(),
//       child: ListView(
//         physics: const BouncingScrollPhysics(),
//         padding: const EdgeInsets.all(20),
//         children: [
// const Gap(30),
// homeHeader(context),
// const Gap(30),
// buildSearch(),
// const Gap(40),
// buildTaskMenu(),
// const Gap(40),
// buildProgressTask(),
// const Gap(20),
//         ],
//       ),
//     ),
//   ],
// ),
// );
// }

Widget buildProgressTask(VoidCallback refresh) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Progress Tasks',
        style: GoogleFonts.poppins(
          fontSize: 20,
          color: AppColor.textTitle,
          fontWeight: FontWeight.bold,
        ),
      ),
      const Gap(20),
      BlocBuilder<ProgressTaskBloc, ProgressTaskState>(
        builder: (context, state) {
          if (state is ProgressTaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProgressTaskFailed) {
            return FailedUI(message: state.message);
          }
          if (state is ProgressTaskLoaded) {
            List<Task> tasks = state.tasks;
            if (tasks.isEmpty) {
              return const FailedUI(
                icon: Icons.alarm_off,
                message: "Belum ada progress task",
              );
            }

            return ListView.builder(
              itemCount: tasks.length,
              padding: const EdgeInsets.all(0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                Task task = tasks[index];
                return buildItemProgressTasks(task, context, refresh);
              },
            );
          }
          return const SizedBox.shrink();
        },
      )
    ],
  );
}

Widget buildItemProgressTasks(
  Task task,
  BuildContext context,
  VoidCallback refresh,
) {
  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(
        context,
        AppRoute.detailTask,
        arguments: task.id,
      ).then((value) => refresh());
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      height: 80,
      child: Row(
        children: [
          Container(
            height: 50,
            width: 6,
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          const Gap(24),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColor.textTitle,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(6),
                Text(
                  dateByStatus(task),
                  style: TextStyle(
                    color: AppColor.textBody,
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            iconByStatus(task),
            height: 40,
            width: 40,
            fit: BoxFit.cover,
          ),
          const Gap(20),
        ],
      ),
    ),
  );
}

Widget buildTaskMenu(User user, VoidCallback refresh) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Tasks',
        style: GoogleFonts.poppins(
          fontSize: 20,
          color: AppColor.textTitle,
          fontWeight: FontWeight.bold,
        ),
      ),
      const Gap(20),
      BlocBuilder<StatEmployeeCubit, Map>(
        builder: (context, state) {
          return GridView.count(
            padding: const EdgeInsets.all(0),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              builItemTaskMenu(user, 'assets/queue_bg.png', 'Queue',
                  state['Queue'], context, refresh),
              builItemTaskMenu(user, 'assets/review_bg.png', 'Review',
                  state['Review'], context, refresh),
              builItemTaskMenu(user, 'assets/approved_bg.png', 'Approved',
                  state['Approved'], context, refresh),
              builItemTaskMenu(user, 'assets/rejected_bg.png', 'Rejected',
                  state['Rejected'], context, refresh),
            ],
          );
        },
      )
    ],
  );
}

Widget builItemTaskMenu(
  User user,
  String asset,
  String status,
  int total,
  BuildContext context,
  VoidCallback refresh,
) {
  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, AppRoute.listTask, arguments: {
        'status': status,
        'employee': user,
      }).then((value) => refresh());
    },
    child: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(asset),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            status,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const Gap(2),
          Text(
            '$total tasks',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildSearch() {
  return Container(
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16)),
    child: Row(
      children: [
        IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search,
              color: AppColor.defaultText,
            )),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search task....',
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: AppColor.defaultText,
              ),
            ),
          ),
        )
      ],
    ),
  );
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
