USE master;
GO

DROP DATABASE MARKET_EXPRESS;
GO

CREATE DATABASE MARKET_EXPRESS;
GO

USE MARKET_EXPRESS;
GO

CREATE TABLE Usuario(
	Id UNIQUEIDENTIFIER DEFAULT newsequentialid(),
	Nombre VARCHAR(40) NOT NULL,
	Cedula VARCHAR(12) UNIQUE NOT NULL,
	Email VARCHAR(40) UNIQUE NOT NULL,
	Telefono VARCHAR(40) NOT NULL,
	Clave VARCHAR(80) NOT NULL,
	Tipo VARCHAR(15) NOT NULL,
	Estado VARCHAR(11) NOT NULL,
	FecCreacion DATETIME NOT NULL,
	AdicionadoPor VARCHAR(12),
	ModificadoPor VARCHAR(12)

	PRIMARY KEY(Id),
	CONSTRAINT CHK_Usuario_Tipo CHECK (Tipo = 'ADMINISTRADOR' OR Tipo = 'CLIENTE'),
	CONSTRAINT CHK_Usuario_Estado CHECK (Estado = 'ACTIVADO' OR Estado = 'DESACTIVADO')
);
GO

CREATE TABLE Permiso(		-- Permisos para crear Roles que ser�n asignados a un usuario
	Id UNIQUEIDENTIFIER DEFAULT newsequentialid(),
	Nombre VARCHAR(30) NOT NULL,
	Descripcion VARCHAR(200),

	PRIMARY KEY(Id)
);
GO

CREATE TABLE Rol(	-- Roles los cuales definiran los permisos de cada usuario
	Id UNIQUEIDENTIFIER DEFAULT newsequentialid(),
	Nombre VARCHAR(30) NOT NULL,
	Descripcion VARCHAR(200),
	FecCreacion DATETIME NOT NULL,

	PRIMARY KEY(Id)	
);
GO

CREATE TABLE Rol_Permiso( -- Para almacenar los permisos que tendra un Rol
	Id UNIQUEIDENTIFIER DEFAULT newsequentialid(),
	IdRol UNIQUEIDENTIFIER NOT NULL,
	IdPermiso UNIQUEIDENTIFIER NOT NULL,

	PRIMARY KEY(Id),
	FOREIGN KEY(IdRol) REFERENCES Rol(Id),
	FOREIGN KEY(IdPermiso) REFERENCES Permiso(Id)
);
GO

CREATE TABLE Usuario_Rol( --Para almacenar los roles asignados a cada usuario
	Id UNIQUEIDENTIFIER DEFAULT newsequentialid(),
	IdRol UNIQUEIDENTIFIER NOT NULL,
	IdUsuario UNIQUEIDENTIFIER NOT NULL,

	PRIMARY KEY(Id),
	FOREIGN KEY(IdUsuario) REFERENCES Usuario(Id),
	FOREIGN KEY(IdRol) REFERENCES Rol(Id)
);
GO

CREATE TABLE Cliente(
	Id UNIQUEIDENTIFIER DEFAULT newsequentialid(),
	IdUsuario UNIQUEIDENTIFIER UNIQUE NOT NULL,
	CodCliente VARCHAR(10), -- Codigo para los clientes registrados en el POS
	Auto_Sinc BIT NOT NULL,

	PRIMARY KEY(Id),
	FOREIGN KEY(IdUsuario) REFERENCES Usuario(Id)
);
GO

CREATE TABLE Direccion(
	Id UNIQUEIDENTIFIER DEFAULT newsequentialid(),
	IdCliente UNIQUEIDENTIFIER NOT NULL,
	Nombre VARCHAR(10) NOT NULL,
	Detalle VARCHAR(255) NOT NULL,

	PRIMARY KEY(Id)
);
GO

CREATE TABLE Bitacora_Acceso(
	Id UNIQUEIDENTIFIER DEFAULT newsequentialid(),
	IdUsuario UNIQUEIDENTIFIER NOT NULL,
	FecInicio DATETIME NOT NULL,
	FecSalida DATETIME,

	PRIMARY KEY(Id),
	FOREIGN KEY(IdUsuario) REFERENCES Usuario(Id)
);
GO

CREATE TABLE Bitacora_Movimiento(
	Id UNIQUEIDENTIFIER DEFAULT newsequentialid(),
	IdUsuario UNIQUEIDENTIFIER NOT NULL,
	FecRealiza DATETIME NOT NULL,
	Tipo VARCHAR(10) NOT NULL,
	Detalle Varchar(100) NOT NULL,

	PRIMARY KEY(Id),
	FOREIGN KEY(IdUsuario) REFERENCES Usuario(Id)
);
GO

