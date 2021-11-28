USE master;
GO

DROP DATABASE IF EXISTS MARKET_EXPRESS;
GO

CREATE DATABASE MARKET_EXPRESS;
GO

USE [MARKET_EXPRESS]
GO
/****** Object:  Table [dbo].[Address]    Script Date: 23/10/2021 16:36:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Address](
	[Id] [uniqueidentifier] NOT NULL,
	[ClientId] [uniqueidentifier] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Detail] [varchar](255) NOT NULL,
	[InUse] [bit] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AppUser]    Script Date: 23/10/2021 16:36:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppUser](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Alias] [varchar](10) NULL,
	[Identification] [varchar](12) NOT NULL,
	[Email] [varchar](100) NOT NULL,
	[Phone] [varchar](40) NOT NULL,
	[Password] [varchar](80) NOT NULL,
	[Type] [varchar](15) NOT NULL,
	[Status] [varchar](11) NOT NULL,
	[CreationDate] [datetime] NOT NULL,
	[ModificationDate] [datetime] NULL,
	[AddedBy] [varchar](40) NOT NULL,
	[ModifiedBy] [varchar](40) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Identification] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AppUser_Role]    Script Date: 23/10/2021 16:36:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppUser_Role](
	[Id] [uniqueidentifier] NOT NULL,
	[RoleId] [uniqueidentifier] NOT NULL,
	[AppUserId] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Article]    Script Date: 23/10/2021 16:36:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Article](
	[Id] [uniqueidentifier] NOT NULL,
	[CategoryId] [uniqueidentifier] NULL,
	[Description] [varchar](255) NOT NULL,
	[BarCode] [varchar](255) NOT NULL,
	[Price] [decimal](19, 2) NOT NULL,
	[Image] [varchar](50) NULL,
	[AutoSync] [bit] NOT NULL,
	[AutoSyncDescription] [bit] NOT NULL,
	[Status] [varchar](11) NOT NULL,
	[CreationDate] [datetime] NOT NULL,
	[ModificationDate] [datetime] NULL,
	[AddedBy] [varchar](40) NOT NULL,
	[ModifiedBy] [varchar](40) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Binnacle_Access]    Script Date: 23/10/2021 16:36:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Binnacle_Access](
	[Id] [uniqueidentifier] NOT NULL,
	[AppUserId] [uniqueidentifier] NOT NULL,
	[EntryDate] [datetime] NOT NULL,
	[ExitDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Binnacle_Movement]    Script Date: 23/10/2021 16:36:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Binnacle_Movement](
	[Id] [uniqueidentifier] NOT NULL,
	[PerformedBy] [varchar](40) NOT NULL,
	[MovementDate] [datetime] NOT NULL,
	[Type] [varchar](10) NOT NULL,
	[Detail] [varchar](600) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Cart]    Script Date: 23/10/2021 16:36:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cart](
	[Id] [uniqueidentifier] NOT NULL,
	[ClientId] [uniqueidentifier] NOT NULL,
	[OpeningDate] [datetime] NOT NULL,
	[Status] [varchar](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Cart_Detail]    Script Date: 23/10/2021 16:36:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cart_Detail](
	[Id] [uniqueidentifier] NOT NULL,
	[CartId] [uniqueidentifier] NOT NULL,
	[ArticleId] [uniqueidentifier] NOT NULL,
	[Quantity] [decimal](19, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Category]    Script Date: 23/10/2021 16:36:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Category](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Description] [varchar](255) NULL,
	[Status] [varchar](11) NOT NULL,
	[Image] [varchar](50) NULL,
	[CreationDate] [datetime] NOT NULL,
	[ModificationDate] [datetime] NULL,
	[AddedBy] [varchar](40) NOT NULL,
	[ModifiedBy] [varchar](40) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Client]    Script Date: 23/10/2021 16:36:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Client](
	[Id] [uniqueidentifier] NOT NULL,
	[AppUserId] [uniqueidentifier] NOT NULL,
	[ClientCode] [varchar](10) NULL,
	[AutoSync] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[AppUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Order_Detail]    Script Date: 23/10/2021 16:36:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Order_Detail](
	[Id] [uniqueidentifier] NOT NULL,
	[OrderId] [uniqueidentifier] NOT NULL,
	[ArticleId] [uniqueidentifier] NOT NULL,
	[Description] [varchar](255) NOT NULL,
	[BarCode] [varchar](255) NOT NULL,
	[Price] [decimal](19, 2) NOT NULL,
	[Quantity] [decimal](19, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Permission]    Script Date: 23/10/2021 16:36:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Permission](
	[Id] [uniqueidentifier] NOT NULL,
	[PermissionCode] [varchar](20) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Description] [varchar](255) NULL,
	[Type] [varchar](10) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PermissionCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Role]    Script Date: 23/10/2021 16:36:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Role](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [varchar](30) NOT NULL,
	[Description] [varchar](255) NULL,
	[Status] [varchar](11) NOT NULL,
	[CreationDate] [datetime] NOT NULL,
	[ModificationDate] [datetime] NULL,
	[AddedBy] [varchar](40) NOT NULL,
	[ModifiedBy] [varchar](40) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Role_Permission]    Script Date: 23/10/2021 16:36:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Role_Permission](
	[Id] [uniqueidentifier] NOT NULL,
	[RoleId] [uniqueidentifier] NOT NULL,
	[PermissionId] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Slider]    Script Date: 23/10/2021 16:36:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Slider](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Image] [varchar](50) NOT NULL,
	[Status] [varchar](11) NOT NULL,
	[CreationDate] [datetime] NOT NULL,
	[ModificationDate] [datetime] NULL,
	[AddedBy] [varchar](40) NOT NULL,
	[ModifiedBy] [varchar](40) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Order]    Script Date: 23/10/2021 16:36:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Order](
	[Id] [uniqueidentifier] NOT NULL,
	[ClientId] [uniqueidentifier] NOT NULL,
	[CreationDate] [datetime] NOT NULL,
	[Total] [decimal](19, 2) NOT NULL,
	[OrderNumber] [int] IDENTITY(1,1) NOT NULL,
	[ShippingAddress] [varchar](255) NOT NULL,
	[Status] [varchar](9) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Address] ADD  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [dbo].[AppUser] ADD  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [dbo].[AppUser_Role] ADD  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [dbo].[Article] ADD  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [dbo].[Binnacle_Access] ADD  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [dbo].[Binnacle_Movement] ADD  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [dbo].[Cart] ADD  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [dbo].[Cart_Detail] ADD  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [dbo].[Category] ADD  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [dbo].[Client] ADD  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [dbo].[Order_Detail] ADD  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [dbo].[Permission] ADD  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [dbo].[Role] ADD  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [dbo].[Role_Permission] ADD  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [dbo].[Slider] ADD  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [dbo].[Order] ADD  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [dbo].[Address]  WITH CHECK ADD FOREIGN KEY([ClientId])
REFERENCES [dbo].[Client] ([Id])
GO
ALTER TABLE [dbo].[AppUser_Role]  WITH CHECK ADD FOREIGN KEY([AppUserId])
REFERENCES [dbo].[AppUser] ([Id])
GO
ALTER TABLE [dbo].[AppUser_Role]  WITH CHECK ADD FOREIGN KEY([RoleId])
REFERENCES [dbo].[Role] ([Id])
GO
ALTER TABLE [dbo].[Article]  WITH CHECK ADD FOREIGN KEY([CategoryId])
REFERENCES [dbo].[Category] ([Id])
GO
ALTER TABLE [dbo].[Binnacle_Access]  WITH CHECK ADD FOREIGN KEY([AppUserId])
REFERENCES [dbo].[AppUser] ([Id])
GO
ALTER TABLE [dbo].[Cart]  WITH CHECK ADD FOREIGN KEY([ClientId])
REFERENCES [dbo].[Client] ([Id])
GO
ALTER TABLE [dbo].[Cart_Detail]  WITH CHECK ADD FOREIGN KEY([ArticleId])
REFERENCES [dbo].[Article] ([Id])
GO
ALTER TABLE [dbo].[Cart_Detail]  WITH CHECK ADD FOREIGN KEY([CartId])
REFERENCES [dbo].[Cart] ([Id])
GO
ALTER TABLE [dbo].[Client]  WITH CHECK ADD FOREIGN KEY([AppUserId])
REFERENCES [dbo].[AppUser] ([Id])
GO
ALTER TABLE [dbo].[Order_Detail]  WITH CHECK ADD FOREIGN KEY([ArticleId])
REFERENCES [dbo].[Article] ([Id])
GO
ALTER TABLE [dbo].[Order_Detail]  WITH CHECK ADD FOREIGN KEY([OrderId])
REFERENCES [dbo].[Order] ([Id])
GO
ALTER TABLE [dbo].[Role_Permission]  WITH CHECK ADD FOREIGN KEY([PermissionId])
REFERENCES [dbo].[Permission] ([Id])
GO
ALTER TABLE [dbo].[Role_Permission]  WITH CHECK ADD FOREIGN KEY([RoleId])
REFERENCES [dbo].[Role] ([Id])
GO
ALTER TABLE [dbo].[Order]  WITH CHECK ADD FOREIGN KEY([ClientId])
REFERENCES [dbo].[Client] ([Id])
GO
ALTER TABLE [dbo].[AppUser]  WITH CHECK ADD  CONSTRAINT [CHK_AppUser_Status] CHECK  (([Status]='ACTIVADO' OR [Status]='DESACTIVADO'))
GO
ALTER TABLE [dbo].[AppUser] CHECK CONSTRAINT [CHK_AppUser_Status]
GO
ALTER TABLE [dbo].[AppUser]  WITH CHECK ADD  CONSTRAINT [CHK_AppUser_Type] CHECK  (([Type]='ADMINISTRADOR' OR [Type]='CLIENTE'))
GO
ALTER TABLE [dbo].[AppUser] CHECK CONSTRAINT [CHK_AppUser_Type]
GO
ALTER TABLE [dbo].[Article]  WITH CHECK ADD  CONSTRAINT [CHK_Article_Status] CHECK  (([Status]='ACTIVADO' OR [Status]='DESACTIVADO'))
GO
ALTER TABLE [dbo].[Article] CHECK CONSTRAINT [CHK_Article_Status]
GO
ALTER TABLE [dbo].[Cart]  WITH CHECK ADD  CONSTRAINT [CHK_Cart_Status] CHECK  (([Status]='ABIERTO' OR [Status]='CERRADO'))
GO
ALTER TABLE [dbo].[Cart] CHECK CONSTRAINT [CHK_Cart_Status]
GO
ALTER TABLE [dbo].[Category]  WITH CHECK ADD  CONSTRAINT [CHK_Category_Status] CHECK  (([Status]='ACTIVADO' OR [Status]='DESACTIVADO'))
GO
ALTER TABLE [dbo].[Category] CHECK CONSTRAINT [CHK_Category_Status]
GO
ALTER TABLE [dbo].[Permission]  WITH CHECK ADD  CONSTRAINT [CHK_Permission_Type] CHECK  (([Type]='ARTICULOS' OR [Type]='BITACORAS' OR [Type]='CATEGORIAS' OR [Type]='REPORTES' OR [Type]='SLIDERS' OR [Type]='USUARIOS' OR [Type]='ROLES' OR [Type]='PEDIDOS'))
GO
ALTER TABLE [dbo].[Permission] CHECK CONSTRAINT [CHK_Permission_Type]
GO
ALTER TABLE [dbo].[Slider]  WITH CHECK ADD  CONSTRAINT [CHK_Slider_Status] CHECK  (([Status]='ACTIVADO' OR [Status]='DESACTIVADO'))
GO
ALTER TABLE [dbo].[Slider] CHECK CONSTRAINT [CHK_Slider_Status]
GO
ALTER TABLE [dbo].[Role]  WITH CHECK ADD  CONSTRAINT [CHK_Role_Status] CHECK  (([Status]='ACTIVADO' OR [Status]='DESACTIVADO'))
GO
ALTER TABLE [dbo].[Role] CHECK CONSTRAINT [CHK_Role_Status]
GO
ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [CHK_Order_Status] CHECK  (([Status]='PENDIENTE' OR [Status]='TERMINADO' OR [Status]='CANCELADO'))
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [CHK_Order_Status]
GO

INSERT INTO Permission(Id,PermissionCode,Type,Name,Description) VALUES
('03B93003-B8F0-4315-A0C0-449E5058F23A','ART_MAN_GEN','ARTICULOS','MANTENIMIENTO GENERAL','PERMITE REALIZAR TODAS LAS OPERACIONES DE MANTENIMIENTO SOBRE LOS ARTICULOS.'),
('1AAF51B4-B054-4487-9FC5-26B96886E737','CAT_MAN_GEN','CATEGORIAS','MANTENIMIENTO GENERAL','PERMITE REALIZAR TODAS LAS OPERACIONES DE MANTENIMIENTO SOBRE LAS CATEGORIAS.'),
('C236C5C0-004C-4B1C-A3E7-0E427E9F9593','SLI_MAN_GEN','SLIDERS','MANTENIMIENTO GENERAL','PERMITE REALIZAR TODAS LAS OPERACIONES DE MANTENIMIENTO SOBRE LOS SLIDERS.'),
('0C13E8A6-3A0A-419E-9D18-778D8DFC87D6','USE_MAN_GEN','USUARIOS','MANTENIMIENTO GENERAL','PERMITE REALIZAR TODAS LAS OPERACIONES DE MANTENIMIENTO SOBRE LOS USUARIOS.'),
('9E66A172-D4C0-4FFB-B2F8-59471A826C17','ROL_MAN_GEN','ROLES','MANTENIMIENTO GENERAL','PERMITE REALIZAR TODAS LAS OPERACIONES DE MANTENIMIENTO SOBRE LOS ROLES.'),
('32985C32-3D78-470E-83D9-35F77DD1BEC7','ORD_MAN_GEN','PEDIDOS','MANTENIMIENTO GENERAL','PERMITE REALIZAR TODAS LAS OPERACIONES DE MANTENIMIENTO SOBRE LOS PEDIDOS.'),
('58F66CFA-78FA-4727-A875-F0416F4608BE','BIN_USE_GEN','BITACORAS','USO GENERAL','PERMITE VER Y GENERAR REPORTES SOBRE LAS BITACORAS.'),
('F239CE9A-1A2E-40AF-97B0-F2412E89AA0E','REP_USE_GEN','REPORTES','USO GENERAL','PERMITE GENERAR CUALQUIER TIPO DE REPORTE.');
GO

INSERT INTO Role(Id,Name,Description,Status,CreationDate,AddedBy) VALUES
('EC81F591-CA24-4A80-8D54-316897E9015C','TODOS LOS PERMISOS','PERMITE REALIZAR TODAS LAS OPERACIONES DE MANTENIMIENTO EN TODOS LOS MODULOS ADMINISTRATIVOS DEL SISTEMA.','ACTIVADO',GETDATE(),'SYSTEM'),
('EAD69380-7151-4A7B-ABFF-E7B2A95DE71B','ADMINISTRADOR DE ARTICULOS','PERMITE REALIZAR TODAS LAS OPERACIONES DE MANTENIMIENTO SOBRE LOS ARTICULOS.','ACTIVADO',GETDATE(),'SYSTEM'),
('A3A677AB-AA67-4676-B685-371E3F2D7714','ADMINISTRADOR DE CATEGORIAS','PERMITE REALIZAR TODAS LAS OPERACIONES DE MANTENIMIENTO SOBRE LAS CATEGORIAS.','ACTIVADO',GETDATE(),'SYSTEM'),
('8A764C74-A21F-42C3-9AAA-2F0643D46EDF','ADMINISTRADOR DE SLIDERS','PERMITE REALIZAR TODAS LAS OPERACIONES DE MANTENIMIENTO SOBRE LOS SLIDERS.','ACTIVADO',GETDATE(),'SYSTEM'),
('377BB6EA-04AB-4433-B3AD-C4A7B0B0C28D','ADMINISTRADOR DE USUARIOS','PERMITE REALIZAR TODAS LAS OPERACIONES DE MANTENIMIENTO SOBRE LOS USUARIOS.','ACTIVADO',GETDATE(),'SYSTEM'),
('84F31CBE-DE5F-4DAF-81F1-E530F132CA41','ADMINISTRADOR DE ROLES','PERMITE REALIZAR TODAS LAS OPERACIONES DE MANTENIMIENTO SOBRE LOS ROLES.','ACTIVADO',GETDATE(),'SYSTEM'),
('4807D531-CA2C-4A52-BC26-522EE0D05F2F','ADMINISTRADOR DE PEDIDOS','PERMITE REALIZAR TODAS LAS OPERACIONES DE MANTENIMIENTO SOBRE LOS PEDIDOS.','ACTIVADO',GETDATE(),'SYSTEM'),
('956DD261-6684-483D-9D66-F94CB7C1AB08','ADMINISTRADOR DE BITACORAS','PERMITE VER Y GENERAR REPORTES SOBRE LAS BITACORAS.','ACTIVADO',GETDATE(),'SYSTEM'),
('7E9F4D53-9E54-4237-8CEC-8335BB91414D','ADMINISTRADOR DE REPORTES','PERMITE GENERAR CUALQUIER TIPO DE REPORTE.','ACTIVADO',GETDATE(),'SYSTEM');
GO



INSERT INTO Role_Permission(Id,RoleId,PermissionId) VALUES
(NEWID(),'EC81F591-CA24-4A80-8D54-316897E9015C','03B93003-B8F0-4315-A0C0-449E5058F23A'), --Todos los permisos
(NEWID(),'EC81F591-CA24-4A80-8D54-316897E9015C','1AAF51B4-B054-4487-9FC5-26B96886E737'), --Todos los permisos
(NEWID(),'EC81F591-CA24-4A80-8D54-316897E9015C','C236C5C0-004C-4B1C-A3E7-0E427E9F9593'), --Todos los permisos
(NEWID(),'EC81F591-CA24-4A80-8D54-316897E9015C','0C13E8A6-3A0A-419E-9D18-778D8DFC87D6'), --Todos los permisos
(NEWID(),'EC81F591-CA24-4A80-8D54-316897E9015C','9E66A172-D4C0-4FFB-B2F8-59471A826C17'), --Todos los permisos
(NEWID(),'EC81F591-CA24-4A80-8D54-316897E9015C','58F66CFA-78FA-4727-A875-F0416F4608BE'), --Todos los permisos
(NEWID(),'EC81F591-CA24-4A80-8D54-316897E9015C','32985C32-3D78-470E-83D9-35F77DD1BEC7'), --Todos los permisos
(NEWID(),'EC81F591-CA24-4A80-8D54-316897E9015C','F239CE9A-1A2E-40AF-97B0-F2412E89AA0E'), --Todos los permisos
(NEWID(),'EAD69380-7151-4A7B-ABFF-E7B2A95DE71B','03B93003-B8F0-4315-A0C0-449E5058F23A'), -- Articulos
(NEWID(),'A3A677AB-AA67-4676-B685-371E3F2D7714','1AAF51B4-B054-4487-9FC5-26B96886E737'), -- Categorias
(NEWID(),'8A764C74-A21F-42C3-9AAA-2F0643D46EDF','C236C5C0-004C-4B1C-A3E7-0E427E9F9593'), -- Sliders
(NEWID(),'377BB6EA-04AB-4433-B3AD-C4A7B0B0C28D','0C13E8A6-3A0A-419E-9D18-778D8DFC87D6'), -- Usuarios
(NEWID(),'84F31CBE-DE5F-4DAF-81F1-E530F132CA41','9E66A172-D4C0-4FFB-B2F8-59471A826C17'), -- Roles
(NEWID(),'4807D531-CA2C-4A52-BC26-522EE0D05F2F','32985C32-3D78-470E-83D9-35F77DD1BEC7'), -- Pedidos
(NEWID(),'956DD261-6684-483D-9D66-F94CB7C1AB08','58F66CFA-78FA-4727-A875-F0416F4608BE'), -- Bitacoras
(NEWID(),'7E9F4D53-9E54-4237-8CEC-8335BB91414D','F239CE9A-1A2E-40AF-97B0-F2412E89AA0E'); -- Reportes
GO
