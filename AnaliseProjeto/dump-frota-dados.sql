-- MySQL dump 10.13  Distrib 5.7.44, for Win64 (x86_64)
--
-- Host: localhost    Database: frota
-- ------------------------------------------------------
-- Server version	5.7.44-log

USE FROTA;

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping data for table `__efmigrationshistory`
--

LOCK TABLES `__efmigrationshistory` WRITE;
/*!40000 ALTER TABLE `__efmigrationshistory` DISABLE KEYS */;
/*!40000 ALTER TABLE `__efmigrationshistory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `abastecimento`
--

LOCK TABLES `abastecimento` WRITE;
/*!40000 ALTER TABLE `abastecimento` DISABLE KEYS */;
INSERT INTO `abastecimento` VALUES (1,1,1,00000000001,1,'2024-12-01 08:30:00',15000,50.00),(2,2,2,00000000002,2,'2024-12-02 09:15:00',20000,45.50),(3,3,3,00000000003,3,'2024-12-03 10:45:00',25000,60.75),(4,4,4,00000000004,4,'2024-12-04 11:30:00',30000,55.30),(5,5,5,00000000005,5,'2024-12-05 12:00:00',12000,48.20),(6,6,6,00000000006,7,'2024-12-06 13:00:00',18000,52.10),(7,7,7,00000000007,10,'2024-12-07 14:30:00',22000,49.00),(8,8,8,00000000008,18,'2024-12-08 15:00:00',17000,53.45),(9,9,9,00000000009,1,'2024-12-09 16:30:00',23000,47.80),(10,10,10,00000000010,2,'2024-12-10 17:00:00',26000,59.10),(11,11,11,00000000011,3,'2024-12-11 18:30:00',31000,50.25),(12,1,12,00000000001,4,'2024-12-12 19:00:00',19000,42.75),(13,2,1,00000000002,5,'2024-12-13 20:30:00',22000,58.00),(14,3,2,00000000003,7,'2024-12-14 21:00:00',25000,45.90),(15,4,3,00000000004,10,'2024-12-15 22:30:00',30000,49.50),(16,5,4,00000000005,18,'2024-12-16 23:00:00',32000,51.30),(17,6,5,00000000006,1,'2024-12-17 07:00:00',12000,53.75),(18,7,6,00000000007,2,'2024-12-18 08:00:00',17000,46.50),(19,8,7,00000000008,3,'2024-12-19 09:30:00',21000,60.25),(20,9,8,00000000009,4,'2024-12-20 10:00:00',18000,55.40),(21,10,9,00000000010,5,'2024-12-21 11:30:00',24000,48.00),(22,11,10,00000000011,7,'2024-12-22 12:00:00',26000,52.10),(23,1,11,00000000001,10,'2024-12-23 13:30:00',30000,49.80),(24,2,12,00000000002,18,'2024-12-24 14:00:00',32000,57.40);
/*!40000 ALTER TABLE `abastecimento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `aspnetroleclaims`
--

LOCK TABLES `aspnetroleclaims` WRITE;
/*!40000 ALTER TABLE `aspnetroleclaims` DISABLE KEYS */;
/*!40000 ALTER TABLE `aspnetroleclaims` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `aspnetroles`
--

LOCK TABLES `aspnetroles` WRITE;
/*!40000 ALTER TABLE `aspnetroles` DISABLE KEYS */;
INSERT INTO `aspnetroles` VALUES ('bd39e691-c4a2-11ef-b263-a8a1593b3445','Administrador','ADMINISTRADOR','bd39e6e6-c4a2-11ef-b263-a8a1593b3445'),('bd39eb8b-c4a2-11ef-b263-a8a1593b3445','Mecânico','MECANICO','bd39eb97-c4a2-11ef-b263-a8a1593b3445'),('bd39ec25-c4a2-11ef-b263-a8a1593b3445','Gestor','GESTOR','bd39ec2c-c4a2-11ef-b263-a8a1593b3445'),('bd39ec6c-c4a2-11ef-b263-a8a1593b3445','Motorista','MOTORISTA','bd39ec72-c4a2-11ef-b263-a8a1593b3445');
/*!40000 ALTER TABLE `aspnetroles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `aspnetuserclaims`
--

LOCK TABLES `aspnetuserclaims` WRITE;
/*!40000 ALTER TABLE `aspnetuserclaims` DISABLE KEYS */;
/*!40000 ALTER TABLE `aspnetuserclaims` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `aspnetuserlogins`
--

LOCK TABLES `aspnetuserlogins` WRITE;
/*!40000 ALTER TABLE `aspnetuserlogins` DISABLE KEYS */;
/*!40000 ALTER TABLE `aspnetuserlogins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `aspnetuserroles`
--

LOCK TABLES `aspnetuserroles` WRITE;
/*!40000 ALTER TABLE `aspnetuserroles` DISABLE KEYS */;
INSERT INTO `aspnetuserroles` VALUES ('74c06eb8-739c-4323-9daa-f292f2252ef2','bd39e691-c4a2-11ef-b263-a8a1593b3445'),('af371b24-46e6-4c09-a941-31f8e2ed4064','bd39e691-c4a2-11ef-b263-a8a1593b3445'),('e99546be-0790-485a-8d67-91fed0eef117','bd39e691-c4a2-11ef-b263-a8a1593b3445'),('1bdc0960-9fac-4ced-8924-b1ee89ceca94','bd39eb8b-c4a2-11ef-b263-a8a1593b3445'),('56d2bb89-302e-46d1-b2f5-ae7b79685000','bd39ec25-c4a2-11ef-b263-a8a1593b3445'),('b4d751b4-b4df-44be-aefd-4492ca4fe766','bd39ec6c-c4a2-11ef-b263-a8a1593b3445');
/*!40000 ALTER TABLE `aspnetuserroles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `aspnetusers`
--

LOCK TABLES `aspnetusers` WRITE;
/*!40000 ALTER TABLE `aspnetusers` DISABLE KEYS */;
INSERT INTO `aspnetusers` VALUES ('1bdc0960-9fac-4ced-8924-b1ee89ceca94','58534953058','58534953058','ricardo.oliveira@gmail.com','RICARDO.OLIVEIRA@GMAIL.COM',1,'AQAAAAIAAYagAAAAENXl1DobFITFY/NTCvyMDKKh0QN4PRRUA+Xkj3yCInMgQsCxB6IudW8KJLKSlOSuug==','O7V2JID7F7NEHLXYO42WK5PFDXCTQFW6','9dffba4c-a1cf-41ea-9f5a-e09c92f0c192',NULL,0,0,NULL,1,0),('56d2bb89-302e-46d1-b2f5-ae7b79685000','58928940028','58928940028','carla.dias@gmail.com','CARLA.DIAS@GMAIL.COM',1,'AQAAAAIAAYagAAAAECuGr1DzZJfL/4q0BfIYKNCIQ/JmzjO6gbWsP/27/Flmezx2P8Qy7xs5+AWYAlrLEg==','XKUWMNWD6MMQ3JDVSG2SZVOG25HJHCOF','f078f962-bed5-44e8-8346-172da794571a',NULL,0,0,NULL,1,0),('74c06eb8-739c-4323-9daa-f292f2252ef2','99738417007','99738417007','grguilima@gmail.com','GRGUILIMA@GMAIL.COM',1,'AQAAAAIAAYagAAAAEJpfooKd91+1ESoEw3ifndGfXlqgl9qWd2Xbti/0le792V1Iok/bmoolDGfn7boTkA==','ME6V3WPW2E7Q7W7E2T73RQ4G2UQPFXI5','0bacbb00-6256-42b8-81dd-21197dcd91d5',NULL,0,0,NULL,1,0),('af371b24-46e6-4c09-a941-31f8e2ed4064','44476798098','44476798098','kaua.oliveira@gmail.com','KAUA.OLIVEIRA@GMAIL.COM',1,'AQAAAAIAAYagAAAAEDFK77sG6EtVmHHTCgx0ZUr6zUyl5bguPSAQHiq+m4oo6EF0ad7CXwvTVcCc3dI+9Q==','2UCZ2MFS3BBMB5RDOS73LECMBKZZXPML','db9ba9b7-b975-4f63-9f7d-7bfd392197a9',NULL,0,0,NULL,1,0),('b4d751b4-b4df-44be-aefd-4492ca4fe766','78860691028','78860691028','igor.andrade@gmail.com','IGOR.ANDRADE@GMAIL.COM',1,'AQAAAAIAAYagAAAAENMX04WGwAR/2njcEOtBCVI+Auxj3atKhjRzE5P56ENJticP1kAQTFxbArB5Igzn9g==','GJDNRBUFPXQZMMZU2MTOIQIYWWGOJPSV','efccd221-e1c7-4ca3-9885-66d235c0db6c',NULL,0,0,NULL,1,0),('e99546be-0790-485a-8d67-91fed0eef117','38534499055','38534499055','marcos.dosea@gmail.com','MARCOS.DOSEA@GMAIL.COM',1,'AQAAAAIAAYagAAAAEEOhya7tb3FYGDuXQpmJy2q+9RDzCwwIh2Hj41oVVjRj66BqznxGqTG9aYzH/IpAoQ==','3JXM7LESATH2MFSHMDG3RJEHQG4ADUB4','fa788efa-db00-402a-8957-16bd6d7f92ab',NULL,0,0,NULL,1,0);
/*!40000 ALTER TABLE `aspnetusers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `aspnetusertokens`
--

LOCK TABLES `aspnetusertokens` WRITE;
/*!40000 ALTER TABLE `aspnetusertokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `aspnetusertokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `fornecedor`
--

LOCK TABLES `fornecedor` WRITE;
/*!40000 ALTER TABLE `fornecedor` DISABLE KEYS */;
INSERT INTO `fornecedor` VALUES (1,'Auto Peças Sul','43038263087',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,00000000001,1),(2,'Auto Manutenção LTDA','95655437074','25716028','Servidão João Pereira da Silva','Cascatinha','400','Pavilhão B','Petrópolis','RJ',-235433,-466339,00000000002,1),(3,'Veículo Pro','22733054007','24753740','Rua Adicional','Rio do Ouro','45','Conjunto 15','São Gonçalo','RJ',NULL,NULL,00000000003,1),(4,'Frota Services','27201030043','68908644','Avenida Macapá','Boné Azul','78','Galpão 10','Macapá','AP',-166860,-492645,00000000004,1),(5,'Frota Parceira','75944992042','31250250','Rua Henrique Dias','Ermelinda','120',NULL,'Belo Horizonte','MG',-235505,-466333,00000000005,1),(6,'Peças e Motores Silva','53597076076','97509572','Quadra R','União das Vilas','150','Pavilhão A','Uruguaiana','RS',-231896,-470050,00000000006,1),(7,'Soluções Automotivas','14775265016','77415630','Rua 75','Parque Residencial Nova Fronteira','500','Andar 10','Gurupi','TO',-229068,-431729,00000000007,1),(8,'Transportadora Nova Frota','91371612021','58404864','Cuités','Vila São Francisco','220',NULL,'Campina Grande','PB',-199260,-439360,00000000008,1),(9,'Itaú Unibanco','23820759026','81830050','Rua Catarina Goossen','Xaxim','1000',NULL,'Curitiba','PR',-235636,-466549,00000000009,1),(10,'Mecânica e Peças Alfa','13237921041','57073080','Rua Radialista Haroldo Amorim Miranda','Cidade Universitária','350','Térreo','Maceió','AL',-157801,-479292,00000000010,1),(11,'Frota Max','79940540051','79104690','Rua 77','Vila Nova Campo Grande','333','Loja 2','Campo Grande','MS',-300346,-512177,00000000011,1),(12,'Frota Total','81493920090','89805540','Rua Francisco Dias Velho','Passo dos Fortes','500','Conjunto 6','Chapecó','SC',-235575,-466333,00000000001,0),(13,'Central de Peças Automotivas','17271430008','83085570','Rua dos Jacarandás','Rio Pequeno','75','Andar 3','São José dos Pinhais','PR',-31190,-601748,00000000002,0);
/*!40000 ALTER TABLE `fornecedor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `frota`
--

LOCK TABLES `frota` WRITE;
/*!40000 ALTER TABLE `frota` DISABLE KEYS */;
INSERT INTO `frota` VALUES (00000000001,'Transporte Silva','89451492000145','88056395','Rua João Pereira','Cachoeira do Bom Jesus','100','Bloco A','Florianópolis','SC'),(00000000002,'Logística Souza','15297537000132','77826075','Rua 19','Loteamento Barros','50',NULL,'Araguaína','TO'),(00000000003,'Cargas Rápidas','09521665000115','03589070','Rua Mário Calazans Machado','Conjunto Habitacional Padre José de Anchieta','234','Sala 302','São Paulo','SP'),(00000000004,'Frota Nordeste','10194051000155','64606320','Quadra 03','Paraibinha','20',NULL,'Picos','PI'),(00000000005,'Expresso Boa Vista','61404878000187','69303400','Rua Sorocaima','São Vicente','120',NULL,'Boa Vista','RR'),(00000000006,'Transporte Maranhense','34544309000164','65080050','Travessa Bom Jesus','Sá Viana','99','Galpão 5','São Luís','MA'),(00000000007,'Frota do Sertão','86317091000109','69921410','Travessa Pêra','Montanhês','456',NULL,'Rio Branco','AC'),(00000000008,'Caminhões Paulista','87116975000168','02982016','Travessa Genaro Astarita','Jardim Sydney','101','Conjunto 12','São Paulo','SP'),(00000000009,'Carga Pesada Ltda','65942254000174','79093510','Rua Caramandel','Jardim São Conrado','15','Edifício Central','Campo Grande','MS'),(00000000010,'Frota Nacional','46938552000146','68909382','Avenida Gramado','Brasil Novo','33',NULL,'Macapá','AP'),(00000000011,'Frota Sergipana','55045902000136',NULL,NULL,NULL,NULL,NULL,NULL,'SE');
/*!40000 ALTER TABLE `frota` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `manutencao`
--

LOCK TABLES `manutencao` WRITE;
/*!40000 ALTER TABLE `manutencao` DISABLE KEYS */;
INSERT INTO `manutencao` VALUES (1,1,2,'2024-12-01 09:30:00',1,120.50,300.00,'P',NULL,'O',00000000001),(2,2,3,'2024-11-25 15:00:00',2,0.00,500.00,'C',NULL,'A',00000000002),(3,3,4,'2024-12-02 10:45:00',3,80.00,250.00,'P',NULL,'E',00000000003),(4,4,5,'2024-11-30 14:20:00',4,150.00,450.00,'C',NULL,'F',00000000004),(5,5,6,'2024-12-03 08:50:00',5,200.00,600.00,'P',NULL,'O',00000000005),(6,6,7,'2024-11-29 13:10:00',7,0.00,300.00,'C',NULL,'A',00000000006),(7,7,8,'2024-12-05 11:15:00',10,75.00,200.00,'P',NULL,'E',00000000007),(8,8,9,'2024-12-04 09:00:00',18,120.00,320.00,'C',NULL,'F',00000000008),(9,9,10,'2024-11-27 12:30:00',1,0.00,150.00,'P',NULL,'O',00000000009),(10,10,11,'2024-11-26 16:20:00',2,90.00,380.00,'C',NULL,'A',00000000010),(11,11,1,'2024-12-06 14:40:00',3,60.00,180.00,'P',NULL,'E',00000000011),(12,12,2,'2024-11-28 10:00:00',4,140.00,400.00,'C',NULL,'F',00000000001),(13,1,3,'2024-11-30 11:30:00',5,80.00,250.00,'P',NULL,'O',00000000002),(14,2,4,'2024-12-01 15:50:00',7,0.00,500.00,'C',NULL,'A',00000000003),(15,3,5,'2024-12-02 09:20:00',10,100.00,300.00,'P',NULL,'E',00000000004);
/*!40000 ALTER TABLE `manutencao` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `manutencaopecainsumo`
--

LOCK TABLES `manutencaopecainsumo` WRITE;
/*!40000 ALTER TABLE `manutencaopecainsumo` DISABLE KEYS */;
INSERT INTO `manutencaopecainsumo` VALUES (1,1,1,2,12,5000,150.00,300.00),(2,5,3,1,24,10000,80.00,80.00),(3,2,2,3,36,15000,120.00,360.00),(4,7,5,1,18,8000,200.00,200.00),(5,9,6,2,12,6000,250.00,500.00),(6,3,4,1,12,4500,180.00,180.00),(7,12,1,4,24,12000,50.00,200.00),(8,6,8,2,36,25000,110.00,220.00),(9,4,7,1,18,10000,95.00,95.00),(10,8,9,3,12,7000,135.00,405.00),(11,11,10,1,24,15000,160.00,160.00),(12,10,11,2,30,20000,190.00,380.00);
/*!40000 ALTER TABLE `manutencaopecainsumo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `marcapecainsumo`
--

LOCK TABLES `marcapecainsumo` WRITE;
/*!40000 ALTER TABLE `marcapecainsumo` DISABLE KEYS */;
INSERT INTO `marcapecainsumo` VALUES (1,'Bosch',00000000001),(2,'Wabco',00000000001),(3,'Exide',00000000002),(4,'Michelin',00000000003),(5,'Valeo',00000000004),(6,'Monroe',00000000005),(7,'SABÓ',00000000006),(8,'NGK ',00000000007),(9,'Mann Filter',00000000008),(10,'Philips',00000000009),(11,'Denso',00000000010),(12,'Gates',00000000011);
/*!40000 ALTER TABLE `marcapecainsumo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `marcaveiculo`
--

LOCK TABLES `marcaveiculo` WRITE;
/*!40000 ALTER TABLE `marcaveiculo` DISABLE KEYS */;
INSERT INTO `marcaveiculo` VALUES (1,'Fiat',00000000001),(2,'Chevrolet',00000000002),(3,'Volkswagen',00000000003),(4,'Ford',00000000004),(5,'Peugeot',00000000005),(6,'Toyota',00000000006),(7,'Honda',00000000007),(8,'Renault',00000000008),(9,'BMW',00000000009),(10,'Audi',00000000010),(11,'Hyundai',00000000011),(12,'Kia',00000000001),(13,'Nissan',00000000002),(14,'Mitsubishi',00000000003),(15,'Mazda',00000000004);
/*!40000 ALTER TABLE `marcaveiculo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `modeloveiculo`
--

LOCK TABLES `modeloveiculo` WRITE;
/*!40000 ALTER TABLE `modeloveiculo` DISABLE KEYS */;
INSERT INTO `modeloveiculo` VALUES (1,1,'Gol',55,00000000001),(2,2,'Uno Mille',50,00000000002),(3,3,'Civic LX',60,00000000003),(4,4,'Corolla GLI',55,00000000004),(5,5,'Onix LT',50,00000000005),(6,6,'Ka SE',51,00000000006),(7,7,'Hilux SRV',80,00000000007),(8,8,'Ranger XLT',80,00000000008),(9,9,'Duster 4x4',50,00000000009),(10,10,'Sandero Stepway',50,00000000010),(11,11,'Fiat Toro',60,00000000011),(12,12,'Strada Volcano',50,00000000001);
/*!40000 ALTER TABLE `modeloveiculo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `papelpessoa`
--

LOCK TABLES `papelpessoa` WRITE;
/*!40000 ALTER TABLE `papelpessoa` DISABLE KEYS */;
INSERT INTO `papelpessoa` VALUES (1,'Administrador'),(2,'Mecânico'),(3,'Gestor'),(4,'Motorista');
/*!40000 ALTER TABLE `papelpessoa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pecainsumo`
--

LOCK TABLES `pecainsumo` WRITE;
/*!40000 ALTER TABLE `pecainsumo` DISABLE KEYS */;
INSERT INTO `pecainsumo` VALUES (1,'Filtro de Ar',12,5000,00000000001),(2,'Pastilhas de Freio',18,8000,00000000002),(3,'Bateria',24,10000,00000000003),(4,'Amortecedor',18,15000,00000000004),(5,'Pneus',24,40000,00000000005),(6,'Correia Dentada',24,25000,00000000006),(7,'Óleo de Motor',6,5000,00000000007),(8,'Filtros de Combustível',12,10000,00000000008),(9,'Lâmpadas',12,10000,00000000009),(10,'Tampa do Radiador',12,12000,00000000010),(11,'Velas de Ignição',12,15000,00000000011),(12,'Bomba de Combustível',24,30000,00000000001),(13,'Radiador',24,30000,00000000002),(14,'Cabo de Acelerador',18,20000,00000000003),(15,'Jogo de Válvulas',36,100000,00000000004),(16,'Disco de Freio',18,15000,00000000005),(17,'Eixo Cardan',36,80000,00000000006),(18,'Sistema de Arrefecimento',24,50000,00000000007),(19,'Sistema de Injeção Eletrônica',36,60000,00000000008),(20,'Tanque de Combustível',24,40000,00000000009),(21,'Motor de Arranque',24,30000,00000000010),(22,'Alternador',24,35000,00000000011),(23,'Suspensão Traseira',18,20000,00000000001),(24,'Suspensão Dianteira',18,20000,00000000002),(25,'Filtro de Óleo',12,7000,00000000003),(26,'Carburador',18,15000,00000000004),(27,'Caixa de Câmbio',36,100000,00000000005),(28,'Tuchos Hidráulicos',24,30000,00000000006),(29,'Bomba de Óleo',18,25000,00000000007),(30,'Bico Injetor',24,30000,00000000008),(31,'Suspensão Pneumática',36,80000,00000000009),(32,'Capô',12,10000,00000000010),(33,'Carenagem do Motor',24,30000,00000000011);
/*!40000 ALTER TABLE `pecainsumo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `percurso`
--

LOCK TABLES `percurso` WRITE;
/*!40000 ALTER TABLE `percurso` DISABLE KEYS */;
INSERT INTO `percurso` VALUES (1,1,1,'2024-12-01 08:00:00','2024-12-01 12:00:00','Aracaju',-10.9472,-37.0731,'São Cristóvão',-11.0083,-37.2043,12000,12050,'Entrega de materiais'),(2,2,2,'2024-12-02 09:30:00','2024-12-02 13:45:00','Itabaiana',-10.6827,-37.4259,'Lagarto',-10.9178,-37.6513,15000,15080,'Reunião administrativa'),(3,3,3,'2024-12-03 07:45:00','2024-12-03 11:20:00','Estância',-11.2696,-37.4383,'Aracaju',-10.9472,-37.0731,10200,10260,'Visita técnica'),(4,4,4,'2024-12-04 10:00:00','2024-12-04 15:30:00','Lagarto',-10.9178,-37.6513,'Nossa Senhora da Glória',-10.215,-37.4214,18000,18090,'Entrega de equipamentos'),(5,5,5,'2024-12-05 14:15:00','2024-12-05 18:00:00','Aracaju',-10.9472,-37.0731,'Itabaiana',-10.6827,-37.4259,21000,21045,'Coleta de materiais'),(6,6,7,'2024-12-06 08:30:00','2024-12-06 12:15:00','Nossa Senhora do Socorro',-10.8467,-37.1233,'São Cristóvão',-11.0083,-37.2043,30000,30050,'Inspeção de obras'),(7,7,10,'2024-12-07 09:00:00','2024-12-07 13:00:00','Propriá',-10.2128,-36.844,'Aracaju',-10.9472,-37.0731,5000,5050,'Treinamento de equipe'),(8,8,18,'2024-12-08 10:00:00','2024-12-08 14:30:00','Itabaiana',-10.6827,-37.4259,'Lagarto',-10.9178,-37.6513,14500,14570,'Entrega de documentos'),(9,9,1,'2024-12-09 07:00:00','2024-12-09 12:30:00','Aracaju',-10.9472,-37.0731,'Estância',-11.2696,-37.4383,25000,25090,'Transporte de funcionários'),(10,10,2,'2024-12-10 11:00:00','2024-12-10 16:15:00','Lagarto',-10.9178,-37.6513,'São Cristóvão',-11.0083,-37.2043,17500,17580,'Reunião externa'),(11,11,3,'2024-12-11 08:15:00','2024-12-11 12:45:00','Aracaju',-10.9472,-37.0731,'Itabaiana',-10.6827,-37.4259,31000,31060,'Entrega de contratos'),(12,12,4,'2024-12-12 14:00:00','2024-12-12 18:00:00','São Cristóvão',-11.0083,-37.2043,'Lagarto',-10.9178,-37.6513,19000,19050,'Supervisão de serviços'),(13,1,5,'2024-12-13 09:00:00','2024-12-13 12:00:00','Estância',-11.2696,-37.4383,'Aracaju',-10.9472,-37.0731,12300,12370,'Entrega de encomendas'),(14,2,7,'2024-12-14 08:30:00','2024-12-14 13:15:00','Lagarto',-10.9178,-37.6513,'Nossa Senhora da Glória',-10.215,-37.4214,20500,20590,'Visita institucional'),(15,3,10,'2024-12-15 10:15:00','2024-12-15 14:00:00','Aracaju',-10.9472,-37.0731,'São Cristóvão',-11.0083,-37.2043,1000,1050,'Entrega de amostras'),(16,4,18,'2024-12-16 09:00:00','2024-12-16 12:30:00','Nossa Senhora do Socorro',-10.8467,-37.1233,'Itabaiana',-10.6827,-37.4259,24000,24070,'Inspeção técnica'),(17,5,1,'2024-12-17 14:30:00','2024-12-17 18:00:00','São Cristóvão',-11.0083,-37.2043,'Lagarto',-10.9178,-37.6513,23000,23090,'Visita de campo'),(18,6,2,'2024-12-18 07:45:00','2024-12-18 11:30:00','Aracaju',-10.9472,-37.0731,'Estância',-11.2696,-37.4383,35000,35080,'Entrega de relatórios'),(19,7,3,'2024-12-19 10:00:00','2024-12-19 14:15:00','Lagarto',-10.9178,-37.6513,'São Cristóvão',-11.0083,-37.2043,12000,12060,'Consulta externa'),(20,8,4,'2024-12-20 08:00:00','2024-12-20 13:00:00','Estância',-11.2696,-37.4383,'Aracaju',-10.9472,-37.0731,17800,17890,'Supervisão de equipe'),(21,9,5,'2024-12-21 09:30:00','2024-12-21 12:45:00','Nossa Senhora da Glória',-10.215,-37.4214,'Lagarto',-10.9178,-37.6513,15000,15070,'Entrega de correspondências'),(22,10,7,'2024-12-22 11:15:00','2024-12-22 15:30:00','Propriá',-10.2128,-36.844,'Aracaju',-10.9472,-37.0731,5000,5070,'Inspeção de rotina'),(23,11,10,'2024-12-23 10:00:00','2024-12-23 14:30:00','Aracaju',-10.9472,-37.0731,'Itabaiana',-10.6827,-37.4259,12300,12380,'Reunião técnica'),(24,12,18,'2024-12-24 08:15:00','2024-12-24 12:45:00','Estância',-11.2696,-37.4383,'São Cristóvão',-11.0083,-37.2043,16700,16790,'Entrega de equipamentos'),(25,1,1,'2024-12-25 09:00:00','2024-12-25 12:30:00','Lagarto',-10.9178,-37.6513,'Nossa Senhora da Glória',-10.215,-37.4214,20000,20070,'Supervisão geral'),(26,2,2,'2024-12-26 10:30:00','2024-12-26 15:00:00','Aracaju',-10.9472,-37.0731,'Lagarto',-10.9178,-37.6513,31000,31080,'Entrega de amostras');
/*!40000 ALTER TABLE `percurso` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pessoa`
--

LOCK TABLES `pessoa` WRITE;
/*!40000 ALTER TABLE `pessoa` DISABLE KEYS */;
INSERT INTO `pessoa` VALUES (1,'24182240073','João Silva','69911818','Rua Beira Rio','Ayrton Sena','Apto 101','100','Rio Branco','AC',00000000010,4,1),(2,'49750862040','Maria Oliveira','53435550','Rua Honorato Fernandes da Paz','Janga','Bloco B','50','Paulista','PE',00000000004,4,1),(3,'95013745055','Carlos Souza','65056160','Rua Primeiro de Novembro','São Bernardo','Sala 203','234','São Luís','MA',00000000008,4,1),(4,'96368649003','Ana Pereira','49025580','Rua Petrônio Carvalho','Grageru',NULL,'20','Aracaju','SE',00000000002,4,1),(5,'35863448059','José Almeida','72852625','Quadra Quadra 25','Jardim Umuarama Setor 1','Casa 12','120','Luziânia','GO',00000000003,4,1),(6,'82845946090','Fernanda Costa','40353633','Primeira Travessa Retirolândia','Fazenda Grande do Retiro',NULL,'99','Salvador','BA',00000000001,2,1),(7,'89551017080','Pedro Santos','29121010','Rua Moacir Nunes','Garoto',NULL,'456','Vila Velha','ES',00000000004,4,1),(8,'47714464070','Beatriz Lima','78746124','84032455','Rua Elizabeth das Graças Maurer Rota','Cará-cará','101','Ponta Grossa','PR',00000000011,2,1),(9,'23307820044','Ricardo Mendes','29105651','Rua Ana Dulce','Cocal','Edifício Central','15','Vila Velha','ES',00000000004,1,1),(10,'25767836000','Camila Barbosa','68907290','Rua Centurião','Renascer',NULL,'33','Macapá','AP',00000000007,4,1),(11,'01385405007','Juliana Freitas','64029310','Rua Francisco Ubaldo Nogueira','Santo Antônio',NULL,'250','Teresina','PI',00000000004,4,0),(12,'02502684005','Renato Braga','76908152','Rua Cariacica','São Francisco','Cobertura','89','Ji-Paraná','RO',00000000004,2,0),(13,'27871214039','Patrícia Ramos','78552415','Rua das Avencas','Jardim das Oliveiras',NULL,'88','Sinop','MT',00000000002,4,0),(14,'24947857072','Leonardo Monteiro','79032270','Rua Avoante','Carandá Bosque',NULL,'150','Campo Grande','MS',00000000001,4,0),(15,'81572274026','Roberta Farias','79085062','Rua Ermandina Otamo da Rosa','Conjunto Aero Rancho','Sala 502','85','Campo Grande','MS',00000000001,4,0),(16,'99738417007','Guilherme Lima Santos','49500972','Rua Francisco Santos','Centro',NULL,'85','Itabaiana','SE',00000000001,1,1),(17,'44476798098','Kauã Oliveira','49500970','Avenida Ivo de Carvalho','Centro',NULL,'336','Itabaiana','SE',00000000001,1,1),(18,'38534499055','Marcos Dósea','49055490','Rua Rejane Maria Pureza do Rosário','Getúlio Vargas',NULL,'100','Aracaju','SE',00000000001,1,1),(19,'58534953058','Ricardo Oliveira','89806172','Rua Jardim Europa - E',NULL,NULL,'54','Chapecó','SC',00000000001,2,1),(20,'58928940028','Carla Dias','49037090',NULL,NULL,NULL,'54','Aracaju','SE',00000000001,3,1),(21,'78860691028','Igor Andrade','76873250',NULL,NULL,NULL,'4','Ariquemes','RO',00000000001,4,1);
/*!40000 ALTER TABLE `pessoa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `solicitacaomanutencao`
--

LOCK TABLES `solicitacaomanutencao` WRITE;
/*!40000 ALTER TABLE `solicitacaomanutencao` DISABLE KEYS */;
INSERT INTO `solicitacaomanutencao` VALUES (1,1,1,'2024-12-01 08:30:00','Ruído no motor ao ligar.',00000000001),(2,2,2,'2024-11-25 14:20:00','Luz do painel acendendo sem motivo.',00000000002),(3,3,3,'2024-12-05 09:00:00','Problemas na direção hidráulica.',00000000003),(4,4,4,'2024-11-28 11:15:00','Vazamento de óleo no motor.',00000000004),(5,5,5,'2024-12-02 16:45:00','Barulho nos freios ao desacelerar.',00000000005),(6,6,7,'2024-11-30 10:50:00','Pneus desgastados, solicitar troca.',00000000006),(7,7,10,'2024-11-27 15:35:00','Problema no sistema elétrico.',00000000007),(8,8,18,'2024-12-04 08:00:00','Ar condicionado parou de funcionar.',00000000008),(9,9,1,'2024-11-29 13:10:00','Cinto de segurança do motorista travado.',00000000009),(10,10,2,'2024-12-03 14:45:00','Vidro elétrico do lado esquerdo não sobe.',00000000010),(11,11,3,'2024-11-26 09:20:00','Farol dianteiro queimado.',00000000011),(12,12,4,'2024-12-06 17:30:00','Suspensão traseira está rangendo.',00000000001),(13,1,5,'2024-11-24 12:10:00','Filtro de óleo precisa de troca.',00000000002),(14,2,7,'2024-11-28 10:40:00','Bateria descarregando rapidamente.',00000000003),(15,3,10,'2024-12-02 08:15:00','Alinhamento da roda está fora.',00000000004),(16,4,18,'2024-11-30 11:50:00','Sistema de escapamento com vazamento.',00000000005),(17,5,1,'2024-12-01 14:30:00','Porta traseira com dificuldade de abrir.',00000000006),(18,6,2,'2024-11-29 09:40:00','Radiador superaquecendo.',00000000007),(19,7,3,'2024-12-05 16:00:00','Problemas na bomba de combustível.',00000000008),(20,8,4,'2024-12-03 11:20:00','Embreagem dura, difícil de engatar.',00000000009);
/*!40000 ALTER TABLE `solicitacaomanutencao` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `unidadeadministrativa`
--

LOCK TABLES `unidadeadministrativa` WRITE;
/*!40000 ALTER TABLE `unidadeadministrativa` DISABLE KEYS */;
INSERT INTO `unidadeadministrativa` VALUES (1,'Administração Central','83085570','Rua dos Jacarandás','Rio Pequeno','Edifício Central','100','São José dos Pinhais','PR',-23.5505,-46.6333,00000000001),(2,'Unidade Regional Sul','77024682','Quadra 1304 Sul Rua 18','Plano Diretor Sul','Sala 202','650','Palmas','TO',-30.0736,-51.2353,00000000002),(3,'Unidade Norte','40254060',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,00000000003),(4,'Unidade Leste','68904279',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,00000000004),(5,'Unidade Nordeste','79022133',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,00000000005),(6,'Unidade Centro-Oeste','62040140',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,00000000006),(7,'Unidade Sudeste','60325615',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,00000000007),(8,'Unidade Sul II','79065502',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,00000000008),(9,'Unidade Norte II','59604230',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,00000000009),(10,'Unidade Oeste','77006148',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,00000000010),(11,'Unidade Nordeste II','57071125','Rua Manoel Tenório Cavalcante','Clima Bom','Andar Térreo','250','Maceió','AL',-5.7945,-35.211,00000000011),(12,'Unidade Especial','88110651',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,00000000001);
/*!40000 ALTER TABLE `unidadeadministrativa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `veiculo`
--

LOCK TABLES `veiculo` WRITE;
/*!40000 ALTER TABLE `veiculo` DISABLE KEYS */;
INSERT INTO `veiculo` VALUES (1,'NBU7262','2EGYLPGVRA0NH6627','Preto',1,00000000001,1,15000,'D',2019,2020,'41629379456','2024-12-31 00:00:00',45000.00,'2024-01-01 00:00:00'),(2,'NAB2635','9HD64JXVGYP3W4813','Branco',2,00000000002,2,20000,'U',2020,2021,'84313163392','2025-11-30 00:00:00',55000.00,'2024-01-01 00:00:00'),(3,'JUE4250','99KUE2A9W3K6V2824','Azul',3,00000000003,3,10000,'M',2021,2022,'26732057390','2025-10-30 00:00:00',60000.00,'2024-01-01 00:00:00'),(4,'HVZ5943','1F8F2CUN0SBB05190','Vermelho',4,00000000004,4,25000,'I',2022,2023,'42345678904','2026-09-29 00:00:00',65000.00,'2024-01-01 00:00:00'),(5,'HZG6326','2GK5VC59CWSEJ3132','Cinza',5,00000000005,5,12000,'D',2018,2019,'52345678905','2024-08-15 00:00:00',40000.00,'2024-01-01 00:00:00'),(6,'JYP5635','2SK9SDKAJ2VWJ9495','Prata',6,00000000006,6,18000,'U',2021,2020,'62345678906','2024-07-14 00:00:00',50000.00,'2024-01-01 00:00:00'),(7,'STU9V01','2CFXRKP4PS5CF4132','Verde',7,00000000007,7,22000,'M',2022,2023,'72345678907','2025-06-13 00:00:00',62000.00,'2024-01-01 00:00:00'),(8,'NAQ3068','4VG8DEKSMFFTB1281','Amarelo',8,00000000008,8,8000,'I',2020,2021,'82345678908','2026-05-12 00:00:00',48000.00,'2024-01-01 00:00:00'),(9,'MRZ1249','4MDYWRX8CL3DV5838','Marrom',9,00000000009,9,30000,'D',2019,2020,'92345678909','2025-04-11 00:00:00',53000.00,'2024-01-01 00:00:00'),(10,'MVV9709','4MLPDYHVX83AD1450','Preto',10,00000000010,10,5000,'U',2021,2020,'81110095169','2024-03-10 00:00:00',47000.00,'2024-01-01 00:00:00'),(11,'LSH7535','4HZF3FYEKDUHB8224','Branco',11,00000000011,11,7500,'M',2022,2023,'12345678911','2026-02-09 00:00:00',49000.00,'2024-01-01 00:00:00'),(12,'HQW5933','1WMESTCZGXXJ78818','Cinza',12,00000000001,12,9000,'I',2020,2021,'22345678912','2025-01-08 00:00:00',51000.00,'2024-01-01 00:00:00');
/*!40000 ALTER TABLE `veiculo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `veiculopecainsumo`
--

LOCK TABLES `veiculopecainsumo` WRITE;
/*!40000 ALTER TABLE `veiculopecainsumo` DISABLE KEYS */;
INSERT INTO `veiculopecainsumo` VALUES (1,1,'2025-01-15 00:00:00',30000,'2025-06-15 00:00:00',35000),(1,10,'2024-10-05 00:00:00',15000,'2025-03-05 00:00:00',20000),(2,5,'2024-12-31 00:00:00',20000,'2025-05-01 00:00:00',25000),(2,14,'2025-03-15 00:00:00',45000,'2025-09-15 00:00:00',50000),(3,8,'2025-02-10 00:00:00',40000,'2025-08-10 00:00:00',45000),(3,19,'2024-12-01 00:00:00',20000,'2025-06-01 00:00:00',25000),(4,12,'2024-11-30 00:00:00',15000,'2025-04-15 00:00:00',20000),(5,15,'2025-03-20 00:00:00',50000,'2025-09-20 00:00:00',55000),(6,18,'2024-10-25 00:00:00',25000,'2025-03-25 00:00:00',30000),(7,22,'2025-01-01 00:00:00',35000,'2025-07-01 00:00:00',40000),(8,25,'2025-02-28 00:00:00',45000,'2025-08-30 00:00:00',50000),(9,30,'2024-12-15 00:00:00',10000,'2025-05-15 00:00:00',15000),(10,2,'2025-04-10 00:00:00',55000,'2025-10-10 00:00:00',60000),(11,4,'2024-09-20 00:00:00',30000,'2025-03-20 00:00:00',35000),(12,6,'2025-06-01 00:00:00',60000,'2025-12-01 00:00:00',65000);
/*!40000 ALTER TABLE `veiculopecainsumo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `vistoria`
--

LOCK TABLES `vistoria` WRITE;
/*!40000 ALTER TABLE `vistoria` DISABLE KEYS */;
INSERT INTO `vistoria` VALUES (1,'2022-02-15 08:30:00','Problema no motor','S',1),(2,'2022-05-20 09:15:00','Falha na suspensão','R',2),(3,'2022-08-10 10:00:00','Pneus desgastados','S',3),(4,'2022-11-12 11:45:00','Correia do alternador danificada','R',4),(5,'2023-01-18 12:30:00','Falta de óleo','S',5),(6,'2023-03-25 14:00:00','Desgaste nas pastilhas de freio','R',7),(7,'2023-06-09 15:00:00','Problema no ar-condicionado','S',9),(8,'2023-08-21 16:30:00','Sistema de iluminação com defeito','R',10),(9,'2023-09-04 17:00:00','Bateria com carga baixa','S',18),(10,'2023-10-16 18:00:00','Alinhamento dos eixos','R',1),(11,'2023-11-02 08:00:00','Problema no sistema de injeção','S',2),(12,'2023-12-05 09:45:00','Vazamento de combustível','R',3),(13,'2024-01-20 10:30:00','Amortecedores danificados','S',4),(14,'2024-03-12 11:15:00','Ruído no câmbio','R',5),(15,'2024-05-14 12:00:00','Freios sem resposta','S',7),(16,'2024-06-18 13:30:00','Desgaste nas palhetas do limpador','R',9),(17,'2024-08-22 14:00:00','Problema na direção hidráulica','S',10),(18,'2024-09-09 15:30:00','Quebra no vidro lateral','R',18),(19,'2024-10-10 16:00:00','Falha na ignição','S',1),(20,'2024-12-05 17:00:00','Bujões de vela corroídos','R',2);
/*!40000 ALTER TABLE `vistoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'frota'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-12-27 20:44:22
