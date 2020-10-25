neo4j在整个项目中的作用是：得到发行人的股权结构，并通过运算得到想要的干系人。

数据是由两个csv文件提供，一个是`company.csv`，另一个是`relationship.csv`

```CQL
# company.csv
name
神华甘泉铁路有限责任公司,
# relationship.csv
p_name,s_name,per_text,per_float
全国社会保障基金理事会,中国东方资产管理股份有限公司,8.4400%,0.0844
```

1. 创建节点（添加唯一约束）

   ```CQL
   create constraint on (n:Company) assert n.name is unique
   ```

   *added 1 constraint*

   此时neo4j浏览器中的 `Node Labels` 会显示有 `Company`

2. 加载节点数据（这里得修改配置文件[^1]）

   ```CQL
   load csv with headers from "file:/company.csv" as row create (n:Company) set n=row;
   ```

   *added 181 labels, create 181 nodes, set 181 properties*

3. 加载关系数据并创建关系

   ```cql
   load csv with headers from "file:/relationship.csv" as line
   mathch (from:Company{name:line.p_name}), (to:Company{name:line.s_name})
   merge (from)-[r:HOLDING_SHARES{percent:toFloat(line.per_float), percent_text:line.per_text}] -> (to);
   ```

   *set 374 properties, created 187 relationships*

   此时的neo4j浏览器中的 `Property Keys`会显示 `per_float`、`per_text`、 `name`，而 `Relationship Types`中则显示 `HOLDING_SHARES`

4. 查询刚才的数据

   ```
   match p=()-[r:HOLDING_SHARES]->() return p limit 25
   ```

   以下就是查询后的具体效果：





<img src="https://i.loli.net/2020/10/25/K3htkbrVOMoScDB.png" alt="image-20201025185424922" style="zoom: 78%;" />

> 参考资料：
>
> [删除节点中多个属性的方法](https://www.jianshu.com/p/f9dfa0d513ca)
>
> [删除节点和关系、彻底删除节点标签名](https://www.jianshu.com/p/59bd829de0de)
>
> [删除标签](https://stackoverflow.com/questions/21983425/how-to-delete-labels-in-neo4j)
>
> [neo4j中文教程](http://neo4j.com.cn/public/cypher/default.html)



[^1]:`neo4j.conf`配置文件

```ini
dbms.default_listen_address=0.0.0.0

dbms.memory.pagecache.size=512M
# 必须得添加这个配置
dbms.directories.import=/var/lib/neo4j/import
dbms.tx_log.rotation.retention_policy=100M size
dbms.memory.heap.maxSize=4G
dbms.directories.logs=/logs
```

