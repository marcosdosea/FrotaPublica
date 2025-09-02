using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace Core;

public partial class FrotaContext : DbContext
{
    public FrotaContext()
    {
    }

    public FrotaContext(DbContextOptions<FrotaContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Abastecimento> Abastecimentos { get; set; }

    public virtual DbSet<Fornecedor> Fornecedors { get; set; }

    public virtual DbSet<Frotum> Frota { get; set; }

    public virtual DbSet<Manutencao> Manutencaos { get; set; }

    public virtual DbSet<Manutencaopecainsumo> Manutencaopecainsumos { get; set; }

    public virtual DbSet<Marcapecainsumo> Marcapecainsumos { get; set; }

    public virtual DbSet<Marcaveiculo> Marcaveiculos { get; set; }

    public virtual DbSet<Modeloveiculo> Modeloveiculos { get; set; }

    public virtual DbSet<Papelpessoa> Papelpessoas { get; set; }

    public virtual DbSet<Pecainsumo> Pecainsumos { get; set; }

    public virtual DbSet<Percurso> Percursos { get; set; }

    public virtual DbSet<Pessoa> Pessoas { get; set; }

    public virtual DbSet<Solicitacaomanutencao> Solicitacaomanutencaos { get; set; }

    public virtual DbSet<Unidadeadministrativa> Unidadeadministrativas { get; set; }

    public virtual DbSet<Veiculo> Veiculos { get; set; }

    public virtual DbSet<Veiculopecainsumo> Veiculopecainsumos { get; set; }

    public virtual DbSet<Vistorium> Vistoria { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Abastecimento>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("abastecimento");

            entity.HasIndex(e => e.IdFornecedor, "fk_Abastecimento_Fornecedor1_idx");

            entity.HasIndex(e => e.IdFrota, "fk_abastecimento_frota1_idx");

            entity.HasIndex(e => e.IdPessoa, "fk_abastecimento_pessoa1_idx");

            entity.HasIndex(e => e.IdVeiculo, "fk_abastecimento_veiculo1_idx");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.DataHora)
                .HasColumnType("datetime")
                .HasColumnName("dataHora");
            entity.Property(e => e.IdFornecedor).HasColumnName("idFornecedor");
            entity.Property(e => e.IdFrota)
                .HasColumnType("int(11) unsigned zerofill")
                .HasColumnName("idFrota");
            entity.Property(e => e.IdPessoa).HasColumnName("idPessoa");
            entity.Property(e => e.IdVeiculo).HasColumnName("idVeiculo");
            entity.Property(e => e.Litros)
                .HasPrecision(10)
                .HasColumnName("litros");
            entity.Property(e => e.Odometro).HasColumnName("odometro");

            entity.HasOne(d => d.IdFornecedorNavigation).WithMany(p => p.Abastecimentos)
                .HasForeignKey(d => d.IdFornecedor)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_Abastecimento_Fornecedor1");

            entity.HasOne(d => d.IdFrotaNavigation).WithMany(p => p.Abastecimentos)
                .HasForeignKey(d => d.IdFrota)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_abastecimento_frota1");

            entity.HasOne(d => d.IdPessoaNavigation).WithMany(p => p.Abastecimentos)
                .HasForeignKey(d => d.IdPessoa)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_abastecimento_pessoa1");

            entity.HasOne(d => d.IdVeiculoNavigation).WithMany(p => p.Abastecimentos)
                .HasForeignKey(d => d.IdVeiculo)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_abastecimento_veiculo1");
        });

        modelBuilder.Entity<Fornecedor>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("fornecedor");

            entity.HasIndex(e => e.Cnpj, "cnpj_UNIQUE").IsUnique();

            entity.HasIndex(e => e.IdFrota, "fk_fornecedor_frota1_idx");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Ativo)
                .HasDefaultValueSql("'1'")
                .HasColumnName("ativo");
            entity.Property(e => e.Bairro)
                .HasMaxLength(50)
                .HasColumnName("bairro");
            entity.Property(e => e.Cep)
                .HasMaxLength(8)
                .HasColumnName("cep");
            entity.Property(e => e.Cidade)
                .HasMaxLength(50)
                .HasColumnName("cidade");
            entity.Property(e => e.Cnpj)
                .HasMaxLength(14)
                .HasColumnName("cnpj");
            entity.Property(e => e.Complemento)
                .HasMaxLength(50)
                .HasColumnName("complemento");
            entity.Property(e => e.Estado)
                .HasMaxLength(2)
                .HasColumnName("estado");
            entity.Property(e => e.IdFrota)
                .HasColumnType("int(11) unsigned zerofill")
                .HasColumnName("idFrota");
            entity.Property(e => e.Latitude).HasColumnName("latitude");
            entity.Property(e => e.Longitude).HasColumnName("longitude");
            entity.Property(e => e.Nome)
                .HasMaxLength(50)
                .HasColumnName("nome");
            entity.Property(e => e.Numero)
                .HasMaxLength(10)
                .HasColumnName("numero");
            entity.Property(e => e.Rua)
                .HasMaxLength(50)
                .HasColumnName("rua");

            entity.HasOne(d => d.IdFrotaNavigation).WithMany(p => p.Fornecedors)
                .HasForeignKey(d => d.IdFrota)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_fornecedor_frota1");
        });

        modelBuilder.Entity<Frotum>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("frota");

            entity.HasIndex(e => e.Cnpj, "cnpj_UNIQUE").IsUnique();

            entity.Property(e => e.Id)
                .HasColumnType("int(11) unsigned zerofill")
                .HasColumnName("id");
            entity.Property(e => e.Bairro)
                .HasMaxLength(50)
                .HasColumnName("bairro");
            entity.Property(e => e.Cep)
                .HasMaxLength(8)
                .HasColumnName("cep");
            entity.Property(e => e.Cidade)
                .HasMaxLength(50)
                .HasColumnName("cidade");
            entity.Property(e => e.Cnpj)
                .HasMaxLength(14)
                .HasColumnName("cnpj");
            entity.Property(e => e.Complemento)
                .HasMaxLength(50)
                .HasColumnName("complemento");
            entity.Property(e => e.Estado)
                .HasMaxLength(2)
                .HasColumnName("estado");
            entity.Property(e => e.Nome)
                .HasMaxLength(50)
                .HasColumnName("nome");
            entity.Property(e => e.Numero)
                .HasMaxLength(10)
                .HasColumnName("numero");
            entity.Property(e => e.Rua)
                .HasMaxLength(50)
                .HasColumnName("rua");
        });

        modelBuilder.Entity<Manutencao>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("manutencao");

            entity.HasIndex(e => e.IdFornecedor, "fk_Manutencao_Fornecedor1_idx");

            entity.HasIndex(e => e.IdResponsavel, "fk_Manutencao_Pessoa1_idx");

            entity.HasIndex(e => e.IdVeiculo, "fk_Manutencao_Veiculo1_idx");

            entity.HasIndex(e => e.IdFrota, "fk_manutencao_frota1_idx");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Comprovante)
                .HasColumnType("blob")
                .HasColumnName("comprovante");
            entity.Property(e => e.DataHora)
                .HasColumnType("datetime")
                .HasColumnName("dataHora");
            entity.Property(e => e.IdFornecedor).HasColumnName("idFornecedor");
            entity.Property(e => e.IdFrota)
                .HasColumnType("int(11) unsigned zerofill")
                .HasColumnName("idFrota");
            entity.Property(e => e.IdResponsavel).HasColumnName("idResponsavel");
            entity.Property(e => e.IdVeiculo).HasColumnName("idVeiculo");
            entity.Property(e => e.Status)
                .HasDefaultValueSql("'O'")
                .HasColumnType("enum('O','A','E','F')")
                .HasColumnName("status");
            entity.Property(e => e.Tipo)
                .HasDefaultValueSql("'P'")
                .HasColumnType("enum('P','C')")
                .HasColumnName("tipo");
            entity.Property(e => e.ValorManutencao)
                .HasPrecision(10)
                .HasColumnName("valorManutencao");
            entity.Property(e => e.ValorPecas)
                .HasPrecision(10)
                .HasColumnName("valorPecas");

            entity.HasOne(d => d.IdFornecedorNavigation).WithMany(p => p.Manutencaos)
                .HasForeignKey(d => d.IdFornecedor)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_Manutencao_Fornecedor1");

            entity.HasOne(d => d.IdFrotaNavigation).WithMany(p => p.Manutencaos)
                .HasForeignKey(d => d.IdFrota)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_manutencao_frota1");

            entity.HasOne(d => d.IdResponsavelNavigation).WithMany(p => p.Manutencaos)
                .HasForeignKey(d => d.IdResponsavel)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_Manutencao_Pessoa1");

            entity.HasOne(d => d.IdVeiculoNavigation).WithMany(p => p.Manutencaos)
                .HasForeignKey(d => d.IdVeiculo)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_Manutencao_Veiculo1");
        });

        modelBuilder.Entity<Manutencaopecainsumo>(entity =>
        {
            entity.HasKey(e => new { e.IdManutencao, e.IdPecaInsumo }).HasName("PRIMARY");

            entity.ToTable("manutencaopecainsumo");

            entity.HasIndex(e => e.IdManutencao, "fk_ManutencaoPecaInsumo_Manutencao1_idx");

            entity.HasIndex(e => e.IdMarcaPecaInsumo, "fk_ManutencaoPecaInsumo_MarcaPecaInsumo1_idx");

            entity.HasIndex(e => e.IdPecaInsumo, "fk_ManutencaoPecaInsumo_PecaInsumo1_idx");

            entity.Property(e => e.IdManutencao).HasColumnName("idManutencao");
            entity.Property(e => e.IdPecaInsumo).HasColumnName("idPecaInsumo");
            entity.Property(e => e.IdMarcaPecaInsumo).HasColumnName("idMarcaPecaInsumo");
            entity.Property(e => e.KmGarantia).HasColumnName("kmGarantia");
            entity.Property(e => e.MesesGarantia).HasColumnName("mesesGarantia");
            entity.Property(e => e.Quantidade)
                .HasDefaultValueSql("'1'")
                .HasColumnName("quantidade");
            entity.Property(e => e.Subtotal)
                .HasPrecision(10)
                .HasColumnName("subtotal");
            entity.Property(e => e.ValorIndividual)
                .HasPrecision(10)
                .HasColumnName("valorIndividual");

            entity.HasOne(d => d.IdManutencaoNavigation).WithMany(p => p.Manutencaopecainsumos)
                .HasForeignKey(d => d.IdManutencao)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_ManutencaoPecaInsumo_Manutencao1");

            entity.HasOne(d => d.IdMarcaPecaInsumoNavigation).WithMany(p => p.Manutencaopecainsumos)
                .HasForeignKey(d => d.IdMarcaPecaInsumo)
                .HasConstraintName("fk_ManutencaoPecaInsumo_MarcaPecaInsumo1");

            entity.HasOne(d => d.IdPecaInsumoNavigation).WithMany(p => p.Manutencaopecainsumos)
                .HasForeignKey(d => d.IdPecaInsumo)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_ManutencaoPecaInsumo_PecaInsumo1");
        });

        modelBuilder.Entity<Marcapecainsumo>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("marcapecainsumo");

            entity.HasIndex(e => e.Idfrota, "fk_marcaPecainsumo_frota1_idx");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Descricao)
                .HasMaxLength(50)
                .HasColumnName("descricao");
            entity.Property(e => e.Idfrota)
                .HasColumnType("int(11) unsigned zerofill")
                .HasColumnName("idfrota");

            entity.HasOne(d => d.IdfrotaNavigation).WithMany(p => p.Marcapecainsumos)
                .HasForeignKey(d => d.Idfrota)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_marcaPecainsumo_frota1");
        });

        modelBuilder.Entity<Marcaveiculo>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("marcaveiculo");

            entity.HasIndex(e => e.IdFrota, "fk_marcaVeiculo_frota1_idx");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.IdFrota)
                .HasColumnType("int(11) unsigned zerofill")
                .HasColumnName("idFrota");
            entity.Property(e => e.Nome)
                .HasMaxLength(50)
                .HasColumnName("nome");

            entity.HasOne(d => d.IdFrotaNavigation).WithMany(p => p.Marcaveiculos)
                .HasForeignKey(d => d.IdFrota)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_marcaVeiculo_frota1");
        });

        modelBuilder.Entity<Modeloveiculo>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("modeloveiculo");

            entity.HasIndex(e => e.IdMarcaVeiculo, "fk_ModeloVeiculo_MarcaVeiculo_idx");

            entity.HasIndex(e => e.IdFrota, "fk_modeloVeiculo_frota1_idx");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.CapacidadeTanque).HasColumnName("capacidadeTanque");
            entity.Property(e => e.IdFrota)
                .HasColumnType("int(11) unsigned zerofill")
                .HasColumnName("idFrota");
            entity.Property(e => e.IdMarcaVeiculo).HasColumnName("idMarcaVeiculo");
            entity.Property(e => e.Nome)
                .HasMaxLength(50)
                .HasColumnName("nome");

            entity.HasOne(d => d.IdFrotaNavigation).WithMany(p => p.Modeloveiculos)
                .HasForeignKey(d => d.IdFrota)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_modeloVeiculo_frota1");

            entity.HasOne(d => d.IdMarcaVeiculoNavigation).WithMany(p => p.Modeloveiculos)
                .HasForeignKey(d => d.IdMarcaVeiculo)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_ModeloVeiculo_MarcaVeiculo");
        });

        modelBuilder.Entity<Papelpessoa>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("papelpessoa");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Papel)
                .HasMaxLength(50)
                .HasColumnName("papel");
        });

        modelBuilder.Entity<Pecainsumo>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("pecainsumo");

            entity.HasIndex(e => e.IdFrota, "fk_pecainsumo_frota1_idx");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Descricao)
                .HasMaxLength(50)
                .HasColumnName("descricao");
            entity.Property(e => e.IdFrota)
                .HasColumnType("int(11) unsigned zerofill")
                .HasColumnName("idFrota");
            entity.Property(e => e.KmGarantia)
                .HasDefaultValueSql("'5000'")
                .HasColumnName("kmGarantia");
            entity.Property(e => e.MesesGarantia)
                .HasDefaultValueSql("'12'")
                .HasColumnName("mesesGarantia");

            entity.HasOne(d => d.IdFrotaNavigation).WithMany(p => p.Pecainsumos)
                .HasForeignKey(d => d.IdFrota)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_pecainsumo_frota1");
        });

        modelBuilder.Entity<Percurso>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("percurso");

            entity.HasIndex(e => e.IdPessoa, "fk_VeiculoPessoa_Pessoa1_idx");

            entity.HasIndex(e => e.IdVeiculo, "fk_VeiculoPessoa_Veiculo1_idx");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.DataHoraRetorno)
                .HasColumnType("datetime")
                .HasColumnName("dataHoraRetorno");
            entity.Property(e => e.DataHoraSaida)
                .HasColumnType("datetime")
                .HasColumnName("dataHoraSaida");
            entity.Property(e => e.IdPessoa).HasColumnName("idPessoa");
            entity.Property(e => e.IdVeiculo).HasColumnName("idVeiculo");
            entity.Property(e => e.LatitudeChegada).HasColumnName("latitudeChegada");
            entity.Property(e => e.LatitudePartida).HasColumnName("latitudePartida");
            entity.Property(e => e.LocalChegada)
                .HasMaxLength(150)
                .HasColumnName("localChegada");
            entity.Property(e => e.LocalPartida)
                .HasMaxLength(150)
                .HasColumnName("localPartida");
            entity.Property(e => e.LongitudeChegada).HasColumnName("longitudeChegada");
            entity.Property(e => e.LongitudePartida).HasColumnName("longitudePartida");
            entity.Property(e => e.Motivo)
                .HasMaxLength(300)
                .HasColumnName("motivo");
            entity.Property(e => e.OdometroFinal).HasColumnName("odometroFinal");
            entity.Property(e => e.OdometroInicial).HasColumnName("odometroInicial");

            entity.HasOne(d => d.IdPessoaNavigation).WithMany(p => p.Percursos)
                .HasForeignKey(d => d.IdPessoa)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_VeiculoPessoa_Pessoa1");

            entity.HasOne(d => d.IdVeiculoNavigation).WithMany(p => p.Percursos)
                .HasForeignKey(d => d.IdVeiculo)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_VeiculoPessoa_Veiculo1");
        });

        modelBuilder.Entity<Pessoa>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("pessoa");

            entity.HasIndex(e => e.Cpf, "cpf_UNIQUE").IsUnique();

            entity.HasIndex(e => e.IdFrota, "fk_Pessoa_Frota1_idx");

            entity.HasIndex(e => e.IdPapelPessoa, "fk_Pessoa_PapelPessoa1_idx");

            entity.HasIndex(e => e.IdunidadeAdministrativa, "fk_pessoa_unidadeAdministrativa1");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Ativo)
                .HasDefaultValueSql("'1'")
                .HasColumnName("ativo");
            entity.Property(e => e.Bairro)
                .HasMaxLength(50)
                .HasColumnName("bairro");
            entity.Property(e => e.Cep)
                .HasMaxLength(8)
                .HasColumnName("cep");
            entity.Property(e => e.Cidade)
                .HasMaxLength(50)
                .HasColumnName("cidade");
            entity.Property(e => e.Complemento)
                .HasMaxLength(50)
                .HasColumnName("complemento");
            entity.Property(e => e.Cpf)
                .HasMaxLength(11)
                .HasColumnName("cpf");
            entity.Property(e => e.Email)
                .HasMaxLength(50)
                .HasDefaultValueSql("'padrao@gmail.com'")
                .HasColumnName("email");
            entity.Property(e => e.Estado)
                .HasMaxLength(2)
                .HasColumnName("estado");
            entity.Property(e => e.IdFrota)
                .HasColumnType("int(11) unsigned zerofill")
                .HasColumnName("idFrota");
            entity.Property(e => e.IdPapelPessoa).HasColumnName("idPapelPessoa");
            entity.Property(e => e.IdunidadeAdministrativa).HasColumnName("idunidadeAdministrativa");
            entity.Property(e => e.Nome)
                .HasMaxLength(50)
                .HasColumnName("nome");
            entity.Property(e => e.Numero)
                .HasMaxLength(10)
                .HasColumnName("numero");
            entity.Property(e => e.Rua)
                .HasMaxLength(50)
                .HasColumnName("rua");
            entity.Property(e => e.Telefone)
                .HasMaxLength(11)
                .HasDefaultValueSql("'99999999999'")
                .HasColumnName("telefone");

            entity.HasOne(d => d.IdFrotaNavigation).WithMany(p => p.Pessoas)
                .HasForeignKey(d => d.IdFrota)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_Pessoa_Frota1");

            entity.HasOne(d => d.IdPapelPessoaNavigation).WithMany(p => p.Pessoas)
                .HasForeignKey(d => d.IdPapelPessoa)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_Pessoa_PapelPessoa1");

            entity.HasOne(d => d.IdunidadeAdministrativaNavigation).WithMany(p => p.Pessoas)
                .HasForeignKey(d => d.IdunidadeAdministrativa)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_pessoa_unidadeAdministrativa1");
        });

        modelBuilder.Entity<Solicitacaomanutencao>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("solicitacaomanutencao");

            entity.HasIndex(e => e.IdPessoa, "fk_VeiculoPessoa_Pessoa2_idx");

            entity.HasIndex(e => e.IdVeiculo, "fk_VeiculoPessoa_Veiculo2_idx");

            entity.HasIndex(e => e.IdFrota, "fk_solicitacaoManutencao_frota1_idx");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.DataSolicitacao)
                .HasColumnType("datetime")
                .HasColumnName("dataSolicitacao");
            entity.Property(e => e.DescricaoProblema)
                .HasMaxLength(500)
                .HasColumnName("descricaoProblema");
            entity.Property(e => e.IdFrota)
                .HasColumnType("int(11) unsigned zerofill")
                .HasColumnName("idFrota");
            entity.Property(e => e.IdPessoa).HasColumnName("idPessoa");
            entity.Property(e => e.IdVeiculo).HasColumnName("idVeiculo");
            entity.Property(e => e.Prioridade)
                .HasMaxLength(1)
                .HasDefaultValueSql("'M'")
                .IsFixedLength()
                .HasComment("B=Baixa, M=Média, A=Alta, U=Urgente")
                .HasColumnName("prioridade");

            entity.HasOne(d => d.IdFrotaNavigation).WithMany(p => p.Solicitacaomanutencaos)
                .HasForeignKey(d => d.IdFrota)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_solicitacaoManutencao_frota1");

            entity.HasOne(d => d.IdPessoaNavigation).WithMany(p => p.Solicitacaomanutencaos)
                .HasForeignKey(d => d.IdPessoa)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_VeiculoPessoa_Pessoa2");

            entity.HasOne(d => d.IdVeiculoNavigation).WithMany(p => p.Solicitacaomanutencaos)
                .HasForeignKey(d => d.IdVeiculo)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_VeiculoPessoa_Veiculo2");
        });

        modelBuilder.Entity<Unidadeadministrativa>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("unidadeadministrativa");

            entity.HasIndex(e => e.IdFrota, "fk_unidadeAdministrativa_frota1_idx");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Bairro)
                .HasMaxLength(50)
                .HasColumnName("bairro");
            entity.Property(e => e.Cep)
                .HasMaxLength(8)
                .HasColumnName("cep");
            entity.Property(e => e.Cidade)
                .HasMaxLength(50)
                .HasColumnName("cidade");
            entity.Property(e => e.Complemento)
                .HasMaxLength(50)
                .HasColumnName("complemento");
            entity.Property(e => e.Estado)
                .HasMaxLength(2)
                .HasColumnName("estado");
            entity.Property(e => e.IdFrota)
                .HasColumnType("int(11) unsigned zerofill")
                .HasColumnName("idFrota");
            entity.Property(e => e.Latitude).HasColumnName("latitude");
            entity.Property(e => e.Longitude).HasColumnName("longitude");
            entity.Property(e => e.Nome)
                .HasMaxLength(50)
                .HasColumnName("nome");
            entity.Property(e => e.Numero)
                .HasMaxLength(10)
                .HasColumnName("numero");
            entity.Property(e => e.Rua)
                .HasMaxLength(50)
                .HasColumnName("rua");

            entity.HasOne(d => d.IdFrotaNavigation).WithMany(p => p.Unidadeadministrativas)
                .HasForeignKey(d => d.IdFrota)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_unidadeAdministrativa_frota1");
        });

        modelBuilder.Entity<Veiculo>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("veiculo");

            entity.HasIndex(e => e.Chassi, "chassi_UNIQUE").IsUnique();

            entity.HasIndex(e => e.IdFrota, "fk_Veiculo_Frota1_idx");

            entity.HasIndex(e => e.IdModeloVeiculo, "fk_Veiculo_ModeloVeiculo1_idx");

            entity.HasIndex(e => e.IdUnidadeAdministrativa, "fk_Veiculo_UnidadeAdministrativa1_idx");

            entity.HasIndex(e => e.Placa, "placa_UNIQUE").IsUnique();

            entity.HasIndex(e => e.Renavan, "renavan_UNIQUE").IsUnique();

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Ano).HasColumnName("ano");
            entity.Property(e => e.Chassi)
                .HasMaxLength(50)
                .HasColumnName("chassi");
            entity.Property(e => e.Cor)
                .HasMaxLength(50)
                .HasColumnName("cor");
            entity.Property(e => e.DataReferenciaValor)
                .HasColumnType("datetime")
                .HasColumnName("dataReferenciaValor");
            entity.Property(e => e.IdFrota)
                .HasColumnType("int(11) unsigned zerofill")
                .HasColumnName("idFrota");
            entity.Property(e => e.IdModeloVeiculo).HasColumnName("idModeloVeiculo");
            entity.Property(e => e.IdUnidadeAdministrativa).HasColumnName("idUnidadeAdministrativa");
            entity.Property(e => e.Modelo).HasColumnName("modelo");
            entity.Property(e => e.Odometro).HasColumnName("odometro");
            entity.Property(e => e.Placa)
                .HasMaxLength(10)
                .HasColumnName("placa");
            entity.Property(e => e.Renavan)
                .HasMaxLength(50)
                .HasColumnName("renavan");
            entity.Property(e => e.Status)
                .HasDefaultValueSql("'D'")
                .HasColumnType("enum('D','U','M','I')")
                .HasColumnName("status");
            entity.Property(e => e.Valor)
                .HasPrecision(10)
                .HasColumnName("valor");
            entity.Property(e => e.VencimentoIpva)
                .HasColumnType("datetime")
                .HasColumnName("vencimentoIPVA");

            entity.HasOne(d => d.IdFrotaNavigation).WithMany(p => p.Veiculos)
                .HasForeignKey(d => d.IdFrota)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_Veiculo_Frota1");

            entity.HasOne(d => d.IdModeloVeiculoNavigation).WithMany(p => p.Veiculos)
                .HasForeignKey(d => d.IdModeloVeiculo)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_Veiculo_ModeloVeiculo1");

            entity.HasOne(d => d.IdUnidadeAdministrativaNavigation).WithMany(p => p.Veiculos)
                .HasForeignKey(d => d.IdUnidadeAdministrativa)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_Veiculo_UnidadeAdministrativa1");
        });

        modelBuilder.Entity<Veiculopecainsumo>(entity =>
        {
            entity.HasKey(e => new { e.IdVeiculo, e.IdPecaInsumo }).HasName("PRIMARY");

            entity.ToTable("veiculopecainsumo");

            entity.HasIndex(e => e.IdPecaInsumo, "fk_VeiculoPecaInsumo_PecaInsumo1_idx");

            entity.HasIndex(e => e.IdVeiculo, "fk_VeiculoPecaInsumo_Veiculo1_idx");

            entity.Property(e => e.IdVeiculo).HasColumnName("idVeiculo");
            entity.Property(e => e.IdPecaInsumo).HasColumnName("idPecaInsumo");
            entity.Property(e => e.DataFinalGarantia)
                .HasColumnType("datetime")
                .HasColumnName("dataFinalGarantia");
            entity.Property(e => e.DataProximaTroca)
                .HasColumnType("datetime")
                .HasColumnName("dataProximaTroca");
            entity.Property(e => e.KmFinalGarantia).HasColumnName("kmFinalGarantia");
            entity.Property(e => e.KmProximaTroca).HasColumnName("kmProximaTroca");

            entity.HasOne(d => d.IdPecaInsumoNavigation).WithMany(p => p.Veiculopecainsumos)
                .HasForeignKey(d => d.IdPecaInsumo)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_VeiculoPecaInsumo_PecaInsumo1");

            entity.HasOne(d => d.IdVeiculoNavigation).WithMany(p => p.Veiculopecainsumos)
                .HasForeignKey(d => d.IdVeiculo)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_VeiculoPecaInsumo_Veiculo1");
        });

        modelBuilder.Entity<Vistorium>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PRIMARY");

            entity.ToTable("vistoria");

            entity.HasIndex(e => e.IdPessoaResponsavel, "fk_Vistoria_Pessoa1_idx");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Data)
                .HasColumnType("datetime")
                .HasColumnName("data");
            entity.Property(e => e.IdPessoaResponsavel).HasColumnName("idPessoaResponsavel");
            entity.Property(e => e.Problemas)
                .HasMaxLength(500)
                .HasColumnName("problemas");
            entity.Property(e => e.Tipo)
                .HasDefaultValueSql("'S'")
                .HasColumnType("enum('S','R')")
                .HasColumnName("tipo");

            entity.HasOne(d => d.IdPessoaResponsavelNavigation).WithMany(p => p.Vistoria)
                .HasForeignKey(d => d.IdPessoaResponsavel)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("fk_Vistoria_Pessoa1");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
