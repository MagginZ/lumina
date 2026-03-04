import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'services/ai_service.dart';
import 'services/database_service.dart';
import 'screens/books_view.dart';
import 'screens/search_view.dart';
import 'screens/editor_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}');
  };

  runZonedGuarded(() async {
    try {
      await DatabaseService.init();
      try {
        await dotenv.load(fileName: 'env');
      } catch (_) {}
      final apiKey = (dotenv.env['OPENROUTER_API_KEY'] ?? '').trim();
      if (apiKey.isNotEmpty) AiService.init(apiKey);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
      );
      runApp(const LuminaNotesApp());
      _setupAppLifecycle();
    } catch (e, st) {
      debugPrint('Init failed: $e\n$st');
      runApp(_ErrorApp('初始化失败: $e'));
    }
  }, (error, stack) {
    debugPrint('Uncaught: $error\n$stack');
    runApp(_ErrorApp('启动错误: $error'));
  });
}

void _setupAppLifecycle() {
  WidgetsBinding.instance.addObserver(
    _AppLifecycleObserver(),
  );
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _flushHive();
    }
  }

  Future<void> _flushHive() async {
    try {
      await DatabaseService.flush();
    } catch (_) {}
  }
}

class _ErrorApp extends StatelessWidget {
  final String message;
  const _ErrorApp(this.message);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(message, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LuminaNotesApp extends StatelessWidget {
  const LuminaNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..loadData(),
      child: MaterialApp(
        title: 'Lumina 笔记',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const LuminaNotesHome(),
      ),
    );
  }
}

class LuminaNotesHome extends StatelessWidget {
  const LuminaNotesHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (state.isLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    '加载中...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }
        if (state.loadError != null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('加载失败：${state.loadError}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => state.loadData(),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final screenWidth = MediaQuery.of(context).size.width;
        return Container(
          width: screenWidth > 430 ? 430 : screenWidth,
          margin: EdgeInsets.symmetric(
            horizontal: screenWidth > 430 ? (screenWidth - 430) / 2 : 0,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: _getSlideOffset(state.currentView),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _buildView(state),
          ),
        );
      },
    );
  }

  Offset _getSlideOffset(AppView view) {
    switch (view) {
      case AppView.books:
        return const Offset(-0.05, 0);
      case AppView.search:
        return const Offset(0, 0.05);
      case AppView.editor:
        return const Offset(0.05, 0);
    }
  }

  Widget _buildView(AppState state) {
    switch (state.currentView) {
      case AppView.books:
        return const BooksView(key: ValueKey('books'));
      case AppView.search:
        return const SearchView(key: ValueKey('search'));
      case AppView.editor:
        if (state.selectedNote != null) {
          return EditorView(
            key: ValueKey('editor-${state.selectedNote!.id}'),
            note: state.selectedNote!,
          );
        }
        return const BooksView(key: ValueKey('books'));
    }
  }
}
