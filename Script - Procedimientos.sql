/*USE MARKET_EXPRESS
GO*/

---------------------------------------------------------------------------------------------------------------
-- PROCEDIMIENTOS ARTICLE
---------------------------------------------------------------------------------------------------------------
--Obtiene info de articulos para mostrar en la vista de detalles de articulos
CREATE PROCEDURE Sp_Article_GetAllForCartDetails
(
	@userId UNIQUEIDENTIFIER = null
)
AS
BEGIN
	SELECT a.Id,
		   a.Description,
		   a.BarCode,
		   a.Price,
		   a.Image,
		   ct.Name AS CategoryName,
		   cd.Quantity
	FROM Cart_Detail cd
	INNER JOIN Article a
	ON a.Id = cd.ArticleId
	INNER JOIN Category ct
	ON a.CategoryId = ct.Id
	WHERE cd.CartId = (SELECT TOP 1 c.Id
					   FROM Cart c
					   INNER JOIN Client cl
					   ON c.ClientId = cl.Id
					   WHERE c.Status = 'ABIERTO'
					   AND cl.AppUserId = @userId
					   ORDER BY c.OpeningDate DESC);
END;
GO

-- Obtiene los articulos ordenados por popularidad con la opcion de obtener "x" cantidad ?nicamente
CREATE PROCEDURE Sp_Article_GetMostPopular
(
	@take INT = null -- Si este valor viene null entonces retorna todos los productos activos con categor?a
)
AS
BEGIN
	SELECT a.Id,
		   a.CategoryId,
		   a.Description,
		   a.BarCode,
		   a.Price,
		   a.Image,
		   COALESCE((SELECT SUM(od.Quantity)
					 FROM Order_Detail od
					 INNER JOIN [Order] o
					 ON o.Id = od.OrderId
					 WHERE od.ArticleId = a.Id
					 AND o.Status = 'TERMINADO'),0) repeatedCount
	FROM Article a, Category c
	WHERE a.CategoryId = c.Id
	AND c.Status = 'ACTIVADO'
	AND a.Status = 'ACTIVADO'
	ORDER BY repeatedCount DESC
	OFFSET 0 ROWS 
	FETCH NEXT COALESCE(@take,(SELECT COUNT(1)
							   FROM Article a
							   WHERE a.Status = 'ACTIVADO'
							   AND a.CategoryId IS NOT NULL)) ROWS ONLY; 
END;
GO

-- Obtiene los articulos para la vista de busqueda de articulos para agregar al carrito
CREATE PROCEDURE Sp_Article_GetAllForSell
(
	@description VARCHAR(255) = null,
	@maxPrice decimal(19,2) = null,
	@minPrice decimal(19,2) = null,
	@category varchar(MAX) = null,
	@pageNumber int = null,
	@pageSize int= null,
	@totalPages int = null OUTPUT,
	@totalCount int = null OUTPUT,
	@userId UNIQUEIDENTIFIER = null
)
AS
BEGIN
	DECLARE @skip int = @pageNumber*@pageSize;
	DECLARE @cartId UNIQUEIDENTIFIER;

	IF @userId IS NOT NULL
	BEGIN
	SET @cartId = (SELECT TOP 1 c.Id 
				   FROM Cart c 
				   WHERE c.ClientId = (SELECT TOP 1 cl.Id 
									   FROM Client cl 
									   WHERE cl.AppUserId = @userId)
				   AND c.Status = 'ABIERTO'
				   ORDER BY c.OpeningDate DESC);
	END;
	
	SET @totalCount = (SELECT COUNT(1) 
					   FROM Article a 
					   INNER JOIN  Category c
					   ON c.Id = a.CategoryId WHERE a.Status = 'ACTIVADO'
					   AND c.Status = 'ACTIVADO' 
					   AND (@description IS NULL OR a.Description LIKE '%'+@description +'%') 
					   AND (@maxPrice IS NULL OR a.Price <= @maxPrice) 
					   AND (@minPrice IS NULL OR a.Price >= @minPrice) 
					   AND (CONVERT(VARCHAR(100),a.CategoryId) IN ((SELECT VALUE FROM STRING_SPLIT(@category,',')))));
	
	SET @totalPages = CEILING(@totalCount / CONVERT(decimal,@pageSize));
	
	SELECT a.Id,
			a.CategoryId,
			a.Description,
			a.BarCode,
			a.Price,
			a.Image,
			(SELECT COALESCE(SUM(cd.Quantity),0)
			 FROM Cart_Detail cd 
			 WHERE cd.CartId = @cartId
			 AND cd.ArticleId = a.Id) CountInCart
	FROM Article a
	INNER JOIN  Category c
	ON c.Id = a.CategoryId
	WHERE a.Status = 'ACTIVADO'
	AND c.Status = 'ACTIVADO'
	AND (@description IS NULL OR a.Description LIKE '%'+@description +'%')
	AND (@maxPrice IS NULL OR a.Price <= @maxPrice)
	AND (@minPrice IS NULL OR a.Price >= @minPrice)
	AND (CONVERT(VARCHAR(100),a.CategoryId) IN ((SELECT VALUE FROM STRING_SPLIT(@category,','))))
	ORDER BY a.Description
	OFFSET @skip ROWS 
	FETCH NEXT @pageSize ROWS ONLY; 
END;
GO

