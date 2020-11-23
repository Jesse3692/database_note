# redis_note

## 基本数据类型

![image-20201107214821950](https://i.loli.net/2020/11/07/UYCFEyLbHh7RK9g.png)

### 字符串常用操作

- 选择数据库 `select 0` 【0-15】

- 赋值 `set key value`
- 取值 `get key`
- 递增数字 `incr key`
- 递减数字 `decr key`
- 增加指定的整数 `incrby key increment`
- 减少减少指定的整数 `decrby key decrement`
- 增加指定的浮点数 `incrbyfloat key increment`
- 向尾部追加值 `append key value`
- 获取字符串长度 `strlen key`
- 同时设置多个键值 `mset key value [key1 value1...]`
- 同时获取多个键值 `mget key [key1...]`
- 位操作

### 散列类型

- 赋值 `hset key field value`[^1]
- 取值 `hget key field`
- 同时设置多个键值 `hmset key field value [field1 value1...]`
- 同时获取多个键值 `hmget key field [field1...]`
- 获取多个键和值 `hgetall key`
- 判断字段是否存在 `hexists key field`
- 设置多个字段的值 `hmset key field1 value1 field2 value2...`
- 获取多个字段的值 `hmget key field1 field2`
- 当字段不存在时赋值 `hsetnx key field value` 当字段已存在时，不执行任何操作
- 递增数字 `hincrby key field increment` 使字段值增加指定的整数

### 列表

### 集合

### 有序集合

[^1]: hset 命令

hset 命令的方便之处在于不区分插入和更新操作，这意味着修改数据时不用事先判断字段是否存在来决定要执行的是插入操作（insert）还是更新操作（update）。当执行的是插入操作时（即之前字段不存在）hset 命令会返回 1，当执行的是更新操作时（即之前的字段已经存在）hset 命令会返回 0。当键本身不存在时，hset 命令还会自动建立它。

redis 中常见的问题：

缓存雪崩：

当缓存重启或者大量的缓存在某一时间失效，这样就导致大批流量直接访问数据库，对 db 造成压力，从而引起 db 故障，系统崩溃。

解决方案：

①：根据热度做分类，热点数据缓存周期长一点，冷门数据缓存周期短一些。

②：设置缓存失效时间时，可以加上一个随机的区间因子。

③：提前预估 db 能力，如果缓存挂掉，数据库仍可以在一定程度上抗住流量的压力

缓存预热：

系统上线后，将相关的缓存数据直接加载到缓存系统

解决方案：

①：数据量不大时，在工程启动时加载缓存

②：设置定时任务脚本，进行缓存的刷新。

③：数据量太大的时候，优先保证热点数据进行提前加载到缓存。

缓存降级：

降级的情况，就是缓存失效或者缓存服务挂掉的情况下，我们也不去访问数据库。我们直接访问内存部分数据缓存或者直接返回默认数据。

解决方案：对热点数据缓存的同时，也将数据存储到内存中（默认数据也放在内存中）。
