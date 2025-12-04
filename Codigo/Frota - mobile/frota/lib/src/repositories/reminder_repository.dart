import '../models/reminder.dart';

class ReminderRepository {
  final List<Reminder> _mockReminders = [
    Reminder(
      id: '1',
      vehicleId: '1',
      title: 'Verificar calibragem dos pneus',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isCompleted: false,
    ),
    Reminder(
      id: '2',
      vehicleId: '1',
      title: 'Verificar trincado no vidro',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isCompleted: false,
    ),
    Reminder(
      id: '3',
      vehicleId: '1',
      title: 'Verificar banco rasgado',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isCompleted: false,
    ),
    Reminder(
      id: '4',
      vehicleId: '1',
      title: 'Botar vulcão do brega no pendrive',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      isCompleted: false,
    ),
    Reminder(
      id: '5',
      vehicleId: '1',
      title: 'Lavar o carro',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      isCompleted: false,
    ),
  ];

  // Obter lembretes para um veículo específico
  Future<List<Reminder>> getRemindersForVehicle(String vehicleId) async {
    return _mockReminders
        .where((reminder) => reminder.vehicleId == vehicleId)
        .toList();
  }

  // Marcar um lembrete como concluído
  Future<Reminder> markReminderAsCompleted(String reminderId) async {
    final index = _mockReminders.indexWhere((reminder) => reminder.id == reminderId);
    if (index != -1) {
      final updatedReminder = _mockReminders[index].copyWith(isCompleted: true);
      _mockReminders[index] = updatedReminder;
      return updatedReminder;
    }
    
    throw Exception('Lembrete não encontrado');
  }

  // Adicionar um novo lembrete
  Future<Reminder> addReminder({
    required String vehicleId,
    required String title,
    String? description,
  }) async {
    final newReminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      vehicleId: vehicleId,
      title: title,
      description: description,
      createdAt: DateTime.now(),
      isCompleted: false,
    );
    
    _mockReminders.add(newReminder);
    return newReminder;
  }
}
