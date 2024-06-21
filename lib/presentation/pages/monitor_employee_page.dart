import 'package:d_button/d_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ploying_app/common/app_color.dart';
import 'package:ploying_app/common/app_route.dart';
import 'package:ploying_app/common/utils.dart';
import 'package:ploying_app/data/models/task.dart';
import 'package:ploying_app/data/models/user.dart';
import 'package:ploying_app/presentation/bloc/progress_task/progress_task_bloc.dart';
import 'package:ploying_app/presentation/bloc/stat_employee/stat_employee_cubit.dart';
import 'package:ploying_app/presentation/widgets/failed_ui.dart';
import 'package:ploying_app/presentation/widgets/update_password.dart';

class MonitorEmployeePage extends StatefulWidget {
  const MonitorEmployeePage({super.key, required this.employee});
  final User employee;

  @override
  State<MonitorEmployeePage> createState() => _MonitorEmployeePageState();
}

class _MonitorEmployeePageState extends State<MonitorEmployeePage> {
  refresh() {
    context.read<StatEmployeeCubit>().fetcStatistic(widget.employee.id!);
    context
        .read<ProgressTaskBloc>()
        .add(OnFetchProgressTasks(widget.employee.id!));
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
                child: buildAddTaskButton(),
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
                buildTaskMenu(),
                const Gap(40),
                buildProgressTask(),
                const Gap(20),
              ],
            ),
          ))
        ],
      ),
    );
  }

  Widget buildProgressTask() {
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
                  return buildItemProgressTasks(task);
                },
              );
            }
            return const SizedBox.shrink();
          },
        )
      ],
    );
  }

  Widget buildItemProgressTasks(Task task) {
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

  Widget buildTaskMenu() {
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
                builItemTaskMenu(
                    'assets/queue_bg.png', 'Queue', state['Queue']),
                builItemTaskMenu(
                    'assets/review_bg.png', 'Review', state['Review']),
                builItemTaskMenu(
                    'assets/approved_bg.png', 'Approved', state['Approved']),
                builItemTaskMenu(
                    'assets/rejected_bg.png', 'Rejected', state['Rejected']),
              ],
            );
          },
        )
      ],
    );
  }

  Widget builItemTaskMenu(String asset, String status, int total) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoute.listTask, arguments: {
          'status': status,
          'employee': widget.employee,
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

  Widget homeHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      height: 150,
      color: AppColor.primary,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      alignment: Alignment.topCenter,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.translate(
            offset: const Offset(-12, 0),
            child: const BackButton(color: Colors.white),
          ),
          Expanded(
            child: Text(
              widget.employee.name ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DButtonFlat(
            height: 40,
            onClick: () {
              UpdatePassword.showResetPasswordDialog(context, widget.employee.id!);
            },
            mainColor: Colors.white,
            radius: 15,
            child: const Text(
              'Reset Password',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAddTaskButton() {
    return DButtonElevation(
      onClick: () {
        Navigator.pushNamed(
          context,
          AppRoute.addTask,
          arguments: widget.employee,
        ).then((value) => refresh());
      },
      height: 50,
      mainColor: Colors.white,
      radius: 16,
      elevation: 4,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add),
          Gap(4),
          Text('Add New Task'),
        ],
      ),
    );
  }
}
