-- phpMyAdmin SQL Dump
-- version 4.8.5
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 30, 2019 at 04:52 PM
-- Server version: 10.1.40-MariaDB
-- PHP Version: 7.1.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `lbta_mysql`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`` PROCEDURE `sp_build_mail` (`uuid` CHAR(36), `last_order` INT, `email` VARCHAR(50))  BEGIN

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
<th style=" width: 100px;text-align: left;">Količina</th>
<th style=" width: 100px;text-align: left;">Cena</th>
<th style=" width: 100px;text-align: left;">Cena po količini</th>
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
                 <p>Vaša porudžbina će biti dostavljena kurirskom službom ',store_delivery_company,'</p>
                 <tr><td><h2>Kontakt</h2></td></tr>
                 <tr>
                  <td>Adresa: ',store_address,';</td><br /> 
                  <td>Telefon: ',store_phone,';</td><br />
                  <td>Email: ',store_mail,';</td><br />    
                  </tr>') as html into mailHtml_part3;

select GROUP_CONCAT(mailHtml_part1,mailHtml_part2, mailHtml_part3,'</tbody></table>') as mailHtml ;

END$$

CREATE DEFINER=`` PROCEDURE `sp_cancel_order` (`uuid_in` CHAR(40))  BEGIN 
declare created_check datetime; declare storno_check int; 
declare mailText varchar(1000);

SET group_concat_max_len = 2048;

select created, storno, GROUP_CONCAT('Otkazana porudžbina ID: ',uuid,'; Poručioc: ',Firstname,' ',Lastname) into created_check,storno_check,mailText
from tbl_orders where uuid = uuid_in limit 1;
if( storno_check <> 1) then if (created_check > DATE_ADD(now(), INTERVAL -1 day) ) then
update tbl_orders set storno = 1, updated = now() where uuid = uuid_in;
select 1 as result, 'order canceled sucesfuly' as msg,mailText;
ELSE select 0 as result,"24 hours have passed from your order, you can't cancel now" as msg;
end if; 
ELSE select 0 as result, 'Allredy canceled' as msg; end if; 
end$$

CREATE DEFINER=`` PROCEDURE `sp_create_orders` (`order_id` INT, `product_id` INT, `product_quantity` DECIMAL(14,4), `Firstname` VARCHAR(50), `Lastname` VARCHAR(50), `PravnoLice` VARCHAR(100), `phone` VARCHAR(50), `Grad` VARCHAR(50), `Ulica` VARCHAR(50), `Drzava` VARCHAR(50), `email` VARCHAR(50), `uuid` CHAR(36))  BEGIN



insert into tbl_orders(order_id,product_id,product_quantity, Firstname,Lastname,PravnoLice,
                    	phone,Grad,Ulica,Drzava,email, created,updated,uuid)
values(order_id,product_id,product_quantity, Firstname,Lastname,PravnoLice,
       phone,Grad,Ulica,Drzava,email,NOW(),NOW(),uuid);


end$$

CREATE DEFINER=`` PROCEDURE `sp_get_all_products` ()  BEGIN
select p.id, p.class_id,p.name,p.description,p.price,p.image,
p.created,p.updated,p.class_id, 
CAST(p.snizenje=p.snizenje AS SIGNED INTEGER) as snizenje ,p.metric_unit_id,
p.img_path_list  , mu.metric_unit,mu.min_qty,mu.piece from tbl_products p 
left join tbl_metric_unit mu on mu.id = p.metric_unit_id;
end$$

CREATE DEFINER=`` PROCEDURE `sp_get_initial_app_state` ()  BEGIN 
call sp_get_product_classes(); 
call sp_get_all_products();
select * from  tbl_slider_images ;
END$$

CREATE DEFINER=`` PROCEDURE `sp_get_last_orderid` ()  BEGIN

declare last_order int;
set last_order = 0;
select order_id into last_order from tbl_orders  order by order_id desc limit 1;
select last_order, uuid() as uuid;

END$$

CREATE DEFINER=`` PROCEDURE `sp_get_product_classes` ()  begin 
select * from tbl_product_class;
end$$

CREATE DEFINER=`` PROCEDURE `sp_get_user_last_order` (`uuid` CHAR(36), `last_order` INT, `email` VARCHAR(50))  BEGIN 




select p.name as pruduct_name,o.product_quantity,p.price as product_price,(p.price * o.product_quantity) as quantity_price,o.uuid from tbl_orders  o 
left join tbl_products p on p.id = o.product_id 
where o.email = email  and o.order_id = last_order and storno <> 1 and o.UUID = uuid ;

call sp_build_mail( uuid ,last_order ,email);


END$$

CREATE DEFINER=`` PROCEDURE `sp_get_user_order_list` (`uuid` CHAR(36))  BEGIN


select p.*,o.product_quantity as quantity,o.UUID from tbl_orders  o 
left join tbl_products p on p.id = o.product_id 
where  o.UUID = UUID and storno <> 1 ;

end$$

CREATE DEFINER=`` PROCEDURE `sp_search_products` (`searchString` VARCHAR(256))  BEGIN 

select name,id from tbl_products where POSITION(searchString IN name) <> 0 ; 
end$$

CREATE DEFINER=`` PROCEDURE `sp_store_info` ()  BEGIN

select id,store_address,store_mail,store_name,store_delivery_company,store_phone from tbl_store_info;

END$$

--
-- Functions
--
CREATE DEFINER=`` FUNCTION `fn_get_last_orderid` () RETURNS INT(11) BEGIN
declare last_order int;
set last_order = 0;
select order_id into last_order from tbl_orders order by order_id desc limit 1;
return last_order;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_metric_unit`
--

CREATE TABLE IF NOT EXISTS `tbl_metric_unit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `metric_unit` varchar(100) CHARACTER SET cp1250 COLLATE cp1250_croatian_ci DEFAULT NULL,
  `min_qty` decimal(14,4) DEFAULT NULL,
  `piece` int(11) DEFAULT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `tbl_metric_unit`
--

INSERT INTO `tbl_metric_unit` (`id`, `metric_unit`, `min_qty`, `piece`) VALUES
(1, 'meter', '1.5000', 0),
(2, 'square_meter', '1.0000', 0),
(3, 'piece', '1.0000', 1);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_orders`
--

CREATE TABLE IF NOT EXISTS `tbl_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) DEFAULT NULL,
  `email` varchar(50) COLLATE cp1250_croatian_ci DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `product_quantity` decimal(14,4) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `UUID` char(36) COLLATE cp1250_croatian_ci DEFAULT NULL,
  `storno` bit(1) DEFAULT b'0',
  `Firstname` varchar(50) COLLATE cp1250_croatian_ci DEFAULT NULL,
  `Lastname` varchar(50) COLLATE cp1250_croatian_ci DEFAULT NULL,
  `PravnoLice` varchar(100) COLLATE cp1250_croatian_ci DEFAULT NULL,
  `phone` varchar(50) COLLATE cp1250_croatian_ci DEFAULT NULL,
  `Grad` varchar(50) COLLATE cp1250_croatian_ci DEFAULT NULL,
  `Ulica` varchar(50) COLLATE cp1250_croatian_ci DEFAULT NULL,
  `Drzava` varchar(50) COLLATE cp1250_croatian_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UC_Product_Order` (`product_id`,`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=523 DEFAULT CHARSET=cp1250 COLLATE=cp1250_croatian_ci;

