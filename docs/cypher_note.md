# cypher_note

## 一、 create 创建

### 1. create nodes 创建节点

#### 1.1 创建单个节点

```cql
create (n)
```

_Created 1 node, completed after 2 ms._

#### 1.2 创建多个节点

```CQL
create (n), (m)
```

_Created 2 nodes, completed after 2 ms._

#### 1.3 创建带有标签的节点

```cql
create(n:Person)
```

_Added 1 label, created 1 node, completed after 4 ms._

#### 1.4 创建具有多个标签的节点

```cql
create(n:Person:Swedish)
```

_Added 2 labels, created 1 node, completed after 2 ms._

#### 1.5 创建节点并添加标签和属性

```CQL
create (n:Person {name:'Andy', title:'Developer'})
```

_Added 1 label, created 1 node, set 2 properties, completed after 43 ms._

#### 1.6 返回创建的节点

这会创建一个节点

```CQL
create (a {name:'Andy'}) return a.name
```

_Created 1 node, set 1 property, started streaming 1 records after 2 ms and completed after 3 ms._

### 2. create relationships 创建关系

#### 2.1 在两个节点之间建立关系

前置操作：

```CQL
create (a:Person {name:'A'}), (b:Person {name:'B'})
```

_Added 2 labels, created 2 nodes, set 2 properties, completed after 18 ms._

```CQL
match (a:Person), (b:Person)
where a.name = 'A' and b.name = 'B'
create (a)-[r:RELTYPE]->(b)
return type(r)
```

_Created 1 relationship, started streaming 1 records after 1 ms and completed after 62 ms._

#### 2.2 创建关系并设置属性

```CQL
match (a:Person), (b:Person)
where a.name = 'A' and b.name = 'B'
create (a)-[r:RELTYPE {name:a.name + '<->' + b.name}]->(b)
return type(r), r.name
```

_Set 1 property, created 1 relationship, started streaming 1 records after 3 ms and completed after 10 ms._

### 3. create a full path 创建一个完整的路径

```CQL
create p =(andy {name:'Andy'})-[:WORKS_AT]->(neo)<-[:WORKS_AT]-(michael {name:'Michael'})
return p
```

_Displaying 3 nodes, 2 relationships_

<img src="https://i.loli.net/2020/10/28/4IiolLBa3m6Ukqy.png" alt="image-20201028190228099" style="zoom:80%;" />

### 4. use parameters with create 在创建时使用参数

#### 4.1 创建带有属性节点的参数

```js
{
    "props":{
        "name":"Andy",
        "position":"Developer"
    }
}
```

```CQL
create (n:Person $props) return n
```

cypher 中不能写 js，故不能执行成功

```cql
create (n:Person {name:"Andy", position:"Developer"}) return n
```

#### 4.2 为多个节点的属性创建一个参数

```js
{
    "props":[
        {
            "name":"Andy",
            "position":"Developer"
        },
        {
            "name":"Michael",
            "position":"Developer"
        }
    ]
}
```

```CQL
unwind $props as map
create (n)
set n = map
```

cypher 中不能写 js，故不能执行成功

```CQL
unwind [{name:"Andy", position:"Developer"}, {name:"Michael", position:"Developer"}] as map create (n) set n = map return n
```

## 二、remove 移除

示例的数据结构：

<img src="https://i.loli.net/2020/10/28/6RS7gJjxpmhLyFn.png" alt="image-20201028222814040" style="zoom:80%;" />

创建的语句：

```CQL
create p=(peter:Swedish:German {name:'Peter', age:34})<-[:KNOWS]-(andy:Swedish {name:'Andy', age:36})-[:KNOWS]->(timothy:Swedish {name:'Timothy', age:25}) 
return p
```

<img src="https://i.loli.net/2020/10/28/IeDmr1ZEhVxSOcp.png" alt="image-20201028222401520" style="zoom:80%;" />

### 1. 移除单个属性

```CQL
match (a {name:'Andy'}) remove a.age 
return a.name, a.age
```

删除之前：

<img src="https://i.loli.net/2020/10/28/DWY2EHxcR8kN9IJ.png" alt="image-20201028225605822" style="zoom:80%;" />

