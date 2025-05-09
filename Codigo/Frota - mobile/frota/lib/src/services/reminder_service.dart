import '../repositories/reminder_repository.dart';
import '../models/reminder.dart';

class ReminderService {
  final ReminderRepository _reminderRepository = ReminderRepository();
  
  // Obter lembretes para um veículo
  Future<List<Reminder>> getRemindersForVehicle(String vehicleId) async {
    try {
      return await _reminderRepository.getRemindersForVehicle(vehicleId);
    } catch (e) {
      // Em um app real, você pode querer registrar o erro
      return [];
    }
  }
  
  // Marcar lembrete como concluído
  Future<Reminder?> markReminderAsCompleted(String reminderId) async {
    try {
      return await _reminderRepository.markReminderAsCompleted(reminderId);
    } catch (e) {
      // Em um app real, você pode querer registrar o erro
      return null;
    }
  }
  
  // Adicionar lembrete
  Future<Reminder?> addReminder({
    required String vehicleId,
    required String title,
    String? description,
  }) async {
    try {
      return await _reminderRepository.addReminder(
        vehicleId: vehicleId,
        title: title,
        description: description,
      );
    } catch (e) {
      // Em um app real, você pode querer registrar o erro
      return null;
    }
  }
}
