import '../models/supplier.dart';
import '../repositories/supplier_repository.dart';
import '../services/local_database_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SupplierService {
  final SupplierRepository _supplierRepository = SupplierRepository();
  final LocalDatabaseService _localDb = LocalDatabaseService();

  // Obter todos os fornecedores (online ou offline)
  Future<List<Supplier>> getAllSuppliers() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      final isOnline = connectivity != ConnectivityResult.none;

      if (isOnline) {
        try {
          final suppliers = await _supplierRepository.getAllSuppliers();
          if (suppliers.isNotEmpty) {
            await _updateLocalSuppliers(suppliers);
            return suppliers;
          }
        } catch (e) {
          print('Erro ao carregar fornecedores online: $e');
        }
      }

      // Carregar dados locais
      final localSuppliers = await _loadLocalSuppliers();
      if (localSuppliers.isNotEmpty) {
        return localSuppliers;
      }

      // Se não há dados locais e está offline, retornar lista vazia
      return [];
    } catch (e) {
      print('Erro no serviço ao obter fornecedores: $e');
      return [];
    }
  }

  // Carregar fornecedores do banco local
  Future<List<Supplier>> _loadLocalSuppliers() async {
    try {
      final localData = await _localDb.getFornecedores();
      return localData
          .map((data) => Supplier(
                id: data['id'] as String,
                name: data['name'] as String,
              ))
          .toList();
    } catch (e) {
      print('Erro ao carregar fornecedores locais: $e');
      return [];
    }
  }

  // Atualizar fornecedores locais
  Future<void> _updateLocalSuppliers(List<Supplier> suppliers) async {
    try {
      final suppliersData = suppliers
          .map((s) => {
                'id': s.id,
                'name': s.name,
              })
          .toList();
      await _localDb.clearAndPopulateFornecedores(suppliersData);
    } catch (e) {
      print('Erro ao atualizar fornecedores locais: $e');
    }
  }

  // Obter um fornecedor pelo ID
  Future<Supplier?> getSupplierById(String id) async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      final isOnline = connectivity != ConnectivityResult.none;

      if (isOnline) {
        try {
          final supplier = await _supplierRepository.getSupplierById(id);
          if (supplier != null) {
            return supplier;
          }
        } catch (e) {
          print('Erro ao carregar fornecedor online: $e');
        }
      }

      // Se não encontrou online ou está offline, buscar local
      final localSuppliers = await _loadLocalSuppliers();
      return localSuppliers.where((s) => s.id == id).firstOrNull;
    } catch (e) {
      print('Erro no serviço ao obter fornecedor por ID: $e');
      return null;
    }
  }

  // Atualizar tabela local de fornecedores
  Future<void> updateLocalSuppliers() async {
    try {
      final suppliers = await _supplierRepository.getAllSuppliers();
      if (suppliers.isNotEmpty) {
        await _updateLocalSuppliers(suppliers);
      } else {
        // Se a API não retornar nada, esvazia a tabela
        await _localDb.clearAndPopulateFornecedores([]);
      }
    } catch (e) {
      print('Erro ao atualizar fornecedores locais: $e');
      rethrow;
    }
  }
}
