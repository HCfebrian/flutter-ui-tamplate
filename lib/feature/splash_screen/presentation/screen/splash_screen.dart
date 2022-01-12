import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_flutter/feature/splash_screen/presentation/bloc/splashscreen_bloc.dart';
import 'package:simple_flutter/utils/route_generator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    Key? key,
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    BlocProvider.of<SplashScreenBloc>(context).add(SplashScreenInitEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashScreenBloc, SplashScreenState>(
      listener: (context, state) {
        if (state is SplashSuccessState) {
          Navigator.pushReplacementNamed(context, AppRoute.login);
        }
      },
      child: Scaffold(
        body: Center(
          child: Image.asset('assets/image/logo.png'),
        ),
      ),
    );
  }
}
