**一些概念**：

`数据库`是按照数据结构来组织、存储和管理数据的仓库
`sql`是英文structured query language的缩写，意为结构化查询语言
`orm`是英文object relational mapping的缩写，意为对象关系映射。在Python中我们可以把一个关系数据库的表结构映射到Python类中
python中的`orm框架`有，SQLobject框架、storm框架、django内置的orm、著名的SQLAlchemy

**数据库操作**：

- 连接数据库：mysql -h 127.0.0.1 -uroot -p 123456
- 创建指定字符集的数据库：create database study character set = UTF8;
- 查看MySQL数据库的默认编码格式：show variables like 'char%database';
- 查看数据库的创建信息：show create database study\G;

**创建引擎 create_engine**

```python
from sqlalchemy import create_engine
# 参数说明：数据库类型+驱动://用户名:密码@主机:端口号/数据库名?charset=编码格式
engine = create_engine('mysql://root@127.0.0.1:3306/study?charset=utf8')
```

**创建映射类需要继承声明基类**，使用declarative_base：

```python
from sqlalchemy.ext.declarative import declarative_base
# 创建声明基类时传入引擎
Base = declarative_base(engine)
```

创建映射类须继承声明基类。首先创建user数据表的映射类，此表存放用户数据，也就是课程作者的数据：

```python
# Column定义字段，Integer、String分别为整数和字符串数据类型
from sqlalchemy import Column, Integer, String

class User(Base):  # 继承声明基类
    __tablename__ = 'user'  # 设置数据表名字，不可省略
    id = Column(Integer, primary_key=True)  # 设置该字段为主键
    # unique设置唯一约束，nullable设置非空约束
    name = Column(String(64), unique=True, nullable=False)
    email = Column(String(64), unique=True)

    # 定义实例的打印样式
    def __repr__(self):
        return '<User: {}>'.format(self.name)
```

**一对多关系**

```python
from sqlalchemy import ForeignKey
from sqlalchemy.orm import relationship, backref

class Course(Base):
    __tablename__ = 'courses'
    id = Column(Integer, primary_key=True)
    name = Column(String(64))
    # Foreignkey 设置外键关联，第一个参数为字符串， user为数据表名，id为字段名
    # 第二个参数ondelete 设置删除user实例后对关联的course实例的处理规则
    # CASCADE表示级联删除，删除用户实例后，对应的课程实例也会被连带删除
    user_id = Column(Integer, ForeignKey('user.id', ondelete="CASCADE"))
    # relationship设置查询接口，以便后期进行数据库查询操作
    # 第一个参数为位置参数，参数值为外键关联的映射类名，数据类型为字符串
    # 第二个参数backef设置反向查询接口
    # backref的第一个参数 course为查询属性，User实例使用该属性可以获得相关课程实例的列表
    # backref的第二个参数cascade如此设置即可实现Python语句删除用户数据时级联删除课程数据
    user = relationship('User',
        backref=backref('course', cascade='all, delete-orphan'))

    def __repr__(self):
    return '<Course: {}>'.format(self.name)
```

定义列时常用参数表：

|   参数   |  说明    |
| :--: | :--: |
|   primary_key   |   如果设为True，这列就是表的主键   |
|   unique   |   默认是为False，如果设为True，这列不允许出现重复的值   |
|   index   |   如果设为True，为这列创建索引，提升查询效率   |
|   nullable   |   默认值为True，这列允许使用空值；如果设为False，这列不允许使用空值   |
|   default   |   为这列定义默认值   |

常用的SQLAlchemy查询关系选项（在backref中使用）：

|   选项   |   说明   |
| :--: | :--: |
|   backref   |   在关系的另一个映射类中添加反向引用   |
|   lazy   |   指定如何加载记录，select、immediate、joined、noload和dynamic   |
|   cascade   |   设置级联删除方式   |
|   uselist   |   如果设置False，查询结果不使用列表，而使用映射类实例   |
|   order_by   |    指定查询记录的排序方式  |
|   secondary   |   指定多对多关系中关系表的名字   |

**创建数据表**

声明基类Base在创建之后并不会主动连接数据库，因为它的默认设置为惰性模式。Base的metadata有个create_all方法，执行此方法会主动连接数据库并创建全部数据表，完成之后自动断开与数据库的连接

