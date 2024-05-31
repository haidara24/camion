import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/post_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/helpers/color_constants.dart';
import 'package:camion/views/widgets/calculator_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int isvisivle = 0;
  bool addgroup = false;
  bool savepost = false;
  List<Color> colors = [
    Colors.red[300]!,
    Colors.yellow[300]!,
    Colors.blue[300]!,
    Colors.pink[200]!,
    Colors.purple[200]!
  ];
  final GlobalKey<FormState> _groupform = GlobalKey();
  String groupName = "";

  String diffText(Duration diff) {
    if (diff.inSeconds < 60) {
      return "منذ ${diff.inSeconds.toString()} ثانية";
    } else if (diff.inMinutes < 60) {
      return "منذ ${diff.inMinutes.toString()} دقيقة";
    } else if (diff.inHours < 24) {
      return "منذ ${diff.inHours.toString()} ساعة";
    } else {
      return "منذ ${diff.inDays.toString()} يوم";
    }
  }

  String diffEnText(Duration diff) {
    if (diff.inSeconds < 60) {
      return "since ${diff.inSeconds.toString()} seconds";
    } else if (diff.inMinutes < 60) {
      return "since ${diff.inMinutes.toString()} minutes";
    } else if (diff.inHours < 24) {
      return "since ${diff.inHours.toString()} hours";
    } else {
      return "since ${diff.inDays.toString()} days";
    }
  }

  Future<void> onRefresh() async {
    BlocProvider.of<PostBloc>(context).add(PostLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    final playDuration = 600.ms;

    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return Directionality(
          textDirection: localeState.value.languageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.grey[100],
              body: RefreshIndicator(
                onRefresh: onRefresh,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: BlocBuilder<PostBloc, PostState>(
                    builder: (context, state) {
                      if (state is PostLoadedSuccess) {
                        return ListView.builder(
                          itemCount: state.posts.length,
                          itemBuilder: (context, index) {
                            DateTime now = DateTime.now();
                            Duration diff =
                                now.difference(state.posts[index].date!);
                            return Card(
                              elevation: 1,
                              clipBehavior: Clip.antiAlias,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 15),
                              color: Colors.white,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Image.network(
                                      state.posts[index].image!,
                                      height: 225.h,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          height: 225.h,
                                          width: double.infinity,
                                          color: Colors.grey[300],
                                          child: Center(
                                            child: Text(AppLocalizations.of(
                                                    context)!
                                                .translate('image_load_error')),
                                          ),
                                        );
                                      },
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }

                                        return Shimmer.fromColors(
                                          baseColor: (Colors.grey[300])!,
                                          highlightColor: (Colors.grey[100])!,
                                          enabled: true,
                                          child: Container(
                                            height: 225.h,
                                            width: double.infinity,
                                            color: Colors.white,
                                          ),
                                        );
                                      },
                                    )
                                        .animate(delay: 400.ms)
                                        .shimmer(
                                            duration: playDuration - 200.ms)
                                        .flip(),
                                    SizedBox(
                                      height: 7.h,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            localeState.value.languageCode ==
                                                    'en'
                                                ? diffEnText(diff)
                                                : diffText(diff),
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          )
                                              .animate()
                                              .fadeIn(
                                                  duration: 300.ms,
                                                  delay: playDuration,
                                                  curve: Curves.decelerate)
                                              .slideX(begin: 0.2, end: 0),
                                          localeState.value.languageCode == 'en'
                                              ? Text(
                                                  state.posts[index].title!,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17.sp,
                                                  ),
                                                )
                                                  .animate()
                                                  .fadeIn(
                                                      duration: 300.ms,
                                                      delay: playDuration,
                                                      curve: Curves.decelerate)
                                                  .slideX(begin: 0.2, end: 0)
                                              : Text(
                                                  state.posts[index].titleAr!,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17.sp,
                                                  ),
                                                )
                                                  .animate()
                                                  .fadeIn(
                                                      duration: 300.ms,
                                                      delay: playDuration,
                                                      curve: Curves.decelerate)
                                                  .slideX(begin: 0.2, end: 0),
                                          Text("${AppLocalizations.of(context)!.translate('source')}: ${state.posts[index].source!}")
                                              .animate()
                                              .scaleXY(
                                                  begin: 0,
                                                  end: 1,
                                                  delay: 300.ms,
                                                  duration:
                                                      playDuration - 100.ms,
                                                  curve: Curves.decelerate),
                                          Visibility(
                                            visible: isvisivle ==
                                                state.posts[index].id!,
                                            child: Column(
                                              children: [
                                                const Divider(),
                                                localeState.value
                                                            .languageCode ==
                                                        'en'
                                                    ? Text(
                                                        state.posts[index]
                                                            .content!,
                                                        maxLines: 1000,
                                                      )
                                                    : Text(
                                                        state.posts[index]
                                                            .contentAr!,
                                                        maxLines: 1000,
                                                      ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    if (isvisivle ==
                                                        state
                                                            .posts[index].id!) {
                                                      isvisivle = 0;
                                                    } else {
                                                      isvisivle = state
                                                          .posts[index].id!;
                                                    }
                                                  });
                                                },
                                                child: !(isvisivle ==
                                                        state.posts[index].id!)
                                                    ? Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .translate(
                                                                'read_more'),
                                                        style: TextStyle(
                                                            color: Colors
                                                                .blue[300]),
                                                      )
                                                    : Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .translate(
                                                                'read_less'),
                                                        style: TextStyle(
                                                            color: Colors
                                                                .blue[300]),
                                                      ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ]),
                            ).animate().slideX(
                                duration: 200.ms,
                                delay: 0.ms,
                                begin: 1,
                                end: 0,
                                curve: Curves.easeInOutSine);
                          },
                        );
                      } else if (state is PostLoadedFailed) {
                        return Center(
                          child: InkWell(
                            onTap: () {
                              BlocProvider.of<PostBloc>(context)
                                  .add(PostLoadEvent());
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!
                                      .translate('loading_error'),
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const Icon(
                                  Icons.refresh,
                                  color: Colors.grey,
                                )
                              ],
                            ),
                          ),
                        );
                      } else {
                        return const CalculatorLoadingScreen();
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
