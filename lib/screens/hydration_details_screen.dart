import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';

class HydrationDetailsScreen extends StatefulWidget {
  final String taskId;

  const HydrationDetailsScreen({
    super.key,
    required this.taskId,
  });

  @override
  State<HydrationDetailsScreen> createState() => _HydrationDetailsScreenState();
}

class _HydrationDetailsScreenState extends State<HydrationDetailsScreen> {
  final List<int> _standardGoals = [1500, 2000, 2500, 3000];
  final List<int> _standardDrinkAmounts = [150, 200, 250, 300, 500];

  // --- Custom Goal Dialog ---
  void _showCustomGoalDialog(BuildContext context, AppState state, RPGTask task) {
    final controller = TextEditingController(text: (task.waterGoalMl / 1000).toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF162033),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.water_drop, color: Color(0xFF38BDF8)),
            SizedBox(width: 8),
            Text('Custom Daily Water Goal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your daily target in Liters (e.g. 2.8 L):',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              decoration: InputDecoration(
                suffixText: 'L',
                suffixStyle: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 2)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final val = double.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                final goalMl = (val * 1000).round();
                state.updateWaterGoal(task.id, goalMl);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save Target', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- Custom Drink Amount Dialog ---
  void _showCustomDrinkAmountDialog(BuildContext context, AppState state, RPGTask task) {
    final controller = TextEditingController(text: '${task.drinkAmountMl}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF162033),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.local_drink, color: Color(0xFF38BDF8)),
            SizedBox(width: 8),
            Text('Custom Drink Amount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter default amount per drink in milliliters (ml):',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              decoration: InputDecoration(
                suffixText: 'ml',
                suffixStyle: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 2)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                state.updateDrinkAmount(task.id, val);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save Amount', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- Custom Quick Add Dialog ---
  void _showCustomAddDialog(BuildContext context, AppState state, RPGTask task) {
    final controller = TextEditingController(text: '${task.drinkAmountMl}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF162033),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.add_circle, color: Color(0xFF38BDF8)),
            SizedBox(width: 8),
            Text('Add Custom Water', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter water volume consumed in ml:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              decoration: InputDecoration(
                suffixText: 'ml',
                suffixStyle: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 2)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                state.addWater(task.id, val, context);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Drink Water', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- Add / Edit Reminder Bottom Sheet ---
  void _showAddEditReminderSheet(BuildContext context, AppState state, RPGTask task, [HydrationReminder? existingReminder]) {
    TimeOfDay selectedTime = existingReminder != null
        ? TimeOfDay(hour: existingReminder.hour, minute: existingReminder.minute)
        : TimeOfDay.now();
    int selectedAmount = existingReminder?.amountMl ?? task.drinkAmountMl;
    String selectedRepeat = existingReminder?.repeat ?? 'Every Day';
    final customAmountCtrl = TextEditingController(text: '$selectedAmount');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF162033),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final formattedTime = selectedTime.format(context);

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.alarm_add, color: Color(0xFFF5B942), size: 24),
                          const SizedBox(width: 8),
                          Text(
                            existingReminder == null ? 'Add Water Reminder' : 'Edit Water Reminder',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                        onPressed: () => Navigator.pop(sheetCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 1. Reminder Time Picker
                  const Text('REMINDER TIME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.1)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setSheetState(() => selectedTime = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.schedule, color: Color(0xFF38BDF8), size: 20),
                              const SizedBox(width: 10),
                              Text(formattedTime, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Text('Change', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Amount per Reminder
                  const Text('DRINK AMOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.1)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...[150, 200, 250, 300, 500].map((amt) {
                        final isSel = selectedAmount == amt;
                        return ChoiceChip(
                          label: Text('$amt ml'),
                          selected: isSel,
                          selectedColor: const Color(0xFF38BDF8),
                          backgroundColor: const Color(0xFF0F172A),
                          labelStyle: TextStyle(
                            color: isSel ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setSheetState(() {
                                selectedAmount = amt;
                                customAmountCtrl.text = '$amt';
                              });
                            }
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. Repeat Pattern
                  const Text('REPEAT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.1)),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Every Day', 'Weekdays', 'Weekends'].map((rep) {
                      final isSel = selectedRepeat == rep;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(rep),
                          selected: isSel,
                          selectedColor: const Color(0xFFF5B942),
                          backgroundColor: const Color(0xFF0F172A),
                          labelStyle: TextStyle(
                            color: isSel ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) {
                            if (val) setSheetState(() => selectedRepeat = rep);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final timeStr = selectedTime.format(context);
                      if (existingReminder == null) {
                        final newRem = HydrationReminder(
                          id: 'rem_${DateTime.now().millisecondsSinceEpoch}',
                          time: timeStr,
                          hour: selectedTime.hour,
                          minute: selectedTime.minute,
                          amountMl: selectedAmount,
                          repeat: selectedRepeat,
                          isEnabled: true,
                        );
                        state.addHydrationReminder(task.id, newRem);
                      } else {
                        existingReminder.time = timeStr;
                        existingReminder.hour = selectedTime.hour;
                        existingReminder.minute = selectedTime.minute;
                        existingReminder.amountMl = selectedAmount;
                        existingReminder.repeat = selectedRepeat;
                        state.updateHydrationReminder(task.id, existingReminder);
                      }
                      Navigator.pop(sheetCtx);
                    },
                    child: const Text('SAVE REMINDER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- Hydration Settings Modal Bottom Sheet ---
  void _showHydrationSettingsSheet(BuildContext context, AppState state, RPGTask task) {
    TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 20, minute: 0);
    int intervalMinutes = task.reminderIntervalMinutes;
    bool notifs = task.notificationsEnabled;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF162033),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.settings, color: Color(0xFFF5B942), size: 24),
                          SizedBox(width: 8),
                          Text('Hydration Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                        onPressed: () => Navigator.pop(sheetCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Notifications Toggle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.notifications_active, color: Color(0xFF38BDF8), size: 22),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Hydration Reminders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                Text('Alert when it is time to drink', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: notifs,
                          activeThumbColor: const Color(0xFF38BDF8),
                          onChanged: (val) {
                            setSheetState(() => notifs = val);
                            state.updateHydrationSettings(task.id, notificationsEnabled: val);
                            // TODO: Integrate with flutter_local_notifications plugin when adding native local notification dependencies
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Schedule Interval Selector
                  const Text('REMINDER FREQUENCY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.1)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [60, 90, 120, 180].map((mins) {
                      final isSel = intervalMinutes == mins;
                      final label = mins == 60 ? 'Every 1 hr' : mins == 90 ? 'Every 1.5 hrs' : mins == 120 ? 'Every 2 hrs' : 'Every 3 hrs';
                      return ChoiceChip(
                        label: Text(label),
                        selected: isSel,
                        selectedColor: const Color(0xFF38BDF8),
                        backgroundColor: const Color(0xFF0F172A),
                        labelStyle: TextStyle(
                          color: isSel ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (val) {
                          if (val) setSheetState(() => intervalMinutes = mins);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Start and End Times
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('START TIME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final p = await showTimePicker(context: context, initialTime: startTime);
                                if (p != null) setSheetState(() => startTime = p);
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF334155)),
                                ),
                                child: Text(startTime.format(context), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('END TIME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final p = await showTimePicker(context: context, initialTime: endTime);
                                if (p != null) setSheetState(() => endTime = p);
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF334155)),
                                ),
                                child: Text(endTime.format(context), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Auto-generate Schedule Button
                  OutlinedButton.icon(
                    icon: const Icon(Icons.auto_awesome, color: Color(0xFFF5B942), size: 18),
                    label: const Text('AUTO-GENERATE DRINKING SCHEDULE'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF5B942),
                      side: const BorderSide(color: Color(0xFFF5B942)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      state.generateHydrationSchedule(
                        task.id,
                        startTime: startTime,
                        endTime: endTime,
                        intervalMinutes: intervalMinutes,
                        drinkAmountMl: task.drinkAmountMl,
                      );
                      Navigator.pop(sheetCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✨ Hydration schedule auto-generated!'),
                          backgroundColor: Color(0xFF22C55E),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final taskIndex = state.tasks.indexWhere((t) => t.id == widget.taskId);

    if (taskIndex == -1) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0F1C),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A0F1C),
          title: const Text('Hydration Quest', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: Text('Hydration Quest not found.', style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    final task = state.tasks[taskIndex];
    final stats = state.getHydrationStats(task);

    final currentLiters = (task.currentWaterMl / 1000).toStringAsFixed(1);
    final goalLiters = (task.waterGoalMl / 1000).toStringAsFixed(1);
    final remainingMl = (task.waterGoalMl - task.currentWaterMl).clamp(0, 99999);
    final remainingL = (remainingMl / 1000).toStringAsFixed(1);
    final progress = (task.waterGoalMl > 0 ? (task.currentWaterMl / task.waterGoalMl) : 0.0).clamp(0.0, 1.0);
    final percentInt = (progress * 100).toInt();

    const cardBg = Color(0xFF162033);
    const borderColor = Color(0xFF1E293B);
    const brightAqua = Color(0xFF38BDF8);
    const goldColor = Color(0xFFF5B942);
    const successGreen = Color(0xFF22C55E);

    final nextReminder = task.getNextReminder();
    final missedReminders = task.getMissedReminders();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F1C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.water_drop, color: Color(0xFF38BDF8), size: 22),
            SizedBox(width: 8),
            Text(
              'Hydration Quest',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF94A3B8)),
            tooltip: 'Hydration Settings',
            onPressed: () => _showHydrationSettingsSheet(context, state, task),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // ==========================================
          // 1. WATER QUEST HEADER & PROGRESS VESSEL
          // ==========================================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: brightAqua.withValues(alpha: 0.35), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: brightAqua.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category & Badges Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: brightAqua.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.water_drop, color: brightAqua, size: 20),
                        ),
                        const SizedBox(width: 8),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '💧 Health / Hydration',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: brightAqua),
                            ),
                            Text(
                              'Daily Water Goal',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (task.isCompleted ? successGreen : brightAqua).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: task.isCompleted ? successGreen : brightAqua),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            task.isCompleted ? Icons.check_circle : Icons.water_drop,
                            color: task.isCompleted ? successGreen : brightAqua,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task.isCompleted ? 'Goal Met' : '$percentInt%',
                            style: TextStyle(
                              color: task.isCompleted ? successGreen : brightAqua,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Quest Perks (XP & Streak Habit)
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: goldColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: goldColor.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: goldColor, size: 14),
                          SizedBox(width: 4),
                          Text('+50 XP', style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.deepOrange.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_fire_department, color: Colors.deepOrangeAccent, size: 14),
                          SizedBox(width: 4),
                          Text('Daily Habit', style: TextStyle(color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Volume numbers
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$currentLiters L',
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: brightAqua),
                    ),
                    Text(
                      ' / $goalLiters L',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                    ),
                    const Spacer(),
                    Text(
                      task.isCompleted ? 'Goal Completed! 🎉' : 'Remaining: ${remainingMl >= 1000 ? "$remainingL L" : "$remainingMl ml"}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: task.isCompleted ? successGreen : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Animated Fluid Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 18,
                    color: const Color(0xFF0F172A),
                    child: Stack(
                      children: [
                        AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF0284C7),
                                  task.isCompleted ? successGreen : brightAqua,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Next reminder alert banner
                if (nextReminder != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule, color: brightAqua, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Next reminder: ${nextReminder.time} — ${nextReminder.amountMl} ml',
                            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ==========================================
          // 2. SET DAILY WATER GOAL & AMOUNT PER DRINK
          // ==========================================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DAILY WATER GOAL',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 8),

                // Stepper UI: [ - ]  [ 2.5 L ]  [ + ]
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        final newGoal = (task.waterGoalMl - 250).clamp(500, 10000);
                        state.updateWaterGoal(task.id, newGoal);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: const Icon(Icons.remove, color: Colors.white, size: 20),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showCustomGoalDialog(context, state, task),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: brightAqua, width: 1.5),
                        ),
                        child: Text(
                          '$goalLiters L',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        final newGoal = (task.waterGoalMl + 250).clamp(500, 10000);
                        state.updateWaterGoal(task.id, newGoal);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Target presets
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ..._standardGoals.map((g) {
                        final isSel = task.waterGoalMl == g;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: ChoiceChip(
                            label: Text('${(g / 1000).toStringAsFixed(1)} L'),
                            selected: isSel,
                            selectedColor: goldColor,
                            backgroundColor: const Color(0xFF0F172A),
                            labelStyle: TextStyle(
                              color: isSel ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            onSelected: (val) {
                              if (val) state.updateWaterGoal(task.id, g);
                            },
                          ),
                        );
                      }),
                      ActionChip(
                        avatar: const Icon(Icons.tune, size: 14, color: brightAqua),
                        label: const Text('Custom'),
                        backgroundColor: const Color(0xFF0F172A),
                        labelStyle: const TextStyle(color: brightAqua, fontWeight: FontWeight.bold, fontSize: 12),
                        onPressed: () => _showCustomGoalDialog(context, state, task),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFF1E293B), height: 28),

                // Amount per drink
                const Text(
                  'AMOUNT PER DRINK',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ..._standardDrinkAmounts.map((amt) {
                        final isSel = task.drinkAmountMl == amt;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: ChoiceChip(
                            label: Text('$amt ml'),
                            selected: isSel,
                            selectedColor: brightAqua,
                            backgroundColor: const Color(0xFF0F172A),
                            labelStyle: TextStyle(
                              color: isSel ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            onSelected: (val) {
                              if (val) state.updateDrinkAmount(task.id, amt);
                            },
                          ),
                        );
                      }),
                      ActionChip(
                        avatar: const Icon(Icons.edit, size: 14, color: goldColor),
                        label: Text(!_standardDrinkAmounts.contains(task.drinkAmountMl) ? '${task.drinkAmountMl} ml' : 'Custom'),
                        backgroundColor: const Color(0xFF0F172A),
                        labelStyle: const TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 12),
                        onPressed: () => _showCustomDrinkAmountDialog(context, state, task),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ==========================================
          // 3. MISSED REMINDERS ALERT (IF ANY)
          // ==========================================
          if (missedReminders.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'MISSED REMINDER',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...missedReminders.map((rem) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '⚠️ Missed ${rem.time}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              '${rem.amountMl} ml scheduled drink',
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.water_drop, size: 16),
                          label: const Text('Drink Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => state.completeHydrationReminder(task.id, rem.id, context),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ==========================================
          // 4. QUICK ADD WATER
          // ==========================================
          const Text(
            '💧 QUICK ADD',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildQuickAddButton(context, state, task, 150, '+150 ml', Icons.local_drink)),
              const SizedBox(width: 8),
              Expanded(child: _buildQuickAddButton(context, state, task, 250, '+250 ml', Icons.water_drop)),
              const SizedBox(width: 8),
              Expanded(child: _buildQuickAddButton(context, state, task, 500, '+500 ml', Icons.sports_bar)),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.add_circle_outline, color: brightAqua),
            label: const Text('+ Add Custom Amount'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF334155)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _showCustomAddDialog(context, state, task),
          ),
          const SizedBox(height: 24),

          // ==========================================
          // 5. DRINKING SCHEDULE
          // ==========================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.schedule, color: goldColor, size: 18),
                  SizedBox(width: 6),
                  Text(
                    '⏰ DRINKING SCHEDULE',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 16, color: brightAqua),
                label: const Text('Add Reminder', style: TextStyle(color: brightAqua, fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: () => _showAddEditReminderSheet(context, state, task),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (task.reminders.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.alarm_off, color: Color(0xFF64748B), size: 36),
                    const SizedBox(height: 8),
                    const Text('No drinking times scheduled.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showAddEditReminderSheet(context, state, task),
                      child: const Text('Create Reminder', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: task.reminders.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (ctx, idx) {
                final rem = task.reminders[idx];
                final isMissed = rem.isMissed();

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMissed
                        ? Colors.red.withValues(alpha: 0.1)
                        : rem.isCompleted
                            ? successGreen.withValues(alpha: 0.08)
                            : cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isMissed
                          ? Colors.redAccent.withValues(alpha: 0.5)
                          : rem.isCompleted
                              ? successGreen.withValues(alpha: 0.4)
                              : borderColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Status icon / checkmark
                      GestureDetector(
                        onTap: () {
                          if (!rem.isCompleted) {
                            state.completeHydrationReminder(task.id, rem.id, context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: rem.isCompleted
                                ? successGreen
                                : isMissed
                                    ? Colors.redAccent.withValues(alpha: 0.2)
                                    : const Color(0xFF0F172A),
                            border: Border.all(
                              color: rem.isCompleted
                                  ? successGreen
                                  : isMissed
                                      ? Colors.redAccent
                                      : const Color(0xFF64748B),
                            ),
                          ),
                          child: Icon(
                            rem.isCompleted
                                ? Icons.check
                                : isMissed
                                    ? Icons.priority_high
                                    : Icons.circle_outlined,
                            size: 16,
                            color: rem.isCompleted ? Colors.black : isMissed ? Colors.redAccent : Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Time & Amount
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  rem.time,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    decoration: rem.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '💧 ${rem.amountMl} ml',
                                  style: const TextStyle(color: brightAqua, fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ],
                            ),
                            Text(
                              rem.isCompleted
                                  ? 'Completed ✓'
                                  : isMissed
                                      ? '⚠️ Missed'
                                      : rem.repeat,
                              style: TextStyle(
                                fontSize: 11,
                                color: rem.isCompleted
                                    ? successGreen
                                    : isMissed
                                        ? Colors.redAccent
                                        : const Color(0xFF94A3B8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Drink Now button if missed or pending
                      if (!rem.isCompleted)
                        Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: InkWell(
                            onTap: () => state.completeHydrationReminder(task.id, rem.id, context),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isMissed ? Colors.redAccent : brightAqua.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isMissed ? Colors.redAccent : brightAqua),
                              ),
                              child: Text(
                                'Drink Now',
                                style: TextStyle(
                                  color: isMissed ? Colors.white : brightAqua,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Reminder Notification Toggle
                      IconButton(
                        icon: Icon(
                          rem.isEnabled ? Icons.notifications_active : Icons.notifications_off_outlined,
                          size: 18,
                          color: rem.isEnabled ? goldColor : const Color(0xFF64748B),
                        ),
                        tooltip: rem.isEnabled ? 'Mute Reminder' : 'Enable Reminder',
                        onPressed: () => state.toggleHydrationReminder(task.id, rem.id, !rem.isEnabled),
                      ),

                      // Menu: Edit / Delete
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF94A3B8)),
                        color: const Color(0xFF162033),
                        onSelected: (val) {
                          if (val == 'edit') {
                            _showAddEditReminderSheet(context, state, task, rem);
                          } else if (val == 'delete') {
                            state.deleteHydrationReminder(task.id, rem.id);
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: brightAqua, size: 16),
                                SizedBox(width: 8),
                                Text('Edit', style: TextStyle(color: Colors.white, fontSize: 13)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.redAccent, size: 16),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 24),

          // ==========================================
          // 6. TODAY'S HYDRATION TIMELINE
          // ==========================================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.timeline, color: brightAqua, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "TODAY'S HYDRATION TIMELINE",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (task.reminders.isEmpty)
                  const Text('No timeline available.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13))
                else
                  Column(
                    children: task.reminders.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final rem = entry.value;
                      final isLast = idx == task.reminders.length - 1;
                      final isMissed = rem.isMissed();

                      Color stateColor = rem.isCompleted
                          ? successGreen
                          : isMissed
                              ? Colors.redAccent
                              : brightAqua;

                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Timeline bar & dot
                            Column(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: rem.isCompleted
                                        ? successGreen
                                        : isMissed
                                            ? Colors.redAccent
                                            : const Color(0xFF0F172A),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: stateColor, width: 2),
                                  ),
                                  child: Icon(
                                    rem.isCompleted
                                        ? Icons.check
                                        : isMissed
                                            ? Icons.priority_high
                                            : Icons.circle,
                                    size: 10,
                                    color: rem.isCompleted ? Colors.black : isMissed ? Colors.white : Colors.transparent,
                                  ),
                                ),
                                if (!isLast)
                                  Expanded(
                                    child: Container(
                                      width: 2,
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 14),

                            // Timeline Content
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              rem.time,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                decoration: rem.isCompleted ? TextDecoration.lineThrough : null,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text('${rem.amountMl} ml', style: TextStyle(color: stateColor, fontWeight: FontWeight.w600, fontSize: 13)),
                                          ],
                                        ),
                                        Text(
                                          rem.isCompleted
                                              ? '✓ Completed'
                                              : isMissed
                                                  ? '⚠️ Missed Drink'
                                                  : '○ Upcoming',
                                          style: TextStyle(
                                            color: stateColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isMissed && !rem.isCompleted)
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onPressed: () => state.completeHydrationReminder(task.id, rem.id, context),
                                        child: const Text('Drink Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ==========================================
          // 7. WATER STATISTICS (ACTUAL DATA)
          // ==========================================
          const Text(
            '📊 HYDRATION STATISTICS',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'TODAY',
                        value: '💧 ${stats['todayConsumedL']} L',
                        subtitle: '/ ${stats['todayGoalL']} L Target',
                        color: brightAqua,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'THIS WEEK',
                        value: '${stats['weeklyAverageL']} L',
                        subtitle: 'Average / Day',
                        color: goldColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'STREAK',
                        value: '🔥 ${stats['streakDays']} Days',
                        subtitle: 'Current Streak',
                        color: Colors.deepOrangeAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'GOAL COMPLETION',
                        value: '🏆 ${stats['goalCompletedDays']} / 7',
                        subtitle: 'Days This Week',
                        color: successGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ==========================================
          // 8. TODAY'S LOGGED ENTRIES
          // ==========================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TODAY'S WATER LOG",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Color(0xFF94A3B8)),
              ),
              Text(
                '${task.waterLogs.length} entries',
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (task.waterLogs.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.opacity, size: 36, color: Color(0xFF64748B)),
                    SizedBox(height: 8),
                    Text('No water logged yet today.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                    SizedBox(height: 4),
                    Text('Tap a Quick Add button above to log your first drink!', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: task.waterLogs.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (ctx, idx) {
                final log = task.waterLogs[idx];
                final timeFormatted = DateFormat('h:mm a').format(log.timestamp);

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: brightAqua.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.water_drop, color: brightAqua, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '+${log.amountMl} ml',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(timeFormatted, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                        tooltip: 'Undo Entry',
                        onPressed: () {
                          state.removeWaterLog(task.id, log.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Removed ${log.amountMl} ml log entry.'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(
    BuildContext context,
    AppState state,
    RPGTask task,
    int amountMl,
    String label,
    IconData icon,
  ) {
    return InkWell(
      onTap: () => state.addWater(task.id, amountMl, context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF38BDF8), size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}
