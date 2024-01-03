-- ==========================================================================
-- Procedure: prc_delete_data_from_schemas_in_db
-- Description: Cleaning data from database schemas and tables
-- Author: Bartosz Caban
-- ==========================================================================

CREATE OR ALTER PROCEDURE prc_delete_data_from_schemas_in_db
	@in_schema_name NVARCHAR(200)

AS
BEGIN

-- ==========================================================================
-- DECLARE LOCAL PARAMTERS
-- ==========================================================================

	DECLARE @l_sql NVARCHAR(MAX);
	DECLARE @l_table_name NVARCHAR(200);
	DECLARE @l_schema_name NVARCHAR(200);

-- ==========================================================================
-- INITITIALIZE LOCAL PARAMTERS
-- ==========================================================================

	SET @l_schema_name = @in_schema_name;

-- ==========================================================================
-- Cursor operations
-- ==========================================================================

	DECLARE cursor_deleting_data CURSOR FOR
		
		SELECT TABLE_NAME
		FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_SCHEMA = @l_schema_name

		OPEN cursor_deleting_data;

		FETCH NEXT FROM cursor_deleting_data INTO @l_table_name
		WHILE @@FETCH_STATUS = 0
			BEGIN
				
				SET @l_sql = 'TRUNCATE TABLE ' + QUOTENAME(@l_schema_name) + '.' + QUOTENAME(@l_table_name)
				EXECUTE sp_executesql @l_sql

				FETCH NEXT FROM cursor_deleting_data INTO @l_table_name

			END
		
		CLOSE cursor_deleting_data;
		DEALLOCATE cursor_deleting_data;

END;

-- ==========================================================================
-- Procedure: cust.prc_add_customer
-- Description: Adding a new customer to the customer table
-- Author: Bartosz Caban
-- ==========================================================================

CREATE OR ALTER PROCEDURE cust.prc_add_customer (
	@in_customer_type_id BIGINT,
	@in_first_name NVARCHAR(200),
	@in_last_name NVARCHAR(200),
	@in_customer_login NVARCHAR(200),
	@in_exec_user_name NVARCHAR(200)
)

AS 
BEGIN

	IF @in_customer_login IS NULL
	BEGIN	
		THROW 52000, 'The above parameters must be determined', 1;
	END

-- ==========================================================================
-- DECLARE AND INITITIALIZE LOCAL PARAMTERS
-- ==========================================================================

		DECLARE @l_customer_type_id BIGINT = @in_customer_type_id;
		DECLARE @l_first_name NVARCHAR(200) = @in_first_name;
		DECLARE @l_last_name NVARCHAR(200) = @in_last_name;
		DECLARE @l_customer_login NVARCHAR(200) = @in_customer_login;
		DECLARE @l_exec_user_name NVARCHAR(200) = @in_exec_user_name;

-- ==========================================================================
-- INSERTING DATA TO THE TABLE
-- ==========================================================================

		BEGIN TRANSACTION;

			INSERT INTO cust.customer (customer_type_id, first_name, last_name, customer_login,
									   row_added_by, row_added_date, row_updt_by, row_updt_date)

			VALUES (@l_customer_type_id, @l_first_name, @l_last_name, @l_customer_login,
					@l_exec_user_name, GETDATE(), @l_exec_user_name, GETDATE());

		COMMIT TRANSACTION;

END;

-- ==========================================================================
-- Procedure: cust.prc_edit_customer
-- Description: Editing customer data in the customer table
-- Author: Bartosz Caban
-- ==========================================================================

CREATE OR ALTER PROCEDURE cust.prc_edit_customer (
	@in_customer_id BIGINT,
	@in_customer_type_id BIGINT,
	@in_first_name NVARCHAR(200),
	@in_last_name NVARCHAR(200),
	@in_customer_login NVARCHAR(200),
	@in_exec_user_name NVARCHAR(200)
)

