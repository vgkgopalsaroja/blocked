import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide/routing/routing.dart';

class NavigatorCubit extends Cubit<AppRoutePath> {
  NavigatorCubit(AppRoutePath initialPath) : super(initialPath);

  void navigateToLevelSelection() {
    emit(const LevelRoutePath.levelSelection());
  }

  void navigateToLevel(String levelId) {
    emit(LevelRoutePath.level(id: levelId));
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
      EditorRoutePath editorRoutePath = state as EditorRoutePath;
      if (editorRoutePath.isInPreview) {
        emit(EditorRoutePath.editor(editorRoutePath.mapString));
      } else {
        emit(const LevelRoutePath.levelSelection());
      }
    }
  }
}
