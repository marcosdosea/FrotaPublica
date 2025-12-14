-- Script de criação da tabela rota
-- Esta tabela armazena as rotas obtidas do Google Maps Directions API para cada percurso

CREATE TABLE IF NOT EXISTS `rota` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `idPercurso` INT(11) UNSIGNED NOT NULL,
  `routeJson` LONGTEXT NOT NULL COMMENT 'JSON completo da resposta da API do Google Maps Directions',
  `dataCriacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_rota_percurso1_idx` (`idPercurso` ASC) VISIBLE,
  CONSTRAINT `fk_rota_percurso1`
    FOREIGN KEY (`idPercurso`)
    REFERENCES `percurso` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

