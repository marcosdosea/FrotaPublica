import 'dart:convert';
import '../models/supplier.dart';
import '../utils/api_client.dart';

class SupplierRepository {
  // Obter todos os fornecedores
  Future<List<Supplier>> getAllSuppliers() async {
    try {
      print('Buscando fornecedores da API...');
      final response = await ApiClient.get('Fornecedor');
      print('Status da resposta de fornecedores: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('Resposta de fornecedores recebida, processando...');

        final List<dynamic> data = jsonDecode(responseBody);
        print('Quantidade de fornecedores encontrados: ${data.length}');

        final suppliers = data.map((json) => Supplier.fromJson(json)).toList();
        print('Fornecedores processados com sucesso');

        return suppliers;
      } else {
        print(
            'Erro ao buscar fornecedores. Status: ${response.statusCode}, Resposta: ${response.body}');
        return [];
      }
    } catch (e, stacktrace) {
      print('Erro ao obter fornecedores: $e');
      print('Stacktrace: $stacktrace');
      return [];
    }
  }

  // Obter um fornecedor pelo ID
  Future<Supplier?> getSupplierById(String id) async {
    try {
      final response = await ApiClient.get('Fornecedor/$id');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Supplier.fromJson(data);
      }

      return null;
    } catch (e) {
      print('Erro ao obter fornecedor por ID: $e');
      return null;
    }
  }
}
