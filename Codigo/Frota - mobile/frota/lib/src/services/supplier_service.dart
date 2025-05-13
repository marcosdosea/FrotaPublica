import '../models/supplier.dart';
import '../repositories/supplier_repository.dart';

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
}