--
-- Dumping data for table `tbl_orders`
--

INSERT INTO `tbl_orders` (`id`, `order_id`, `email`, `product_id`, `product_quantity`, `created`, `updated`, `UUID`, `storno`, `Firstname`, `Lastname`, `PravnoLice`, `phone`, `Grad`, `Ulica`, `Drzava`) VALUES
(295, 1, 'maricic92marko@gmail.com', 1, '2.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', '17618b7e-8c4b-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(296, 1, 'maricic92marko@gmail.com', 2, '2.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', '17618b7e-8c4b-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(297, 1, 'maricic92marko@gmail.com', 3, '2.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', '17618b7e-8c4b-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(298, 2, 'maricic92marko@gmail.com', 1, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', '2ef12d49-8c4b-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(299, 2, 'maricic92marko@gmail.com', 3, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', '2ef12d49-8c4b-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(300, 2, 'maricic92marko@gmail.com', 2, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', '2ef12d49-8c4b-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(301, 3, 'maricic92marko@gmail.com', 1, '2.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', '863fc92a-8c4d-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(302, 3, 'maricic92marko@gmail.com', 2, '2.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', '863fc92a-8c4d-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(303, 4, 'maricic92marko@gmail.com', 2, '5.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'e629f40f-8c4d-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(304, 4, 'maricic92marko@gmail.com', 1, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'e629f40f-8c4d-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(305, 4, 'maricic92marko@gmail.com', 3, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'e629f40f-8c4d-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(306, 5, 'maricic92marko@gmail.com', 3, '2.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'e0855eef-8c51-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(307, 5, 'maricic92marko@gmail.com', 2, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'e0855eef-8c51-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(308, 5, 'maricic92marko@gmail.com', 1, '2.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'e0855eef-8c51-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(309, 6, 'maricic92marko@gmail.com', 1, '2.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'a0078676-8c65-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(310, 6, 'maricic92marko@gmail.com', 2, '2.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'a0078676-8c65-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(321, 1, 'maricic92marko@gmail.com', 4, '9.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'ac39ca79-8c6f-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(322, 1, 'maricic92marko@gmail.com', 5, '9.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'ac39ca79-8c6f-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(326, 2, 'maricic92marko@gmail.com', 4, '5.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', '1c38f618-8c70-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(327, 2, 'maricic92marko@gmail.com', 5, '5.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', '1c38f618-8c70-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(328, 3, 'maricic92marko@gmail.com', 3, '2.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'e6865dca-8c70-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(331, 3, 'maricic92marko@gmail.com', 5, '2.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'e6865dca-8c70-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(332, 3, 'maricic92marko@gmail.com', 4, '2.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'e6865dca-8c70-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(333, 7, 'maricic92marko@gmail.com', 2, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'd9a22449-8c72-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(334, 7, 'maricic92marko@gmail.com', 1, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'd9a22449-8c72-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(335, 7, 'maricic92marko@gmail.com', 3, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'd9a22449-8c72-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(336, 7, 'maricic92marko@gmail.com', 4, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'd9a22449-8c72-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(337, 7, 'maricic92marko@gmail.com', 5, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'd9a22449-8c72-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(338, 8, 'maricic92marko@gmail.com', 1, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', '28b5af56-8c74-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(339, 8, 'maricic92marko@gmail.com', 2, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', '28b5af56-8c74-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(340, 8, 'maricic92marko@gmail.com', 3, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', '28b5af56-8c74-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(341, 9, 'maricic92marko@gmail.com', 1, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', '6cd3c117-8c74-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(342, 9, 'maricic92marko@gmail.com', 2, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', '6cd3c117-8c74-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(343, 10, 'maricic92marko@gmail.com', 2, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'b7a3bef0-8c76-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(344, 10, 'maricic92marko@gmail.com', 3, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'b7a3bef0-8c76-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(345, 10, 'maricic92marko@gmail.com', 5, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'b7a3bef0-8c76-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(346, 10, 'maricic92marko@gmail.com', 4, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'b7a3bef0-8c76-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(347, 10, 'maricic92marko@gmail.com', 1, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'b7a3bef0-8c76-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(348, 11, 'maricic92marko@gmail.com', 1, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', '380006cb-8c77-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(349, 11, 'maricic92marko@gmail.com', 2, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', '380006cb-8c77-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(350, 11, 'maricic92marko@gmail.com', 3, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', '380006cb-8c77-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(351, 11, 'maricic92marko@gmail.com', 4, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', '380006cb-8c77-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(352, 11, 'maricic92marko@gmail.com', 5, '1.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', '380006cb-8c77-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(353, 12, 'maricic92marko@gmail.com', 1, '8.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'faeed466-8c7b-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(354, 12, 'maricic92marko@gmail.com', 2, '8.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'faeed466-8c7b-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(355, 12, 'maricic92marko@gmail.com', 3, '8.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'faeed466-8c7b-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(356, 12, 'maricic92marko@gmail.com', 4, '8.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'faeed466-8c7b-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(357, 12, 'maricic92marko@gmail.com', 5, '8.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', 'faeed466-8c7b-11e9-8cde-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(358, 13, 'maricic92marko@gmail.com', 1, '2.0000', '2019-06-11 15:45:22', '0000-00-00 00:00:00', '13905625-8d05-11e9-9822-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(359, 14, 'maricic92marko@gmail.com', 1, '1.0000', '2019-06-11 15:45:22', '2019-06-12 14:10:50', 'f05eca5b-8d05-11e9-9822-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(360, 15, 'maricic92marko@gmail.com', 1, '1.0000', '2019-06-11 15:45:22', '2019-06-12 14:18:37', '2e7ca122-8d0c-11e9-9822-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(361, 16, 'maricic92marko@gmail.com', 1, '7.0000', '2019-06-11 15:45:22', '2019-06-12 14:44:38', 'd750b157-8d0f-11e9-9822-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(362, 16, 'maricic92marko@gmail.com', 2, '7.0000', '2019-06-11 15:45:22', '2019-06-12 14:44:39', 'd750b157-8d0f-11e9-9822-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(363, 16, 'maricic92marko@gmail.com', 3, '7.0000', '2019-06-11 15:45:22', '2019-06-12 14:44:39', 'd750b157-8d0f-11e9-9822-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(364, 17, 'maricic92marko@gmail.com', 1, '1.0000', '2019-06-11 15:45:22', '2019-06-12 14:53:19', 'fd879edd-8d10-11e9-9822-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(365, 18, 'maricic92marko@gmail.com', 1, '1.0000', '2019-06-11 15:45:22', '2019-06-12 15:22:55', '20a3dba1-8d15-11e9-9822-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(366, 19, 'maricic92marko@gmail.com', 1, '1.0000', '2019-06-11 15:45:22', '2019-06-12 15:30:43', '4e33733a-8d15-11e9-9822-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(367, 19, 'maricic92marko@gmail.com', 2, '1.0000', '2019-06-11 15:45:22', '2019-06-12 15:30:43', '4e33733a-8d15-11e9-9822-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(368, 20, 'maricic92marko@gmail.com', 2, '1.0000', '2019-06-11 15:45:22', '2019-06-12 15:38:51', '6a24f23b-8d17-11e9-9822-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(369, 20, 'maricic92marko@gmail.com', 1, '2.0000', '2019-06-11 15:45:22', '2019-06-12 15:38:51', '6a24f23b-8d17-11e9-9822-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(370, 20, 'maricic92marko@gmail.com', 3, '2.0000', '2019-06-11 15:45:22', '2019-06-12 15:38:51', '6a24f23b-8d17-11e9-9822-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(371, 21, 'maricic92marko@gmail.com', 1, '2.0000', '2019-06-11 15:45:22', '2019-06-12 15:44:30', '28413a6b-8d18-11e9-9822-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(372, 22, 'maricic92marko@gmail.com', 1, '1.0000', '2019-06-11 15:45:22', '2019-06-12 15:48:50', '8cc61fea-8d18-11e9-9822-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(373, 23, 'maricic92marko@gmail.com', 1, '2.0000', '2019-06-11 15:45:22', '2019-06-13 15:45:22', 'c3a023a1-8de0-11e9-9822-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(374, 24, 'maricic92marko@gmail.com', 1, '1.0000', '2019-06-13 16:23:40', '2019-06-13 16:23:40', 'cfde8cd3-8de6-11e9-9822-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(375, 25, 'maricic92marko@gmail.com', 1, '1.0000', '2019-06-13 16:24:27', '2019-06-13 16:24:27', 'ebbbdad1-8de6-11e9-9822-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(376, 26, 'maricic92marko@gmail.com', 1, '1.0000', '2019-06-13 16:24:45', '2019-06-13 16:25:00', 'f6d975d8-8de6-11e9-9822-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(377, 27, 'maricic92marko@gmail.com', 5, '2.0000', '2019-06-19 14:12:14', '2019-06-19 14:12:14', '78ca51a8-928b-11e9-82a4-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(378, 27, 'maricic92marko@gmail.com', 4, '4.0000', '2019-06-19 14:12:14', '2019-06-19 14:12:14', '78ca51a8-928b-11e9-82a4-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(379, 28, 'maricic92marko@gmail.com', 5, '2.0000', '2019-06-19 14:17:41', '2019-06-19 14:17:41', '3bd4a85a-928c-11e9-82a4-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(380, 28, 'maricic92marko@gmail.com', 4, '4.0000', '2019-06-19 14:17:41', '2019-06-19 14:17:41', '3bd4a85a-928c-11e9-82a4-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(381, 29, 'maricic92marko@gmail.com', 5, '2.0000', '2019-06-19 14:19:29', '2019-06-19 14:19:29', '7c10995c-928c-11e9-82a4-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(382, 29, 'maricic92marko@gmail.com', 4, '4.0000', '2019-06-19 14:19:29', '2019-06-19 14:19:29', '7c10995c-928c-11e9-82a4-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(383, 30, 'maricic92marko@gmail.com', 4, '4.0000', '2019-06-19 14:20:51', '2019-06-19 14:20:51', 'acd4c15e-928c-11e9-82a4-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(384, 30, 'maricic92marko@gmail.com', 5, '2.0000', '2019-06-19 14:20:51', '2019-06-19 14:20:51', 'acd4c15e-928c-11e9-82a4-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(385, 31, 'maricic92marko@gmail.com', 4, '4.0000', '2019-06-19 14:25:36', '2019-06-19 14:25:36', '56d6fdb0-928d-11e9-82a4-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(386, 31, 'maricic92marko@gmail.com', 5, '2.0000', '2019-06-19 14:25:36', '2019-06-19 14:25:36', '56d6fdb0-928d-11e9-82a4-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(387, 32, 'maricic92marko@gmail.com', 4, '4.0000', '2019-06-19 14:26:43', '2019-06-19 14:26:43', '7ecf6446-928d-11e9-82a4-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(388, 32, 'maricic92marko@gmail.com', 5, '2.0000', '2019-06-19 14:26:43', '2019-06-19 14:26:43', '7ecf6446-928d-11e9-82a4-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(389, 33, 'maricic92marko@gmail.com', 4, '4.0000', '2019-06-19 14:40:36', '2019-06-19 14:40:36', '6f25a345-928f-11e9-82a4-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(390, 33, 'maricic92marko@gmail.com', 5, '2.0000', '2019-06-19 14:40:36', '2019-06-19 14:40:36', '6f25a345-928f-11e9-82a4-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(391, 34, 'maricic92marko@gmail.com', 4, '4.0000', '2019-06-19 14:42:54', '2019-06-19 14:42:54', 'c1cc395e-928f-11e9-82a4-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(392, 34, 'maricic92marko@gmail.com', 5, '2.0000', '2019-06-19 14:42:54', '2019-06-19 14:42:54', 'c1cc395e-928f-11e9-82a4-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(393, 35, 'maricic92marko@gmail.com', 1, '3.0000', '2019-06-19 15:49:24', '2019-06-19 15:49:24', '0bc362d4-9299-11e9-82a4-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(394, 35, 'maricic92marko@gmail.com', 4, '9.0000', '2019-06-19 15:49:25', '2019-06-19 15:49:25', '0bc362d4-9299-11e9-82a4-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(395, 36, 'maricic92marko@gmail.com', 1, '1.0000', '2019-07-11 17:09:28', '2019-07-11 17:11:20', 'e013df8c-a3ed-11e9-8ffd-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(396, 36, 'maricic92marko@gmail.com', 4, '0.0000', '2019-07-11 17:09:28', '2019-07-11 17:11:20', 'e013df8c-a3ed-11e9-8ffd-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(397, 37, 'maricic92marko@gmail.com', 10, '4.0000', '2019-07-13 18:49:39', '2019-07-13 18:49:39', '2a740a29-a58e-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(398, 37, 'maricic92marko@gmail.com', 4, '3.0000', '2019-07-13 18:49:39', '2019-07-13 18:49:39', '2a740a29-a58e-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(399, 37, 'maricic92marko@gmail.com', 1, '3.0000', '2019-07-13 18:49:39', '2019-07-13 18:49:39', '2a740a29-a58e-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(400, 37, 'maricic92marko@gmail.com', 8, '2.0000', '2019-07-13 18:49:39', '2019-07-13 18:49:39', '2a740a29-a58e-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(401, 38, 'maricic92marko@gmail.com', 4, '2.0000', '2019-07-13 19:44:04', '2019-07-13 19:44:04', 'c4de1c72-a595-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(402, 38, 'maricic92marko@gmail.com', 8, '11.0000', '2019-07-13 19:44:04', '2019-07-13 19:44:04', 'c4de1c72-a595-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(403, 38, 'maricic92marko@gmail.com', 7, '81.0000', '2019-07-13 19:44:04', '2019-07-13 19:44:04', 'c4de1c72-a595-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(404, 39, 'maricic92marko@gmail.com', 8, '10.0000', '2019-07-13 19:45:33', '2019-07-13 19:45:33', 'f9a8dce0-a595-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(405, 40, 'maricic92marko@gmail.com', 8, '3.0000', '2019-07-13 19:50:10', '2019-07-13 19:50:10', '9ef086fe-a596-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(406, 41, 'maricic92marko@gmail.com', 6, '8.6000', '2019-07-13 19:54:02', '2019-07-13 19:54:02', '294bb5c0-a597-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(407, 42, 'maricic92marko@gmail.com', 3, '2.6000', '2019-07-14 21:16:35', '2019-07-14 21:16:35', 'cfd4be3d-a66b-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(408, 42, 'maricic92marko@gmail.com', 8, '7.7000', '2019-07-14 21:16:35', '2019-07-14 21:16:35', 'cfd4be3d-a66b-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(409, 42, 'maricic92marko@gmail.com', 5, '6.7000', '2019-07-14 21:16:35', '2019-07-14 21:16:35', 'cfd4be3d-a66b-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(410, 43, 'maricic92marko@gmail.com', 8, '4.5000', '2019-07-14 21:18:40', '2019-07-14 21:18:40', '1a7311fc-a66c-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(411, 44, 'maricic92marko@gmail.com', 14, '3.3000', '2019-07-14 21:22:11', '2019-07-14 21:22:11', '97f3f9f6-a66c-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(412, 45, 'maricic92marko@gmail.com', 1, '33.0000', '2019-07-14 21:22:56', '2019-07-14 21:22:56', 'b2f27072-a66c-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(413, 46, 'maricic92marko@gmail.com', 7, '4.8000', '2019-07-14 21:24:15', '2019-07-14 21:24:15', 'e1fb2e1a-a66c-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(414, 47, 'maricic92marko@gmail.com', 3, '2.2000', '2019-07-14 21:32:18', '2019-07-14 21:32:18', '019f3b24-a66e-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(415, 48, 'maricic92marko@gmail.com', 4, '2.0000', '2019-07-14 21:33:17', '2019-07-14 21:33:17', '24df97c7-a66e-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(416, 48, 'maricic92marko@gmail.com', 5, '3.0000', '2019-07-14 21:33:17', '2019-07-14 21:33:17', '24df97c7-a66e-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(417, 48, 'maricic92marko@gmail.com', 6, '4.0000', '2019-07-14 21:33:17', '2019-07-14 21:33:17', '24df97c7-a66e-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(418, 49, 'maricic92marko@gmail.com', 4, '2.0000', '2019-07-14 21:36:27', '2019-07-14 21:36:27', '96575b8a-a66e-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(419, 49, 'maricic92marko@gmail.com', 5, '2.0000', '2019-07-14 21:36:27', '2019-07-14 21:36:27', '96575b8a-a66e-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(420, 49, 'maricic92marko@gmail.com', 6, '2.0000', '2019-07-14 21:36:27', '2019-07-14 21:36:27', '96575b8a-a66e-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(421, 50, 'maricic92marko@gmail.com', 6, '22.0000', '2019-07-14 22:06:25', '2019-07-14 22:06:25', 'c629bb7c-a672-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(422, 50, 'maricic92marko@gmail.com', 4, '2.0000', '2019-07-14 22:06:25', '2019-07-14 22:06:25', 'c629bb7c-a672-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(423, 51, 'maricic92marko@gmail.com', 5, '4.0000', '2019-07-14 22:09:40', '2019-07-14 22:09:40', '39f198e2-a673-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(424, 51, 'maricic92marko@gmail.com', 11, '4.0000', '2019-07-14 22:09:40', '2019-07-14 22:09:40', '39f198e2-a673-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(425, 52, 'maricic92marko@gmail.com', 1, '20.0000', '2019-07-14 22:12:53', '2019-07-14 22:12:53', 'ad1c153e-a673-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(426, 53, 'maricic92marko@gmail.com', 7, '2.0000', '2019-07-14 22:14:13', '2019-07-14 22:14:13', 'dcd43101-a673-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(427, 54, 'maricic92marko@gmail.com', 1, '2.0000', '2019-07-14 22:16:17', '2019-07-14 22:16:17', '26d52fde-a674-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(428, 55, 'maricic92marko@gmail.com', 14, '5.0000', '2019-07-15 14:11:08', '2019-07-15 14:11:08', '84a66c9b-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(429, 55, 'maricic92marko@gmail.com', 6, '5.0000', '2019-07-15 14:11:08', '2019-07-15 14:11:08', '84a66c9b-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(430, 55, 'maricic92marko@gmail.com', 7, '5.0000', '2019-07-15 14:11:08', '2019-07-15 14:11:08', '84a66c9b-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(431, 55, 'maricic92marko@gmail.com', 10, '5.0000', '2019-07-15 14:11:08', '2019-07-15 14:11:08', '84a66c9b-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(432, 55, 'maricic92marko@gmail.com', 11, '5.0000', '2019-07-15 14:11:08', '2019-07-15 14:11:08', '84a66c9b-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(433, 55, 'maricic92marko@gmail.com', 8, '5.0000', '2019-07-15 14:11:08', '2019-07-15 14:11:08', '84a66c9b-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(434, 55, 'maricic92marko@gmail.com', 15, '5.0000', '2019-07-15 14:11:08', '2019-07-15 14:11:08', '84a66c9b-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(435, 55, 'maricic92marko@gmail.com', 13, '5.0000', '2019-07-15 14:11:08', '2019-07-15 14:11:08', '84a66c9b-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(436, 55, 'maricic92marko@gmail.com', 9, '5.0000', '2019-07-15 14:11:08', '2019-07-15 14:11:08', '84a66c9b-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(437, 55, 'maricic92marko@gmail.com', 5, '5.0000', '2019-07-15 14:11:08', '2019-07-15 14:11:08', '84a66c9b-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(438, 55, 'maricic92marko@gmail.com', 12, '5.0000', '2019-07-15 14:11:08', '2019-07-15 14:11:08', '84a66c9b-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(439, 55, 'maricic92marko@gmail.com', 4, '5.0000', '2019-07-15 14:11:09', '2019-07-15 14:11:09', '84a66c9b-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(440, 56, 'maricic92marko@gmail.com', 14, '5.0000', '2019-07-15 14:11:10', '2019-07-15 14:11:10', '859ae8e9-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(441, 56, 'maricic92marko@gmail.com', 4, '5.0000', '2019-07-15 14:11:10', '2019-07-15 14:11:10', '859ae8e9-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(442, 56, 'maricic92marko@gmail.com', 5, '5.0000', '2019-07-15 14:11:10', '2019-07-15 14:11:10', '859ae8e9-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(443, 56, 'maricic92marko@gmail.com', 6, '5.0000', '2019-07-15 14:11:10', '2019-07-15 14:11:10', '859ae8e9-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(444, 56, 'maricic92marko@gmail.com', 7, '5.0000', '2019-07-15 14:11:10', '2019-07-15 14:11:10', '859ae8e9-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(445, 56, 'maricic92marko@gmail.com', 9, '5.0000', '2019-07-15 14:11:10', '2019-07-15 14:11:10', '859ae8e9-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(446, 56, 'maricic92marko@gmail.com', 10, '5.0000', '2019-07-15 14:11:10', '2019-07-15 14:11:10', '859ae8e9-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(447, 56, 'maricic92marko@gmail.com', 11, '5.0000', '2019-07-15 14:11:10', '2019-07-15 14:11:10', '859ae8e9-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(448, 56, 'maricic92marko@gmail.com', 12, '5.0000', '2019-07-15 14:11:10', '2019-07-15 14:11:10', '859ae8e9-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(449, 56, 'maricic92marko@gmail.com', 13, '5.0000', '2019-07-15 14:11:10', '2019-07-15 14:11:10', '859ae8e9-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(450, 56, 'maricic92marko@gmail.com', 15, '5.0000', '2019-07-15 14:11:10', '2019-07-15 14:11:10', '859ae8e9-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(451, 56, 'maricic92marko@gmail.com', 8, '5.0000', '2019-07-15 14:11:10', '2019-07-15 14:11:10', '859ae8e9-a6f9-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(452, 57, 'maricic92marko@gmail.com', 3, '9.0000', '2019-07-15 14:26:45', '2019-07-15 14:26:45', 'b33ec68f-a6fb-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(453, 58, 'maricic92marko@gmail.com', 4, '9.6000', '2019-07-15 15:40:55', '2019-07-15 15:40:55', '0f1dac62-a706-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(454, 58, 'maricic92marko@gmail.com', 3, '9.0000', '2019-07-15 15:40:55', '2019-07-15 15:40:55', '0f1dac62-a706-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(455, 59, 'maricic92marko@gmail.com', 1, '3.0000', '2019-07-15 15:42:20', '2019-07-15 15:42:20', '422d6812-a706-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(456, 60, 'maricic92marko@gmail.com', 13, '5.0000', '2019-07-15 15:43:58', '2019-07-15 15:43:58', '7c79fa71-a706-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(457, 61, 'maricic92marko@gmail.com', 4, '2.0000', '2019-07-15 16:06:34', '2019-07-15 16:06:34', 'a4d9af3b-a709-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(458, 61, 'maricic92marko@gmail.com', 13, '2.0000', '2019-07-15 16:06:34', '2019-07-15 16:06:34', 'a4d9af3b-a709-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(459, 61, 'maricic92marko@gmail.com', 6, '2.0000', '2019-07-15 16:06:34', '2019-07-15 16:06:34', 'a4d9af3b-a709-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(460, 61, 'maricic92marko@gmail.com', 7, '2.0000', '2019-07-15 16:06:34', '2019-07-15 16:06:34', 'a4d9af3b-a709-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(461, 61, 'maricic92marko@gmail.com', 10, '2.0000', '2019-07-15 16:06:34', '2019-07-15 16:06:34', 'a4d9af3b-a709-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(462, 61, 'maricic92marko@gmail.com', 8, '2.0000', '2019-07-15 16:06:34', '2019-07-15 16:06:34', 'a4d9af3b-a709-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(463, 61, 'maricic92marko@gmail.com', 14, '2.0000', '2019-07-15 16:06:34', '2019-07-15 16:06:34', 'a4d9af3b-a709-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(464, 61, 'maricic92marko@gmail.com', 2, '2.0000', '2019-07-15 16:06:34', '2019-07-15 16:06:34', 'a4d9af3b-a709-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(465, 61, 'maricic92marko@gmail.com', 11, '2.0000', '2019-07-15 16:06:34', '2019-07-15 16:06:34', 'a4d9af3b-a709-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(466, 61, 'maricic92marko@gmail.com', 9, '2.0000', '2019-07-15 16:06:34', '2019-07-15 16:06:34', 'a4d9af3b-a709-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(467, 61, 'maricic92marko@gmail.com', 5, '2.0000', '2019-07-15 16:06:34', '2019-07-15 16:06:34', 'a4d9af3b-a709-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(468, 61, 'maricic92marko@gmail.com', 15, '2.0000', '2019-07-15 16:06:34', '2019-07-15 16:06:34', 'a4d9af3b-a709-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(469, 61, 'maricic92marko@gmail.com', 12, '2.0000', '2019-07-15 16:06:34', '2019-07-15 16:06:34', 'a4d9af3b-a709-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(470, 61, 'maricic92marko@gmail.com', 1, '2.0000', '2019-07-15 16:06:35', '2019-07-15 16:06:35', 'a4d9af3b-a709-11e9-a964-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(471, 62, 'maricic92marko@gmail.com', 1, '3.0000', '2019-07-18 13:45:50', '2019-07-18 13:45:50', '96ccf31a-a951-11e9-9302-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(472, 62, 'maricic92marko@gmail.com', 10, '88.0000', '2019-07-18 13:45:50', '2019-07-18 13:45:50', '96ccf31a-a951-11e9-9302-6c71d923c8da', b'0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(473, 63, 'maricic92marko@gmail.com', 1, '2.0000', '2019-07-18 15:34:01', '2019-07-18 15:34:01', 'b3959e05-a960-11e9-9302-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', '00000', 'gg', NULL, 'gg'),
(474, 64, 'maricic92marko@gmail.com', 1, '9.0000', '2019-07-18 15:52:16', '2019-07-18 15:52:16', '40b134e5-a963-11e9-9302-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'rrr'),
(475, 65, 'maricic92marko@gmail.com', 4, '4.0000', '2019-07-19 17:20:19', '2019-07-19 17:20:19', 'afe121a2-aa38-11e9-ba83-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(476, 65, 'maricic92marko@gmail.com', 5, '5.0000', '2019-07-19 17:20:19', '2019-07-19 17:20:19', 'afe121a2-aa38-11e9-ba83-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(477, 65, 'maricic92marko@gmail.com', 6, '3.0000', '2019-07-19 17:20:19', '2019-07-19 17:20:19', 'afe121a2-aa38-11e9-ba83-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(478, 66, 'maricic92marko@gmail.com', 2, '88.0000', '2019-07-19 18:44:02', '2019-07-19 18:44:02', '61c6e5ac-aa44-11e9-ba83-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'gg'),
(479, 66, 'maricic92marko@gmail.com', 3, '88.0000', '2019-07-19 18:44:02', '2019-07-19 18:44:02', '61c6e5ac-aa44-11e9-ba83-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'gg'),
(480, 66, 'maricic92marko@gmail.com', 1, '88.0000', '2019-07-19 18:44:02', '2019-07-19 18:44:02', '61c6e5ac-aa44-11e9-ba83-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'gg'),
(481, 67, 'maricic92marko@gmail.com', 1, '44.0000', '2019-07-19 23:10:20', '2019-07-19 23:10:20', '9ddb415e-aa69-11e9-b3e2-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(482, 68, 'maricic92marko@gmail.com', 1, '2.0000', '2019-07-19 23:12:57', '2019-07-19 23:12:57', 'fb7887d5-aa69-11e9-b3e2-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(483, 69, 'maricic92marko@gmail.com', 1, '33.0000', '2019-07-19 23:15:33', '2019-07-19 23:15:33', '57f83062-aa6a-11e9-b3e2-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(484, 70, 'maricic92marko@gmail.com', 1, '88.0000', '2019-07-19 23:49:55', '2019-07-19 23:49:55', '2566165d-aa6f-11e9-b3e2-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(485, 71, 'maricic92marko@gmail.com', 3, '99.0000', '2019-07-19 23:56:03', '2019-07-19 23:56:03', '00a91d2c-aa70-11e9-b3e2-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(486, 72, 'maricic92marko@gmail.com', 6, '99.0000', '2019-07-22 19:43:47', '2019-07-22 19:43:47', '4211184a-aca8-11e9-9bf0-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(487, 72, 'maricic92marko@gmail.com', 4, '88.0000', '2019-07-22 19:43:47', '2019-07-22 19:43:47', '4211184a-aca8-11e9-9bf0-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(488, 72, 'maricic92marko@gmail.com', 5, '77.0000', '2019-07-22 19:43:47', '2019-07-22 19:43:47', '4211184a-aca8-11e9-9bf0-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(489, 73, 'maricic92marko@gmail.com', 1, '77.0000', '2019-07-22 19:50:55', '2019-07-22 19:50:55', '41042989-aca9-11e9-9bf0-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(490, 73, 'maricic92marko@gmail.com', 4, '77.0000', '2019-07-22 19:50:55', '2019-07-22 19:50:55', '41042989-aca9-11e9-9bf0-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(491, 73, 'maricic92marko@gmail.com', 6, '77.0000', '2019-07-22 19:50:55', '2019-07-22 19:50:55', '41042989-aca9-11e9-9bf0-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(492, 73, 'maricic92marko@gmail.com', 5, '77.0000', '2019-07-22 19:50:55', '2019-07-22 19:50:55', '41042989-aca9-11e9-9bf0-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(493, 74, 'maricic92marko@gmail.com', 2, '99.0000', '2019-07-22 19:53:53', '2019-07-22 19:53:53', 'ab13e1b7-aca9-11e9-9bf0-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', '00000', 'ss', 'rrr', 'ss'),
(494, 75, 'maricic92marko@gmail.com', 2, '80.0000', '2019-07-22 20:05:31', '2019-07-22 20:05:31', '4b2341b5-acab-11e9-9bf0-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(495, 76, 'maricic92marko@gmail.com', 5, '99.0000', '2019-07-23 10:07:37', '2019-07-23 10:07:37', 'e8f41c9a-ad20-11e9-9bf0-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(496, 77, 'maricic92marko@gmail.com', 2, '23.0000', '2019-07-23 10:13:32', '2019-07-23 10:13:32', 'bc94ba87-ad21-11e9-9bf0-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(497, 78, 'maricic92marko@gmail.com', 1, '99.0000', '2019-07-23 10:16:10', '2019-07-23 10:16:10', '1ac3e005-ad22-11e9-9bf0-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(498, 79, 'maricic92marko@gmail.com', 1, '22.0000', '2019-07-23 10:18:07', '2019-07-23 10:18:07', '6069d172-ad22-11e9-9bf0-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(499, 80, 'maricic92marko@gmail.com', 5, '22.0000', '2019-07-23 10:22:08', '2019-07-23 10:22:08', 'f016841b-ad22-11e9-9bf0-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(500, 81, 'maricic92marko@gmail.com', 1, '99.0000', '2019-07-23 10:23:52', '2019-07-23 10:23:52', '2e6c83aa-ad23-11e9-9bf0-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(501, 82, 'maricic92marko@gmail.com', 1, '9.0000', '2019-07-23 11:39:58', '2019-07-23 11:39:58', 'cfc58fb8-ad2d-11e9-9bf0-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(502, 83, 'maricic92marko@gmail.com', 1, '9.0000', '2019-07-23 11:42:39', '2019-07-23 11:42:39', '2f910dfa-ad2e-11e9-9bf0-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(503, 84, 'maricic92marko@gmail.com', 6, '2.0000', '2019-07-23 11:43:35', '2019-07-23 11:43:35', '50b700ce-ad2e-11e9-9bf0-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(504, 85, 'maricic92marko@gmail.com', 1, '2.0000', '2019-07-23 11:47:34', '2019-07-23 11:47:34', 'df27c303-ad2e-11e9-9bf0-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(505, 86, 'maricic92marko@gmail.com', 9, '2.0000', '2019-07-23 11:48:46', '2019-07-23 11:48:46', '0a600be3-ad2f-11e9-9bf0-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(506, 87, 'maricic92marko@gmail.com', 6, '2.0000', '2019-07-23 11:52:02', '2019-07-23 11:52:02', '7f0d72d4-ad2f-11e9-9bf0-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(507, 88, 'maricic92marko@gmail.com', 5, '22.0000', '2019-07-23 12:03:07', '2019-07-23 12:03:07', '0b9392ae-ad31-11e9-9bf0-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(508, 89, 'maricic92marko@gmail.com', 7, '22.0000', '2019-07-23 12:15:58', '2019-07-23 12:15:58', 'd70a3eba-ad32-11e9-9bf0-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(509, 90, 'maricic92marko@gmail.com', 3, '88.0000', '2019-07-29 14:59:37', '2019-07-29 14:59:37', 'b7f723d5-b200-11e9-b38e-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(510, 90, 'maricic92marko@gmail.com', 1, '8.0000', '2019-07-29 14:59:37', '2019-07-29 14:59:37', 'b7f723d5-b200-11e9-b38e-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(511, 91, 'maricic92marko@gmail.com', 4, '2.0000', '2019-07-29 15:04:00', '2019-07-29 15:04:00', '54785053-b201-11e9-b38e-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(512, 92, 'maricic92marko@gmail.com', 4, '9.0000', '2019-07-29 15:08:22', '2019-07-29 15:08:22', 'f09a375e-b201-11e9-b38e-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(513, 93, 'maricic92marko@gmail.com', 1, '2.0000', '2019-07-29 15:13:45', '2019-07-29 15:13:45', 'b159954d-b202-11e9-b38e-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(514, 94, 'maricic92marko@gmail.com', 1, '2.0000', '2019-07-29 15:19:34', '2019-07-29 15:19:34', '813a02f0-b203-11e9-b38e-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(515, 95, 'rolosistem@live.com', 1, '2.0000', '2019-07-29 15:27:18', '2019-07-29 15:27:18', '962bcc59-b204-11e9-b38e-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(516, 96, 'marko92maricic@gmail.com', 1, '3.0000', '2019-07-29 15:34:31', '2019-07-29 17:10:08', '98364d19-b205-11e9-b38e-6c71d923c8da', b'1', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(517, 97, 'marko92maricic@gmail.com', 1, '3.0000', '2019-07-29 15:46:39', '2019-07-29 15:46:55', '49f90c71-b207-11e9-b38e-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(518, 98, 'marko92maricic@gmail.com', 3, '3.0000', '2019-07-29 16:00:38', '2019-07-29 17:00:36', '3de1f07d-b209-11e9-b38e-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(519, 99, 'maricic92marko@gmail.com', 1, '9.0000', '2019-07-29 17:43:36', '2019-07-29 17:43:36', 'a0a42e53-b217-11e9-b847-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(520, 100, 'marko92maricic@gmail.com', 4, '8.0000', '2019-07-29 17:44:53', '2019-07-29 17:45:18', 'cf04690a-b217-11e9-b847-6c71d923c8da', b'1', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss'),
(521, 101, 'radaocokoljic7@gmail.com', 1, '3.0000', '2019-07-30 14:24:42', '2019-07-30 14:24:42', '0249938c-b2c5-11e9-9a2e-6c71d923c8da', b'0', 'Rada', 'Ocokolji?', NULL, 'dd', 'ss', 'rrr', 'ss'),
(522, 102, 'maricic92marko@gmail.com', 2, '2.0000', '2019-07-30 14:34:42', '2019-07-30 14:34:42', '67ee9610-b2c6-11e9-9a2e-6c71d923c8da', b'0', 'marko', 'maricic', 'mm', 'dd', 'ss', 'rrr', 'ss');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_products`
--

CREATE TABLE IF NOT EXISTS `tbl_products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(120) CHARACTER SET cp1250 COLLATE cp1250_croatian_ci DEFAULT NULL,
  `description` text CHARACTER SET cp1250 COLLATE cp1250_croatian_ci,
  `price` decimal(18,2) DEFAULT NULL,
  `image` varchar(100) CHARACTER SET cp1250 COLLATE cp1250_croatian_ci DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `class_id` int(11) DEFAULT NULL,
  `snizenje` bit(1) NOT NULL DEFAULT b'0',
  `metric_unit_id` int(11) DEFAULT NULL,
  `img_path_list` mediumtext CHARACTER SET cp1250 COLLATE cp1250_croatian_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin2 COLLATE=latin2_croatian_ci;

--
-- Dumping data for table `tbl_products`
--

INSERT INTO `tbl_products` (`id`, `name`, `description`, `price`, `image`, `created`, `updated`, `class_id`, `snizenje`, `metric_unit_id`, `img_path_list`) VALUES
(1, 'I am Groot', 'This stuffed Groot makes an excellent toy for both youngsters due to it\'s soft nature and adorable design, to fans and collectors of \'The Guardians of the Galaxy\' franchise.', '19.99', '/products/Untitled-1.png', '2018-10-01 01:57:07', '2018-10-01 01:57:07', 1, b'0', 3, '/products/20-livestock-truck copy.jpg,/products/20-livestock-truck copy.jpg,/products/20-livestock-truck copy.jpg,/products/20-livestock-truck copy.jpg,/products/20-livestock-truck copy.jpg,/products/20-livestock-truck copy.jpg,/products/20-livestock-truck copy.jpg,/products/20-livestock-truck copy.jpg,/products/20-livestock-truck copy.jpg,/products/20-livestock-truck copy.jpg'),
(2, 'Buzz Lightyear Action Doll', 'Buzz Lightyear is a favorite of youngsters. He has a ray-gun, wings that can be retracted or extended on the push of a button, and a grin that could make any alien get a chill up their spine - should they have one.', '38.50', '/products/zavrsetakfi19srebropresek.png', '2019-05-29 14:42:59', '2019-05-29 14:42:59', 2, b'0', 3, '/products/zavrsetakfi19srebropresek2.png,/products/logos-mastercard.png'),
(3, 'Minion Dave', 'Dave is a two-eyed and medium-sized minion with nice combed hair. This plush version of him is extremely huggable and makes a great best friend for your young child. He is stitched well and has no small parts to choke one', '12.99', '/products/3-minion-dave.jpg', '2019-05-29 14:46:48', '2019-05-29 14:46:48', 3, b'0', 2, NULL),
(4, 'Minion Kevin', 'Kevin is a tall, two-eyed minion with sprout cut hair and is usually seen wearing his golf apparel. This plush version of him is extremely huggable and makes a great best friend for your young child. He is stitched well and has no small parts to choke on.', '12.99', '/products/4-minion-kevin.jpg', '2019-05-29 14:48:06', '2019-05-29 14:48:06', 4, b'1', 1, NULL),
(5, 'Minion Bob', 'Bob is a short and bald minion with multi-colored eyes (green and brown). He often carries around a teddy bear that he owns called Tim, which is brown with yellow buttoned eyes. This plush version of him is extremely huggable and makes a great best friend for your young child. He is stitched well and has no small parts to choke on.', '12.99', '/products/5-minion-bob.jpg', '2019-05-29 14:50:00', '2019-05-29 14:50:00', 4, b'1', 1, NULL),
(6, 'uukelele', 'new', '123.00', '/products/12-ukelele.jpg', '2019-07-01 21:50:30', '2019-07-01 21:50:30', 4, b'1', 1, NULL),
(7, 'ukelele', 'new', '123.00', '/products/12-ukelele.jpg', '2019-07-01 21:52:13', '2019-07-01 21:52:13', 4, b'1', 1, NULL),
(8, '11-electricguitar.jpg', 'new', '123.00', '/products/11-electric-guitar.jpg', '2019-07-01 22:50:15', '2019-07-01 22:50:15', 4, b'1', 1, NULL),
(9, '13-flute.jpg', 'new', '123.00', '/products/13-flute.jpg', '2019-07-01 22:50:54', '2019-07-01 22:50:54', 4, b'1', 2, NULL),
(10, '14-drums.jpg', 'new', '123.00', '/products/14-drums.jpg', '2019-07-01 22:51:41', '2019-07-01 22:51:41', 4, b'1', 2, NULL),
(11, '15-llama.jpg', 'new', '123.00', '/products/15-llama.jpg', '2019-07-01 22:52:03', '2019-07-01 22:52:03', 4, b'1', 2, NULL),
(12, '16-pikachu.jpg', 'new', '123.00', '/products/16-pikachu.jpg', '2019-07-01 22:52:29', '2019-07-01 22:52:29', 4, b'1', 2, NULL),
(13, '17-mario-3.jpg', 'new', '123.00', '/products/17-mario-3.jpg', '2019-07-01 22:53:17', '2019-07-01 22:53:17', 4, b'1', 2, NULL),
(14, '18-bunny.jpg', 'new', '123.00', '/products/18-bunny.jpg', '2019-07-01 22:53:44', '2019-07-01 22:53:44', 4, b'1', 1, NULL),
(15, '19-dump-truck.jpg', 'new', '123.00', '/products/19-dump-truck.jpg', '2019-07-01 22:54:35', '2019-07-01 22:54:35', 4, b'1', 1, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_product_class`
--

CREATE TABLE IF NOT EXISTS `tbl_product_class` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `class_name` varchar(100) DEFAULT NULL,
  `image_path` varchar(256) DEFAULT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `tbl_product_class`
--

INSERT INTO `tbl_product_class` (`id`, `class_name`, `image_path`) VALUES
(1, 'Garnišne', '/products/garnisne.slika.klasa.png'),
(2, 'Elektro motori', '/products/el.motori.png'),
(3, 'Rolo sistemi', '/products/rolo_sistemi.png'),
(4, 'Komponente', '/images/komponente.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_product_images`
--

CREATE TABLE IF NOT EXISTS `tbl_product_images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `img_path_list` varchar(2000) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `tbl_product_images`
--

INSERT INTO `tbl_product_images` (`id`, `img_path_list`, `product_id`) VALUES
(1, '/products/20-livestock-truck copy.jpg,/products/20-livestock-truck copy.jpg,/products/20-livestock-truck copy.jpg,/products/20-livestock-truck copy.jpg,/products/20-livestock-truck copy.jpg,/products/20-livestock-truck copy.jpg,/products/20-livestock-truck copy.jpg,/products/20-livestock-truck copy.jpg,/products/20-livestock-truck copy.jpg,/products/20-livestock-truck copy.jpg', 1),
(2, '/products/zavrsetakfi19srebropresek2.png,/products/logos-mastercard.png', 2),
(3, '/products/sliderimg.jpg,/products/sliderimg1.jpg,/products/sliderimg2.jpg,/products/sliderimg3.jpg,/products/sliderimg4.jpg,/products/sliderimg5.jpg', 0);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_slider_images`
--

CREATE TABLE IF NOT EXISTS `tbl_slider_images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `image_path` varchar(100) CHARACTER SET cp1250 COLLATE cp1250_croatian_ci DEFAULT NULL,
  `page_link` varchar(100) CHARACTER SET cp1250 COLLATE cp1250_croatian_ci DEFAULT NULL,
  `class_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_croatian_ci;

--
-- Dumping data for table `tbl_slider_images`
--

INSERT INTO `tbl_slider_images` (`id`, `image_path`, `page_link`, `class_id`, `product_id`) VALUES
(1, '/products/panel.jpg', '/ProductList', 1, NULL),
(2, '/products/roler.jpg', '/ProductList', 2, NULL),
(3, '/products/roman.jpg', '/ProductList', 3, NULL),
(4, '/products/trakaste.jpg', '/ProductList', 4, NULL),
(5, '/products/siluetZavese.jpg', '/ProductDetails', NULL, 1);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_store_info`
--

CREATE TABLE IF NOT EXISTS `tbl_store_info` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `store_mail` varchar(256) COLLATE utf8_croatian_ci DEFAULT NULL,
  `store_name` varchar(256) COLLATE utf8_croatian_ci DEFAULT NULL,
  `store_phone` varchar(124) COLLATE utf8_croatian_ci DEFAULT NULL,
  `store_address` varchar(256) COLLATE utf8_croatian_ci DEFAULT NULL,
  `store_delivery_company` varchar(100) COLLATE utf8_croatian_ci DEFAULT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_croatian_ci;

--
-- Dumping data for table `tbl_store_info`
--

INSERT INTO `tbl_store_info` (`id`, `store_mail`, `store_name`, `store_phone`, `store_address`, `store_delivery_company`) VALUES
(1, 'rolosistem@gmail.com', 'Rolo Sistem', '0600999888', 'Lazarevački drum 5, 1030 Beograd, Srbija', 'Royal Express d.o.o.');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `id` int(6) UNSIGNED NOT NULL AUTO_INCREMENT,
  `first_name` varchar(30) NOT NULL,
  `last_name` varchar(30) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `first_name`, `last_name`) VALUES
(1, 'Brian', 'Voong'),
(2, 'Stephen', 'Curry'),
(3, 'Clay', 'Thompson'),
(4, 'Kevin', 'Durant'),
(5, 'Draymond', 'Green'),
(6, 'Marko', 'Maricic'),
(7, 'Marko', 'Maricic'),
(8, 'asd', 'asdasd'),
(9, 'Marko', 'Maricic'),
(10, 'Marko', 'Maricic');
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