--Obtiene un articulo por Id con data de estado en el carrito del usuario
CREATE PROCEDURE Sp_Article_GetByIdForSell
(
	@userId UNIQUEIDENTIFIER = null,
	@articleId UNIQUEIDENTIFIER = null
)
AS
BEGIN
	DECLARE @cartId UNIQUEIDENTIFIER;

	IF @userId IS NOT NULL
	BEGIN
	SET @cartId = (SELECT TOP 1 c.Id 
				   FROM Cart c 
				   WHERE c.ClientId = (SELECT TOP 1 cl.Id 
									   FROM Client cl 
									   WHERE cl.AppUserId = @userId)
				   AND c.Status = 'ABIERTO'
				   ORDER BY c.OpeningDate DESC);
	END;
	
	SELECT a.Id,
			a.CategoryId,
			a.Description,
			a.BarCode,
			a.Price,
			a.Image,
			a.Status,
			c.Name AS CategoryName, 
			c.Description AS CategoryDescription,
			c.Status AS CategoryStatus,
			c.Image AS CategoryImage,
			(SELECT COALESCE(SUM(cd.Quantity),0)
			 FROM Cart_Detail cd 
			 WHERE cd.CartId = @cartId
			 AND cd.ArticleId = a.Id) CountInCart
	FROM Article a
	INNER JOIN  Category c
	ON c.Id = a.CategoryId
	WHERE a.Id = @articleId;
END;
GO

---------------------------------------------------------------------------------------------------------------
-- PROCEDIMIENTOS REPORT
---------------------------------------------------------------------------------------------------------------
--Fuente de datos para la vista de reporte de articulos paginado

CREATE PROCEDURE Sp_Report_GetMostSoldArticlesPaginated
(
	@categoryId UNIQUEIDENTIFIER = NULL,
	@description VARCHAR(255) = NULL,
	@maxPrice DECIMAL(19,2) = NULL,
	@minPrice DECIMAL(19,2) = NULL,
	@pageNumber INT = NULL,
	@pageSize INT= NULL,
	@totalPages INT = NULL OUTPUT,
	@totalCount INT = NULL OUTPUT
)
AS
BEGIN
	DECLARE @skip int = @pageNumber*@pageSize;
	
	SET @totalCount = ( SELECT COUNT(1)
					    FROM Article a
						LEFT JOIN Category c
						ON a.CategoryId = c.Id
						WHERE (@categoryId IS NULL OR c.Id = @categoryId)
						AND (@description IS NULL OR a.Description LIKE '%'+@description+'%')
						AND (@maxPrice IS NULL OR a.Price <= @maxPrice)
						AND (@minPrice IS NULL OR a.Price >= @minPrice));
	
	SET @totalPages = CEILING(@totalCount / CONVERT(decimal,@pageSize));

	SELECT a.Description,
		   a.BarCode,
		   a.Price,
		   c.Name CategoryName,
		   (SELECT COALESCE(SUM(od.Quantity),0)
			FROM Order_Detail od
			INNER JOIN [Order] o
			ON o.Id = od.OrderId
			WHERE od.ArticleId = a.Id
			AND o.Status = 'TERMINADO') SoldUnitsCount,
		   a.Status
	FROM Article a
	LEFT JOIN Category c
	ON a.CategoryId = c.Id
	WHERE (@categoryId IS NULL OR c.Id = @categoryId)
	AND (@description IS NULL OR a.Description LIKE '%'+@description+'%')
	AND (@maxPrice IS NULL OR a.Price <= @maxPrice)
	AND (@minPrice IS NULL OR a.Price >= @minPrice)
	ORDER BY SoldUnitsCount DESC, a.Description ASC
	OFFSET @skip ROWS 
	FETCH NEXT @pageSize ROWS ONLY;
END;
GO


--Fuente de datos para el reporte de articulos mas vendidos
CREATE PROCEDURE Sp_Report_GetMostSoldArticles
(
	@categoryId UNIQUEIDENTIFIER = NULL,
	@description VARCHAR(255) = NULL,
	@maxPrice DECIMAL(19,2) = NULL,
	@minPrice DECIMAL(19,2) = NULL
)
AS
BEGIN
	SELECT a.Description,
		   a.BarCode,
		   a.Price,
		   c.Name CategoryName,
		   (SELECT COALESCE(SUM(od.Quantity),0)
			FROM Order_Detail od
			INNER JOIN [Order] o
			ON o.Id = od.OrderId
			WHERE od.ArticleId = a.Id
			AND o.Status = 'TERMINADO') SoldUnitsCount,
		   a.Status
	FROM Article a
	LEFT JOIN Category c
	ON a.CategoryId = c.Id
	WHERE (@categoryId IS NULL OR c.Id = @categoryId)
	AND (@description IS NULL OR a.Description LIKE '%'+@description+'%')
	AND (@maxPrice IS NULL OR a.Price <= @maxPrice)
	AND (@minPrice IS NULL OR a.Price >= @minPrice)
	ORDER BY SoldUnitsCount DESC, a.Description ASC
END;
GO

