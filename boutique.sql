-- ==========================================================
-- PROYECTO: Kinsui Sushi
-- DESCRIPCIÓN: Script de creación de base de datos (11 entidades)
-- ARCHIVO: bdkinsuisushi.sql
-- ==========================================================

-- Crear la base de datos si no existe
CREATE DATABASE IF NOT EXISTS bdkinsuisushi;
USE bdkinsuisushi;

-- 1. TABLA: Categoria
CREATE TABLE Categoria (
    id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- 2. TABLA: Producto
CREATE TABLE Producto (
    id_producto INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    disponible BOOLEAN DEFAULT TRUE,
    id_categoria INT,
    CONSTRAINT fk_producto_categoria FOREIGN KEY (id_categoria) 
        REFERENCES Categoria(id_categoria) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 3. TABLA: Cliente
CREATE TABLE Cliente (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion TEXT,
    puntos_fidelidad INT DEFAULT 0,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 4. TABLA: Empleado
CREATE TABLE Empleado (
    id_empleado INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    rol ENUM('Chef', 'Mesero', 'Cajero', 'Repartidor', 'Gerente') NOT NULL,
    telefono VARCHAR(20),
    activo BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

-- 5. TABLA: Proveedor
CREATE TABLE Proveedor (
    id_proveedor INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    contacto VARCHAR(100),
    telefono VARCHAR(20)
) ENGINE=InnoDB;

-- 6. TABLA: Pedido (Cabecera)
CREATE TABLE Pedido (
    id_pedido INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT,
    id_empleado INT,
    fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    tipo ENUM('Local', 'Delivery', 'Takeout') NOT NULL,
    estado ENUM('Pendiente', 'En Preparación', 'Enviado', 'Entregado', 'Cancelado') DEFAULT 'Pendiente',
    total DECIMAL(10,2) DEFAULT 0.00,
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    CONSTRAINT fk_pedido_empleado FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado)
) ENGINE=InnoDB;

-- 7. TABLA: Detalle_Pedido (Cuerpo)
CREATE TABLE Detalle_Pedido (
    id_detalle INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT,
    id_producto INT,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) AS (cantidad * precio_unitario),
    CONSTRAINT fk_detalle_pedido FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido) ON DELETE CASCADE,
    CONSTRAINT fk_detalle_producto FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
) ENGINE=InnoDB;

-- 8. TABLA: Pago
CREATE TABLE Pago (
    id_pago INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT,
    metodo ENUM('Efectivo', 'Tarjeta', 'Transferencia') NOT NULL,
    monto_pagado DECIMAL(10,2) NOT NULL,
    fecha_pago DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pago_pedido FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido)
) ENGINE=InnoDB;

-- 9. TABLA: Entrega (Seguimiento para Delivery)
CREATE TABLE Entrega (
    id_entrega INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT,
    id_empleado INT, -- Repartidor
    hora_salida DATETIME,
    hora_entrega DATETIME,
    estado_entrega VARCHAR(50),
    CONSTRAINT fk_entrega_pedido FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido),
    CONSTRAINT fk_entrega_repartidor FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado)
) ENGINE=InnoDB;

-- 10. TABLA: Compra (Abastecimiento de Insumos)
CREATE TABLE Compra (
    id_compra INT PRIMARY KEY AUTO_INCREMENT,
    id_proveedor INT,
    id_empleado INT,
    fecha_compra DATE NOT NULL,
    total_compra DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_compra_proveedor FOREIGN KEY (id_proveedor) REFERENCES Proveedor(id_proveedor),
    CONSTRAINT fk_compra_empleado FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado)
) ENGINE=InnoDB;

-- 11. TABLA: Detalle_Compra
CREATE TABLE Detalle_Compra (
    id_detalle_compra INT PRIMARY KEY AUTO_INCREMENT,
    id_compra INT,
    descripcion_insumo VARCHAR(100) NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) AS (cantidad * precio_unitario),
    CONSTRAINT fk_detalle_compra FOREIGN KEY (id_compra) REFERENCES Compra(id_compra) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Índices básicos para optimizar búsquedas frecuentes
CREATE INDEX idx_pedido_fecha ON Pedido(fecha_hora);
CREATE INDEX idx_producto_categoria ON Producto(id_categoria);
CREATE INDEX idx_cliente_nombre ON Cliente(nombre);