删除之后：

<img src="https://i.loli.net/2020/10/28/VSXlQbgE7W6rTGN.png" alt="image-20201028225816898" style="zoom:80%;" />

### 2. 移除所有属性

remove 不能用来从节点和关系中移除现有的节点和关系

使用 set 来移除所有属性：

```CQL
match (p {name:'Peter'}) set p = {} 
return p.name, p.age
```

### 3. 从一个节点中移除一个标签

```CQL
match (n {name:'Peter'}) remove n:German 
return n.name, labels(n)
```

未移除之前：

<img src="https://i.loli.net/2020/10/28/Bz6EdOVPqhoySu1.png" alt="image-20201028231152729" style="zoom:80%;" />

移除之后：

<img src="https://i.loli.net/2020/10/28/S2X7YnBvQUMVq8r.png" alt="image-20201028231254707" style="zoom:80%;" />

<img src="https://i.loli.net/2020/10/28/LdeEODHM5Ni7vFr.png" alt="image-20201028230949892" style="zoom: 67%;" />

### 4. 从一个节点移除多个标签

```CQL
match (n {name:'Peter'}) remove n:German:Swedish 
return n.name , labels(n)
```

移除之前：

<img src="https://i.loli.net/2020/10/28/Bz6EdOVPqhoySu1.png" alt="image-20201028231152729" style="zoom:80%;" />

移除之后：

<img src="https://i.loli.net/2020/10/28/jGXhlC7i3HfbvmP.png" alt="image-20201028233318933" style="zoom:80%;" />

<img src="https://i.loli.net/2020/10/28/VNkIbxhiWyAnaT4.png" alt="image-20201028232750139" style="zoom:80%;" />

## 三、delete 删除

示例的数据结构：

<img src="https://i.loli.net/2020/10/28/hQ65mNDjey9AZx7.png" alt="image-20201028234821216" style="zoom:80%;" />

创建的语句：

```CQL
create p=(timothy:Person {name:'Timothy', age:25})<-[:KNOWS]-(andy:Person {name:'Andy', age:36})-[:KNOWS]->(peter:Person {name:'Peter', age:34}) 
return p
```

```CQL
create (unknown:Person {name:'UNKNOWN'})
```

<img src="https://i.loli.net/2020/10/28/V65EbCAd2wYmMj3.png" alt="image-20201028235002508" style="zoom:80%;" />

### 1. 删除单个节点

```CQL
match (n:Person {name:'UNKNOWN'}) delete n
```

<img src="https://i.loli.net/2020/10/28/XcnpR4JESPYCTMj.png" alt="image-20201028235430603" style="zoom:80%;" />

### 2. 删除所有的节点和关系

```CQL
match (n) detach delete n
```

### 3. 删除一个节点以及与它关联的关系

```CQL
match (n {name:'Andy'}) detach delete n
```

_Deleted 1 node, deleted 2 relationships, completed after 2 ms._

<img src="https://i.loli.net/2020/10/28/45UKe1urbgTlB6h.png" alt="image-20201028235743522" style="zoom:80%;" />

### 4. 只删除关系

```CQL
match (n {name:'Andy'})-[r:KNOWS]->() delete r
```

_Deleted 2 relationships, completed after 3 ms._

<img src="https://i.loli.net/2020/10/29/JFRi4cf9OUjLKEB.png" alt="image-20201029000136198" style="zoom:80%;" />

## 四、 match 匹配

<img src="https://i.loli.net/2020/10/29/7eoDw9hGfqbQ6Xt.png" alt="image-20201029215018033" style="zoom:80%;" />

样例数据插入：

```CQL
create (o:Person {name:'Oliver Stone'}), (m:Person {name:'Michael Douglas'}), (c:Person {name:'Charlie Sheen'}), (s:Person {name:'Martin Sheen'}), (r:Person {name:'Rob Reiner'}), (w:Movie {title:'Wall Street'}), (t:Movie {title:'The American President'})
create (o)-[:DIRECTED]->(w)
create (m)-[:ACTED_IN {role:'Gordon Gekko'}]->(w)
create (c)-[:ACTED_IN {role:'BUd Fox'}]->(w)
create (s)-[:ACTED_IN {role:'Carl Fox'}]->(w)
create (m)-[:ACTED_IN {role:'President Andrew Shepherd'}]->(t)
create (s)-[:ACTED_IN {role:'A.J.MacInerney'}]->(t)
create (r)-[:DIRECTED]->(t)
return o,m,c,s,r,w,t
```