-- Obtiene estadisticas de los clientes paginado y filtrado por fechas de realizacion del pedido
CREATE PROCEDURE Sp_Report_GetClientsStatsPaginated
(
	@startDate DATE = NULL,
	@endDate DATE = NULL,
	@pageNumber INT = NULL,
	@pageSize INT= NULL,
	@totalPages INT = NULL OUTPUT,
	@totalCount INT = NULL OUTPUT
)
AS
BEGIN
	DECLARE @skip int = @pageNumber*@pageSize;
	
	SET @totalCount = ( SELECT COUNT(1)
						FROM Client cl
						INNER JOIN AppUser ap
						ON ap.Id = cl.AppUserId);
	
	SET @totalPages = CEILING(@totalCount / CONVERT(decimal,@pageSize));

	SELECT  ap.Id,
			ap.Name,
			ap.Identification,
			ap.Phone,
			ap.Email,
			cl.ClientCode,
			(SELECT COUNT(1) 
			FROM [Order] o 
			WHERE o.ClientId = cl.Id 
			AND o.Status = 'PENDIENTE'
			AND (@startDate IS NULL OR CAST(o.CreationDate AS DATE) >= @startDate)
			AND (@endDate IS NULL OR CAST(o.CreationDate AS DATE) <= @endDate)) Pending,
			(SELECT COUNT(1) 
			FROM [Order] o 
			WHERE o.ClientId = cl.Id 
			AND o.Status = 'TERMINADO'
			AND (@startDate IS NULL OR CAST(o.CreationDate AS DATE) >= @startDate)
			AND (@endDate IS NULL OR CAST(o.CreationDate AS DATE) <= @endDate)) Finished,
			(SELECT COUNT(1)
			FROM [Order] o
			WHERE o.ClientId = cl.Id
			AND o.Status = 'CANCELADO'
			AND (@startDate IS NULL OR CAST(o.CreationDate AS DATE) >= @startDate)
			AND (@endDate IS NULL OR CAST(o.CreationDate AS DATE) <= @endDate)) Canceled
	FROM Client cl
	INNER JOIN AppUser ap
	ON ap.Id = cl.AppUserId
	ORDER BY ap.Name ASC
	OFFSET @skip ROWS 
	FETCH NEXT @pageSize ROWS ONLY;
END;
GO

CREATE PROCEDURE Sp_Report_GetClientsStats
(
	@startDate DATE = NULL,
	@endDate DATE = NULL
)
AS
BEGIN
	SELECT  ap.Name,
			ap.Identification,
			ap.Phone,
			ap.Email,
			cl.ClientCode,
			(SELECT COUNT(1) 
			FROM [Order] o 
			WHERE o.ClientId = cl.Id 
			AND o.Status = 'PENDIENTE'
			AND (@startDate IS NULL OR CAST(o.CreationDate AS DATE) >= @startDate)
			AND (@endDate IS NULL OR CAST(o.CreationDate AS DATE) <= @endDate)) Pending,
			(SELECT COUNT(1) 
			FROM [Order] o 
			WHERE o.ClientId = cl.Id 
			AND o.Status = 'TERMINADO'
			AND (@startDate IS NULL OR CAST(o.CreationDate AS DATE) >= @startDate)
			AND (@endDate IS NULL OR CAST(o.CreationDate AS DATE) <= @endDate)) Finished,
			(SELECT COUNT(1)
			FROM [Order] o
			WHERE o.ClientId = cl.Id
			AND o.Status = 'CANCELADO'
			AND (@startDate IS NULL OR CAST(o.CreationDate AS DATE) >= @startDate)
			AND (@endDate IS NULL OR CAST(o.CreationDate AS DATE) <= @endDate)) Canceled
	FROM Client cl
	INNER JOIN AppUser ap
	ON ap.Id = cl.AppUserId
	ORDER BY ap.Name ASC
END;
GO

---------------------------------------------------------------------------------------------------------------
-- PROCEDIMIENTOS BINNACLE_MOVEMENT
---------------------------------------------------------------------------------------------------------------
-- Obtiene todos los registros paginados
CREATE PROCEDURE Sp_BinnacleMovement_GetAllPaginated 
(
	@type VARCHAR(20) = NULL,
	@startDate DATE = NULL,
	@endDate DATE = NULL,
	@name VARCHAR(50) = NULL,
	@ignoreSystem BIT = 0,
	@pageNumber INT = null,
	@pageSize INT= null,
	@totalPages INT = null OUTPUT,
	@totalCount INT = null OUTPUT
)
AS
BEGIN
	DECLARE @skip int = @pageNumber*@pageSize;

	SET @totalCount =  (SELECT COUNT(1) totalCount
						FROM Binnacle_Movement bm
						LEFT JOIN AppUser ap
						ON bm.PerformedBy = CONVERT(VARCHAR(100),ap.Id)
						WHERE (@type IS NULL OR bm.Type = @type)
						AND (@startDate IS NULL OR CAST(bm.MovementDate AS DATE) >= CAST(@startDate AS DATE))
						AND (@endDate IS NULL OR CAST(bm.MovementDate AS DATE) <= CAST(@endDate AS DATE))
						AND (@name IS NULL OR (bm.PerformedBy = @name OR ap.Name = @name))
						AND ((@ignoreSystem = 1 AND bm.PerformedBy <> 'SYSTEM') OR @ignoreSystem = 0));

	SET @totalPages = CEILING(@totalCount / CONVERT(decimal,@pageSize));

	SELECT bm.Id,
		   bm.Type,
		   bm.Detail,
		   bm.MovementDate,
		   CASE
		   WHEN bm.PerformedBy = 'SYSTEM' THEN bm.PerformedBy
		   ELSE ap.Name END AS PerformedBY,
		   CASE
		   WHEN bm.PerformedBy = 'SYSTEM' THEN 'N/A'
		   ELSE ap.Identification END AS Identification
	FROM Binnacle_Movement bm
	LEFT JOIN AppUser ap
	ON bm.PerformedBy = CONVERT(VARCHAR(100),ap.Id)
	WHERE (@type IS NULL OR bm.Type = @type)
	AND (@startDate IS NULL OR CAST(bm.MovementDate AS DATE) >= CAST(@startDate AS DATE))
	AND (@endDate IS NULL OR CAST(bm.MovementDate AS DATE) <= CAST(@endDate AS DATE))
	AND (@name IS NULL OR (bm.PerformedBy = @name OR ap.Name = @name))
	AND ((@ignoreSystem = 1 AND bm.PerformedBy <> 'SYSTEM') OR @ignoreSystem = 0)
	ORDER BY bm.MovementDate DESC
	OFFSET @skip ROWS 
	FETCH NEXT @pageSize ROWS ONLY; 
