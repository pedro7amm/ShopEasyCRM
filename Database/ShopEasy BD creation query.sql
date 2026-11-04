-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema ShopEasy_CRM
-- -----------------------------------------------------
-- Modelo CRM Ecommerce ShopEasy basado en requerimientos del laboratorio SOF-30.
-- DROP SCHEMA IF EXISTS `ShopEasy_CRM` ; -- Deshabilitado para evitar borrar datos existentes

-- -----------------------------------------------------
-- Schema ShopEasy_CRM
--
-- Modelo CRM Ecommerce ShopEasy basado en requerimientos del laboratorio SOF-30.
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `ShopEasy_CRM` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
USE `ShopEasy_CRM` ;

-- -----------------------------------------------------
-- Table `ShopEasy_CRM`.`Tipo_Usuario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ShopEasy_CRM`.`Tipo_Usuario` (
  `idTipo_Usuario` INT NOT NULL AUTO_INCREMENT,
  `Descripcion` VARCHAR(50) NOT NULL,
  `Activo` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`idTipo_Usuario`),
  UNIQUE INDEX `UQ_Tipo_Usuario_Descripcion` (`Descripcion` ASC) VISIBLE)
ENGINE = InnoDB
COMMENT = 'Rol de acceso: Administrador, Agente, Marketing o Cliente.';


