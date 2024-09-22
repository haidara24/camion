import 'package:camion/data/models/post_model.dart';
import 'package:camion/data/repositories/post_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  late PostRepository postRepository;
  PostBloc({required this.postRepository}) : super(PostInitial()) {
    on<PostLoadEvent>((event, emit) async {
      emit(PostLoadingProgress());
      try {
        var posts = await postRepository.getposts();
        emit(PostLoadedSuccess(posts));
        // ignore: empty_catches
      } catch (e) {}
    });

    on<PostSaveEvent>(
      (event, emit) {
        PostLoadedSuccess currentstate = state as PostLoadedSuccess;
        emit(PostLoadingProgress());
        for (var i = 0; i < currentstate.posts.length; i++) {
          if (currentstate.posts[i].id! == event.postId) {
            currentstate.posts[i].is_saved = event.save;
            break;
          }
        }
        emit(PostLoadedSuccess(currentstate.posts));
      },
    );
  }
}