END;
GO

-- Obtiene todos los registros para generar el reporte
CREATE PROCEDURE Sp_BinnacleMovement_GetAllForReport
(
	@type VARCHAR(20) = NULL,
	@startDate DATE = NULL,
	@endDate DATE = NULL,
	@name VARCHAR(50) = NULL,
	@ignoreSystem BIT = 0
)
AS
BEGIN
	SELECT bm.Id,
		   bm.Type,
		   bm.Detail,
		   bm.MovementDate,
		   CASE
		   WHEN bm.PerformedBy = 'SYSTEM' THEN bm.PerformedBy
		   ELSE ap.Name END AS PerformedBY,
		   CASE
		   WHEN bm.PerformedBy = 'SYSTEM' THEN 'N/A'
		   ELSE ap.Identification END AS Identification
	FROM Binnacle_Movement bm
	LEFT JOIN AppUser ap
	ON bm.PerformedBy = CONVERT(VARCHAR(100),ap.Id)
	WHERE (@type IS NULL OR bm.Type = @type)
	AND (@startDate IS NULL OR CAST(bm.MovementDate AS DATE) >= CAST(@startDate AS DATE))
	AND (@endDate IS NULL OR CAST(bm.MovementDate AS DATE) <= CAST(@endDate AS DATE))
	AND (@name IS NULL OR (bm.PerformedBy = @name OR ap.Name = @name))
	AND ((@ignoreSystem = 1 AND bm.PerformedBy <> 'SYSTEM') OR @ignoreSystem = 0)
	ORDER BY bm.MovementDate DESC 
END;
GO


---------------------------------------------------------------------------------------------------------------
-- PROCEDIMIENTOS APPUSER
---------------------------------------------------------------------------------------------------------------
-- Obtiene los permisos del usuario segun los roles asignados
CREATE PROCEDURE Sp_AppUser_GetPermissions
(
	@Id UNIQUEIDENTIFIER
)
AS
BEGIN
	SELECT DISTINCT 
		   p.Id,
		   p.PermissionCode,
		   p.Name,
		   p.Description,
		   p.Type
	FROM AppUser u,
		 AppUser_Role ur,
		 Role r,
		 Role_Permission rp,
		 Permission p
	WHERE ur.AppUserId = @Id
	AND ur.RoleId = r.Id
	AND ur.RoleId = rp.RoleId
	AND p.Id = rp.PermissionId
END;
GO


---------------------------------------------------------------------------------------------------------------
-- PROCEDIMIENTOS CART
---------------------------------------------------------------------------------------------------------------
--Obtiene el carrito actual del usuario
CREATE PROCEDURE Sp_Cart_GetCurrentByUserId
(
	@UserId UNIQUEIDENTIFIER
)
AS
BEGIN
	SELECT c.Id,
		   c.ClientId,
		   c.OpeningDate,
		   c.Status
	FROM Cart c
	INNER JOIN Client cl
	ON c.ClientId = cl.Id
	AND cl.AppUserId = @userId
	WHERE (SELECT MAX(OpeningDate) FROM Cart WHERE ClientId = cl.Id) = c.OpeningDate
	AND c.Status = 'ABIERTO';
END;
GO

--Obtiene la cantidad de articulos en el carrito
CREATE PROCEDURE Sp_Cart_GetArticlesCount
(
	@UserId UNIQUEIDENTIFIER
)
AS
BEGIN
	DECLARE @count INT = 0;
	DECLARE @cartId UNIQUEIDENTIFIER = (SELECT TOP 1 c.Id
										FROM Cart c
										INNER JOIN Client cl
										ON cl.Id = c.ClientId
										WHERE cl.AppUserId = @UserId
										AND (SELECT MAX(OpeningDate) 
											 FROM Cart 
											 WHERE ClientId = cl.Id) = c.OpeningDate);
	
	IF (SELECT Status FROM Cart WHERE Id = @cartId) = 'ABIERTO'
	BEGIN
		SET @count = (SELECT COALESCE(SUM(cd.Quantity),0) 
					  FROM Cart_Detail cd 
					  WHERE cd.CartId = @cartId);
	END
	 
	SELECT @count;
END;
GO

--Obtiene la cantidad de carritos que tienen "X" articulo en el
CREATE PROCEDURE Sp_Cart_GetOpenCountByArticleId
(
	@articleId UNIQUEIDENTIFIER
)
AS
BEGIN
	SELECT COUNT(1)
	FROM Cart c, Cart_Detail cd
	WHERE c.Id = cd.CartId
	AND c.Status = 'ABIERTO'
	AND cd.ArticleId = @articleId;
END;
GO


