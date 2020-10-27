# neomodel 官方手册笔记

```python
from config import (
    neo4j_uri, neo4j_username, neo4j_password
)
from neomodel import config
from neomodel import (
    StructuredNode, StringProperty, IntegerProperty, UniqueIdProperty, RelationshipTo, RelationshipFrom
)
```

```python
# 配置neo4j链接
config.DATABASE_URL = neo4j_uri.format(neo4j_username, neo4j_password)
config.ENCRYPTED_CONNECTION = False
```

```python
class Person(StructuredNode):
    uid = UniqueIdProperty()
    name = StringProperty(unique_index=True)
    age = IntegerProperty(index=True, default=0)
    country = RelationshipTo(Country, 'IS_FROM')

class Country(StructuredNode):
    code = StringProperty(unique_index=True, required=True)
#     inhabitant = RelationshipFrom(Person, 'Persons', model=Person)
```

## 创建、更新、删除操作

```python
# create
jim = Person(name='Jim', age=3).save()
```

```python
# Update, (with validation)
jim.age = 4
jim.save()
```

```python
# delete
jim.delete()
```

```python
# # reload properties from the database
jim.refresh()
```

```python
# # neo4j internal id
jim.id
```

## 检索节点

### 使用.nodes class 属性

```python
# return all nodes
Person.nodes.all()
```

```python
# Returns Person by Person.name=='Jim' or raises neomodel.DoesNotExist if no match
Person.nodes.get(age=4)
```

```python
# will return None unless "bob" exists
Person.nodes.get_or_none(name='bob')
```

```python
# Will return the first Person node with the name bob. This raises neomodel.DoesNotExist if there's no match.
Person.nodes.first(name='bob')
```

```python
# Will return the first Person node with the name bob or None if there's no match
Person.nodes.first_or_none(name='bob')
```

```python
# return set of nodes
Person.nodes.filter(age__gt=3)
```

## 人际关系

### 处理人际关系

```python
germany = Country(code='DE').save()
```

```python
jim.country.connect(germany)
```

<img src="https://i.loli.net/2020/10/28/thgiez3Q6CFZBSw.png" alt="image-20201028015000283" style="zoom:80%;" />

```python
if jim.country.is_connected(germany):
    print("Jim's from Germany")
```

```python
for p in germany.inhabitant.all():
    print(p.name)
```

> 参考资料
> [官方文档](https://neomodel.readthedocs.io/en/latest/getting_started.html#relationships)
