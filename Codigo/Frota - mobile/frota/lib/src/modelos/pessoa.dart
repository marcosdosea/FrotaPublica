import 'package:intl/intl.dart';

class Pessoa {
  final int id;
  final String nome;
  final String? cpf;
  final String? rg;
  final String? email;
  final String? telefone;
  final DateTime? dataNascimento;
  final String? cnh;
  final String? categoriaCnh;
  final DateTime? validadeCnh;
  final bool ativo;
  final int? unidadeAdministrativaId;
  final String? nomeUnidade;
  final String? papelPessoa;

  Pessoa({
    required this.id,
    required this.nome,
    this.cpf,
    this.rg,
    this.email,
    this.telefone,
    this.dataNascimento,
    this.cnh,
    this.categoriaCnh,
    this.validadeCnh,
    required this.ativo,
    this.unidadeAdministrativaId,
    this.nomeUnidade,
    this.papelPessoa,
  });

  factory Pessoa.deJson(Map<String, dynamic> json) {
    return Pessoa(
      id: json['id'],
      nome: json['nome'],
      cpf: json['cpf'],
      rg: json['rg'],
      email: json['email'],
      telefone: json['telefone'],
      dataNascimento: json['dataNascimento'] != null
          ? DateTime.parse(json['dataNascimento'])
          : null,
      cnh: json['cnh'],
      categoriaCnh: json['categoriaCnh'],
      validadeCnh: json['validadeCnh'] != null
          ? DateTime.parse(json['validadeCnh'])
          : null,
      ativo: json['ativo'],
      unidadeAdministrativaId: json['unidadeAdministrativaId'],
      nomeUnidade: json['nomeUnidade'],
      papelPessoa: json['papelPessoa'],
    );
  }

  Map<String, dynamic> paraJson() {
    return {
      'id': id,
      'nome': nome,
      'cpf': cpf,
      'rg': rg,
      'email': email,
      'telefone': telefone,
      'dataNascimento': dataNascimento?.toIso8601String(),
      'cnh': cnh,
      'categoriaCnh': categoriaCnh,
      'validadeCnh': validadeCnh?.toIso8601String(),
      'ativo': ativo,
      'unidadeAdministrativaId': unidadeAdministrativaId,
      'nomeUnidade': nomeUnidade,
      'papelPessoa': papelPessoa,
    };
  }

  String get dataNascimentoFormatada {
    if (dataNascimento == null) return '';
    return DateFormat('dd/MM/yyyy').format(dataNascimento!);
  }

  String get validadeCnhFormatada {
    if (validadeCnh == null) return '';
    return DateFormat('dd/MM/yyyy').format(validadeCnh!);
  }
}