---------------------------------------------------------------------------------------------------------------
-- PROCEDIMIENTOS ADDRESS
---------------------------------------------------------------------------------------------------------------
--Obtiene las direcciones del cliente por Id de usuario
CREATE PROCEDURE Sp_Address_GetAllByClient
(
	@UserId UNIQUEIDENTIFIER
)
AS
BEGIN
	SELECT ad.Id,
		   ad.ClientId,
		   ad.Name,
		   ad.Detail,
		   ad.InUse
	FROM AppUser a, Client c, Address ad
	WHERE a.Id = @UserId
	AND c.AppUserId = a.Id
	AND ad.ClientId = c.Id
END;
GO


---------------------------------------------------------------------------------------------------------------
-- PROCEDIMIENTOS APPUSERROLE
---------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE Sp_AppUserRole_GetUserCountUsingARole
(
	@roleId UNIQUEIDENTIFIER
)
AS
BEGIN
	SELECT (SELECT COUNT(1)
			FROM AppUser_Role ar, AppUser au
			WHERE ar.RoleId = @roleId
			AND ar.AppUserId = au.Id
			AND au.Status = 'ACTIVADO') ActiveUsers,
		   (SELECT COUNT(1)
			FROM AppUser_Role ar, AppUser au
			WHERE ar.RoleId = @roleId
			AND ar.AppUserId = au.Id
			AND au.Status = 'DESACTIVADO') DisabledUsers;
END;
GO


---------------------------------------------------------------------------------------------------------------
-- PROCEDIMIENTOS PERMISSION
---------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE Sp_Permission_GetAllByRoleId
(
	@Id UNIQUEIDENTIFIER
)
AS
BEGIN
	SELECT p.Id,
		   p.Name,
		   p.Description,
		   p.PermissionCode,
		   p.Type
	FROM Role_Permission rp,
		 Permission p
	WHERE rp.RoleId = @Id
	AND p.Id = rp.PermissionId
	ORDER BY p.Type ASC;
END;
GO

--Obtiene todos los tipos de permisos
CREATE PROCEDURE Sp_Permission_GetAllTypes
AS
BEGIN
	SELECT DISTINCT p.Type
	FROM Permission p
	ORDER BY p.Type ASC
END;
GO

---------------------------------------------------------------------------------------------------------------
-- PROCEDIMIENTOS CATEGORY
---------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE Sp_Category_GetMostPopular
(
	@take int = null
)
AS
BEGIN
	SELECT c.Id,
	       c.Name,
		   c.Description,
		   c.Image,
		   COALESCE(( SELECT SUM(od.Quantity)
					  FROM Order_Detail od
					  INNER JOIN Article a
					  ON od.ArticleId = a.Id
					  INNER JOIN [Order] o
					  ON od.OrderId = o.Id
					  WHERE a.CategoryId = c.Id
					  AND o.Status = 'TERMINADO'),0) repeated
	FROM Category c
	WHERE c.Status = 'ACTIVADO'
	ORDER BY repeated DESC
	OFFSET 0 ROWS 
	FETCH NEXT COALESCE(@take,(SELECT COUNT(1)
							   FROM Category c
							   WHERE c.Status = 'ACTIVADO')) ROWS ONLY; 
END;
GO

--Obtiene cantidad de articulos asignados a la categoria por Id
CREATE PROCEDURE Sp_Category_GetArticleDetails
(
	@CategoryId UNIQUEIDENTIFIER
)
AS
BEGIN
	DECLARE @ArticlesEnabledCount INT = 0;
	DECLARE @ArticlesDisabledCount INT = 0;

	IF EXISTS (SELECT 1 FROM Category WHERE Id = @CategoryId)
	BEGIN
		SET @ArticlesEnabledCount = ISNULL((SELECT COUNT(1) 
											FROM Article a 
											WHERE a.CategoryId = @CategoryId 
											AND a.Status = 'ACTIVADO'), 0);

		SET @ArticlesDisabledCount = ISNULL((SELECT COUNT(1) 
											 FROM Article a 
											 WHERE a.CategoryId = @CategoryId 
										     AND a.Status = 'DESACTIVADO'), 0);
	END;

	SELECT @ArticlesEnabledCount,
		   @ArticlesDisabledCount;

END;
GO


--Obtiene todas las categorias activas y la cantidad de articulos asignados
CREATE PROCEDURE Sp_Category_GetAllAvailableForSearch
AS
BEGIN
	SELECT c.Id,
	       c.Name,
		   c.Description,
		   c.Status,
		   c.image,
		   c.CreationDate,
		   c.ModificationDate,
		   c.AddedBy,
		   c.ModifiedBy,
		   (SELECT COUNT(1) 
		    FROM Article a 
			WHERE a.Status = 'ACTIVADO' 
			AND a.CategoryId = c.Id) AS ArticlesCount
	FROM Category c
	WHERE c.Status = 'ACTIVADO'
	ORDER BY ArticlesCount DESC;

END;
GO

---------------------------------------------------------------------------------------------------------------
-- PROCEDIMIENTOS ORDER
---------------------------------------------------------------------------------------------------------------
--Obtiene los detalles (articulos) por id de pedido
CREATE PROCEDURE Sp_Order_GetDetailsById
(
	@orderId UNIQUEIDENTIFIER = NULL
)
AS
BEGIN
	SELECT a.Id,
		   a.Description,
		   a.BarCode,
		   od.Quantity,
		   a.Price
	FROM Order_Detail od
	INNER JOIN Article a
	ON od.ArticleId = a.Id
	WHERE od.OrderId = @orderId;