CREATE TABLE Inventario_Categoria(
	Id UNIQUEIDENTIFIER DEFAULT newsequentialid(),
	Nombre VARCHAR(20) NOT NULL,
	Descripcion VARCHAR(200),
	Estado VARCHAR(11) NOT NULL,
	FecCreacion DATETIME NOT NULL,
	AdicionadoPor VARCHAR(12),
	ModificadoPor VARCHAR(12)

	PRIMARY KEY(Id),
	CONSTRAINT CHK_Categoria_Estado CHECK (Estado = 'ACTIVADO' OR Estado = 'DESACTIVADO')
);
GO

CREATE TABLE Inventario_Articulo(
	Id UNIQUEIDENTIFIER DEFAULT newsequentialid(),
	Id_Categoria UNIQUEIDENTIFIER,
	Descripcion VARCHAR(255) NOT NULL,
	CodigoBarras VARCHAR(255) UNIQUE NOT NULL,
	Precio DECIMAL(19,2) NOT NULL,
	Imagen VARCHAR(30),
	Auto_Sinc BIT NOT NULL,
	Estado VARCHAR(11) NOT NULL,
	FecCreacion DATETIME NOT NULL,
	AdicionadoPor VARCHAR(12),
	ModificadoPor VARCHAR(12)

	PRIMARY KEY(Id),
	CONSTRAINT CHK_Articulo_Estado CHECK (Estado = 'ACTIVADO' OR Estado = 'DESACTIVADO')
);
GO

CREATE TABLE Carrito(
	Id UNIQUEIDENTIFIER DEFAULT newsequentialid(),
	IdCliente UNIQUEIDENTIFIER NOT NULL,
	FecApertura DATETIME NOT NULL,
	Estado VARCHAR(7) NOT NULL,

	PRIMARY KEY(Id),
	FOREIGN KEY(IdCliente) REFERENCES Cliente(Id),
	CONSTRAINT CHK_Carrito_Estado CHECK (Estado = 'ABIERTO' OR Estado = 'CERRADO')
);
GO

CREATE TABLE Carrito_Detalle(
	Id UNIQUEIDENTIFIER DEFAULT newsequentialid(),
	IdCarrito UNIQUEIDENTIFIER NOT NULL,
	IdArticulo UNIQUEIDENTIFIER NOT NULL

	PRIMARY KEY(Id),
	FOREIGN KEY(IdCarrito) REFERENCES Carrito(Id),
	FOREIGN KEY(IdArticulo) REFERENCES Inventario_Articulo(Id)
);
GO

CREATE TABLE Pedido(
	Id UNIQUEIDENTIFIER DEFAULT newsequentialid(),
	IdCliente UNIQUEIDENTIFIER NOT NULL,
	FecCreacion DATETIME NOT NULL,
	Total DECIMAL(19,2) NOT NULL,
	Estado VARCHAR(9) NOT NULL,

	PRIMARY KEY(Id),
	CONSTRAINT CHK_Pedido_Estado CHECK (Estado = 'PENDIENTE' OR Estado = 'TERMINADO' OR Estado = 'CANCELADO')
);

CREATE TABLE Pedido_Detalle(
	Id UNIQUEIDENTIFIER DEFAULT newsequentialid(),
	Id_Pedido UNIQUEIDENTIFIER NOT NULL,
	IdArticulo UNIQUEIDENTIFIER NOT NULL, -- Se agrega para realizar el promedio de art. m�s solicitados
	Descripcion VARCHAR(255) NOT NULL,
	CodigoBarras VARCHAR(255) NOT NULL,
	Precio DECIMAL(19,2) NOT NULL,

	PRIMARY KEY(Id),
	FOREIGN KEY(Id_Pedido) REFERENCES Pedido(Id),
	FOREIGN KEY(IdArticulo) REFERENCES Inventario_Articulo(Id)
);

INSERT INTO Permiso(Id,Nombre) VALUES
('03B93003-B8F0-4315-A0C0-449E5058F23A','Permiso 1'),
('1AAF51B4-B054-4487-9FC5-26B96886E737','Permiso 2'),
('C236C5C0-004C-4B1C-A3E7-0E427E9F9593','Permiso 3'),
('0C13E8A6-3A0A-419E-9D18-778D8DFC87D6','Permiso 4'),
('9E66A172-D4C0-4FFB-B2F8-59471A826C17','Permiso 5');
GO

