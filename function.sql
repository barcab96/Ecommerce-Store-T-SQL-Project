-- ==========================================================================
-- Procedure: ord.fn_calculate_order_sum 
-- Description: A function that calculates the value of an order
-- Author: Bartosz Caban
-- ==========================================================================

CREATE OR ALTER FUNCTION ord.fn_calculate_order_sum 
(
	@in_order_id INT

)

RETURNS DECIMAL(10, 2)

AS
BEGIN

	DECLARE @l_order_id INT = @in_order_id;
	DECLARE @l_total DECIMAL(10, 2)

	SELECT @l_total = SUM(quantity * unit_price)
	FROM ord.order_details
	WHERE order_details_id = @l_order_id;

	RETURN ISNULL(@l_total, 0);

END;

CREATE OR ALTER PROCEDURE ord.prc_calculate_order_sum
(
	@in_order_id INT
)

AS
BEGIN 

	DECLARE @l_order_id INT = @in_order_id;

		UPDATE ord.order_details
		SET price = ord.fn_calculate_order_sum(order_details_id)
		WHERE order_details_id = @l_order_id;

END;

-- ==========================================================================
-- Procedure: ord.fn_get_average_product_rating 
-- Description: A function that determines the average rating of a product
-- Author: Bartosz Caban
-- ==========================================================================

CREATE OR ALTER FUNCTION ord.fn_get_average_product_rating
(
	@in_product_id BIGINT
)

RETURNS DECIMAL(3, 2)

AS
BEGIN

	DECLARE @l_average_rating DECIMAL(3, 2);
	DECLARE @l_product_id BIGINT;

	SET @l_product_id = @in_product_id;

		SELECT @l_average_rating = AVG(rating)
		FROM ord.reviews
		WHERE product_id = @l_product_id;

	RETURN ISNULL(@l_average_rating, 0);

END;

-- ==========================================================================
-- Procedure: prod.fn_top_selling_products
-- Description: A function that returns the best-selling products
-- Author: Bartosz Caban
-- ==========================================================================

CREATE OR ALTER FUNCTION prod.fn_top_selling_products
(
	@in_top_count BIGINT
)

RETURNS TABLE
AS
		
RETURN
(
	
	SELECT TOP (@in_top_count) p.product_id, p.product_name, p.price, p.product_description, p.stock_quantity,  SUM(od.quantity) AS total_sold
	FROM prod.products AS p
	INNER JOIN ord.order_details AS od ON p.product_id = od.product_id
	GROUP BY p.product_id, p.product_name, p.price, p.product_description, p.stock_quantity
	ORDER BY total_sold DESC

);
