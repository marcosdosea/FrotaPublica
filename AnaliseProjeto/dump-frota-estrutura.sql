-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema Frota
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `Frota` ;

-- -----------------------------------------------------
-- Schema Frota
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `Frota` DEFAULT CHARACTER SET utf8 ;
USE `Frota` ;

-- -----------------------------------------------------
-- Table `__efmigrationshistory`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `__efmigrationshistory` ;

CREATE TABLE IF NOT EXISTS `__efmigrationshistory` (
  `MigrationId` VARCHAR(150) NOT NULL,
  `ProductVersion` VARCHAR(32) NOT NULL,
  PRIMARY KEY (`MigrationId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `frota`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `frota` ;

CREATE TABLE IF NOT EXISTS `frota` (
  `id` INT(11) UNSIGNED ZEROFILL NOT NULL AUTO_INCREMENT,
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


-- -----------------------------------------------------
-- Table `fornecedor`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `fornecedor` ;

CREATE TABLE IF NOT EXISTS `fornecedor` (
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
  `idFrota` INT(11) UNSIGNED ZEROFILL NOT NULL,
  `ativo` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `cnpj_UNIQUE` (`cnpj` ASC),
  INDEX `fk_fornecedor_frota1_idx` (`idFrota` ASC),
  CONSTRAINT `fk_fornecedor_frota1`
    FOREIGN KEY (`idFrota`)
    REFERENCES `frota` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `marcaVeiculo`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marcaVeiculo` ;

CREATE TABLE IF NOT EXISTS `marcaVeiculo` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(50) NOT NULL,
  `idFrota` INT(11) UNSIGNED ZEROFILL NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_marcaVeiculo_frota1_idx` (`idFrota` ASC),
  CONSTRAINT `fk_marcaVeiculo_frota1`
    FOREIGN KEY (`idFrota`)
    REFERENCES `frota` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `modeloVeiculo`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `modeloVeiculo` ;

CREATE TABLE IF NOT EXISTS `modeloVeiculo` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `idMarcaVeiculo` INT(10) UNSIGNED NOT NULL,
  `nome` VARCHAR(50) NOT NULL,
  `capacidadeTanque` INT(11) NOT NULL,
  `idFrota` INT(11) UNSIGNED ZEROFILL NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_ModeloVeiculo_MarcaVeiculo_idx` (`idMarcaVeiculo` ASC),
  INDEX `fk_modeloVeiculo_frota1_idx` (`idFrota` ASC),
  CONSTRAINT `fk_ModeloVeiculo_MarcaVeiculo`
    FOREIGN KEY (`idMarcaVeiculo`)
    REFERENCES `marcaVeiculo` (`id`),
  CONSTRAINT `fk_modeloVeiculo_frota1`
    FOREIGN KEY (`idFrota`)
    REFERENCES `frota` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `unidadeAdministrativa`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `unidadeAdministrativa` ;

CREATE TABLE IF NOT EXISTS `unidadeAdministrativa` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(50) NOT NULL,
  `cep` VARCHAR(8) NULL DEFAULT NULL,
  `rua` VARCHAR(50) NULL DEFAULT NULL,
  `bairro` VARCHAR(50) NULL DEFAULT NULL,
  `complemento` VARCHAR(50) NULL DEFAULT NULL,
  `numero` VARCHAR(10) NULL DEFAULT NULL,
  `cidade` VARCHAR(50) NULL DEFAULT NULL,
  `estado` VARCHAR(2) NULL DEFAULT NULL,
  `latitude` FLOAT NULL DEFAULT NULL,
  `longitude` FLOAT NULL DEFAULT NULL,
  `idFrota` INT(11) UNSIGNED ZEROFILL NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_unidadeAdministrativa_frota1_idx` (`idFrota` ASC),
  CONSTRAINT `fk_unidadeAdministrativa_frota1`
    FOREIGN KEY (`idFrota`)
    REFERENCES `frota` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `veiculo`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `veiculo` ;

CREATE TABLE IF NOT EXISTS `veiculo` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `placa` VARCHAR(10) NOT NULL,
  `chassi` VARCHAR(50) NULL DEFAULT NULL,
  `cor` VARCHAR(50) NOT NULL,
  `idModeloVeiculo` INT(10) UNSIGNED NOT NULL,
  `idFrota` INT(11) UNSIGNED ZEROFILL NOT NULL,
  `idUnidadeAdministrativa` INT(10) UNSIGNED NOT NULL,
  `odometro` INT(11) NOT NULL DEFAULT '0',
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
  UNIQUE INDEX `placa_UNIQUE` (`placa` ASC),
  UNIQUE INDEX `chassi_UNIQUE` (`chassi` ASC),
  UNIQUE INDEX `renavan_UNIQUE` (`renavan` ASC),
  CONSTRAINT `fk_Veiculo_Frota1`
    FOREIGN KEY (`idFrota`)
    REFERENCES `frota` (`id`),
  CONSTRAINT `fk_Veiculo_ModeloVeiculo1`
    FOREIGN KEY (`idModeloVeiculo`)
    REFERENCES `modeloVeiculo` (`id`),
  CONSTRAINT `fk_Veiculo_UnidadeAdministrativa1`
    FOREIGN KEY (`idUnidadeAdministrativa`)
    REFERENCES `unidadeAdministrativa` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `papelPessoa`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `papelPessoa` ;

CREATE TABLE IF NOT EXISTS `papelPessoa` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `papel` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `pessoa`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `pessoa` ;

CREATE TABLE IF NOT EXISTS `pessoa` (
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
  `idFrota` INT(11) UNSIGNED ZEROFILL NOT NULL,
  `idPapelPessoa` INT(10) UNSIGNED NOT NULL,
  `ativo` TINYINT(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `cpf_UNIQUE` (`cpf` ASC),
  INDEX `fk_Pessoa_Frota1_idx` (`idFrota` ASC),
  INDEX `fk_Pessoa_PapelPessoa1_idx` (`idPapelPessoa` ASC),
  CONSTRAINT `fk_Pessoa_Frota1`
    FOREIGN KEY (`idFrota`)
    REFERENCES `frota` (`id`),
  CONSTRAINT `fk_Pessoa_PapelPessoa1`
    FOREIGN KEY (`idPapelPessoa`)
    REFERENCES `papelPessoa` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `abastecimento`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `abastecimento` ;

CREATE TABLE IF NOT EXISTS `abastecimento` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `idFornecedor` INT(10) UNSIGNED NOT NULL,
  `idVeiculo` INT(10) UNSIGNED NOT NULL,
  `idFrota` INT(11) UNSIGNED ZEROFILL NOT NULL,
  `idPessoa` INT(10) UNSIGNED NOT NULL,
  `dataHora` DATETIME NOT NULL,
  `odometro` INT(11) NOT NULL DEFAULT '0',
  `litros` DECIMAL(10,2) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  INDEX `fk_Abastecimento_Fornecedor1_idx` (`idFornecedor` ASC),
  INDEX `fk_abastecimento_veiculo1_idx` (`idVeiculo` ASC),
  INDEX `fk_abastecimento_frota1_idx` (`idFrota` ASC),
  INDEX `fk_abastecimento_pessoa1_idx` (`idPessoa` ASC),
  CONSTRAINT `fk_Abastecimento_Fornecedor1`
    FOREIGN KEY (`idFornecedor`)
    REFERENCES `fornecedor` (`id`),
  CONSTRAINT `fk_abastecimento_veiculo1`
    FOREIGN KEY (`idVeiculo`)
    REFERENCES `veiculo` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_abastecimento_frota1`
    FOREIGN KEY (`idFrota`)
    REFERENCES `frota` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_abastecimento_pessoa1`
    FOREIGN KEY (`idPessoa`)
    REFERENCES `pessoa` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `aspnetroles`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `aspnetroles` ;

CREATE TABLE IF NOT EXISTS `aspnetroles` (
  `Id` VARCHAR(255) NOT NULL,
  `Name` VARCHAR(256) NULL DEFAULT NULL,
  `NormalizedName` VARCHAR(256) NULL DEFAULT NULL,
  `ConcurrencyStamp` LONGTEXT NULL DEFAULT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE INDEX `RoleNameIndex` (`NormalizedName` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `aspnetroleclaims`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `aspnetroleclaims` ;

CREATE TABLE IF NOT EXISTS `aspnetroleclaims` (
  `Id` INT(11) NOT NULL AUTO_INCREMENT,
  `RoleId` VARCHAR(255) NOT NULL,
  `ClaimType` LONGTEXT NULL DEFAULT NULL,
  `ClaimValue` LONGTEXT NULL DEFAULT NULL,
  PRIMARY KEY (`Id`),
  INDEX `IX_AspNetRoleClaims_RoleId` (`RoleId` ASC),
  CONSTRAINT `FK_AspNetRoleClaims_AspNetRoles_RoleId`
    FOREIGN KEY (`RoleId`)
    REFERENCES `aspnetroles` (`Id`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `aspnetusers`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `aspnetusers` ;

CREATE TABLE IF NOT EXISTS `aspnetusers` (
  `Id` VARCHAR(255) NOT NULL,
  `UserName` VARCHAR(256) NOT NULL,
  `NormalizedUserName` VARCHAR(256) NULL,
  `Email` VARCHAR(256) NOT NULL,
  `NormalizedEmail` VARCHAR(256) NULL DEFAULT NULL,
  `EmailConfirmed` TINYINT(1) NOT NULL,
  `PasswordHash` LONGTEXT NULL DEFAULT NULL,
  `SecurityStamp` LONGTEXT NULL DEFAULT NULL,
  `ConcurrencyStamp` LONGTEXT NULL DEFAULT NULL,
  `PhoneNumber` LONGTEXT NULL DEFAULT NULL,
  `PhoneNumberConfirmed` TINYINT(1) NOT NULL,
  `TwoFactorEnabled` TINYINT(1) NOT NULL,
  `LockoutEnd` DATETIME(6) NULL DEFAULT NULL,
  `LockoutEnabled` TINYINT(1) NOT NULL,
  `AccessFailedCount` INT(11) NOT NULL,
  PRIMARY KEY (`Id`),
  INDEX `EmailIndex` (`NormalizedEmail` ASC),
  UNIQUE INDEX `Email_UNIQUE` (`Email` ASC),
  UNIQUE INDEX `UserName_UNIQUE` (`UserName` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `aspnetuserclaims`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `aspnetuserclaims` ;

CREATE TABLE IF NOT EXISTS `aspnetuserclaims` (
  `Id` INT(11) NOT NULL AUTO_INCREMENT,
  `UserId` VARCHAR(255) NOT NULL,
  `ClaimType` LONGTEXT NULL DEFAULT NULL,
  `ClaimValue` LONGTEXT NULL DEFAULT NULL,
  PRIMARY KEY (`Id`),
  INDEX `IX_AspNetUserClaims_UserId` (`UserId` ASC),
  CONSTRAINT `FK_AspNetUserClaims_AspNetUsers_UserId`
    FOREIGN KEY (`UserId`)
    REFERENCES `aspnetusers` (`Id`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `aspnetuserlogins`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `aspnetuserlogins` ;

CREATE TABLE IF NOT EXISTS `aspnetuserlogins` (
  `LoginProvider` VARCHAR(128) NOT NULL,
  `ProviderKey` VARCHAR(128) NOT NULL,
  `ProviderDisplayName` LONGTEXT NULL DEFAULT NULL,
  `UserId` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`LoginProvider`, `ProviderKey`),
  INDEX `IX_AspNetUserLogins_UserId` (`UserId` ASC),
  CONSTRAINT `FK_AspNetUserLogins_AspNetUsers_UserId`
    FOREIGN KEY (`UserId`)
    REFERENCES `aspnetusers` (`Id`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `aspnetuserroles`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `aspnetuserroles` ;

CREATE TABLE IF NOT EXISTS `aspnetuserroles` (
  `UserId` VARCHAR(255) NOT NULL,
  `RoleId` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`UserId`, `RoleId`),
  INDEX `IX_AspNetUserRoles_RoleId` (`RoleId` ASC),
  CONSTRAINT `FK_AspNetUserRoles_AspNetRoles_RoleId`
    FOREIGN KEY (`RoleId`)
    REFERENCES `aspnetroles` (`Id`)
    ON DELETE CASCADE,
  CONSTRAINT `FK_AspNetUserRoles_AspNetUsers_UserId`
    FOREIGN KEY (`UserId`)
    REFERENCES `aspnetusers` (`Id`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `aspnetusertokens`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `aspnetusertokens` ;

CREATE TABLE IF NOT EXISTS `aspnetusertokens` (
  `UserId` VARCHAR(255) NOT NULL,
  `LoginProvider` VARCHAR(128) NOT NULL,
  `Name` VARCHAR(128) NOT NULL,
  `Value` LONGTEXT NULL DEFAULT NULL,
  PRIMARY KEY (`UserId`, `LoginProvider`, `Name`),
  CONSTRAINT `FK_AspNetUserTokens_AspNetUsers_UserId`
    FOREIGN KEY (`UserId`)
    REFERENCES `aspnetusers` (`Id`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `manutencao`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `manutencao` ;

CREATE TABLE IF NOT EXISTS `manutencao` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `idVeiculo` INT(10) UNSIGNED NOT NULL,
  `idFornecedor` INT(10) UNSIGNED NOT NULL,
  `dataHora` DATETIME NOT NULL,
  `idResponsavel` INT(10) UNSIGNED NOT NULL,
  `valorPecas` DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  `valorManutencao` DECIMAL(10,2) NOT NULL,
  `tipo` ENUM('P', 'C') NOT NULL DEFAULT 'P',
  `comprovante` BLOB NULL DEFAULT NULL,
  `status` ENUM('O', 'A', 'E', 'F') NOT NULL DEFAULT 'O',
  `idFrota` INT(11) UNSIGNED ZEROFILL NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_Manutencao_Veiculo1_idx` (`idVeiculo` ASC),
  INDEX `fk_Manutencao_Fornecedor1_idx` (`idFornecedor` ASC),
  INDEX `fk_Manutencao_Pessoa1_idx` (`idResponsavel` ASC),
  INDEX `fk_manutencao_frota1_idx` (`idFrota` ASC),
  CONSTRAINT `fk_Manutencao_Fornecedor1`
    FOREIGN KEY (`idFornecedor`)
    REFERENCES `fornecedor` (`id`),
  CONSTRAINT `fk_Manutencao_Pessoa1`
    FOREIGN KEY (`idResponsavel`)
    REFERENCES `pessoa` (`id`),
  CONSTRAINT `fk_Manutencao_Veiculo1`
    FOREIGN KEY (`idVeiculo`)
    REFERENCES `veiculo` (`id`),
  CONSTRAINT `fk_manutencao_frota1`
    FOREIGN KEY (`idFrota`)
    REFERENCES `frota` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `marcaPecainsumo`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marcaPecainsumo` ;

CREATE TABLE IF NOT EXISTS `marcaPecainsumo` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `descricao` VARCHAR(50) NOT NULL,
  `idfrota` INT(11) UNSIGNED ZEROFILL NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_marcaPecainsumo_frota1_idx` (`idfrota` ASC),
  CONSTRAINT `fk_marcaPecainsumo_frota1`
    FOREIGN KEY (`idfrota`)
    REFERENCES `frota` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `pecainsumo`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `pecainsumo` ;

CREATE TABLE IF NOT EXISTS `pecainsumo` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `descricao` VARCHAR(50) NOT NULL,
  `mesesGarantia` INT NOT NULL DEFAULT 12,
  `kmGarantia` INT NOT NULL DEFAULT 5000,
  `idFrota` INT(11) UNSIGNED ZEROFILL NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_pecainsumo_frota1_idx` (`idFrota` ASC),
  CONSTRAINT `fk_pecainsumo_frota1`
    FOREIGN KEY (`idFrota`)
    REFERENCES `frota` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `manutencaoPecainsumo`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `manutencaoPecainsumo` ;

CREATE TABLE IF NOT EXISTS `manutencaoPecainsumo` (
  `idManutencao` INT(10) UNSIGNED NOT NULL,
  `idPecaInsumo` INT(10) UNSIGNED NOT NULL,
  `idMarcaPecaInsumo` INT(10) UNSIGNED NULL,
  `quantidade` FLOAT NOT NULL DEFAULT '1',
  `mesesGarantia` INT(11) NOT NULL DEFAULT '0',
  `kmGarantia` INT(11) NOT NULL,
  `valorIndividual` DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  `subtotal` DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`idManutencao`, `idPecaInsumo`),
  INDEX `fk_ManutencaoPecaInsumo_PecaInsumo1_idx` (`idPecaInsumo` ASC),
  INDEX `fk_ManutencaoPecaInsumo_Manutencao1_idx` (`idManutencao` ASC),
  INDEX `fk_ManutencaoPecaInsumo_MarcaPecaInsumo1_idx` (`idMarcaPecaInsumo` ASC),
  CONSTRAINT `fk_ManutencaoPecaInsumo_Manutencao1`
    FOREIGN KEY (`idManutencao`)
    REFERENCES `manutencao` (`id`),
  CONSTRAINT `fk_ManutencaoPecaInsumo_MarcaPecaInsumo1`
    FOREIGN KEY (`idMarcaPecaInsumo`)
    REFERENCES `marcaPecainsumo` (`id`),
  CONSTRAINT `fk_ManutencaoPecaInsumo_PecaInsumo1`
    FOREIGN KEY (`idPecaInsumo`)
    REFERENCES `pecainsumo` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `percurso`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `percurso` ;

CREATE TABLE IF NOT EXISTS `percurso` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `idVeiculo` INT(10) UNSIGNED NOT NULL,
  `idPessoa` INT(10) UNSIGNED NOT NULL,
  `dataHoraSaida` DATETIME NOT NULL,
  `dataHoraRetorno` DATETIME NOT NULL,
  `localPartida` VARCHAR(50) NOT NULL,
  `latitudePartida` FLOAT NULL DEFAULT NULL,
  `longitudePartida` FLOAT NULL DEFAULT NULL,
  `localChegada` VARCHAR(50) NOT NULL,
  `latitudeChegada` FLOAT NULL DEFAULT NULL,
  `longitudeChegada` FLOAT NULL DEFAULT NULL,
  `odometroInicial` INT(11) NOT NULL,
  `odometroFinal` INT(11) NOT NULL,
  `motivo` VARCHAR(300) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_VeiculoPessoa_Pessoa1_idx` (`idPessoa` ASC),
  INDEX `fk_VeiculoPessoa_Veiculo1_idx` (`idVeiculo` ASC),
  CONSTRAINT `fk_VeiculoPessoa_Pessoa1`
    FOREIGN KEY (`idPessoa`)
    REFERENCES `pessoa` (`id`),
  CONSTRAINT `fk_VeiculoPessoa_Veiculo1`
    FOREIGN KEY (`idVeiculo`)
    REFERENCES `veiculo` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `solicitacaoManutencao`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `solicitacaoManutencao` ;

CREATE TABLE IF NOT EXISTS `solicitacaoManutencao` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `idVeiculo` INT(10) UNSIGNED NOT NULL,
  `idPessoa` INT(10) UNSIGNED NOT NULL,
  `dataSolicitacao` DATETIME NOT NULL,
  `descricaoProblema` VARCHAR(500) NOT NULL,
  `idFrota` INT(11) UNSIGNED ZEROFILL NOT NULL,
  `prioridade` CHAR(1) DEFAULT 'M' COMMENT 'B=Baixa, M=Média, A=Alta, U=Urgente',
  `status` VARCHAR(20) DEFAULT 'Pendente',
  `observacoesTecnico` TEXT NULL,
  `dataConclusao` DATETIME NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_VeiculoPessoa_Pessoa2_idx` (`idPessoa` ASC),
  INDEX `fk_VeiculoPessoa_Veiculo2_idx` (`idVeiculo` ASC),
  INDEX `fk_solicitacaoManutencao_frota1_idx` (`idFrota` ASC),
  CONSTRAINT `fk_VeiculoPessoa_Pessoa2`
    FOREIGN KEY (`idPessoa`)
    REFERENCES `pessoa` (`id`),
  CONSTRAINT `fk_VeiculoPessoa_Veiculo2`
    FOREIGN KEY (`idVeiculo`)
    REFERENCES `veiculo` (`id`),
  CONSTRAINT `fk_solicitacaoManutencao_frota1`
    FOREIGN KEY (`idFrota`)
    REFERENCES `frota` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `veiculoPecainsumo`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `veiculoPecainsumo` ;

CREATE TABLE IF NOT EXISTS `veiculoPecainsumo` (
  `idVeiculo` INT(10) UNSIGNED NOT NULL,
  `idPecaInsumo` INT(10) UNSIGNED NOT NULL,
  `dataFinalGarantia` DATETIME NOT NULL,
  `kmFinalGarantia` INT(11) NOT NULL,
  `dataProximaTroca` DATETIME NOT NULL,
  `kmProximaTroca` INT(11) NOT NULL,
  PRIMARY KEY (`idVeiculo`, `idPecaInsumo`),
  INDEX `fk_VeiculoPecaInsumo_PecaInsumo1_idx` (`idPecaInsumo` ASC),
  INDEX `fk_VeiculoPecaInsumo_Veiculo1_idx` (`idVeiculo` ASC),
  CONSTRAINT `fk_VeiculoPecaInsumo_PecaInsumo1`
    FOREIGN KEY (`idPecaInsumo`)
    REFERENCES `pecainsumo` (`id`),
  CONSTRAINT `fk_VeiculoPecaInsumo_Veiculo1`
    FOREIGN KEY (`idVeiculo`)
    REFERENCES `veiculo` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `vistoria`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vistoria` ;

CREATE TABLE IF NOT EXISTS `vistoria` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `data` DATETIME NOT NULL,
  `problemas` VARCHAR(500) NOT NULL,
  `tipo` ENUM('S', 'R') NOT NULL DEFAULT 'S',
  `idPessoaResponsavel` INT(10) UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_Vistoria_Pessoa1_idx` (`idPessoaResponsavel` ASC),
  CONSTRAINT `fk_Vistoria_Pessoa1`
    FOREIGN KEY (`idPessoaResponsavel`)
    REFERENCES `pessoa` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
