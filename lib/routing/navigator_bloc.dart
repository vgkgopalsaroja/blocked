import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/routing/app_route_path.dart';

class NavigationCubit extends Cubit<AppRoutePath> {
  NavigationCubit() : super(const AppRoutePath.levelSelection());

  void navigateToLevelSelection() {
    emit(const AppRoutePath.levelSelection());
  }

  void navigateToLevel(String levelId) {
    emit(AppRoutePath.level(id: levelId));
  }

  void navigateToEditor() {
    emit(const AppRoutePath.editor());
  }

  void navigateToPreviousPage() {
    emit(const AppRoutePath.levelSelection());
  }
}