END;
GO

--Obtiene estadisticas de pedidos 
CREATE PROCEDURE Sp_Order_GetStats
AS
BEGIN
	SELECT (SELECT COUNT(1) FROM [Order] o WHERE o.Status = 'PENDIENTE') pending,
		   (SELECT COUNT(1) FROM [Order] o WHERE o.Status = 'TERMINADO') finished,
	       (SELECT COUNT(1) FROM [Order] o WHERE o.Status = 'CANCELADO') canceled;
END;
GO

--Obtiene estadisticas de pedidos por id de usuario
CREATE PROCEDURE Sp_Order_GetStatsByUserId
(
	@userId UNIQUEIDENTIFIER = NULL
)
AS
BEGIN
	SELECT (SELECT COUNT(1) FROM [Order] o WHERE o.ClientId = c.Id AND o.Status = 'PENDIENTE') pending,
		   (SELECT COUNT(1) FROM [Order] o WHERE o.ClientId = c.Id AND o.Status = 'TERMINADO') finished,
	       (SELECT COUNT(1) FROM [Order] o WHERE o.ClientId = c.Id AND o.Status = 'CANCELADO') canceled
	FROM Client c
	INNER JOIN AppUser ap
	ON c.AppUserId = ap.Id
	WHERE ap.Id = @userId;
END;
GO

--Obtiene ordenes recientes por id de usuario
CREATE PROCEDURE Sp_Order_GetMostRecentByUserId
(
	@userId UNIQUEIDENTIFIER = NULL,
	@take INT = NULL
)
AS
BEGIN
	SELECT o.Id,
	   o.CreationDate,
	   o.OrderNumber,
	   o.Status,
	   (SELECT a.Image
	    FROM Article a
		WHERE a.Id = (SELECT TOP 1 ArticleId
					  FROM Order_Detail
					  WHERE OrderId = o.Id
					  ORDER BY Quantity DESC)) MostRequestedArticleImage
	FROM [Order] o
	INNER JOIN Client cl
	ON cl.Id = o.ClientId
	INNER JOIN AppUser ap
	ON ap.Id = cl.AppUserId
	WHERE ap.Id = @userId
	ORDER BY o.CreationDate DESC
	OFFSET 0 ROWS
	FETCH NEXT COALESCE(@take,(SELECT COUNT(1)
							   FROM [Order] o
							   INNER JOIN Client cl
							   ON o.ClientId = cl.Id
							   WHERE cl.AppUserId = @userId)) ROWS ONLY;
END;
GO

--Obtiene los pedidos mas recientes de todos los clientes
CREATE PROCEDURE Sp_Order_GetMostRecent
(
	@take INT = NULL,
	@onlyPending BIT = NULL
)
AS
BEGIN
	SELECT o.Id,
	   o.CreationDate,
	   o.OrderNumber,
	   o.Status,
	   (SELECT a.Image
	    FROM Article a
		WHERE a.Id = (SELECT TOP 1 ArticleId
					  FROM Order_Detail
					  WHERE OrderId = o.Id
					  ORDER BY Quantity DESC)) MostRequestedArticleImage
	FROM [Order] o
	WHERE (@onlyPending IS NULL OR (o.Status = 'PENDIENTE' AND @onlyPending = 1))
	ORDER BY o.CreationDate DESC
	OFFSET 0 ROWS
	FETCH NEXT COALESCE(@take,(SELECT COUNT(1)
							   FROM [Order] o
							   WHERE (@onlyPending IS NULL OR (o.Status = 'PENDIENTE' AND @onlyPending = 1)))) ROWS ONLY;
END;
GO

---------------------------------------------------------------------------------------------------------------
-- PROCEDIMIENTOS ROLE
---------------------------------------------------------------------------------------------------------------
--Obtiene los roles de un usuario
CREATE PROCEDURE Sp_Role_GetAllByUserId
(
	@userId UNIQUEIDENTIFIER
)
AS
BEGIN
	SELECT r.Id,
		   r.Name,
		   r.Description,
		   r.CreationDate,
		   r.ModificationDate,
		   r.AddedBy,
		   r.ModifiedBy
	FROM dbo.[Role] r, AppUser_Role ar
	WHERE r.Id = ar.RoleId
	AND ar.AppUserId = @userId
	ORDER BY r.Name;
END;
GO

---------------------------------------------------------------------------------------------------------------
-- TRIGGERS ARTICLE
---------------------------------------------------------------------------------------------------------------
--Registra movimiento de insercion en la tb Article
CREATE TRIGGER TRG_Article_RegMovement_Insert
ON Article
FOR INSERT
AS
BEGIN
	DECLARE curArticles CURSOR FOR SELECT i.Description,
										  i.BarCode,
										  i.CreationDate,
										  i.AddedBy
								   FROM inserted i;
	
	DECLARE @Description VARCHAR(255);
	DECLARE @BarCode VARCHAR(255);
	DECLARE @CreationDate DATETIME;
	DECLARE @AddedBy VARCHAR(40);

	OPEN curArticles
	FETCH NEXT FROM curArticles INTO @Description, @BarCode, @CreationDate, @AddedBy
	WHILE @@fetch_status = 0
	BEGIN
		INSERT INTO Binnacle_Movement(PerformedBy,MovementDate,Type,Detail)
		VALUES(@AddedBy,@CreationDate,'INSERT','INSERT Articulo ' + @Description + ' '+@BarCode);

		FETCH NEXT FROM curArticles INTO @Description, @BarCode, @CreationDate, @AddedBy
	END
	CLOSE curArticles
	DEALLOCATE curArticles
