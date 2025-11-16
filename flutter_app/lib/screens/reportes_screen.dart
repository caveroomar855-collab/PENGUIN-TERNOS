import 'package:flutter/material.dart';

class ReportesScreen extends StatelessWidget {
  const ReportesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
      ),
      body: Center(
        child: Text(
          'Aquí podrás generar reportes de alquileres y ventas.',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
