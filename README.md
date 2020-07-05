# Datebase学习笔记

## Mongodb数据

>MongoDB shell version v3.4.19
>connecting to: mongodb://127.0.0.1:27017
>MongoDB server version: 3.4.19
>NoSQLBooster: 6.0.4

### 简介

Mongodb是一款非关系型数据库，非关系型数据库就是把数据直接放进一个大仓库，不标号、不连线、单纯的堆起来。

mongodb是一个介于关系数据库和非关系数据库之间的产品，是非关系数据库中功能最丰富、最像关系数据库的。

mongodb支持的数据结构非常松散，是类似json的bson格式，因此可以存储比较复杂的数据类型。

mongodb与mysql的比较：

| mysql  | mongodb |
| :----: | :-----: |
| 数据库 | 数据库  |
|   表   |  集合   |
|  记录  |  文档   |

### 基本概念

**数据库**：一个mongodb可以创建多个数据库，库名规范：不能有空格、点号和$符

**文档**：文档是mongodb的核心，类似于关系型数据库的每一行数据。多个键及其关联的值放在一起就是文档。文档之间的逻辑关系：嵌入式关系，比较适合一对一的关系；引用式关系，比较适合一对多或者多对多的情况。

**集合**：集合就是一组文档的组合，就相当于是关系数据库中的表，在mongodb中可以存储不同的文档结构的文档。mongodb在存储信息时，将字段名存储多次，每一条记录都会存储一次字段名，比较好的解决办法就是采用尽可能短的字段名。

**元数据**：数据库的信息存储在集合中，他们统一使用系统的命名空间：`DBNAME.system.*`

DBNAME可用db或数据库名替代：

- DBNAME.system.namespaces 列出所有名字空间
- DBNAME.system.indexs 列出所有索引
- DBNAME.system.profile 列出数据库概要信息
- DBNAME.system.users 列出访问数据库的用户
- DBNAME.system.sources 列出服务器信息

### 数据库的创建和销毁

**创建数据库**：

- `use mydb` 创建数据库
- `db` 查看当前连接的数据库
- `show dbs` 查看所有的数据库

**销毁数据库**：

- `db.dropDatabase()`

### 集合的创建和销毁

**创建集合**：

- `db.createCollection("users")`创建集合
- `show collections`查看创建的集合

**删除集合**：

- `db.users.drop()`删除集合

### 向集合中插入数据

可以在插入数据时同时创建集合

**使用insert（）**：

```js
db.users.insert([
    {_id:1, name:"jim", email:"jim@qq.com"},
    {_id:2, name:"tom", email:"tom@qq.com"}
])
```

![image-20200705155947899](https://i.loli.net/2020/07/05/EeyiqnYp1fJ94Vb.png)

**使用save（）**：

```js
db.users.save(
    {_id:2, name:"tom", email:"tom1@qq.com"}    
)
```

![image-20200705160021606](https://i.loli.net/2020/07/05/8iDqzcwR59nbSEW.png)

**insert和save的区别**：

- insert只能插入一条新的记录无法插入一条已经存在的记录
- save不仅可以保存一条新纪录也可以更新原纪录