<img src="https://i.loli.net/2020/10/29/8nhY5TLqS1Gaz9B.png" alt="image-20201029201833854" style="zoom:80%;" />

### 1. 基本节点查找

#### 1.1 获取所有节点

```CQL
match (n) return n
```



#### 1.2 获取带标签的所有节点

```CQL
match (movie:Movie) return movie.title
```



#### 1.3 相关节点`--`

```CQL
match (director {name:'Oliver Stone'})--(movie) return movie.title
```



#### 1.4 与标签匹配

```CQL
match (:Person {name:'Oliver Stone'})--(movie:Movie) return movie.title
```

不太明白

### 2. 基本关系

#### 2.1 外向的关系

```CQL
match (:Person {name:'Oliver Stone'})-->(movie) return movie.title
```

外向关系有`-->`和`<---`，它可以返回任何与该节点连接的节点（注意箭头方向）

#### 2.2 直接关系和变量

```cql
match (:Person {name:'Oliver Stone'})-[r]->(movie) return type(r)
```

不太明白

#### 2.3 匹配关系类型

```CQL
match (wallstreet:Movie {title:'Wall Street'})<-[:ACTED_IN]-(actor) return actor.name
```

使用冒号和关系类型来进行匹配

#### 2.4 匹配多种关系类型

```cql
match (wallstreet {title:'Wall Street'})<-[:ACTED_IN|:DIRECTED]-(person) return person.name
```

使用`|`匹配多个关系类型

#### 2.5 匹配关系类型并使用变量

```cql
match (wallstreet {title:'Wall Street'})<-[r:ACTED_IN]-(actor) return r.role
```

在关系类型中使用变量

### 3. 深度关系

![image-20201029220048215](https://i.loli.net/2020/10/29/vPWcyEjC4boaLYN.png)

样例数据插入（在原先数据库上操作）：

在`Rob Reiner`和`Charlie Sheen`之间添加一个新的关系`TYPE INCLUDING A SPACE`

```cql
match (r:Person {name:'Rob Reiner'}), (c:Person {name:'Charlie Sheen'})
create (r)-[:`TYPE INCLUDING A SPACE`]->(c)
```

<img src="https://i.loli.net/2020/10/29/idSIRZJnx9hTa7e.png" alt="image-20201029220023203" style="zoom:80%;" />

#### 3.1 关系类型中包含不常用字符时的查找

```CQL
match (n {name:'Rob Reiner'})-[r:`TYPE INCLUDING A SPACE`]->() return type(r)
```

返回包含空格的关系类型

#### 3.2 多重关系

```cql
match (charlie {name:'Charlie Sheen'})-[:ACTED_IN]->(movie)<-[:DIRECTED]-(director) return movie.title, director.name
```

返回查理·辛出演的电影和电影的导演。

#### 3.3 可变长度关系

语法：`[:TYPE*minHops..maxHops]`

```cql
match (charlie {name:'Charlie Sheen'})-[:ACTED_IN*1..3]-(movie:Movie)
return movie.title
```

返回所有与`Charlie Sheen`有关的电影，1-3个跳数

不太明白

<img src="https://i.loli.net/2020/10/29/nbiPdZSCLFqG9Xf.png" alt="image-20201029232053920" style="zoom:80%;" />



#### 3.4 具有多种关系类型的可变长度关系



#### 3.5 可变长度关系中的关系变量

#### 3.6 匹配可变长度路径上的属性

#### 3.7 零长度路径

#### 3.8 命名路径

#### 3.9 绑定关系上的匹配

### 4. 最短路径

#### 4.1 单一最短路径

#### 4.2 带谓词的单个最短路径

#### 4.3 所有最短的路径

### 5. 通过id获取节点或关系

#### 5.1 通过id获取节点

#### 5.2 通过id获取关系

#### 5.3 通过id获取多个节点