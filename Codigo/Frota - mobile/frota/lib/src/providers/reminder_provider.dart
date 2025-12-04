import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart'; // Added for WidgetsBinding
import '../models/reminder.dart';
import '../services/reminder_service.dart';

class ReminderProvider with ChangeNotifier {
  final ReminderService _reminderService = ReminderService();

  List<Reminder> _vehicleReminders = [];
  bool _isLoading = false;
  String? _error;

  List<Reminder> get vehicleReminders => _vehicleReminders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Carregar lembretes para um veículo
  Future<void> loadVehicleReminders(String vehicleId) async {
    _isLoading = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _vehicleReminders =
          await _reminderService.getRemindersForVehicle(vehicleId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Marcar lembrete como concluído
  Future<bool> markReminderAsCompleted(String reminderId) async {
    _isLoading = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final reminder =
          await _reminderService.markReminderAsCompleted(reminderId);

      if (reminder != null) {
        final index = _vehicleReminders.indexWhere((r) => r.id == reminderId);
        if (index != -1) {
          _vehicleReminders[index] = reminder;
        }
        _error = null;
        return true;
      } else {
        _error = 'Não foi possível marcar o lembrete como concluído';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Adicionar lembrete
  Future<bool> addReminder({
    required String vehicleId,
    required String title,
    String? description,
  }) async {
    _isLoading = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final reminder = await _reminderService.addReminder(
        vehicleId: vehicleId,
        title: title,
        description: description,
      );

      if (reminder != null) {
        _vehicleReminders.add(reminder);
        _error = null;
        return true;
      } else {
        _error = 'Não foi possível adicionar o lembrete';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Limpar erro
  void clearError() {
    _error = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
