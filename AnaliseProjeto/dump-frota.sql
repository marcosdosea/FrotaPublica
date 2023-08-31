-- MySQL Workbench Synchronization
-- Generated: 2023-08-30 23:06
-- Model: New Model
-- Version: 1.0
-- Project: Name of the project
-- Author: marco

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE SCHEMA IF NOT EXISTS `Frota` DEFAULT CHARACTER SET utf8 ;

CREATE TABLE IF NOT EXISTS `Frota`.`Frota` (
  `id` INT(11) ZEROFILL NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(50) NOT NULL,
  `cnpj` VARCHAR(14) NOT NULL,
  `cep` VARCHAR(8) NULL DEFAULT NULL,
  `rua` VARCHAR(50) NULL DEFAULT NULL,
  `bairro` VARCHAR(50) NULL DEFAULT NULL,
  `numero` VARCHAR(10) NULL DEFAULT NULL,
  `complemento` VARCHAR(50) NULL DEFAULT NULL,
  `cidade` VARCHAR(50) NULL DEFAULT NULL,
  `estado` VARCHAR(2) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `cnpj_UNIQUE` (`cnpj` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `Frota`.`MarcaVeiculo` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `Frota`.`ModeloVeiculo` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `idMarcaVeiculo` INT(10) UNSIGNED NOT NULL,
  `nome` VARCHAR(50) NOT NULL,
  `capacidadeTanque` INT(11) NOT NULL,
  INDEX `fk_ModeloVeiculo_MarcaVeiculo_idx` (`idMarcaVeiculo` ASC),
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_ModeloVeiculo_MarcaVeiculo`
    FOREIGN KEY (`idMarcaVeiculo`)
    REFERENCES `Frota`.`MarcaVeiculo` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `Frota`.`MarcaPecaInsumo` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `descricao` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `Frota`.`PecaInsumo` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `descricao` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `Frota`.`Veiculo` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `placa` VARCHAR(10) NOT NULL,
  `chassi` VARCHAR(50) NULL DEFAULT NULL,
  `cor` VARCHAR(50) NOT NULL,
  `idModeloVeiculo` INT(10) UNSIGNED NOT NULL,
  `idFrota` INT(11) ZEROFILL NOT NULL,
  `idUnidadeAdministrativa` INT(10) UNSIGNED NOT NULL,
  `odometro` INT(11) NOT NULL DEFAULT 0,
  `status` ENUM('D', 'U', 'M', 'I') NOT NULL DEFAULT 'D',
  `ano` INT(11) NOT NULL,
  `modelo` INT(11) NOT NULL,
  `renavan` VARCHAR(50) NULL DEFAULT NULL,
  `vencimentoIPVA` DATETIME NULL DEFAULT NULL,
  `valor` DECIMAL(10,2) NOT NULL,
  `dataReferenciaValor` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_Veiculo_ModeloVeiculo1_idx` (`idModeloVeiculo` ASC),
  INDEX `fk_Veiculo_Frota1_idx` (`idFrota` ASC),
  INDEX `fk_Veiculo_UnidadeAdministrativa1_idx` (`idUnidadeAdministrativa` ASC),
  CONSTRAINT `fk_Veiculo_ModeloVeiculo1`
    FOREIGN KEY (`idModeloVeiculo`)
    REFERENCES `Frota`.`ModeloVeiculo` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_Veiculo_Frota1`
    FOREIGN KEY (`idFrota`)
    REFERENCES `Frota`.`Frota` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_Veiculo_UnidadeAdministrativa1`
    FOREIGN KEY (`idUnidadeAdministrativa`)
    REFERENCES `Frota`.`UnidadeAdministrativa` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `Frota`.`Pessoa` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `cpf` VARCHAR(11) NOT NULL,
  `nome` VARCHAR(50) NOT NULL,
  `cep` VARCHAR(8) NULL DEFAULT NULL,
  `rua` VARCHAR(50) NULL DEFAULT NULL,
  `bairro` VARCHAR(50) NULL DEFAULT NULL,
  `complemento` VARCHAR(50) NULL DEFAULT NULL,
  `numero` VARCHAR(10) NULL DEFAULT NULL,
  `cidade` VARCHAR(50) NULL DEFAULT NULL,
  `estado` VARCHAR(2) NOT NULL,
  `idFrota` INT(11) ZEROFILL NOT NULL,
  `idPapelPessoa` INT(10) UNSIGNED NOT NULL,
  `ativo` TINYINT(4) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `cpf_UNIQUE` (`cpf` ASC),
  INDEX `fk_Pessoa_Frota1_idx` (`idFrota` ASC),
  INDEX `fk_Pessoa_PapelPessoa1_idx` (`idPapelPessoa` ASC),
  CONSTRAINT `fk_Pessoa_Frota1`
    FOREIGN KEY (`idFrota`)
    REFERENCES `Frota`.`Frota` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_Pessoa_PapelPessoa1`
    FOREIGN KEY (`idPapelPessoa`)
    REFERENCES `Frota`.`PapelPessoa` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `Frota`.`UnidadeAdministrativa` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(50) NOT NULL,
  `cep` VARCHAR(8) NULL DEFAULT NULL,
  `rua` VARCHAR(50) NULL DEFAULT NULL,
  `bairro` VARCHAR(50) NULL DEFAULT NULL,
  `complemento` VARCHAR(50) NULL DEFAULT NULL,
  `numero` VARCHAR(10) NULL DEFAULT NULL,
  `cidade` VARCHAR(50) NULL DEFAULT NULL,
  `estado` VARCHAR(2) NULL DEFAULT NULL,
  `latitude` FLOAT(11) NULL DEFAULT NULL,
  `longitude` FLOAT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `Frota`.`Percurso` (
  `idVeiculo` INT(10) UNSIGNED NOT NULL,
  `idPessoa` INT(10) UNSIGNED NOT NULL,
  `dataHoraSaida` DATETIME NOT NULL,
  `dataHoraRetorno` DATETIME NOT NULL,
  `localPartida` VARCHAR(50) NOT NULL,
  `latitudePartida` FLOAT(11) NULL DEFAULT NULL,
  `longitudePartida` FLOAT(11) NULL DEFAULT NULL,
  `localChegada` VARCHAR(50) NOT NULL,
  `latitudeChegada` FLOAT(11) NULL DEFAULT NULL,
  `longitudeChegada` FLOAT(11) NULL DEFAULT NULL,
  `odometroInicial` INT(11) NOT NULL,
  `odometroFinal` INT(11) NOT NULL,
  `motivo` VARCHAR(300) NULL DEFAULT NULL,
  PRIMARY KEY (`idVeiculo`, `idPessoa`),
  INDEX `fk_VeiculoPessoa_Pessoa1_idx` (`idPessoa` ASC),
  INDEX `fk_VeiculoPessoa_Veiculo1_idx` (`idVeiculo` ASC),
  CONSTRAINT `fk_VeiculoPessoa_Veiculo1`
    FOREIGN KEY (`idVeiculo`)
    REFERENCES `Frota`.`Veiculo` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_VeiculoPessoa_Pessoa1`
    FOREIGN KEY (`idPessoa`)
    REFERENCES `Frota`.`Pessoa` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `Frota`.`PapelPessoa` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `papel` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `Frota`.`Abastecimento` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `idVeiculoPercurso` INT(10) UNSIGNED NOT NULL,
  `idPessoaPercurso` INT(10) UNSIGNED NOT NULL,
  `dataHora` DATETIME NOT NULL,
  `odometro` INT(11) NOT NULL DEFAULT 0,
  `litros` INT(11) NOT NULL DEFAULT 0,
  `idFornecedor` INT(10) UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_Abastecimento_Percurso1_idx` (`idVeiculoPercurso` ASC, `idPessoaPercurso` ASC),
  INDEX `fk_Abastecimento_Fornecedor1_idx` (`idFornecedor` ASC),
  CONSTRAINT `fk_Abastecimento_Percurso1`
    FOREIGN KEY (`idVeiculoPercurso` , `idPessoaPercurso`)
    REFERENCES `Frota`.`Percurso` (`idVeiculo` , `idPessoa`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_Abastecimento_Fornecedor1`
    FOREIGN KEY (`idFornecedor`)
    REFERENCES `Frota`.`Fornecedor` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `Frota`.`Fornecedor` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(50) NOT NULL,
  `cnpj` VARCHAR(14) NOT NULL,
  `cep` VARCHAR(8) NULL DEFAULT NULL,
  `rua` VARCHAR(50) NULL DEFAULT NULL,
  `bairro` VARCHAR(50) NULL DEFAULT NULL,
  `numero` VARCHAR(10) NULL DEFAULT NULL,
  `complemento` VARCHAR(50) NULL DEFAULT NULL,
  `cidade` VARCHAR(50) NULL DEFAULT NULL,
  `estado` VARCHAR(2) NULL DEFAULT NULL,
  `latitude` INT(11) NULL DEFAULT NULL,
  `longitude` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `cnpj_UNIQUE` (`cnpj` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `Frota`.`Manutencao` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `idVeiculo` INT(10) UNSIGNED NOT NULL,
  `idFornecedor` INT(10) UNSIGNED NOT NULL,
  `dataHora` DATETIME NOT NULL,
  `idResponsavel` INT(10) UNSIGNED NOT NULL,
  `valorPecas` DECIMAL(10,2) NOT NULL DEFAULT 0,
  `valorManutencao` DECIMAL(10,2) NOT NULL,
  `tipo` ENUM('P', 'C') NOT NULL DEFAULT 'P',
  `comprovante` BLOB NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_Manutencao_Veiculo1_idx` (`idVeiculo` ASC),
  INDEX `fk_Manutencao_Fornecedor1_idx` (`idFornecedor` ASC),
  INDEX `fk_Manutencao_Pessoa1_idx` (`idResponsavel` ASC),
  CONSTRAINT `fk_Manutencao_Veiculo1`
    FOREIGN KEY (`idVeiculo`)
    REFERENCES `Frota`.`Veiculo` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_Manutencao_Fornecedor1`
    FOREIGN KEY (`idFornecedor`)
    REFERENCES `Frota`.`Fornecedor` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_Manutencao_Pessoa1`
    FOREIGN KEY (`idResponsavel`)
    REFERENCES `Frota`.`Pessoa` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `Frota`.`ManutencaoPecaInsumo` (
  `idManutencao` INT(10) UNSIGNED NOT NULL,
  `idPecaInsumo` INT(10) UNSIGNED NOT NULL,
  `idMarcaPecaInsumo` INT(10) UNSIGNED NOT NULL,
  `quantidade` FLOAT(11) NOT NULL DEFAULT 1,
  `mesesGarantia` INT(11) NOT NULL DEFAULT 0,
  `kmGarantia` INT(11) NOT NULL,
  `valorIndividual` DECIMAL(10,2) NOT NULL DEFAULT 0,
  `subtotal` DECIMAL(10,2) NOT NULL DEFAULT 0,
  PRIMARY KEY (`idManutencao`, `idPecaInsumo`),
  INDEX `fk_ManutencaoPecaInsumo_PecaInsumo1_idx` (`idPecaInsumo` ASC),
  INDEX `fk_ManutencaoPecaInsumo_Manutencao1_idx` (`idManutencao` ASC),
  INDEX `fk_ManutencaoPecaInsumo_MarcaPecaInsumo1_idx` (`idMarcaPecaInsumo` ASC),
  CONSTRAINT `fk_ManutencaoPecaInsumo_Manutencao1`
    FOREIGN KEY (`idManutencao`)
    REFERENCES `Frota`.`Manutencao` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_ManutencaoPecaInsumo_PecaInsumo1`
    FOREIGN KEY (`idPecaInsumo`)
    REFERENCES `Frota`.`PecaInsumo` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_ManutencaoPecaInsumo_MarcaPecaInsumo1`
    FOREIGN KEY (`idMarcaPecaInsumo`)
    REFERENCES `Frota`.`MarcaPecaInsumo` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `Frota`.`VeiculoPecaInsumo` (
  `idVeiculo` INT(10) UNSIGNED NOT NULL,
  `idPecaInsumo` INT(10) UNSIGNED NOT NULL,
  `dataFinalGarantia` DATETIME NOT NULL,
  `kmFinalGarantia` INT(11) NOT NULL,
  `dataProximaTroca` DATETIME NOT NULL,
  `kmProximaTroca` INT(11) NOT NULL,
  PRIMARY KEY (`idVeiculo`, `idPecaInsumo`),
  INDEX `fk_VeiculoPecaInsumo_PecaInsumo1_idx` (`idPecaInsumo` ASC),
  INDEX `fk_VeiculoPecaInsumo_Veiculo1_idx` (`idVeiculo` ASC),
  CONSTRAINT `fk_VeiculoPecaInsumo_Veiculo1`
    FOREIGN KEY (`idVeiculo`)
    REFERENCES `Frota`.`Veiculo` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_VeiculoPecaInsumo_PecaInsumo1`
    FOREIGN KEY (`idPecaInsumo`)
    REFERENCES `Frota`.`PecaInsumo` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `Frota`.`SolicitacaoManutencao` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `idVeiculo` INT(10) UNSIGNED NOT NULL,
  `idPessoa` INT(10) UNSIGNED NOT NULL,
  `dataSolicitacao` DATETIME NOT NULL,
  `descricaoProblema` VARCHAR(500) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_VeiculoPessoa_Pessoa2_idx` (`idPessoa` ASC),
  INDEX `fk_VeiculoPessoa_Veiculo2_idx` (`idVeiculo` ASC),
  CONSTRAINT `fk_VeiculoPessoa_Veiculo2`
    FOREIGN KEY (`idVeiculo`)
    REFERENCES `Frota`.`Veiculo` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_VeiculoPessoa_Pessoa2`
    FOREIGN KEY (`idPessoa`)
    REFERENCES `Frota`.`Pessoa` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `Frota`.`Vistoria` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `data` DATETIME NOT NULL,
  `problemas` VARCHAR(500) NOT NULL,
  `tipo` ENUM('S', 'R') NOT NULL DEFAULT 'S',
  `idPessoaResponsavel` INT(10) UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_Vistoria_Pessoa1_idx` (`idPessoaResponsavel` ASC),
  CONSTRAINT `fk_Vistoria_Pessoa1`
    FOREIGN KEY (`idPessoaResponsavel`)
    REFERENCES `Frota`.`Pessoa` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
