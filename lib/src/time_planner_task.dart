import 'package:flutter/material.dart';
import 'package:time_planner/src/time_planner_date_time.dart';
import 'package:time_planner/src/config/global_config.dart' as config;

/// Widget that show on time planner as the tasks
class TimePlannerTask extends StatelessWidget {
  /// Minutes duration of task or object
  final int minutesDuration;

  /// Days duration of task or object, default is 1
  final int? daysDuration;

  /// When this task will be happen
  TimePlannerDateTime dateTime;
  int conflictCount = 0;

  /// When this taks will end
  late TimePlannerDateTime endDateTime;

  /// Background color of task
  final Color? color;

  /// This will be happen when user tap on task, for example show a dialog or navigate to other page
  final Function? onTap;

  /// Show this child on the task
  ///
  /// Typically an [Text].
  final Widget? child;

  /// parameter to set space from left, to set it: config.cellWidth! * dateTime.day.toDouble()
  final double? leftSpace;

  /// parameter to set width of task, to set it: (config.cellWidth!.toDouble() * (daysDuration ?? 1)) -config.horizontalTaskPadding!
  final double? widthTask;

  final int parallelOrder;

  /// Widget that show on time planner as the tasks
  TimePlannerTask({Key? key,
    required this.minutesDuration,
    required this.dateTime,
    this.daysDuration,
    this.color,
    this.onTap,
    this.child,
    required this.parallelOrder,
    this.leftSpace,
    this.widthTask}) {
    this.endDateTime = TimePlannerDateTime(
        day: dateTime.day + minutesDuration ~/ (24 * 60),
        hour: dateTime.hour + minutesDuration ~/ 60,
        minutes: dateTime.minutes + minutesDuration % 60);
  }

  bool isConflictInDay(final TimePlannerTask other) {
    bool status = this.dateTime.isBeforeInDay(other.endDateTime) &&
        this.endDateTime.isAfterInDay(other.dateTime);
    return status;
  }

  bool isConflict(final TimePlannerTask other) {
    bool status = this.dateTime.isBefore(other.endDateTime) &&
        this.endDateTime.isAfter(other.dateTime);
    return status;
  }

  @override
  Widget build(BuildContext context) {
    if (dateTime.day > 0) {
      print("");
    }
    return Positioned(
      top: ((config.cellHeight! * (dateTime.hour - config.startHour)) +
          ((dateTime.minutes * config.cellHeight!) / 60))
          .toDouble(),
      left: 314 / (conflictCount + 1) * (dateTime.day).toDouble() +
          (leftSpace ?? 0),
      child: Container(
        width: 314 / (conflictCount + 1),
        margin: EdgeInsets.only(bottom: 5),
        child: Padding(
          padding: EdgeInsets.only(bottom: 0),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: config.borderRadius!,
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child:
                  InkWell(
                    onTap: onTap as void Function() ? ?? () {},
                    child: Container(
                      alignment: Alignment.topLeft,
                      height: ((minutesDuration.toDouble() *
                          config.cellHeight!) /
                          60 - 10), //60 minutes
                      // (daysDuration! >= 1 ? daysDuration! : 1)),
                      decoration: BoxDecoration(
                          borderRadius: config.borderRadius,
                          color: color ?? Theme
                              .of(context)
                              .primaryColor),
                      child: child,

                    ),
                  ),),
              ],
            ),)
          ,
        )
        ,
      )
      ,
    );
  }
}
