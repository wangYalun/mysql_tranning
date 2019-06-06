## **高性能MySQL** 

**推荐序**
> 在2015的时候，我就是这本书的粉丝了，这是一本伟大的书。

### **MySQL 架构与历史**

**1.1 MySQL逻辑架构**



**1.2 并发控制**

> 读写锁 - 共享锁（读锁）和排它锁（写锁）
> 锁粒度 - 表锁 和 行级锁

**1.3 事务**
> ACID: 原子性(atomicity)、一致性(consistency)、隔离性(isolation)、持久性(durability)

> 隔离级别: READ UNCOMMITTID, READ COMMITTED, REPEATABLE READ, SERIALIZABLE

### **基准测试**
> 安装学习 sysbench

```
Ubuntu/Debian
$ curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | sudo bash
$ sudo apt -y install sysbench
```

### **服务器性能剖析**
- 使用MySQL 官网提供的测试数据库，sakila 
- 使用show profile
```
// 默认是禁用的，可以通过服务器变量在会话（链接级别）动态的修改, 只会记录和分析当前会话的SQL查询
mysql> set profiling=1;
mysql> select * from actor;
mysql> show profiles;
mysql> show profile for query 1;
```
- 使用 show status

### **第四章 Schema与数据类型优化**

**4.1 选择优化的数据类型**
> 下面几个简单的原则有助于做出更好的选择。
- 更小的通常更好，因为它们占有更少的的磁盘、内存和CPU缓存，但不要低估需要储存值的范围。
- 简单更好，例如 整型比字符串操作代价更低，用MySQL 内建类型（date,time,datetime）来存储日期和时间，用整型来存储IP地址
- 避免使用null

**4.1.1 整型类型** 

> tinyint, smallint, mediumint, int, bigint ,分别使用 8, 16,24,32,64位存储数据。 整数类型有可选的 unsigned 属性，这样可以使正数的上限提升一倍。

**4.1.2 实数类型** 
> float, double, decimal

**4.1.3 字符串类型** 
> varchar ,char ,binary, varbinary, blob, text
```
//测试char, varchar 
mysql> create table mt_char(char_test char(10));
mysql> insert into mt_char values('string1'),('   string2'),('string3   ');
mysql> select concat('`',char_test,'`') from mt_char;
```
> 使用枚举（ENUM）代替字符串类型
```
mysql> create table mt_enum(e enum('fish','apple','dog') not null);
mysql> insert into mt_enum(e) values('fish'),('dog'),('apple');
mysql> select e+0 from mt_enum; 
// 实际存储为整数，排序也是按存储的整数排序，可以在定义时就按字母顺序排好序。
```
**4.1.4 日期和时间类型** 
> datetime, timestamp ,精确到秒

**4.1.5 位数据类型** 
>bit ,set 
```
mysql> create table mt_acl(perms set('CAN_READ','CAN_WRITE','CAN_DELETE') not null);
mysql> insert into mt_acl(perms) values('CAN_READ,CAN_DELETE'),('CAN_READ');
mysql> select * from mt_acl where find_in_set('CAN_READ',perms);
```

**4.1.6 选择标识符**
- 整数类型通常是最好的选择，可以使用auto_increment
- ENUM 和 SET 类型
- 字符串类型
**4.1.7 特殊数据类型** 
```
mysql> select INET_ATON('192.168.1.100');
mysql> select INET_NTOA(32);
```

**4.2 MySQL schema设计中的陷阱**
- 太多的列
- 太多的关联
- 变相的枚举
- 全能的枚举

**4.3 范式和反范式**
--- 
三大范式
- 1NF：字段是原子性的，不可分;
- 2NF：有主键，非主键字段依赖主键。确保一个表只说明一个事物
- 3NF：非主键字段不能相互依赖。 每列都与主键有直接关系，不存在传递的依赖

**4.3.1范式的优点和缺点**
**4.3.2反范式的优点和缺点** 
**4.3.3通用范式和反范式化**

**4.4 缓存表和汇总表**

- 计数器表
```
// 例如记录网站的点击次数
mysql> create table mt_hit_counter(cnt int unsigned not null);
mysql> update mt_hit_counter set cnt=cnt+1;
// 获得更高的并发，可以随机访问
mysql> create table mt_hit_counter_rand(
    slot int unsigned not null primary key,
    cnt int unsigned not null
    );
mysql> update hit_counter_rand set cnt=cnt+1 where slot=rand()*100;

mysql> create table mt_daily_hit_counter(
    day date not null,
    slot tiny unsigned not null,
    cnt int unsigned not null,
    primary key(day,slot)
);
mysql> inster into mt_daily_hit_conter(day,slot,cnt) values(current_date(),rand()*100,1) on duplicate key update cnt=cnt+1;
```

**4.5 加快 alter table 操作的速度**


**### 第五章 创建高性能索引**
**5.1 索引基础**
- B_Tree 索引
```
mysql> create table people(
    last_name varchar(50) not null,
    first_name varchar(50) not null,
    dob date not null,
    gender enum('m','f') not null,
    key(last_name,first_name,dob)
);
```
- 哈希索引
- 空间索引，需要使用 MyISAM 表引擎
- 全文索引

索引三大优点
1. 索引大大减少了服务器需要扫描的数据量
2. 索引可以帮助服务器避免排序和临时表。
3. 索引可以将随机I/O 变为顺序I/O.

**5.3 高性能的索引策略**

- 独立的列
```
mysql> select actor_id from sakila.actor where actor_id+1=5;
```
- 前缀索引和索引性选择
> 索引的选择性，不重复的索引值（也称基数）和数据表的总记录数（#T）的比值，索引的选择性越高则查询效率越高。
```
mysql> alter table table_name add key(city(7));
```
- 多列索引
- 选择合适的索引列的顺序
- 聚簇索引
- 覆盖索引
> 如果一个索引包含（或者说覆盖）所有需要查询的字段的值，我们就称之为“覆盖索引”
```
mysql> explain select store_id,file_id from sakila.inventory \G;

```
- 使用索引扫描来做排序
- 冗余索引和重复索引
- 未使用的索引
- 索引和锁
```
mysql> begin;
mysql> select * from hit_conter_rand where slot=1 for update;
mysql> commit;

```

**### 查询性能优化**
- 慢查询基础：优化数据访问

**6.3 重构查询的方式**
- 一个复杂的查询还是多个简单查询
- 切分查询
- 分解关联查询
```

```
