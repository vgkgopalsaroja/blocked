import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/routing/routing.dart';

class NavigatorCubit extends Cubit<AppRoutePath> {
  NavigatorCubit(AppRoutePath initialPath) : super(initialPath);

  /// The id of the latest level that was visited.
  /// Used by the [Hero] widgets in level selection and level pages to
  /// determine which puzzle widgets to animate to.
  String? latestLevelId;

  void navigateToLevelSelection() {
    emit(const LevelRoutePath.levelSelection());
  }

  void navigateToLevel(String levelId) {
    emit(LevelRoutePath.level(id: levelId));
    latestLevelId = levelId;
  }

  void navigateToEditor(String mapString) {
    emit(EditorRoutePath.editor(mapString));
  }

  void navigateToGeneratedLevel(String mapString) {
    emit(EditorRoutePath.generatedLevel(mapString));
  }

  void navigateToPreviousPage() {
    if (state is LevelRoutePath) {
      emit(const LevelRoutePath.levelSelection());
    } else if (state is EditorRoutePath) {
      final editorRoutePath = state as EditorRoutePath;
      if (editorRoutePath.isInPreview) {
        emit(EditorRoutePath.editor(editorRoutePath.mapString));
      } else {
        emit(const LevelRoutePath.levelSelection());
      }
    }
  }
}
