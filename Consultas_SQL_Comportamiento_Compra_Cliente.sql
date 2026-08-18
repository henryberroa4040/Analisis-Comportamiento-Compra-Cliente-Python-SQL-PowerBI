--P1. ¿Cuál es el ingreso total generado por clientes hombres frente a clientas mujeres?
select gender, SUM(purchase_amount) as revenue
from customer
group by gender

--P2. ¿Qué clientes utilizaron un descuento pero aun así gastaron más que el importe medio de compra?
select customer_id, purchase_amount 
from customer
where discount_applied= 'yes' and purchase_amount >= (select AVG(purchase_amount) from customer)

--P3. ¿Cuáles son los 5 productos con la calificación promedio de reseñas más alta?
select top 5 item_purchased, ROUND(AVG(review_rating),2) as "Promedio de reseña de producto"
from customer
group by item_purchased
order by AVG(review_rating) desc

--P4. Compare los importes promedio de compra entre el envío estándar y el envío exprés.
select shipping_type,
AVG(purchase_amount)
from customer
where shipping_type in ('Standard','Express')
group by shipping_type

--P5. ¿Gastan más los clientes suscritos? Compare el gasto promedio y los ingresos totales entre suscriptores y no suscriptores.

select subscription_status,
COUNT(customer_id) as cliente_totales,
ROUND(AVG(CAST(purchase_amount AS DECIMAL (10,2))),2) as promedio_gastado,
ROUND(SUM(purchase_amount),2) as importe_gastado
from customer
group by subscription_status
order by cliente_totales, promedio_gastado desc;


--P6. ¿Cuáles son los 5 productos con el mayor porcentaje de compras con descuentos aplicados?
SELECT TOP 5 item_purchased,
ROUND(100 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) as porcentaje_decuento
from customer
group by item_purchased
order by porcentaje_decuento desc

--P7. Clasifique a los clientes en nuevos, recurrentes y leales según el número total de compras anteriores y muestre el recuento de cada segmento.
with tipos_clientes as (
select customer_id, previous_purchases,
case
	when previous_purchases = 1 then 'Nuevos'
	when previous_purchases between 2 and 10 then 'Recurrentes'
	else 'Leales'
	end as segmentos_cliente
from customer
)
select segmentos_cliente, COUNT(*) as 'Numero de clientes'
from tipos_clientes
group by segmentos_cliente

--P8. ¿Cuáles son los 3 productos más comprados dentro de cada categoría?
with conteo_articulo as (
select category, item_purchased,
COUNT(customer_id) as pedidos_totales,
ROW_NUMBER() over(partition by category order by COUNT(customer_id) desc) as top_articulos
from customer
group by category, item_purchased
)
select top_articulos, category, item_purchased, pedidos_totales
from conteo_articulo
where top_articulos <=3

--P9. ¿Es probable que los clientes que repiten compra (más de 5 compras anteriores) también se suscriban?

select subscription_status,
COUNT(customer_id) as compradores_habituales
from customer
where previous_purchases >5
group by subscription_status

--P10. ¿Cuál es la contribución a los ingresos de cada grupo de edad?

select age_group,
SUM(purchase_amount) as ingresos_totales
from customer
group by age_group
order by ingresos_totales desc