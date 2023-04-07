/* Explore data to determine usable informations */
SELECT * 
FROM sales.customers

SELECT * 
FROM sales.order_items

SELECT * 
FROM sales.orders

SELECT * 
FROM sales.staffs

SELECT * 
FROM sales.stores

SELECT * 
FROM production.brands

SELECT * 
FROM production.categories

SELECT * 
FROM production.products

SELECT * 
FROM production.stocks



/*Extract Required information for Analysis and Visualisation */


SELECT 
	so.order_id,
	so.order_date,
	sc.city,
	sc.state,
	CONCAT(sc.first_name,' ',sc.last_name) AS "Customer Name",
	so.store_id,
	ss.store_name,
	so.staff_id,
	CONCAT(sta.first_name,' ',sta.last_name) AS "Sales Rep",
	pp.product_name,
	pc.category_name AS "Product Category",
	SUM(soi.quantity) AS "Quantity Sold",
	SUM(soi.quantity * soi.list_price) AS "Total Sales"
FROM
	sales.orders so
JOIN 
	sales.customers sc
ON 
	so.customer_id = sc.customer_id
JOIN
	sales.order_items soi
ON
	so.order_id = soi.order_id
JOIN
	production.products pp
ON
	soi.product_id = pp.product_id
JOIN
	production.categories pc
ON
	pp.category_id = pc.category_id
JOIN
	sales.stores ss
ON
	so.store_id = ss.store_id
JOIN
	sales.staffs sta
ON
	so.staff_id = sta.staff_id
GROUP BY
	so.order_id,
	so.order_date,
	sc.city,
	sc.state,
	CONCAT(sc.first_name,' ',sc.last_name),
	so.store_id,
	so.staff_id,
	pp.product_name,
	pc.category_name,
	ss.store_name,
	CONCAT(sta.first_name,' ',sta.last_name)