END;
GO

--Registra movimiento de actualizacion en la tb Article
CREATE TRIGGER TRG_Article_RegMovement_Update
ON Article
FOR UPDATE
AS
BEGIN
	DECLARE curArticles CURSOR FOR SELECT i.Description,
										  i.BarCode,
										  i.ModificationDate,
										  i.ModifiedBy
								   FROM inserted i;
	
	DECLARE @Description VARCHAR(255);
	DECLARE @BarCode VARCHAR(255);
	DECLARE @ModificationDate DATETIME;
	DECLARE @ModifiedBy VARCHAR(40);

	OPEN curArticles
	FETCH NEXT FROM curArticles INTO @Description, @BarCode, @ModificationDate, @ModifiedBy
	WHILE @@fetch_status = 0
	BEGIN
		INSERT INTO Binnacle_Movement(PerformedBy,MovementDate,Type,Detail)
		VALUES(@ModifiedBy,@ModificationDate,'UPDATE','UPDATE Articulo ' + @Description + ' '+@BarCode);

		FETCH NEXT FROM curArticles INTO @Description, @BarCode, @ModificationDate, @ModifiedBy
	END
	CLOSE curArticles
	DEALLOCATE curArticles
END;
GO

---------------------------------------------------------------------------------------------------------------
-- TRIGGERS CATEGORY
---------------------------------------------------------------------------------------------------------------
CREATE TRIGGER TRG_Category_RegMovement_Insert
ON Category
FOR INSERT
AS
BEGIN
										  
	DECLARE curCategories CURSOR FOR SELECT i.Name,
										  i.Description,
										  i.CreationDate,
										  i.AddedBy
								   FROM inserted i;
	
	DECLARE @Name VARCHAR(50);
	DECLARE @Description VARCHAR(255);
	DECLARE @CreationDate DATETIME;
	DECLARE @AddedBy VARCHAR(40);

	OPEN curCategories
	FETCH NEXT FROM curCategories INTO @Name, @Description, @CreationDate, @AddedBy
	WHILE @@fetch_status = 0
	BEGIN
		INSERT INTO Binnacle_Movement(PerformedBy,MovementDate,Type,Detail)
		VALUES(@AddedBy,@CreationDate,'INSERT','INSERT Categoria ' + @Name);

		FETCH NEXT FROM curCategories INTO @Name, @Description, @CreationDate, @AddedBy
	END
	CLOSE curCategories
	DEALLOCATE curCategories
END;
GO

CREATE TRIGGER TRG_Category_RegMovement_Update
ON Category
FOR UPDATE
AS
BEGIN
										  
	DECLARE curCategories CURSOR FOR SELECT i.Name,
										  i.Description,
										  i.ModificationDate,
										  i.ModifiedBy
								   FROM inserted i;
	
	DECLARE @Name VARCHAR(50);
	DECLARE @Description VARCHAR(255);
	DECLARE @ModificationDate DATETIME;
	DECLARE @ModifiedBy VARCHAR(40);

	OPEN curCategories
	FETCH NEXT FROM curCategories INTO @Name, @Description, @ModificationDate, @ModifiedBy
	WHILE @@fetch_status = 0
	BEGIN
		INSERT INTO Binnacle_Movement(PerformedBy,MovementDate,Type,Detail)
		VALUES(@ModifiedBy,@ModificationDate,'UPDATE','UPDATE Categoria ' + @Name);

		FETCH NEXT FROM curCategories INTO @Name, @Description, @ModificationDate, @ModifiedBy
	END
	CLOSE curCategories
	DEALLOCATE curCategories
END;
GO



---------------------------------------------------------------------------------------------------------------
-- TRIGGERS ROLE
---------------------------------------------------------------------------------------------------------------
CREATE TRIGGER TRG_Role_RegMovement_Insert
ON [Role]
FOR INSERT
AS
BEGIN
										  
	DECLARE curRoles CURSOR FOR SELECT i.Name,
										  i.Description,
										  i.CreationDate,
										  i.AddedBy
								   FROM inserted i;
	
	DECLARE @Name VARCHAR(50);
	DECLARE @Description VARCHAR(255);
	DECLARE @CreationDate DATETIME;
	DECLARE @AddedBy VARCHAR(40);

	OPEN curRoles
	FETCH NEXT FROM curRoles INTO @Name, @Description, @CreationDate, @AddedBy
	WHILE @@fetch_status = 0
	BEGIN
		INSERT INTO Binnacle_Movement(PerformedBy,MovementDate,Type,Detail)
		VALUES(@AddedBy,@CreationDate,'INSERT','INSERT Rol ' + @Name);

		FETCH NEXT FROM curRoles INTO @Name, @Description, @CreationDate, @AddedBy
	END
	CLOSE curRoles
	DEALLOCATE curRoles
END;
GO

