import 'package:flutter/material.dart';
import 'package:time_planner/src/config/global_config.dart' as config;
import 'package:time_planner/src/time_planner_style.dart';
import 'package:time_planner/src/time_planner_task.dart';
import 'package:time_planner/src/time_planner_time.dart';
import 'package:time_planner/src/time_planner_title.dart';

/// Time planner widget
class TimePlanner extends StatefulWidget {
  /// Time start from this, it will start from 0
  final int startHour;

  /// Time end at this hour, max value is 23
  final int endHour;

  /// Create days from here, each day is a TimePlannerTitle.
  ///
  /// you should create at least one day
  final List<TimePlannerTitle> headers;

  ///option to show header.
  final bool showHeader;

  /// List of widgets on time planner
  final List<TimePlannerTask>? tasks;

  /// Style of time planner
  final TimePlannerStyle? style;

  /// When widget loaded scroll to current time with an animation. Default is true
  final bool? currentTimeAnimation;

  /// Whether time is displayed in 24 hour format or am/pm format in the time column on the left.
  final bool use24HourFormat;

  //Whether the time is displayed on the axis of the tim or on the center of the timeblock. Default is false.
  final bool setTimeOnAxis;

  /// Time planner widget
  const TimePlanner({
    Key? key,
    required this.startHour,
    required this.endHour,
    required this.headers,
    this.tasks,
    this.showHeader = true,
    this.style,
    this.use24HourFormat = false,
    this.setTimeOnAxis = false,
    this.currentTimeAnimation,
  }) : super(key: key);


  @override
  _TimePlannerState createState() => _TimePlannerState();
}

class _TimePlannerState extends State<TimePlanner> {
  ScrollController mainVerticalController = ScrollController();

  TimePlannerStyle style = TimePlannerStyle();
  List<TimePlannerTask> tasks = [];
  bool? isAnimated = true;

  /// check input value rules
  void _checkInputValue() {
    if (widget.startHour > widget.endHour) {
      throw FlutterError("Start hour should be lower than end hour");
    } else if (widget.startHour < 0) {
      throw FlutterError("Start hour should be larger than 0");
    } else if (widget.endHour > 24) {
      throw FlutterError("Start hour should be lower than 23");
    } else if (widget.headers.isEmpty) {
      throw FlutterError("header can't be empty");
    }
  }

  /// create local style
  void _convertToLocalStyle() {
    style.backgroundColor = widget.style?.backgroundColor;
    style.cellHeight = widget.style?.cellHeight ?? 80;
    style.cellWidth = widget.style?.cellWidth ?? 90;
    style.horizontalTaskPadding = widget.style?.horizontalTaskPadding ?? 0;
    style.borderRadius = widget.style?.borderRadius ??
        const BorderRadius.all(Radius.circular(8.0));
    style.dividerColor = widget.style?.dividerColor;
    style.interstitialOddColor = widget.style?.interstitialOddColor;
    style.interstitialEvenColor = widget.style?.interstitialEvenColor;
  }

  /// store input data to static values
  void _initData() {
    _checkInputValue();
    _convertToLocalStyle();
    config.horizontalTaskPadding = style.horizontalTaskPadding;
    config.cellHeight = style.cellHeight;
    config.cellWidth = style.cellWidth;
    config.totalHours = (widget.endHour - widget.startHour).toDouble();
    config.totalDays = widget.headers.length;
    config.startHour = widget.startHour;
    config.use24HourFormat = widget.use24HourFormat;
    config.setTimeOnAxis = widget.setTimeOnAxis;
    config.borderRadius = style.borderRadius;
    isAnimated = widget.currentTimeAnimation;
    tasks = widget.tasks ?? [];
  }

  setParallelOrder(List<TimePlannerTask> tasks) {
    tasks.sort((a, b) => a.minutesDuration.compareTo(b.minutesDuration));

    for (int i = 0; i < tasks.length; i++) {
      for (int j = i + 1; j < tasks.length; j++) {
        if (tasks[i].isConflictInDay(tasks[j])) {
          tasks[i].conflictCount++;
          tasks[j].conflictCount++;
          if (tasks[i].parallelOrder > tasks[j].parallelOrder) {
            tasks[i].dateTime.day ++;
            tasks[i].endDateTime.day ++;
          } else {
            tasks[j].dateTime.day ++;
            tasks[j].endDateTime.day ++;
          }
        }
      }
    }
  }


  @override
  void initState() {
    _initData();
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      int hour = DateTime
          .now()
          .hour;
      if (isAnimated != null && isAnimated == true) {
        if (hour > widget.startHour) {
          double scrollOffset =
              (hour - widget.startHour) * config.cellHeight!.toDouble();
          mainVerticalController.animateTo(
            scrollOffset,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCirc,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // we need to update the tasks list in case the tasks have changed
    tasks = widget.tasks ?? [];
    setParallelOrder(tasks);


    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (widget.showHeader)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(
                    width: 60,
                  ),
                  for (int i = 0; i < config.totalDays; i++) widget
                      .headers[i],
                ],
              ),
            ),
          if (widget.showHeader)
            Container(
              height: 1,
              color: style.dividerColor ?? Theme
                  .of(context)
                  .primaryColor,
            ),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: Container(
                    child: buildMainBody(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMainBody() {
    return SingleChildScrollView(
      controller: mainVerticalController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  //first number is start hour and second number is end hour
                  for (int i = widget.startHour; i <= widget.endHour; i++)
                    Padding(
                      // we need some additional padding horizontally if we're showing in am/pm format
                      padding: EdgeInsets.symmetric(
                        horizontal: !config.use24HourFormat ? 4 : 0,
                      ),
                      child: TimePlannerTime(
                        // this returns the formatted time string based on the use24HourFormat argument.
                        time: formattedTime(i),
                        setTimeOnAxis: config.setTimeOnAxis,
                      ),
                    )
                ],
              ),
              SizedBox(width: 4,),
              Expanded(
                child: Container(
                  color: style.backgroundColor,
                  height: (config.totalHours * config.cellHeight!) + 100,
                  padding: const EdgeInsets.only(top: 18),
                  width: double.infinity,
                  child: Stack(
                    children: <Widget>[
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          for (var i = 0; i < config.totalHours; i++)
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Container(
                                  height: (config.cellHeight!).toDouble(),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        bottom: const BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        ),
                                        top: (i == 0)
                                            ? const BorderSide(
                                          color: Colors.black12,
                                          width: 1,
                                        )
                                            : BorderSide.none),
                                  ),
                                ),
                              ],
                            )
                        ],
                      ),
                      for (int i = 0; i < tasks.length; i++) tasks[i],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String formattedTime(int hour) {
    /// this method formats the input hour into a time string
    /// modifing it as necessary based on the use24HourFormat flag .
    if (config.use24HourFormat) {
      // we use the hour as-is
      return hour.toString() + ':00';
    } else {
      // we format the time to use the am/pm scheme
      if (hour == 0) return "12:00 am";
      if (hour < 12) return "$hour:00 am";
      if (hour == 12) return "12:00 pm";
      return "${hour - 12}:00 pm";
    }
  }
}
