import 'package:flutter/material.dart';

void main() {
  runApp(const PlannerApp());
}

class PlannerApp extends StatelessWidget {
  const PlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const SplitDashboard(),
    );
  }
}

class SplitDashboard extends StatefulWidget {
  const SplitDashboard({super.key});

  @override
  State<SplitDashboard> createState() => _SplitDashboardState();
}

class _SplitDashboardState extends State<SplitDashboard> {
  // --- APP STATE (DATA) ---
  final List<String> _priorities = [];
  final List<bool> _priorityStates = [];

  final List<String> _todos = [];
  final List<bool> _todoStates = [];

  final List<String> _scheduleTimes = [];
  final List<String> _scheduleTasks = [];

  // Controllers for text inputs
  final TextEditingController _priorityInputController = TextEditingController();
  final TextEditingController _todoInputController = TextEditingController();
  final TextEditingController _timeInputController = TextEditingController();
  final TextEditingController _scheduleTaskInputController = TextEditingController();

  bool get _allPrioritiesCompleted {
    return _priorities.length == 3 && !_priorityStates.contains(false);
  }

  @override
  void dispose() {
    _priorityInputController.dispose();
    _todoInputController.dispose();
    _timeInputController.dispose();
    _scheduleTaskInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 Daily Time Planner'),
        centerTitle: true,
      ),
      // LayoutBuilder inspects the dimensions of whatever device screen opens the app
      body: LayoutBuilder(
        builder: (context, constraints) {
          // If the width is narrow (like a phone screen), use mobile layout
          if (constraints.maxWidth < 600) {
            return _buildMobileLayout();
          } else {
            // If the width is wide (desktop/tablet), keep the original side-by-side view
            return _buildTabletDesktopLayout();
          }
        },
      ),
    );
  }

  // ================= MOBILE VIEW (Stacked Vertically) =================
  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPrioritiesSection(),
                const Divider(height: 40),
                _buildTodoSection(),
                const Divider(height: 40),
                _buildScheduleSection(),
              ],
            ),
          ),
        ),
        _buildRewardBanner(),
      ],
    );
  }

  // ================= TABLET/DESKTOP VIEW (Side-by-Side) =================
  Widget _buildTabletDesktopLayout() {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.grey.withOpacity(0.2))),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPrioritiesSection(),
                        const Divider(height: 40),
                        _buildTodoSection(),
                      ],
                    ),
                  ),
                ),
              ),
              // Right Column
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: _buildScheduleSection(),
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildRewardBanner(),
      ],
    );
  }

  // ================= REUSABLE UI SECTIONS =================

  Widget _buildPrioritiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('🎯 TOP 3 PRIORITIES', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
            Text('${_priorities.length}/3', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _priorityInputController,
                enabled: _priorities.length < 3,
                decoration: InputDecoration(
                  hintText: _priorities.length < 3 ? 'Add priority #${_priorities.length + 1}...' : 'Max 3 priorities set!',
                  hintStyle: const TextStyle(fontSize: 13),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: _priorities.length < 3 ? Colors.amber : Colors.grey),
              onPressed: _priorities.length < 3 ? () {
                if (_priorityInputController.text.trim().isNotEmpty) {
                  setState(() {
                    _priorities.add(_priorityInputController.text.trim());
                    _priorityStates.add(false);
                    _priorityInputController.clear();
                  });
                }
              } : null,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _priorities.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('No priorities added yet.', style: TextStyle(color: Colors.grey, fontSize: 13)),
              )
            : Column(
                children: List.generate(_priorities.length, (index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: _priorityStates[index] ? Colors.green.withOpacity(0.1) : null,
                    child: ListTile(
                      dense: true,
                      leading: Icon(_priorityStates[index] ? Icons.star : Icons.star_border, color: Colors.amber, size: 20),
                      title: Text(
                        _priorities[index],
                        style: TextStyle(
                          fontSize: 14,
                          decoration: _priorityStates[index] ? TextDecoration.lineThrough : null,
                          color: _priorityStates[index] ? Colors.grey : null,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(_priorityStates[index] ? Icons.check_circle : Icons.radio_button_unchecked, color: _priorityStates[index] ? Colors.green : Colors.grey),
                            onPressed: () {
                              setState(() { _priorityStates[index] = !_priorityStates[index]; });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                            onPressed: () {
                              setState(() {
                                _priorities.removeAt(index);
                                _priorityStates.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
      ],
    );
  }

  Widget _buildTodoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('📝 TO-DO LIST', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _todoInputController,
                decoration: const InputDecoration(hintText: 'Add a new to-do task...', hintStyle: TextStyle(fontSize: 13)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.greenAccent),
              onPressed: () {
                if (_todoInputController.text.trim().isNotEmpty) {
                  setState(() {
                    _todos.add(_todoInputController.text.trim());
                    _todoStates.add(false);
                    _todoInputController.clear();
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        _todos.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('No general tasks added yet.', style: TextStyle(color: Colors.grey, fontSize: 13)),
              )
            : Column(
                children: List.generate(_todos.length, (index) {
                  return Row(
                    children: [
                      Checkbox(
                        value: _todoStates[index],
                        activeColor: Colors.green,
                        onChanged: (val) {
                          setState(() { _todoStates[index] = val ?? false; });
                        },
                      ),
                      Expanded(
                        child: Text(
                          _todos[index],
                          style: TextStyle(
                            fontSize: 14,
                            decoration: _todoStates[index] ? TextDecoration.lineThrough : null,
                            color: _todoStates[index] ? Colors.grey : null,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 18),
                    onPressed: () {
                      setState(() {
                        _todos.removeAt(index);
                        _todoStates.removeAt(index);
                      });
                    },
                  ),
                ],
              );
            }),
          ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.alarm, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text('SCHEDULE TIME', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SizedBox(
              width: 80, 
              child: TextField(
                controller: _timeInputController,
                decoration: const InputDecoration(hintText: '12:00 PM', hintStyle: TextStyle(fontSize: 12, color: Colors.grey)),
                style: const TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _scheduleTaskInputController,
                decoration: const InputDecoration(hintText: 'Enter schedule event...', hintStyle: TextStyle(fontSize: 13)),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.blueAccent),
              onPressed: () {
                if (_timeInputController.text.trim().isNotEmpty && _scheduleTaskInputController.text.trim().isNotEmpty) {
                  setState(() {
                    _scheduleTimes.add(_timeInputController.text.trim());
                    _scheduleTasks.add(_scheduleTaskInputController.text.trim());
                    _timeInputController.clear();
                    _scheduleTaskInputController.clear();
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        _scheduleTimes.isEmpty
            ? const Text('Your timeline is empty. Add events above!', style: TextStyle(color: Colors.grey, fontSize: 13))
            : Column(
                children: List.generate(_scheduleTimes.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_scheduleTimes[index], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14)),
                        const SizedBox(width: 16),
                        Expanded(child: Text(_scheduleTasks[index], style: const TextStyle(fontSize: 14))),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.clear, color: Colors.grey, size: 16),
                          onPressed: () {
                            setState(() {
                              _scheduleTimes.removeAt(index);
                              _scheduleTasks.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ),
      ],
    );
  }

  Widget _buildRewardBanner() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: double.infinity,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _allPrioritiesCompleted ? Colors.amber.withOpacity(0.2) : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _allPrioritiesCompleted ? Colors.amber : Colors.blueAccent.withOpacity(0.3),
          width: _allPrioritiesCompleted ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_allPrioritiesCompleted ? Icons.lock_open : Icons.lock, color: _allPrioritiesCompleted ? Colors.amber : Colors.grey, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_allPrioritiesCompleted ? '🎉 REWARD UNLOCKED!' : '🔒 GRAND REWARD LOCKED', style: TextStyle(fontWeight: FontWeight.bold, color: _allPrioritiesCompleted ? Colors.amber : Colors.blueAccent)),
                const SizedBox(height: 2),
                Text(
                  _allPrioritiesCompleted ? 'Enjoy an hour of video games! You earned it!' : 'Complete all 3 priorities above to unlock your reward!',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}