drop procedure if exists sp_build_mail; 
drop procedure if exists sp_cancel_order; 
drop procedure if exists sp_get_all_products; 
drop procedure if exists sp_get_initial_app_state; 
drop procedure if exists sp_get_last_orderid; 
drop procedure if exists sp_create_orders; 
drop procedure if exists sp_get_product_classes; 
drop procedure if exists sp_get_user_last_order; 
drop procedure if exists sp_get_user_order_list; 
drop procedure if exists sp_search_products; 
drop procedure if exists sp_store_info; 

DELIMITER $$
CREATE   PROCEDURE `sp_build_mail`( uuid char(36), last_order int, email VARCHAR(50) )
BEGIN

declare mailHtml_part1 mediumtext ;
declare mailHtml_part2 mediumtext ;
declare mailHtml_part3 mediumtext ;
declare order_sum decimal(14,2);
declare store_mail varchar(100);
declare store_name varchar(100);
declare store_address varchar(100);
declare store_phone varchar(100);
declare store_delivery_company varchar(100);

select s.store_mail,s.store_name,s.store_address,s.store_phone,s.store_delivery_company 
into store_mail,store_name,store_address,store_phone,store_delivery_company  from tbl_store_info s;

select sum(p.price * o.product_quantity) as os into order_sum
                       from tbl_orders  o 
                      left join tbl_products p on p.id = o.product_id 
                      where o.email = email  and o.order_id = last_order and storno <> 1 ;
SET group_concat_max_len = 20480;
                      
                      
select GROUP_CONCAT('
<h2>ID porudžbine: ',uuid,'</h2>
<h2>Ukupna cena: ',round(order_sum,2),' RSD</h2>
<table>
<thead>
<tr>
</tr>
<tr>
<th style=" width: 100px; text-align: left;">Proizvod</th>
<th style=" width: 100px;text-align: left;">Kolièina</th>
<th style=" width: 100px;text-align: left;">Cena</th>
<th style=" width: 100px;text-align: left;">Cena po kolièini</th>
</tr>
</thead><tbody> ') as Html into mailHtml_part1;


select GROUP_CONCAT('<tr>
<td><h3>',p.name,'</h3></td>   
<td><h3>', round( o.product_quantity,2) ,'</h3></td>
<td><h3>',round(p.price,2) ,'</h3></td>
<td><h3>',round((p.price * o.product_quantity),2),'</h3></td>
</tr>' SEPARATOR '') as Html  into mailHtml_part2
                       from tbl_orders  o 
                      left join tbl_products p on p.id = o.product_id 
                      where o.email = email  and o.order_id = last_order and storno <> 1 ;
                      
select GROUP_CONCAT('
                 <p>Porudžbinu možete otkazati u roku od 24 sata</p>
                  <a href="http://localhost:3000/alerts?uuid=',uuid,'&email=',email,'">
  <button>Cancel order</button></a>
                 <p>Vaša porudžbina æe biti dostavljena kurirskom službom ',store_delivery_company,'</p>
                 <tr><td><h2>Kontakt</h2></td></tr>
                 <tr>
                  <td>Adresa: ',store_address,';</td><br /> 
                  <td>Telefon: ',store_phone,';</td><br />
                  <td>Email: ',store_mail,';</td><br />    
                  </tr>') as html into mailHtml_part3;

select GROUP_CONCAT(mailHtml_part1,mailHtml_part2, mailHtml_part3,'</tbody></table>') as mailHtml ;

END$$
 

 
CREATE   PROCEDURE `sp_cancel_order`(uuid_in char(40))
BEGIN 
declare created_check datetime; declare storno_check int; 
declare mailText varchar(1000);

SET group_concat_max_len = 2048;

select created, storno, GROUP_CONCAT('Otkazana porudžbina ID: ',uuid,'; Poruèioc: ',Firstname,' ',Lastname) into created_check,storno_check,mailText
from tbl_orders where uuid = uuid_in limit 1;
if( storno_check <> 1) then if (created_check > DATE_ADD(now(), INTERVAL -1 day) ) then
update tbl_orders set storno = 1, updated = now() where uuid = uuid_in;
select 1 as result, 'order canceled sucesfuly' as msg,mailText;
ELSE select 0 as result,"24 hours have passed from your order, you can't cancel now" as msg;
end if; 
ELSE select 0 as result, 'Allredy canceled' as msg; end if; 
end$$
 

 
CREATE   PROCEDURE `sp_get_all_products`()
BEGIN
select p.id, p.class_id,p.name,p.description,p.price,p.image,
p.created,p.updated,p.class_id, 
CAST(p.snizenje=p.snizenje AS SIGNED INTEGER) as snizenje ,p.metric_unit_id,
p.img_path_list  , mu.metric_unit,mu.min_qty,mu.piece from tbl_products p 
left join tbl_metric_unit mu on mu.id = p.metric_unit_id;
end$$
 

 
CREATE   PROCEDURE `sp_get_initial_app_state`()
BEGIN 
call sp_get_product_classes(); 
call sp_get_all_products();
select * from  tbl_slider_images ;
END$$
 

 
CREATE   PROCEDURE `sp_get_last_orderid`()
BEGIN

declare last_order int;
set last_order = 0;
select order_id into last_order from tbl_orders  order by order_id desc limit 1;
select last_order, uuid() as uuid;

END$$
 

 
CREATE   PROCEDURE `sp_create_orders`(order_id int,
product_id int,
product_quantity decimal(14,4),
Firstname varchar(50),
Lastname varchar(50),
PravnoLice varchar(100),
phone varchar(50),
Grad varchar(50),
Ulica varchar(50),
Drzava varchar(50), 
email varchar(50),
uuid char(36))
BEGIN



insert into tbl_orders(order_id,product_id,product_quantity, Firstname,Lastname,PravnoLice,
                    	phone,Grad,Ulica,Drzava,email, created,updated,uuid)
values(order_id,product_id,product_quantity, Firstname,Lastname,PravnoLice,
       phone,Grad,Ulica,Drzava,email,NOW(),NOW(),uuid);


end$$
 

 
CREATE   PROCEDURE `sp_get_product_classes`()
begin 
select * from tbl_product_class;
end$$
 

 
CREATE   PROCEDURE `sp_get_user_last_order`(uuid char(36),last_order int, email VARCHAR(50))
BEGIN 




select p.name as pruduct_name,o.product_quantity,p.price as product_price,(p.price * o.product_quantity) as quantity_price,o.uuid from tbl_orders  o 
left join tbl_products p on p.id = o.product_id 
where o.email = email  and o.order_id = last_order and storno <> 1 and o.UUID = uuid ;

call sp_build_mail( uuid ,last_order ,email);


END$$
 

 
CREATE   PROCEDURE `sp_get_user_order_list`(uuid char(36))
BEGIN


select p.*,o.product_quantity as quantity,o.UUID from tbl_orders  o 
left join tbl_products p on p.id = o.product_id 
where  o.UUID = UUID and storno <> 1 ;

end$$
 

 
CREATE   PROCEDURE `sp_search_products`(searchString varchar(256))
BEGIN 

select name,id from tbl_products where POSITION(searchString IN name) <> 0 ; 
end$$
 

 
CREATE   PROCEDURE `sp_store_info`()
BEGIN

select id,store_address,store_mail,store_name,store_delivery_company,store_phone from tbl_store_info;

END$$
 