AS 
BEGIN

	IF @in_customer_id IS NULL OR @in_customer_login IS NULL
	BEGIN 
		THROW 52000, 'The above parameters must be determined.', 1;
	END

-- ==========================================================================
-- DECLARE AND INITITIALIZE LOCAL PARAMTERS
-- ==========================================================================

		DECLARE @l_customer_id BIGINT = @in_customer_id;
		DECLARE @l_customer_type_id BIGINT = @in_customer_type_id;
		DECLARE @l_first_name NVARCHAR(200) = @in_first_name;
		DECLARE @l_last_name NVARCHAR(200) = @in_last_name;
		DECLARE @l_cusomter_login NVARCHAR(200) = @in_customer_login;
		DECLARE @l_exec_user_name NVARCHAR(200) = @in_exec_user_name;

-- ==========================================================================
-- UPDATING DATA TO THE TABLE
-- ==========================================================================

		BEGIN TRANSACTION; 

			UPDATE cust.customer
			SET 
				customer_type_id = @l_customer_type_id,
				first_name = @l_first_name,
				last_name = @l_last_name,
				customer_login = @l_cusomter_login,
				row_updt_by = @l_exec_user_name,
				row_updt_date = GETDATE()
			WHERE 
				customer_id = @l_customer_id;

		COMMIT TRANSACTION;

END;

-- ==========================================================================
-- Procedure: cust.prc_rmv_customer
-- Description: Deleting customer data in the customer table
-- Author: Bartosz Caban
-- ==========================================================================

CREATE OR ALTER PROCEDURE cust.prc_rmv_customer (
	@in_customer_id BIGINT
)

AS 
BEGIN

	IF @in_customer_id IS NULL
	BEGIN 
		THROW 52000, 'The above parameters must be determined.', 1;
	END

-- ==========================================================================
-- DECLARE AND INITITIALIZE LOCAL PARAMTERS
-- ==========================================================================

		DECLARE @l_customer_id BIGINT = @in_customer_id;

-- ==========================================================================
-- DELETING DATA FROM THE TABLE
-- ==========================================================================

		BEGIN TRANSACTION;

			DELETE
			FROM cust.customers
			WHERE customer_id = @l_customer_id;

			DELETE 
			FROM cust.customer_contact
			WHERE customer_id = @l_customer_id;

			DELETE 
			FROM cust.addresses
			WHERE customer_id = @l_customer_id;

			DELETE 
			FROM ord.orders
			WHERE customer_id = @l_customer_id;

			DELETE 
			FROM ord.reviews
			WHERE customer_id = @l_customer_id;

			DELETE 
			FROM ord.shopping_cart
			WHERE customer_id = @l_customer_id;

			COMMIT TRANSACTION;

END;

-- ==========================================================================
-- CREATING A SCOPE CREDENTIAL FROM AZURE
-- ==========================================================================

CREATE DATABASE SCOPED CREDENTIAL azurecred
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 
'sv=2022-11-02&ss=bfqt&srt=sco&sp=rwdlacupiytfx&se=2025-12-08T03:26:19Z&st=2023-12-07T19:26:19Z&spr=https&sig=vuYAp%2B1ZHQIyeILg4uRbauNes%2F%2B4Fp2eGYvJQi8O5TI%3D';

-- ==========================================================================
-- CREATING AN EXTERNAL DATA SOURCE
-- ==========================================================================

CREATE EXTERNAL DATA SOURCE products
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://devintrlfilestrg.blob.core.windows.net/products',
    CREDENTIAL = azurecred
);

-- ==========================================================================
-- Procedure: prc_etl_prod_load 
-- Description: Loading data from a CSV file from Azure Blob into Azure SQL Database
-- Author: Bartosz Caban
-- ==========================================================================

CREATE OR ALTER PROCEDURE prc_etl_prod_load 
(
	@in_customer_id BIGINT
	,@in_file_uri NVARCHAR(MAX)
)

AS
BEGIN 