INSERT INTO Rol(Id,Nombre,FecCreacion) VALUES
('EC81F591-CA24-4A80-8D54-316897E9015C','Todos los permisos',GETDATE()),
('DF22A0FF-6FD5-4422-977D-49B99D3D71C2','Permiso 1 y 2',GETDATE()),
('C4934D01-205D-4888-827C-8787AB6B3CEE','Permiso 4 y 5',GETDATE());
GO

INSERT INTO Rol_Permiso(IdRol,IdPermiso) VALUES
('EC81F591-CA24-4A80-8D54-316897E9015C','03B93003-B8F0-4315-A0C0-449E5058F23A'), --Todos los permisos
('EC81F591-CA24-4A80-8D54-316897E9015C','1AAF51B4-B054-4487-9FC5-26B96886E737'), --Todos los permisos
('EC81F591-CA24-4A80-8D54-316897E9015C','C236C5C0-004C-4B1C-A3E7-0E427E9F9593'), --Todos los permisos
('EC81F591-CA24-4A80-8D54-316897E9015C','0C13E8A6-3A0A-419E-9D18-778D8DFC87D6'), --Todos los permisos
('EC81F591-CA24-4A80-8D54-316897E9015C','9E66A172-D4C0-4FFB-B2F8-59471A826C17'), --Todos los permisos
('DF22A0FF-6FD5-4422-977D-49B99D3D71C2','03B93003-B8F0-4315-A0C0-449E5058F23A'), --Permiso 1 y 2
('DF22A0FF-6FD5-4422-977D-49B99D3D71C2','1AAF51B4-B054-4487-9FC5-26B96886E737'), --Permiso 1 y 2
('C4934D01-205D-4888-827C-8787AB6B3CEE','0C13E8A6-3A0A-419E-9D18-778D8DFC87D6'), --Permiso 4 y 5
('C4934D01-205D-4888-827C-8787AB6B3CEE','9E66A172-D4C0-4FFB-B2F8-59471A826C17'); --Permiso 4 y 5
GO

INSERT INTO Usuario(Id,Nombre,Cedula,Email,Telefono,Clave,Tipo,Estado,FecCreacion,AdicionadoPor) VALUES
('EA16E721-5E1D-EC11-9953-3863BBBB3AE0','Luis Diego Solís Camacho','1-1731-0010','1diego321@gmail.com','83358092','10000.+UfMddrk8Z1k7UZBQDNPvA==.705k1c4kJPT9uYc77Fkjw2/VAl257UUmJkSj0jGY/Zo=','ADMINISTRADOR','ACTIVADO',GETDATE(),'SYSTEM');
GO

INSERT INTO Usuario_Rol(IdRol,IdUsuario) VALUES
('EC81F591-CA24-4A80-8D54-316897E9015C','EA16E721-5E1D-EC11-9953-3863BBBB3AE0') --Todos los permisos
--('DF22A0FF-6FD5-4422-977D-49B99D3D71C2','EA16E721-5E1D-EC11-9953-3863BBBB3AE0'), --Permiso 1 y 2
--('C4934D01-205D-4888-827C-8787AB6B3CEE','EA16E721-5E1D-EC11-9953-3863BBBB3AE0') --Permiso 4 y 5
GO

INSERT INTO Cliente(IdUsuario,Auto_Sinc) VALUES
('EA16E721-5E1D-EC11-9953-3863BBBB3AE0',0);  
GO


/*

SELECT * FROM Usuario;
SELECT * FROM Usuario_Rol;
SELECT * FROM Rol;
SELECT * FROM Rol_Permiso;
SELECT * FROM Permiso;



SELECT DISTINCT 
	   u.Nombre AS Nombre_Usuario,
	   u.Tipo AS Tipo_Usuario,
	   p.Nombre AS Nombre_Permiso
FROM Usuario u, Usuario_Rol ur, Rol r, Rol_Permiso rp, Permiso p
WHERE u.Id = ur.IdUsuario
AND ur.IdRol = r.Id
AND ur.IdRol = rp.IdRol
AND p.Id = rp.IdPermiso

*/


CREATE PROCEDURE Sp_Usuario_GetPermisos
(
	@Id UNIQUEIDENTIFIER
)
AS
	BEGIN
	SELECT DISTINCT 
		   p.Id,
		   p.Descripcion,
		   p.Nombre
	FROM Usuario u, Usuario_Rol ur, Rol r, Rol_Permiso rp, Permiso p
	WHERE ur.IdUsuario = @Id
	AND ur.IdRol = r.Id
	AND ur.IdRol = rp.IdRol
	AND p.Id = rp.IdPermiso
END;







