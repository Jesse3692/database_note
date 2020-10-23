# Datebase学习笔记

## MySQL数据库



## Mongodb数据库

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

### 文档基本操作

#### 数据库的操作

**创建数据库**：

- `use mydb` 创建数据库
- `db` 查看当前连接的数据库
- `show dbs` 查看所有的数据库

**销毁数据库**：

- `db.dropDatabase()`

#### 集合的操作

**创建集合**：

语法：`db.createCollection(name, options(可选))`

- `db.createCollection("users")`创建集合
- `show collections`查看创建的集合

**options**：

- capped：类型为Boolean，默认为false，为true则创建固定大小的集合，当其条目达到最大时自动覆盖以前的条目。与size一起使用。
- autoIndexId：类型为Boolean，默认为false，如果设置为true，则会在_id字段上自动创建索引
- size：单位为byte，如果capped为true则需要指定
- max：指定的最大文档数

mongodb可以在创建文档时自动创建集合

**删除集合**：

语法：`db.COLLECTION.drop()`

- `db.users.drop()`删除集合

#### 文档的操作

**插入文档**：

语法：`db.COLLECTION_NAME.insert(document)`

之前是直接在document中写入数据，这里也可以通过参数赋值的方式

```js
> stud1 = ({name:'王五', age:26, gender:'男'})
> db.student.insert(stud1)
```

**更新文档**：

语法：`db.COLLECTION_NAME.update(SELECTION_CRITERIA, UPDATED_DATA)`

```js
> db.student.update({name:"张三"}, 
    {$set:{email:"zhangsan@qq.com"}}, 
)
> db.student.find({name:"张三"})
```

- 将name:"张三"的文档的email修改为`zhangsan@qq.com`
- 第一个大括号中的内容是查找条件，第二个大括号则表示要更新的数据（注意：$set是固定写法，如不加则用更新数据覆盖原先数据，相当于原先数据丢失）
- 默认的update函数只对一个文档更新，如果想作用所有文档，则需要加入`mutil:true`

```js
> db.student.update({name:/^张/}, 
    {$set:{email:"test@qq.com"}}, 
    { multi: true, upsert: false}
)

> db.student.find({name:/^张/})
```

**替换已存在的文档**：

语法：`db.COLLECTION_NAME.save({_id:ObjectId(), NEW_DATA})`

**删除文档**：

语法：`db.COLLECTION_NAME.remove(DELECTION_CRITERIA)`

这里的删除参数相当于查找条件

### 查询、索引与聚合

#### 查询语句 find()

语法：`db.COLLECTION_NAME.find(Parameter)`

**条件操作符1**

mongodb中的条件操作符有：

- `$gt` ：大于  greater than
- `$lt` ：小于  less than
- `$gte` ：大于等于  greater than equal
- `$lte` ： 小于等于 less than equal

```js
> db.shiyanlou.find({user_id:{$gt:1}})
> db.shiyanlou.find({user_id:{$lte:2, $gt:1}})
```

**条件操作符2**

语法：`$type:[key]`

key的值如下：

- 1：双精度型（Double）
- 2：字符串（String）
- 3：对象（Object）
- 4：数组（Array）
- 5：二进制数据（Binary data）
- 7：对象ID（Object id）
- 8：布尔类型（Boolean）
- 9：日期（Date）
- 10：空（Null）
- 11：正则表达式（Regular Expression）
- 13：JS代码（JavaScript）
- 14：符号（Symbol）
- 15：有作用域的JS代码（JavaScript with scope）
- 16：32位整型数（32-bit integer）
- 17：时间戳（Timestamp）
- 18：64位整型数（64-bit integer）
- -1：最小值（Min key）
- 127：最大值（Max key）

```js
> db.shiyanlou.find({"name":{$type:2}})
等同于
> db.shiyanlou.find({"name":{$type:'string'}})
```

**limit()与skip()**

读取指定数量的数据记录`limit()`

```js
> db.shiyanlou.find().limit(1)
```

读取一条记录，默认是排在最前面的那一条数据被读取。

读取数据时跳过指定数量的数据记录`skip()`

```js
> db.shiyanlou.find().limit(1).skip(1)
```

**排序sort()**

mongodb中的排序有升序和降序，其中升序用1表示，降序用-1表示

语法：`db.COLLECTION_NAME.find().sort({KEY:1|-1})`

```js
> db.shiyanlou.find().sort({"time":1})
```

