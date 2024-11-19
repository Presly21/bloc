// ignore: file_names
import 'package:bloctest/btb.dart';
import 'package:bloctest/test1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Les événements du Bloc
abstract class AuthEvent {}

class LoginEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

// Les états du Bloc
abstract class AuthState {}

class AuthenticatedState extends AuthState {
  final String username;

  AuthenticatedState(this.username);
}

class UnauthenticatedState extends AuthState {}

// Le Bloc qui gère les événements et les états
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(UnauthenticatedState()) {
    on<LoginEvent>((event, emit) {
      emit(AuthenticatedState('Flutter User'));
    });

    on<LogoutEvent>((event, emit) {
      emit(UnauthenticatedState());
    });
  }
}

// Application Flutter
void main() {
  runApp(
    BlocProvider(
      create: (_) => AuthBloc(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthScreen(),
    );
  }
}

// L'écran de connexion
// ignore: use_key_in_widget_constructors
class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Bloc Auth Example')),
      body: Column(
        children: [
          const SizedBox(
            height: 200,
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CallScreen()),
                );
              },
              child: Container(
                width: 100,
                height: 50,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(20)),
                child: const Center(child: Text("Clic here")),
              ),
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Container(
                width: 100,
                height: 50,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(20)),
                child: const Center(child: Text("Test 1")),
              ),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Center(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthenticatedState) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Bienvenue, ${state.username}',
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          BlocProvider.of<AuthBloc>(context).add(LogoutEvent());
                        },
                        child: const Text('Déconnexion'),
                      ),
                    ],
                  );
                } else {
                  return ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<AuthBloc>(context).add(LoginEvent());
                    },
                    child: const Text('Connexion'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