CREATE TRIGGER TRG_Role_RegMovement_Update
ON [Role]
FOR UPDATE
AS
BEGIN
										  
	DECLARE curRoles CURSOR FOR SELECT i.Name,
										  i.Description,
										  i.ModificationDate,
										  i.ModifiedBy
								   FROM inserted i;
	
	DECLARE @Name VARCHAR(50);
	DECLARE @Description VARCHAR(255);
	DECLARE @ModificationDate DATETIME;
	DECLARE @ModifiedBy VARCHAR(40);

	OPEN curRoles
	FETCH NEXT FROM curRoles INTO @Name, @Description, @ModificationDate, @ModifiedBy
	WHILE @@fetch_status = 0
	BEGIN
		INSERT INTO Binnacle_Movement(PerformedBy,MovementDate,Type,Detail)
		VALUES(@ModifiedBy,@ModificationDate,'UPDATE','UPDATE Rol ' + @Name);

		FETCH NEXT FROM curRoles INTO @Name, @Description, @ModificationDate, @ModifiedBy
	END
	CLOSE curRoles
	DEALLOCATE curRoles
END;
GO

---------------------------------------------------------------------------------------------------------------
-- TRIGGERS APPUSER
---------------------------------------------------------------------------------------------------------------
CREATE TRIGGER TRG_AppUser_RegMovement_Insert
ON [AppUser]
FOR INSERT
AS
BEGIN
										  
	DECLARE curAppUser CURSOR FOR SELECT i.Name,
										  i.Identification,
										  i.CreationDate,
										  i.AddedBy
								   FROM inserted i;
	
	DECLARE @Name VARCHAR(50);
	DECLARE @Identification VARCHAR(255);
	DECLARE @CreationDate DATETIME;
	DECLARE @AddedBy VARCHAR(40);

	OPEN curAppUser
	FETCH NEXT FROM curAppUser INTO @Name, @Identification, @CreationDate, @AddedBy
	WHILE @@fetch_status = 0
	BEGIN
		INSERT INTO Binnacle_Movement(PerformedBy,MovementDate,Type,Detail)
		VALUES(@AddedBy,@CreationDate,'INSERT','INSERT Usuario ' + @Name + ' ' +@Identification);

		FETCH NEXT FROM curAppUser INTO @Name, @Identification, @CreationDate, @AddedBy
	END
	CLOSE curAppUser
	DEALLOCATE curAppUser
END;
GO

CREATE TRIGGER TRG_AppUser_RegMovement_Update
ON [AppUser]
FOR UPDATE
AS
BEGIN
										  
	DECLARE curAppUser CURSOR FOR SELECT i.Name,
										  i.Identification,
										  i.ModificationDate,
										  i.ModifiedBy
								   FROM inserted i;
	
	DECLARE @Name VARCHAR(50);
	DECLARE @Identification VARCHAR(255);
	DECLARE @ModificationDate DATETIME;
	DECLARE @ModifiedBy VARCHAR(40);

	OPEN curAppUser
	FETCH NEXT FROM curAppUser INTO @Name, @Identification, @ModificationDate, @ModifiedBy
	WHILE @@fetch_status = 0
	BEGIN
		INSERT INTO Binnacle_Movement(PerformedBy,MovementDate,Type,Detail)
		VALUES(@ModifiedBy,@ModificationDate,'UPDATE','UPDATE Usuario ' + @Name + ' ' +@Identification);

		FETCH NEXT FROM curAppUser INTO @Name, @Identification, @ModificationDate, @ModifiedBy
	END
	CLOSE curAppUser
	DEALLOCATE curAppUser
END;
GO

---------------------------------------------------------------------------------------------------------------
-- TRIGGERS SLIDER
---------------------------------------------------------------------------------------------------------------
CREATE TRIGGER TRG_Slider_RegMovement_Insert
ON [Slider]
FOR INSERT
AS
BEGIN
										  
	DECLARE curSlider CURSOR FOR SELECT i.Name,
										  i.CreationDate,
										  i.AddedBy
								   FROM inserted i;
	
	DECLARE @Name VARCHAR(50);
	DECLARE @CreationDate DATETIME;
	DECLARE @AddedBy VARCHAR(40);

	OPEN curSlider
	FETCH NEXT FROM curSlider INTO @Name, @CreationDate, @AddedBy
	WHILE @@fetch_status = 0
	BEGIN
		INSERT INTO Binnacle_Movement(PerformedBy,MovementDate,Type,Detail)
		VALUES(@AddedBy,@CreationDate,'INSERT','INSERT Slider ' + @Name);

		FETCH NEXT FROM curSlider INTO @Name, @CreationDate, @AddedBy
	END
	CLOSE curSlider
	DEALLOCATE curSlider
END;
GO

CREATE TRIGGER TRG_Slider_RegMovement_Update
ON [Slider]
FOR UPDATE
AS
BEGIN
										  
	DECLARE curSlider CURSOR FOR SELECT i.Name,
										  i.ModificationDate,
										  i.ModifiedBy
								   FROM inserted i;
	
	DECLARE @Name VARCHAR(50);
	DECLARE @ModificationDate DATETIME;
	DECLARE @ModifiedBy VARCHAR(40);

	OPEN curSlider
	FETCH NEXT FROM curSlider INTO @Name, @ModificationDate, @ModifiedBy
	WHILE @@fetch_status = 0
	BEGIN
		INSERT INTO Binnacle_Movement(PerformedBy,MovementDate,Type,Detail)
		VALUES(@ModifiedBy,@ModificationDate,'UPDATE','UPDATE Slider ' + @Name);

		FETCH NEXT FROM curSlider INTO @Name, @ModificationDate, @ModifiedBy
	END
	CLOSE curSlider
	DEALLOCATE curSlider
END;
GO

