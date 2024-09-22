import 'package:camion/Localization/app_localizations.dart';
import 'package:camion/business_logic/bloc/post_bloc.dart';
import 'package:camion/business_logic/cubit/locale_cubit.dart';
import 'package:camion/views/widgets/calculator_loading_screen.dart';
import 'package:camion/views/widgets/main_screen/error_indicator.dart';
import 'package:camion/views/widgets/main_screen/post_card.dart';
import 'package:camion/views/widgets/no_reaults_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int visiblePostId = 0;

  Future<void> onRefresh() async {
    BlocProvider.of<PostBloc>(context).add(PostLoadEvent());
  }

  String getTimeDifferenceText(Duration diff, String languageCode) {
    if (diff.inSeconds < 60) {
      return languageCode == 'en'
          ? "since ${diff.inSeconds.toString()} seconds"
          : "منذ ${diff.inSeconds.toString()} ثانية";
    } else if (diff.inMinutes < 60) {
      return languageCode == 'en'
          ? "since ${diff.inMinutes.toString()} minutes"
          : "منذ ${diff.inMinutes.toString()} دقيقة";
    } else if (diff.inHours < 24) {
      return languageCode == 'en'
          ? "since ${diff.inHours.toString()} hours"
          : "منذ ${diff.inHours.toString()} ساعة";
    } else {
      return languageCode == 'en'
          ? "since ${diff.inDays.toString()} days"
          : "منذ ${diff.inDays.toString()} يوم";
    }
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
                child: BlocBuilder<PostBloc, PostState>(
                  builder: (context, state) {
                    if (state is PostLoadedSuccess) {
                      return state.posts.isEmpty
                          ? NoResultsWidget(
                              text: AppLocalizations.of(context)!
                                  .translate('no_posts'),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView.builder(
                                itemCount: state.posts.length,
                                itemBuilder: (context, index) {
                                  final post = state.posts[index];
                                  final now = DateTime.now();
                                  final diff = now.difference(post.date!);
                                  final languageCode =
                                      localeState.value.languageCode;

                                  return PostCard(
                                    post: post,
                                    diffText: getTimeDifferenceText(
                                        diff, languageCode),
                                    isVisible: visiblePostId == post.id!,
                                    onVisibilityToggle: () {
                                      setState(() {
                                        visiblePostId =
                                            visiblePostId == post.id!
                                                ? 0
                                                : post.id!;
                                      });
                                    },
                                    playDuration: playDuration,
                                    languageCode: languageCode,
                                  );
                                },
                              ),
                            );
                    } else if (state is PostLoadedFailed) {
                      return ErrorIndicator(onRetry: onRefresh);
                    } else {
                      return const CalculatorLoadingScreen();
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