#### 索引ensureIndex()

索引通常能够极大的提高查询的效率，如果没有索引，mongodb在读取数据的时候必须扫描集合中的每个文件并选取那些符合查询条件的记录，而这种扫描全集合的查询效率是非常低的，特别是在处理大量的数据时，查询可能要花费几十秒甚至几分钟，这无疑对网站的性能是非常致命的。

索引是特殊的数据结构，索引存储在一个易于遍历读取的数据集合中，索引是对数据库集合中一个文档或者多个文档的值进行排序的一种结构。

语法：`db.COLLECTION_NAME.ensureIndex({KEY:1|-1})`

跟上面排序同样，1代表升序，-1代表降序

```js
> db.shiyanlou.ensureIndex({"name":1})
```

`ensureIndex()`的可选参数：

|        参数        |     类型      |                      描述                       |
| :----------------: | :-----------: | :---------------------------------------------: |
|     background     |    Boolean    | 建立索引时要不要阻塞其他数据库操作，默认为false |
|       unique       |    Boolean    |          建立的索引是否唯一，默认false          |
|        name        |    String     |       索引的名称，若未指定，系统自动生成        |
|      dropDups      |    Boolean    |   建立唯一索引时，是否删除重复记录，默认false   |
|       sparse       |    Boolean    |   对文档不存在的字段数据不启用索引，默认false   |
| expireAfterSeconds |    Integer    |          设置集合的生存时间，单位为秒           |
|         v          | Index version |                  索引的版本号                   |
|      weights       |   Document    |            索引权重值，范围为1到9999            |
|  default-language  |    String     |                   默认为英语                    |
| language_override  |    String     |                默认值为language                 |

```js
> db.shiyanlou.ensureIndex({"user_id":1, "name":1}, {background:1})
```

#### 聚合aggregate()

语法：

```js
db.COLLECTION_NAME.aggregate({
	$match:{x:1},
	{limit:NUM},
	$group:{_id:$age}
})
```

参数：

- `$match`：查询，跟find一样
- `$limit`：限制显示结果数量
- `$skip`：忽略结果数量
- `$sort`：排序
- `$group`：按照给定表达式组合结果

```js
> db.shiyanlou.aggregate([{$group:{_id:"$name", user:{$sum:"$user_id"}}}])
```

`$name` 意为取得name的值，然后再使用`$user_id`取得user_id的值并使用`$sum`进行求和运算

![image-20200712115751048](https://i.loli.net/2020/07/12/nVFwQEhrg5dsXUa.png)

**聚合表达式**：

|    名称     |                    描述                    |
| :---------: | :----------------------------------------: |
|   `$sum`    |                  计算总和                  |
|   `$avg`    |                 计算平均值                 |
|  min和max   |             计算最小值和最大值             |
|   `$push`   |        在结果文档中插入值到一个数组        |
| `$addToSet` | 在结果文档中插入值到一个数组，但不创建副本 |
|  `$first`   |   根据资源文档的排序获取到第一个文档数据   |
|   `$last`   |  根据资源文档的排序获取到最后一个文档数据  |

**管道**：

mongodb的聚合管道将mongodb文档在一个管道处理完毕后将结果传递给下一个管道处理。管道操作时可以重复的。

表达式：处理输入文档并输出。表达式是无状态的，只能用于计算当前聚合管道的文档，不能处理其它的文档。

聚合框架中常用的几个操作：

- `$project`：修改输入文档的结构。可以用来重命名、增加或删除域，也可以用于创建计算结果以及嵌套文档
- `$match`：用于过滤数据，只输出符合条件的文档。`$match`使用mongodb的标准查询操作
- `$limit`：用来限制mongodb聚合管道返回的文档数
- `$skip`：在聚合管道中跳过指定数量的文档，并返回余下的文档
- `$unwind`：将文档中的某一个数组类型字段拆分为多条，每条包含数组中的一个值
- `$group`：将集合中的文档分组，可用于统计结果
- `$sort`：将输入文档排序后输出
- `$geoNear`：输出接近某一地理位置的有序文档

```js
> db.shiyanlou.aggregate([{$match:{user_id:{$gt:0,$lte:2}}},{$group:{_id:"user",count:{$sum:1}}}])

{"_id":"user","count":2}
```

![image-20200712142233209](https://i.loli.net/2020/07/12/YbH8iMBuZvp95et.png)