import 'package:calculate/calculator_logic.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const OneRepMaxCalculatorApp());
}

class OneRepMaxCalculatorApp extends StatelessWidget {
  const OneRepMaxCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '1RM Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightFocusNode = FocusNode();
  final _repsFocusNode = FocusNode();

  CalculationResult? _result;
  int? _reps; // Store parsed reps for warning

  void _calculate() {
    final double? weight = double.tryParse(_weightController.text);
    final int? reps = int.tryParse(_repsController.text);

    if (weight == null || reps == null || weight <= 0 || reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Пожалуйста, введите корректный вес и количество повторений.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _reps = reps; // Update _reps state
      _result = OneRepMaxCalculator.calculate(weight: weight, reps: reps);
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _weightFocusNode.dispose();
    _repsFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Кибер-Колхоз 1ПМ Калькулятор'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _weightController,
                focusNode: _weightFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Вес на штанге (кг)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_repsFocusNode);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _repsController,
                focusNode: _repsFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Количество повторений',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _calculate(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Рассчитать'),
              ),
              const SizedBox(height: 24),
              if (_result != null)
                Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Результаты Расчёта:',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              title: const Text('Средний 1ПМ'),
                              trailing: Text(
                                '${_result!.average.toStringAsFixed(1)} кг',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            ListTile(
                              title: const Text('Прогнозируемый диапазон'),
                              trailing: Text(
                                '${_result!.min.toStringAsFixed(1)} - ${_result!.max.toStringAsFixed(1)} кг',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_reps != null && _reps! > 10)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Внимание: Точность расчётов снижается для количества повторений > 10.',
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Результаты по формулам:',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ..._result!.allFormulas.entries.map((entry) {
                              if (entry.value <= 0) return const SizedBox.shrink();
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(entry.key),
                                    Text('${entry.value.toStringAsFixed(1)} кг'),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
