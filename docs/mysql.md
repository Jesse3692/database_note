## 数据库和数据表的常用操作

### 数据库

通过环境变量创建的docker容器数据库，其编码为latin1

- 创建数据库：`create database [if not exists] db_name [DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci]`;

- 查看已有的数据库：show database;

- 使用数据库：use db_name;

- 查看 MySQL 的默认编码：show variables like '%character%';

- 修改数据库编码：alter database db_name character set utf8;

- 删除数据库：drop database [if not exists] db_name;

  

### 数据表

- 创建数据表：create table tb_name [if not exists] (column_name data_type );
-

### MySQL 性能优化

查询数据库中的慢日志记录：

`show global status like '%Slow_queries%';`

#### 慢日志：

开启慢日志，在配置文件`my.ini`添加以下内容

```ini
# 开启慢查询日志
# 定义超过多少秒的查询算是慢查询，这里定义的是2秒
long_query_time=1
# 定义慢查询日志的路径（注意如果是 Linux 或 Mac 系统要考虑权限问题）
slow_query_log=1
slow-query-log-file="D:\\Program Files\\mysql-5.6.42\\bin\\mysql_slow_query.log"
# 记录下没有使用索引的query
# log_queries_not_using_indexes=1
```

使用`mysqldumpslow.pl`分析慢日志：

- 安装`ActivePerl-5.26.3.2603-MSWin32-x64-a95bce075.exe`

按照平均查询时间进行排序，同时取排序的前 20 个

命令参数：

- -s ORDER what to sort by (al, at, ar, c, l, r, t), 'at' is default
  al: average lock time
  ar: average rows sent
  at: average query time
  c: count
  l: lock time
  r: rows sent
  t: query time
- -r reverse the sort order (largest last instead of first)
- -t NUM just show the top n queries
- -a don't abstract all numbers to N and strings to 'S'
- -n NUM abstract numbers with at least n digits within names
- -g PATTERN grep: only consider stmts that include this string
- -h HOSTNAME hostname of db server for _-slow.log filename (can be wildcard),
  default is '_', i.e. match all
- -i NAME name of server instance (if using mysql.server startup script)
- -l don't subtract lock time from total time

![image-20200719230531082](https://i.loli.net/2020/07/19/5kKmnTPgAVxUB2J.png)

|         参数         |         含义         |
| :------------------: | :------------------: |
|        Count         |       出现次数       |
|         Time         |     执行最长时间     |
|         Time         |    累计总耗费时间    |
|         Lock         |     等待锁的时间     |
|         Rows         | 发送给客户端的总行数 |
|         Rows         |     扫描的总行数     |
| root[root]@localhost |   操作的用户和地址   |
|   select sleep(N)    | sql 语句本身（抽象） |

#### explain\desc 查看 sql 语句

![image-20200719234419752](https://i.loli.net/2020/07/19/76pneX4zLcJZ1UB.png)

- id：select 的查询序列号
- select_type：select 的类型
- table：表示当前这一行正在访问哪张表，如果 SQL 定义了别名，则展示表的别名
- type：
- possible_keys
- key
- key_len
- ref
- rows
- Extra

select_type 的类型

|       查询类型       |                                                                                 作用                                                                                  |
| :------------------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
|        SIMPLE        |                                                                   简单查询（未使用 UNION 或子查询）                                                                   |
|       PRIMARY        |                                                                             最外层的查询                                                                              |
|        UNION         |                 在 UNION 中的第二个和随后的 SELECT 被标记为 UNION。如果 UNION 被 FROM 子句中的子查询包含，那么它的第一个 SELECT 会被标记为 DERIVED。                  |
|   DEPENDENT UNION    |                                                            UNION 中的第二个或后面的查询，依赖了外面的查询                                                             |
|     UNION RESULT     |                                                                             UNION 的结果                                                                              |
|       SUBQUERY       |                                                                        子查询中的第一个 SELECT                                                                        |
|  DEPENDENT SUBQUERY  |                                                               子查询中的第一个 SELECT，依赖了外面的查询                                                               |
|       DERIVED        | 用来表示包含在 FROM 子句的子查询中的 SELECT，MySQL 会递归执行并将结果放到一个临时表中。MySQL 内部将其称为是 Derived table（派生表），因为该临时表是从子查询派生出来的 |
|  DEPENDENT DERIVED   |                                                                        派生表，依赖了其他的表                                                                         |
|     MATERIALIZED     |                                                                              物化子查询                                                                               |
| UNCACHEABLE SUBQUERY |                                                        子查询，结果无法缓存，必须针对外部查询的每一行重新评估                                                         |
|  UNCACHEABLE UNION   |                                                         UNION 属于 UNCACHEABLE SUBQUERY 的第二个或后面的查询                                                          |

### 常见术语：

sql: 结构化查询语言（structured query language）

dba: 数据库管理员（database administrator）

dbd: 数据库开发人员（database developer）

DQL: 数据查询语言（select）

DML:数据操作语言（insert，update 和 delete）

DCL:数据控制语言（grant，revoke）

DDL:数据定义语言（create，drop）

TPL:事务处理语言（begin，transaction，commit，rollback）

CCL:指针控制语言（declare，cursor）
