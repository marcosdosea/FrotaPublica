CREATE DATABASE  IF NOT EXISTS `frota` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `frota`;
-- MySQL dump 10.13  Distrib 8.0.34, for Win64 (x86_64)
--
-- Host: localhost    Database: frota
-- ------------------------------------------------------
-- Server version	5.7.44-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `__efmigrationshistory`
--

DROP TABLE IF EXISTS `__efmigrationshistory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `__efmigrationshistory` (
  `MigrationId` varchar(150) NOT NULL,
  `ProductVersion` varchar(32) NOT NULL,
  PRIMARY KEY (`MigrationId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `__efmigrationshistory`
--

LOCK TABLES `__efmigrationshistory` WRITE;
/*!40000 ALTER TABLE `__efmigrationshistory` DISABLE KEYS */;
/*!40000 ALTER TABLE `__efmigrationshistory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `abastecimento`
--

DROP TABLE IF EXISTS `abastecimento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `abastecimento` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `idVeiculoPercurso` int(10) unsigned NOT NULL,
  `idPessoaPercurso` int(10) unsigned NOT NULL,
  `dataHora` datetime NOT NULL,
  `odometro` int(11) NOT NULL DEFAULT '0',
  `litros` int(11) NOT NULL DEFAULT '0',
  `idFornecedor` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_Abastecimento_Percurso1_idx` (`idVeiculoPercurso`,`idPessoaPercurso`),
  KEY `fk_Abastecimento_Fornecedor1_idx` (`idFornecedor`),
  CONSTRAINT `fk_Abastecimento_Fornecedor1` FOREIGN KEY (`idFornecedor`) REFERENCES `fornecedor` (`id`),
  CONSTRAINT `fk_Abastecimento_Percurso1` FOREIGN KEY (`idVeiculoPercurso`, `idPessoaPercurso`) REFERENCES `percurso` (`idVeiculo`, `idPessoa`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `abastecimento`
--

LOCK TABLES `abastecimento` WRITE;
/*!40000 ALTER TABLE `abastecimento` DISABLE KEYS */;
/*!40000 ALTER TABLE `abastecimento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aspnetroleclaims`
--

DROP TABLE IF EXISTS `aspnetroleclaims`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aspnetroleclaims` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `RoleId` varchar(255) NOT NULL,
  `ClaimType` longtext,
  `ClaimValue` longtext,
  PRIMARY KEY (`Id`),
  KEY `IX_AspNetRoleClaims_RoleId` (`RoleId`),
  CONSTRAINT `FK_AspNetRoleClaims_AspNetRoles_RoleId` FOREIGN KEY (`RoleId`) REFERENCES `aspnetroles` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aspnetroleclaims`
--

LOCK TABLES `aspnetroleclaims` WRITE;
/*!40000 ALTER TABLE `aspnetroleclaims` DISABLE KEYS */;
/*!40000 ALTER TABLE `aspnetroleclaims` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aspnetroles`
--

DROP TABLE IF EXISTS `aspnetroles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aspnetroles` (
  `Id` varchar(255) NOT NULL,
  `Name` varchar(256) DEFAULT NULL,
  `NormalizedName` varchar(256) DEFAULT NULL,
  `ConcurrencyStamp` longtext,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `RoleNameIndex` (`NormalizedName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aspnetroles`
--

LOCK TABLES `aspnetroles` WRITE;
/*!40000 ALTER TABLE `aspnetroles` DISABLE KEYS */;
INSERT INTO `aspnetroles` VALUES ('03dd21ba-a0cd-11ef-ab61-a8a1593b3445','Administrador','ADMINISTRADOR','03dd21d2-a0cd-11ef-ab61-a8a1593b3445'),('03dd246a-a0cd-11ef-ab61-a8a1593b3445','Mecânico','MECÂNICO','03dd246f-a0cd-11ef-ab61-a8a1593b3445'),('03dd24e1-a0cd-11ef-ab61-a8a1593b3445','Gestor','GESTOR','03dd24e6-a0cd-11ef-ab61-a8a1593b3445'),('03dd2521-a0cd-11ef-ab61-a8a1593b3445','Motorista','MOTORISTA','03dd2525-a0cd-11ef-ab61-a8a1593b3445');
/*!40000 ALTER TABLE `aspnetroles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aspnetuserclaims`
--

DROP TABLE IF EXISTS `aspnetuserclaims`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aspnetuserclaims` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `UserId` varchar(255) NOT NULL,
  `ClaimType` longtext,
  `ClaimValue` longtext,
  PRIMARY KEY (`Id`),
  KEY `IX_AspNetUserClaims_UserId` (`UserId`),
  CONSTRAINT `FK_AspNetUserClaims_AspNetUsers_UserId` FOREIGN KEY (`UserId`) REFERENCES `aspnetusers` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aspnetuserclaims`
--

LOCK TABLES `aspnetuserclaims` WRITE;
/*!40000 ALTER TABLE `aspnetuserclaims` DISABLE KEYS */;
/*!40000 ALTER TABLE `aspnetuserclaims` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aspnetuserlogins`
--

DROP TABLE IF EXISTS `aspnetuserlogins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aspnetuserlogins` (
  `LoginProvider` varchar(128) NOT NULL,
  `ProviderKey` varchar(128) NOT NULL,
  `ProviderDisplayName` longtext,
  `UserId` varchar(255) NOT NULL,
  PRIMARY KEY (`LoginProvider`,`ProviderKey`),
  KEY `IX_AspNetUserLogins_UserId` (`UserId`),
  CONSTRAINT `FK_AspNetUserLogins_AspNetUsers_UserId` FOREIGN KEY (`UserId`) REFERENCES `aspnetusers` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aspnetuserlogins`
--

LOCK TABLES `aspnetuserlogins` WRITE;
/*!40000 ALTER TABLE `aspnetuserlogins` DISABLE KEYS */;
/*!40000 ALTER TABLE `aspnetuserlogins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aspnetuserroles`
--

DROP TABLE IF EXISTS `aspnetuserroles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aspnetuserroles` (
  `UserId` varchar(255) NOT NULL,
  `RoleId` varchar(255) NOT NULL,
  PRIMARY KEY (`UserId`,`RoleId`),
  KEY `IX_AspNetUserRoles_RoleId` (`RoleId`),
  CONSTRAINT `FK_AspNetUserRoles_AspNetRoles_RoleId` FOREIGN KEY (`RoleId`) REFERENCES `aspnetroles` (`Id`) ON DELETE CASCADE,
  CONSTRAINT `FK_AspNetUserRoles_AspNetUsers_UserId` FOREIGN KEY (`UserId`) REFERENCES `aspnetusers` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aspnetuserroles`
--

LOCK TABLES `aspnetuserroles` WRITE;
/*!40000 ALTER TABLE `aspnetuserroles` DISABLE KEYS */;
/*!40000 ALTER TABLE `aspnetuserroles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aspnetusers`
--

DROP TABLE IF EXISTS `aspnetusers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aspnetusers` (
  `Id` varchar(255) NOT NULL,
  `UserName` varchar(256) NOT NULL,
  `NormalizedUserName` varchar(256) DEFAULT NULL,
  `Email` varchar(256) NOT NULL,
  `NormalizedEmail` varchar(256) DEFAULT NULL,
  `EmailConfirmed` tinyint(1) NOT NULL,
  `PasswordHash` longtext,
  `SecurityStamp` longtext,
  `ConcurrencyStamp` longtext,
  `PhoneNumber` longtext,
  `PhoneNumberConfirmed` tinyint(1) NOT NULL,
  `TwoFactorEnabled` tinyint(1) NOT NULL,
  `LockoutEnd` datetime DEFAULT NULL,
  `LockoutEnabled` tinyint(1) NOT NULL,
  `AccessFailedCount` int(11) NOT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `Email_UNIQUE` (`Email`),
  UNIQUE KEY `UserName_UNIQUE` (`UserName`),
  KEY `EmailIndex` (`NormalizedEmail`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aspnetusers`
--

LOCK TABLES `aspnetusers` WRITE;
/*!40000 ALTER TABLE `aspnetusers` DISABLE KEYS */;
/*!40000 ALTER TABLE `aspnetusers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aspnetusertokens`
--

DROP TABLE IF EXISTS `aspnetusertokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aspnetusertokens` (
  `UserId` varchar(255) NOT NULL,
  `LoginProvider` varchar(128) NOT NULL,
  `Name` varchar(128) NOT NULL,
  `Value` longtext,
  PRIMARY KEY (`UserId`,`LoginProvider`,`Name`),
  CONSTRAINT `FK_AspNetUserTokens_AspNetUsers_UserId` FOREIGN KEY (`UserId`) REFERENCES `aspnetusers` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aspnetusertokens`
--

LOCK TABLES `aspnetusertokens` WRITE;
/*!40000 ALTER TABLE `aspnetusertokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `aspnetusertokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fornecedor`
--

DROP TABLE IF EXISTS `fornecedor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fornecedor` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(50) NOT NULL,
  `cnpj` varchar(14) NOT NULL,
  `cep` varchar(8) DEFAULT NULL,
  `rua` varchar(50) DEFAULT NULL,
  `bairro` varchar(50) DEFAULT NULL,
  `numero` varchar(10) DEFAULT NULL,
  `complemento` varchar(50) DEFAULT NULL,
  `cidade` varchar(50) DEFAULT NULL,
  `estado` varchar(2) DEFAULT NULL,
  `latitude` int(11) DEFAULT NULL,
  `longitude` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cnpj_UNIQUE` (`cnpj`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fornecedor`
--

LOCK TABLES `fornecedor` WRITE;
/*!40000 ALTER TABLE `fornecedor` DISABLE KEYS */;
/*!40000 ALTER TABLE `fornecedor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `frota`
--

DROP TABLE IF EXISTS `frota`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `frota` (
  `id` int(11) unsigned zerofill NOT NULL AUTO_INCREMENT,
  `nome` varchar(50) NOT NULL,
  `cnpj` varchar(14) NOT NULL,
  `cep` varchar(8) DEFAULT NULL,
  `rua` varchar(50) DEFAULT NULL,
  `bairro` varchar(50) DEFAULT NULL,
  `numero` varchar(10) DEFAULT NULL,
  `complemento` varchar(50) DEFAULT NULL,
  `cidade` varchar(50) DEFAULT NULL,
  `estado` varchar(2) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cnpj_UNIQUE` (`cnpj`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `frota`
--

LOCK TABLES `frota` WRITE;
/*!40000 ALTER TABLE `frota` DISABLE KEYS */;
/*!40000 ALTER TABLE `frota` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `manutencao`
--

DROP TABLE IF EXISTS `manutencao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `manutencao` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `idVeiculo` int(10) unsigned NOT NULL,
  `idFornecedor` int(10) unsigned NOT NULL,
  `dataHora` datetime NOT NULL,
  `idResponsavel` int(10) unsigned NOT NULL,
  `valorPecas` decimal(10,2) NOT NULL DEFAULT '0.00',
  `valorManutencao` decimal(10,2) NOT NULL,
  `tipo` enum('P','C') NOT NULL DEFAULT 'P',
  `comprovante` blob,
  `status` enum('O','A','E','F') NOT NULL DEFAULT 'O',
  PRIMARY KEY (`id`),
  KEY `fk_Manutencao_Veiculo1_idx` (`idVeiculo`),
  KEY `fk_Manutencao_Fornecedor1_idx` (`idFornecedor`),
  KEY `fk_Manutencao_Pessoa1_idx` (`idResponsavel`),
  CONSTRAINT `fk_Manutencao_Fornecedor1` FOREIGN KEY (`idFornecedor`) REFERENCES `fornecedor` (`id`),
  CONSTRAINT `fk_Manutencao_Pessoa1` FOREIGN KEY (`idResponsavel`) REFERENCES `pessoa` (`id`),
  CONSTRAINT `fk_Manutencao_Veiculo1` FOREIGN KEY (`idVeiculo`) REFERENCES `veiculo` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `manutencao`
--

LOCK TABLES `manutencao` WRITE;
/*!40000 ALTER TABLE `manutencao` DISABLE KEYS */;
/*!40000 ALTER TABLE `manutencao` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `manutencaopecainsumo`
--

DROP TABLE IF EXISTS `manutencaopecainsumo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `manutencaopecainsumo` (
  `idManutencao` int(10) unsigned NOT NULL,
  `idPecaInsumo` int(10) unsigned NOT NULL,
  `idMarcaPecaInsumo` int(10) unsigned NOT NULL,
  `quantidade` float NOT NULL DEFAULT '1',
  `mesesGarantia` int(11) NOT NULL DEFAULT '0',
  `kmGarantia` int(11) NOT NULL,
  `valorIndividual` decimal(10,2) NOT NULL DEFAULT '0.00',
  `subtotal` decimal(10,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`idManutencao`,`idPecaInsumo`),
  KEY `fk_ManutencaoPecaInsumo_PecaInsumo1_idx` (`idPecaInsumo`),
  KEY `fk_ManutencaoPecaInsumo_Manutencao1_idx` (`idManutencao`),
  KEY `fk_ManutencaoPecaInsumo_MarcaPecaInsumo1_idx` (`idMarcaPecaInsumo`),
  CONSTRAINT `fk_ManutencaoPecaInsumo_Manutencao1` FOREIGN KEY (`idManutencao`) REFERENCES `manutencao` (`id`),
  CONSTRAINT `fk_ManutencaoPecaInsumo_MarcaPecaInsumo1` FOREIGN KEY (`idMarcaPecaInsumo`) REFERENCES `marcapecainsumo` (`id`),
  CONSTRAINT `fk_ManutencaoPecaInsumo_PecaInsumo1` FOREIGN KEY (`idPecaInsumo`) REFERENCES `pecainsumo` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `manutencaopecainsumo`
--

LOCK TABLES `manutencaopecainsumo` WRITE;
/*!40000 ALTER TABLE `manutencaopecainsumo` DISABLE KEYS */;
/*!40000 ALTER TABLE `manutencaopecainsumo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `marcapecainsumo`
--

DROP TABLE IF EXISTS `marcapecainsumo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `marcapecainsumo` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `descricao` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=216 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `marcapecainsumo`
--

LOCK TABLES `marcapecainsumo` WRITE;
/*!40000 ALTER TABLE `marcapecainsumo` DISABLE KEYS */;
/*!40000 ALTER TABLE `marcapecainsumo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `marcaveiculo`
--

DROP TABLE IF EXISTS `marcaveiculo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `marcaveiculo` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `marcaveiculo`
--

LOCK TABLES `marcaveiculo` WRITE;
/*!40000 ALTER TABLE `marcaveiculo` DISABLE KEYS */;
/*!40000 ALTER TABLE `marcaveiculo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `modeloveiculo`
--

DROP TABLE IF EXISTS `modeloveiculo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `modeloveiculo` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `idMarcaVeiculo` int(10) unsigned NOT NULL,
  `nome` varchar(50) NOT NULL,
  `capacidadeTanque` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_ModeloVeiculo_MarcaVeiculo_idx` (`idMarcaVeiculo`),
  CONSTRAINT `fk_ModeloVeiculo_MarcaVeiculo` FOREIGN KEY (`idMarcaVeiculo`) REFERENCES `marcaveiculo` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `modeloveiculo`
--

LOCK TABLES `modeloveiculo` WRITE;
/*!40000 ALTER TABLE `modeloveiculo` DISABLE KEYS */;
/*!40000 ALTER TABLE `modeloveiculo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `papelpessoa`
--

DROP TABLE IF EXISTS `papelpessoa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `papelpessoa` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `papel` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `papelpessoa`
--

LOCK TABLES `papelpessoa` WRITE;
/*!40000 ALTER TABLE `papelpessoa` DISABLE KEYS */;
INSERT INTO `papelpessoa` VALUES (1,'Administrador'),(2,'Mecânico'),(3,'Gestor'),(4,'Motorista');
/*!40000 ALTER TABLE `papelpessoa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pecainsumo`
--

DROP TABLE IF EXISTS `pecainsumo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pecainsumo` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `descricao` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pecainsumo`
--

LOCK TABLES `pecainsumo` WRITE;
/*!40000 ALTER TABLE `pecainsumo` DISABLE KEYS */;
/*!40000 ALTER TABLE `pecainsumo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `percurso`
--

DROP TABLE IF EXISTS `percurso`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `percurso` (
  `idVeiculo` int(10) unsigned NOT NULL,
  `idPessoa` int(10) unsigned NOT NULL,
  `dataHoraSaida` datetime NOT NULL,
  `dataHoraRetorno` datetime NOT NULL,
  `localPartida` varchar(50) NOT NULL,
  `latitudePartida` float DEFAULT NULL,
  `longitudePartida` float DEFAULT NULL,
  `localChegada` varchar(50) NOT NULL,
  `latitudeChegada` float DEFAULT NULL,
  `longitudeChegada` float DEFAULT NULL,
  `odometroInicial` int(11) NOT NULL,
  `odometroFinal` int(11) NOT NULL,
  `motivo` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`idVeiculo`,`idPessoa`),
  KEY `fk_VeiculoPessoa_Pessoa1_idx` (`idPessoa`),
  KEY `fk_VeiculoPessoa_Veiculo1_idx` (`idVeiculo`),
  CONSTRAINT `fk_VeiculoPessoa_Pessoa1` FOREIGN KEY (`idPessoa`) REFERENCES `pessoa` (`id`),
  CONSTRAINT `fk_VeiculoPessoa_Veiculo1` FOREIGN KEY (`idVeiculo`) REFERENCES `veiculo` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `percurso`
--

LOCK TABLES `percurso` WRITE;
/*!40000 ALTER TABLE `percurso` DISABLE KEYS */;
/*!40000 ALTER TABLE `percurso` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pessoa`
--

DROP TABLE IF EXISTS `pessoa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pessoa` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `cpf` varchar(11) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `cep` varchar(8) DEFAULT NULL,
  `rua` varchar(50) DEFAULT NULL,
  `bairro` varchar(50) DEFAULT NULL,
  `complemento` varchar(50) DEFAULT NULL,
  `numero` varchar(10) DEFAULT NULL,
  `cidade` varchar(50) DEFAULT NULL,
  `estado` varchar(2) NOT NULL,
  `idFrota` int(11) unsigned zerofill NOT NULL,
  `idPapelPessoa` int(10) unsigned NOT NULL,
  `ativo` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `cpf_UNIQUE` (`cpf`),
  KEY `fk_Pessoa_Frota1_idx` (`idFrota`),
  KEY `fk_Pessoa_PapelPessoa1_idx` (`idPapelPessoa`),
  CONSTRAINT `fk_Pessoa_Frota1` FOREIGN KEY (`idFrota`) REFERENCES `frota` (`id`),
  CONSTRAINT `fk_Pessoa_PapelPessoa1` FOREIGN KEY (`idPapelPessoa`) REFERENCES `papelpessoa` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pessoa`
--

LOCK TABLES `pessoa` WRITE;
/*!40000 ALTER TABLE `pessoa` DISABLE KEYS */;
/*!40000 ALTER TABLE `pessoa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `solicitacaomanutencao`
--

DROP TABLE IF EXISTS `solicitacaomanutencao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `solicitacaomanutencao` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `idVeiculo` int(10) unsigned NOT NULL,
  `idPessoa` int(10) unsigned NOT NULL,
  `dataSolicitacao` datetime NOT NULL,
  `descricaoProblema` varchar(500) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_VeiculoPessoa_Pessoa2_idx` (`idPessoa`),
  KEY `fk_VeiculoPessoa_Veiculo2_idx` (`idVeiculo`),
  CONSTRAINT `fk_VeiculoPessoa_Pessoa2` FOREIGN KEY (`idPessoa`) REFERENCES `pessoa` (`id`),
  CONSTRAINT `fk_VeiculoPessoa_Veiculo2` FOREIGN KEY (`idVeiculo`) REFERENCES `veiculo` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `solicitacaomanutencao`
--

LOCK TABLES `solicitacaomanutencao` WRITE;
/*!40000 ALTER TABLE `solicitacaomanutencao` DISABLE KEYS */;
/*!40000 ALTER TABLE `solicitacaomanutencao` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `unidadeadministrativa`
--

DROP TABLE IF EXISTS `unidadeadministrativa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `unidadeadministrativa` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(50) NOT NULL,
  `cep` varchar(8) DEFAULT NULL,
  `rua` varchar(50) DEFAULT NULL,
  `bairro` varchar(50) DEFAULT NULL,
  `complemento` varchar(50) DEFAULT NULL,
  `numero` varchar(10) DEFAULT NULL,
  `cidade` varchar(50) DEFAULT NULL,
  `estado` varchar(2) DEFAULT NULL,
  `latitude` float DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `unidadeadministrativa`
--

LOCK TABLES `unidadeadministrativa` WRITE;
/*!40000 ALTER TABLE `unidadeadministrativa` DISABLE KEYS */;
/*!40000 ALTER TABLE `unidadeadministrativa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `veiculo`
--

DROP TABLE IF EXISTS `veiculo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `veiculo` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `placa` varchar(10) NOT NULL,
  `chassi` varchar(50) DEFAULT NULL,
  `cor` varchar(50) NOT NULL,
  `idModeloVeiculo` int(10) unsigned NOT NULL,
  `idFrota` int(11) unsigned zerofill NOT NULL,
  `idUnidadeAdministrativa` int(10) unsigned NOT NULL,
  `odometro` int(11) NOT NULL DEFAULT '0',
  `status` enum('D','U','M','I') NOT NULL DEFAULT 'D',
  `ano` int(11) NOT NULL,
  `modelo` int(11) NOT NULL,
  `renavan` varchar(50) DEFAULT NULL,
  `vencimentoIPVA` datetime DEFAULT NULL,
  `valor` decimal(10,2) NOT NULL,
  `dataReferenciaValor` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `placa_UNIQUE` (`placa`),
  UNIQUE KEY `chassi_UNIQUE` (`chassi`),
  UNIQUE KEY `renavan_UNIQUE` (`renavan`),
  KEY `fk_Veiculo_ModeloVeiculo1_idx` (`idModeloVeiculo`),
  KEY `fk_Veiculo_Frota1_idx` (`idFrota`),
  KEY `fk_Veiculo_UnidadeAdministrativa1_idx` (`idUnidadeAdministrativa`),
  CONSTRAINT `fk_Veiculo_Frota1` FOREIGN KEY (`idFrota`) REFERENCES `frota` (`id`),
  CONSTRAINT `fk_Veiculo_ModeloVeiculo1` FOREIGN KEY (`idModeloVeiculo`) REFERENCES `modeloveiculo` (`id`),
  CONSTRAINT `fk_Veiculo_UnidadeAdministrativa1` FOREIGN KEY (`idUnidadeAdministrativa`) REFERENCES `unidadeadministrativa` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `veiculo`
--

LOCK TABLES `veiculo` WRITE;
/*!40000 ALTER TABLE `veiculo` DISABLE KEYS */;
/*!40000 ALTER TABLE `veiculo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `veiculopecainsumo`
--

DROP TABLE IF EXISTS `veiculopecainsumo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `veiculopecainsumo` (
  `idVeiculo` int(10) unsigned NOT NULL,
  `idPecaInsumo` int(10) unsigned NOT NULL,
  `dataFinalGarantia` datetime NOT NULL,
  `kmFinalGarantia` int(11) NOT NULL,
  `dataProximaTroca` datetime NOT NULL,
  `kmProximaTroca` int(11) NOT NULL,
  PRIMARY KEY (`idVeiculo`,`idPecaInsumo`),
  KEY `fk_VeiculoPecaInsumo_PecaInsumo1_idx` (`idPecaInsumo`),
  KEY `fk_VeiculoPecaInsumo_Veiculo1_idx` (`idVeiculo`),
  CONSTRAINT `fk_VeiculoPecaInsumo_PecaInsumo1` FOREIGN KEY (`idPecaInsumo`) REFERENCES `pecainsumo` (`id`),
  CONSTRAINT `fk_VeiculoPecaInsumo_Veiculo1` FOREIGN KEY (`idVeiculo`) REFERENCES `veiculo` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `veiculopecainsumo`
--

LOCK TABLES `veiculopecainsumo` WRITE;
/*!40000 ALTER TABLE `veiculopecainsumo` DISABLE KEYS */;
/*!40000 ALTER TABLE `veiculopecainsumo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vistoria`
--

DROP TABLE IF EXISTS `vistoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vistoria` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data` datetime NOT NULL,
  `problemas` varchar(500) NOT NULL,
  `tipo` enum('S','R') NOT NULL DEFAULT 'S',
  `idPessoaResponsavel` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_Vistoria_Pessoa1_idx` (`idPessoaResponsavel`),
  CONSTRAINT `fk_Vistoria_Pessoa1` FOREIGN KEY (`idPessoaResponsavel`) REFERENCES `pessoa` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vistoria`
--

LOCK TABLES `vistoria` WRITE;
/*!40000 ALTER TABLE `vistoria` DISABLE KEYS */;
/*!40000 ALTER TABLE `vistoria` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-11-12  5:08:15
