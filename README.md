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

### 基本概念和简单操作

#### 概念：数据库，文档，集合，元数据

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

#### 数据库的创建和销毁

**创建数据库**：

- `use mydb` 创建数据库
- `db` 查看当前连接的数据库
- `show dbs` 查看所有的数据库

**销毁数据库**：

- `db.dropDatabase()`

#### 集合的创建和销毁

**创建集合**：

- `db.createCollection("users")`创建集合
- `show collections`查看创建的集合

**删除集合**：

- `db.users.drop()`删除集合

#### 向集合中插入数据

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

### 数据查询

#### find()语句

**用法**：`db.COLLECTION_NAME.find()`

```js
> use post
> db.post.insert([
{
   title: 'MongoDB Overview',
   description: 'MongoDB is no sql database',
   by: 'mongodb',
   url: 'http://www.mongodb.com',
   tags: ['mongodb', 'database', 'NoSQL'],
   likes: 100
},
{
   title: 'NoSQL Database',
   description: "NoSQL database doesn't have tables",
   by: 'mongodb',
   url: 'http://www.mongodb.com',
   tags: ['mongodb', 'database', 'NoSQL'],
   likes: 20,
   comments: [
      {
         user:'user1',
         message: 'My first comment',
         dateCreated: new Date(2013,11,10,2,35),
         like: 0
      }
   ]
}
])
```

查询数据，不加任何参数默认返回所有数据记录：

```js
> db.post.find()
```

这种写法会导致，大量的数据传输，造成服务器响应迟缓，显示的数据也不美观

**pretty()语句**

使用pretty()语句可以使查询输出的结果更美观

```js
> db.post.find().pretty()
```

也可以使用以下方式让mongo shell始终以pretty的方式显示返回数据

```shell
echo "DBQuery.prototype._prettyShell = true" >> ~/.mongorc.js  # Linux
```

在windows下可以找到`C:\Users\用户名\.mongorc.js`文件，然后在里面写入`DBQuery.prototype._prettyShell = true`

#### AND运算符

mongodb中没有类似于其他数据库的AND运算符，当find()中传入多个键值对时，Mongodb就会将其作为AND查询处理

**用法**：`db.COLLECTION_NAME.find({key1:value1, key2:value2})`

```js
>  db.post.find({"by":"mongodb", "likes":20})
```

上面的语句就可以查询出by字段为“mongodb”，likes字段为“20”的所有记录

它对应的关系型SQL语句为：

```mysql
SELECT * FROM post WHERE by='mongodb' AND likes=20
```

#### OR运算符

mongodb中，OR查询语句以`$or`作为关键词

**用法**：

```js
> db.post.find(
	{
		$or:[
			{key1:value1},{key2,value2}
		]
	}
)
```

```js
> db.post.find({
    $or: [{by:"mongodb"}, {title:"MongoDB Overview"}]
})
```

它对应的关系型SQL语句为：

```js
SELECT * FROM post WHERE by='mongodb' OR title='MongoDB Overview'
```

#### 比较运算符

```js
> db.post.find({
	"likes":{$gt:10},
	$or:[
		{by:"mongodb"}, 
		{title:"MongoDB Overview"}
	]
})
```

- `$gt` ：大于  greater than
- `$lt` ：小于  less than
- `$gte` ：大于等于  greater than equal
- `$lte` ： 小于等于 less than equal

#### 模糊查询

mongodb的模糊查询可以使用正则匹配的方式实现：

```
# 以'start'开头的匹配
{"name":/^start/}
# 以'tail'结尾的匹配
{"name":/tail$/}
```

**实践**：

插入以下数据：

```js
> use student

> db.student.insert([
    {name:"张三", age:18, gender:"男" },
    {name:"李雷", age:25, gender:"男"},
    {name:"韩梅梅", age:23, gender:"女"}
    {name:"张益达", age:20, gender:"男"}
])
```

查询学生库，学生集合中姓张且年龄不小于20岁的男同学

```js
db.student.find({
    name: /^张/,
    age:{$gte:20},
    gender:"男"
})
```