-- -----------------------------------------------------
-- Table `ShopEasy_CRM`.`Persona`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ShopEasy_CRM`.`Persona` (
  `Cedula` VARCHAR(25) NOT NULL,
  `Nombre` VARCHAR(15) NOT NULL,
  `Apellido1` VARCHAR(15) NOT NULL,
  `Apellido2` VARCHAR(15) NOT NULL,
  `Fecha_Nacimiento` DATE NOT NULL,
  `Correo` VARCHAR(120) NOT NULL,
  `Telefono` INT NOT NULL,
  `Nombre_Usuario` VARCHAR(60) NOT NULL,
  `Password_Hash` VARCHAR(255) NOT NULL,
  `Activo` TINYINT NOT NULL DEFAULT 1,
  `Tipo_Usuario_idTipo_Usuario` INT NOT NULL,
  PRIMARY KEY (`Cedula`),
  UNIQUE INDEX `UQ_Persona_Cedula` (`Cedula` ASC) VISIBLE,
  UNIQUE INDEX `UQ_Persona_Correo` (`Correo` ASC) VISIBLE,
  UNIQUE INDEX `UQ_Persona_Nombre_Usuario` (`Nombre_Usuario` ASC) VISIBLE,
  INDEX `IX_Persona_Tipo_Usuario_idTipo_Usuario` (`Tipo_Usuario_idTipo_Usuario` ASC) VISIBLE,
  CONSTRAINT `fk_Persona_Tipo_Usuario_Tipo_Usuario_idTipo_Usuario`
    FOREIGN KEY (`Tipo_Usuario_idTipo_Usuario`)
    REFERENCES `ShopEasy_CRM`.`Tipo_Usuario` (`idTipo_Usuario`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
COMMENT = 'Persona y sus credenciales opcionales (solo hash). Sin tabla Usuario.';


-- -----------------------------------------------------
-- Table `ShopEasy_CRM`.`Cliente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ShopEasy_CRM`.`Cliente` (
  `idCliente` INT NOT NULL AUTO_INCREMENT,
  `FechaInicio` DATETIME NOT NULL,
  `Fecha_Alta` DATETIME NOT NULL,
  `Acepta_Marketing` TINYINT NOT NULL DEFAULT 0,
  `Persona_Cedula` VARCHAR(25) NOT NULL,
  PRIMARY KEY (`idCliente`),
  INDEX `fk_Cliente_Persona1_idx` (`Persona_Cedula` ASC) VISIBLE,
  CONSTRAINT `fk_Cliente_Persona1`
    FOREIGN KEY (`Persona_Cedula`)
    REFERENCES `ShopEasy_CRM`.`Persona` (`Cedula`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'Datos de CRM vinculados a una sola Persona; Persona_idPersona es FK INTEGER interna heredada como nombre.';


-- -----------------------------------------------------
-- Table `ShopEasy_CRM`.`Provincia`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ShopEasy_CRM`.`Provincia` (
  `idProvincia` INT NOT NULL AUTO_INCREMENT,
  `Descripcion_Provincia` VARCHAR(60) NOT NULL,
  `Activo` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`idProvincia`),
  UNIQUE INDEX `UQ_Provincia_Descripcion_Provincia` (`Descripcion_Provincia` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ShopEasy_CRM`.`Canton`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ShopEasy_CRM`.`Canton` (
  `idCanton` INT NOT NULL AUTO_INCREMENT,
  `Descripcion_Canton` VARCHAR(60) NOT NULL,
  `Activo` TINYINT NOT NULL DEFAULT 1,
  `Provincia_idProvincia` INT NOT NULL,
  PRIMARY KEY (`idCanton`),
  UNIQUE INDEX `UQ_Canton_Provincia_idProvincia_Descripcion_Canton` (`Provincia_idProvincia` ASC, `Descripcion_Canton` ASC) VISIBLE,
  CONSTRAINT `fk_Canton_Provincia_Provincia_idProvincia`
    FOREIGN KEY (`Provincia_idProvincia`)
    REFERENCES `ShopEasy_CRM`.`Provincia` (`idProvincia`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ShopEasy_CRM`.`Distrito`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ShopEasy_CRM`.`Distrito` (
  `idDistrito` INT NOT NULL AUTO_INCREMENT,
  `Descripcion_Distrito` VARCHAR(80) NOT NULL,
  `Codigo_Postal` INT NOT NULL,
  `Activo` TINYINT NOT NULL DEFAULT 1,
  `Canton_idCanton` INT NOT NULL,
  PRIMARY KEY (`idDistrito`),
  UNIQUE INDEX `UQ_Distrito_Canton_idCanton_Descripcion_Distrito` (`Canton_idCanton` ASC, `Descripcion_Distrito` ASC) VISIBLE,
  CONSTRAINT `fk_Distrito_Canton_Canton_idCanton`
    FOREIGN KEY (`Canton_idCanton`)
    REFERENCES `ShopEasy_CRM`.`Canton` (`idCanton`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ShopEasy_CRM`.`Direccion`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ShopEasy_CRM`.`Direccion` (
  `idDireccion` INT NOT NULL AUTO_INCREMENT,
  `Otras_Senas` VARCHAR(500) NOT NULL,
  `Es_Principal` TINYINT NOT NULL DEFAULT 0,
  `Activo` TINYINT NOT NULL DEFAULT 1,
  `Distrito_idDistrito` INT NOT NULL,
  `Persona_Cedula` VARCHAR(25) NOT NULL,
  PRIMARY KEY (`idDireccion`),
  INDEX `IX_Direccion_Distrito_idDistrito` (`Distrito_idDistrito` ASC) VISIBLE,
  INDEX `fk_Direccion_Persona1_idx` (`Persona_Cedula` ASC) VISIBLE,
  CONSTRAINT `fk_Direccion_Distrito_Distrito_idDistrito`
    FOREIGN KEY (`Distrito_idDistrito`)
    REFERENCES `ShopEasy_CRM`.`Distrito` (`idDistrito`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Direccion_Persona1`
    FOREIGN KEY (`Persona_Cedula`)
    REFERENCES `ShopEasy_CRM`.`Persona` (`Cedula`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'La provincia y el canton se consultan a traves de Distrito.';


-- -----------------------------------------------------
-- Table `ShopEasy_CRM`.`Categoria_Producto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ShopEasy_CRM`.`Categoria_Producto` (
  `idCategoria_Producto` INT NOT NULL AUTO_INCREMENT,
  `Nombre` VARCHAR(90) NOT NULL,
  `Activo` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`idCategoria_Producto`),
  UNIQUE INDEX `UQ_Categoria_Producto_Nombre` (`Nombre` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ShopEasy_CRM`.`Bodega`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ShopEasy_CRM`.`Bodega` (
  `idBodega` INT NOT NULL AUTO_INCREMENT,
  `Descripcion_Bodega` VARCHAR(100) NOT NULL,
  `Activo` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`idBodega`),
  UNIQUE INDEX `UQ_Bodega_Descripcion_Bodega` (`Descripcion_Bodega` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ShopEasy_CRM`.`Producto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ShopEasy_CRM`.`Producto` (
  `numSerieProducto` INT NOT NULL AUTO_INCREMENT,
  `Nombre` VARCHAR(120) NOT NULL,
  `Descripcion` VARCHAR(300) NOT NULL,
  `Precio` DECIMAL(12,2) NOT NULL,
  `Cantidad_Disponible` INT NOT NULL DEFAULT 0,
  `Activo` TINYINT NOT NULL DEFAULT 1,
  `Categoria_Producto_idCategoria_Producto` INT NOT NULL,
  `Bodega_idBodega` INT NOT NULL,
  PRIMARY KEY (`numSerieProducto`),
  INDEX `IX_Producto_Categoria_Producto_idCategoria_Producto` (`Categoria_Producto_idCategoria_Producto` ASC) VISIBLE,
  INDEX `IX_Producto_Bodega_idBodega` (`Bodega_idBodega` ASC) VISIBLE,
  CONSTRAINT `fk_Producto_Categoria_Producto_Categoria_Producto_idCategoria_`
    FOREIGN KEY (`Categoria_Producto_idCategoria_Producto`)
    REFERENCES `ShopEasy_CRM`.`Categoria_Producto` (`idCategoria_Producto`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Producto_Bodega_Bodega_idBodega`
    FOREIGN KEY (`Bodega_idBodega`)
    REFERENCES `ShopEasy_CRM`.`Bodega` (`idBodega`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
COMMENT = 'Stock total del producto en una sola bodega; modelo deliberadamente basico.';


-- -----------------------------------------------------
-- Table `ShopEasy_CRM`.`Estado_Orden`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ShopEasy_CRM`.`Estado_Orden` (
  `idEstado_Orden` INT NOT NULL AUTO_INCREMENT,
  `Descripcion_Estado_Orden` VARCHAR(55) NOT NULL,
  `Activo` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`idEstado_Orden`),
  UNIQUE INDEX `UQ_Estado_Orden_Descripcion_Estado_Orden` (`Descripcion_Estado_Orden` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ShopEasy_CRM`.`Orden`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ShopEasy_CRM`.`Orden` (
  `idOrden` INT NOT NULL AUTO_INCREMENT,
  `Fecha_Orden` DATETIME NOT NULL,
  `Codigo_Referencia` VARCHAR(60) NOT NULL,
  `Total` DECIMAL(12,2) NOT NULL,
  `Observaciones` VARCHAR(300) NOT NULL,
  `Cliente_idCliente` INT NOT NULL,
  `Estado_Orden_idEstado_Orden` INT NOT NULL,
  `Direccion_idDireccion` INT NOT NULL,
  PRIMARY KEY (`idOrden`),
  UNIQUE INDEX `UQ_Orden_Codigo_Referencia` (`Codigo_Referencia` ASC) VISIBLE,
  INDEX `IX_Orden_Cliente_idCliente` (`Cliente_idCliente` ASC) VISIBLE,
  INDEX `IX_Orden_Estado_Orden_idEstado_Orden` (`Estado_Orden_idEstado_Orden` ASC) VISIBLE,
  INDEX `IX_Orden_Direccion_idDireccion` (`Direccion_idDireccion` ASC) VISIBLE,
  CONSTRAINT `fk_Orden_Cliente_Cliente_idCliente`
    FOREIGN KEY (`Cliente_idCliente`)
    REFERENCES `ShopEasy_CRM`.`Cliente` (`idCliente`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Orden_Estado_Orden_Estado_Orden_idEstado_Orden`
    FOREIGN KEY (`Estado_Orden_idEstado_Orden`)
    REFERENCES `ShopEasy_CRM`.`Estado_Orden` (`idEstado_Orden`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Orden_Direccion_Direccion_idDireccion`
    FOREIGN KEY (`Direccion_idDireccion`)
    REFERENCES `ShopEasy_CRM`.`Direccion` (`idDireccion`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
COMMENT = 'El codigo de referencia unico ayuda a detectar pedidos repetidos.';


-- -----------------------------------------------------
-- Table `ShopEasy_CRM`.`Orden_Producto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ShopEasy_CRM`.`Orden_Producto` (
  `idOrden_Producto` INT NOT NULL AUTO_INCREMENT,
  `Cantidad` INT NOT NULL,
  `Precio_Unitario` DECIMAL(12,2) NOT NULL,
  `Orden_idOrden` INT NOT NULL,
  `Producto_numSerieProducto` INT NOT NULL,
  PRIMARY KEY (`idOrden_Producto`),
  UNIQUE INDEX `UQ_Orden_Producto_Orden_idOrden_Producto_idProducto` (`Orden_idOrden` ASC, `Producto_numSerieProducto` ASC) VISIBLE,
  INDEX `IX_Orden_Producto_Producto_idProducto` (`Producto_numSerieProducto` ASC) VISIBLE,
  CONSTRAINT `fk_Orden_Producto_Orden_Orden_idOrden`
    FOREIGN KEY (`Orden_idOrden`)
    REFERENCES `ShopEasy_CRM`.`Orden` (`idOrden`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Orden_Producto_Producto_Producto_idProducto`
    FOREIGN KEY (`Producto_numSerieProducto`)
    REFERENCES `ShopEasy_CRM`.`Producto` (`numSerieProducto`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
COMMENT = 'Tabla puente N:M. Precio historico al momento de la venta.';


-- -----------------------------------------------------
-- Table `ShopEasy_CRM`.`Metodo_Pago`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ShopEasy_CRM`.`Metodo_Pago` (
  `idMetodo_Pago` INT NOT NULL AUTO_INCREMENT,
  `Descripcion_Metodo_Pago` VARCHAR(55) NOT NULL,
  `Activo` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`idMetodo_Pago`),
  UNIQUE INDEX `UQ_Metodo_Pago_Descripcion_Metodo_Pago` (`Descripcion_Metodo_Pago` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ShopEasy_CRM`.`Factura`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ShopEasy_CRM`.`Factura` (
  `idFactura` INT NOT NULL AUTO_INCREMENT,
  `Numero_Factura` VARCHAR(60) NOT NULL,
  `Fecha` DATETIME NOT NULL,
  `Total` DECIMAL(12,2) NOT NULL,
  `Anulada` TINYINT NOT NULL DEFAULT 0,
  `Orden_idOrden` INT NOT NULL,
  `Metodo_Pago_idMetodo_Pago` INT NOT NULL,
  PRIMARY KEY (`idFactura`),
  UNIQUE INDEX `UQ_Factura_Numero_Factura` (`Numero_Factura` ASC) VISIBLE,
  UNIQUE INDEX `IX_Factura_Orden_idOrden` (`Orden_idOrden` ASC) VISIBLE,
  INDEX `IX_Factura_Metodo_Pago_idMetodo_Pago` (`Metodo_Pago_idMetodo_Pago` ASC) VISIBLE,
  CONSTRAINT `fk_Factura_Orden_Orden_idOrden`
    FOREIGN KEY (`Orden_idOrden`)
    REFERENCES `ShopEasy_CRM`.`Orden` (`idOrden`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Factura_Metodo_Pago_Metodo_Pago_idMetodo_Pago`
    FOREIGN KEY (`Metodo_Pago_idMetodo_Pago`)
    REFERENCES `ShopEasy_CRM`.`Metodo_Pago` (`idMetodo_Pago`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
COMMENT = 'Factura asociada a una sola orden; no duplicar detalle de productos.';


-- -----------------------------------------------------
-- Table `ShopEasy_CRM`.`Catalogo_EstadosSoporte`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ShopEasy_CRM`.`Catalogo_EstadosSoporte` (
  `idCatalogo_EstadosSoporte` INT NOT NULL,
  `descripcionEstado` VARCHAR(45) NOT NULL,
  `Activo` TINYINT NOT NULL,
  PRIMARY KEY (`idCatalogo_EstadosSoporte`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ShopEasy_CRM`.`Caso_Soporte`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ShopEasy_CRM`.`Caso_Soporte` (
  `idCaso_Soporte` INT NOT NULL AUTO_INCREMENT,
  `Tipo` VARCHAR(30) NOT NULL,
  `Asunto` VARCHAR(120) NOT NULL,
  `Descripcion` VARCHAR(500) NOT NULL,
  `Fecha_Creacion` DATETIME NOT NULL,
  `Cliente_idCliente` INT NOT NULL,
  `Orden_idOrden` INT NULL,
  `Persona_Cedula` VARCHAR(25) NOT NULL,
  `Catalogo_EstadosSoporte_idCatalogo_EstadosSoporte` INT NOT NULL,
  PRIMARY KEY (`idCaso_Soporte`),
  INDEX `IX_Caso_Soporte_Cliente_idCliente` (`Cliente_idCliente` ASC) VISIBLE,
  INDEX `IX_Caso_Soporte_Orden_idOrden` (`Orden_idOrden` ASC) VISIBLE,
  INDEX `fk_Caso_Soporte_Persona1_idx` (`Persona_Cedula` ASC) VISIBLE,
  INDEX `fk_Caso_Soporte_Catalogo_EstadosSoporte1_idx` (`Catalogo_EstadosSoporte_idCatalogo_EstadosSoporte` ASC) VISIBLE,
  CONSTRAINT `fk_Caso_Soporte_Cliente_Cliente_idCliente`
    FOREIGN KEY (`Cliente_idCliente`)
    REFERENCES `ShopEasy_CRM`.`Cliente` (`idCliente`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Caso_Soporte_Orden_Orden_idOrden`
    FOREIGN KEY (`Orden_idOrden`)
    REFERENCES `ShopEasy_CRM`.`Orden` (`idOrden`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Caso_Soporte_Persona1`
    FOREIGN KEY (`Persona_Cedula`)
    REFERENCES `ShopEasy_CRM`.`Persona` (`Cedula`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Caso_Soporte_Catalogo_EstadosSoporte1`
    FOREIGN KEY (`Catalogo_EstadosSoporte_idCatalogo_EstadosSoporte`)
    REFERENCES `ShopEasy_CRM`.`Catalogo_EstadosSoporte` (`idCatalogo_EstadosSoporte`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'Quejas y solicitudes con estado y responsable.';


-- -----------------------------------------------------
-- Table `ShopEasy_CRM`.`Seguimiento_Caso`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ShopEasy_CRM`.`Seguimiento_Caso` (
  `idSeguimiento_Caso` INT NOT NULL AUTO_INCREMENT,
  `Fecha` DATETIME NOT NULL,
  `Comentario` VARCHAR(500) NOT NULL,
  `Caso_Soporte_idCaso_Soporte` INT NOT NULL,
  `Cliente_idCliente` INT NOT NULL,
  PRIMARY KEY (`idSeguimiento_Caso`),
  INDEX `IX_Seguimiento_Caso_Caso_Soporte_idCaso_Soporte` (`Caso_Soporte_idCaso_Soporte` ASC) VISIBLE,
  INDEX `fk_Seguimiento_Caso_Cliente1_idx` (`Cliente_idCliente` ASC) VISIBLE,
  CONSTRAINT `fk_Seguimiento_Caso_Caso_Soporte_Caso_Soporte_idCaso_Soporte`
    FOREIGN KEY (`Caso_Soporte_idCaso_Soporte`)
    REFERENCES `ShopEasy_CRM`.`Caso_Soporte` (`idCaso_Soporte`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Seguimiento_Caso_Cliente1`
    FOREIGN KEY (`Cliente_idCliente`)
    REFERENCES `ShopEasy_CRM`.`Cliente` (`idCliente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'Historial del seguimiento a una queja o solicitud.';


-- -----------------------------------------------------
-- Table `ShopEasy_CRM`.`Preferencia_Cliente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ShopEasy_CRM`.`Preferencia_Cliente` (
  `idPreferencia_Cliente` INT NOT NULL AUTO_INCREMENT,
  `Cliente_idCliente` INT NOT NULL,
  `Categoria_Producto_idCategoria_Producto` INT NOT NULL,
  PRIMARY KEY (`idPreferencia_Cliente`),
  UNIQUE INDEX `UQ_Preferencia_Cliente_Cliente_idCliente_Categoria_Producto_idCa` (`Cliente_idCliente` ASC, `Categoria_Producto_idCategoria_Producto` ASC) VISIBLE,
  INDEX `IX_Preferencia_Cliente_Categoria_Producto_idCategoria_Producto` (`Categoria_Producto_idCategoria_Producto` ASC) VISIBLE,
  CONSTRAINT `fk_Preferencia_Cliente_Cliente_Cliente_idCliente`
    FOREIGN KEY (`Cliente_idCliente`)
    REFERENCES `ShopEasy_CRM`.`Cliente` (`idCliente`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Preferencia_Cliente_Categoria_Producto_Categoria_Producto_i`
    FOREIGN KEY (`Categoria_Producto_idCategoria_Producto`)
    REFERENCES `ShopEasy_CRM`.`Categoria_Producto` (`idCategoria_Producto`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
COMMENT = 'Preferencia N:M de clientes por categorias de producto.';


-- -----------------------------------------------------
-- Table `ShopEasy_CRM`.`Catalogo_EstadoCampana`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ShopEasy_CRM`.`Catalogo_EstadoCampana` (
  `idCatalogo_EstadoCampana` INT NOT NULL,
  `descripcionEstado` VARCHAR(45) NOT NULL,
  `Activo` TINYINT NOT NULL,
  PRIMARY KEY (`idCatalogo_EstadoCampana`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ShopEasy_CRM`.`Campana`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ShopEasy_CRM`.`Campana` (
  `idCampana` INT NOT NULL AUTO_INCREMENT,
  `Nombre` VARCHAR(120) NOT NULL,
  `Descripcion` VARCHAR(400) NOT NULL,
  `Fecha_Programada` DATETIME NOT NULL,
  `Catalogo_EstadoCampana_idCatalogo_EstadoCampana` INT NOT NULL,
  PRIMARY KEY (`idCampana`),
  INDEX `fk_Campana_Catalogo_EstadoCampana1_idx` (`Catalogo_EstadoCampana_idCatalogo_EstadoCampana` ASC) VISIBLE,
  CONSTRAINT `fk_Campana_Catalogo_EstadoCampana1`
    FOREIGN KEY (`Catalogo_EstadoCampana_idCatalogo_EstadoCampana`)
    REFERENCES `ShopEasy_CRM`.`Catalogo_EstadoCampana` (`idCatalogo_EstadoCampana`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'La app se encarga de ejecutar la campana en la fecha programada.';


-- -----------------------------------------------------
-- Table `ShopEasy_CRM`.`Catalogo_EstadoEnvioCampanaCliente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ShopEasy_CRM`.`Catalogo_EstadoEnvioCampanaCliente` (
  `idCatalogo_EstadoEnvioCampanaCliente` INT NOT NULL,
  `descripcionEstado` VARCHAR(45) NOT NULL,
  `Activo` TINYINT NOT NULL,
  PRIMARY KEY (`idCatalogo_EstadoEnvioCampanaCliente`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ShopEasy_CRM`.`Campana_Cliente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ShopEasy_CRM`.`Campana_Cliente` (
  `idCampana_Cliente` INT NOT NULL AUTO_INCREMENT,
  `Fecha_Envio` DATETIME NOT NULL,
  `Campana_idCampana` INT NOT NULL,
  `Cliente_idCliente` INT NOT NULL,
  `Catalogo_EstadoEnvioCampanaCliente` INT NOT NULL,
  PRIMARY KEY (`idCampana_Cliente`),
  UNIQUE INDEX `UQ_Campana_Cliente_Campana_idCampana_Cliente_idCliente` (`Campana_idCampana` ASC, `Cliente_idCliente` ASC) VISIBLE,
  INDEX `IX_Campana_Cliente_Cliente_idCliente` (`Cliente_idCliente` ASC) VISIBLE,
  INDEX `fk_Campana_Cliente_Catalogo_EstadoCampanaCliente1_idx` (`Catalogo_EstadoEnvioCampanaCliente` ASC) VISIBLE,
  CONSTRAINT `fk_Campana_Cliente_Campana_Campana_idCampana`
    FOREIGN KEY (`Campana_idCampana`)
    REFERENCES `ShopEasy_CRM`.`Campana` (`idCampana`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Campana_Cliente_Cliente_Cliente_idCliente`
    FOREIGN KEY (`Cliente_idCliente`)
    REFERENCES `ShopEasy_CRM`.`Cliente` (`idCliente`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Campana_Cliente_Catalogo_EstadoCampanaCliente1`
    FOREIGN KEY (`Catalogo_EstadoEnvioCampanaCliente`)
    REFERENCES `ShopEasy_CRM`.`Catalogo_EstadoEnvioCampanaCliente` (`idCatalogo_EstadoEnvioCampanaCliente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'Destinatarios de la campana; respetar consentimiento de Cliente.';


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