```python
Base.metadata.create_all()
```

[完整的建表代码](https://github.com/Jesse3692/database_note/blob/707d9dd1c1e6bfe95e21a47bd88efa33385710e9/code/mysql_sqlalchemy_db_1.py)

**添加测试数据**

- 安装faker`pipenv install faker`

- 安装ipython`pipenv install ipython`

**伪造数据：**

```python
In [1]: from faker import Faker

In [2]: fake = Faker('zh-cn')  # 伪造中文数据

In [3]: fake.name()
Out[3]: '杜峰'

In [4]: fake.address()
Out[4]: '宁夏回族自治区柳州市双滦长沙街C座 447388'

In [5]: fake.email()
Out[5]: 'qbai@duan.cn'

In [6]: fake.url()
Out[6]: 'http://www.kongfang.cn/'

In [7]: fake.date()
Out[7]: '2018-08-28'
```

**使用session处理数据**

上面写了使用映射类创建数据表要用声明基类Base

处理数据的时候就要用到session了，他是sessionmaker类的实例，该实例实现了__call__方法，本身可以作为函数来执行，返回值就是能够处理数据的session

```python
from sqlalchemy.orm import sessionmaker

# 从之前的model中引入下列对象备用
from db import Base, engine, User,Course
# 将engine引擎作为参数创建session实例
session = sessionmaker(engine)()
```

当我们创建了session实例，就启动了一个操作MySQL数据库的会话

[生成测试数据](https://github.com/Jesse3692/database_note/blob/707d9dd1c1e6bfe95e21a47bd88efa33385710e9/code/create_data.py)

在ipython中操作

```python
# 从create_data中引入相关对象
In [1]: from create_data import User, Course, session, create_courses, create_user 
# 执行创建User实例的函数
In [2]: create_user()
# session查询结果为列表，每个元素就是一个User实例
In [3]: session.query(User).all()
Out[3]:
[<User:马璐>,
 <User:赵文>,
 <User:张洋>,
 <User:王欢>,
 <User:海秀兰>,
 <User:冯宇>,
 <User:叶勇>,
 <User:雷洁>,
 <User:朱桂花>,
 <User:卢海燕>]
# 将某个User实例赋值给user变量
In [4]: user = session.query(User).all()[3]
# 查看实例的相关属性
In [5]: user.name  
Out[5]: '王欢'

In [6]: user.id
Out[6]: 4
# 执行创建Course实例的函数
In [7]: create_courses()
# 查看前四个Course实例的name属性
In [8]: for course in session.query(Course)[:4]:
   ...:     print(course.name)
   ...:
你们你们关系成功
积分服务投资内容
广告程序一种关系
部分这些而且北京
# User实例的course属性为查询接口，通过relationship设置
# 属性值为列表，里面是两个课程实例
In [9]: user.course
Out[9]: [<Course: 汽车发表因此其中>, <Course: 参加女人阅读其中>]
# 将某个课程实例赋值给course变量
In [10]: course = session.query(Course)[12]
# 课程实例的user属性为查询接口，通过relationship设置
In [11]: course.user
Out[11]: <User:叶勇>
# 将全部实例提交到对应的数据表
In [12]: session.commit()
```
接下来删除user实例，验证级联删除功能是否生效

```python
In [13]: session.delete(user)

In [14]: session.commit()
```
查看数据表的情况，如预期，user表中id为4的行被删除，course表中user_id为4的行也被删除


一对一关系

这里我们学习创建一对一关系的数据表。为了方便演示，假设我们的每个课程只有一个实验，我们要创建映射类Lab和实验表lab，课程和实验就是一对一的关系，如何实现这种关系呢？把lab的主键id设置为外键关联到course的主键id即可，因为主键是自带唯一约束的，这样就实现了一对一关系。

创建映射类Lab

```python
class Lab(Base):
    __tablename__ = 'lab'
    # 设置主键为外键，关联course表的id字段
    # 注意参数顺序，先定义外键，再定义主键
    id = Column(Integer, ForeignKey('course.id'), primary_key=True)
    name = Column(String(128))
    # 设置查询接口，Lab实例的course属性值为Course实例
    # Course实例的lab属性值默认为列表，列表中有一个Lab实例
    # uselist参数可以设置Course实例的lab属性值为Lab实例而非列表
    course = relationship('Course', backref=backref('lab', uselist=False))

    def __repr__(self):
        return '<Lab: {}>'.format(self.name)
```

保存代码后，在终端运行文件即可生成数据表： `python db.py`


多对多关系

一个课程可以有多个标签，每个标签可以贴在多个课程上，我们需要实现course课程表和tag标签表的多对多关系。

- 一对多关系： 一个User实例（课程教师）对应多个Course实例，一个Course实例对应一个User实例

- 一对一关系： 一个Course实例对应一个Lab实例，一个Lab实例对应一个Course实例

- 多对多关系： 一个Course实例对应多个Tag实例，一个Tag实例对应多个Course实例

满足上述需求的多对多关系，需要在创建Tag映射类之前，首先创建中间表的映射类，用Table这个特殊类创建，此类的实例就是映射类

```python
# 创建Table类的实例，即中间表映射类，赋值给变量Rela
# 该类子啊实例化时，接收4个参数：
# ① 数据表名字 ②Base metadata
# ③和④两个Column（列名，数据类型，外键，主键）
Rela = Table('rela', Base.metadata,
    Column('tag_id', Integer, ForeignKey('tag.id'), primary_key=True),
    Column('course_id', Integer, ForeignKey('course.id'), primary_key=True)
)
```

有了中间表的映射类，就可以创建tag表的映射类Tag了

```python
class Tag(Base):
    __tablename__ = 'tag'
    id = Column(Integer, primary_key=True)
    name = Column(String(64), unique=True)
    # 设置查询接口，secondary指定多对多关系的中间表，注意数据类型不是字符串
    course = relationship('Course', secondary=Rela, backref='tag')

    def __repr__(self):
        return '<Tag: {}>'.format(self.name)
```

同样的，终端运行文件生成数据表： `python db.py`

注意：中间表是真是存在的数据表，它有两个字段，当我们给课程添加标签时，该表会记录相关信息：

下面对`create_data.py`文件补充一些代码，我们用10个随机中文汉字作为lab表的name字段的值，创建20个Lab类的实例，10个Tag类的实例

```python
from db import Lab, Tag

def create_labs():
    for course in session.query(Course):
        lab = Lab(name=''.join(fake.words(5)), id=course.id)
        session.add(lab)

def create_user():
    for name in ['python', 'linux', 'java', 'mysql', 'lisp']:
        tag = Tag(name=name)
        session.add(tag)
```

启动命令行交互解释器ipython，引入相关对象，执行创建数据的函数

```python
In [1]: from create_data import *

In [2]: create_labs()

In [3]: create_tags()

In [4]: session.commit()
```

查看数据库内数据

```sql
select * from lab;

select * from tag;
```

给课程添加标签

课程实例有tag属性，这是在映射类中设置的查询接口，标签实例也有对应的查询接口course，它们的属性值均为空列表，如果要给课程添加标签，只需要将标签实例添加到tag属性的列表中，给标签添加课程同理

```python
# 通过查询将两个课程实例赋值给变量c1,c2 将两个标签实例赋值给 t1, t2
In [5]: c1 = session.query(Course)[3]

In [6]: c2 = session.query(Course)[11]

In [7]: t1 = session.query(Tag)[1]

In [8]: t2 = session.query(Tag)[2]

# 课程的tag属性默认为空列表
In [9]: c1.tag
Out[9]: []

# 将标签实例添加到列表
In [10]: c1.tag.append(t1)

In [11]: c1.tag.append(t2)

# 标签的course属性里就有了对应的课程实例
In [12]: t1.course
Out[12]: [<Course: 选择只有只有市场>]

# 当然了，课程实例的tag属性里有了两个标签实例
In [13]: c1.tag
Out[13]: [<Tag: linux>, <Tag: lisp>]

In [14]: t2.course.append(c2)

In [15]: c2.tag
Out[15]: [<Tag: lisp>]

# 执行session.commit() 即可将它们的关系传入数据库中
In [16]: session.commit()
```

查看数据库的中间表，可以看到给课程添加标签后，每组关系都被保存在该表中

```sql
select * from rela;
```