-- ==========================================================================
-- DECLARE LOCAL PARAMTERS
-- ==========================================================================

	DECLARE @l_customer_id BIGINT;
	DECLARE @l_file_uri NVARCHAR(MAX);
	DECLARE @l_count INT;
	DECLARE @l_sql NVARCHAR(MAX);
	DECLARE @l_tmp_table_name NVARCHAR(200);

-- ==========================================================================
-- INITITIALIZE LOCAL PARAMTERS
-- ==========================================================================

	SET @in_customer_id = @l_customer_id;
	SET @in_file_uri = @l_file_uri;

-- ==========================================================================
-- PREPARING STAGE OBJECTS
-- ==========================================================================

	DELETE FROM stage.stg_prod
	WHERE customer_id = @l_customer_id;

-- ==========================================================================
-- LOAD DATA TO TMP LOAD OBJECT
-- ==========================================================================

	SET @l_tmp_table_name = 'tmp_' + CONVERT(NVARCHAR, @l_customer_id) + '_prod_load_tbl';

	SELECT @l_count = COUNT(*)
	FROM sys.tables
	WHERE NAME = @l_tmp_table_name

	IF @l_count > 0
	BEGIN

		SET @l_sql = 'DROP TABLE ' + @l_tmp_table_name + ';'
		EXECUTE(@l_sql)

	END

-- ==========================================================================
-- CREATE TEMP TABLE
-- ==========================================================================

	SET @l_sql = 
		'CREATE TABLE ' + @l_tmp_table_name + ' (
		[product_id] [NVARCHAR](MAX) NULL,
		[product_name] [NVARCHAR](MAX) NULL,
		[sku] [NVARCHAR](MAX) NULL,
		[price] [NVARCHAR](MAX) NULL,
		[product_description] [NVARCHAR](MAX) NULL,
		[stock_quantity] [NVARCHAR](MAX) NULL)';

	EXECUTE(@l_sql)

-- ==========================================================================
-- LOAD DATA TO TEMP TABLE
-- ==========================================================================

	SET @l_sql =
		'BULK INSERT ' + @l_tmp_table_name +
		' FROM ' + @l_file_uri + 
		' WITH
			(DATA_SOURCE = ''products'',
			FORMAT = ''csv'',
			FIRSTROW = 2,
			CODEPAGE = ''65001'',
			FIELDTERMINATOR = ''&|&'',  
			ROWTERMINATOR = ''0x0A'' )';

	EXECUTE(@l_sql)

-- ==========================================================================
-- LOAD DATA TO STAGE
-- ==========================================================================

	SET @l_sql = 
		N' INSERT INTO stage.stg_prod
		SELECT ' + CONVERT(NVARCHAR, @l_customer_id) + N' AS customer_id,
		CAST(product_id AS BIGINT) AS product_id,
		CAST(product_name AS NVARCHAR(200)) AS product_name,
		CAST(sku AS NVARCHAR(250)) AS sku,
		CAST(price AS DECIMAL(10, 2)) AS price,
		CAST(product_description AS NVARCHAR(MAX)) AS product_description,
		CAST(product_quantity AS BIGINT) AS product_quantity' 
		+ N' FROM' + @l_tmp_table_name;

	EXECUTE(@l_sql)

-- ==========================================================================
-- LOAD DATA TO TARGET TABLE
-- ==========================================================================

	MERGE INTO calc.prod_price_month AS trgt
	USING (
		SELECT
			product_id
			,product_name
			,sku
			,price
			,product_description
			,stock_quantity
		FROM stage.stg_prod) AS src
	ON trgt.product_id = src.product_id
	WHEN MATCHED THEN
	UPDATE SET
		trgt.product_name = src.product_name,
		trgt.sku = src.sku,
		trgt.price = src.price,
		trgt.product_description = src.product_description,
		trgt.stock_quantity = src.stock_quantity;


	IF @l_count > 0
	BEGIN

		SET @l_sql = 'DROP TABLE ' + @l_tmp_table_name + ';'
		EXECUTE(@l_sql)

	END

END;
