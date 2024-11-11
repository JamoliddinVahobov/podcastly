import 'package:flutter_bloc/flutter_bloc.dart';

abstract class NavigationEvent {}

class NavigateToLogin extends NavigationEvent {}

class NavigateToSignup extends NavigationEvent {}

class NavigateToPodcastsPage extends NavigationEvent {}

class NavigationBloc extends Bloc<NavigationEvent, String> {
  NavigationBloc() : super('auth');

  Stream<String> mapEventToState(NavigationEvent event) {
    if (event is NavigateToLogin) {
      return Stream.value('login');
    } else if (event is NavigateToSignup) {
      return Stream.value('signup');
    } else if (event is NavigateToPodcastsPage) {
      return Stream.value('podcasts');
    }
    return Stream.value('auth');
  }
}
