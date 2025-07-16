import '../models/supplier.dart';
import '../repositories/supplier_repository.dart';
import '../services/local_database_service.dart';

class SupplierService {
  final SupplierRepository _supplierRepository = SupplierRepository();

  // Obter todos os fornecedores
  Future<List<Supplier>> getAllSuppliers() async {
    try {
      return await _supplierRepository.getAllSuppliers();
    } catch (e) {
      print('Erro no serviço ao obter fornecedores: $e');
      return [];
    }
  }

  // Obter um fornecedor pelo ID
  Future<Supplier?> getSupplierById(String id) async {
    try {
      return await _supplierRepository.getSupplierById(id);
    } catch (e) {
      print('Erro no serviço ao obter fornecedor por ID: $e');
      return null;
    }
  }

  // Atualizar tabela local de fornecedores
  Future<void> updateLocalSuppliers() async {
    final suppliers = await getAllSuppliers();
    final db = LocalDatabaseService();
    if (suppliers.isNotEmpty) {
      await db.clearAndPopulateFornecedores(
        suppliers.map((s) => {'id': s.id, 'name': s.name}).toList(),
      );
    } else {
      // Se a API não retornar nada, esvazia a tabela
      await db.clearAndPopulateFornecedores([]);
    }
  }
}
