/**
 * Author:  Allen
 * Created: 2019-04-02
 */

create database `mysql_training` default character set utf8 COLLATE utf8_general_ci;

use mysql_training;

create table `mt_test`(
  `id` int(11) unsigned not null auto_increment comment '自增标识ID',
  primary key(`id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='测试表';

-- 试验 sakila ，MySQL 官网测试数据库
-- SHOW PROFILE 
-- 在会话（连接）级别开启
set profiling=1;

select * from sakila.

show profiles;
show profile from query 1;
set @query_id=15;
select state, sum(duration) as Total_R,
round(100*sum(duration)/
(select sum(duration) from information_schema.profiling 
where query_id=@query_id),2) as Pct_R,
count(*) as Calls,
sum(duration)/count(8) as 'R/Call' 
from information_schema.profiling
where query_id=@query_id
group by state
order by Total_R desc;

-- 存储过程-循环

DELIMITER //
  CREATE PROCEDURE proc5()
    BEGIN
      DECLARE var INT;
      SET var=0;
      WHILE var<100 DO
        INSERT INTO hit_counter_rand VALUES (var+1,0);
        SET var=var+1;
      END WHILE ;
    END;
  //
DELIMITER ;

DELIMITER //
  CREATE PROCEDURE proc_inster()
    BEGIN
      DECLARE var INT;
      SET var=0;
      WHILE var<1000 DO
        update hit_counter_rand set cnt=cnt+1 where slot=floor(rand()*100);
        SET var=var+1;
      END WHILE;
    END;
  //
DELIMITER;

-- 触发器

DELIMITER //
create trigger table_name_filed_operation before inster on table_name for each row
BEGIN
set new.filed+crc=crc32(new.filed);
end;
//
DELIMITER ;

-- MySQL 对GIS 空间数据的支持
CREATE TABLE mt_tb_geo(
id INT PRIMARY KEY AUTO_INCREMENT,
NAME VARCHAR(128) NOT NULL,
pnt POINT NOT NULL,
SPATIAL INDEX `spatIdx` (`pnt`) 
)ENGINE=MYISAM DEFAULT CHARSET=utf8;
-- 创建表时创建空间索引 

INSERT INTO `mt_tb_geo` VALUES(
NULL,
'a test string',
POINTFROMTEXT('POINT(15 20)'));

