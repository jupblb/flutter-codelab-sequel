import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyAppStateCurrent()),
        ChangeNotifierProvider(create: (_) => MyAppStateFavorites()),
      ],
      child: MaterialApp.router(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        routerConfig: GoRouter(
          initialLocation: '/generator',
          routes: [
            GoRoute(
              path: '/generator',
              pageBuilder: (context, state) =>
                  _transition(context, state, MyHomePage(0, GeneratorPage())),
            ),
            GoRoute(
              path: '/favorites',
              pageBuilder: (context, state) =>
                  _transition(context, state, MyHomePage(1, FavoritesPage())),
            ),
          ],
        ),
      ),
    );
  }

  Page<dynamic> _transition(
      BuildContext context, GoRouterState state, Widget child) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
}

class MyAppStateCurrent extends ChangeNotifier {
  MyAppStateCurrent() {
    () async {
      while (true) {
        await Future.delayed(const Duration(seconds: 3));
        getNext();
      }
    }();
  }

  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}

class MyAppStateFavorites extends ChangeNotifier {
  var favorites = <WordPair>[];

  void toggleFavorite(WordPair word) {
    if (favorites.contains(word)) {
      favorites.remove(word);
    } else {
      favorites.add(word);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  final int selectedIndex;
  final Widget child;

  const MyHomePage(this.selectedIndex, this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  switch (value) {
                    case 0:
                      context.go('/generator');
                      break;
                    case 1:
                      context.go('/favorites');
                      break;
                  }
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: child,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugPrint("REBUILDING GeneratorPage ${DateTime.now().toString()}");

    var appStateC = context.watch<MyAppStateCurrent>();
    var appStateF = context.watch<MyAppStateFavorites>();
    var pair = appStateC.current;

    IconData icon;
    if (appStateF.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appStateF.toggleFavorite(pair);
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: null,
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugPrint("REBUILDING FavoritesPage ${DateTime.now().toString()}");

    var appState = context.watch<MyAppStateFavorites>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}
